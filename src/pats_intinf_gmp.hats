(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-2013 Hongwei Xi, ATS Trustful Software, Inc.
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
*)

(* ****** ****** *)
//
// Author: Hongwei Xi
// Authoremail: gmhwxiATgmailDOTcom
// Start Time: May, 2011
//
(* ****** ****** *)
//
#include "share/atspre_staload.hats"
//
(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload UT = "./pats_utils.sats"
staload _(*anon*) = "./pats_utils.dats"

(* ****** ****** *)

staload "./pats_intinf.sats"

(* ****** ****** *)
//
// HX: an intinf is a pointer to a heap-allocated mpz_t; as there
// is no GC, the global arena is used for the mpz_t cells (the memory
// functions of gmp are set to use the global arena as well)
//
assume intinf_type = ptr

(* ****** ****** *)
//
// HX: the C functions below are defined in the C code at the end
//
extern
fun mpz_new ():<> ptr = "mac#patsopt_mpz_new" // uninitialized cell
extern
fun mpz_init_set_int (p: ptr, i: int):<> void = "mac#patsopt_mpz_init_set_int"
extern
fun mpz_init_set_ulint (p: ptr, i: ulint):<> void = "mac#patsopt_mpz_init_set_ulint"
extern
fun mpz_init_set_mpz (p: ptr, q: ptr):<> void = "mac#patsopt_mpz_init_set_mpz"
extern
fun mpz_init_set_str_exn (p: ptr, s: string, base: int):<> void = "mac#patsopt_mpz_init_set_str_exn"
extern
fun mpz_neg1 (p: ptr):<> void = "mac#patsopt_mpz_neg1"
extern
fun mpz_add_int (p: ptr, i: int):<> void = "mac#patsopt_mpz_add_int"
extern
fun mpz_add_mpz (p: ptr, q: ptr):<> void = "mac#patsopt_mpz_add_mpz"
extern
fun mpz_sub_mpz (p: ptr, q: ptr):<> void = "mac#patsopt_mpz_sub_mpz"
extern
fun mpz_mul_int (p: ptr, i: int):<> void = "mac#patsopt_mpz_mul_int"
extern
fun mpz_mul_mpz (p: ptr, q: ptr):<> void = "mac#patsopt_mpz_mul_mpz"
extern
fun mpz_cmp_int (p: ptr, i: int):<> int = "mac#patsopt_mpz_cmp_int"
extern
fun mpz_cmp_mpz (p: ptr, q: ptr):<> int = "mac#patsopt_mpz_cmp_mpz"
extern
fun mpz_get_int (p: ptr):<> int = "mac#patsopt_mpz_get_int"
extern
fun fprint0_mpz (out: FILEref, p: ptr):<> void = "mac#patsopt_fprint0_mpz"

(* ****** ****** *)

fn
mpz_copy (p: ptr):<> ptr = let
  val res = mpz_new ()
  val () = mpz_init_set_mpz (res, p)
in
  res
end // end of [mpz_copy]

(* ****** ****** *)

implement
intinf_make_int (i) = let
  val p = mpz_new ()
  val () = mpz_init_set_int (p, i)
in
  $UN.cast{intinf}(p)
end // end of [intinf_make_int]

implement
intinf_make_size (sz) = let
  val p = mpz_new ()
  val () = mpz_init_set_ulint (p, $UN.cast{ulint}(sz))
in
  $UN.cast{intinf}(p)
end // end of [intinf_make_size]

(* ****** ****** *)
(*
** HX: [rep] is unsigned!
*)
implement
intinf_make_string (rep) = let
  val rep = g1ofg0 (rep)
in
//
if string_is_atend (rep, i2sz(0)) then intinf_make_int (0)
else let
  val c0 = rep[0]
in
  if c0 = '0' then (
    if string_is_atend (rep, i2sz(1)) then intinf_make_int (0)
    else let
      val c1 = rep[1]
    in
      if (c1 != 'x' && c1 != 'X') then
        intinf_make_base_string_ofs (8, rep, 1)
      else
        intinf_make_base_string_ofs (16, rep, 2)
      // end of [if]
    end
  ) else
    intinf_make_base_string_ofs (10, rep, 0)
  // end of [if]
end // end of [if]
//
end // end of [intinf_make_string]

(* ****** ****** *)

implement
intinf_make_base_string_ofs
  (base, rep, ofs) = let
//
  val rep_ofs =
    $UN.cast{string}(ptr0_add_guint<char>($UN.cast{ptr}(rep), i2sz(ofs)))
//
// HX-2018-07-01:
// "0x" is treated as "0x0"
//
  val rep_ofs =
  (if
   string_is_empty(g1ofg0(rep_ofs)) then "0" else rep_ofs
  ) : string // end of [val]
//
  val p = mpz_new ()
  val () = mpz_init_set_str_exn (p, rep_ofs, base)
in
  $UN.cast{intinf}(p)
end // end of [intinf_make_base_string_ofs]

(* ****** ****** *)

implement
fprint_intinf (out, x) = fprint0_mpz (out, $UN.cast{ptr}(x))

(* ****** ****** *)

implement
intinf_get_int (x) = mpz_get_int ($UN.cast{ptr}(x))

(* ****** ****** *)

implement
lt_intinf_int (x1, x2) =
  compare_intinf_int (x1, x2) < 0
// end of [lt_intinf_int]

implement
lte_intinf_int (x1, x2) =
  compare_intinf_int (x1, x2) <= 0
// end of [lte_intinf_int]

implement
gt_intinf_int (x1, x2) =
  compare_intinf_int (x1, x2) > 0
// end of [gt_intinf_int]

implement
gte_intinf_int (x1, x2) =
  compare_intinf_int (x1, x2) >= 0
// end of [gte_intinf_int]

(* ****** ****** *)

implement
eq_intinf_int (x1, x2) =
  compare_intinf_int (x1, x2) = 0
// end of [eq_intinf_int]

implement
eq_int_intinf (x1, x2) =
  compare_intinf_int (x2, x1) = 0
// end of [eq_int_intinf]

implement
eq_intinf_intinf (x1, x2) =
  compare_intinf_intinf (x1, x2) = 0
// end of [eq_intinf_intinf]

(* ****** ****** *)

implement
neq_intinf_int (x1, x2) =
  compare_intinf_int (x1, x2) != 0
// end of [neq_intinf_int]

implement
neq_int_intinf (x1, x2) =
  compare_intinf_int (x2, x1) != 0
// end of [neq_int_intinf]

implement
neq_intinf_intinf (x1, x2) =
  compare_intinf_intinf (x1, x2) != 0
// end of [neq_intinf_intinf]

(* ****** ****** *)

implement
compare_intinf_int
  (x1, x2) = mpz_cmp_int ($UN.cast{ptr}(x1), x2)
// end of [compare_intinf_int]

implement
compare_intinf_intinf
  (x1, x2) = mpz_cmp_mpz ($UN.cast{ptr}(x1), $UN.cast{ptr}(x2))
// end of [compare_intinf_intinf]

(* ****** ****** *)

implement
neg_intinf (x) = let
  val p = mpz_copy ($UN.cast{ptr}(x))
  val () = mpz_neg1 (p)
in
  $UN.cast{intinf}(p)
end // end of [neg_intinf]

(* ****** ****** *)

implement
add_intinf_int
  (x1, x2) = let
  val p = mpz_copy ($UN.cast{ptr}(x1))
  val () = mpz_add_int (p, x2)
in
  $UN.cast{intinf}(p)
end // end of [add_intinf_int]

implement
add_int_intinf (x1, x2) = add_intinf_int (x2, x1)

implement
add_intinf_intinf
  (x1, x2) = let
  val p = mpz_copy ($UN.cast{ptr}(x1))
  val () = mpz_add_mpz (p, $UN.cast{ptr}(x2))
in
  $UN.cast{intinf}(p)
end // end of [add_intinf_intinf]

(* ****** ****** *)

implement
sub_intinf_intinf
  (x1, x2) = let
  val p = mpz_copy ($UN.cast{ptr}(x1))
  val () = mpz_sub_mpz (p, $UN.cast{ptr}(x2))
in
  $UN.cast{intinf}(p)
end // end of [sub_intinf_intinf]

(* ****** ****** *)

implement
mul_intinf_int
  (x1, x2) = let
  val p = mpz_copy ($UN.cast{ptr}(x1))
  val () = mpz_mul_int (p, x2)
in
  $UN.cast{intinf}(p)
end // end of [mul_intinf_int]

implement
mul_int_intinf (x1, x2) = mul_intinf_int (x2, x1)

implement
mul_intinf_intinf
  (x1, x2) = let
  val p = mpz_copy ($UN.cast{ptr}(x1))
  val () = mpz_mul_mpz (p, $UN.cast{ptr}(x2))
in
  $UN.cast{intinf}(p)
end // end of [mul_intinf_intinf]

(* ****** ****** *)

local
//
// HX: an intinfset is a list in DESCENDING order (and duplicate-free), like [funset_listord] of ATS1:
// [intinfset_listize] (and [fprint_intinfset]) give the largest element first
//
assume intinfset_type = glist(intinf)
//
in (*in-of-local*)

implement
intinfset_sing (x) = glist_sing (x)

implement
intinfset_is_member
  (xs, x) = (
//
case+ glist_view(xs) of
| ~GLnil () => false
| ~GLcons (x1, xs1) => let
    val sgn = compare_intinf_intinf (x1, x)
  in
    if sgn > 0
      then intinfset_is_member (xs1, x) else (sgn = 0)
    // end of [if]
  end (* end of [GLcons] *)
//
) (* end of [intinfset_is_member] *)

implement
intinfset_add
  (xs, x) = (
//
case+ glist_view(xs) of
| ~GLnil () => glist_sing (x)
| ~GLcons (x1, xs1) => let
    val sgn = compare_intinf_intinf (x1, x)
  in
    if sgn > 0
      then glist_cons (x1, intinfset_add (xs1, x))
      else (if sgn = 0 then xs else glist_cons (x, xs))
    // end of [if]
  end (* end of [GLcons] *)
//
) (* end of [intinfset_add] *)

implement
intinfset_listize (xs) = glist_listize (xs)

end // end of [local]

(* ****** ****** *)

implement
fprint_intinfset
  (out, xs) = $UT.fprintlst<intinf>
  (out, $UN.cast{glist(intinf)}(xs), ", ", fprint_intinf)
// end of [fprint_intinfset]

(* ****** ****** *)

val () = intinf_initialize () where
{
//
extern
fun intinf_initialize ():<> void = "mac#patsopt_intinf_initialize"
//
} (* end of [where] *) // end of [val]

(* ****** ****** *)

%{^
#include <gmp.h>
extern atstype_void patsopt_intinf_initialize () ;
//
// HX: thin wrappers over gmp: an [mpz_t] cell is an [mpz_ptr]
//
static
void* patsopt_mpz_new () { return atslib_the_garena_alloc (sizeof(mpz_t)) ; }
static void patsopt_mpz_init_set_int (void *p, int i) { mpz_init_set_si ((mpz_ptr)p, i) ; }
static void patsopt_mpz_init_set_ulint (void *p, unsigned long i) { mpz_init_set_ui ((mpz_ptr)p, i) ; }
static void patsopt_mpz_init_set_mpz (void *p, void *q) { mpz_init_set ((mpz_ptr)p, (mpz_ptr)q) ; }
static
void patsopt_mpz_init_set_str_exn (void *p, char *s, int base)
{
  if (mpz_init_set_str ((mpz_ptr)p, s, base) < 0) {
    fprintf (stderr, "exit(ATS): mpz_init_set_str failed: %s\n", s) ; exit (1) ;
  }
}
static void patsopt_mpz_neg1 (void *p) { mpz_neg ((mpz_ptr)p, (mpz_ptr)p) ; }
static void patsopt_mpz_add_int (void *p, int i) { if (i >= 0) mpz_add_ui ((mpz_ptr)p, (mpz_ptr)p, (unsigned long)i) ; else mpz_sub_ui ((mpz_ptr)p, (mpz_ptr)p, (unsigned long)(-(long)i)) ; }
static void patsopt_mpz_add_mpz (void *p, void *q) { mpz_add ((mpz_ptr)p, (mpz_ptr)p, (mpz_ptr)q) ; }
static void patsopt_mpz_sub_mpz (void *p, void *q) { mpz_sub ((mpz_ptr)p, (mpz_ptr)p, (mpz_ptr)q) ; }
static void patsopt_mpz_mul_int (void *p, int i) { mpz_mul_si ((mpz_ptr)p, (mpz_ptr)p, i) ; }
static void patsopt_mpz_mul_mpz (void *p, void *q) { mpz_mul ((mpz_ptr)p, (mpz_ptr)p, (mpz_ptr)q) ; }
static int patsopt_mpz_cmp_int (void *p, int i) { return mpz_cmp_si ((mpz_ptr)p, i) ; }
static int patsopt_mpz_cmp_mpz (void *p, void *q) { return mpz_cmp ((mpz_ptr)p, (mpz_ptr)q) ; }
static int patsopt_mpz_get_int (void *p) { return (int)mpz_get_si ((mpz_ptr)p) ; }
static void patsopt_fprint0_mpz (void *out, void *p) { mpz_out_str ((FILE*)out, 10, (mpz_ptr)p) ; }
%}

%{$
//
// This is necessary to prevent memory leak
//
static
void* patsopt_intinf_malloc
  (size_t sz) { return ATS_MALLOC (sz) ; }
// end of [patsopt_intinf_malloc]

static
void patsopt_intinf_free
  (void* ptr, size_t sz) { ATS_MFREE (ptr) ; return ; }
// end of [patsopt_intinf_free]

static
void* patsopt_intinf_realloc (
  void* ptr, size_t sz_old, size_t sz_new
) {
  return ATS_REALLOC (ptr, sz_new) ;
} // end of [patsopt_intinf_realloc]

atstype_void
patsopt_intinf_initialize
  (/*argumentless*/) {
  mp_set_memory_functions (
    &patsopt_intinf_malloc, &patsopt_intinf_realloc, &patsopt_intinf_free
  ) ; // end of [mp_set_memory_functions]
  return ;
} // end of [patsopt_intinf_initialize]

%} // end of [%{$]

(* ****** ****** *)

(* end of [pats_intinf_gmp.hats] *)
