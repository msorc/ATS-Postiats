(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(***********************************************************************)

(*
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
*)

(* ****** ****** *)
//
(* ****** ****** *)
//
// Author: Hongwei Xi (hwxi AT cs DOT bu DOT edu)
// Start Time: April, 2011
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of the ATS1 version of this file)
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "./../SATS/libatsdoc_symbol.sats"

(* ****** ****** *)

implement
eq_symbol_symbol (x1, x2) = (symbol_get_stamp (x1) = symbol_get_stamp (x2))
implement
neq_symbol_symbol (x1, x2) = (symbol_get_stamp (x1) != symbol_get_stamp (x2))

implement
compare_symbol_symbol (x1, x2) = let
  val s1 = symbol_get_stamp (x1) and s2 = symbol_get_stamp (x2)
in
  if s1 < s2 then ~1 else (if s1 > s2 then 1 else 0)
end // end of [compare_symbol_symbol]

(* ****** ****** *)

implement
fprint_symbol (out, x) = fprint_string (out, symbol_get_name (x))
implement
print_symbol (x) = fprint_symbol (stdout_ref, x)
implement
prerr_symbol (x) = fprint_symbol (stderr_ref, x)

(* ****** ****** *)

%{$
#include "libatsdoc/CATS/libatsdoc_symbol.cats"

#define LIBATSDOC_SYMTBL_INISZ 1024

static libatsdoc_symbol_struct **libatsdoc_symtbl = 0 ;
static size_t libatsdoc_symtbl_size = 0 ;
static size_t libatsdoc_symtbl_count = 0 ;

static
size_t
libatsdoc_symbol_hash (const char *s)
{
  size_t h = 5381 ; unsigned char c ;
  while ((c = (unsigned char)*s++)) h = h * 33 + c ;
  return h ;
}

static
void
libatsdoc_symtbl_grow (void)
{
  size_t i, nsz = libatsdoc_symtbl_size ? 2 * libatsdoc_symtbl_size : LIBATSDOC_SYMTBL_INISZ ;
  libatsdoc_symbol_struct **ntbl = (libatsdoc_symbol_struct**)calloc(nsz, sizeof(void*)) ;
  for (i = 0 ; i < libatsdoc_symtbl_size ; i += 1) {
    libatsdoc_symbol_struct *p = libatsdoc_symtbl[i], *q ;
    while (p) { q = p->next ; p->next = ntbl[libatsdoc_symbol_hash(p->name) % nsz] ; ntbl[libatsdoc_symbol_hash(p->name) % nsz] = p ; p = q ; }
  }
  free (libatsdoc_symtbl) ;
  libatsdoc_symtbl = ntbl ; libatsdoc_symtbl_size = nsz ;
}

atstype_ptr
libatsdoc_symbol_make_string (atstype_ptr name0)
{
  const char *name = (const char*)name0 ;
  libatsdoc_symbol_struct *p ;
  size_t h, n ;
  if (libatsdoc_symtbl_count >= libatsdoc_symtbl_size) libatsdoc_symtbl_grow () ;
  h = libatsdoc_symbol_hash (name) % libatsdoc_symtbl_size ;
  for (p = libatsdoc_symtbl[h] ; p ; p = p->next)
    if (strcmp (p->name, name) == 0) return p ;
  p = (libatsdoc_symbol_struct*)malloc(sizeof(libatsdoc_symbol_struct)) ;
  n = strlen (name) ;
  p->name = (char*)malloc(n + 1) ; memcpy (p->name, name, n + 1) ;
  p->stamp = (unsigned int)libatsdoc_symtbl_count ;
  p->value = 0 ;
  p->next = libatsdoc_symtbl[h] ; libatsdoc_symtbl[h] = p ;
  libatsdoc_symtbl_count += 1 ;
  return p ;
}

atstype_ptr libatsdoc_symbol_empty = 0 ;
static void libatsdoc_symbol_init (void) __attribute__((constructor)) ;
static void libatsdoc_symbol_init (void) { libatsdoc_symbol_empty = libatsdoc_symbol_make_string ("") ; }
%}

(* ****** ****** *)

(* end of [libatsdoc_symbol.dats] *)
