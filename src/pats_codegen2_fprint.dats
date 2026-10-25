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
// Start Time: August, 2015
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_codegen2_fprint.dats, see PORTING.md, "Codegen2")
// The local closures are lambda-lifted (nested [fun]s), [fprint!] is a sequence of explicit calls.
//
(* ****** ****** *)

#include "share/atspre_staload.hats"
#include "./pats_assert.hats"

(* ****** ****** *)
//
staload
UN =
"prelude/SATS/unsafe.sats"
//
(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)
//
staload
LOC = "./pats_location.sats"
//
(* ****** ****** *)

staload SYM = "./pats_symbol.sats"

(* ****** ****** *)
//
staload "./pats_staexp1.sats"
//
(* ****** ****** *)
//
staload "./pats_staexp2.sats"
staload "./pats_dynexp2.sats"
//
staload "./pats_trans2_env.sats"
//
(* ****** ****** *)

staload "./pats_codegen2.sats"

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
($LOC.fprint_location(out, loc0); fprint_string(out, ": error(codegen2): no spec on datatype is given\n")) (* end of [val] *)
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
($LOC.fprint_location(out, loc0); fprint_string(out, ": error(codegen2): no datatype of the given spec\n")) (* end of [val] *)
//
val () = (fprint_string(out, "*)"); fprint_newline(out))
//
} (* end of [auxerr_s2cst] *)

fun
auxerr_d2cst
(
  out: FILEref, d2c0: d2ecl, s2dat: s2cst
) : void = {
//
val loc0 = d2c0.d2ecl_loc()
//
val () = (fprint_string(out, "(*\n"))
//
val () =
($LOC.fprint_location(out, loc0); fprint_string(out, ": error(codegen2): no fprint-function of the given spec\n")) (* end of [val] *)
//
val () = (fprint_string(out, "*)"); fprint_newline(out))
//
} (* end of [auxerr_d2cst] *)

fun
aux_datype
(
  out: FILEref
, d2c0: d2ecl, s2dat: s2cst, xs: e1xplst
) : void = let
//
fun
auxfun1
(
  s2dat: s2cst
) : Option_vt(d2cst) = let
//
val sym = s2cst_get_sym(s2dat)
val name = $SYM.symbol_get_name(sym)
val d2cf = string0_append3("fprint_", name, "_")
val d2cf = let
  val sym = $SYM.symbol_make_string($UN.strptr2string(d2cf))
in
  strptr_free(d2cf); sym
end
//
in
//
case+
the_d2expenv_find(d2cf)
of // case+
| ~None_vt() => None_vt()
| ~Some_vt(d2i) =>
  (
    case+ d2itm_view(d2i) of
    | ~D2ITMcst(d2cf) => Some_vt(d2cf)
    | v => (d2itm_view_free(v); None_vt())
  ) (* end of [Some_vt] *)
//
end // end of [auxfun1]
//
fun
auxfun2
(
  s2dat: s2cst, xs: e1xplst
) : Option_vt(d2cst) =
(
case+ glist_view(xs) of
| ~GLnil() => auxfun1(s2dat)
| ~GLcons(x, _) => codegen2_get_d2cst(x)
)
//
val opt = auxfun2(s2dat, xs)
val xs2 =
(
  case+ glist_view(xs) of
  | ~GLnil() => xs | ~GLcons(_, xs) => xs
) : e1xplst // end of [val]
//
//
in
//
case+ opt of
| ~None_vt() =>
    auxerr_d2cst(out, d2c0, s2dat)
  // end of [None_vt]
| ~Some_vt(d2cf) =>
    aux_datype_d2cf(out, d2c0, s2dat, d2cf, xs2)
  // end of [Some_vt]
//
end (* end of [aux_datype] *)

and
aux_datype_d2cf
(
  out: FILEref
, d2c0: d2ecl, s2dat: s2cst, d2cf: d2cst, xs: e1xplst
) : void = let
//
val
linesep =
"(* ****** ****** *)"
//
val
fname = d2cst_get_name(d2cf)
//
fun
auxd2c_dec
(
  d2c: d2con
) : void = let
//
val cname = d2con_get_name(d2c)
//
val () =
fprint_string(out, "extern\nfun")
val () =
codegen2_emit_tmpcstdec(out, d2cf)
val () = fprint_string(out, "\n")
val () =
(fprint_string(out, fname); fprint_string(out, "$"); fprint_string(out, cname))
val () =
(fprint_string(out, ": $d2ctype("); fprint_string(out, fname))
val () = codegen2_emit_tmpcstapp(out, d2cf)
val ((*closing*)) = (fprint_string(out, ")"); fprint_newline(out))
//
in
  // nothing
end // end of [auxd2c_dec]
//
fun
auxd2cs_dec
(
  d2cs: d2conlst
) : void =
(
case+ glist_view(d2cs) of
| ~GLnil() => ()
| ~GLcons(d2c, d2cs) =>
  let val () = auxd2c_dec(d2c) in auxd2cs_dec(d2cs) end
)
//
fun
auxd2c_cla
(
  d2c: d2con
) : void = let
//
val cname = d2con_get_name(d2c)
//
val () =
(fprint_string(out, "| "); fprint_string(out, cname); fprint_string(out, " _ => "))
//
val () = (fprint_string(out, fname); fprint_string(out, "$"); fprint_string(out, cname))
val () = codegen2_emit_tmpcstapp(out, d2cf)
val () = (fprint_string(out, "(out, arg0)"); fprint_newline(out))
//
in
  // nothing
end // end of [auxd2c_cla]
//
fun
auxd2cs_cla
(
  d2cs: d2conlst
) : void =
(
case+ glist_view(d2cs) of
| ~GLnil() => ()
| ~GLcons(d2c, d2cs) =>
  let val () = auxd2c_cla(d2c) in auxd2cs_cla(d2cs) end
)
//
fun
auxsep
(
// argless
) : void =
{
//
val () =
(fprint_string(out, "//\nextern\nfun{}\n")) (* end of [val] *)
val () =
(fprint_string(out, fname); fprint_string(out, "$sep: (FILEref) -> void"); fprint_newline(out))
val () =
(fprint_string(out, "implement{}\n"))
val () =
(fprint_string(out, fname); fprint_string(out, "$sep(out) = fprint(out, \",\")"); fprint_newline(out))
//
} (* end of [auxsep] *)
//
fun
auxcarg
(
// argless
) : void =
{
//
val () =
(fprint_string(out, "//\nextern\nfun{a:t0p}\n")) (* end of [val] *)
val () =
(fprint_string(out, fname); fprint_string(out, "$carg: (FILEref, INV(a)) -> void"); fprint_newline(out))
val () =
(fprint_string(out, "implement{a}\n"))
val () =
(fprint_string(out, fname); fprint_string(out, "$carg(out, arg) = fprint_val<a>(out, arg)"); fprint_newline(out))
//
} (* end of [auxcarg] *)
//
fun
auxlpar
(
// argless
) : void =
{
//
val () =
(fprint_string(out, "//\nextern\nfun{}\n")) (* end of [val] *)
val () =
(fprint_string(out, fname); fprint_string(out, "$lpar: (FILEref) -> void"); fprint_newline(out))
val () =
(fprint_string(out, "implement{}\n"))
val () =
(fprint_string(out, fname); fprint_string(out, "$lpar(out) = fprint(out, \"(\")"); fprint_newline(out))
//
} (* end of [auxlpar] *)
fun
auxrpar
(
// argless
) : void =
{
//
val () =
(fprint_string(out, "//\nextern\nfun{}\n")) (* end of [val] *)
val () =
(fprint_string(out, fname); fprint_string(out, "$rpar: (FILEref) -> void"); fprint_newline(out))
val () =
(fprint_string(out, "implement{}\n"))
val () =
(fprint_string(out, fname); fprint_string(out, "$rpar(out) = fprint(out, \")\")"); fprint_newline(out))
//
} (* end of [auxrpar] *)
//
val d2cs =
(
case+ gopt_view(s2cst_get_dconlst(s2dat)) of
| ~GOsome(d2cs) => d2cs
| ~GOnone() => (assertloc(false); glist_nil((*void*))) // HX: the MatchError of [val-Some]
) : d2conlst
//
val () =
(fprint_string(out, linesep); fprint_string(out, "\n//\n"))
//
val () = auxd2cs_dec (d2cs)
//
val () =
(fprint_string(out, "//\n"); fprint_string(out, linesep); fprint_string(out, "\n//\n"))
//
val () = fprint_string(out, "implement")
val () = codegen2_emit_tmpcstimp(out, d2cf)
val () = (fprint_newline(out))
//
val () =
(fprint_string(out, fname))
//
val () =
(fprint_string(out, "\n  "))
val () =
(fprint_string(out, "(out, arg0) ="); fprint_newline(out))
//
val () =
(fprint_string(out, "(\n"))
val () =
(fprint_string(out, "case+ arg0 of"); fprint_newline(out))
//
val () = auxd2cs_cla (d2cs) // clauses
//
val () = (fprint_string(out, ")\n"))
val () = (fprint_string(out, "//\n"); fprint_string(out, linesep); fprint_newline(out))
//
val () = auxsep ()
val () = auxlpar ()
val () = auxrpar ()
val () = auxcarg ()
//
val () = (fprint_string(out, "//\n"); fprint_string(out, linesep); fprint_newline(out))
//
val () =
aux_datype_d2cf_conlst(out, d2c0, s2dat, d2cf, d2cs)
//
val () = (fprint_string(out, "//\n"); fprint_string(out, linesep); fprint_newline(out))
//
in
  // nothing
end // end of [aux_datype_d2cf]

and
aux_datype_d2cf_con
(
  out: FILEref
, d2c0: d2ecl, s2dat: s2cst, d2cf: d2cst, d2cn: d2con
) : void = let
//
val
fname = d2cst_get_name(d2cf)
//
val
ftype = d2cst_get_type(d2cf)
//
val
cname = d2con_get_name(d2cn)
//
val narg = d2con_get_arity_real(d2cn)
//
fun
auxcon1
(
// argless
) : void =
{
//
val () =
fprint_string(out, "extern\nfun")
val () =
codegen2_emit_tmpcstdec(out, d2cf)
val () = fprint_string(out, "\n")
val () =
(fprint_string(out, fname); fprint_string(out, "$"); fprint_string(out, cname); fprint_string(out, "$con"))
val () =
(fprint_string(out, ": $d2ctype("); fprint_string(out, fname))
val () = codegen2_emit_tmpcstapp(out, d2cf)
val ((*closing*)) = (fprint_string(out, ")"); fprint_newline(out))
//
}
//
fun
auxlpar1
(
// argless
) : void =
{
//
val () =
fprint_string(out, "extern\nfun")
val () =
codegen2_emit_tmpcstdec(out, d2cf)
val () = fprint_string(out, "\n")
val () =
(fprint_string(out, fname); fprint_string(out, "$"); fprint_string(out, cname); fprint_string(out, "$lpar"))
val () =
(fprint_string(out, ": $d2ctype("); fprint_string(out, fname))
val () = codegen2_emit_tmpcstapp(out, d2cf)
val ((*closing*)) = (fprint_string(out, ")"); fprint_newline(out))
//
}
//
fun
auxrpar1
(
// argless
) : void =
{
//
val () =
fprint_string(out, "extern\nfun")
val () =
codegen2_emit_tmpcstdec(out, d2cf)
val () = fprint_string(out, "\n")
val () =
(fprint_string(out, fname); fprint_string(out, "$"); fprint_string(out, cname); fprint_string(out, "$rpar"))
val () =
(fprint_string(out, ": $d2ctype("); fprint_string(out, fname))
val () = codegen2_emit_tmpcstapp(out, d2cf)
val ((*closing*)) = (fprint_string(out, ")"); fprint_newline(out))
//
}
//
fun
auxsep1_n
(
  n: int
) : void =
{
//
val () =
fprint_string(out, "extern\nfun")
val () =
codegen2_emit_tmpcstdec(out, d2cf)
val () = fprint_string(out, "\n")
val () =
(fprint_string(out, fname); fprint_string(out, "$"); fprint_string(out, cname); fprint_string(out, "$sep"); fprint_int(out, n)) (* fprint! *)
//
val () =
(fprint_string(out, ": $d2ctype("); fprint_string(out, fname))
val () = codegen2_emit_tmpcstapp(out, d2cf)
val ((*closing*)) = (fprint_string(out, ")"); fprint_newline(out))
//
}
//
fun
auxarg1_n
(
  n: int
) : void =
{
//
val () =
fprint_string(out, "extern\nfun")
val () =
codegen2_emit_tmpcstdec(out, d2cf)
val () = fprint_string(out, "\n")
val () =
(fprint_string(out, fname); fprint_string(out, "$"); fprint_string(out, cname); fprint_string(out, "$arg"); fprint_int(out, n))
val () =
(fprint_string(out, ": $d2ctype("); fprint_string(out, fname))
val () = codegen2_emit_tmpcstapp(out, d2cf)
val ((*closing*)) = (fprint_string(out, ")"); fprint_newline(out))
//
}
//
fun
auxcon2
(
// argless
) : void =
{
//
val () =
(fprint_string(out, "val () = "))
val () =
(fprint_string(out, fname); fprint_string(out, "$"); fprint_string(out, cname); fprint_string(out, "$con"))
val () = codegen2_emit_tmpcstapp(out, d2cf)
val () = (fprint_string(out, "(out, arg0)"); fprint_newline(out))
//
}
fun
auxlpar2
(
// argless
) : void =
{
//
val () =
(fprint_string(out, "val () = "))
val () =
(fprint_string(out, fname); fprint_string(out, "$"); fprint_string(out, cname); fprint_string(out, "$lpar"))
//
val () = codegen2_emit_tmpcstapp(out, d2cf)
val () = (fprint_string(out, "(out, arg0)"); fprint_newline(out))
//
}
//
fun
auxrpar2
(
// argless
) : void =
{
//
val () =
(fprint_string(out, "val () = "))
val () =
(fprint_string(out, fname); fprint_string(out, "$"); fprint_string(out, cname); fprint_string(out, "$rpar"))
//
val () = codegen2_emit_tmpcstapp(out, d2cf)
val () = (fprint_string(out, "(out, arg0)"); fprint_newline(out))
//
}
//
fun
auxsep2_n
(
  n: int
) : void =
{
//
val () =
(fprint_string(out, "val () = "))
val () =
(fprint_string(out, fname); fprint_string(out, "$"); fprint_string(out, cname); fprint_string(out, "$sep"); fprint_int(out, n))
//
val () = codegen2_emit_tmpcstapp(out, d2cf)
val () = (fprint_string(out, "(out, arg0)"); fprint_newline(out))
//
}
fun
auxarg2_n
(
  n: int
) : void =
{
//
val () =
(fprint_string(out, "val () = "))
val () =
(fprint_string(out, fname); fprint_string(out, "$"); fprint_string(out, cname); fprint_string(out, "$arg"); fprint_int(out, n))
//
val () = codegen2_emit_tmpcstapp(out, d2cf)
val () = (fprint_string(out, "(out, arg0)"); fprint_newline(out))
//
}
//
fun
auxbody2
(
  n0: int, n: int
) : void =
(
//
if
n < narg
then let
  val () =
  if n > n0
    then auxsep2_n(n)
  // end of [val]
  val () = auxarg2_n(n+1)
in
  auxbody2(n0, n+1)
end // end of [then]
else () // end of [else]
//
) (* end of [auxbody2] *)
//
fun
auxcon3
(
// argless
) : void =
{
//
val () =
fprint_string(out, "implement")
val () =
codegen2_emit_tmpcstimp(out, d2cf)
val () = (fprint_newline(out))
//
val () =
(fprint_string(out, fname); fprint_string(out, "$"); fprint_string(out, cname); fprint_string(out, "$con(out, _) = "))
val () =
(fprint_string(out, "fprint(out, \""); fprint_string(out, cname); fprint_string(out, "\")"); fprint_newline(out))
//
} (* end of [auxcon3] *)
//
fun
auxlpar3
(
// argless
) : void =
{
//
val () =
fprint_string(out, "implement")
val () =
codegen2_emit_tmpcstimp(out, d2cf)
val () = (fprint_newline(out))
val () =
(fprint_string(out, fname); fprint_string(out, "$"); fprint_string(out, cname); fprint_string(out, "$lpar(out, _) = "); fprint_string(out, fname); fprint_string(out, "$lpar(out)"); fprint_newline(out))
//
} (* end of [auxlpar3] *)
//
fun
auxrpar3
(
// argless
) : void =
{
//
val () =
fprint_string(out, "implement")
val () =
codegen2_emit_tmpcstimp(out, d2cf)
val () = (fprint_newline(out))
val () =
(fprint_string(out, fname); fprint_string(out, "$"); fprint_string(out, cname); fprint_string(out, "$rpar(out, _) = "); fprint_string(out, fname); fprint_string(out, "$rpar(out)"); fprint_newline(out))
//
} (* end of [auxrpar3] *)
//
fun
auxsep3_n
(
  n: int
) : void =
{
//
val () =
fprint_string(out, "implement")
val () =
codegen2_emit_tmpcstimp(out, d2cf)
val () = (fprint_newline(out))
val () =
(fprint_string(out, fname); fprint_string(out, "$"); fprint_string(out, cname); fprint_string(out, "$sep"); fprint_int(out, n); fprint_string(out, "(out, _) = "); fprint_string(out, fname); fprint_string(out, "$sep<>(out)"); fprint_newline(out))
//
} (* end of [auxsep3_n] *)
//
fun
auxpat3_n
(
  n: int
) : void = let
//
fun
aux(i: int) : void =
(
if
(i <= narg)
then let
  val () =
  if i > 1
    then fprint_string(out, ", ")
  // end of [val]
  val () =
  if (i = n)
    then (fprint_string(out, "arg"); fprint_int(out, n))
  // end of [val]
  val () =
  if (i != n) then fprint_string(out, "_")
in
  aux(i+1)
end // end of [then]
else () // end of [else]
)
//
in
  (fprint_string(out, cname); fprint_string(out, "(")); aux(1); fprint_string(out, ")")
end // end of [auxpat3_n]
//
fun
auxarg3_n
(
  n: int
) : void =
{
//
val () =
fprint_string(out, "implement")
val () =
codegen2_emit_tmpcstimp(out, d2cf)
val () = (fprint_newline(out))
val () =
(fprint_string(out, fname); fprint_string(out, "$"); fprint_string(out, cname); fprint_string(out, "$arg"); fprint_int(out, n); fprint_string(out, "(out, arg0) ="); fprint_newline(out))
//
val () =
fprint
  (out, "  let val-")
//
val () = auxpat3_n(n)
//
val () =
(fprint_string(out, " = arg0 in "); fprint_string(out, fname); fprint_string(out, "$carg(out, arg"); fprint_int(out, n); fprint_string(out, ") end"); fprint_newline(out))
//
} (* end of [auxarg3_n] *)
//
val () =
fprint_string(out, "//\n")
//
val () = auxcon1()
val () = auxlpar1()
val () = auxrpar1()
val () = loop(1) where
{
  fun loop(n: int) : void = if n < narg then (auxsep1_n(n); loop(n+1))
}
val () = loop(1) where
{
  fun loop(n: int) : void = if n <= narg then (auxarg1_n(n); loop(n+1))
}
//
val () =
fprint_string(out, "//\n")
//
val () =
fprint_string(out, "implement")
val () =
codegen2_emit_tmpcstimp(out, d2cf)
val () = (fprint_newline(out))
//
val () =
(fprint_string(out, fname); fprint_string(out, "$"); fprint_string(out, cname); fprint_string(out, "(out, arg0) = "); fprint_newline(out))
//
val () = (fprint_string(out, "{\n//"); fprint_newline(out))
val () = auxcon2()
val () = auxlpar2()
val () = auxbody2(0, 0)
val () = auxrpar2()
val () = (fprint_string(out, "//\n}"); fprint_newline(out))
//
val () = auxcon3()
val () = auxlpar3()
val () = auxrpar3()
val () = loop(1) where
{
  fun loop(n: int) : void = if n < narg then (auxsep3_n(n); loop(n+1))
}
val () = loop(1) where
{
  fun loop(n: int) : void = if n <= narg then (auxarg3_n(n); loop(n+1))
}
//
in
  // nothing
end // end of [aux_datype_d2cf_con]

and
aux_datype_d2cf_conlst
(
  out: FILEref
, d2c0: d2ecl, s2dat: s2cst, d2cf: d2cst, xs: d2conlst
) : void =
(
case+ glist_view(xs) of
| ~GLnil() => ()
| ~GLcons(x, xs) =>
  {
    val () = aux_datype_d2cf_con(out, d2c0, s2dat, d2cf, x)
    val () = aux_datype_d2cf_conlst(out, d2c0, s2dat, d2cf, xs)
  }
) (* end of [aux_datype_d2cf_conlst] *)

in (* in-of-local *)

implement
codegen2_fprint
  (out, d2c0, xs) = let
//
(*
val () =
println!
  ("codegen2_fprint: d2c0 = ", d2c0)
*)
//
in
//
case+ glist_view(xs) of
| ~GLnil() =>
    auxerr_nil(out, d2c0)
  // end of [list_nil]
| ~GLcons(x, xs) => let
    val opt = codegen2_get_datype(x)
  in
    case+ opt of
    | ~None_vt() => auxerr_s2cst(out, d2c0)
    | ~Some_vt(s2c) => aux_datype(out, d2c0, s2c, xs)
  end // end of [list_cons]
//
end // end of [codegen2_fprint]

end // end of [local]

(* ****** ****** *)

(* end of [pats_codegen2_fprint.dats] *)
