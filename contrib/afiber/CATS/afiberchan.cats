/* ******************************************************************* */
/*                                                                     */
/*                         ATS/contrib/afiber                          */
/*                                                                     */
/* ******************************************************************* */

/*
** Copyright (C) 2026 Mikhail Sorochan
**
** Permission is hereby granted, free of charge, to any person obtaining a
** copy of this software and associated documentation files (the "Software"),
** to deal in the Software without restriction, including without limitation
** the rights to use, copy, modify, merge, publish, distribute, sublicense,
** and/or sell copies of the Software, and to permit persons to whom the
** Software is furnished to do so, subject to the following stated conditions:
**
** The above copyright notice and this permission notice shall be included in
** all copies or substantial portions of the Software.
**
** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
** OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
** FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
** THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
** LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
** FROM OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
** IN THE SOFTWARE.
*/


/* ****** ****** */

/*
** MS-2026-10 (step G):
** afiberchan: the channel object. One C struct, aligned to a cache line,
** holds everything: the lock, the flags, the ring header, both wait
** queues (first line: all of it is written by a send or a receive), then
** the read-mostly [cap] and [tsz] (second line), then the [cap] slots of
** [tsz] bytes (the ring data, in the same allocation). A producer on one
** core and a consumer on another so transfer the first line and the slot
** they touch, and nothing else (before, the lock, the ring header, the
** data and the two wait queues were six separate allocations). The ATS side
** moves the values with ptr0_set/ptr0_get on the slots.
*/

/* ****** ****** */

#ifndef ATSCNTRB_AFIBER_CATS_AFIBERCHAN
#define ATSCNTRB_AFIBER_CATS_AFIBERCHAN

/* ****** ****** */

#include <stdio.h>
#include <stdlib.h>

#include "contrib/afiber/CATS/afiber.cats"

/* ****** ****** */

/*
** MS-2026-10 (step G3'): the direct hand-off. The channel owns a small
** pool of scratch slots (the size of a slot): a parked receiver owns one
** of them, the sender writes the payload into it and wakes the
** receiver, which takes the payload out of it. So a hand-off costs one
** lock acquisition (the sender's) instead of two (the sender's push
** and the receiver's pop), and the ring is not touched at all.
*/
#ifndef ATSCNTRB_AFIBER_CHAN_SCRATCH
#define ATSCNTRB_AFIBER_CHAN_SCRATCH 16 // the number of scratch slots per channel
#endif
#ifndef ATSCNTRB_AFIBER_CHAN_HANDOFF
/*
** MS-2026-10 (step G3'): the hand-off is OFF by default: it does not
** pay off (see contrib/afiber/doc/PLAN.md). The reason: the parking
** protocol takes the channel's lock again when the fiber wakes up (see
** [afiber_waitq_park] in CATS/afiber.cats), so a hand-off still costs
** two lock acquisitions per item (the sender's and the woken
** receiver's): the lock's cache line keeps bouncing between the cores
** and the hand-off only adds work. It would pay off if the wait queue
** did not need the lock (the woken fiber would take the value out of
** its own scratch slot without taking the channel's lock).
*/
#define ATSCNTRB_AFIBER_CHAN_HANDOFF 0 // 1: the direct hand-off is on
#endif

/* the state of a hand-off (in the fiber record) */
#define ATSCNTRB_AFIBER_HO_NONE 0 // no scratch slot
#define ATSCNTRB_AFIBER_HO_WAITING 1 // the fiber is parked and waits for a hand-off
#define ATSCNTRB_AFIBER_HO_HANDED_OFF 2 // the payload is in the scratch slot
#define ATSCNTRB_AFIBER_HO_DONE 3 // the payload was taken out of the scratch slot

typedef
struct {
  /* the first line: hot */
  int lock ; // the spinlock
  int closed ;
  size_t head ; // the oldest item
  size_t n ; // the number of items
  atscntrb_afiber_q recvq ;
  atscntrb_afiber_q sendq ;
  int rfcnt ; // changed (under the lock) only by chan_ref/unref
  /* the second line: read-mostly */
  size_t cap __attribute__((aligned(ATSCNTRB_AFIBER_LINE))) ; // the number of slots
  size_t tsz ; // the size of a slot
  void *scratch_free ; // the free list of the scratch slots (under the lock)
  /* then the slots, from [sizeof(...)] on, then the scratch slots */
} __attribute__((aligned(ATSCNTRB_AFIBER_LINE))) atscntrb_afiberchan_t ;

_Static_assert(offsetof(atscntrb_afiberchan_t, rfcnt) < ATSCNTRB_AFIBER_LINE, "afiberchan: the hot fields are not on the first line") ;
_Static_assert(offsetof(atscntrb_afiberchan_t, cap) == ATSCNTRB_AFIBER_LINE, "afiberchan: cap is not on the second line") ;

#define ATSCNTRB_AFIBERCHAN_DATA(c) ((char*)(c) + sizeof(atscntrb_afiberchan_t))
/* the scratch slots: after the ring slots (which are rounded up) */
#define ATSCNTRB_AFIBERCHAN_SCRATCH(c) \
  ((void*)(((char*)(c) + sizeof(atscntrb_afiberchan_t) \
            + (((c)->cap * (c)->tsz + 7) & ~(size_t)7))))

/* ****** ****** */

ATSinline()
atstype_ptr
atscntrb_afiberchan_make
  (atstype_size cap, atstype_size tsz)
{
  atscntrb_afiberchan_t *c ;
  // a scratch slot is on a cache line of its own (no false sharing)
  size_t slot_size = (tsz < 8) ? 8 : tsz ;
  slot_size = (slot_size + ATSCNTRB_AFIBER_LINE - 1) & ~(size_t)(ATSCNTRB_AFIBER_LINE - 1) ;
  size_t sz = sizeof(atscntrb_afiberchan_t) + cap * tsz ;
  sz = (sz + ATSCNTRB_AFIBER_LINE - 1) & ~(size_t)(ATSCNTRB_AFIBER_LINE - 1) ;
#if ATSCNTRB_AFIBER_CHAN_HANDOFF
  sz += ATSCNTRB_AFIBER_CHAN_SCRATCH * slot_size ;
#endif
  c = (atscntrb_afiberchan_t*)aligned_alloc(ATSCNTRB_AFIBER_LINE, sz) ;
  if (!c) { fprintf(stderr, "afiberchan: out of memory\n") ; abort() ; }
  c->lock = 0 ; c->closed = 0 ; c->head = 0 ; c->n = 0 ;
  c->recvq.head = c->recvq.tail = (atscntrb_afiber_t*)0 ;
  c->sendq.head = c->sendq.tail = (atscntrb_afiber_t*)0 ;
  c->rfcnt = 1 ; c->cap = cap ; c->tsz = tsz ;
  c->scratch_free = (void*)0 ;
#if ATSCNTRB_AFIBER_CHAN_HANDOFF
  {
    // the free list of the scratch slots (the first word of a free slot
    // holds the next one); the slots are at least 8 bytes long
    size_t i ; void *fre = (void*)0 ;
    char *base = (char*)ATSCNTRB_AFIBERCHAN_SCRATCH(c) ;
    for (i = ATSCNTRB_AFIBER_CHAN_SCRATCH ; i > 0 ; i--) {
      void *sl = (void*)(base + (i - 1) * slot_size) ;
      *(void**)sl = fre ; fre = sl ;
    }
    c->scratch_free = fre ;
  }
#endif
  return (atstype_ptr)c ;
} // end of [atscntrb_afiberchan_make]

/*
** the scratch slots (the hand-off). The caller holds the lock.
*/
ATSinline()
void*
atscntrb_afiberchan__scratch_pop
  (atscntrb_afiberchan_t *c)
{
#if ATSCNTRB_AFIBER_CHAN_HANDOFF
  void *s = c->scratch_free ;
  if (s) c->scratch_free = *(void**)s ;
  return s ;
#else
  return (void*)0 ;
#endif
} // end of [atscntrb_afiberchan__scratch_pop]

ATSinline()
void
atscntrb_afiberchan__scratch_push
  (atscntrb_afiberchan_t *c, void *s)
{
#if ATSCNTRB_AFIBER_CHAN_HANDOFF
  if (s) { *(void**)s = c->scratch_free ; c->scratch_free = s ; }
#else
  (void)c ; (void)s ;
#endif
} // end of [atscntrb_afiberchan__scratch_push]

ATSinline()
void
atscntrb_afiberchan_free
  (atstype_ptr c0)
{
  atscntrb_afiberchan_t *c = (atscntrb_afiberchan_t*)c0 ;
  if (c->n != 0) {
    fprintf(stderr, "afiberchan: [free]: the buffer is not empty\n") ; abort() ;
  }
  if (c->lock) { fprintf(stderr, "afiberchan: [free]: the lock is held\n") ; abort() ; }
  if (c->recvq.head || c->sendq.head) {
    fprintf(stderr, "afiberchan: [free]: a fiber is still parked\n") ; abort() ;
  }
  free(c) ;
} // end of [atscntrb_afiberchan_free]

/* ****** ****** */

ATSinline()
void
atscntrb_afiberchan_lock
  (atstype_ptr c0)
{
  atscntrb_afiber__spin_lock(&(((atscntrb_afiberchan_t*)c0)->lock)) ;
}

ATSinline()
void
atscntrb_afiberchan_unlock
  (atstype_ptr c0)
{
  atscntrb_afiber__spin_unlock(&(((atscntrb_afiberchan_t*)c0)->lock)) ;
}

/* ****** ****** */

ATSinline()
atstype_int
atscntrb_afiberchan_rfcnt_get
  (atstype_ptr c0)
{ return ((atscntrb_afiberchan_t*)c0)->rfcnt ; }

ATSinline()
void
atscntrb_afiberchan_rfcnt_set
  (atstype_ptr c0, atstype_int n)
{ ((atscntrb_afiberchan_t*)c0)->rfcnt = n ; }

ATSinline()
atstype_size
atscntrb_afiberchan_cap
  (atstype_ptr c0)
{ return ((atscntrb_afiberchan_t*)c0)->cap ; }

ATSinline()
atstype_size
atscntrb_afiberchan_size
  (atstype_ptr c0)
{ return ((atscntrb_afiberchan_t*)c0)->n ; }

ATSinline()
atstype_bool
atscntrb_afiberchan_is_full
  (atstype_ptr c0)
{
  atscntrb_afiberchan_t *c = (atscntrb_afiberchan_t*)c0 ;
  return (c->n >= c->cap) ? atsbool_true : atsbool_false ;
}

ATSinline()
atstype_bool
atscntrb_afiberchan_is_closed
  (atstype_ptr c0)
{ return ((atscntrb_afiberchan_t*)c0)->closed ? atsbool_true : atsbool_false ; }

ATSinline()
void
atscntrb_afiberchan_set_closed
  (atstype_ptr c0)
{ ((atscntrb_afiberchan_t*)c0)->closed = 1 ; }

/*
** the slot for a new item at the end; [n] < [cap] is required
*/
ATSinline()
atstype_ptr
atscntrb_afiberchan_push
  (atstype_ptr c0)
{
  atscntrb_afiberchan_t *c = (atscntrb_afiberchan_t*)c0 ;
  size_t i = c->head + c->n ;
  if (i >= c->cap) i -= c->cap ;
  c->n += 1 ;
  return (atstype_ptr)(ATSCNTRB_AFIBERCHAN_DATA(c) + i * c->tsz) ;
} // end of [atscntrb_afiberchan_push]

/*
** the slot of the oldest item; [n] > 0 is required
*/
ATSinline()
atstype_ptr
atscntrb_afiberchan_pop
  (atstype_ptr c0)
{
  atscntrb_afiberchan_t *c = (atscntrb_afiberchan_t*)c0 ;
  size_t i = c->head ;
  c->head += 1 ;
  if (c->head == c->cap) c->head = 0 ;
  c->n -= 1 ;
  return (atstype_ptr)(ATSCNTRB_AFIBERCHAN_DATA(c) + i * c->tsz) ;
} // end of [atscntrb_afiberchan_pop]

/* ****** ****** */

/*
** the wait queues are embedded; the caller holds the lock. Parking
** queues the fiber, releases the lock once the fiber is off its stack
** and takes it again before the return (see [afiber_waitq_park]).
*/
ATSinline()
void
atscntrb_afiberchan_park_recv (atstype_ptr c0)
{
  atscntrb_afiberchan_t *c = (atscntrb_afiberchan_t*)c0 ;
  atscntrb_afiber_t *f = atscntrb_afiber__cw()->current ;
#if ATSCNTRB_AFIBER_CHAN_HANDOFF
  // the fiber owns a scratch slot: a sender may hand the value to it
  if (f->ho_state == ATSCNTRB_AFIBER_HO_NONE) {
    void *sl = atscntrb_afiberchan__scratch_pop (c) ;
    if (sl) { f->ho_slot = sl ; f->ho_state = ATSCNTRB_AFIBER_HO_WAITING ; }
  }
#endif
  atscntrb_afiber_waitq_park((atstype_ptr)&(c->recvq), (atstype_ptr)&(c->lock)) ;
}

/*
** the same, but the fiber does not own a scratch slot: it cannot be
** the target of a hand-off. The batch receive uses it (the batch reads
** the ring itself).
*/
ATSinline()
void
atscntrb_afiberchan_park_recv_noho (atstype_ptr c0)
{
  atscntrb_afiberchan_t *c = (atscntrb_afiberchan_t*)c0 ;
  atscntrb_afiber_waitq_park((atstype_ptr)&(c->recvq), (atstype_ptr)&(c->lock)) ;
}

ATSinline()
void
atscntrb_afiberchan_park_send (atstype_ptr c0)
{
  atscntrb_afiberchan_t *c = (atscntrb_afiberchan_t*)c0 ;
  atscntrb_afiber_waitq_park((atstype_ptr)&(c->sendq), (atstype_ptr)&(c->lock)) ;
}

ATSinline()
void
atscntrb_afiberchan_wake_recv (atstype_ptr c0)
{
  atscntrb_afiberchan_t *c = (atscntrb_afiberchan_t*)c0 ;
  if (c->recvq.head) atscntrb_afiber_waitq_wake_one((atstype_ptr)&(c->recvq)) ;
}

ATSinline()
void
atscntrb_afiberchan_wake_send (atstype_ptr c0)
{
  atscntrb_afiberchan_t *c = (atscntrb_afiberchan_t*)c0 ;
  if (c->sendq.head) atscntrb_afiber_waitq_wake_one((atstype_ptr)&(c->sendq)) ;
}

ATSinline()
void
atscntrb_afiberchan_wake_all
  (atstype_ptr c0)
{
  atscntrb_afiberchan_t *c = (atscntrb_afiberchan_t*)c0 ;
  atscntrb_afiber_waitq_wake_all((atstype_ptr)&(c->recvq)) ;
  atscntrb_afiber_waitq_wake_all((atstype_ptr)&(c->sendq)) ;
}

/* ****** ****** */

/*
** MS-2026-10 (step J): the common paths in one C call. [send_begin] takes
** the lock and returns the slot for the new item (the caller stores the
** item, then calls [send_end]: wake a parked receiver, unlock), or
** NULL when the buffer is full (the lock is held: the caller parks, see
** [park_send], and calls [send_recheck], which does not lock again), or
** (void*)1 when the channel is closed (the lock is released). [recv_*] are
** the mirror image; the slot returned by [recv_begin] holds the oldest
** item, already removed from the ring, and stays valid until [recv_end]
** (nobody else can push into it before the unlock). [trysend_begin] and
** [tryrecv_begin] return a slot (lock held, finish with [send_end] or
** [recv_end]) or (void*)1 (refused, the lock is released).
*/
ATSinline()
atstype_bool
atscntrb_afiberchan_ptr_is_one
  (atstype_ptr p)
{ return (p == (atstype_ptr)1) ? atsbool_true : atsbool_false ; }

ATSinline()
atstype_ptr
atscntrb_afiberchan__send_check
  (atscntrb_afiberchan_t *c)
{
  size_t n = c->n, cap = c->cap, i ;
  if (c->closed) { atscntrb_afiber__spin_unlock(&(c->lock)) ; return (atstype_ptr)1 ; }
#if ATSCNTRB_AFIBER_CHAN_HANDOFF
  // a parked receiver takes the value directly (Go's sendDirect): the
  // value is written into the receiver's scratch slot and the receiver
  // is woken by [send_end] (the lock is still held here, so the parked
  // receiver is still the head of the queue).
  if (c->recvq.head) {
    atscntrb_afiber_t *f = c->recvq.head ;
    if (f->ho_state == ATSCNTRB_AFIBER_HO_WAITING) {
      f->ho_state = ATSCNTRB_AFIBER_HO_HANDED_OFF ;
      return f->ho_slot ;
    }
  }
#endif
  if (n >= cap) return (atstype_ptr)0 ;
  i = c->head + n ;
  if (i >= cap) i -= cap ;
  c->n = n + 1 ;
  return (atstype_ptr)(ATSCNTRB_AFIBERCHAN_DATA(c) + i * c->tsz) ;
}

ATSinline()
atstype_ptr
atscntrb_afiberchan_send_begin
  (atstype_ptr c0)
{
  atscntrb_afiberchan_t *c = (atscntrb_afiberchan_t*)c0 ;
  atscntrb_afiber__spin_lock(&(c->lock)) ;
  return atscntrb_afiberchan__send_check(c) ;
}

ATSinline()
atstype_ptr
atscntrb_afiberchan_send_recheck
  (atstype_ptr c0)
{ return atscntrb_afiberchan__send_check((atscntrb_afiberchan_t*)c0) ; }

ATSinline()
void
atscntrb_afiberchan_send_end
  (atstype_ptr c0)
{
  atscntrb_afiberchan_t *c = (atscntrb_afiberchan_t*)c0 ;
  if (c->recvq.head) atscntrb_afiber_waitq_wake_one((atstype_ptr)&(c->recvq)) ;
  atscntrb_afiber__spin_unlock(&(c->lock)) ;
}

ATSinline()
atstype_ptr
atscntrb_afiberchan_trysend_begin
  (atstype_ptr c0)
{
  atscntrb_afiberchan_t *c = (atscntrb_afiberchan_t*)c0 ;
  atstype_ptr p ;
  atscntrb_afiber__spin_lock(&(c->lock)) ;
  p = atscntrb_afiberchan__send_check(c) ;
  if (p == (atstype_ptr)0) { atscntrb_afiber__spin_unlock(&(c->lock)) ; return (atstype_ptr)1 ; }
  return p ;
}

/*
** the check of the receive path. [handoff] is 1 in the re-check (the
** fiber has parked and may have been handed a value) and 0 in the first
** attempt (the fiber has not parked: it cannot have a hand-off).
*/
ATSinline()
atstype_ptr
atscntrb_afiberchan__recv_check
  (atscntrb_afiberchan_t *c, int handoff)
{
  size_t n = c->n, h ;
#if ATSCNTRB_AFIBER_CHAN_HANDOFF
  atscntrb_afiber_t *f = (void*)0 ;
  if (handoff) {
    f = atscntrb_afiber__cw()->current ;
    // the value was handed to the fiber: it is in its scratch slot (the
    // hand-off is checked before the ring: the ring may have been filled
    // by another sender in the meantime)
    if (f->ho_state == ATSCNTRB_AFIBER_HO_HANDED_OFF) {
      f->ho_state = ATSCNTRB_AFIBER_HO_DONE ;
      return f->ho_slot ;
    }
  }
#else
  (void)handoff ;
#endif
  if (n > 0) {
    h = c->head ;
    c->n = n - 1 ;
    c->head = (h + 1 == c->cap) ? 0 : h + 1 ;
#if ATSCNTRB_AFIBER_CHAN_HANDOFF
    // the fiber does not wait for a hand-off any more
    if (handoff && f->ho_state == ATSCNTRB_AFIBER_HO_WAITING) {
      atscntrb_afiberchan__scratch_push (c, f->ho_slot) ;
      f->ho_state = ATSCNTRB_AFIBER_HO_NONE ;
    }
#endif
    return (atstype_ptr)(ATSCNTRB_AFIBERCHAN_DATA(c) + h * c->tsz) ;
  }
  if (c->closed) {
    atscntrb_afiber__spin_unlock(&(c->lock)) ;
#if ATSCNTRB_AFIBER_CHAN_HANDOFF
    if (handoff && f->ho_state == ATSCNTRB_AFIBER_HO_WAITING) {
      atscntrb_afiberchan__scratch_push (c, f->ho_slot) ;
      f->ho_state = ATSCNTRB_AFIBER_HO_NONE ;
    }
#endif
    return (atstype_ptr)1 ;
  }
  return (atstype_ptr)0 ;
}

ATSinline()
atstype_ptr
atscntrb_afiberchan_recv_begin
  (atstype_ptr c0)
{
  atscntrb_afiberchan_t *c = (atscntrb_afiberchan_t*)c0 ;
  atscntrb_afiber__spin_lock(&(c->lock)) ;
  return atscntrb_afiberchan__recv_check(c, 0) ;
}

ATSinline()
atstype_ptr
atscntrb_afiberchan_recv_recheck
  (atstype_ptr c0)
{ return atscntrb_afiberchan__recv_check((atscntrb_afiberchan_t*)c0, 1) ; }

ATSinline()
void
atscntrb_afiberchan_recv_end
  (atstype_ptr c0)
{
  atscntrb_afiberchan_t *c = (atscntrb_afiberchan_t*)c0 ;
  atscntrb_afiber_t *f = atscntrb_afiber__cw()->current ;
#if ATSCNTRB_AFIBER_CHAN_HANDOFF
  // the scratch slot of the fiber (if any) goes back to the pool
  if (f->ho_state == ATSCNTRB_AFIBER_HO_DONE
      || f->ho_state == ATSCNTRB_AFIBER_HO_WAITING) {
    atscntrb_afiberchan__scratch_push (c, f->ho_slot) ;
    f->ho_state = ATSCNTRB_AFIBER_HO_NONE ;
  }
#endif
  if (c->sendq.head) atscntrb_afiber_waitq_wake_one((atstype_ptr)&(c->sendq)) ;
  atscntrb_afiber__spin_unlock(&(c->lock)) ;
}

ATSinline()
atstype_ptr
atscntrb_afiberchan_tryrecv_begin
  (atstype_ptr c0)
{
  atscntrb_afiberchan_t *c = (atscntrb_afiberchan_t*)c0 ;
  atstype_ptr p ;
  atscntrb_afiber__spin_lock(&(c->lock)) ;
  p = atscntrb_afiberchan__recv_check(c, 0) ;
  if (p == (atstype_ptr)0) { atscntrb_afiber__spin_unlock(&(c->lock)) ; return (atstype_ptr)1 ; }
  return p ;
}

/* ****** ****** */

#endif // ifndef ATSCNTRB_AFIBER_CATS_AFIBERCHAN

/* ****** ****** */

/* end of [afiberchan.cats] */
