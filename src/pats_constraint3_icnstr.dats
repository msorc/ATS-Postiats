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
// Start Time: February, 2012
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_constraint3_icnstr.dats, see PORTING.md, "Constraint solving (constraint3)")
// The templates here are instantiated by pats_constraint3_solve.dats (it #includes pats_lintprgm_myint.dats
// for one kind of integers and staloads this file).
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)
//
staload
"./pats_errmsg.sats"
staload
_(*anon*) = "./pats_errmsg.dats"
//
implement
prerr_FILENAME<> () = prerr "pats_constraint3_icnstr"
//
(* ****** ****** *)

staload "./pats_intinf.sats"

(* ****** ****** *)
//
staload ERR = "./pats_error.sats"
staload _(*anon*) = "./pats_error.dats"
staload LOC = "./pats_location.sats"
//
(* ****** ****** *)
//
staload "./pats_staexp2.sats"
//
(* ****** ****** *)

staload "./pats_trans3_env.sats"
staload "./pats_lintprgm.sats"
staload "./pats_constraint3.sats"

(* ****** ****** *)

local

staload LM = "libats/SATS/linmap_avltree.sats"
staload _(*anon*) = "libats/DATS/linmap_avltree.dats"

assume s2varindmap_vtype (n:int) = $LM.map (s2var, natLt (n))

implement
$LM.compare_key_key<s2var> (x1, x2) = compare_s2var_s2var (x1, x2)

in // in of [local]

implement
s2varindmap_make
  {n} (s2vs) = let
//
vtypedef vmap = s2varindmap (n)
//
fun loop
  {k,nk:nat | k+nk==n} .<k>. (
  s2vs: !list_vt (s2var, k), nk: int nk, vmap: &vmap
) : int (n) =
  case+ s2vs of
  | @list_vt_cons (s2v, s2vs1) => let
      var res: natLt (n) // uninitialized
      val _(*found*) = $LM.linmap_insert<s2var,natLt(n)> (vmap, s2v, nk, res)
      prval () = opt_clear (res)
      val n = loop (s2vs1, nk+1, vmap)
    in
      n
    end // end of [list_vt_cons]
  | @list_vt_nil () => nk
// end of [loop]
//
var vim
  : vmap = $LM.linmap_make_nil<> ()
val n = loop {n,0} (s2vs, 0, vim)
//
in
  @(vim, n)
end // end of [s2varindmap_make]

implement
s2varindmap_find
  {n} (vim, s2v) = let
  typedef res = natLt (n)
  var x: res? // unintialized
  val found = $LM.linmap_search<s2var,res> (vim, s2v, x)
in
  if found then let
    prval () = opt_unsome {res} (x) in x+1
  end else let
    prval () = opt_unnone {res} (x) in 0(*error*)
  end (* end of [if] *)
end // end of [s2varindmap]

implement
s2varindmap_free {n} (vim) = $LM.linmap_free<s2var,natLt(n)> (vim)

end // end of [local]

(* ****** ****** *)

extern
fun{a:t@ype}
myintvec_addby_const
  {n:pos} (
  iv: !myintvec (a, n), cff: myint(a)
) : void // end of [myintvec_addby_const]
extern
fun{a:t@ype}
myintvec_addby_cffvar
  {n:nat} (
  iv: !myintvec (a, n+1)
, vim: !s2varindmap (n), cff: myint(a), s2v: s2var, err: &int
) : void // end of [myintvec_addby_cffvar]

(* ****** ****** *)

implement{a}
myintvec_addby_const
  (iv, cff) = () where {
  vtypedef x = myint(a)
  val (pf | p) = myintvec_takeout {a} (iv)
  prval (pf1, pf2) = array_v_uncons {x} (pf)
  val () = !p := add01_myint_myint (!p, cff)
  val () = myint_free (cff)
  prval () = pf := array_v_cons {x} (pf1, pf2)
  prval () = myintvecout_addback (pf | iv)
} // end of [myintvec_addby_const]

implement{a}
myintvec_addby_cffvar
  (iv, vim, cff, s2v, err) = let
  val i = s2varindmap_find (vim, s2v)
in
//
if i > 0 then let
  val (pf | p) = myintvec_takeout {a} (iv)
  val (pf1, fpf2 | pi) = array_ptr_takeout<myint(a)> (pf | p, i2sz (i))
  val () = !pi := add01_myint_myint (!pi, cff)
  val () = myint_free (cff)
  prval () = pf := fpf2 (pf1)
  prval () = myintvecout_addback (pf | iv)
in
  (*nothing*)
end else let
  val () = myint_free (cff) in err := err + 1
end // end of [if]
//
end // end of [myintvec_addby_cffvar]

(* ****** ****** *)

implement{a}
s3exp2icnstr
  {n} (loc0, vim, n, s3e0) = let
in
//
case+ s3exp_view (s3e0) of
//
| ~S3Ebool (b) => (
    if b then
      ICveclst (0(*conj*), list_vt_nil) // ic_true
    else
      ICveclst (1(*disj*), list_vt_nil) // ic_false
    // end of [if]
  ) // end of [S3Ebool]
//
| ~S3Ebvar (s2v) => let
    val n1 = n + 1
    val iv = myintvec_make<a> (n1)
    val cff = myint_make_int<a> (1)
    var err: int = 0
    val () = myintvec_addby_cffvar<a> (iv, vim, cff, s2v, err)
    val () = myintvec_add_int (iv, ~1)
  in
    if err > 0 then let
      val () = myintvec_free<a> (iv, n1) in ICerr (loc0, $UN.cast(s3e0))
    end else ICvec (1(*eq*), iv)
  end // end of [S3Ebvar]
//
| ~S3Ebneg (s3e) => let
    val ic = s3exp2icnstr<a> (loc0, vim, n, s3e)
  in
    icnstr_negate (ic)
  end // end of [S3Ebneg]
//
| ~S3Ebadd (s3e1, s3e2) => let
    val ic1 = s3exp2icnstr<a> (loc0, vim, n, s3e1)
    val ic2 = s3exp2icnstr<a> (loc0, vim, n, s3e2)
  in
    ICveclst (1(*disj*), list_vt_pair (ic1, ic2))
  end // end of [S3Ebadd]
| ~S3Ebmul (s3e1, s3e2) => let
    val ic1 = s3exp2icnstr<a> (loc0, vim, n, s3e1)
    val ic2 = s3exp2icnstr<a> (loc0, vim, n, s3e2)
  in
    ICveclst (0(*conj*), list_vt_pair (ic1, ic2))
  end // end of [S3Ebmul]
//
| ~S3Ebeq (s3e1, s3e2) => let
    val n1 = n + 1
    val ic1 = s3exp2icnstr<a> (loc0, vim, n, s3e1)
    val ic2 = s3exp2icnstr<a> (loc0, vim, n, s3e2)
    val ic1_neg = icnstr_negate (icnstr_copy<a> (ic1, n1))
    val ic2_neg = icnstr_negate (icnstr_copy<a> (ic2, n1))
    val ic12 = ICveclst (0(*conj*), list_vt_pair (ic1, ic2))
    val ic12_neg = ICveclst (0(*conj*), list_vt_pair (ic1_neg, ic2_neg))
  in
    ICveclst (1(*disj*), list_vt_pair (ic12, ic12_neg))
  end // end of [S3Ebeq]
| ~S3Ebneq (s3e1, s3e2) => let
    val n1 = n + 1
    val ic1 = s3exp2icnstr<a> (loc0, vim, n, s3e1)
    val ic2 = s3exp2icnstr<a> (loc0, vim, n, s3e2)
    val ic1_neg = icnstr_negate (icnstr_copy<a> (ic1, n1))
    val ic2_neg = icnstr_negate (icnstr_copy<a> (ic2, n1))
    val ic_1_neg2 = ICveclst (0(*conj*), list_vt_pair (ic1, ic2_neg))
    val ic_neg1_2 = ICveclst (0(*conj*), list_vt_pair (ic1_neg, ic2))
  in
    ICveclst (1(*disj*), list_vt_pair (ic_1_neg2, ic_neg1_2))
  end // end of [S3Ebneq]
//
| ~S3Ebineq (knd, s3e) => let
    var err: int = 0
    val iv = s3exp2myintvec<a> (vim, n, s3e, err)
  in
    if err > 0 then let
      val () = myintvec_free<a> (iv, n+1) in ICerr (loc0, $UN.cast(s3e0))
    end else ICvec ($UN.cast{int2} (knd), iv)
  end // end of [S3Ebineq]
//
| ~S3Ebdom (s2v) => ICveclst (0(*conj*), list_vt_nil)
//
| v => let
    val () = s3exp_view_free (v)
    val () =
    prerr_error3_loc (loc0)
    val () = prerr ": this constraint cannot be s3exp2icnstr-handled: s3e0 = "
    val () = prerr_s3exp (s3e0)
    val () = prerr_newline ()
    val () = $ERR.abort<void>()
  in
    ICerr (loc0, $UN.cast(s3e0))
  end // end of [_]
//
end // end of [s3exp2icnstr]

(* ****** ****** *)

local

fun{a:t@ype}
myintvec_addby_s3exp
  {n:nat} (
  iv: !myintvec (a, n+1)
, vim: !s2varindmap (n), s3e0: s3exp, err: &int
) : void = let
in
//
case+ s3exp_view (s3e0) of
| ~S3Evar (s2v) => let
    val cff = myint_make_int<a> (1) in
    myintvec_addby_cffvar (iv, vim, cff, s2v, err)
  end // end of [S3Evar]
//
| ~S3Eunit () => let
    val cff = myint_make_int<a> (1) in myintvec_addby_const (iv, cff)
  end // end of [S3Eunit]
//
| ~S3Eicff (cff, s3e) => (
  case+ s3exp_view (s3e) of
  | ~S3Evar (s2v) => let
      val cff = myint_make_intinf<a> (cff) in
      myintvec_addby_cffvar (iv, vim, cff, s2v, err)
    end // end of [S3Evar]
  | ~S3Eunit () => let
      val cff = myint_make_intinf<a> (cff) in myintvec_addby_const (iv, cff)
    end // end of [S3Evar]
  | v => (s3exp_view_free (v); err := err + 1)
  ) // end of [S3Eicff]
| v => (s3exp_view_free (v); err := err + 1)
//
end // end of [myintvec_addby_s3exp]

fun{a:t@ype}
myintvec_addby_s3explst
  {n:nat} (
  iv: !myintvec (a, n+1)
, vim: !s2varindmap (n), s3es: s3explst, err: &int
) : void =
  if glist_is_cons (s3es) then let
    val () =
      myintvec_addby_s3exp (iv, vim, glist_head<s3exp> (s3es), err)
    // end of [val]
  in
    myintvec_addby_s3explst (iv, vim, glist_tail<s3exp> (s3es), err)
  end else ()
// end of [myintvec_addby_s3explst]

in (* in of [local] *)

implement{a}
s3exp2myintvec{n}
(
  vim, n, s3e0, err
) = let
  val iv = myintvec_make<a> (n+1)
in
//
case+ s3exp_view (s3e0) of
| ~S3Evar (s2v) => iv where {
    val cff = myint_make_int<a> (1)
    val ( ) = myintvec_addby_cffvar (iv, vim, cff, s2v, err)
  } // end of [S3Evar]
//
| ~S3Enull () => iv
| ~S3Eunit () => iv where {
    val cff = myint_make_int<a> (1)
    val ( ) = myintvec_addby_const (iv, cff)
  } // end of [S3Eunit]
//
| ~S3Eicff (cff, s3e) => (
  case+ s3exp_view (s3e) of
  | ~S3Evar (s2v) => iv where {
      val cff = myint_make_intinf<a> (cff)
      val ( ) = myintvec_addby_cffvar (iv, vim, cff, s2v, err)
    } // end of [S3Eunit]
  | ~S3Eunit () => iv where {
      val cff = myint_make_intinf<a> (cff)
      val ( ) = myintvec_addby_const (iv, cff)
    } // end of [S3Eunit]
  | v => (s3exp_view_free (v); err := err + 1; iv)
  ) // end of [S3Eicff]
//
| ~S3Eisum (s3es) => iv where {
    val () = myintvec_addby_s3explst (iv, vim, s3es, err)
  } // end of [S3Eisum]
//
| v => (s3exp_view_free (v); err := err + 1; iv)
//
end // end of [s3exp2myintvec]

end // end of [local]

(* ****** ****** *)

(* end of [pats_constraint3_icnstr.dats] *)
