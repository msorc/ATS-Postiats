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
** arenas (regions) for memory that is
** released all at once (no GC is needed)
*/

/* ****** ****** */

#ifndef ATSLIB_LIBATS_CATS_ARENA
#define ATSLIB_LIBATS_CATS_ARENA

/* ****** ****** */

#include <string.h>

/* ****** ****** */

typedef
struct atslib_arena_chunk_s
{
  struct atslib_arena_chunk_s *next ;
  size_t size ; // the capacity of [data]
  size_t used ; // the used part of [data]
  double data[1] ; // HX: for alignment
} atslib_arena_chunk ;

typedef
struct {
  atslib_arena_chunk *head ;
  size_t chunksz ; // the default chunk size
  size_t ntotal ; // the total number of allocated bytes
} atslib_arena_struct ;

/* ****** ****** */

#define ATSLIB_ARENA_ALIGN (sizeof(double) > sizeof(void*) ? sizeof(double) : sizeof(void*))
#define ATSLIB_ARENA_CHUNKSZ (64 * 1024)

/* ****** ****** */

ATSinline()
atstype_ptr
atslib_arena_make_size
  (atstype_size chunksz)
{
  atslib_arena_struct *ar ;
  ar = ATS_MALLOC(sizeof(atslib_arena_struct)) ;
  ar->head = (atslib_arena_chunk*)0 ;
  ar->chunksz = (chunksz > 0 ? chunksz : ATSLIB_ARENA_CHUNKSZ) ;
  ar->ntotal = 0 ;
  return ar ;
} /* end of [atslib_arena_make_size] */

#define \
atslib_arena_make_nil() atslib_arena_make_size(ATSLIB_ARENA_CHUNKSZ)

/* ****** ****** */

ATSinline()
atsvoid_t0ype
atslib_arena_free
  (atstype_ptr ar0)
{
  atslib_arena_struct *ar = ar0 ;
  atslib_arena_chunk *chk = ar->head, *chk2 ;
  while (chk) { chk2 = chk->next ; ATS_MFREE(chk) ; chk = chk2 ; }
  ATS_MFREE(ar) ; return ;
} /* end of [atslib_arena_free] */

/* ****** ****** */

ATSinline()
atstype_size
atslib_arena_get_ntotal
  (atstype_ptr ar0)
{
  return ((atslib_arena_struct*)ar0)->ntotal ;
} /* end of [atslib_arena_get_ntotal] */

/* ****** ****** */
//
// HX: the allocated memory is zero-filled
//
ATSinline()
atstype_ptr
atslib_arena_alloc
(
  atstype_ptr ar0, atstype_size bsz
)
{
  char *res ;
  atslib_arena_struct *ar = ar0 ;
  atslib_arena_chunk *chk = ar->head ;
  size_t align = ATSLIB_ARENA_ALIGN ;
  size_t bsz2 = ((bsz + align - 1) / align) * align ;
  if (bsz2 == 0) bsz2 = align ;
  if (!chk || chk->used + bsz2 > chk->size)
  {
    size_t size =
      (bsz2 > ar->chunksz ? bsz2 : ar->chunksz) ;
    chk = ATS_MALLOC(sizeof(atslib_arena_chunk) + size) ;
    chk->next = ar->head ; chk->size = size ; chk->used = 0 ;
    ar->head = chk ;
  } /* end of [if] */
  res = ((char*)chk->data) + chk->used ;
  chk->used += bsz2 ; ar->ntotal += bsz2 ;
  memset(res, 0, bsz2) ;
  return res ;
} /* end of [atslib_arena_alloc] */

/* ****** ****** */

ATSinline()
atstype_ptr
atslib_arena_strdup
(
  atstype_ptr ar0, atstype_string str
)
{
  size_t n = strlen((char*)str) ;
  char *res = atslib_arena_alloc(ar0, n+1) ;
  memcpy(res, str, n) ; res[n] = '\000' ; return res ;
} /* end of [atslib_arena_strdup] */

/* ****** ****** */

/* ****** ****** */
/*
** HX-2026-10:
** the global arena: what is allocated in it
** lives until the program exits (the arena is
** never freed); there is one per compilation unit
*/
ATSinline()
atstype_ptr
atslib_the_garena_alloc
  (atstype_size bsz)
{
  static atslib_arena_struct *the_garena = 0 ;
  if (!the_garena)
    the_garena = atslib_arena_make_size(ATSLIB_ARENA_CHUNKSZ) ;
  return atslib_arena_alloc(the_garena, bsz) ;
} /* end of [atslib_the_garena_alloc] */

ATSinline()
atstype_string
atslib_the_garena_strdup
  (atstype_string str)
{
  size_t n = strlen((char*)str) ;
  char *res = atslib_the_garena_alloc(n+1) ;
  memcpy(res, str, n) ; res[n] = '\000' ; return res ;
} /* end of [atslib_the_garena_strdup] */

/* ****** ****** */

#endif // ifndef ATSLIB_LIBATS_CATS_ARENA

/* ****** ****** */

/* end of [arena.cats] */
