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
** MS-2026-10:
** afiberchan: the ring buffer behind a channel. It holds
** [cap] slots of [tsz] bytes; the ATS side moves values in
** and out of the slots with ptr0_set/ptr0_get.
*/

/* ****** ****** */

#ifndef ATSCNTRB_AFIBER_CATS_AFIBERCHAN
#define ATSCNTRB_AFIBER_CATS_AFIBERCHAN

/* ****** ****** */

#include <stdio.h>
#include <stdlib.h>

/* ****** ****** */

typedef
struct {
  size_t cap ; // the number of slots
  size_t tsz ; // the size of a slot
  size_t head ; // the oldest item
  size_t n ; // the number of items
  char *data ;
} atscntrb_afiberchan_ring ;

/* ****** ****** */

ATSinline()
atstype_ptr
atscntrb_afiberchan_ring_make
  (atstype_size cap, atstype_size tsz)
{
  atscntrb_afiberchan_ring *r = ATS_MALLOC(sizeof(atscntrb_afiberchan_ring)) ;
  r->cap = cap ; r->tsz = tsz ; r->head = 0 ; r->n = 0 ;
  r->data = ATS_MALLOC(cap * tsz) ;
  return (atstype_ptr)r ;
} // end of [atscntrb_afiberchan_ring_make]

ATSinline()
void
atscntrb_afiberchan_ring_free
  (atstype_ptr r0)
{
  atscntrb_afiberchan_ring *r = (atscntrb_afiberchan_ring*)r0 ;
  if (r->n != 0) {
    fprintf(stderr, "afiberchan: [ring_free]: the buffer is not empty\n") ; abort() ;
  }
  ATS_MFREE(r->data) ; ATS_MFREE(r) ;
} // end of [atscntrb_afiberchan_ring_free]

ATSinline()
atstype_size
atscntrb_afiberchan_ring_size
  (atstype_ptr r0)
{
  return (atstype_size)(((atscntrb_afiberchan_ring*)r0)->n) ;
} // end of [atscntrb_afiberchan_ring_size]

ATSinline()
atstype_bool
atscntrb_afiberchan_ring_is_full
  (atstype_ptr r0)
{
  atscntrb_afiberchan_ring *r = (atscntrb_afiberchan_ring*)r0 ;
  return (r->n >= r->cap) ? atsbool_true : atsbool_false ;
} // end of [atscntrb_afiberchan_ring_is_full]

/*
** the slot for a new item at the end; [n] < [cap] is required
*/
ATSinline()
atstype_ptr
atscntrb_afiberchan_ring_push
  (atstype_ptr r0)
{
  atscntrb_afiberchan_ring *r = (atscntrb_afiberchan_ring*)r0 ;
  size_t i = r->head + r->n ;
  if (i >= r->cap) i -= r->cap ;
  r->n += 1 ;
  return (atstype_ptr)(r->data + i * r->tsz) ;
} // end of [atscntrb_afiberchan_ring_push]

/*
** the slot of the oldest item; [n] > 0 is required
*/
ATSinline()
atstype_ptr
atscntrb_afiberchan_ring_pop
  (atstype_ptr r0)
{
  atscntrb_afiberchan_ring *r = (atscntrb_afiberchan_ring*)r0 ;
  size_t i = r->head ;
  r->head += 1 ;
  if (r->head == r->cap) r->head = 0 ;
  r->n -= 1 ;
  return (atstype_ptr)(r->data + i * r->tsz) ;
} // end of [atscntrb_afiberchan_ring_pop]

/* ****** ****** */

#endif // ifndef ATSCNTRB_AFIBER_CATS_AFIBERCHAN

/* ****** ****** */

/* end of [afiberchan.cats] */
