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
// HX-2026-10: no GC (ATS2 port of src/pats_lintprgm_solve.dats, see PORTING.md
// "Constraint solver (lintprgm)"). Everything but [indexset_*] is a template:
// the user does [staload _ = "./pats_lintprgm_solve.dats"] (and
// [#include "./pats_lintprgm_myint.dats"] for the kind of integers) and links
// this file compiled by itself for the (non-template) [indexset_*].
//
#include "share/atspre_staload.hats"
#include "./pats_assert.hats"
//
(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "./pats_lintprgm.sats"

(* ****** ****** *)

staload _(*anon*) = "./pats_lintprgm.dats"
staload _(*anon*) = "./pats_lintprgm_print.dats"

(* ****** ****** *)

extern
fun{a:t@ype}
myintvec_combine_at
  {n:int} (
  iv_pos: !myintvec (a, n)
, iv_neg: !myintvec (a, n)
, n: int n, i: intBtw (1, n)
) : myintvec (a, n) // end of [myintvec_combine_at]

implement{a}
myintvec_combine_at
  (iv_pos, iv_neg, n, i) = let
  val c_pos = myintvec_get_at<a> (iv_pos, i) // c_pos > 0
  and c_neg = neg_myint<a> (myintvec_get_at<a> (iv_neg, i)) // c_neg > 0
  val iv = myintvec_copy_cff<a> (c_pos, iv_neg, n)
  val () = myintvec_addby_cff<a> (iv, c_neg, iv_pos, n)
  val () = myint_free<a> (c_pos)
  and () = myint_free<a> (c_neg)
in
  iv(*NewlyCreatedVector*)
end // end of [myintvec_combine_at]

(* ****** ****** *)
//
// HX-2012-02:
// ~1/0: CONTRADICTION/UNDECIDED
//
extern
fun{a:t@ype}
myintveclst_split_at
  {n:int} (
  vecs: &myintveclst (a, n) >> myintveclst (a, n), n: int n, i: intBtw (1, n)
) : int(*~1/0*) // end of [myintveclst_split_at]

implement{a}
myintveclst_split_at
  {n} (ivs, n, i) = let
//
stadef iv = myintvec (a, n)
stadef ivs = myintveclst (a, n)
//
fun
auxbeg
(
  ivs: ivs, i: natLt n
, neus: &ivs >> ivs, poss: &ivs >> ivs, negs: &ivs >> ivs
) : void = let
in
//
case+ ivs of
//
| ~list_vt_nil() => ()
//
| @list_vt_cons
    (iv, ivs1) => let
    val sgn =
      myintvec_compare_at<a> (iv, i, 0)
    // end of [val]
    val ivs1_ = ivs1
  in
    if sgn > 0 then let
      val () = ivs1 := poss
      prval () = fold@ (ivs)
      val () = poss := ivs
    in
      auxbeg (ivs1_, i, neus, poss, negs)
    end else if sgn < 0 then let
      val () = ivs1 := negs
      prval () = fold@ (ivs)
      val () = negs := ivs
    in
      auxbeg (ivs1_, i, neus, poss, negs)
    end else let // sgn = 0
      val () = ivs1 := neus
      prval () = fold@ (ivs)
      val () = neus := ivs
    in
      auxbeg (ivs1_, i, neus, poss, negs)
    end // end of [if]
  end (* end of [list_vt_cons] *)
//
end // end of [auxbeg]
//
fun
auxcomb
(
//
// ~1/0 means contradiction/undecided
//
  n: int n, i: intBtw (1, n)
, neus: &ivs >> ivs, poss: &ivs >> ivs, neg: !iv
) : int(*~1/0*) = let
in
//
case+ poss of
//
| list_vt_nil () => 0(*UNDECIDED*)
//
| @list_vt_cons
    (pos, poss1) => let
    val iv_new =
      myintvec_combine_at<a> (pos, neg, n, i)
    // end of [val]
    val sgn = myintvec_inspect_gte<a> (iv_new, n)
    val () = (
      if sgn != 0 then
        myintvec_free<a> (iv_new, n) else let
        val () = myintvec_normalize_gte<a> (iv_new, n)
      in
        neus := list_vt_cons (iv_new, neus)
      end // end of [if]
    ) : void // end of [val]
    in
      if (sgn >= 0) then let
        val ans = auxcomb (n, i, neus, poss1, neg)
      in
        ans
      end else ~1(*CONTRADITION*)
      // end of [if]
    end (* end of [list_vt_cons] *)
//
end // end of [auxcomb]
//
// HX: [~1] is returned if contradiction is reached
//
fun
auxcomblst
(
  n: int n, i: intBtw (1, n)
, neus: &ivs >> ivs, poss: &ivs >> ivs, negs: ivs
) : int(*~1/0*) = let
in
//
case+ negs of
| ~list_vt_cons
    (neg, negs) => let
    val ans =
      auxcomb (n, i, neus, poss, neg)
    // end of [val]
    val () = myintvec_free<a> (neg, n)
  in
    if ans >= 0 then
      auxcomblst (n, i, neus, poss, negs)
    else let
      val () = myintveclst_free<a> (negs, n) in ~1(*CONTRADICTION*)
    end // end of [if]
  end (* list_vt_cons *)
| ~list_vt_nil () => 0(*UNDECIDED*)
//
end // end of [auxcomblst]
//
var neus: ivs = list_vt_nil ()
var poss: ivs = list_vt_nil ()
and negs: ivs = list_vt_nil ()
//
val () =
  auxbeg (ivs, i, neus, poss, negs)
val ans =
  auxcomblst (n, i, neus, poss, negs)
val () = myintveclst_free<a> (poss, n)
val () = ivs := neus
//
in
  ans(*~1/0*)
end // end of [myintveclst_split_at]

(* ****** ****** *)

extern
fun
{a:t@ype}
myintvec_get_index_of_absmincff
  {n:pos}
  (iv: !myintvec (a, n), n: int n): intBtw (1, n)
// end of [myintvec_get_index_of_absmincff]
implement
{a}(*tmp*)
myintvec_get_index_of_absmincff
  {n}(iv, n) = let
//
vtypedef x = myint(a)
//
fun loop
  {k:nat | k <= n}{l:addr} .<k>. (
  pf: !array_v (x, l, k)
| p: ptr l, n: int n, k: int k
, isz: bool, ind: &natLt (n) >> _, cff: &x >> _
) : void = let
in
  if k > 0 then let
    prval (pf1, pf2) = array_v_uncons {x} (pf)
    val sgn = compare_myint_int<a> (!p, 0)
    val () = (
      if sgn > 0 then (
        if (
          isz || lt_myint_myint<a> (!p, cff)
        ) then let
          val () = ind := n - k
          val () = myint_free<a> (cff)
        in
          cff := myint_copy<a> (!p)
        end else (
          // nothing
        ) // end of [if]
      ) // end of [if]
    ) : void // end of [val]
    val () = (
      if sgn < 0 then let
        val cff1 = neg1_myint<a> (!p)
      in
        if (
          isz || lt_myint_myint<a> (cff1, cff)
        ) then let
          val () = ind := n - k
          val () = myint_free<a> (cff)
        in
          cff := cff1
        end else (
          myint_free<a> (cff1)
        ) // end of [if]
      end // end of [if]
    ) : void // end of [val]
  in
    if sgn = 0 then let
      val () = loop (pf2 | ptr_succ<x> (p), n, k-1, isz, ind, cff)
    in
      pf := array_v_cons {x} (pf1, pf2)
    end else if gt_myint_int<a> (cff, 1) then let
      val () = loop (pf2 | ptr_succ<x> (p), n, k-1, false, ind, cff)
    in
      pf := array_v_cons {x} (pf1, pf2)
    end else (
      pf := array_v_cons {x} (pf1, pf2)
    ) // end of [if]
  end // end of [if]
end // end of [loop]
//
var ind: natLt (n) = 0
var cff: myint (a) = myint_make_int<a> (0)
val (pf | p) = myintvec_takeout (iv)
prval (pf1, pf2) = array_v_uncons {x} (pf)
val () = loop (pf2 | ptr_succ<x> (p), n, n-1, true(*isz*), ind, cff)
prval () = pf := array_v_cons {x} (pf1, pf2)
prval () = myintvecout_addback (pf | iv)
val () = myint_free<a> (cff)
//
val () = assertloc (ind > 0)
//
in
  ind
end // end of [myintvec_get_index_of_absmincff]

(* ****** ****** *)
//
// HX-2026-10: [indexset] is a set of indices: no GC, so no persistent
// tree; the word [w] is either [(mask << 1) | 1] where bit [k] of [mask]
// tells that [k] is in the set ([1 <= k <= 62], no allocation) or the
// address of a block of the global arena: [nwords, word0, word1, ...].
//
assume indexset (n:int) = ptr
//
fn indexset_w2p (w: ulint):<> ptr = $UN.cast{ptr}(w)
fn indexset_p2w (p: ptr):<> ulint = $UN.cast{ulint}(p)
//
fn indexset_isimm (w: ulint):<> bool = ((w land 1UL) = 1UL)
//
fn indexset_get
  (p: ptr, j: int):<> ulint = $UN.ptr0_get<ulint> (ptr0_add_guint<ulint> (p, $UN.cast{size_t}(j)))
fn indexset_set
  (p: ptr, j: int, w: ulint):<!wrt> void = $UN.ptr0_set<ulint> (ptr0_add_guint<ulint> (p, $UN.cast{size_t}(j)), w)
//
implement
indexset_nil () = indexset_w2p (1UL)
//
implement
indexset_is_member
  (xs, x) = let
  val w = indexset_p2w ($UN.cast{ptr}(xs))
in
  if indexset_isimm (w)
    then (
      if x <= 62 then (((w >> (x+1)) land 1UL) = 1UL) else false
    ) else let
      val p = indexset_w2p (w)
      val nw = $UN.cast{int}(indexset_get (p, 0))
      val j = $UN.cast{int}(x / 64)
    in
      if j >= nw then false else (((indexset_get (p, j+1) >> g1int_nmod (x, 64)) land 1UL) = 1UL)
    end // end of [if]
end // end of [indexset_is_member]
//
implement
indexset_add
  {n} (xs, x) = $effmask_all let
  val w = indexset_p2w ($UN.cast{ptr}(xs))
in
//
if indexset_is_member{n} (xs, x) then xs
else if indexset_isimm (w) && x <= 62 then
  $UN.cast{indexset(n)}(indexset_w2p (w lor (1UL << (x+1))))
else let
  val nw0 =
    (if indexset_isimm (w) then 1 else $UN.cast{int}(indexset_get (indexset_w2p (w), 0))): int
  val nw1 = $UN.cast{int}(x / 64 + 1)
  val nw = (if nw1 > nw0 then nw1 else nw0): int
  val p = the_garena_alloc ($UN.cast{size_t}(8*(nw+1)))
  val () = indexset_set (p, 0, $UN.cast{ulint}(nw))
//
  fun clear (p: ptr, j: int, nw: int): void =
    if j <= nw then (indexset_set (p, j, 0UL); clear (p, j+1, nw))
  val () = clear (p, 1, nw)
//
  fun copy (p: ptr, q: ptr, j: int, nw0: int): void =
    if j < nw0 then (indexset_set (p, j+1, indexset_get (q, j+1)); copy (p, q, j+1, nw0))
  val () = (
    if indexset_isimm (w) then let
      // the bits [1..62] of the mask, as bits [1..62] of the word 0
      val mask = w >> 1
    in
      indexset_set (p, 1, mask)
    end else copy (p, indexset_w2p (w), 0, nw0)
  ) : void
  val j = $UN.cast{int}(x / 64)
  val () = indexset_set (p, j+1, indexset_get (p, j+1) lor (1UL << g1int_nmod (x, 64)))
in
  $UN.cast{indexset(n)}(p)
end // end of [if]
//
end // end of [indexset_add]
//
(* ****** ****** *)

(* HX: the indices of [iset] first, then the others, both in ascending order *)
vtypedef indexlst (n:int) = List0_vt (index (n))
//
extern
fun
indexlst_make
  {n:pos}
(
  xs: indexset (n), n: int n
) : indexlst (n) // end-of-fun
//
fn indexlst_free {n:pos} (xs: indexlst (n)): void = list_vt_free (xs)

implement
indexlst_make
  {n}(iset, n) = let
//
vtypedef res = List0_vt (index (n))
//
fun
loop
{k:nat | k < n} .<k>.
(
  iset: indexset (n), k: int k, res1: res, res2: res
) : res =
(
if
k > 0
then let
  val
  ismem =
  indexset_is_member{n}(iset, k)
in
  if ismem
    then loop(iset, k-1, list_vt_cons(k, res1), res2)
    else loop(iset, k-1, res1, list_vt_cons(k, res2))
  // end of [if]
end // end of [then]
else list_vt_append(res1, res2)
//
) (* end of [loop] *)
in
  loop(iset, n-1, list_vt_nil, list_vt_nil)
end // end of [indexlst_make]

fn indexlst_choose
  {n:pos}
  (xs: &indexlst (n) >> indexlst (n)): natLt(n) =
(
  case+ xs of
  | ~list_vt_cons
      (x, xs1) => (xs := xs1; x)
  |  list_vt_nil() => 0 // HX: error indication
) (* end of [indexlst_choose] *)

(* ****** ****** *)
//
extern
fun
{a:t@ype}
myintveclst_solve
  {n:pos}
(
  iset: indexset(n), ivs: myintveclst(a, n), n: int(n)
) : Ans2(*~1/0*) // end of [myintveclst_solve]
implement
{a}(*tmp*)
myintveclst_solve
  {n}(iset, ivs, n) = let
(*
val () = begin
  print "myintveclst_solve: ivs =\n"; print_myintveclst (ivs, n); print_newline ();
end // end of [val]
*)
//
vtypedef ivs = myintveclst (a, n)
//
fun solve (
  ivs: &ivs >> ivs, ilst: &indexlst (n) >> indexlst (n), n: int n
) : Ans2(*~1/0*) = let
//
val i = indexlst_choose{n} (ilst)
in
  if i > 0 then let
    val ans =
      myintveclst_split_at<a> (ivs, n, i)
    // end of [val]
  in
    if ans >= 0 then solve (ivs, ilst, n) else ~1(*solved*)
  end else 0(*UNDECIDED*) // end of [if]
end // end of [solve]
//
var ivs: ivs = ivs
var ilst = indexlst_make (iset, n)
val ans = solve (ivs, ilst, n)
val () = myintveclst_free<a> (ivs, n)
val () = indexlst_free{n} (ilst)
//
in
  ans
end // end of [myintveclst_solve]

(* ****** ****** *)

(*
**
** HX-2012-02:
** iveq refers to an equality of the form:
** A[0] + A[1]*x1 + A[2]*x2 + ... + A[n]*xn = 0
**
*)

extern
fun{a:t@ype}
myintvec_elimeq_at {n:int} (
  iv: !myintvec (a, n), iveq: !myintvec (a, n), n: int n, i: intBtw (1, n)
) : void // end of [myintvec_elimeq_at]
extern
fun{a:t@ype}
myintveclst_elimeq_at {n:int} (
  ivs: !myintveclst (a, n), iveq: !myintvec (a, n), n: int n, i: intBtw (1, n)
) : void // end of [myintveclst_elimeq_at]

(* ****** ****** *)

implement{a}
myintvec_elimeq_at
  (iv, iveq, n, i) = let
//
val sgn = myintvec_compare_at<a> (iv, i, 0)
//
in
//
if sgn != 0 then let
  var c = myintvec_get_at<a> (iv, i)
  var ceq = myintvec_get_at<a> (iveq, i)
  val sgn = compare_myint_int<a> (ceq, 0)
in
  if sgn >= 0 then let
    val () = c := neg_myint<a> (c)
    val () = myintvec_scale<a> (ceq, iv, n)
    val () = myintvec_addby_cff<a> (iv, c, iveq, n)
    val () = myint_free<a> (c) and () = myint_free<a> (ceq)
  in
    (*nothing*)
  end else let
    val () = ceq := neg_myint<a> (ceq)
    val () = myintvec_scale<a> (ceq, iv, n)
    val () = myintvec_addby_cff<a> (iv, c, iveq, n)
    val () = myint_free<a> (c) and () = myint_free<a> (ceq)
  in
    (*nothing*)
  end (* end of [if] *)
end else () // end of [if]
//
end // end of [myintvec_elimeq_at]

implement{a}
myintveclst_elimeq_at
  (ivs, iveq, n, i) = (
  case+ ivs of
  | @list_vt_cons
      (iv, ivs1) => let
      val () = myintvec_elimeq_at<a> (iv, iveq, n, i)
      val () = myintveclst_elimeq_at<a> (ivs1, iveq, n, i)
    in
      ()
    end // end of [list_vt_cons]
  | list_vt_nil () => ()
) // end of [myintveclst_elimeq_at]

(* ****** ****** *)
//
datavtype
myivlst(a:t@ype, int) =
  | {n:int}
    MYIVLSTnil(a, n) of ()
  | {n:int}
    MYIVLSTcons(a, n) of (
      int(*stamp*), myintvec (a, n), myivlst (a, n)
    ) // end of [MYIVLSTcons]
  | {n:int}
    MYIVLSTmark(a, n) of myivlst (a, n)
// end of [myivlst]
//
(* ****** ****** *)
//
extern
fun
{a:t@ype}
myivlst_free {n:int}
  (i1vs: myivlst (a, n), n: int n): void
// end of [myivlst_free]
//
implement
{a}(*tmp*)
myivlst_free
  (i1vs, n) =
(
  case+ i1vs of
  | ~MYIVLSTnil
      ((*void*)) => ()
  | ~MYIVLSTcons
      (_, iv, i1vs) => let
      val () = myintvec_free<a> (iv, n) in myivlst_free<a> (i1vs, n)
    end // end of [MYIVLSTcons]
  | ~MYIVLSTmark (i1vs) => myivlst_free<a> (i1vs, n)
) (* end of [myivlst_free] *)
//
(* ****** ****** *)

extern
fun
{a:t@ype}
myivlst_mark{n:int}
  (i1vs: myivlst (a, n)): myivlst(a, n)
// end of [myivlst_mark]
implement
{a}(*tmp*)
myivlst_mark{n}(i1vs) = MYIVLSTmark(i1vs)

(* ****** ****** *)

extern
fun{a:t@ype}
myivlst_unmark{n:int}
  (i1vs: myivlst(a, n), n: int n): myivlst(a, n)
// end of [myivlst_unmark]
implement{a}
myivlst_unmark
  (i1vs, n) =
(
//
case+ i1vs of
| ~MYIVLSTnil
    ((*void*)) => MYIVLSTnil()
| ~MYIVLSTcons
    (_, iv, i1vs) => let
    val () = myintvec_free<a> (iv, n) in myivlst_unmark<a> (i1vs, n)
  end // end of [MYIVEQLSTcons]
| ~MYIVLSTmark(i1vs) => (i1vs)
//
) (* end of [myivlst_unmark] *)

(* ****** ****** *)
//
(*
** HX-2012-02:
** this is a poorman's doubly-linked list
** I am somewhat fond of this design. Maybe it should
** be put into libats for general use.
*)
//
datavtype
myiveqlst
(
  a:t@ype, int
) = // myiveqlst
  | {n:int}
    MYIVEQLSTnil(a, n) of ()
  | {n:int}
    {i:int | 0 < i; i < n}
    MYIVEQLSTcons(a, n) of (
      int(*stamp*)
    , myintvec (a, n), int i(*index*)
    , ptr(*prev*)
    , myiveqlst (a, n)
    ) // end of [MYIVEQLSTcons]
  | {n:int}
    MYIVEQLSTmark(a, n) of (ptr(*prev*), myiveqlst (a, n))
// end of [myiveqlst]
//
(* ****** ****** *)

extern
fun
{a:t@ype}
myiveqlst_free {n:int}
  (i1vs: myiveqlst (a, n), n: int n): void
// end of [myiveqlst_free]
implement
{a}(*tmp*)
myiveqlst_free
  (i1vs, n) =
(
//
case+ i1vs of
//
| ~MYIVEQLSTnil() => ()
//
| ~MYIVEQLSTcons
    (_, iv, _, _, i1vs) =>
  let
    val () =
    myintvec_free<a> (iv, n) in myiveqlst_free<a> (i1vs, n)
  end // end of [MYIVEQLSTcons]
//
| ~MYIVEQLSTmark(_, i1vs) => myiveqlst_free<a> (i1vs, n)
//
) (* end of [myiveqlst_free] *)

(* ****** ****** *)

extern
castfn myiveqlst2ptr
  {a:t@ype}{n:int} (x: !myiveqlst (a, n)): ptr
// end of [myiveqlst2ptr]

(* ****** ****** *)
//
// HX-2026-10: [prev] of the head is set to [p] (the head must not be a [nil])
//
fun{a:t@ype}
myiveqlst_set_prev
  {n:int}
(
  x: !myiveqlst (a, n), p: ptr
) : void = (
//
case+ x of
| MYIVEQLSTnil
    ((*void*)) => ()
| @MYIVEQLSTcons
    (_, _, _, prev, _) => prev := p
| @MYIVEQLSTmark (prev, _) => prev := p
//
) (* end of [myiveqlst_set_prev] *)

(* ****** ****** *)
//
extern
fun
{a:t@ype}
myiveqlst_cons
  {n:int}
(
  stamp: int, i: intBtw(1, n)
, i1veq: myintvec(a, n), i1veqs: myiveqlst(a, n)
) : myiveqlst (a, n) // end-of-function
//
implement
{a}(*tmp*)
myiveqlst_cons
(
  stamp, i, i1veq, i1veqs
) = res where
{
//
  val res =
  MYIVEQLSTcons
    (stamp, i1veq, i, the_null_ptr(*prev*), i1veqs)
  // end of [val]
//
  val resp = myiveqlst2ptr(res)
  val () = (
    case+ res of
    | @MYIVEQLSTcons (_, _, _, _, next) =>
        (myiveqlst_set_prev<a> (next, resp))
    | MYIVEQLSTnil () => ()
    | MYIVEQLSTmark _ => ()
  ) : void
//
} (* end of [myiveqlst_cons] *)
//
(* ****** ****** *)
//
extern
fun
{a:t@ype}
myiveqlst_mark
  {n:int}
  (i1veqs: myiveqlst(a, n)): myiveqlst (a, n)
//
implement
{a}(*tmp*)
myiveqlst_mark
  {n}(i1veqs) = res where
{
//
val res =
MYIVEQLSTmark(the_null_ptr(*prev*), i1veqs)
//
val resp = myiveqlst2ptr(res)
val () = (
  case+ res of
  | @MYIVEQLSTmark (_, next) =>
      (myiveqlst_set_prev<a> (next, resp))
  | MYIVEQLSTnil () => ()
  | MYIVEQLSTcons _ => ()
) : void
//
} (* end of [myiveqlst_mark] *)

(* ****** ****** *)
//
extern
fun
{a:t@ype}
myiveqlst_unmark
  {n:int}
  (i1veqs: myiveqlst(a, n), n: int n): myiveqlst(a, n)
// end of [myiveqlst_unmark]
implement{a}
myiveqlst_unmark
  (i1veqs, n) =
(
//
case+ i1veqs of
| ~MYIVEQLSTnil
    ((*void*)) => MYIVEQLSTnil()
| ~MYIVEQLSTcons
    (_, iv, _, _, i1veqs) => let
    val () = myintvec_free<a> (iv, n) in myiveqlst_unmark<a> (i1veqs, n)
  end // end of [MYIVEQLSTcons]
| ~MYIVEQLSTmark(_, i1veqs) => i1veqs
//
) (* end of [myiveqlst_unmark] *)
//
(* ****** ****** *)

extern
fun
{a:t@ype}
myiveqlst_get_last
  {n:int}(xs: !myiveqlst (a, n)): ptr
// end of [myiveqlst_get_last]

implement
{a}(*tmp*)
myiveqlst_get_last
  {n}(xs) = let
//
vtypedef vt = myiveqlst (a, n)
//
fun loop
  (prev: ptr, xs: !vt): ptr = let
  val pcur = $UN.castvwtp1{ptr}{vt}(xs)
in
//
case+ xs of
| MYIVEQLSTnil
    ((*void*)) => prev
  // end of [MYIVEQLSTnil]
| @MYIVEQLSTcons
    (_, _, _, _, xs1) => let
    val res = loop (pcur, xs1) in res
  end // end of [MYIVEQLSTcons]
| @MYIVEQLSTmark(_, xs1) => let
    val res = loop (pcur, xs1) in res
  end // end of [MYIVEQLSTmark]
//
end // end of [loop]
//
in
  loop (the_null_ptr, xs)
end // end of [myiveqlst_get_last]

(* ****** ****** *)
//
extern
fun
{a:t@ype}
myintvec_elimeqlst
  {n:int}
(
  stamp0: int
, iv: !myintvec (a, n), i1veqs: !myiveqlst (a, n), n: int (n)
) : void // end of [myintvec_elimeqlst]
//
(*
** HX-2026-10: not in a [local]: a template that is used by the instance of
** another template must not refer to a name that is local to this file
*)
fun{a:t@ype}
myintvec_elimeqlst_rev {n:int} (
  stamp0: int
, iv: !myintvec (a, n), i1veqs: !myiveqlst (a, n), n: int (n)
) : void = let
//
val prev = (
case+ i1veqs of
//
| MYIVEQLSTnil() => the_null_ptr
//
| @MYIVEQLSTcons
  (
    stamp, i1veq, i, prev, _
  ) => prev1 where
  {
    val prev1 = prev
    val () = if
      stamp0 <= stamp then myintvec_elimeq_at<a> (iv, i1veq, n, i)
    // end of [val]
  } (* end of [MYIVEQLSTcons] *)
| @MYIVEQLSTmark
    (prev, _) => prev1 where
  {
    val prev1 = prev
  } (* end of [MYIVEQLSTmark] *)
//
) : ptr // end of [val]
//
in
//
if ptr_isnot_null (prev) then {
  val _prev = $UN.castvwtp0{myiveqlst(a, n)}(prev)
  val () = myintvec_elimeqlst_rev<a> (stamp0, iv, _prev, n)
  val _ = $UN.castvwtp0{ptr}(_prev)
} (* end of [if] *)
//
end // end of [myintvec_elimeqlst_rev]

implement{a}
myintvec_elimeqlst
  {n} (stamp0, iv, i1veqs, n) = let
  val last = myiveqlst_get_last<a> (i1veqs)
in
//
if ptr_isnot_null (last) then {
  val i1veqs = $UN.castvwtp0{myiveqlst(a, n)}(last)
  val () = myintvec_elimeqlst_rev<a> (stamp0, iv, i1veqs, n)
  val _ = $UN.castvwtp0{ptr}(i1veqs)
} (* end of [if] *)
//
end // end of [myintvec_elimeqlst]

(* ****** ****** *)

extern
fun{a:t@ype}
myivlst_elimeqlst {n:nat} (
  i1vs: !myivlst (a, n), i1veqs: !myiveqlst (a, n), n: int n
) : myintveclst (a, n) // end of [myivlst_elimeqlst]

implement{a}
myivlst_elimeqlst
  {n} (i1vs, i1veqs, n) = let
//
viewtypedef res = myintveclst (a, n)
//
// HX: [acc] is the reversed result
//
fun loop (
  i1vs: !myivlst (a, n)
, i1veqs: !myiveqlst (a, n)
, n: int n
, acc: res
) : res = let
in
//
case+ i1vs of
| MYIVLSTnil
    ((*void*)) => acc
| @MYIVLSTcons
    (stamp, iv, i1vs1) => let
    val iv_new = myintvec_copy<a> (iv, n)
    val () = myintvec_elimeqlst<a> (stamp, iv_new, i1veqs, n)
    val res = loop (i1vs1, i1veqs, n, list_vt_cons (iv_new, acc))
  in
    res
  end // end of [MYIVLSTcons]
| @MYIVLSTmark
    (i1vs1) => let
    val res = loop (i1vs1, i1veqs, n, acc)
  in
    res
  end // end of [MYIVLSTmark]
//
end // end of [loop]
//
in
  list_vt_reverse (loop (i1vs, i1veqs, n, list_vt_nil ()))
end // end of [myivlst_elimeqlst]

(* ****** ****** *)

extern
fun{
a:t@ype
} auxmain {n:pos}{s:int} (
  stamp: int
, iset: indexset (n)
, i1vs: &myivlst (a, n)
, i1veqs: &myiveqlst (a, n)
, n: int n
, ics: &list_vt(icnstr (a, n), s) >> list_vt(icnstr (a, n), s)
) : Ans2 (*~1/0*)

extern
fun{
a:t@ype
} auxmain_conj
  {n:pos}{s:int} (
  stamp: int
, iset: indexset (n)
, i1vs: &myivlst (a, n)
, i1veqs: &myiveqlst (a, n)
, n: int n
, ics: &list_vt (icnstr (a, n), s) >> list_vt (icnstr (a, n), s)
, ics1: &icnstrlst (a, n) >> icnstrlst (a, n)
) : Ans2 (*~1/0*)
extern
fun{
a:t@ype
} auxmain_disj
  {n:pos}{s:int} (
  stamp: int
, iset: indexset (n)
, i1vs: &myivlst (a, n)
, i1veqs: &myiveqlst (a, n)
, n: int n
, ics: &list_vt (icnstr (a, n), s) >> list_vt (icnstr (a, n), s)
, ics1: &icnstrlst (a, n) >> icnstrlst (a, n)
, rics1: icnstrlst (a, n)
) : Ans2 (*~1/0*)

(* ****** ****** *)

fun{
a:t@ype
} auxlt {n:pos} (
  stamp: int
, i1vs: &myivlst (a, n)
, i1veqs: &myiveqlst (a, n)
, iv: myintvec (a, n)
, n: int n
) : Ans3 (*~1/0/1*) = let
val () =
  myintvec_elimeqlst<a> (0(*stamp*), iv, i1veqs, n)
val sgn = myintvec_inspect_lt<a> (iv, n)
//
in
//
if sgn = 0 then let
  val () = myintvec_negate<a> (iv, n)
  val () = myintvec_add_int<a> (iv, ~1)
  val () = myintvec_normalize_gte<a> (iv, n)
  val () = i1vs := MYIVLSTcons (stamp, iv, i1vs)
in
  0(*undecided*)
end else let
  val () = myintvec_free<a> (iv, n) in sgn
end // end of [if]
//
end // end of [auxlt]

fun{
a:t@ype
} auxgte {n:pos} (
  stamp: int
, i1vs: &myivlst (a, n)
, i1veqs: &myiveqlst (a, n)
, iv: myintvec (a, n)
, n: int n
) : Ans3 (*~1/0/1*) = let
val () =
  myintvec_elimeqlst<a> (0(*stamp*), iv, i1veqs, n)
val sgn = myintvec_inspect_gte<a> (iv, n)
//
in
//
if sgn = 0 then let
  val () = myintvec_normalize_gte<a> (iv, n)
  val () = i1vs := MYIVLSTcons (stamp, iv, i1vs)
in
  0(*undecided*)
end else let
  val () = myintvec_free<a> (iv, n) in sgn
end // end of [if]
//
end // end of [auxgte]

fun{
a:t@ype
} auxeq {n:pos} (
  stamp: int
, i1vs: &myivlst (a, n)
, i1veqs: &myiveqlst (a, n)
, iv: myintvec (a, n)
, n: int n
) : Ans3 (*~1/0/1*) = let
val () =
  myintvec_elimeqlst<a> (0(*stamp*), iv, i1veqs, n)
val sgn = myintvec_inspect_eq<a> (iv, n)
//
in
//
if sgn = 0 then let
  val i =
    myintvec_get_index_of_absmincff<a> (iv, n)
  val () = i1veqs :=
    myiveqlst_cons<a> (stamp, i, iv, i1veqs)
  // end of [val]
in
  0(*undecided*)
end else let
  val () = myintvec_free<a> (iv, n) in sgn(*contra/tauto*)
end // end of [if]
//
end // end of [auxeq]

fun{
a:t@ype
} auxcont
  {n:pos}{s:int} (
  stamp: int
, iset: indexset (n)
, i1vs: &myivlst (a, n)
, i1veqs: &myiveqlst (a, n)
, n: int n
, ics: &list_vt(icnstr (a, n), s) >> list_vt(icnstr (a, n), s)
, sgn: int // ~1/0/1
) : Ans2(*~1/0*) = let
in
//
if sgn < 0 then ~1(*solved*)
else if sgn > 0 then
    auxmain<a> (stamp, iset, i1vs, i1veqs, n, ics)
else let // sgn = 0
    var ivs = myivlst_elimeqlst<a> (i1vs, i1veqs, n)
    var ans2: Ans2 = myintveclst_inspect_gte<a> (ivs, n)
    val () = (
      if ans2 >= 0 then let
        val () = myintveclst_normalize_gte<a> (ivs, n)
        val () = ans2 := myintveclst_solve<a> (iset, ivs, n)
      in
        // nothing
      end else let
        val () = myintveclst_free<a> (ivs, n) in (*nothing*)
      end // end of [if]
    ) : void // end of [if]
    val () = (
      if ans2 >= 0 then (
        ans2 := auxmain<a> (stamp+1, iset, i1vs, i1veqs, n, ics)
      ) // end of [if]
    ) : void // end of [val]
  in
    ans2
  end // end of [let] // end of [_(sgn=0)]
//
end // end of [auxcont]

fun{a:t@ype}
auxneq {n:pos} (
  stamp: int
, i1vs: &myivlst (a, n)
, i1veqs: &myiveqlst (a, n)
, iv: myintvec (a, n)
, n: int n
, sgn: &int? >> int
) : icnstr (a, n) = let
//
val () = // HX: stamp = 0
  myintvec_elimeqlst<a> (0, iv, i1veqs, n)
val () = sgn := myintvec_inspect_neq<a> (iv, n)
//
in
//
if sgn = 0 then let
  val iv1_new = myintvec_copy<a> (iv, n)
  val () = myintvec_add_int<a> (iv1_new, ~1)
  val cff = myint_make_int<a> (~1)
  val iv2_new = myintvec_copy_cff<a> (cff, iv, n)
  val () = myint_free<a> (cff)
  val () = myintvec_add_int<a> (iv2_new, ~1)
//
  val () = myintvec_free<a> (iv, n)
//
  val knd = (2(*gte*))
  val () = myintvec_normalize_gte<a> (iv1_new, n)
  val () = myintvec_normalize_gte<a> (iv2_new, n)
  val ic1 = ICvec (knd, iv1_new)
  val ic2 = ICvec (knd, iv2_new)
in
  ICveclst (1(*disj*), list_vt_pair (ic1, ic2))
end else let
//
// sgn=~1/1:contra/tauto
//
  val () = myintvec_free<a> (iv, n)
  val knd =
    (if sgn > 0 then 0(*conj*) else 1(*disj*)): nat2
  // end of [val]
in
  ICveclst (knd, list_vt_nil)
end // end of [if]
//
end // end of [auxneq]

implement{a}
auxmain {n}{s} (
  stamp, iset, i1vs, i1veqs, n, ics
) = let
//
viewtypedef ic = icnstr (a, n)
//
in
//
case+ ics of
| @list_vt_cons
    (ic, ics1) => (
//
case+ ic of
| @ICvec (knd, iv) => let
    val knd1 = knd
  in
  if knd1 = ~2(*lt*) then let
      val iv_new = myintvec_copy<a> (iv, n)
      prval () = fold@ (ic)
      val ans3 = auxlt<a> (stamp, i1vs, i1veqs, iv_new, n)
      val ans2 = auxcont<a> (stamp, iset, i1vs, i1veqs, n, ics1, ans3)
    in
      ans2
    end // end of [knd=~2]
  else if knd1 = 2(*gte*) then let
      val iv_new = myintvec_copy<a> (iv, n)
      prval () = fold@ (ic)
      val ans3 = auxgte<a> (stamp, i1vs, i1veqs, iv_new, n)
      val ans2 = auxcont<a> (stamp, iset, i1vs, i1veqs, n, ics1, ans3)
    in
      ans2
    end // end of [knd = 2]
  else if knd1 = 1(*eq*) then let
      val iv_new = myintvec_copy<a> (iv, n)
      prval () = fold@ (ic)
      val ans3 = auxeq<a> (stamp, i1vs, i1veqs, iv_new, n)
      val ans2 = auxcont<a> (stamp, iset, i1vs, i1veqs, n, ics1, ans3)
    in
      ans2
    end // end of [knd = 1]
  else (* knd = ~1(neq) *) let
      var ans3: int // uninitized
      val iv_ = iv
      val () = free@ {a}{0} (ic)
      val ic_new =
        auxneq<a> (stamp, i1vs, i1veqs, iv_, n, ans3)
      val () =
        ic := ic_new // HX: [ic] is equivalent to [ic_new]
      prval () =
        fold@ (ics) // HX: trying again after folding
      // end of [prval]
    in
      if ans3 >= 0 then
        auxmain<a> (stamp, iset, i1vs, i1veqs, n, ics) else ~1(*solved*)
      // end of [if]
    end // end of [knd = ~1]
  end // end of [ICvec]
| @ICveclst
    (knd, ics2) => let
    val knd1 = knd
  in
  if knd1 = 0 then let
      val ans2 =
        auxmain_conj<a> (
        stamp, iset, i1vs, i1veqs, n, ics1, ics2
      ) // end of [val]
      prval () = fold@ (ic)
    in
      ans2
    end // end of [conj]
  else (* knd = 1 *) let
      val ans2 =
        auxmain_disj<a> (
        stamp, iset, i1vs, i1veqs, n, ics1, ics2, list_vt_nil
      ) // end of [val]
      prval () = fold@ (ic)
    in
      ans2
    end // end of [disj]
  end // end of [ICveclst]
| @ICerr (loc, s3e) => let
    prval () = fold@ (ic) in 0(*undecided*)
  end // end of [ICerr]
//
) (* end of [list_vt_cons] *)
| list_vt_nil () => 0(*unsolved*)
//
end // end of [auxmain]

implement{a}
auxmain_conj {n}{s} (
  stamp, iset, i1vs, i1veqs, n, ics, ics1
) = let
//
  viewtypedef ic = icnstr (a, n)
  prval () = lemma_list_vt_param (ics)
  prval () = lemma_list_vt_param (ics1)
//
  val s1 = list_vt_length (ics1)
  val () = ics := list_vt_append<ic> (ics1, ics)
  val ans2 = auxmain<a> (stamp, iset, i1vs, i1veqs, n, ics)
  val (ics1_, ics_) = list_vt_split_at<ic> (ics, s1)
  val () = ics1 := ics1_
  val () = ics := ics_
in
  ans2
end // end of [auxmain_conj]

implement{a}
auxmain_disj {n}{s} (
  stamp, iset, i1vs, i1veqs, n, ics, ics1, rics1
) = let
  viewtypedef ic = icnstr (a, n)
  prval () = lemma_list_vt_param (ics)
in
//
case+ ics1 of
| ~list_vt_cons
    (ic1, ics1_next) => let
//
    val () = ics1 := ics1_next
//
//  HX: copying needed for backtracking
    val icsx = icnstrlst_copy<a> (ics, n)
    val icsx = list_vt_cons (ic1, icsx)
//
    val () = i1vs := myivlst_mark<a> (i1vs)
    val () = i1veqs := myiveqlst_mark<a> (i1veqs)
    var icsx = icsx // HX: for call-by-reference
    val ans2 = auxmain<a> (stamp, iset, i1vs, i1veqs, n, icsx)
    val () = i1vs := myivlst_unmark<a> (i1vs, n)
    val () = i1veqs := myiveqlst_unmark<a> (i1veqs, n)
//
    val+~list_vt_cons (ic1, icsx) = icsx
    val () = icnstrlst_free<a> (icsx, n) // HX: [icsx] may have been modified!
    val rics1 = list_vt_cons (ic1, rics1)
//
  in
    if ans2 >= 0 then let
      val () = (ics1 := list_vt_reverse_append<ic> (rics1, ics1))
    in
      0(*unsolved*)
    end else ( // solved and continue
      auxmain_disj<a> (stamp, iset, i1vs, i1veqs, n, ics, ics1, rics1)
    ) // end of [if]
  end // end of [list_vt_cons]
| ~list_vt_nil () => let
    val () = ics1 := list_vt_reverse<ic> (rics1) in ~1(*solved*)
  end // end of [list_vt_nil]
//
end // end of [auxmain_disj]

implement{a}
icnstrlst_solve
  {n} (iset, ics, n) = let
var
i1vs: myivlst (a, n) = MYIVLSTnil()
var
i1veqs: myiveqlst (a, n) = MYIVEQLSTnil()
//
val ans2 =
  auxmain<a> (0(*stamp*), iset, i1vs, i1veqs, n, ics)
//
val () = myivlst_free<a> (i1vs, n)
val () = myiveqlst_free<a> (i1veqs, n)
//
in
  ans2
end // end of [icnstrlst_solve]

(* ****** ****** *)

(* end of [pats_lintprgm_solve.dats] *)
