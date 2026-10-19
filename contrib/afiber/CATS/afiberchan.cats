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

typedef
struct {
  /* the first line: hot */
  int lock ; // the spinlock (it must be the first member: see [lock_ptr] uses)
  int closed ;
  size_t head ; // the oldest item
  size_t n ; // the number of items
  atscntrb_afiber_q recvq ;
  atscntrb_afiber_q sendq ;
  int rfcnt ; // changed (under the lock) only by chan_ref/unref
  /* the second line: read-mostly */
  size_t cap __attribute__((aligned(ATSCNTRB_AFIBER_LINE))) ; // the number of slots
  size_t tsz ; // the size of a slot
  /* then the slots, from [sizeof(...)] on */
} __attribute__((aligned(ATSCNTRB_AFIBER_LINE))) atscntrb_afiberchan_t ;

_Static_assert(offsetof(atscntrb_afiberchan_t, rfcnt) < ATSCNTRB_AFIBER_LINE, "afiberchan: the hot fields are not on the first line") ;
_Static_assert(offsetof(atscntrb_afiberchan_t, cap) == ATSCNTRB_AFIBER_LINE, "afiberchan: cap is not on the second line") ;

#define ATSCNTRB_AFIBERCHAN_DATA(c) ((char*)(c) + sizeof(atscntrb_afiberchan_t))

/* ****** ****** */

ATSinline()
atstype_ptr
atscntrb_afiberchan_make
  (atstype_size cap, atstype_size tsz)
{
  atscntrb_afiberchan_t *c ;
  size_t sz = sizeof(atscntrb_afiberchan_t) + cap * tsz ;
  sz = (sz + ATSCNTRB_AFIBER_LINE - 1) & ~(size_t)(ATSCNTRB_AFIBER_LINE - 1) ;
  c = (atscntrb_afiberchan_t*)aligned_alloc(ATSCNTRB_AFIBER_LINE, sz) ;
  if (!c) { fprintf(stderr, "afiberchan: out of memory\n") ; abort() ; }
  c->lock = 0 ; c->closed = 0 ; c->head = 0 ; c->n = 0 ;
  c->recvq.head = c->recvq.tail = (atscntrb_afiber_t*)0 ;
  c->sendq.head = c->sendq.tail = (atscntrb_afiber_t*)0 ;
  c->rfcnt = 1 ; c->cap = cap ; c->tsz = tsz ;
  return (atstype_ptr)c ;
} // end of [atscntrb_afiberchan_make]

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
  atscntrb_afiber_waitq_park((atstype_ptr)&(((atscntrb_afiberchan_t*)c0)->recvq), c0) ;
}

ATSinline()
void
atscntrb_afiberchan_park_send (atstype_ptr c0)
{
  atscntrb_afiber_waitq_park((atstype_ptr)&(((atscntrb_afiberchan_t*)c0)->sendq), c0) ;
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

#endif // ifndef ATSCNTRB_AFIBER_CATS_AFIBERCHAN

/* ****** ****** */

/* end of [afiberchan.cats] */
