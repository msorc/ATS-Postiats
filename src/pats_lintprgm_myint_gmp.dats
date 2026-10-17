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
// Authoremail: gmhwxi AT gmail DOT com
// Time: February 2012
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_lintprgm_myint_gmp.dats)
// This file is #include-d by the user of [icnstrlst_solve<gmpknd>] (link with -lgmp)
// A [myint(gmpknd)] is a pointer to a malloc-ed [mpz_t]
//
(* ****** ****** *)

%{^
#include "pats_lintprgm_myint_gmp.cats"
%} // end of [%{^]

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload INTINF = "./pats_intinf.sats"

(* ****** ****** *)

staload "./pats_lintprgm.sats"

(* ****** ****** *)

vtypedef myint = myint (gmpknd)

extern castfn myint2ptr0 (x: myint):<> ptr
// HX: the pointer is only borrowed
extern castfn myint2ptr1 (x: !myint):<> ptr
extern castfn ptr2myint (x: ptr):<> myint
//
macdef mi2p0 = myint2ptr0
macdef mi2p1 = myint2ptr1
macdef p2mi = ptr2myint

(* ****** ****** *)

extern fun lpz_new_si (i: int):<> ptr = "mac#patsopt_lpz_new_si"
extern fun lpz_new_copy (p: ptr):<> ptr = "mac#patsopt_lpz_new_copy"
extern fun lpz_new_zero ():<> ptr = "mac#patsopt_lpz_new_zero"
extern fun lpz_free (p: ptr):<> void = "mac#patsopt_lpz_free"
extern fun lpz_neg (p: ptr):<> void = "mac#patsopt_lpz_neg"
extern fun lpz_neg_to (r: ptr, p: ptr):<> void = "mac#patsopt_lpz_neg_to"
extern fun lpz_add_si (p: ptr, i: int):<> void = "mac#patsopt_lpz_add_si"
extern fun lpz_add (p: ptr, q: ptr):<> void = "mac#patsopt_lpz_add"
extern fun lpz_sub (p: ptr, q: ptr):<> void = "mac#patsopt_lpz_sub"
extern fun lpz_mul_to (r: ptr, p: ptr, q: ptr):<> void = "mac#patsopt_lpz_mul_to"
extern fun lpz_tdiv_q (p: ptr, q: ptr):<> void = "mac#patsopt_lpz_tdiv_q"
extern fun lpz_divexact (p: ptr, q: ptr):<> void = "mac#patsopt_lpz_divexact"
extern fun lpz_mod_to (r: ptr, p: ptr, q: ptr):<> void = "mac#patsopt_lpz_mod_to"
extern fun lpz_gcd (p: ptr, q: ptr):<> void = "mac#patsopt_lpz_gcd"
extern fun lpz_cmp_si (p: ptr, i: int):<> int = "mac#patsopt_lpz_cmp_si"
extern fun lpz_cmp (p: ptr, q: ptr):<> int = "mac#patsopt_lpz_cmp"
extern fun lpz_fprint (out: FILEref, p: ptr):<> void = "mac#patsopt_lpz_fprint"

(* ****** ****** *)
//
implement
fprint_myint<gmpknd>
  (out, x) = lpz_fprint (out, mi2p1(x))
//
implement
print_myint<gmpknd> (x) = fprint_myint<gmpknd> (stdout_ref, x)
implement
prerr_myint<gmpknd> (x) = fprint_myint<gmpknd> (stderr_ref, x)
//
(* ****** ****** *)

implement
myint_make_int<gmpknd> (i) = p2mi (lpz_new_si (i))

(* ****** ****** *)
//
// HX: an intinf is a pointer to the [mpz_t] cell
//
implement
myint_make_intinf<gmpknd> (i) = p2mi (lpz_new_copy ($UN.cast{ptr}(i)))

(* ****** ****** *)

implement
myint_copy<gmpknd> (x) = p2mi (lpz_new_copy (mi2p1(x)))

(* ****** ****** *)

implement
myint_free<gmpknd> (x) = lpz_free (mi2p0(x))

(* ****** ****** *)

implement
neg_myint<gmpknd>
  (x) = let val p = mi2p0(x) in lpz_neg (p); p2mi(p) end
// end of [neg_myint<gmpknd>]

implement
neg1_myint<gmpknd>
  (x) = let
  val r = lpz_new_zero ()
  val () = lpz_neg_to (r, mi2p1(x))
in
  p2mi(r)
end // end of [neg1_myint<gmpknd>]

(* ****** ****** *)

implement
add01_myint_myint<gmpknd>
  (x, y) = let
  val p = mi2p0(x) in lpz_add (p, mi2p1(y)); p2mi(p)
end // end of [add_myint_myint<gmpknd>]

implement
sub01_myint_myint<gmpknd>
  (x, y) = let
  val p = mi2p0(x) in lpz_sub (p, mi2p1(y)); p2mi(p)
end // end of [sub_myint_myint<gmpknd>]

implement
add_myint_int<gmpknd>
  (x, i) = let
  val p = mi2p0(x) in lpz_add_si (p, i); p2mi(p)
end // end of [add_myint_int<gmpknd>]

(* ****** ****** *)

implement
mul01_myint_myint<gmpknd>
  (x, y) = let
  val p = mi2p0(x) in lpz_mul_to (p, p, mi2p1(y)); p2mi(p)
end // end of [mul01_myint_myint<gmpknd>]

implement
mul10_myint_myint<gmpknd>
  (x, y) = let
  val q = mi2p0(y) in lpz_mul_to (q, mi2p1(x), q); p2mi(q)
end // end of [mul10_myint_myint<gmpknd>]

implement
mul11_myint_myint<gmpknd>
  (x, y) = let
  val r = lpz_new_zero ()
  val () = lpz_mul_to (r, mi2p1(x), mi2p1(y))
in
  p2mi(r)
end // end of [mul11_myint_myint<gmpknd>]

(* ****** ****** *)

implement
div01_myint_myint<gmpknd>
  (x, y) = let
  val p = mi2p0(x) in lpz_tdiv_q (p, mi2p1(y)); p2mi(p)
end // end of [div01_myint_myint<gmpknd>]

(*
** HX: div11 is declared but not implemented in ATS1 (gmpknd)
*)

implement
ediv01_myint_myint<gmpknd>
  (x, y) = let
  val p = mi2p0(x) in lpz_divexact (p, mi2p1(y)); p2mi(p)
end // end of [ediv01_myint_myint<gmpknd>]

(* ****** ****** *)

implement
mod01_myint_myint<gmpknd>
  (x, y) = let
  val p = mi2p0(x) in lpz_mod_to (p, p, mi2p1(y)); p2mi(p)
end // end of [mod01_myint_myint<gmpknd>]

implement
mod11_myint_myint<gmpknd>
  (x, y) = let
  val r = lpz_new_zero ()
  val () = lpz_mod_to (r, mi2p1(x), mi2p1(y))
in
  p2mi(r)
end // end of [mod11_myint_myint<gmpknd>]

(* ****** ****** *)

implement
gcd01_myint_myint<gmpknd>
  (x, y) = let
  val p = mi2p0(x) in lpz_gcd (p, mi2p1(y)); p2mi(p)
end // end of [gcd01_myint_myint<gmpknd>]

(* ****** ****** *)

implement
compare_myint_int<gmpknd>
  (x, i) = lpz_cmp_si (mi2p1(x), i)
// end of [compare_myint_int<gmpknd>]

implement
compare_myint_myint<gmpknd>
  (x, y) = lpz_cmp (mi2p1(x), mi2p1(y))
// end of [compare_myint_myint<gmpknd>]

(* ****** ****** *)

(* end of [pats_lintprgm_myint_gmp.dats] *)
