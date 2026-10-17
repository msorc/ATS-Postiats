/***********************************************************************/
/*                                                                     */
/*                         Applied Type System                         */
/*                                                                     */
/***********************************************************************/

/*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-20?? Hongwei Xi, ATS Trustworthy Software, Inc.
** All rights reserved
**
** ATS is free software;  you can  redistribute it and/or modify it under
** the terms of the GNU LESSER GENERAL PUBLIC LICENSE as published by the
** Free Software Foundation; either version 2.1, or (at your option)  any
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
** HX-2026-10: no GC
** A growable byte buffer (the [stroutptr] of ATS1 atsdoc, which was
** built on libats/linqueue_lst): the functions are used from libatsdoc
** and from utils/atsdoc.
*/

#ifndef LIBATSDOC_SBUF_CATS
#define LIBATSDOC_SBUF_CATS

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct { char *ptr ; size_t len ; size_t cap ; } libatsdoc_sbuf_struct ;

static inline
atstype_ptr
libatsdoc_sbuf_make (void)
{
  libatsdoc_sbuf_struct *b = (libatsdoc_sbuf_struct*)malloc(sizeof(libatsdoc_sbuf_struct)) ;
  b->cap = 64 ; b->len = 0 ; b->ptr = (char*)malloc(b->cap) ;
  return b ;
}

static inline
atstype_void
libatsdoc_sbuf_add_char (atstype_ptr p, atstype_char c)
{
  libatsdoc_sbuf_struct *b = (libatsdoc_sbuf_struct*)p ;
  if (b->len + 1 >= b->cap) { b->cap *= 2 ; b->ptr = (char*)realloc(b->ptr, b->cap) ; }
  b->ptr[b->len++] = c ;
  return ;
}

static inline
atstype_void
libatsdoc_sbuf_add_string (atstype_ptr p, atstype_ptr s)
{
  const char *q = (const char*)s ;
  while (*q) { libatsdoc_sbuf_add_char (p, *q) ; q += 1 ; }
  return ;
}

static inline
atstype_size
libatsdoc_sbuf_length (atstype_ptr p)
{
  return ((libatsdoc_sbuf_struct*)p)->len ;
}

/* the contents as a NUL-terminated string (kept: ATS_MALLOC-ed); the buffer is freed */
static inline
atstype_ptr
libatsdoc_sbuf_takeout (atstype_ptr p)
{
  libatsdoc_sbuf_struct *b = (libatsdoc_sbuf_struct*)p ;
  char *res = b->ptr ;
  res = (char*)realloc(res, b->len + 1) ;
  res[b->len] = '\0' ;
  free (b) ;
  return res ;
}

/* as [takeout], but a NUL is an error (ATS1: [string_make_list_int] of the list of chars) */
static inline
atstype_ptr
libatsdoc_sbuf_takeout_nonul (atstype_ptr p)
{
  libatsdoc_sbuf_struct *b = (libatsdoc_sbuf_struct*)p ;
  if (memchr (b->ptr, 0, b->len)) {
    fprintf (stderr, "exit(ATS): a string cannot contain null characters in the middle.\n") ;
    exit (1) ;
  }
  return libatsdoc_sbuf_takeout (p) ;
}

/*
** HX: [fprint_newline] of ATS1 (the ATS2 one exits when the output fails)
*/
static inline
atstype_void
libatsdoc_fprint_newline (atstype_ptr out)
{
  fprintf ((FILE*)out, "\n") ; fflush ((FILE*)out) ; return ;
}

#endif // end of [LIBATSDOC_SBUF_CATS]

/* end of [libatsdoc_sbuf.cats] */
