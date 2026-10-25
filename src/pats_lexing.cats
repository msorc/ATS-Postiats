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


#ifndef POSTIATS_SRC_PATS_LEXING_CATS
#define POSTIATS_SRC_PATS_LEXING_CATS

/* ****** ****** */

#include <stdlib.h>
#include <string.h>

/* ****** ****** */

/*
** HX-2026-10: no GC
** the char queue that collects the chars of a string constant is a
** plain malloc-ed byte buffer ([libats/linqueue_arr] is gone)
*/
typedef struct {
  char *p ; size_t len ; size_t cap ;
} patsopt_strbuf ;

static inline
atstype_ptr
patsopt_strbuf_new
  (atstype_void)
{
  patsopt_strbuf *sb = (patsopt_strbuf*)malloc(sizeof(patsopt_strbuf)) ;
  sb->cap = 128 ; sb->len = 0 ; sb->p = (char*)malloc(sb->cap) ;
  return sb ;
}

static inline
atstype_void
patsopt_strbuf_ins
  (atstype_ptr p0, atstype_int c)
{
  patsopt_strbuf *sb = (patsopt_strbuf*)p0 ;
  if (sb->len >= sb->cap) {
    sb->cap *= 2 ; sb->p = (char*)realloc(sb->p, sb->cap) ;
  }
  sb->p[sb->len++] = (char)c ;
  return ;
}

// the result (a NUL-terminated copy) is to be freed by strptr_free
static inline
atstype_ptr
patsopt_strbuf_free
  (atstype_ptr p0)
{
  patsopt_strbuf *sb = (patsopt_strbuf*)p0 ;
  char *s = (char*)realloc(sb->p, sb->len+1) ;
  s[sb->len] = '\0' ;
  free(sb) ;
  return s ;
}

/* ****** ****** */

#endif // end of [POSTIATS_SRC_PATS_LEXING_CATS]

/* ****** ****** */

/* end of [pats_lexing.cats] */
