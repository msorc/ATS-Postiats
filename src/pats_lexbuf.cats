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


#ifndef POSTIATS_SRC_PATS_LEXBUF_CATS
#define POSTIATS_SRC_PATS_LEXBUF_CATS

/* ****** ****** */

#include <stdlib.h>
#include <string.h>

/* ****** ****** */

#include "pats_reader.cats"

/* ****** ****** */

/*
** HX-2026-10: no GC
** the character queue (a lookahead buffer) is a plain malloc-ed byte
** array: [libats/linqueue_arr] is gone
*/
typedef struct {
//
  atstype_ptr cbuf_ptr ; // bytes
  atstype_size cbuf_cap ; // capacity
  atstype_size cbuf_head ; // index of the first byte
  atstype_size cbuf_len ; // number of bytes
//
  atstype_lint base ;
  atstype_int base_nrow ; // line number
  atstype_int base_ncol ; // line offset
//
  atstype_int nspace ; // leading space
//
  pats_reader_struct reader ; // for getchar
//
} pats_lexbuf_struct ;

/* ****** ****** */

#define PATSOPT_LEXBUF_QINISZ 1024 // initial size
#define PATSOPT_LEXBUF_QDELTA 1024 // subsequent increment

static inline
atstype_void
patsopt_lexbuf_init
  (atstype_ptr p0)
{
  pats_lexbuf_struct *p = (pats_lexbuf_struct*)p0 ;
  p->cbuf_ptr = malloc(PATSOPT_LEXBUF_QINISZ) ;
  p->cbuf_cap = PATSOPT_LEXBUF_QINISZ ;
  p->cbuf_head = 0 ; p->cbuf_len = 0 ;
  p->base = 0 ; p->base_nrow = 0 ; p->base_ncol = 0 ; p->nspace = 0 ;
  return ;
}

static inline
atstype_void
patsopt_lexbuf_fini
  (atstype_ptr p0)
{
  pats_lexbuf_struct *p = (pats_lexbuf_struct*)p0 ;
  free(p->cbuf_ptr) ; p->cbuf_ptr = 0 ;
  return ;
}

static inline
atstype_size
patsopt_lexbuf_qsize
  (atstype_ptr p0)
{
  return ((pats_lexbuf_struct*)p0)->cbuf_len ;
}

static inline
atstype_int
patsopt_lexbuf_qget
  (atstype_ptr p0, atstype_size i)
{
  pats_lexbuf_struct *p = (pats_lexbuf_struct*)p0 ;
  return ((unsigned char*)p->cbuf_ptr)[p->cbuf_head + i] ;
}

static inline
atstype_void
patsopt_lexbuf_qins
  (atstype_ptr p0, atstype_int c)
{
  pats_lexbuf_struct *p = (pats_lexbuf_struct*)p0 ;
  if (p->cbuf_head + p->cbuf_len >= p->cbuf_cap) {
    if (p->cbuf_head > 0) {
      memmove(p->cbuf_ptr, (char*)p->cbuf_ptr + p->cbuf_head, p->cbuf_len) ;
      p->cbuf_head = 0 ;
    }
    if (p->cbuf_len >= p->cbuf_cap) {
      p->cbuf_cap += PATSOPT_LEXBUF_QDELTA ;
      p->cbuf_ptr = realloc(p->cbuf_ptr, p->cbuf_cap) ;
    }
  }
  ((unsigned char*)p->cbuf_ptr)[p->cbuf_head + p->cbuf_len] = (unsigned char)c ;
  p->cbuf_len += 1 ;
  return ;
}

// removing the first [n] bytes (n <= len)
static inline
atstype_void
patsopt_lexbuf_qclear
  (atstype_ptr p0, atstype_size n)
{
  pats_lexbuf_struct *p = (pats_lexbuf_struct*)p0 ;
  p->cbuf_head += n ; p->cbuf_len -= n ;
  if (p->cbuf_len == 0) p->cbuf_head = 0 ;
  return ;
}

// a fresh NUL-terminated copy of the bytes [st, st+ln)
static inline
atstype_ptr
patsopt_lexbuf_qsub
  (atstype_ptr p0, atstype_size st, atstype_size ln)
{
  pats_lexbuf_struct *p = (pats_lexbuf_struct*)p0 ;
  char *s = (char*)malloc(ln+1) ;
  memcpy(s, (char*)p->cbuf_ptr + p->cbuf_head + st, ln) ;
  s[ln] = '\0' ;
  return s ;
}

/* ****** ****** */

#endif // end of [POSTIATS_SRC_PATS_LEXBUF_CATS]

/* ****** ****** */

/* end of [pats_lexbuf.cats] */
