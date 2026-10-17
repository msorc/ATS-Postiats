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
// Start Time: April, 2011
//
(* ****** ****** *)
//
// HX-2026-10: no GC. Helpers shared by the pats_trans1_*.dats files
// (include this file after the staload of the arena and of [UN]).
//
(* ****** ****** *)
//
// HX: [list_map_fun] of ATS1 maps from the head (the order of the side
// effects of the translation is kept)
//
fun{a,b:type}
glist_map_loop
(
  xs: glist(a), f: a -> b, res: List0_vt(b)
) : List0_vt(b) =
(
  case+ glist_view (xs) of
  | ~GLnil () => list_vt_reverse (res)
  | ~GLcons (x, xs1) => let
      val y = f (x) in glist_map_loop<a,b> (xs1, f, list_vt_cons (y, res))
    end // end of [GLcons]
) (* end of [glist_map_loop] *)
//
fun{a,b:type}
glist_map_fun
  (xs: glist(a), f: a -> b): glist(b) =
  glist_make_list_vt (glist_map_loop<a,b> (xs, f, list_vt_nil ()))
//
//
// HX-2026-10: the same for the lists of declarations ([d0eclist_tr], [d1eclist_tr], [d2eclist_tr]).
// An exception of the compiler that leaves [f] ends (or aborts the translation of) a whole
// file: the accumulator [res] (a list_vt) is freed before the exception is raised again,
// so that nothing is left behind (a LeakSanitizer report) on that path. The setjmp of
// [try] is paid once per declaration, not per element of every list of the translation,
// which is why the other maps do not do it. The exceptions of the compiler have no
// argument (but [PATSOPT_FILENONE_EXN]), the same value is raised again.
//
staload ERRG = "./pats_error.sats"
//
fun{a,b:type}
glist_map_loop_g
(
  xs: glist(a), f: a -> b, res: List0_vt(b)
) : List0_vt(b) =
(
  case+ glist_view (xs) of
  | ~GLnil () => list_vt_reverse (res)
  | ~GLcons (x, xs1) => let
      val rp = $UN.castvwtp1{ptr} (res) // HX: [res] is not consumed by a handler of [try]
      val y = (
        try f (x) with
        | ~$ERRG.FatalErrorExn () => (list_vt_free ($UN.castvwtp0{List0_vt(b)} (rp)); $raise $ERRG.FatalErrorExn ())
        | ~$ERRG.FatalErrorExn_interr () => (list_vt_free ($UN.castvwtp0{List0_vt(b)} (rp)); $raise $ERRG.FatalErrorExn_interr ())
        | ~$ERRG.PATSOPT_FILENONE_EXN (s) => (list_vt_free ($UN.castvwtp0{List0_vt(b)} (rp)); $raise $ERRG.PATSOPT_FILENONE_EXN (s))
        | ~$ERRG.PATSOPT_FIXITY_EXN () => (list_vt_free ($UN.castvwtp0{List0_vt(b)} (rp)); $raise $ERRG.PATSOPT_FIXITY_EXN ())
        | ~$ERRG.PATSOPT_TRANS1_EXN () => (list_vt_free ($UN.castvwtp0{List0_vt(b)} (rp)); $raise $ERRG.PATSOPT_TRANS1_EXN ())
        | ~$ERRG.PATSOPT_TRANS2_EXN () => (list_vt_free ($UN.castvwtp0{List0_vt(b)} (rp)); $raise $ERRG.PATSOPT_TRANS2_EXN ())
        | ~$ERRG.PATSOPT_TRANS3_EXN () => (list_vt_free ($UN.castvwtp0{List0_vt(b)} (rp)); $raise $ERRG.PATSOPT_TRANS3_EXN ())
        | ~$ERRG.PATSOPT_TRANS4_EXN () => (list_vt_free ($UN.castvwtp0{List0_vt(b)} (rp)); $raise $ERRG.PATSOPT_TRANS4_EXN ())
      ) : b // end of [val]
    in
      glist_map_loop_g<a,b> (xs1, f, list_vt_cons (y, res))
    end // end of [GLcons]
) (* end of [glist_map_loop_g] *)
//
fun{a,b:type}
glist_map_fun_g
  (xs: glist(a), f: a -> b): glist(b) =
  glist_make_list_vt (glist_map_loop_g<a,b> (xs, f, list_vt_nil ()))
//
(* ****** ****** *)
//
// HX: closure conversion (PORTING.md, rule 13): the environment of a
// closure that is stored in a fixity operator is a cell of the global arena
//
fn{a:t@ype}
trans1_env_make (x: a): ptr = let
  val p = the_garena_alloc (sizeof<a>)
  val () = $UN.ptr0_set<a> (p, x)
in
  p
end // end of [trans1_env_make]
//
fn{a:t@ype}
trans1_env_get (p: ptr): a = $UN.ptr0_get<a> (p)
//
(* ****** ****** *)

//
// HX: a string that outlives its creator is copied into the global arena
//
fn
trans1_strptr2gstring
  (str: Strptr1): string = let
  val res = the_garena_strdup ($UN.castvwtp1{string}(str))
  val ((*freed*)) = strptr_free (str)
in
  res
end // end of [trans1_strptr2gstring]

(* ****** ****** *)

(* end of [pats_trans1.hats] *)
