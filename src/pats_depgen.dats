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
// Start Time: August, 2012
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_depgen.dats)
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)
//
staload
UN = "prelude/SATS/unsafe.sats"
//
staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"
//
(* ****** ****** *)

staload
GLOB = "./pats_global.sats"
staload
FIL = "./pats_filename.sats"

(* ****** ****** *)

staload "./pats_syntax.sats"

(* ****** ****** *)

staload "./pats_depgen.sats"

(* ****** ****** *)

typedef path = string
typedef pathlst = glist (path)
vtypedef pathlst_vt = List0_vt (path)

(* ****** ****** *)
//
extern
fun
pathtry_givename
  (given: string): Option_vt (string)
//
(* ****** ****** *)

implement
pathtry_givename(given) = let
//
extern
castfn
p2s{l:agz}(x: !strptr l):<> string
//
fun
loop
(
ps: glist(string), given: string
) : Option_vt(string) = let
in
  case+ glist_view(ps) of
  | ~GLnil
      () => None_vt()
    // end of [GLnil]
  | ~GLcons 
      (p, ps) => let
      val pname =
      $FIL.filename_dirbase(p, given)
      val test =
        test_file_exists((p2s)pname)
      // end of [val]
    in
      if
      (test)
      then let
        val
        pname_norm =
        $FIL.path_normalize((p2s)pname)
        val ((*freed*)) = strptr_free(pname)
      in
        Some_vt(pname_norm)
      end // end of [then]
      else
      loop(ps, given) where
      {
        val ((*freed*)) = strptr_free(pname)
      } (* end of [else] *)
    end // end of [GLcons]
end // end of [loop]
//
val knd = $FIL.givename_srchknd(given)
//
in
//
case+ knd of
//
| 0 => let // local: ./<filename>
    val fil =
      $FIL.filename_get_current()
    val pname =
      $FIL.filename_get_partname(fil)
    val pname2 =
      $FIL.filename_merge(pname, given)
    val isexi =
      test_file_exists((p2s)pname2)
  in
    if isexi then let
      val pname2_norm =
        $FIL.path_normalize((p2s)pname2)
      val ((*freed*)) = strptr_free(pname2)
    in
      Some_vt(pname2_norm)
    end else let
      val ((*freed*)) =
        strptr_free(pname2) in None_vt()
    end // end of [else]
  end // end of [0]
//
| 1 => None_vt() // $PATSHOMELOCS
//
| _ (*non-local*) =>
    loop($GLOB.the_IATS_dirlst_get(), given)
//
end // end of [pathtry_givename]

(* ****** ****** *)

typedef
depgen_ftype
  (a: type) = (a, &pathlst_vt >> pathlst_vt) -> void
// end of [depgen_ftype]

(* ****** ****** *)
//
extern
fun depgen_d0exp : depgen_ftype(d0exp)
and depgen_d0explst : depgen_ftype(d0explst)
and depgen_d0expopt : depgen_ftype(d0expopt)
and depgen_labd0explst : depgen_ftype(labd0explst)
//
extern
fun depgen_d0ecl : depgen_ftype(d0ecl)
and depgen_d0eclist : depgen_ftype(d0eclist)
and depgen_guad0ecl_node : depgen_ftype(guad0ecl_node)
//
(* ****** ****** *)

implement
depgen_d0exp
  (d0e0, res) = let
in
//
case+
  d0exp_node_view(d0e0.d0exp_node()) of
//
| ~D0Efoldat(d0es) => depgen_d0explst (d0es, res)
| ~D0Efreeat(d0es) => depgen_d0explst (d0es, res)
//
| ~D0Elet(d0cs1, d0e2) => let
    val () = depgen_d0eclist (d0cs1, res) in depgen_d0exp (d0e2, res)
  end // end of [D0Elet]
| ~D0Edeclseq(d0cs) => depgen_d0eclist (d0cs, res)
| ~D0Ewhere(d0e1, d0cs2) => let
    val () = depgen_d0eclist (d0cs2, res) in depgen_d0exp (d0e1, res)
  end // end of [D0Ewhere]
//
| ~D0Eapp(d0e1, d0e2) => let
    val () = depgen_d0exp (d0e1, res)
    val () = depgen_d0exp (d0e2, res)
  in
    // nothing
  end // end of [D0Eapp]
//
| ~D0Elist(npf, d0es) => depgen_d0explst (d0es, res)
//
| ~D0Eifhead
  (
    hd, _cond, _then, _else
  ) => let
    val () = depgen_d0exp (_cond, res)
    val () = depgen_d0exp (_then, res)
    val () = depgen_d0expopt (_else, res)
  in
    // nothing
  end // end of [D0Eifhead]
| ~D0Esifhead
  (
    hd, _cond, _then, _else
  ) => let
    val () = depgen_d0exp (_then, res)
    val () = depgen_d0exp (_else, res)
  in
    // nothing
  end // end of [D0Esifhead]
//
| ~D0Eseq(d0es) => depgen_d0explst(d0es, res)
//
| ~D0Elst(lin, elt, d0e) => depgen_d0exp(d0e, res)
//
| ~D0Etup(knd, npf, d0es) => depgen_d0explst(d0es, res)
//
| ~D0Erec(knd, npf, ld0es) => depgen_labd0explst(ld0es, res)
//
| v (* rest-of-d0exp *) => (d0exp_node_view_free(v))
//
end // end of [depgen_d0exp]

(* ****** ****** *)

implement
depgen_d0explst
  (xs, res) =
(
//
case+ glist_view(xs) of
| ~GLcons
    (x, xs) => let
    val () = depgen_d0exp (x, res) in depgen_d0explst (xs, res)
  end // end of [GLcons]
| ~GLnil () => ()
//
) // end of [depgen_d0explst]

implement
depgen_d0expopt
  (opt, res) =
(
//
case+ gopt_view(opt) of
| ~GOsome (d0e) => depgen_d0exp (d0e, res) | ~GOnone () => ()
//
) // end of [depgen_d0expopt]

(* ****** ****** *)

implement
depgen_labd0explst
  (lxs, res) =
(
//
case+ glist_view(lxs) of
| ~GLnil() => ()
| ~GLcons(lx, lxs) => let
    val () = depgen_d0exp(lx.labd0exp_elt(), res)
  in
    depgen_labd0explst(lxs, res)
  end // end of [GLcons]
//
) // end of [depgen_labd0explst]

(* ****** ****** *)

implement
depgen_d0ecl
  (d0c0, res) = let
in
//
case+
  d0ecl_node_view(d0c0.d0ecl_node()) of
//
| ~D0Cinclude
    (pfil, _, given) => let
    val opt = pathtry_givename(given)
  in
    case+ opt of
    | ~None_vt() => ()
    | ~Some_vt(pname) =>
        (res := list_vt_cons(pname, res))
      // end of [Some_vt]
  end // end of [DOCinclude]
//
| ~D0Cstaload
    (pfil, _, given) => let
    val opt = pathtry_givename(given)
  in
    case+ opt of
    | ~None_vt() => ()
    | ~Some_vt(pname) =>
        (res := list_vt_cons(pname, res))
      // end of [Some_vt]
  end // end of [D0Cstaload]
//
| ~D0Cstaloadloc
    (pfil, nspace, d0cs) => depgen_d0eclist (d0cs, res)
//
| ~D0Clocal
    (d0cs_head, d0cs_body) =>
  {
    val () = depgen_d0eclist (d0cs_head, res)
    val () = depgen_d0eclist (d0cs_body, res)
  } (* end of [D0Clocal] *)
//
| ~D0Cguadecl
    (knd, gd0c) => depgen_guad0ecl_node (gd0c.guad0ecl_node(), res)
  // end of [D0Cguadecl]
//
| v (* rest-of-d0ecl *) => (d0ecl_node_view_free(v))
//
end // end of [depgen_d0ecl]

(* ****** ****** *)

implement
depgen_d0eclist
  (xs, res) =
(
//
case+ glist_view(xs) of
| ~GLnil() => ()
| ~GLcons(x, xs) => let
    val () = depgen_d0ecl(x, res) in depgen_d0eclist(xs, res)
  end // end of [GLcons]
//
) // end of [depgen_d0eclist]

(* ****** ****** *)

implement
depgen_guad0ecl_node
  (x, res) = let
in
//
case+ guad0ecl_node_view(x) of
| ~GD0Cone(gua, d0cs) =>
    depgen_d0eclist(d0cs, res)
| ~GD0Ctwo
    (gua, d0cs1, d0cs2) => let
    val () = depgen_d0eclist(d0cs1, res)
    val () = depgen_d0eclist(d0cs2, res)
  in
    // nothing
  end // end of [GD0Ctwo]
| ~GD0Ccons
    (gua, d0cs1, knd, x2) => let
    val () = depgen_d0eclist(d0cs1, res)
    val () = depgen_guad0ecl_node(x2, res)
  in
    // nothing
  end // end of [GD0Ccons]
//
end // end of [depgen_guad0ecl_node]

(* ****** ****** *)

implement
depgen_eval(d0cs) =
list_vt_reverse(res) where
{
//
var
res: pathlst_vt = list_vt_nil()
//
val () = depgen_d0eclist(d0cs, res)
//
} (* end of [depgen_eval] *)

(* ****** ****** *)

implement
fprint_target
  (out, given) = let
//
fun
rindex
(
  p: ptr, i: int, k: int
) : int = let
  val c = $UN.ptr0_get<char> (p)
in
  if c = '\000'
    then k
    else rindex (ptr0_succ<char> (p), i+1, (if c = '.' then i else k))
end // end of [rindex]
//
val k = rindex ($UN.cast{ptr}(given), 0, ~1)
//
in
//
if k >= 0 then let
    fun fpr
    (
      out: FILEref
    , p: ptr, k: int, i: int
    ) : void = let
      val c = $UN.ptr0_get<char> (p)
    in
      if c != '\000' then let
        val c =
        (
          if i = k then '_' else c
        ) : char // end of [val]
      in
        fprint_char(out, c); fpr(out, ptr0_succ<char> (p), k, i+1)
      end // end of [if]
    end (* end of [fpr] *)
  in
    fpr(out, $UN.cast{ptr}(given), k, 0); fprint_string(out, ".o")
  end // end of [_ when ...]
else fprint_string (out, given) (*~found*)
//
end // end of [fprint_target]

(* ****** ****** *)

implement
fprint_entlst
  (out, given, ents) = let
//
fun
loop
(
  out: FILEref, i: int, ents: pathlst_vt
) : void = let
in
//
case+ ents of
| ~list_vt_nil
    ((*void*)) => ()
  // end of [list_vt_nil]
| ~list_vt_cons
    (ent, ents) => let
    val () =
    (
      if i > 0 then fprint_char (out, ' ')
    ) : void
    val () = fprint_string (out, ent)
  in
    loop (out, i + 1, ents)
  end // end of [list_vt_cons]
//
end
//
val () =
  fprint_target(out, given)
val () = fprint_string(out, " : ")
val () = loop(out, 0, ents)
val () = fprint_newline(out)
//
in
  // nothing
end // end of [fprint_entlst]

(* ****** ****** *)

(* end of [pats_depgen.dats] *)
