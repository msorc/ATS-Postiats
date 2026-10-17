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
// HX-2026-10: no GC (ATS2 port of src/pats_lintprgm.dats, see PORTING.md
// "Constraint solver (lintprgm)")
//
#include "share/atspre_staload.hats"
#include "./pats_assert.hats"
//
(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "./pats_utils.sats"

(* ****** ****** *)

staload "./pats_lintprgm.sats"

(* ****** ****** *)

implement{a}
lt_myint_int (x, i) = (compare_myint_int (x, i) < 0)
implement{a}
lte_myint_int (x, i) = (compare_myint_int (x, i) <= 0)

implement{a}
gt_myint_int (x, i) = (compare_myint_int (x, i) > 0)
implement{a}
gte_myint_int (x, i) = (compare_myint_int (x, i) >= 0)

implement{a}
eq_myint_int (x, i) = (compare_myint_int (x, i) = 0)
implement{a}
neq_myint_int (x, i) = (compare_myint_int (x, i) != 0)

(* ****** ****** *)

implement{a}
lt_myint_myint (x1, x2) = (compare_myint_myint (x1, x2) < 0)
implement{a}
lte_myint_myint (x1, x2) = (compare_myint_myint (x1, x2) <= 0)

implement{a}
gt_myint_myint (x1, x2) = (compare_myint_myint (x1, x2) > 0)
implement{a}
gte_myint_myint (x1, x2) = (compare_myint_myint (x1, x2) >= 0)

(* ****** ****** *)

implement{a}
myintvec_get_at
  (iv, i) = x where {
  val (pf | p) = myintvec_takeout (iv)
  val (pfat, fpf | p_i) = array_ptr_takeout<myint(a)> (pf | p, i2sz(i))
  val x = myint_copy (!p_i)
  prval () = pf := fpf (pfat)
  prval () = myintvecout_addback (pf | iv)
} // end of [myintvec_get_at]

implement{a}
myintvec_set_at
  (iv, i, x) = () where {
  val (pf | p) = myintvec_takeout (iv)
  val (pfat, fpf | p_i) = array_ptr_takeout<myint(a)> (pf | p, i2sz(i))
  val () = myint_free (!p_i)
  val () = !p_i := x
  prval () = pf := fpf (pfat)
  prval () = myintvecout_addback (pf | iv)
} // end of [myintvec_set_at]

(* ****** ****** *)

implement{a}
myintvec_compare_at
  (iv, i, x) = sgn where {
  val (pf | p) = myintvec_takeout (iv)
  val (pfat, fpf | p_i) = array_ptr_takeout<myint(a)> (pf | p, i2sz(i))
  val sgn = compare_myint_int (!p_i, x)
  prval () = pf := fpf (pfat)
  prval () = myintvecout_addback (pf | iv)
} // end of [myintvec_compare_at]

(* ****** ****** *)

implement{a}
myintvec_add_int
  (iv, i) = let
  vtypedef x = myint(a)
  val (pf | p) = myintvec_takeout {a} (iv)
  prval (pf1, pf2) = array_v_uncons {x} (pf)
  val () = !p := add_myint_int (!p, i)
  prval () = pf := array_v_cons {x} (pf1, pf2)
  prval () = myintvecout_addback (pf | iv)
in
  // nothing
end // end of [myintvec_add_int]

(* ****** ****** *)

implement
myintvec0_free
  {a}{n} (xs, n) = let
  vtypedef vt = myint(a)
  val (pfgc, pf | p) = __cast (xs) where {
    extern castfn __cast
      (x: myintvec0 (a, n))
      :<> [l:addr] (mfree_gc_v (l), array_v(vt?, l, n) | ptr l)
  } // end of [val]
in
  $effmask_wrt (array_ptr_free (pf, pfgc | p))
end // end of [myintvec0_free]

implement{a}
myintvec_free (iv, n) = let
  vtypedef x = myint(a)
//
  fun loop
    {n:nat}{l:addr} .<n>.
  (
    pf: !array_v (x, l, n) >> array_v (x?, l, n) | p: ptr l, n: int n
  ) : void =
    if n > 0 then let
      prval (pf1, pf2) = array_v_uncons {x} (pf)
      val () = myint_free<a> (!p)
      val () = loop (pf2 | ptr_succ<x> (p), n-1)
      prval () = pf := array_v_cons {x?} (pf1, pf2)
    in
      // nothing
    end else let
      prval () = array_v_unnil (pf) in pf := array_v_nil {x?} ()
    end // end of [if]
//
  prval () = lemma_myintvec_params (iv)
  val (pfarr | p) = myintvec_takeout (iv)
  val () = loop (pfarr | p, n)
  prval () = myintvecout0_addback {a} (pfarr | iv)
in
  myintvec0_free (iv, n)
end // end of [myintvec_free]

(* ****** ****** *)

implement{a}
icnstr_copy (ic, n) =
  case+ ic of
  | @ICvec (knd, iv) => let
      val iv_new = myintvec_copy<a> (iv, n)
      val knd1 = knd
    in
      fold@ (ic); ICvec (knd1, iv_new)
    end // end of [ICvec]
  | @ICveclst (knd, ics) => let
      val ics_new = icnstrlst_copy<a> (ics, n)
      val knd1 = knd
    in
      fold@ (ic); ICveclst (knd1, ics_new)
    end // end of [ICveclst]
  | @ICerr (loc, s3e) => let
      val loc1 = loc and s3e1 = s3e
    in
      fold@ (ic); ICerr (loc1, s3e1)
    end // end of [ICerr]
// end of [icnstr_copy]

implement{a}
icnstrlst_copy (ics, n) =
  case+ ics of
  | @list_vt_cons
      (ic, ics1) => let
      val ic_new = icnstr_copy<a> (ic, n)
      val ics1_new = icnstrlst_copy<a> (ics1, n)
      prval () = fold@ (ics)
    in
      list_vt_cons (ic_new, ics1_new)
    end // end of [list_vt_cons]
  | list_vt_nil () => list_vt_nil ()
// end of [icnstrlst_copy]

(* ****** ****** *)

implement{a}
icnstr_negate (ic) =
  case+ ic of
  | @ICvec (knd, _) => (
      knd := ~(knd); fold@ (ic); ic
    ) // end of [ICvec]
  | @ICveclst (knd, ics) => let
      val () = knd := 1-knd
      val () = ics := icnstrlst_negate<a> (ics)
    in
      fold@ (ic); ic
    end // end of [ICveclst]
  | @ICerr _ => (fold@ (ic); ic)
// end of [icnstr_negate]

implement{a}
icnstrlst_negate (ics) =
  case+ ics of
  | @list_vt_cons (ic, ics1) => let
      val () = ic := icnstr_negate<a> (ic)
      val () = ics1 := icnstrlst_negate<a> (ics1)
    in
      fold@ (ics); ics
    end // end of [list_vt_cons]
  | list_vt_nil () => ics
// end of [icnstrlst_negate]

(* ****** ****** *)

implement{a}
myintveclst_free (ivs, n) =
  case+ ivs of
  | ~list_vt_cons (iv, ivs) =>
      (myintvec_free<a> (iv, n); myintveclst_free<a> (ivs, n))
  | ~list_vt_nil () => ()
// end of [myintveclst_free]

(* ****** ****** *)

implement{a}
icnstr_free (x, n) =
  case+ x of
  | ~ICvec (knd, obj) => myintvec_free<a> (obj, n)
  | ~ICveclst (knd, xs) => icnstrlst_free<a> (xs, n)
  | ~ICerr (loc, s3e) => ()
// end of [icnstr_free]

implement{a}
icnstrlst_free (xs, n) =
  case+ xs of
  | ~list_vt_cons (x, xs) =>
      (icnstr_free<a> (x, n); icnstrlst_free<a> (xs, n))
  | ~list_vt_nil () => ()
// end of [icnstrlst_free]

(* ****** ****** *)

#define UNDECIDED 0
#define TAUTOLOGY 1
#define CONTRADICTION ~1

(* ****** ****** *)

extern
fun{a:t@ype}
myintvec_normalize // knd=2/1:gte/eq
  {n:pos} (knd: int, vec: !myintvec (a, n), n: int n): Ans2(*~1/0*)
// end of [myintvec_normalize]

(* ****** ****** *)

implement{a}
myintvec_inspect
  {n}(knd, iv, n) = let
//
vtypedef vt = myint(a)
//
fun
loop
{n:nat}
{l:addr} .<n>.
(
  pf: !array_v (vt, l, n) | p: ptr l, n: int n
) : bool(*cffs=0*) = let
in
  if n > 0 then let
    prval (pf1, pf2) = array_v_uncons {vt} (pf)
  in
    if !p = 0 then let
      val ans = loop (pf2 | ptr_succ<vt> (p), n-1)
      prval () = pf := array_v_cons {vt} (pf1, pf2)
    in
      ans
    end else let
      prval () = pf := array_v_cons {vt} (pf1, pf2)
    in
      false
    end // end of [if]
  end else true // end of [if]
end // end of [loop]
//
val (pf | p) = myintvec_takeout (iv)
prval (pf1, pf2) = array_v_uncons {vt} (pf)
val cffsZero = loop (pf2 | ptr_succ<vt> (p), n-1)
var ans3: Ans3 = UNDECIDED
val () = (
//
if cffsZero then (
  if knd = 2 then (
    // gte
    if !p >= 0 then ans3 := TAUTOLOGY else ans3 := CONTRADICTION
  ) else if knd = ~2 then (
    // lt
    if !p  <  0 then ans3 := TAUTOLOGY else ans3 := CONTRADICTION
  ) else if knd = 1 then (
    // eq
    if !p  =  0 then ans3 := TAUTOLOGY else ans3 := CONTRADICTION
  ) else if knd = ~1 then (
    // neq
    if !p != 0 then ans3 := TAUTOLOGY else ans3 := CONTRADICTION
  ) else () // HX: this should not happen
) // end of [if]
//
) : void // end of [val]
//
prval () =
  pf := array_v_cons {vt} (pf1, pf2)
prval () = myintvecout_addback (pf | iv)
//
in
  ans3(*~1/0/1*)
end // end of [myintvec_inspect]

implement{a}
myintvec_inspect_lt
  (iv, n) = myintvec_inspect<a> (~2(*lt*), iv, n)
// end of [myintvec_inspect_gte]

implement{a}
myintvec_inspect_gte
  (iv, n) = myintvec_inspect<a> (2(*gte*), iv, n)
// end of [myintvec_inspect_gte]

implement{a}
myintvec_inspect_eq
  (iv, n) = let
  val knd = 1(*eq*)
  val ans2 = myintvec_inspect<a> (knd, iv, n)
in
  if ans2 = 0 then
    myintvec_normalize<a> (knd, iv, n) else ans2
  // end of [if]
end // end of [myintvec_inspect_eq]

implement{a}
myintvec_inspect_neq
  (iv, n) = myintvec_inspect<a> (~1(*neq*), iv, n)
// end of [myintvec_inspect_neq]

(* ****** ****** *)

implement{a}
myintveclst_inspect_gte
  {n} (ivs, n) = let
//
vtypedef vt = myintvec (a,n)
//
in
//
case+ ivs of
| @list_vt_cons
    (iv, ivs1) => let
    val ans3 =
      myintvec_inspect_gte<a> (iv, n)
    // end of [val]
  in
    if ans3 != 0 then let
      val ivs1_ = ivs1
      val () = myintvec_free<a> (iv, n)
      val () = free@ {vt}{0} (ivs)
      val () = ivs := ivs1_
    in
      if ans3 > 0 then // TAUTOLOGY
        myintveclst_inspect_gte<a> (ivs, n) else ~1(*CONTRADICTION*)
      // end of [if]
    end else let
      val ans =
        myintveclst_inspect_gte<a> (ivs1, n)
      prval () = fold@ (ivs)
    in
      ans // the final answers
    end // end of [if]
  end (* end of [list_vt_cons] *)
| list_vt_nil () => 0(*UNDECIDED*)
//
end // end of [myintveclst_inspect_gte]

(* ****** ****** *)

implement{a}
myintvec_cffgcd
  {n}(iv, n) = let
//
vtypedef vt = myint(a)
//
// HX: [res] is the gcd found so far; the loop is stopped as soon as the
// gcd is known to be 1
//
fun
loop
  {n:nat}
  {l:addr} .<n>.
(
  pf: !array_v (vt, l, n) | p: ptr l, n: int n, res: &vt
) : void = (
if
n > 0
then let
  prval (pf1, pf2) = array_v_uncons {vt} (pf)
  val () = (
    if !p != 0 then (
      if !p != 1 then let
        val () = res := gcd01_myint_myint<a> (res, !p)
      in
        loop (pf2 | ptr_succ<vt> (p), n-1, res)
      end else let
        val () = myint_free<a> (res)
        val () = res := myint_make_int<a> (1)
      in
        // nothing
      end // end of [if]
    ) else (
      loop (pf2 | ptr_succ<vt> (p), n-1, res)
    ) // end of [if]
  ) : void
  prval () = pf := array_v_cons {vt} (pf1, pf2)
in
  // nothing
end else () // end of [if]
) (* end of [loop] *)
//
var res: myint(a) = myint_make_int<a> (0)
val (pfarr | p_arr) = myintvec_takeout (iv)
prval (pf1, pf2) = array_v_uncons {vt} (pfarr)
val () = loop (pf2 | ptr_succ<vt> (p_arr), n-1, res)
prval () = pfarr := array_v_cons {vt} (pf1, pf2)
prval () = myintvecout_addback (pfarr | iv)
//
in
  res
end // end of [myintvec_cffgcd]

(* ****** ****** *)

implement{a}
myintvec_normalize
  {n} (knd, iv, n) = let
//
vtypedef vt = myint (a)
//
fun
loop
  {n:nat}
  {l:addr} .<n>.
(
  pf: !array_v (vt, l, n) | gcd: !vt, p: ptr l, n: int n

) : void =
  if n > 0 then let
    prval
    (pf1, pf2) =
      array_v_uncons {vt} (pf)
    // end of [prval]
    val () = !p := ediv01_myint_myint<a> (!p, gcd)
    val () = loop (pf2 | gcd, ptr_succ<vt> (p), n-1)
    prval () = pf := array_v_cons {vt} (pf1, pf2)
  in
    // nothing
  end // end of [if]
//
val gcd = myintvec_cffgcd<a> (iv, n)
//
in
//
if gcd > 1 then let
  val (pf | p) = myintvec_takeout {a} (iv)
  prval (pf1, pf2) = array_v_uncons {vt} (pf)
  var ans2: Ans2 = 0
  val () = loop (pf2 | gcd, ptr_succ<vt> (p), n-1)
  val () = (
    if knd = 2 then (
        if !p >= 0 then
          !p := div01_myint_myint<a> (!p, gcd)
        else let // !p < 0
          val () = !p := sub01_myint_myint<a> (!p, gcd)
          val () = !p := add_myint_int<a> (!p, 1)
        in
          !p := div01_myint_myint<a> (!p, gcd)
        end // end of [if]
    ) (* end of [knd=2/gte] *) else if knd = 1 then let
        val rmd = mod11_myint_myint<a> (!p, gcd)
        val () = // HX: a contradiction may be reached
          if rmd = 0 then (!p := ediv01_myint_myint<a> (!p, gcd)) else (ans2 := ~1)
        val () = myint_free<a> (rmd)
      in
        (*nothing*)
      end (* end of [knd=1/eq] *) else let
        val () = assertloc (false) in ans2 := ~1
      end // end of [_]
  ) : void // end of [val]
  val ((*freed*)) = myint_free<a> (gcd)
  prval pf = array_v_cons {vt} (pf1, pf2)
  prval () = myintvecout_addback {a} (pf | iv)
in
  ans2
end else let
  val ((*freed*)) = myint_free<a> (gcd) in 0(*normal*)
end // end of [if]
//
end // end of [myintvec_normalize]

implement{a}
myintvec_normalize_gte
  (iv, n) = () where {
  val _(*0*) = myintvec_normalize<a> (2(*knd*), iv, n)
} // end of [myintvec_normalize_gte]

implement{a}
myintveclst_normalize_gte
  {n} (ivs, n) = let
//
vtypedef vt = myintvec (a,n)
//
in
//
case+ ivs of
| @list_vt_cons
    (iv, ivs1) => let
    val () = myintvec_normalize_gte<a> (iv, n)
    val () = myintveclst_normalize_gte<a> (ivs1, n)
  in
    fold@ (ivs)
  end // end of [list_vt_cons]
| list_vt_nil () => ()
//
end // end of [myintveclst_normalize_gte]

(* ****** ****** *)

implement{a}
myintvec0_make
  {n} (n) = let
  val n = g1ofg0(i2sz(n))
  val (pfarr, pfgc | p) = $effmask_wrt (array_ptr_alloc<myint(a)> (n))
in
  __cast (pfgc, pfarr | p) where {
    extern castfn
      __cast {v1,v2:view} (_:v1, _:v2 | p: ptr):<> myintvec0(a, n)
  } // end of [__cast]
end // end of [myintvec0_make]

(* ****** ****** *)

implement{a}
myintvec_make
  {n} (n) = let
//
vtypedef x = myint (a)
//
fun
loop
  {n:nat}
  {l:addr} .<n>.
(
  pf: !array_v (x?, l, n) >> array_v (x, l, n) | p: ptr l, n: int n

) : void =
  if n > 0 then let
    prval
    (pf1, pf2) =
      array_v_uncons{x?}(pf)
    // end of [prval]
    val () = !p := myint_make_int<a> (0)
    val () = loop (pf2 | ptr_succ<x> (p), n-1)
    prval () = pf := array_v_cons{x}(pf1, pf2)
  in
    // nothing
  end else let
    prval () = array_v_unnil (pf) in pf := array_v_nil {x} ()
  end // end of [if]
// end of [loop]
//
val iv = myintvec0_make<a> (n)
val (pf | p) = myintvec0_takeout (iv)
val () = loop (pf | p, n)
prval () = myintvecout_addback (pf | iv)
//
in
  iv(* initialized with zeros *)
end // end of [myintvec_make]

(* ****** ****** *)

implement{a}
myintvec_copy
  {n}(iv1, n) = let
//
vtypedef vt = myint (a)
//
prval () = lemma_myintvec_params (iv1)
//
fun loop
  {n:nat} {l1,l2:addr} .<n>. (
  pf1: !array_v (vt, l1, n)
, pf2: !array_v (vt?, l2, n) >> array_v (vt, l2, n)
| p1: ptr l1, p2: ptr l2, n: int n

) : void =
  if n > 0 then let
    prval (pf11, pf12) = array_v_uncons {vt} (pf1)
    prval (pf21, pf22) = array_v_uncons {vt?} (pf2)
    val () = !p2 := myint_copy<a> (!p1)
    val () = loop (pf12, pf22 | ptr_succ<vt> (p1), ptr_succ<vt> (p2), n-1)
    prval () = pf1 := array_v_cons {vt} (pf11, pf12)
    prval () = pf2 := array_v_cons {vt} (pf21, pf22)
  in
    // nothing
  end else let
    prval () = array_v_unnil (pf2) in pf2 := array_v_nil {vt} ()
  end // end of [if]
val iv2 = myintvec0_make<a> (n)
val (pf1 | p1) = myintvec_takeout {a} (iv1)
val (pf2 | p2) = myintvec0_takeout {a} (iv2)
val () = loop (pf1, pf2 | p1, p2, n)
prval () = myintvecout_addback {a} (pf1 | iv1)
prval () = myintvecout_addback {a} (pf2 | iv2)
//
in
  iv2
end // end of [myintvec_copy]

(* ****** ****** *)

implement{a}
myintvec_copy_cff
  {n} (cff, iv1, n) = let
//
vtypedef vt = myint (a)
//
prval () = lemma_myintvec_params (iv1)
//
fun loop
  {n:nat} {l1,l2:addr} .<n>. (
  pf1: !array_v (vt, l1, n)
, pf2: !array_v (vt?, l2, n) >> array_v (vt, l2, n)
| cff: !vt, p1: ptr l1, p2: ptr l2, n: int n

) : void =
  if n > 0 then let
    prval (pf11, pf12) = array_v_uncons {vt} (pf1)
    prval (pf21, pf22) = array_v_uncons {vt?} (pf2)
    val () = !p2 := mul11_myint_myint<a> (cff, !p1)
    val () = loop (pf12, pf22 | cff, ptr_succ<vt> (p1), ptr_succ<vt> (p2), n-1)
    prval () = pf1 := array_v_cons {vt} (pf11, pf12)
    prval () = pf2 := array_v_cons {vt} (pf21, pf22)
  in
    // nothing
  end else let
    prval () = array_v_unnil (pf2) in pf2 := array_v_nil {vt} ()
  end // end of [if]
val iv2 = myintvec0_make<a> (n)
val (pf1 | p1) = myintvec_takeout {a} (iv1)
val (pf2 | p2) = myintvec0_takeout {a} (iv2)
val () = loop (pf1, pf2 | cff, p1, p2, n)
prval () = myintvecout_addback {a} (pf1 | iv1)
prval () = myintvecout_addback {a} (pf2 | iv2)
//
in
  iv2
end // end of [myintvec_copy_cff]

(* ****** ****** *)

implement{a}
myintvec_negate
  {n} (iv, n) = let
//
vtypedef vt = myint (a)
//
prval () = lemma_myintvec_params (iv)
//
fun
loop
  {n:nat}
  {l:addr} .<n>.
(
  pf: !array_v (vt, l, n) | p: ptr l, n: int n

) : void =
  if n > 0 then let
    prval (pf1, pf2) = array_v_uncons {vt} (pf)
    val () = !p := neg_myint<a> (!p)
    val () = loop (pf2 | ptr_succ<vt> (p), n-1)
    prval () = pf := array_v_cons {vt} (pf1, pf2)
  in
    // nothing
  end // end of [if]
//
val
(pf | p) =
myintvec_takeout {a} (iv)
//
val () = loop (pf | p, n)
//
prval () = myintvecout_addback {a} (pf | iv)
//
in
  // nothing
end // end of [myintvec_negate]

(* ****** ****** *)

implement{a}
myintvec_scale
  {n} (cff, iv, n) = let
//
vtypedef vt = myint (a)
//
prval () = lemma_myintvec_params (iv)
//
fun loop
  {n:nat} {l:addr} .<n>. (
  pf: !array_v (vt, l, n)
| cff: !myint(a), p: ptr l, n: int n

) : void =
  if n > 0 then let
    prval (pf1, pf2) = array_v_uncons {vt} (pf)
    val () = !p := mul10_myint_myint<a> (cff, !p)
    val () = loop (pf2 | cff, ptr_succ<vt> (p), n-1)
    prval () = pf := array_v_cons {vt} (pf1, pf2)
  in
    // nothing
  end // end of [if]
val (pf | p) = myintvec_takeout {a} (iv)
val () = loop (pf | cff, p, n)
prval () = myintvecout_addback {a} (pf | iv)
//
in
  // nothing
end // end of [myintvec_negate]

(* ****** ****** *)

implement{a}
myintvec_addby
  {n} (iv1, iv2, n) = let
//
vtypedef vt = myint (a)
//
prval () = lemma_myintvec_params (iv1)
//
fun loop
  {n:nat} {l1,l2:addr} .<n>. (
  pf1: !array_v (vt, l1, n)
, pf2: !array_v (vt, l2, n)
| p1: ptr l1, p2: ptr l2, n: int n

) : void =
  if n > 0 then let
    prval (pf11, pf12) = array_v_uncons {vt} (pf1)
    prval (pf21, pf22) = array_v_uncons {vt} (pf2)
    val () = !p1 := add01_myint_myint<a> (!p1, !p2)
    val () = loop (pf12, pf22 | ptr_succ<vt> (p1), ptr_succ<vt> (p2), n-1)
    prval () = pf1 := array_v_cons {vt} (pf11, pf12)
    prval () = pf2 := array_v_cons {vt} (pf21, pf22)
  in
    // nothing
  end // end of [if]
val (pf1 | p1) = myintvec_takeout {a} (iv1)
val (pf2 | p2) = myintvec_takeout {a} (iv2)
val () = loop (pf1, pf2 | p1, p2, n)
prval () = myintvecout_addback {a} (pf1 | iv1)
prval () = myintvecout_addback {a} (pf2 | iv2)
//
in
  // nothing
end // end of [myintvec_addby]

(* ****** ****** *)

implement{a}
myintvec_subby
  {n} (iv1, iv2, n) = let
//
vtypedef vt = myint (a)
//
prval () = lemma_myintvec_params (iv1)
//
fun loop
  {n:nat} {l1,l2:addr} .<n>. (
  pf1: !array_v (vt, l1, n)
, pf2: !array_v (vt, l2, n)
| p1: ptr l1, p2: ptr l2, n: int n

) : void =
  if n > 0 then let
    prval (pf11, pf12) = array_v_uncons {vt} (pf1)
    prval (pf21, pf22) = array_v_uncons {vt} (pf2)
    val () = !p1 := sub01_myint_myint<a> (!p1, !p2)
    val () = loop (pf12, pf22 | ptr_succ<vt> (p1), ptr_succ<vt> (p2), n-1)
    prval () = pf1 := array_v_cons {vt} (pf11, pf12)
    prval () = pf2 := array_v_cons {vt} (pf21, pf22)
  in
    // nothing
  end // end of [if]
val (pf1 | p1) = myintvec_takeout {a} (iv1)
val (pf2 | p2) = myintvec_takeout {a} (iv2)
val () = loop (pf1, pf2 | p1, p2, n)
prval () = myintvecout_addback {a} (pf1 | iv1)
prval () = myintvecout_addback {a} (pf2 | iv2)  
//
in
  // nothing
end // end of [myintvec_subby]

(* ****** ****** *)

implement{a}
myintvec_addby_cff
  {n} (iv1, cff, iv2, n) = let
//
vtypedef vt = myint (a)
//
prval () = lemma_myintvec_params (iv1)
//
fun loop
  {n:nat} {l1,l2:addr} .<n>. (
  pf1: !array_v (vt, l1, n)
, pf2: !array_v (vt, l2, n)
| p1: ptr l1, cff: !vt, p2: ptr l2, n: int n

) : void =
  if n > 0 then let
    prval (pf11, pf12) = array_v_uncons {vt} (pf1)
    prval (pf21, pf22) = array_v_uncons {vt} (pf2)
    val cx2 = mul11_myint_myint<a> (cff, !p2)
    val () = !p1 := add01_myint_myint<a> (!p1, cx2)
    val () = myint_free<a> (cx2)
    val () = loop (pf12, pf22 | ptr_succ<vt> (p1), cff, ptr_succ<vt> (p2), n-1)
    prval () = pf1 := array_v_cons {vt} (pf11, pf12)
    prval () = pf2 := array_v_cons {vt} (pf21, pf22)
  in
    // nothing
  end // end of [if]
val (pf1 | p1) = myintvec_takeout {a} (iv1)
val (pf2 | p2) = myintvec_takeout {a} (iv2)
val () = loop (pf1, pf2 | p1, cff, p2, n)
prval () = myintvecout_addback {a} (pf1 | iv1)
prval () = myintvecout_addback {a} (pf2 | iv2)  
//
in
  // nothing
end // end of [myintvec_addby_cff]

(* ****** ****** *)

(* end of [pats_lintprgm.dats] *)
