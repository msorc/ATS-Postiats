/* ******************************************************************* */
/*                                                                     */
/*                         Applied Type System                         */
/*                                                                     */
/* ******************************************************************* */

/*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2026 Hongwei Xi, ATS Trustful Software, Inc.
** All rights reserved
**
** ATS is free software;  you can  redistribute it and/or modify it under
** the terms of  the GNU GENERAL PUBLIC LICENSE (GPL) as published by the
** Free Software Foundation; either version 3, or (at  your  option)  any
** later version.
**
** ATS is distributed in the hope that it will be useful, but WITHOUT ANY
** WARRANTY; without  even  the  implied  warranty  of MERCHANTABILITY or
** FITNESS FOR A PARTICULAR PURPOSE.  See the  GNU General Public License
** for more details.
**
** You  should  have  received  a  copy of the GNU General Public License
** along  with  ATS;  see the  file COPYING.  If not, please write to the
** Free Software Foundation,  51 Franklin Street, Fifth Floor, Boston, MA
** 02110-1301, USA.
*/


/* ****** ****** */

/*
** HX-2026-10:
** afiberchan: the ring buffer behind a channel. It holds
** [cap] slots of [tsz] bytes; the ATS side moves values in
** and out of the slots with ptr0_set/ptr0_get.
*/

/* ****** ****** */

#ifndef ATSLIB_LIBATS_CATS_AFIBERCHAN
#define ATSLIB_LIBATS_CATS_AFIBERCHAN

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
} atslib_afiberchan_ring ;

/* ****** ****** */

ATSinline()
atstype_ptr
atslib_afiberchan_ring_make
  (atstype_size cap, atstype_size tsz)
{
  atslib_afiberchan_ring *r = ATS_MALLOC(sizeof(atslib_afiberchan_ring)) ;
  r->cap = cap ; r->tsz = tsz ; r->head = 0 ; r->n = 0 ;
  r->data = ATS_MALLOC(cap * tsz) ;
  return (atstype_ptr)r ;
} // end of [atslib_afiberchan_ring_make]

ATSinline()
void
atslib_afiberchan_ring_free
  (atstype_ptr r0)
{
  atslib_afiberchan_ring *r = (atslib_afiberchan_ring*)r0 ;
  if (r->n != 0) {
    fprintf(stderr, "libats/afiberchan: [ring_free]: the buffer is not empty\n") ; abort() ;
  }
  ATS_MFREE(r->data) ; ATS_MFREE(r) ;
} // end of [atslib_afiberchan_ring_free]

ATSinline()
atstype_size
atslib_afiberchan_ring_size
  (atstype_ptr r0)
{
  return (atstype_size)(((atslib_afiberchan_ring*)r0)->n) ;
} // end of [atslib_afiberchan_ring_size]

ATSinline()
atstype_bool
atslib_afiberchan_ring_is_full
  (atstype_ptr r0)
{
  atslib_afiberchan_ring *r = (atslib_afiberchan_ring*)r0 ;
  return (r->n >= r->cap) ? atsbool_true : atsbool_false ;
} // end of [atslib_afiberchan_ring_is_full]

/*
** the slot for a new item at the end; [n] < [cap] is required
*/
ATSinline()
atstype_ptr
atslib_afiberchan_ring_push
  (atstype_ptr r0)
{
  atslib_afiberchan_ring *r = (atslib_afiberchan_ring*)r0 ;
  size_t i = (r->head + r->n) % r->cap ;
  r->n += 1 ;
  return (atstype_ptr)(r->data + i * r->tsz) ;
} // end of [atslib_afiberchan_ring_push]

/*
** the slot of the oldest item; [n] > 0 is required
*/
ATSinline()
atstype_ptr
atslib_afiberchan_ring_pop
  (atstype_ptr r0)
{
  atslib_afiberchan_ring *r = (atslib_afiberchan_ring*)r0 ;
  size_t i = r->head ;
  r->head = (r->head + 1) % r->cap ;
  r->n -= 1 ;
  return (atstype_ptr)(r->data + i * r->tsz) ;
} // end of [atslib_afiberchan_ring_pop]

/* ****** ****** */

#endif // ifndef ATSLIB_LIBATS_CATS_AFIBERCHAN

/* ****** ****** */

/* end of [afiberchan.cats] */
