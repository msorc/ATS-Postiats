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
// HX-2026-10: no GC (ATS2 port of src/pats_patcst2.dats, see PORTING.md, "Pattern coverage (patcst2)")
//
(* ****** ****** *)

#include "share/atspre_staload.hats"
#include "./pats_assert.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)
//
staload UT = "./pats_utils.sats"
staload _(*anon*) = "./pats_utils.dats"
//
macdef charset_add = $UT.charset_add
macdef charset_sing = $UT.charset_sing
macdef charset_is_member = $UT.charset_is_member
macdef charset_listize = $UT.charset_listize
//
macdef fprint_charset = $UT.fprint_charset
//
(* ****** ****** *)
//
staload INTINF = "./pats_intinf.sats"
//
overload = with $INTINF.eq_intinf_intinf
//
macdef intinf_make_int = $INTINF.intinf_make_int
macdef intinf_make_string = $INTINF.intinf_make_string
//
macdef intinfset_add = $INTINF.intinfset_add
macdef intinfset_sing = $INTINF.intinfset_sing
macdef intinfset_is_member = $INTINF.intinfset_is_member
macdef intinfset_listize = $INTINF.intinfset_listize
//
macdef fprint_intinf = $INTINF.fprint_intinf
macdef fprint_intinfset = $INTINF.fprint_intinfset
//
(* ****** ****** *)

staload "./pats_basics.sats"
staload "./pats_lexing.sats" // for T_*

(* ****** ****** *)

staload ERR = "./pats_error.sats"
staload _(*anon*) = "./pats_error.dats"

(* ****** ****** *)

staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
implement prerr_FILENAME<> () = prerr "pats_p2atcst"

(* ****** ****** *)

staload LAB = "./pats_label.sats"

staload SYN = "./pats_syntax.sats"

(* ****** ****** *)

staload "./pats_staexp2.sats"
staload "./pats_stacst2.sats"
staload "./pats_dynexp2.sats"

(* ****** ****** *)

staload "./pats_patcst2.sats"

(* ****** ****** *)

#include "./pats_patcst2_gen_dats.hats"

(* ****** ****** *)

#define l2l glist_make_list_vt

(* ****** ****** *)

fn mk_any (): p2atcst = p2atcst_P2TCany ()

//
// HX-2026-10: the lists of the results can be long (products of the cases): the functions that build them are loops
// (an accumulator that is reversed) so that the depth of the stack does not depend on the length
//
fn
p2atcstlst_vt_rev (xs: p2atcstlst_vt): p2atcstlst_vt = list_vt_reverse<p2atcst> (xs)
fn
labp2atcstlst_vt_rev (xs: labp2atcstlst_vt): labp2atcstlst_vt = list_vt_reverse<labp2atcst> (xs)
fn
p2atcstlstlst_vt_rev (xs: p2atcstlstlst_vt): p2atcstlstlst_vt = list_vt_reverse<p2atcstlst_vt> (xs)
fn
labp2atcstlstlst_vt_rev (xs: labp2atcstlstlst_vt): labp2atcstlstlst_vt = list_vt_reverse<labp2atcstlst_vt> (xs)
//
fn
p2atcstlst_vt_append (xs: p2atcstlst_vt, ys: p2atcstlst_vt): p2atcstlst_vt =
  list_vt_reverse_append<p2atcst> (list_vt_reverse<p2atcst> (xs), ys)
fn
p2atcstlstlst_vt_append (xs: p2atcstlstlst_vt, ys: p2atcstlstlst_vt): p2atcstlstlst_vt =
  list_vt_reverse_append<p2atcstlst_vt> (list_vt_reverse<p2atcstlst_vt> (xs), ys)
fn
labp2atcstlstlst_vt_append (xs: labp2atcstlstlst_vt, ys: labp2atcstlstlst_vt): labp2atcstlstlst_vt =
  list_vt_reverse_append<labp2atcstlst_vt> (list_vt_reverse<labp2atcstlst_vt> (xs), ys)

fn eq_bool (b1: bool, b2: bool): bool = if b1 then b2 else ~b2
fn eq_char (c1: char, c2: char): bool = (char2int0 (c1) = char2int0 (c2))

// HX: [string_make_substring] of ATS1 ([rep2] is not freed: it lives in the arena)
fn
my_make_substring
(
  origin: string, start: size_t, length: size_t
) : string = let
  val p = the_garena_alloc (length + i2sz(1))
  val () = $extfcall (void, "memcpy", p, ptr0_add_guint<char> ($UN.cast{ptr}(origin), start), length)
  val () = $UN.ptr0_set<char> (ptr0_add_guint<char> (p, length), '\000')
in
  $UN.cast{string}(p)
end // end of [my_make_substring]

(* ****** ****** *)

#include "./pats_syntax_token.hats"

(* ****** ****** *)

fn
i0nt2intinf_aux
  (rep: string, sfx: uint): intinf =
(
if sfx > 0u
  then let
    val n = string0_length (rep)
    val sfx = $UN.cast{size_t}(sfx)
    val ln = n - sfx
    val rep2 = my_make_substring (rep, i2sz(0), ln)
  in
    intinf_make_string (rep2)
  end // end of [then]
  else intinf_make_string (rep)
// end of [if]
) (* end of [i0nt2intinf_aux] *)

implement
i0nt2intinf (tok) = let
//
in
//
case+ token_node_view(tok.token_node()) of
| ~T_INT(_, rep, sfx) => i0nt2intinf_aux (rep, sfx)
| v => (token_node_view_free(v); assertloc(false); intinf_make_int (0))
// HX: the MatchError of [val-T_INT(_, rep, sfx) = tok.token_node]
//
end // end of [i0nt2intinf]

(* ****** ****** *)

implement
p2atcst_lst
  (lin, xs) = let
//
(*
val () = println! ("p2atcst_lst: lin = ", lin)
*)
//
// HX-2026-10: no GC: lists are linear
//
val s2c =
  s2cstref_get_cst (the_list_vt0ype_int_vtype)
// end of [val]
//
val xx =
(
case+ gopt_view(s2cst_get_islst (s2c)) of
| ~GOsome(xx) => xx
| ~GOnone() => (assertloc(false); $UN.cast{d2conpair}(the_null_ptr))
) : d2conpair // HX: the MatchError of [val-Some xx]
val d2c_nil = d2conpair_0(xx) and d2c_cons = d2conpair_1(xx)
//
fun
auxlst
(
  xs: p2atcstlst
) : p2atcst =
(
case+ glist_view(xs) of
| ~GLnil () =>
    p2atcst_P2TCcon (d2c_nil, glist_nil())
| ~GLcons (x, xs) => let
    val ys = auxlst(xs)
  in
    p2atcst_P2TCcon(d2c_cons, glist_cons(x, glist_sing(ys)))
  end
) (* end of [auxlst] *)
//
in
  auxlst (xs)
end // end of [p2atcst_lst]

(* ****** ****** *)

implement
p2atcstlstlst_vt_free (xss) =
(
  case+ xss of
  | ~list_vt_cons (xs, xss) => let
      val () = list_vt_free (xs) in p2atcstlstlst_vt_free (xss)
    end // end of [list_vt_cons]
  | ~list_vt_nil () => ()
) // end of [p2atcstlstlst_vt_free]

//
// HX: a list of lists is walked as the list of the pointers to the (borrowed) inner lists
//
fn
p2atcstlstlst_ptrs (xss: !p2atcstlstlst_vt): List0_vt (ptr) = let
  val ps = $UN.castvwtp1{List0_vt(ptr)} (xss)
  val res = list_vt_copy<ptr> (ps)
  val ((*dropped*)) = $UN.castvwtp0{void} (ps)
in
  res
end // end of [p2atcstlstlst_ptrs]
fn
p2atcstlst_borrow (p: ptr): p2atcstlst_vt = let
  val xs = $UN.castvwtp1{p2atcstlst_vt} (p)
  val res = list_vt_copy<p2atcst> (xs)
  val ((*dropped*)) = $UN.castvwtp0{void} (xs)
in
  res
end // end of [p2atcstlst_borrow]

implement
p2atcstlstlst_vt_copy (xss) = let
//
fun
loop
(
  ps: List0_vt (ptr), res: p2atcstlstlst_vt
) : p2atcstlstlst_vt =
(
case+ ps of
| ~list_vt_cons (p, ps) =>
    loop (ps, list_vt_cons (p2atcstlst_borrow (p), res))
| ~list_vt_nil () => p2atcstlstlst_vt_rev (res)
)
//
in
  loop (p2atcstlstlst_ptrs (xss), list_vt_nil ())
end // end of [p2atcstlstlst_vt_copy]

(* ****** ****** *)

implement
p2atcstlst_of_vt (xs) = l2l (list_vt_copy<p2atcst> (xs))
implement
labp2atcstlst_of_vt (xs) = l2l (list_vt_copy<labp2atcst> (xs))
implement
p2atcstlstlst_of_vt (xss) = let
//
fun
loop
(
  ps: List0_vt (ptr), res: List0_vt (p2atcstlst)
) : List0_vt (p2atcstlst) =
(
case+ ps of
| ~list_vt_cons (p, ps) => let
    val ys = p2atcstlst_borrow (p)
  in
    loop (ps, list_vt_cons (l2l (ys), res))
  end
| ~list_vt_nil () => list_vt_reverse<p2atcstlst> (res)
)
//
in
  l2l (loop (p2atcstlstlst_ptrs (xss), list_vt_nil ()))
end // end of [p2atcstlstlst_of_vt]

(* ****** ****** *)
//
implement
fprint_p2atcst
  (out, p2tc) = let
//
macdef
prstr (s) = fprint_string (out, ,(s))  
//
in
//
case+ p2atcst_view (p2tc) of
//
| ~P2TCany () => fprint_char (out, '_')
//
| ~P2TCcon
    (d2c, p2tcs) => {
    val () = fprint_d2con (out, d2c);
    val () = prstr "("
    val () = fprint_p2atcstlst (out, p2tcs)
    val () =  prstr ")"
  } // end of [P2TCcon]
//
| ~P2TCempty () => prstr "P2TCempty()"
//
| ~P2TCint (int) => {
    val () = fprint_intinf (out, int)
  }
| ~P2TCintc (ints) => {
    val () = prstr "[^"
    val () = fprint_intinfset (out, ints)
    val () = prstr "]"
  } // end of [P2TCintc]
//
| ~P2TCbool (b) => {
    val () = fprint_bool (out, b)
  }
| ~P2TCchar (c) => {
    val () = fprint_char (out, c)
  }
| ~P2TCcharc (cs) => {
    val () = prstr "[^"
    val () = fprint_charset (out, cs)
    val () = prstr "]"
  }
| ~P2TCfloat (rep) => {
    val () = fprint_string (out, rep)
  }
| ~P2TCstring (x) => {
    val () = prstr "\""
    val () = fprint_string (out, x)
    val () = prstr "\""
  }
//
| ~P2TCrec
    (knd, lp2tcs) => {
    val () = if knd = 0 then fprint_char (out, '@')
    val () = if knd > 0 then fprint_char (out, '\'')
    val () = prstr "{"
    val () = fprint_labp2atcstlst (out, lp2tcs)
    val () = prstr "}"
  } // end of [P2TCrec]
//
end // end of [fprint_p2atcst]
//
implement
print_p2atcst (x) = fprint_p2atcst (stdout_ref, x)
implement
prerr_p2atcst (x) = fprint_p2atcst (stderr_ref, x)
//
(* ****** ****** *)

implement
fprint_p2atcstlst
  (out, xs) = $UT.fprintlst<p2atcst> (out, xs, ", ", fprint_p2atcst)
// end of [fprint_p2atcstlst]

(* ****** ****** *)

fun
fprint_p2atcstlst_vt
  (out: FILEref, xs: !p2atcstlst_vt): void = let
//
fun
loop
(
  xs: p2atcstlst_vt, i: int
) : void =
(
case+ xs of
| ~list_vt_cons (x, xs1) => let
    val () = if i > 0 then fprint_string (out, ", ")
    val () = fprint_p2atcst (out, x)
  in
    loop (xs1, i+1)
  end // end of [list_vt_cons]
| ~list_vt_nil () => ()
)
//
in
  loop (list_vt_copy<p2atcst> (xs), 0)
end // end of [fprint_p2atcstlst_vt]

(* ****** ****** *)

implement
print_p2atcstlst (xs) = fprint_p2atcstlst (stdout_ref, xs)
implement
prerr_p2atcstlst (xs) = fprint_p2atcstlst (stderr_ref, xs)

implement
print_p2atcstlst_vt (xs) =
  fprint_p2atcstlst_vt (stdout_ref, xs)
// end of [print_p2atcstlst_vt]
implement
prerr_p2atcstlst_vt (xs) =
  fprint_p2atcstlst_vt (stderr_ref, xs)
// end of [prerr_p2atcstlst_vt]

(* ****** ****** *)

fun fprint_labp2atcst (
  out: FILEref, lp2tc: labp2atcst
) : void = let
  val l = labp2atcst_lab (lp2tc)
  val p2tc = labp2atcst_elt (lp2tc)
in
  $LAB.fprint_label (out, l);
  fprint_string (out, "= ");
  fprint_p2atcst (out, p2tc)
end // end of [fprint_lab;2atcst]

implement
fprint_labp2atcstlst
  (out, xs) = $UT.fprintlst<labp2atcst> (out, xs, ", ", fprint_labp2atcst)
// end of [fprint_labp2atcstlst]

implement
print_labp2atcstlst (xs) = fprint_labp2atcstlst (stdout_ref, xs)
implement
prerr_labp2atcstlst (xs) = fprint_labp2atcstlst (stderr_ref, xs)

(* ****** ****** *)

implement
fprint_p2atcstlstlst
  (out, xss) = let
  val () = $UT.fprintlst<p2atcstlst> (out, xss, "\n", fprint_p2atcstlst)
in
  fprint_newline (out)
end // end of [fprint_p2atcstlst]

implement
print_p2atcstlstlst (xss) = fprint_p2atcstlstlst (stdout_ref, xss)
implement
prerr_p2atcstlstlst (xss) = fprint_p2atcstlstlst (stderr_ref, xss)

fun
fprint_p2atcstlstlst_vt
  (out: FILEref, xss: !p2atcstlstlst_vt): void = let
//
fun
loop
(
  ps: List0_vt (ptr), i: int
) : void =
(
case+ ps of
| ~list_vt_cons (p, ps) => let
    val () = if i > 0 then fprint_string (out, "\n")
    val xs = p2atcstlst_borrow (p)
    val () = fprint_p2atcstlst_vt (out, xs)
    val () = list_vt_free<p2atcst> (xs)
  in
    loop (ps, i+1)
  end // end of [list_vt_cons]
| ~list_vt_nil () => ()
)
//
in
  loop (p2atcstlstlst_ptrs (xss), 0); fprint_newline (out)
end // end of [fprint_p2atcstlstlst_vt]

implement
print_p2atcstlstlst_vt (xss) =
  fprint_p2atcstlstlst_vt (stdout_ref, xss)
// end of [print_p2atcstlstlst_vt]
implement
prerr_p2atcstlstlst_vt (xss) =
  fprint_p2atcstlstlst_vt (stderr_ref, xss)
// end of [prerr_p2atcstlstlst_vt]

(* ****** ****** *)

fun
p2at2cstlst_vt (
  p2ts: p2atlst
) : p2atcstlst_vt =
(
case+ glist_view (p2ts) of
| ~GLcons (p2t, p2ts) => let
    val p2tc = p2at2cst (p2t)
  in
    list_vt_cons (p2tc, p2at2cstlst_vt (p2ts))
  end // end of [GLcons]
| ~GLnil () => list_vt_nil ()
) // end of [p2at2cstlst_vt]

implement p2at2cstlst (p2ts) = l2l (p2at2cstlst_vt (p2ts))

(* ****** ****** *)

fun labp2at2cstlst_vt
  (lp2ts: labp2atlst): labp2atcstlst_vt =
  case+ glist_view (lp2ts) of
  | ~GLcons
      (lp2t, lp2ts) => (
    case+ labp2at_view (lp2t) of
    | ~LABP2ATnorm
        (l0, p2t) => let
        val l = $SYN.l0ab_lab(l0) and p2tc = p2at2cst (p2t)
      in
        list_vt_cons (labp2atcst_new (l, p2tc), labp2at2cstlst_vt lp2ts)
      end // end of [LABP2ATnorm]
    | ~LABP2ATomit (loc) => labp2at2cstlst_vt (lp2ts)
    ) // end of [GLcons]
  | ~GLnil () => list_vt_nil ()
// end of [labp2at2cstlst_vt]

(* ****** ****** *)
//
// HX: the stable merge sort of ATS1 [list_vt_mergesort] by the label:
// an element is inserted after the elements that are not larger
//
fun
labp2atcst_insert
(
  x: labp2atcst, ys: labp2atcstlst_vt
) : labp2atcstlst_vt =
(
case+ ys of
| ~list_vt_cons (y, ys1) =>
  (
    if $LAB.compare_label_label (labp2atcst_lab (x), labp2atcst_lab (y)) < 0
      then list_vt_cons (x, list_vt_cons (y, ys1))
      else list_vt_cons (y, labp2atcst_insert (x, ys1))
  ) // end of [list_vt_cons]
| ~list_vt_nil () => list_vt_sing (x)
) // end of [labp2atcst_insert]

fun
labp2atcst_sort
(
  xs: labp2atcstlst_vt, ys: labp2atcstlst_vt
) : labp2atcstlst_vt =
(
case+ xs of
| ~list_vt_cons (x, xs) => labp2atcst_sort (xs, labp2atcst_insert (x, ys))
| ~list_vt_nil () => ys
) // end of [labp2atcst_sort]

(* ****** ****** *)

implement
p2at2cst (p2t0) = let
//
in
//
case+ p2at_node_view (p2t0.p2at_node()) of
//
| ~P2Tvar _ => mk_any ()
| ~P2Tany () => mk_any ()
//
| ~P2Tcon
    (_, d2c, _, _, _, p2ts) =>
    p2atcst_P2TCcon (d2c, p2at2cstlst (p2ts))
  // end of [P2Tcon]
//
| ~P2Tempty () => p2atcst_P2TCempty ()
//
| ~P2Tint (i) => let
    val i = intinf_make_int (i) in p2atcst_P2TCint (i)
  end // end of [P2Tint]
| ~P2Tintrep (rep) => let
    val i = intinf_make_string (rep) in p2atcst_P2TCint (i)
  end // end of [P2Tint]
//
| ~P2Tbool (b) => p2atcst_P2TCbool (b)
| ~P2Tchar (c) => p2atcst_P2TCchar (c)
| ~P2Tfloat (rep) => p2atcst_P2TCfloat (rep)
| ~P2Tstring (str) => p2atcst_P2TCstring (str)
//
| ~P2Ti0nt (tok) => let
    val i0 = i0nt2intinf (tok) in p2atcst_P2TCint (i0)
  end // end of [P2Ti0nt]
| ~P2Tf0loat (tok) => let
    val rep = token_float_rep (tok) in p2atcst_P2TCfloat (rep)
  end // end of [P2Tf0loat]
//
| ~P2Tlst (lin, p2ts) =>
    p2atcst_lst (lin, p2at2cstlst (p2ts))
//
| ~P2Trec (
    recknd, npf, lp2ts
  ) => let
    val lp2tcs = labp2at2cstlst_vt (lp2ts)
    val lp2tcs = labp2atcst_sort (lp2tcs, list_vt_nil ())
  in
    p2atcst_P2TCrec (recknd, l2l (lp2tcs))
  end // end of [P2Trec]
//
| ~P2Trefas (_(*d2v*), p2t) => p2at2cst (p2t)
//
| ~P2Texist (_(*s2vs*), p2t) => p2at2cst (p2t)
//
| ~P2Tvbox _ => mk_any () // HX: only [vbox(d2v)] is allowed
//
| ~P2Tann (p2t, _) => p2at2cst (p2t)
//
| v (* P2T-rest *) => let
    val () = p2at_node_view_free (v)
    val () = prerr_interror_loc<> (p2t0.p2at_loc())
    val () = prerr_string (": p2at2cst: p2t0 = ")
    val () = prerr_p2at (p2t0)
    val () = prerr_newline ()
  in
    let val ((*exit*)) = assertloc(false) in mk_any () end
  end // end of [P2T-rest]
//
end (* end of [p2at2cst] *)

(* ****** ****** *)
//
// the list of the P2TCany of the length of a list (the elements are not used)
//
fun
auxanys
(
  n: int, res: p2atcstlst_vt
) : p2atcstlst_vt =
  if n > 0 then
    auxanys (n-1, list_vt_cons (mk_any (), res)) else res
  (* end of [if] *)
// end of [auxanys]

fun
auxanys_lst
(
  xs: p2atcstlst, res: p2atcstlst_vt
) : p2atcstlst_vt =
  case+ glist_view (xs) of
  | ~GLcons (x, xs) =>
      auxanys_lst (xs, list_vt_cons (mk_any (), res))
  | ~GLnil () => res
// end of [auxanys_lst]

(* ****** ****** *)
//
// [p2atcstlstlst_vt]: each list of [xss] is given to [P2TCcon (d2c, -)]
//
fun
p2atcstlstlst_con_loop
(
  d2c: d2con, xss: p2atcstlstlst_vt, res: p2atcstlst_vt
) : p2atcstlst_vt =
(
case+ xss of
| ~list_vt_cons (xs, xss) => let
    val x = p2atcst_P2TCcon (d2c, l2l (xs))
  in
    p2atcstlstlst_con_loop (d2c, xss, list_vt_cons (x, res))
  end // end of [list_vt_cons]
| ~list_vt_nil () => p2atcstlst_vt_rev (res)
) // end of [p2atcstlstlst_con_loop]

fn
p2atcstlstlst_con
(
  d2c: d2con, xss: p2atcstlstlst_vt
) : p2atcstlst_vt = p2atcstlstlst_con_loop (d2c, xss, list_vt_nil ())

fun
labp2atcstlstlst_rec_loop
(
  knd: int, xss: labp2atcstlstlst_vt, res: p2atcstlst_vt
) : p2atcstlst_vt =
(
case+ xss of
| ~list_vt_cons (xs, xss) => let
    val x = p2atcst_P2TCrec (knd, l2l (xs))
  in
    labp2atcstlstlst_rec_loop (knd, xss, list_vt_cons (x, res))
  end // end of [list_vt_cons]
| ~list_vt_nil () => p2atcstlst_vt_rev (res)
) // end of [labp2atcstlstlst_rec_loop]

fn
labp2atcstlstlst_rec
(
  knd: int, xss: labp2atcstlstlst_vt
) : p2atcstlst_vt = labp2atcstlstlst_rec_loop (knd, xss, list_vt_nil ())

(* ****** ****** *)

fun
p2atcst_comp_con
(
  d2c0: d2con
, d2cs: d2conlst, arg: p2atcstlst
) : p2atcstlst_vt = let
//
fun auxmain (
  d2c0: d2con, d2cs: d2conlst, arg: p2atcstlst
) : p2atcstlst_vt =
  case+ glist_view (d2cs) of
  | ~GLcons
      (d2c, d2cs) => (
      if d2c0 = d2c then let
        val carglst = p2atcstlst_comp (arg)
        val res1 = p2atcstlstlst_con (d2c, carglst)
        val res2 = auxmain (d2c0, d2cs, arg)
      in
        p2atcstlst_vt_append (res1, res2)
      end else let
        val anys =
          auxanys (d2con_get_arity_full d2c, list_vt_nil ())
        // end of [val]
        val p2tc = p2atcst_P2TCcon (d2c, l2l (anys))
        val res = auxmain (d2c0, d2cs, arg)
      in
        list_vt_cons (p2tc, res)
      end // end of [if]
    ) // end of [GLcons]
  | ~GLnil () => list_vt_nil ()
// end of [auxmain]
in
  auxmain (d2c0, d2cs, arg)
end // end of [p2atcst_comp_con]

(* ****** ****** *)

implement
p2atcst_comp
  (p2tc0) = let
in
//
case+ p2atcst_view (p2tc0) of
| ~P2TCany () => list_vt_nil ()
//
| ~P2TCcon (d2c0, p2tcs) => let
    val tag = d2con_get_tag (d2c0)
  in
    if tag >= 0 then let
      val s2c0 = d2con_get_scst (d2c0)
      val d2cs =
      (
        case+ gopt_view (s2cst_get_dconlst (s2c0)) of
        | ~GOsome (d2cs) => d2cs
        | ~GOnone () => (assertloc(false); glist_nil ())
      ) : d2conlst // HX: the MatchError of [val-Some (d2cs)]
    in
      p2atcst_comp_con (d2c0, d2cs, p2tcs)
    end else // HX: [d2c0] associated with an extensible sum
      list_vt_sing (mk_any ())
    // end of [if]
  end // end of [P2TCcon]
//
| ~P2TCempty () => list_vt_nil ()
//
| ~P2TCint (x) => let
    val xs = intinfset_sing (x) in list_vt_sing (p2atcst_P2TCintc (xs))
  end // end of [P2TCint]
| ~P2TCintc (xs) => let
    fun aux
    (
      xs: List0_vt (intinf), res: p2atcstlst_vt
    ) : p2atcstlst_vt =
    (
      case+ xs of
      | ~list_vt_nil () => p2atcstlst_vt_rev (res)
      | ~list_vt_cons (x, xs) => aux (xs, list_vt_cons (p2atcst_P2TCint (x), res))
    ) (* end of [aux] *)
  in
    aux ($UN.castvwtp0{List0_vt(intinf)} (intinfset_listize (xs)), list_vt_nil ())
  end // end of [P2TCintc]
//
| ~P2TCbool (b) => list_vt_sing (p2atcst_P2TCbool (~b))
//
| ~P2TCchar (c) => let
    val cs = charset_sing (c) in list_vt_sing (p2atcst_P2TCcharc (cs))
  end // end of [P2TCchar]
| ~P2TCcharc (cs) => let
    fun aux
    (
      cs: List0_vt (char), res: p2atcstlst_vt
    ) : p2atcstlst_vt =
    (
      case+ cs of
      | ~list_vt_nil () => p2atcstlst_vt_rev (res)
      | ~list_vt_cons (x, cs) => aux (cs, list_vt_cons (p2atcst_P2TCchar (x), res))
    ) (* end of [aux] *)
  in
    aux ($UN.castvwtp0{List0_vt(char)} (charset_listize (cs)), list_vt_nil ())
  end // end of [P2TCcharc]
//
| ~P2TCfloat _ => list_vt_sing (mk_any ()) // conservative estimate
| ~P2TCstring _ => list_vt_sing (mk_any ()) // conservative estimate
//
| ~P2TCrec
    (knd, arg) => res where
  {
    val carglst =
      labp2atcstlst_comp (arg)
    val res = labp2atcstlstlst_rec (knd, carglst)
  } (* end of [P2TCrec] *)
//
end // end of [p2atcst_comp]

(* ****** ****** *)
//
// [x :: xs] for each [xs] of [xss]
//
fun
p2atcstlstlst_prefix_loop
(
  x: p2atcst, xss: p2atcstlstlst_vt, res: p2atcstlstlst_vt
) : p2atcstlstlst_vt =
(
case+ xss of
| ~list_vt_cons (xs, xss) => let
    val ys = list_vt_cons (x, xs)
  in
    p2atcstlstlst_prefix_loop (x, xss, list_vt_cons (ys, res))
  end // end of [list_vt_cons]
| ~list_vt_nil () => p2atcstlstlst_vt_rev (res)
) // end of [p2atcstlstlst_prefix_loop]

fn
p2atcstlstlst_prefix
(
  x: p2atcst, xss: p2atcstlstlst_vt
) : p2atcstlstlst_vt = p2atcstlstlst_prefix_loop (x, xss, list_vt_nil ())

fun
labp2atcstlstlst_prefix_loop
(
  x: labp2atcst, xss: labp2atcstlstlst_vt, res: labp2atcstlstlst_vt
) : labp2atcstlstlst_vt =
(
case+ xss of
| ~list_vt_cons (xs, xss) => let
    val ys = list_vt_cons (x, xs)
  in
    labp2atcstlstlst_prefix_loop (x, xss, list_vt_cons (ys, res))
  end // end of [list_vt_cons]
| ~list_vt_nil () => labp2atcstlstlst_vt_rev (res)
) // end of [labp2atcstlstlst_prefix_loop]

fn
labp2atcstlstlst_prefix
(
  x: labp2atcst, xss: labp2atcstlstlst_vt
) : labp2atcstlstlst_vt = labp2atcstlstlst_prefix_loop (x, xss, list_vt_nil ())

(* ****** ****** *)

implement
p2atcstlst_comp
  (p2tcs0) = let
in
//
case+ glist_view (p2tcs0) of
//
| ~GLnil () => list_vt_nil ()
//
| ~GLcons (p2tc1, p2tcs1) => let
//
    val res1 =
      p2atcstlstlst_prefix (p2tc1, p2atcstlst_comp (p2tcs1))
    // end of [val]
//
    val res2 = let
      fun aux (
        xs: p2atcstlst_vt, res: p2atcstlstlst_vt
      ) : p2atcstlstlst_vt =
        case+ xs of
        | ~list_vt_cons
            (x, xs) => let
            val ys =
              list_vt_cons (x, auxanys_lst (p2tcs1, list_vt_nil))
            // end of [val]
          in
            aux (xs, list_vt_cons (ys, res))
          end // end of [list_vt_cons]
        | ~list_vt_nil () => p2atcstlstlst_vt_rev (res)
      // end of [aux]
    in
      aux (p2atcst_comp (p2tc1), list_vt_nil ())
    end // end of [val]
//
  in
    p2atcstlstlst_vt_append (res1, res2)
  end // end of [GLcons]
//
end // end of [p2atcstlst_comp]

(* ****** ****** *)

fun
labp2atcst_comp
(
  lp2tc: labp2atcst
) : labp2atcstlst_vt = let
  val l = labp2atcst_lab (lp2tc)
  val p2tc = labp2atcst_elt (lp2tc)
  val cp2tcs = p2atcst_comp (p2tc)
//
  fun aux
  (
    xs: p2atcstlst_vt, res: labp2atcstlst_vt
  ) : labp2atcstlst_vt =
  (
    case+ xs of
    | ~list_vt_cons (x, xs) =>
        aux (xs, list_vt_cons (labp2atcst_new (l, x), res))
    | ~list_vt_nil () => labp2atcstlst_vt_rev (res)
  )
//
in
  aux (cp2tcs, list_vt_nil ())
end // end of [labp2atcst_comp]

(* ****** ****** *)

implement
labp2atcstlst_comp 
  (lp2tcs0) = let
in
//
case+ glist_view (lp2tcs0) of
//
| ~GLnil () => list_vt_nil ()
//
| ~GLcons (lp2tc1, lp2tcs1) => let
    val res1 =
      labp2atcstlstlst_prefix (lp2tc1, labp2atcstlst_comp (lp2tcs1))
    val res2 = let
      fun aux (
        xs: labp2atcstlst_vt, res: labp2atcstlstlst_vt
      ) : labp2atcstlstlst_vt =
        case+ xs of
        | ~list_vt_cons (x, xs) => let
            val ys = list_vt_sing (x) in aux (xs, list_vt_cons (ys, res))
          end // end of [list_vt_cons]
        | ~list_vt_nil () => labp2atcstlstlst_vt_rev (res)
      // end of [aux]
    in
      aux (labp2atcst_comp (lp2tc1), list_vt_nil ())
    end // end of [val]
  in
    labp2atcstlstlst_vt_append (res1, res2)
  end // end of [GLcons]
//
end // end of [labp2atcst_comp]

(* ****** ****** *)

fun
p2atlst_any
(
  p2ts: p2atlst
) : p2atcstlst_vt =
(
case+ glist_view (p2ts) of
| ~GLcons (_, p2ts) => list_vt_cons (mk_any (), p2atlst_any (p2ts))
| ~GLnil () => list_vt_nil ()
) // end of [p2atlst_any]

implement
c2lau_pat_any
  (c2l) = let
//
val p2ts = c2l.c2lau_pat()
//
in
  list_vt_sing(p2atlst_any(p2ts))
end // end of [c2lau_pat_any]

(* ****** ****** *)

implement
c2lau_pat_comp
  (c2l) = let
//
val p2ts = c2l.c2lau_pat()
(*
val () = fprintln! (
  stdout_ref, "c2lau_pat_comp: c2l.c2lau_pat = ", p2ts
) (* end of [val] *)
*)
//
in
//
if glist_is_cons (c2l.c2lau_gua()) then let
(*
//
// HX: conservative estimate: [c2l] cannot be chosen
//
*)
    val anys = p2atlst_any (p2ts)
  in
    list_vt_sing (anys)
  end // end of [list_cons]
else let
    val p2tcs = p2at2cstlst (p2ts)
    val cp2tcss = p2atcstlst_comp (p2tcs)
  in
    cp2tcss
  end // end of [list_nil]
//
end // end of [c2lau_pat_complement]

(* ****** ****** *)

implement
p2atcst_inter_test
  (p2tc1, p2tc2) = let
in
//
if p2atcst_is_P2TCany (p2tc1) then true
else if p2atcst_is_P2TCany (p2tc2) then true
else (
//
case+ p2atcst_view (p2tc1) of
| ~P2TCcon (d2c1, p2tcs1) => (
  case+ p2atcst_view (p2tc2) of
  | ~P2TCcon (d2c2, p2tcs2) => (
      if d2c1 = d2c2 then
        p2atcstlst_inter_test (p2tcs1, p2tcs2) else false
      // end of [if]
    ) // end of [P2TCcon, P2TCcon]
  | v => (p2atcst_view_free (v); true)
  )
| ~P2TCempty () => (
  case+ p2atcst_view (p2tc2) of
  | ~P2TCempty () => true
  | v => (p2atcst_view_free (v); true)
  )
//
| ~P2TCint i1 => (
  case+ p2atcst_view (p2tc2) of
  | ~P2TCint i2 => (i1 = i2)
  | ~P2TCintc xs =>
      if intinfset_is_member (xs, i1) then false else true
  | v => (p2atcst_view_free (v); true)
  )
| ~P2TCintc xs => (
  case+ p2atcst_view (p2tc2) of
  | ~P2TCint x =>
      if intinfset_is_member (xs, x) then false else true
  | v => (p2atcst_view_free (v); true)
  )
//
| ~P2TCbool b1 => (
  case+ p2atcst_view (p2tc2) of
  | ~P2TCbool b2 => eq_bool (b1, b2)
  | v => (p2atcst_view_free (v); true)
  )
//
| ~P2TCchar c1 => (
  case+ p2atcst_view (p2tc2) of
  | ~P2TCchar c2 => eq_char (c1, c2)
  | ~P2TCcharc xs =>
      if charset_is_member (xs, c1) then false else true
  | v => (p2atcst_view_free (v); true)
  )
| ~P2TCcharc xs => (
  case+ p2atcst_view (p2tc2) of
  | ~P2TCchar x =>
      if charset_is_member (xs, x) then false else true
  | v => (p2atcst_view_free (v); true)
  )
//
| ~P2TCrec (_, lp2atcs1) => (
  case+ p2atcst_view (p2tc2) of
  | ~P2TCrec (_, lp2atcs2) =>
      labp2atcstlst_inter_test (lp2atcs1, lp2atcs2)
    // end of [P2TCrec, P2TCrec]
  | v => (p2atcst_view_free (v); true)
  )
//
| v (* HX: being conservative *) => (p2atcst_view_free (v); true)
//
) (* end of [else] *)
//
end (* end of [p2atcst_inter_test] *)

implement
p2atcstlst_inter_test
  (xs1, xs2) = let
in
//
case+ glist_view (xs1) of
| ~GLcons (x1, xs1) => (
  case+ glist_view (xs2) of
  | ~GLcons (x2, xs2) =>
      if p2atcst_inter_test (x1, x2)
        then p2atcstlst_inter_test (xs1, xs2) else false
      // end of [if]
  | ~GLnil () => false
  ) // end of [GLcons]
| ~GLnil () => (
  case+ glist_view (xs2) of ~GLcons _ => false | ~GLnil () => true
  ) // end of [GLnil]
//
end // end of [p2atcstlst_inter_test]

implement
labp2atcstlst_inter_test
  (lxs10, lxs20) = let
in
//
if glist_is_cons (lxs10) then let
  val lx1 = glist_head<labp2atcst> (lxs10)
  val lxs1 = glist_tail<labp2atcst> (lxs10)
in
  if glist_is_cons (lxs20) then let
      val lx2 = glist_head<labp2atcst> (lxs20)
      val lxs2 = glist_tail<labp2atcst> (lxs20)
      val l1 = labp2atcst_lab (lx1) and x1 = labp2atcst_elt (lx1)
      val l2 = labp2atcst_lab (lx2) and x2 = labp2atcst_elt (lx2)
      val sgn = $LAB.compare_label_label (l1, l2)
    in
      if sgn < 0 then
        labp2atcstlst_inter_test (lxs1, lxs20)
      else if sgn > 0 then
        labp2atcstlst_inter_test (lxs10, lxs2)
      else (
        if p2atcst_inter_test (x1, x2) then 
          labp2atcstlst_inter_test (lxs1, lxs2) else false
        // end of [if]
      ) // end of [if]
    end // end of [then]
  else true
end // end of [then]
else true
//
end // end of [labp2atcstlst_inter_test]

(* ****** ****** *)
//
// the list of the constraints of [xss] (each given to [P2TCcon (d2c, -)])
//
fun
p2atcstlstlst_map_con
(
  d2c: d2con, xss: p2atcstlstlst_vt
) : p2atcstlst_vt = p2atcstlstlst_con (d2c, xss)

fun
labp2atcstlst_map_loop
(
  l: label, xs: p2atcstlst_vt, res: labp2atcstlst_vt
) : labp2atcstlst_vt =
(
case+ xs of
| ~list_vt_cons (x, xs) =>
    labp2atcstlst_map_loop (l, xs, list_vt_cons (labp2atcst_new (l, x), res))
| ~list_vt_nil () => labp2atcstlst_vt_rev (res)
) // end of [labp2atcstlst_map_loop]

fn
labp2atcstlst_map
(
  l: label, xs: p2atcstlst_vt
) : labp2atcstlst_vt = labp2atcstlst_map_loop (l, xs, list_vt_nil ())

(* ****** ****** *)

implement
p2atcst_diff
  (p2tc1, p2tc2) = let
in
//
if p2atcst_is_P2TCany (p2tc2) then list_vt_nil ()
else if p2atcst_is_P2TCany (p2tc1) then p2atcst_comp (p2tc2)
else (
//
case+ p2atcst_view (p2tc1) of
| ~P2TCint i1 => (
  case+ p2atcst_view (p2tc2) of
  | ~P2TCint i2 =>
      if i1 = i2 then list_vt_nil else list_vt_sing (p2tc1)
    // end of [P2TCint, P2TCint]
  | ~P2TCintc xs =>
      if intinfset_is_member (xs, i1) then list_vt_sing (p2tc1) else list_vt_nil
    // end of [P2TCint, P2TCintc]
  | v => (p2atcst_view_free (v); list_vt_sing (p2tc1))
  )
| ~P2TCintc xs => (
  case+ p2atcst_view (p2tc2) of
  | ~P2TCint x => (
      if intinfset_is_member (xs, x)
        then list_vt_sing (p2tc1) else let
        val xs = intinfset_add (xs, x) in list_vt_sing (p2atcst_P2TCintc (xs))
      end // end of [if]
    ) // end of [P2TCintc, P2TCint]
  | v => (p2atcst_view_free (v); list_vt_sing (p2tc1))
  )
//
| ~P2TCbool b1 => (
  case+ p2atcst_view (p2tc2) of
  | ~P2TCbool b2 =>
      if eq_bool (b1, b2) then list_vt_nil else list_vt_sing (p2tc1)
    // end of [P2TCbool, P2TCbool]
  | v => (p2atcst_view_free (v); list_vt_sing (p2tc1))
  )
//
| ~P2TCchar c1 => (
  case+ p2atcst_view (p2tc2) of
  | ~P2TCchar c2 => begin
      if eq_char (c1, c2) then list_vt_nil else list_vt_sing (p2tc1)
      end // end of [P2TCchar, P2TCchar]
  | ~P2TCcharc xs =>
      if charset_is_member (xs, c1) then list_vt_sing (p2tc1) else list_vt_nil
  | v => (p2atcst_view_free (v); list_vt_sing (p2tc1))
  )
| ~P2TCcharc xs => (
  case+ p2atcst_view (p2tc2) of
  | ~P2TCchar x => (
      if charset_is_member (xs, x)
        then list_vt_sing (p2tc1) else let
        val xs = charset_add (xs, x) in list_vt_sing (p2atcst_P2TCcharc (xs))
      end // end of [if]
    ) // end of [P2TCcharc, P2TCchar]
  | v => (p2atcst_view_free (v); list_vt_sing (p2tc1))
  )
//
| ~P2TCstring s1 => (
  case+ p2atcst_view (p2tc2) of
  | ~P2TCstring s2 =>
      if s1 = s2 then list_vt_nil else list_vt_sing (p2tc1)
    // end of [P2TCstring, P2TCstring]
  | v => (p2atcst_view_free (v); list_vt_sing (p2tc1))
  )
//
| ~P2TCcon (d2c1, p2tcs1) => (
  case+ p2atcst_view (p2tc2) of
  | ~P2TCcon (d2c2, p2tcs2) =>
    (
      if
      (d2c1 = d2c2)
      then let
        val
        p2tcss =
        p2atcstlst_diff(p2tcs1, p2tcs2)
      in
        p2atcstlstlst_map_con (d2c1, p2tcss)
      end // end of [then]
      else list_vt_sing (p2tc1)
    ) // end of [P2TCcon, P2TCcon]
  | v => (p2atcst_view_free (v); list_vt_sing (p2tc1))
  )
//
| ~P2TCempty () => (
  case+ p2atcst_view (p2tc2) of
  | ~P2TCempty () => list_vt_nil ()
  | v => (p2atcst_view_free (v); list_vt_sing (p2tc1))
  )
//
| ~P2TCrec (knd1, lp2tcs1) => (
  case+ p2atcst_view (p2tc2) of
  | ~P2TCrec (knd2, lp2tcs2) => let
      val
      lp2tcss =
      labp2atcstlst_diff(lp2tcs1, lp2tcs2)
    in
      labp2atcstlstlst_rec (knd1, lp2tcss)
    end
  | v => (p2atcst_view_free (v); list_vt_sing (p2tc1))
  )
//
| v => (p2atcst_view_free (v); list_vt_sing (p2tc1))
//
) (* end of [else] *)
//
end // end of [p2atcst_diff]

(* ****** ****** *)

implement
p2atcstlst_diff
  (xs1, xs2) = let
in
//
case+ glist_view (xs1) of
| ~GLcons (x1, xs1) => (
  case+ glist_view (xs2) of
  | ~GLcons (x2, xs2) => let
      val p2tcss_res1 = let
        val xss = p2atcstlst_diff (xs1, xs2)
      in
        p2atcstlstlst_prefix (x1, xss)
      end // end of [val]
      fun aux2 (
        xs: p2atcstlst_vt, xs1: p2atcstlst, res: p2atcstlstlst_vt
      ) : p2atcstlstlst_vt =
        case+ xs of
        | ~list_vt_cons (x, xs) => let
            val xs1_ = glist_listize<p2atcst> (xs1) in
            aux2 (xs, xs1, list_vt_cons (list_vt_cons (x, xs1_), res))
          end // end of [list_vt_cons]
        | ~list_vt_nil () => p2atcstlstlst_vt_rev (res)
      // end of [aux2]
      val p2tcss_res2 = aux2 (p2atcst_diff (x1, x2), xs1, list_vt_nil ())
    in
      p2atcstlstlst_vt_append (p2tcss_res1, p2tcss_res2)
    end // end of [GLcons]
  | ~GLnil () => list_vt_nil ()
  ) // end of [GLcons]
| ~GLnil () => p2atcstlst_comp (xs2)
//
end (* end of [p2atcstlst_diff] *)

(* ****** ****** *)

implement
labp2atcst_diff
  (lp2tc1, lp2tc2) = let
//
val l1 = labp2atcst_lab (lp2tc1)
and p2tc1 = labp2atcst_elt (lp2tc1)
val l2 = labp2atcst_lab (lp2tc2)
and p2tc2 = labp2atcst_elt (lp2tc2)
//
in
//
if
$LAB.eq_label_label
(l1, l2)
then let
val p2tcs =
p2atcst_diff(p2tc1, p2tc2)
in
  labp2atcstlst_map (l1, p2tcs)
end
else list_vt_sing (lp2tc1)
//
end // end of [labp2atcst_diff]

(* ****** ****** *)

implement
labp2atcstlst_diff
  (lxs1, lxs2) = let
in
//
case+ glist_view (lxs1) of
| ~GLcons (lx1, lxs1) => (
  case+ glist_view (lxs2) of
  | ~GLcons (lx2, lxs2) => let
      val lp2tcss_res1 = let
        val lxss = labp2atcstlst_diff(lxs1, lxs2)
      in
        labp2atcstlstlst_prefix (lx1, lxss)
      end // end of [val]
      fun aux2 (
        lxs: labp2atcstlst_vt, lxs1: labp2atcstlst, res: labp2atcstlstlst_vt
      ) : labp2atcstlstlst_vt =
        case+ lxs of
        | ~list_vt_cons (lx, lxs) => let
            val lxs1_ = glist_listize<labp2atcst> (lxs1) in
            aux2 (lxs, lxs1, list_vt_cons (list_vt_cons (lx, lxs1_), res))
          end // end of [list_vt_cons]
        | ~list_vt_nil () => labp2atcstlstlst_vt_rev (res)
      // end of [aux2]
      val lp2tcss_res2 = aux2 (labp2atcst_diff (lx1, lx2), lxs1, list_vt_nil ())
    in
      labp2atcstlstlst_vt_append (lp2tcss_res1, lp2tcss_res2)
    end // end of [GLcons]
  | ~GLnil () => list_vt_nil ()
  ) // end of [GLcons]
| ~GLnil () => labp2atcstlst_comp (lxs2)
//
end (* end of [labp2atcstlst_diff] *)

(* ****** ****** *)

(* end of [pats_patcst2.dats] *)
