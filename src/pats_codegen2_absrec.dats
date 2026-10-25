(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-2015 Hongwei Xi, ATS Trustful Software, Inc.
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
// Start Time: August, 2016
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_codegen2_absrec.dats, see PORTING.md, "Codegen2")
// [absrecfld] (a nonlinear datatype with arguments) is a flat pair of a kind and a [s2exp];
// [s2cst_get_name] is the one of pats_staexp2.sats (same definition as the static one of ATS1).
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
staload
LAB = "./pats_label.sats"
//
(* ****** ****** *)
//
staload
LOC = "./pats_location.sats"
//
(* ****** ****** *)
//
staload SYM = "./pats_symbol.sats"
//
(* ****** ****** *)
//
staload "./pats_staexp1.sats"
//
(* ****** ****** *)
//
staload "./pats_staexp2.sats"
staload "./pats_dynexp2.sats"
//
(* ****** ****** *)

staload "./pats_codegen2.sats"

(* ****** ****** *)
//
extern
fun
absrec_emit_tydef_uni
(
  out: FILEref, s2e0: s2exp
) : void // end-of-function
//
implement
absrec_emit_tydef_uni
  (out, s2e0) = let
//
fun
aux_s2varlst
(
  out: FILEref
, s2vs: s2varlst, i: int
) : void =
(
case+ glist_view(s2vs) of
| ~GLnil() => ()
| ~GLcons(s2v, s2vs) =>
  {
//
    val () =
    if i > 0
      then fprint_string(out, ";")
    // end of [if]
    val () = let
      val s2t = s2var_get_srt(s2v)
    in
      codegen2_emit_s2var(out, s2v);
      fprint_string(out, ":"); codegen2_emit_s2rt(out, s2t)
    end (* end of [val] *)
//
    val () = aux_s2varlst(out, s2vs, i+1)
//
  } (* end of [list_cons] *)
) (* end of [aux_s2varlst] *)
//
in
//
case+
s2exp_node_view(s2e0.s2exp_node())
of (* case+ *)
| ~S2Elam
  (
    s2vs, s2e_body
  ) => () where
  {
    val () = fprint_string(out, "{")
    val () = aux_s2varlst(out, s2vs, 0)
    val () = fprint_string(out, "}")
    val () = absrec_emit_tydef_uni(out, s2e_body)
  } (* S2Elam *)
| v(*non-S2Elam*) => s2exp_node_view_free(v)
//
end // end of [absrec_emit_tydef_uni]
//
(* ****** ****** *)
//
extern
fun
absrec_emit_tydef_arg
(
  out: FILEref, s2e0: s2exp
) : void // end-of-function
//
implement
absrec_emit_tydef_arg
  (out, s2e0) = let
//
fun
aux_s2varlst
(
  out: FILEref
, s2vs: s2varlst, i: int
) : void =
(
case+ glist_view(s2vs) of
| ~GLnil() => ()
| ~GLcons(s2v, s2vs) =>
  {
//
    val () =
    if i > 0
      then fprint_string(out, ", ")
    // end of [if]
    val () =
    (
      codegen2_emit_s2var(out, s2v)
    ) (* end of [val] *)
//
    val () = aux_s2varlst(out, s2vs, i+1)
//
  } (* end of [list_cons] *)
) (* end of [aux_s2varlst] *)
//
in
//
case+
s2exp_node_view(s2e0.s2exp_node())
of (* case+ *)
| ~S2Elam
  (
    s2vs, s2e_body
  ) => () where
  {
    val () = fprint_string(out, "(")
    val () = aux_s2varlst(out, s2vs, 0)
    val () = fprint_string(out, ")")
    val () = absrec_emit_tydef_arg(out, s2e_body)
  } (* S2Elam *)
| v(*non-S2Elam*) => s2exp_node_view_free(v)
//
end // end of [absrec_emit_tydef_arg]
//
(* ****** ****** *)
//
datatype
absrecfldkind =
//
  | ABSRECFLDget
  | ABSRECFLDset
  | ABSRECFLDgetset
//
  | ABSRECFLDexch
//
(*
  | ABSRECFLDvtget0
  | ABSRECFLDvtget1
*)
//
  | ABSRECFLDgetref
//
  | ABSRECFLDunknown
//
typedef absrecfld = @(absrecfldkind, s2exp)
//
(* ****** ****** *)
//
extern
fun
absrecfld_of_s2exp
  (s2e0: s2exp): absrecfld
//
implement
absrecfld_of_s2exp
  (s2e0) = let
//
macdef
is_get(name) = (,(name) = "get")
macdef
is_set(name) =  (,(name) = "set")
macdef
is_getset(name) = (,(name) = "getset")
//
macdef
is_exch(name) = (,(name) = "exch")
//
(*
macdef
is_vtget0(name) = (,(name) = "vtget0")
macdef
is_vtget0(name) = (,(name) = "vtget1")
*)
//
macdef
is_getref(name) = (,(name) = "getref")
//
in
//
case+
s2exp_node_view(s2e0.s2exp_node()) of
| ~S2Eapp
  (
    s2e1, s2es
  ) => (
    case+ glist_view(s2es) of
    | ~GLnil() => @(ABSRECFLDunknown, s2e0)
    | ~GLcons(s2e2, _) => (
    case+
    s2exp_node_view(s2e1.s2exp_node())
    of // case+
    | ~S2Ecst(s2c1) => let
        val name = s2cst_get_name(s2c1)
      in
//
        if is_get(name) then @(ABSRECFLDget, s2e2)
        else if is_set(name) then @(ABSRECFLDset, s2e2)
        else if is_getset(name) then @(ABSRECFLDgetset, s2e2)
//
        else if is_exch(name) then @(ABSRECFLDexch, s2e2)
//
(*
        else if is_vtget0(name) then @(ABSRECFLDvtget0, s2e2)
        else if is_vtget1(name) then @(ABSRECFLDvtget1, s2e2)
*)
//
        else if is_getref(name) then @(ABSRECFLDgetref, s2e2)
//
        else (* unrecognized *) @(ABSRECFLDunknown, s2e0)
//
      end (* end of [S2Ecst] *)
    | v(*non-S2Ecst*) => (s2exp_node_view_free(v); @(ABSRECFLDunknown, s2e0))
    ) (* end of [GLcons] *)
  )
| v(*non-S2Eapp*) => (s2exp_node_view_free(v); @(ABSRECFLDunknown, s2e0))
//
end // end of [absrecfld_of_s2exp]
//
(* ****** ****** *)
//
// HX: [auxdecl] of ATS1 (a local function), lambda-lifted by hand
//
fun
absrec_emit_decl
(
  out: FILEref
, s2c0: s2cst, tnm: string, l0: label, fnm: string, s2e: s2exp
) : void =
{
//
val
s2t0 = s2cst_get_srt(s2c0)
val s2def =
(
case+ gopt_view(s2cst_get_def(s2c0)) of
| ~GOsome(s2def) => s2def
| ~GOnone() => (assertloc(false); s2e) // HX: the MatchError of [val-Some]
) : s2exp
//
val () =
(fprint_string(out, "extern\nfun{}\n"))
//
val () =
(fprint_string(out, tnm); fprint_string(out, fnm); fprint_string(out, "_"); $LAB.fprint_label(out, l0)) (* fprint! *)
val () =
absrec_emit_tydef_uni(out, s2def)
//
val () =
(fprint_string(out, " : absrec_"); fprint_string(out, fnm); fprint_string(out, "_fun_"))
//
val
islin = s2rt_is_lin_fun(s2t0)
val
isboxed = s2rt_is_boxed_fun(s2t0)
val () =
if
isboxed
then (
//
if ~islin
  then fprint_string(out, "type") else fprint_string(out, "vtype")
//
) (* end of [then] *)
else (
//
if ~islin
  then fprint_string(out, "t0ype") else fprint_string(out, "vt0ype")
//
) (* end of [else] *)
//
val () = fprint_string(out, "(")
//
val () =
(fprint_s2cst(out, s2c0))
val () =
absrec_emit_tydef_arg(out, s2def)
//
val () =
(fprint_string(out, ", "))
val () =
codegen2_emit_s2exp(out, s2e)
val () =
fprint_string(out, ")\n")
//
} (* end of [absrec_emit_decl] *)
//
(* ****** ****** *)
//
extern
fun
absrec_emit_tyrecfld
( out: FILEref
, s2c0: s2cst, tnm: string, ls2e: labs2exp
) : void // end of [absrec_emit_tyrecfld]
//
implement
absrec_emit_tyrecfld
(
  out, s2c0, tnm, ls2e
) = let
//
val l0 = labs2exp_lab(ls2e)
val s2e = labs2exp_elt(ls2e)
//
val
fld = absrecfld_of_s2exp(s2e)
//
fun
auxproc
(
  fld: absrecfld
) : void = let
//
val s2e = fld.1
//

//
in
//
case+ fld.0 of
//
| ABSRECFLDget() =>
  {
    val () = absrec_emit_decl(out, s2c0, tnm, l0, "get", s2e)
    val () =
    (fprint_string(out, "overload "); fprint_string(out, "."); $LAB.fprint_label(out, l0); fprint_string(out, " with "); fprint_string(out, tnm); fprint_string(out, "get_"); $LAB.fprint_label(out, l0); fprint_string(out, "\n"))
    val ((*void*)) = fprint_newline(out)
  }
//
| ABSRECFLDset() =>
  {
    val () = absrec_emit_decl(out, s2c0, tnm, l0, "set", s2e)
    val () =
    (fprint_string(out, "overload "); fprint_string(out, "."); $LAB.fprint_label(out, l0); fprint_string(out, " with "); fprint_string(out, tnm); fprint_string(out, "set_"); $LAB.fprint_label(out, l0); fprint_string(out, "\n"))
    val ((*void*)) = fprint_newline(out)
  }
//
| ABSRECFLDgetset() =>
  {
    val () =
    absrec_emit_decl(out, s2c0, tnm, l0, "get", s2e)
    val () =
    (fprint_string(out, "overload "); fprint_string(out, "."); $LAB.fprint_label(out, l0); fprint_string(out, " with "); fprint_string(out, tnm); fprint_string(out, "get_"); $LAB.fprint_label(out, l0); fprint_string(out, "\n"))
    val () =
    absrec_emit_decl(out, s2c0, tnm, l0, "set", s2e)
    val () =
    (fprint_string(out, "overload "); fprint_string(out, "."); $LAB.fprint_label(out, l0); fprint_string(out, " with "); fprint_string(out, tnm); fprint_string(out, "set_"); $LAB.fprint_label(out, l0); fprint_string(out, "\n"))
    val ((*void*)) = fprint_newline(out)
  }
//
| ABSRECFLDexch() =>
  {
    val () = absrec_emit_decl(out, s2c0, tnm, l0, "exec", s2e)
    val ((*void*)) = fprint_newline(out)
  }
//
| ABSRECFLDgetref() =>
  {
    val () = absrec_emit_decl(out, s2c0, tnm, l0, "getref", s2e)
    val ((*void*)) = fprint_newline(out)
  }
//
| _(*rest-of-absrecfld*) => ()
//
end // end of [auxproc]
//
in
//
  auxproc(fld)
//
end (* end of [absrec_emit_tyrecfld] *)
//
(* ****** ****** *)
//
extern
fun
absrec_emit_tyrecfldlst
( out: FILEref
, s2c0: s2cst, tnm: string, ls2es: labs2explst
) : void // end of [absrec_emit_tyrecfldlst]
//
implement
absrec_emit_tyrecfldlst
(
  out, s2c0, tnm, ls2es
) = (
//
case+ glist_view(ls2es) of
| ~GLnil() => ()
| ~GLcons(ls2e, ls2es) =>
  {
    val () = absrec_emit_tyrecfld(out, s2c0, tnm, ls2e)
    val () = absrec_emit_tyrecfldlst(out, s2c0, tnm, ls2es)
  } (* end of [list_cons] *)
//
) (* end of [absrec_emit_tyrecfldlst] *)
//
(* ****** ****** *)
//
extern
fun
absrec_s2cst_get_tyrec
(
  s2c0: s2cst
) : s2expopt_vt
//
implement
absrec_s2cst_get_tyrec
  (s2c0) = let
//
fun
auxget
(
  s2e0: s2exp
) : s2expopt_vt = let
//
(*
val () =
print!("absrec_s2cst_get_tyrec")
val () =
println!(": auxget: s2e0 = ", s2e0)
*)
//
in
//
case+
s2exp_node_view(s2e0.s2exp_node())
of // case+
| ~S2Etyrec(_, _, _) => Some_vt(s2e0)
| ~S2Elam(s2vs, s2e) => auxget(s2e)
(*
| S2Eexi(s2vs, s2ps, s2e) => auxget(s2e)
*)
| v(*rest-of-s2exp*) => (s2exp_node_view_free(v); None_vt(*void*))
//
end // end of [auxget]
//
val s2e0 =
(
case+ gopt_view(s2cst_get_def(s2c0)) of
| ~GOsome(s2e0) => s2e0
| ~GOnone() => (assertloc(false); $UN.cast{s2exp}(the_null_ptr)) // HX: the MatchError of [val-Some]
) : s2exp
//
in
  auxget(s2e0)
end // end of [absrec_s2cst_get_tyrec]

(* ****** ****** *)

local

fun
auxerr_nil
(
  out: FILEref, d2c0: d2ecl
) : void =  {
//
val loc0 = d2c0.d2ecl_loc()
//
val () = (fprint_string(out, "(*\n"))
//
val () =
($LOC.fprint_location(out, loc0); fprint_string(out, ": error(codegen2): absrec: no spec on typedef is given\n")) (* end of [val] *)
//
val () = (fprint_string(out, "*)"); fprint_newline(out))
//
} (* end of [auxerr_nil] *)

fun
auxerr_s2cst
(
  out: FILEref, d2c0: d2ecl
) : void = {
//
val loc0 = d2c0.d2ecl_loc()
//
val () = (fprint_string(out, "(*\n"))
//
val () =
($LOC.fprint_location(out, loc0); fprint_string(out, ": error(codegen2): absrec: no typedef of the given spec\n")) (* end of [val] *)
//
val () = (fprint_string(out, "*)"); fprint_newline(out))
//
} (* end of [auxerr_s2cst] *)

fun
auxerr_s2cst_tyrec
(
  out: FILEref, d2c0: d2ecl, s2c: s2cst
) : void = {
//
val loc0 = d2c0.d2ecl_loc()
//
val () = (fprint_string(out, "(*\n"))
//
val () =
($LOC.fprint_location(out, loc0); fprint_string(out, ": error(codegen2): absrec: ["); fprint_s2cst(out, s2c); fprint_string(out, "] does not refer to a record\n")) (* end of [val] *)
//
val () = (fprint_string(out, "*)"); fprint_newline(out))
//
} (* end of [auxerr_s2cst_tyrec] *)

fun
aux_tydef
(
  out: FILEref
, d2c0: d2ecl
, s2c0: s2cst, xs: e1xplst
) : void = let
//
(*
val () =
println! (
//
"codegen2_absrec: aux_tydef: s2c0 = ", s2c0
//
) (* println! *)
*)
//
val opt =
  absrec_s2cst_get_tyrec(s2c0)
//
in
//
case+ opt of
| ~None_vt() =>
    auxerr_s2cst_tyrec(out, d2c0, s2c0)
| ~Some_vt(s2rec) =>
    aux_tydef_tyrec(out, d2c0, s2c0, s2rec, xs)
//
end (* end of [aux_tydef] *)

and
aux_tydef_tyrec
(
  out: FILEref
, d0c0: d2ecl
, s2c0: s2cst
, s2rec: s2exp, xs: e1xplst
) : void = let
//
(*
val () =
println!
(
  "codegen2_absrec: aux_tydef_tyrec: s2rec = ", s2rec
) (* println! *)
*)
//
val tnm =
(
//
case+ glist_view(xs) of
| ~GLnil() =>
    s2cst_get_name(s2c0)
  // list_nil
| ~GLcons(x0, _) =>
  (
    case+
    e1xp_node_view(x0.e1xp_node())
    of // case+
    | ~E1XPide(id) =>
      $SYM.symbol_get_name(id)
      // E1XPide
    | ~E1XPstring(name) => name
    | v(*unrecogized*) =>
      (
        e1xp_node_view_free(v);
        let
          val tnm = string0_append(s2cst_get_name(s2c0), "_")
          val tnm2 = the_garena_strdup($UN.strptr2string(tnm))
        in
          strptr_free(tnm); tnm2
        end
      )
  )
//
) : string // end of [val]
//
val ls2es =
(
case+ s2exp_node_view(s2rec.s2exp_node()) of
| ~S2Etyrec(knd, npf, ls2es) => ls2es
| v => (s2exp_node_view_free(v); assertloc(false); glist_nil((*void*))) // HX: the MatchError of [val-S2Etyrec]
) : labs2explst
//
in
  absrec_emit_tyrecfldlst(out, s2c0, tnm, ls2es)
end // end of [aux_tydef_tyrec]

in (* in-of-local *)

implement
codegen2_absrec
  (out, d2c0, xs) = let
//
(*
val () =
println!
  ("codegen2_absrec: d2c0 = ", d2c0)
*)
//
in
//
case+ glist_view(xs) of
| ~GLnil() =>
    auxerr_nil(out, d2c0)
  // end of [list_nil]
| ~GLcons(x, xs) => let
    val opt = codegen2_get_tydef(x)
  in
    case+ opt of
    | ~None_vt() => auxerr_s2cst(out, d2c0)
    | ~Some_vt(s2c) => aux_tydef(out, d2c0, s2c, xs)
  end // end of [list_cons]
//
end // end of [codegen2_absrec]

end // end of [local]

(* ****** ****** *)

(* end of [pats_codegen2_absrec.dats] *)
