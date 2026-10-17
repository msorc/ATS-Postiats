/* ******************************************************************* */
/*                                                                     */
/*                         Applied Type System                         */
/*                                                                     */
/* ******************************************************************* */

/*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-20?? Hongwei Xi, ATS Trustful Software, Inc.
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
//
// Author: Hongwei Xi (gmhwxi@gmail.com)
// Start Time: March, 2011
//
/* ****** ****** */


#ifndef POSTIATS_SRC_PATS_TOKBUF_CATS
#define POSTIATS_SRC_PATS_TOKBUF_CATS

/* ****** ****** */

#include <stdlib.h>

/* ****** ****** */

#include "pats_lexbuf.cats"

/* ****** ****** */

/*
** HX-2026-10: no GC
** the double-ended queue of tokens is a ring buffer of pointers
** ([libats/ngc/deque_arr] is gone); a token is a handle (a pointer)
*/
typedef struct {
//
  atstype_ptr tbuf_ptr ; // ring buffer
  atstype_size tbuf_cap ; // capacity
  atstype_size tbuf_head ; // index of the first element
  atstype_size tbuf_len ; // number of elements
//
  atstype_uint ntok ; // the current token number
//
  pats_lexbuf_struct lexbuf ; // for lexing
//
} pats_tokbuf_struct ;

/* ****** ****** */

#define PATSOPT_TOKBUF_QINISZ 1024 // initial size

static inline
atstype_void
patsopt_tokbuf_init
  (atstype_ptr p0)
{
  pats_tokbuf_struct *p = (pats_tokbuf_struct*)p0 ;
  p->tbuf_ptr = malloc(PATSOPT_TOKBUF_QINISZ * sizeof(void*)) ;
  p->tbuf_cap = PATSOPT_TOKBUF_QINISZ ;
  p->tbuf_head = 0 ; p->tbuf_len = 0 ;
  p->ntok = 0 ;
  return ;
}

static inline
atstype_void
patsopt_tokbuf_fini
  (atstype_ptr p0)
{
  pats_tokbuf_struct *p = (pats_tokbuf_struct*)p0 ;
  free(p->tbuf_ptr) ; p->tbuf_ptr = 0 ;
  return ;
}

static inline
atstype_size
patsopt_tokbuf_qsize
  (atstype_ptr p0)
{
  return ((pats_tokbuf_struct*)p0)->tbuf_len ;
}

static inline
atstype_ptr
patsopt_tokbuf_qget
  (atstype_ptr p0, atstype_size i)
{
  pats_tokbuf_struct *p = (pats_tokbuf_struct*)p0 ;
  return ((void**)p->tbuf_ptr)[(p->tbuf_head + i) % p->tbuf_cap] ;
}

static inline
atstype_void
patsopt_tokbuf_qgrow
  (pats_tokbuf_struct *p)
{
  size_t i, cap2 = 2 * p->tbuf_cap ;
  void **q = (void**)malloc(cap2 * sizeof(void*)) ;
  for (i = 0 ; i < p->tbuf_len ; i += 1)
    q[i] = ((void**)p->tbuf_ptr)[(p->tbuf_head + i) % p->tbuf_cap] ;
  free(p->tbuf_ptr) ;
  p->tbuf_ptr = q ; p->tbuf_cap = cap2 ; p->tbuf_head = 0 ;
  return ;
}

static inline
atstype_void
patsopt_tokbuf_qins_end
  (atstype_ptr p0, atstype_ptr x)
{
  pats_tokbuf_struct *p = (pats_tokbuf_struct*)p0 ;
  if (p->tbuf_len >= p->tbuf_cap) patsopt_tokbuf_qgrow(p) ;
  ((void**)p->tbuf_ptr)[(p->tbuf_head + p->tbuf_len) % p->tbuf_cap] = x ;
  p->tbuf_len += 1 ;
  return ;
}

static inline
atstype_void
patsopt_tokbuf_qins_beg
  (atstype_ptr p0, atstype_ptr x)
{
  pats_tokbuf_struct *p = (pats_tokbuf_struct*)p0 ;
  if (p->tbuf_len >= p->tbuf_cap) patsopt_tokbuf_qgrow(p) ;
  p->tbuf_head = (p->tbuf_head + p->tbuf_cap - 1) % p->tbuf_cap ;
  ((void**)p->tbuf_ptr)[p->tbuf_head] = x ;
  p->tbuf_len += 1 ;
  return ;
}

// removing the first [n] elements (n <= len)
static inline
atstype_void
patsopt_tokbuf_qclear
  (atstype_ptr p0, atstype_size n)
{
  pats_tokbuf_struct *p = (pats_tokbuf_struct*)p0 ;
  p->tbuf_head = (p->tbuf_head + n) % p->tbuf_cap ;
  p->tbuf_len -= n ;
  return ;
}

/* ****** ****** */

#endif // end of [POSTIATS_SRC_PATS_TOKBUF_CATS]

/* ****** ****** */

/* end of [pats_tokbuf.cats] */
