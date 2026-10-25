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
// Start Time: January, 2013
// Authoremail: gmhwxiATgmailDOTcom
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_ccomp_emit3.dats, see PORTING.md, "ccomp group A (emit)")
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)
//
staload
UN =
"prelude/SATS/unsafe.sats"
//
staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"
//
(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)
//
staload
"./pats_errmsg.sats"
staload
_(*anon*) = "./pats_errmsg.dats"
//
implement
prerr_FILENAME<> () = prerr "pats_ccomp_emit2"
//
(* ****** ****** *)
//
staload
ERR = "./pats_error.sats"
//
staload
FIL = "./pats_filename.sats"
staload
LOC = "./pats_location.sats"
//
(* ****** ****** *)

staload SYM = "./pats_symbol.sats"
staload SYN = "./pats_syntax.sats"

(* ****** ****** *)

staload "./pats_avlmap.sats"
staload "./pats_staexp2.sats"

(* ****** ****** *)

staload "./pats_dynexp2.sats"
overload = with eq_d2cst_d2cst
overload != with neq_d2cst_d2cst

(* ****** ****** *)

staload
TR2ENV = "./pats_trans2_env.sats"

(* ****** ****** *)

staload "./pats_histaexp.sats"
staload "./pats_hidynexp.sats"

(* ****** ****** *)

staload "./pats_ccomp.sats"

(* ****** ****** *)

implement
emit_exndec
  (out, hid) = let
//
val
loc0 = hid.hidecl_loc ()
val-~
HIDexndecs(d2cs) = hidecl_node_view (hid.hidecl_node ())
//
val () = emit_text(out, "/*\n")
val () = emit_location(out, loc0)
val () = emit_text(out, "\n*/\n")
//
fun
auxlst
(
  out: FILEref, d2cs: d2conlst
) : void = let
in
//
if glist_is_cons (d2cs) then let
//
    val d2c = glist_head<d2con> (d2cs)
    val d2cs = glist_tail<d2con> (d2cs)
//
    val () =
    emit_text
    (out, "ATSdynexn_dec(")
    val () = emit_d2con(out, d2c)
    val () = emit_text(out, ") ;\n")
//
  in
    auxlst(out, d2cs)
  end // end of [list_cons]
else () // end of [list_nil]
//
end (* end of [auxlst] *)
//
in
  auxlst(out, d2cs)
end // end of [emit_exndec]

(* ****** ****** *)

implement
emit_saspdec
  (out, hid) = let
//
val loc0 = hid.hidecl_loc ()
val-~HIDsaspdec (d2c) = hidecl_node_view (hid.hidecl_node ())
//
val () = emit_text (out, "/*\n")
val () = emit_location (out, loc0)
val () = emit_text (out, "\n*/\n")
//
val () = emit_text (out, "ATSassume(")
val () = emit_s2cst (out, d2c.s2aspdec_cst ())
val () = emit_text (out, ") ;\n")
//
in
  // nothing
end // end of [emit_saspdec]

(* ****** ****** *)

implement
emit_extype
  (out, hid) = let
//
val loc0 = hid.hidecl_loc ()
//
val-~HIDextype
  (name, hse_def) = hidecl_node_view (hid.hidecl_node ())
//
val () = emit_text (out, "/*\n")
val () = emit_location (out, loc0)
val () = emit_text (out, "\n*/\n")
//
in
//
if
hisexp_node_is_HSEtysum (hse_def.hisexp_node ())
then {
//
    val () =
    emit_text (out, "typedef\n")
    val () =
    emit_hisexp_sel (out, hse_def)
    val () = emit_text (out, "\n")
    val () = emit_text (out, name)
    val () = emit_text (out, "_")
    val () = emit_text (out, " ;\n")
//
    val () =
    emit_text (out, "typedef\n")
    val () = emit_text (out, name)
    val () = emit_text (out, "_ *")
    val () = emit_text (out, name)
    val () = emit_text (out, " ;\n")
//
  } (* end of [HSEtysum] *)
//
else {
    val () =
    emit_text (out, "typedef\n")
    val () = emit_hisexp (out, hse_def)
    val () = emit_text (out, "\n")
    val () = emit_text (out, name)
    val () = emit_text (out, " ;\n")
  } (* end of [non-tysum] *)
//
end // end of [emit_extype]

(* ****** ****** *)

implement
emit_extcode
  (out, hid) = let
//
val loc0 = hid.hidecl_loc ()
val-~HIDextcode (knd, pos, code) = hidecl_node_view (hid.hidecl_node ())
//
val () = emit_text (out, "/*\n")
val () = emit_location (out, loc0)
val () = emit_text (out, "\n*/")
val () = emit_text (out, "\nATSextcode_beg()")
val () = emit_text (out, code)
val () = emit_text (out, "ATSextcode_end()\n")
//
in
  // nothing
end // end of [emit_extcode]

(* ****** ****** *)

local

fun
auxloc
(
  out: FILEref, loc: $LOC.location
) : void = let
  val () = emit_text (out, "/*\n")
  val () = emit_location (out, loc)
  val () = emit_text (out, "\n*/\n")
in
  // nothing
end // end of [auxloc]

fun
auxsta
(
  out: FILEref, d2cs: d2eclist
) : void = let
//
in
//
if glist_is_cons (d2cs) then let
    val d2c = glist_head<d2ecl> (d2cs)
    val d2cs = glist_tail<d2ecl> (d2cs)
    val () =
    (
    case+
    d2ecl_node_view (d2c.d2ecl_node ())
    of // case+
//
    | ~D2Cextcode
        (knd, pos, code) =>
      (
//
      if
      (pos = 0) // %{#
      then let
        val loc = d2c.d2ecl_loc ()
      in
        auxloc(out, loc); emit_text(out, code)
      end // end of [then] // end of [if]
//
      ) (* end of [D2Cextcode] *)
//
    | ~D2Cstaload
      (
        idopt
      , fil, flag, fenv, _(*loaded*)
      ) => let
        val d2cs =
          $TR2ENV.filenv_get_d2eclist(fenv)
        val issta =
          $FIL.filename_is_sats(fil)
      in
        if issta then auxsta(out, d2cs) else ((*void*))
      end // end of [D2Cstaload]
//
    | v (* rest-of-d2ecl *) => d2ecl_node_view_free (v) // skipped
//
    ) : void // end of [val]
  in
    auxsta(out, d2cs)
  end // end of [list_cons]
else () // end of [list_nil]
//
end // end of [auxsta]

fun
auxdyn
(
  out: FILEref, d2cs: d2eclist
) : void = let
in
//
if glist_is_cons (d2cs) then let
    val d2c = glist_head<d2ecl> (d2cs)
    val d2cs = glist_tail<d2ecl> (d2cs)
    val () =
    (
    case+
    d2ecl_node_view (d2c.d2ecl_node ())
    of // case+
//
    | ~D2Cextcode
        (knd, pos, code) =>
      (
//
      if
      (pos = 0) // %{#
      then let
        val loc = d2c.d2ecl_loc ()
      in
        auxloc(out, loc); emit_text(out, code)
      end // end of [then] // end of [if]
//
      ) (* end of [D2Cextcode] *)
//
    | ~D2Cstaload
      (
        idopt
      , fil, flag, fenv, loaded
      ) => let
        val d2cs =
          $TR2ENV.filenv_get_d2eclist(fenv)
        val issta =
          $FIL.filename_is_sats(fil)
      in
        if issta
          then auxsta(out, d2cs) else auxdyn(out, d2cs)
        // end of [if]
      end // end of [D2Cstaload]
//
    | ~D2Clocal
      (
        d2cs_head, d2cs_body
      ) =>
      (
        auxdyn(out, d2cs_head); auxdyn(out, d2cs_body)
      ) // end of [D2Clocal]
//
    | ~D2Cinclude
        (knd, d2cs) =>
      (
        if knd = 0
          then auxsta(out, d2cs) else auxdyn(out, d2cs)
        // end of [if]
      ) (* end of [D2Cinclude] *)
    | v (* rest-of-d2ecl *) => d2ecl_node_view_free (v) // skipped
//
    ) : void // end of [val]
//
  in
    auxdyn(out, d2cs)
  end // end of [list_cons]
else () // end of [list_nil]
//
end // end of [auxdyn]

in (* in of [local] *)

implement
emit_staload
  (out, hid) = let
//
val-~HIDstaload
(
  idopt, fil, flag, fenv, loaded
) = hidecl_node_view (hid.hidecl_node ()) // end-of-val
val d2cs =
  $TR2ENV.filenv_get_d2eclist(fenv)
//
val issta = $FIL.filename_is_sats(fil)
//
in
  if issta then auxsta(out, d2cs) else auxdyn(out, d2cs)
end // end of [emit_staload]

end // end of [local]

(* ****** ****** *)
//
extern
fun
emit_tmprimval(out: FILEref, tpmv: tmprimval): void
extern
fun
emit_tmpmovlst(out: FILEref, tmvlst: tmpmovlst): void
//
(* ****** ****** *)

implement
emit_tmprimval (out, tpmv) =
(
case+ tmprimval_view (tpmv) of
| ~TPMVnone (pmv) => emit_primval (out, pmv)
| ~TPMVsome (tmp, _) => emit_tmpvar (out, tmp)
) (* end of [emit_tmprimval] *)

(* ****** ****** *)

implement
emit_tmpmovlst (out, tmvlst) = let
//
fun auxlst
(
  out: FILEref, i: int, xs: tmpmovlst
) : void = let
in
//
if glist_is_cons (xs) then let
    val x = glist_head<tmpmov> (xs)
    val xs = glist_tail<tmpmov> (xs)
    val () =
    emit_text (out, "ATSINSmove(")
    val () = emit_tmpvar (out, x.tmpmov_dst ())
    val () = emit_text (out, ", ")
    val () = emit_tmprimval (out, x.tmpmov_src ())
    val () = emit_text (out, ") ; ")
  in
    auxlst (out, i+1, xs)
  end // end of [list_cons]
else ((*void*)) // end of [list_nil]
//
end // end of [auxlst]
//
in
  auxlst (out, 0(*i*), tmvlst)
end (* end of [emit_tmpmovlst] *)

(* ****** ****** *)
//
extern
fun
emit_patckont
  (out: FILEref, fail: patckont): void
//
implement
emit_patckont
  (out, fail) = let
in
//
case+ patckont_view (fail) of
//
| ~PTCKNTtmplab (tlab) =>
  {
    val () =
    emit_text (out, "ATSINSgoto(")
    val () = emit_tmplab (out, tlab)
    val ((*closing*)) = emit_text (out, ")")
  }
//
| ~PTCKNTtmplabint (tlab, int) =>
  {
    val () =
    emit_text (out, "ATSINSgoto(")
    val () = emit_tmplabint (out, tlab, int)
    val ((*closing*)) = emit_text (out, ")")
  }
//
| ~PTCKNTtmplabmov (tlab, tmvlst) =>
  {
    val () =
    emit_tmpmovlst (out, tmvlst)
    val () =
    emit_text (out, "ATSINSgoto(")
    val () = emit_tmplab (out, tlab)
    val ((*closing*)) = emit_text (out, ")")
  }
//
| ~PTCKNTraise (tmp, pmv_exn) =>
  {
    val () =
    emit_text (out, "ATSINSraise_exn(")
    val () = (
      emit_tmpvar (out, tmp); emit_text (out, ", "); emit_primval (out, pmv_exn)
    ) (* end of [val] *)
    val ((*closing*)) = emit_text (out, ")")
  }
//
| ~PTCKNTcaseof_fail (loc) =>
  {
    val () =
    emit_text (out, "ATSINScaseof_fail(\"")
    val () = $LOC.fprint_location (out, loc)
    val ((*closing*)) = emit_text (out, "\")")
  }
//
| ~PTCKNTfunarg_fail (loc, flab) =>
  {
    val () =
    emit_text (out, "ATSINSfunarg_fail(\"")
    val () = $LOC.fprint_location (out, loc)
    val ((*closing*)) = emit_text (out, "\")")
  }
//
| ~PTCKNTnone ((*void*)) =>
  {
    val () = emit_text (out, "ATSINSdeadcode_fail()")
  }
//
end // (* end of [emit_patckont] *)
//
(* ****** ****** *)
//
// HX-2013-01:
//
// the kind of code duplication in the implementation
// of [emit_instr_patck] can be readily removed by using
// template system of ATS2.
//
//
local

fun auxcon
(
  out: FILEref
, pmv: primval
, d2c: d2con, fail: patckont
) : void =let
//
val s2c = d2con_get_scst (d2c)
//
in
//
if
  s2cst_is_singular (s2c) then ()
else if
  s2cst_is_listlike (s2c) then let
    val islst = s2cst_get_islst (s2c)
    val isnil = (
      case+ gopt_view (islst) of
      | ~GOsome xx =>
          eq_d2con_d2con (d2c, d2conpair_0 (xx))
      | ~GOnone () => false (* deadcode *)
    ) : bool // end of [val]
    val () = emit_text (out, "ATSifthen(")
    val () = (
      if isnil
        then emit_text (out, "ATSCKptriscons(")
        else emit_text (out, "ATSCKptrisnull(")
      // end of [if]
    ) : void // end of [val]
    val () = emit_primval (out, pmv)
    val () = emit_text (out, ")) { ")
    val () = emit_patckont (out, fail)
    val () = emit_text (out, " ; } ;")
  in
    // nothing
  end // end of [islistlike]
else let
    val isnul =
      d2con_is_nullary (d2c)
    // end of [val]
    val () =
      emit_text (out, "ATSifnthen(")
    val () =
    (
      if isnul
        then emit_text (out, "ATSCKpat_con0(")
        else emit_text (out, "ATSCKpat_con1(")
      // end of [if]
    ) : void // end of [val]
    val () = emit_primval (out, pmv)
    val () = emit_text (out, ", ")
    val () = emit_int (out, d2con_get_tag (d2c))
    val () = emit_text (out, ")) { ")
    val () = emit_patckont (out, fail)
    val () = emit_text (out, " ; } ;")
  in
    // nothing
  end // end of [PATCKcon]
//
end // end of [auxcon]

fun auxexn
(
  out: FILEref
, pmv: primval
, d2c: d2con, fail: patckont
) : void = let
//
val narg =
  d2con_get_arity_real (d2c)
//
val () =
  emit_text (out, "ATSifnthen(")
val () =
(
  if narg = 0
    then emit_text (out, "ATSCKpat_exn0(")
    else emit_text (out, "ATSCKpat_exn1(")
  // end of [if]
) : void // end of [val]
val () = emit_primval (out, pmv)
val () = emit_text (out, ", ")
val () = emit_d2con (out, d2c);
val () = emit_text (out, ")) { ")
val () = emit_patckont (out, fail)
val () = emit_text (out, " ; } ;")
//
in
  // nothing
end // end of [auxexn]

fun auxmain (
  out: FILEref
, pmv: primval, patck: patck, fail: patckont
) : void = let
in
//
case+ patck_view (patck) of
//
| ~PATCKcon (d2c) => let
    val iscon = d2con_is_con (d2c)
  in
    if iscon then
      auxcon (out, pmv, d2c, fail) else auxexn (out, pmv, d2c, fail)
    // end of [if]
  end // end of [PATCKcon]
//
| ~PATCKint (i) => {
    val () = emit_text (out, "ATSifnthen(")
    val () = emit_text (out, "ATSCKpat_int(")
    val () = emit_primval (out, pmv)
    val () = emit_text (out, ", ")
    val () = emit_ATSPMVint (out, i)
    val () = emit_text (out, ")) { ")
    val () = emit_patckont (out, fail)
    val () = emit_text (out, " ; } ;")
  } (* end of [PATCKint] *)
//
| ~PATCKbool (b) => {
    val () = emit_text (out, "ATSifnthen(")
    val () = emit_text (out, "ATSCKpat_bool(")
    val () = emit_primval (out, pmv)
    val () = emit_text (out, ", ")
    val () = emit_ATSPMVbool (out, b)
    val () = emit_text (out, ")) { ")
    val () = emit_patckont (out, fail)
    val () = emit_text (out, " ; } ;")
  } (* end of [PATCKbool] *)
//
| ~PATCKchar (c) => {
    val () = emit_text (out, "ATSifnthen(")
    val () = emit_text (out, "ATSCKpat_char(")
    val () = emit_primval (out, pmv)
    val () = emit_text (out, ", ")
    val () = emit_ATSPMVchar (out, c)
    val () = emit_text (out, ")) { ")
    val () = emit_patckont (out, fail)
    val () = emit_text (out, " ; } ;")
  } (* end of [PATCKchar] *)
//
| ~PATCKfloat (float) =>
  {
    val () = emit_text (out, "ATSifnthen(")
    val () = emit_text (out, "ATSCKpat_float(")
    val () = emit_primval (out, pmv)
    val () = emit_text (out, ", ")
    val () = emit_ATSPMVfloat (out, float)
    val () = emit_text (out, ")) { ")
    val () = emit_patckont (out, fail)
    val () = emit_text (out, " ; } ;")
  } (* end of [PATCKfloat] *)
//
| ~PATCKstring (str) =>
  {
    val () = emit_text (out, "ATSifnthen(")
    val () = emit_text (out, "ATSCKpat_string(")
    val () = emit_primval (out, pmv)
    val () = emit_text (out, ", ")
    val () = emit_ATSPMVstring (out, str)
    val () = emit_text (out, ")) { ")
    val () = emit_patckont (out, fail)
    val () = emit_text (out, " ; } ;")
  } (* end of [PATCKstring] *)
//
| ~PATCKi0nt (tok) => {
    val () = emit_text (out, "ATSifnthen(")
    val () = emit_text (out, "ATSCKpat_int(")
    val () = emit_primval (out, pmv)
    val () = emit_text (out, ", ")
    val () = emit_ATSPMVi0nt (out, tok)
    val () = emit_text (out, ")) { ")
    val () = emit_patckont (out, fail)
    val () = emit_text (out, " ; } ;")
  } (* end of [PATCKi0nt] *)
//
| ~PATCKf0loat (tok) => {
    val () = emit_text (out, "ATSifnthen(")
    val () = emit_text (out, "ATSCKpat_float(")
    val () = emit_primval (out, pmv)
    val () = emit_text (out, ", ")
    val () = emit_ATSPMVf0loat (out, tok)
    val () = emit_text (out, ")) { ")
    val () = emit_patckont (out, fail)
    val () = emit_text (out, " ; } ;")
  } (* end of [PATCKf0loat] *)
//
end (* end of [auxmain] *)

in (* in of [local] *)

implement
emit_instr_patck
  (out, ins) = let
//
val-~INSpatck
  (pmv, patck, fail) = instr_node_view (ins.instr_node ())
val isnone = patckont_is_none (fail)
val () =
  if isnone then emit_text (out, "#if(0)\n")
val () = auxmain (out, pmv, patck, fail)
val () =
  if isnone then emit_text (out, "\n#endif")
//
in
  // nothing
end // end of [emit_instr_patck]

end // end of [local]

(* ****** ****** *)

local

fun aux
(
  out: FILEref, ibr: ibranch
) : void =  let
//
val inss = ibr.ibranch_inslst ()
//
val () = emit_text (out, "ATSbranch_beg()\n")
val () = emit_instrlst_ln (out, inss)
val () = emit_text (out, "ATSbranch_end()\n")
//
in
  // nothing
end // end of [emit_branch]

in (*in-of-local*)

implement
emit_ibranchlst
  (out, ibrs) = let
//
fun auxlst
(
  out: FILEref
, i: int, ibrs: ibranchlst
) : void = let
in
//
if glist_is_cons (ibrs) then let
    val ibr = glist_head<ibranch> (ibrs)
    val ibrs = glist_tail<ibranch> (ibrs)
    val () = aux (out, ibr)
    val () = emit_newline (out)
    val () = auxlst (out, i+1, ibrs)
  in
    // nothing
  end // end of [list_cons]
else () // end of [list_nil]
//
end // end of [auxlst]
//
val () = emit_text
(
  out, "/*\n** ibranchlst-beg\n*/\n"
)
val () = auxlst (out, 0(*i*), ibrs)
val () = emit_text
(
  out, "/*\n** ibranchlst-end\n*/\n"
)
in
  // nothing
end // end of [emit_ibranchlst]

end // end of [local]

(* ****** ****** *)

local

fun
auxfun
(
  out: FILEref, fent: funent
) : void = let
//
val flab = funent_get_lab(fent)
val istmp = (funlab_get_tmpknd(flab) > 0)
//
val qopt = funlab_get_d2copt(flab)
val isqua = gopt_is_some (qopt)
val isext =
(
if gopt_is_some (qopt) then
    (if d2cst_is_static(gopt_unsome<d2cst>(qopt)) then false else true)
else false
) : bool // end of [val]
//
val flopt = funlab_get_origin(flab)
val isqua =
(
  if gopt_is_some (flopt) then false else isqua
) : bool // end of [val]
val isext =
(
  if gopt_is_some (flopt) then false else isext
) : bool // end of [val]
val issta = not (isext)
//
val () = if istmp then emit_text (out, "#if(0)\n")
val () = if isqua then emit_text (out, "#if(0)\n")
//
val () = if isext then emit_text (out, "ATSextern()\n")
val () = if issta then emit_text (out, "ATSstatic()\n")
//
val hse_res = funlab_get_type_res (flab)
val hses_arg = funlab_get_type_fullarg (flab)
//
val (
) = emit_hisexp (out, hse_res)
val () = emit_text (out, "\n")
val () = emit_funlab (out, flab)
val () = emit_text (out, "(")
val (
) = emit_hisexplst_sep (out, hses_arg, ", ")
val () = emit_text (out, ") ;\n")
//
val () =
  if isqua then emit_text (out, "#endif // end of [QUALIFIED]\n")
//
val () =
  if istmp then emit_text (out, "#endif // end of [TEMPLATE]\n")
//
in
  // nothing
end // end of [auxfun]

in (* in of [local] *)

implement
emit_funent_ptype
  (out, fent) = let
//
val () = auxfun (out, fent)
//
val () = emit_newline (out)
//
in
  // nothing
end // end of [emit_funentry_ptype]

end // end of [local]

(* ****** ****** *)

local

fun
aux0_arglst
(
  out: FILEref
, hses: hisexplst, i: int
) : void = let
in
//
if glist_is_cons (hses) then let
    val hse = glist_head<hisexp> (hses)
    val hses = glist_tail<hisexp> (hses)
    val () =
    if i > 0
      then emit_text (out, ", ")
    // end of [if]
    val () = emit_hisexp (out, hse)
  in
    aux0_arglst (out, hses, i+1)
  end // end of [list_cons]
else () // end of [list_nil]
//
end (* end of [aux0_arglst] *)

fun
aux1_arglst
(
  out: FILEref
, hses: hisexplst, n0: int, i: int
) : void = let
in
//
if glist_is_cons (hses) then let
    val hse = glist_head<hisexp> (hses)
    val hses = glist_tail<hisexp> (hses)
    val () =
    if n0+i > 0 then emit_text (out, ", ")
    val () =
    (
      emit_hisexp (out, hse); emit_text (out, " arg"); emit_int (out, i)
    ) : void // end of [val]
  in
    aux1_arglst (out, hses, n0, i+1)
  end // end of [list_cons]
else () // end of [list_nil]
//
end (* end of [aux1_arglst] *)

fun
aux2_arglst
(
  out: FILEref
, hses: hisexplst, n0: int, i: int
) : void = let
in
//
if glist_is_cons (hses) then let
    val hse = glist_head<hisexp> (hses)
    val hses = glist_tail<hisexp> (hses)
    val () =
    if n0+i > 0 then emit_text (out, ", ")
    val () =
    (
      emit_text (out, "arg"); emit_int (out, i)
    ) : void // end of [val]
  in
    aux2_arglst (out, hses, n0, i+1)
  end // end of [list_cons]
else () // end of [list_nil]
//
end (* end of [aux2_arglst] *)

fun
aux0_envlst
(
  out: FILEref, d2es: d2envlst, i: int
) : void = let
in
//
if glist_is_cons (d2es) then let
    val d2e = glist_head<d2env> (d2es)
    val d2es = glist_tail<d2env> (d2es)
    val hse = d2env_get_type (d2e)
    val () =
    if i > 0
      then emit_text (out, ", ")
    // end of [if]
    val () = emit_hisexp (out, hse)
  in
    aux0_envlst (out, d2es, i+1)
  end // end of [list_cons]
else () // end of [list_nil]
//
end (* end of [aux0_envlst] *)

fun
aux1_envlst
(
  out: FILEref, d2es: d2envlst, i: int
) : void = let
in
//
if glist_is_cons (d2es) then let
    val d2e = glist_head<d2env> (d2es)
    val d2es = glist_tail<d2env> (d2es)
    val hse = d2env_get_type (d2e)
    val () =
    (
      emit_hisexp (out, hse); emit_text (out, " env"); emit_int (out, i)
    )
    val () = emit_text (out, " ;\n")
  in
    aux1_envlst (out, d2es, i+1)
  end // end of [list_cons]
else () // end of [list_nil]
//
end (* end of [aux1_envlst] *)

fun
aux2_envlst
(
  out: FILEref
, d2es: d2envlst, n0: int, i: int
) : int = let
in
//
if glist_is_cons (d2es) then let
    val d2e = glist_head<d2env> (d2es)
    val d2es = glist_tail<d2env> (d2es)
    val hse = d2env_get_type (d2e)
    val () =
    if n0+i > 0 then emit_text (out, ", ")
    val () =
    (
      emit_hisexp (out, hse); emit_text (out, " env"); emit_int (out, i)
    ) : void // end of [val]
  in
    aux2_envlst (out, d2es, n0, i+1)
  end // end of [list_cons]
else (n0+i) // end of [list_nil]
//
end (* end of [aux2_envlst] *)

fun
aux3_envlst
(
  out: FILEref
, d2es: d2envlst, n0: int, i: int
) : int = let
in
//
if glist_is_cons (d2es) then let
    val d2e = glist_head<d2env> (d2es)
    val d2es = glist_tail<d2env> (d2es)
    val () =
    if n0+i > 0 then emit_text (out, ", ")
    val () =
    (
      emit_text (out, "env"); emit_int (out, i)
    ) : void // end of [val]
  in
    aux3_envlst (out, d2es, n0, i+1)
  end // end of [list_cons]
else (n0+i) // end of [list_nil]
//
end (* end of [aux3_envlst] *)

fun
aux4_envlst
(
  out: FILEref
, d2es: d2envlst, n0: int, i: int
) : int = let
in
//
if glist_is_cons (d2es) then let
    val d2e = glist_head<d2env> (d2es)
    val d2es = glist_tail<d2env> (d2es)
    val () =
    if n0+i > 0 then emit_text (out, ", ")
    val () =
    (
      emit_text (out, "p_cenv->env"); emit_int (out, i)
    ) : void // end of [val]
  in
    aux4_envlst (out, d2es, n0, i+1)
  end // end of [list_cons]
else (i) // end of [list_nil]
//
end (* end of [aux4_envlst] *)

fun
aux5_envlst
(
  out: FILEref, d2es: d2envlst, i: int
) : void = let
in
//
if glist_is_cons (d2es) then let
    val d2e = glist_head<d2env> (d2es)
    val d2es = glist_tail<d2env> (d2es)
    val hse = d2env_get_type (d2e)
    val () =
    (
      emit_text (out, "p_cenv->env"); emit_int (out, i)
    ) : void // end of [val]
    val () =
    (
      emit_text (out, " = "); emit_text (out, "env"); emit_int (out, i)
    ) : void // end of [val]
    val () = emit_text (out, " ;\n")
  in
    aux5_envlst (out, d2es, i+1)
  end // end of [list_cons]
else () // end of [list_nil]
//
end (* end of [aux5_envlst] *)

fun
auxclo_type
(
  out: FILEref
, flab: funlab, d2es: d2envlst
) : void = let
//
val () = emit_text (out, "typedef\n")
val () = emit_text (out, "ATSstruct {\n")
val () = emit_text (out, "atstype_funptr cfun ;\n")
val () = aux1_envlst (out, d2es, 0)
val ((*closing*)) = emit_text (out, "} ")
//
val () = emit_funlab (out, flab)
val () = emit_text (out, "__closure_t0ype ;\n")
//
in
  // nothing
end (* end of [auxclo_type] *)

fun
auxclo_cfun
(
  out: FILEref
, flab: funlab, d2es: d2envlst
) : void = let
//
val hse_res = funlab_get_type_res (flab)
val hses_arg = funlab_get_type_arg (flab)
//
val isvoid = hisexp_is_void (hse_res)
//
val () = emit_text (out, "ATSstatic()\n")
val () = emit_hisexp (out, hse_res)
val () = emit_text (out, "\n")
val () = emit_funlab (out, flab)
val () = emit_text (out, "__cfun")
val () = emit_text (out, "\n(\n")
val () = emit_funlab (out, flab)
val () = emit_text (out, "__closure_t0ype *p_cenv")
val () = aux1_arglst (out, hses_arg, 1, 0)
val () = emit_text (out, "\n)\n{\n")
val () = emit_text (out, "ATSFCreturn")
val () = if isvoid then emit_text (out, "_void")
val () = emit_text (out, "(")
val () = emit_funlab (out, flab)
val () = emit_text (out, "(")
val n0 = aux4_envlst (out, d2es, 0, 0)
val () = aux2_arglst (out, hses_arg, n0, 0)
val () = emit_text (out, ")) ;\n")
val () = emit_text (out, "} /* end of [cfun] */\n")
//
in
  // nothing
end (* end of [auxclo_cfun] *)

fun
auxclo_init
(
  out: FILEref
, flab: funlab, d2es: d2envlst
) : void = let
//
val () = emit_text (out, "ATSstatic()\n")
val () = emit_text (out, "atstype_cloptr\n")
//
val () = emit_funlab (out, flab)
val () = emit_text (out, "__closureinit")
val () = emit_text (out, "\n(\n")
//
val () = emit_funlab (out, flab)
val () = emit_text (out, "__closure_t0ype *p_cenv")
val n0 = aux2_envlst (out, d2es, 1, 0)
//
val () = emit_text (out, "\n)\n{\n")
val () = aux5_envlst (out, d2es, 0)
val () = emit_text (out, "p_cenv->cfun = ")
val () = emit_funlab (out, flab)
val () = emit_text (out, "__cfun ;\n")
val () = emit_text (out, "return p_cenv ;\n")
val () = emit_text (out, "} /* end of [closureinit] */\n")
//
in
  // nothing
end (* end of [auxclo_init] *)

fun
auxclo_create
(
  out: FILEref
, flab: funlab, d2es: d2envlst
) : void = let
//
val () = emit_text (out, "ATSstatic()\n")
val () = emit_text (out, "atstype_cloptr\n")
//
val () = emit_funlab (out, flab)
val () = emit_text (out, "__closurerize")
val () = emit_text (out, "\n(\n")
//
val n0 = aux2_envlst (out, d2es, 0, 0)
val () = if n0 = 0 then emit_text (out, "// argumentless")
//
val () = emit_text (out, "\n)\n{\n")
val () = emit_text (out, "return ")
val () = emit_funlab (out, flab)
val () = emit_text (out, "__closureinit(")
val () = emit_text (out, "ATS_MALLOC(sizeof(")
val () = emit_funlab (out, flab)
val () = emit_text (out, "__closure_t0ype))")
val n0 = aux3_envlst (out, d2es, 1, 0)
val () = emit_text (out, ") ;\n")
val () = emit_text (out, "} /* end of [closurerize] */\n")
//
in
  // nothing
end (* end of [auxclo_create] *)

fun
auxall_beg
(
  out: FILEref
, flab: funlab, d2es: d2envlst
) : void =
{
//
val hse_res = funlab_get_type_res (flab)
val hses_arg = funlab_get_type_arg (flab)
//
val () =
emit_text
(
  out
, "ATSclosurerize_beg"
) (* end of [val] *)
//
val () = emit_LPAREN (out)
//
val () =
emit_funlab (out, flab)
//
val () = emit_text (out, ", ")
//
val () = emit_LPAREN (out)
val () = aux0_envlst (out, d2es, 0)
val () = emit_RPAREN (out)
//
val () = emit_text (out, ", ")
//
val () = emit_LPAREN (out)
val () = aux0_arglst (out, hses_arg, 0)
val () = emit_RPAREN (out)
//
val () = emit_text (out, ", ")
//
val () = emit_hisexp (out, hse_res)
//
val () = emit_RPAREN (out)
val () = emit_newline (out)
//
} (* end of [auxall_end] *)

fun auxall_end
(
  out: FILEref
, flab: funlab, d2es: d2envlst
) : void =
{
//
val () = emit_text (out, "ATSclosurerize_end()\n")
//
} (* end of [auxall_end] *)

in (* in of [local] *)

implement
emit_funent_closure
  (out, fent) = let
//
val flab = funent_get_lab (fent)
val d2es = funent_eval_d2envlst (fent)
//
val () = auxall_beg (out, flab, d2es)
//
val () = auxclo_type (out, flab, d2es)
val () = auxclo_cfun (out, flab, d2es)
val () = auxclo_init (out, flab, d2es)
//
val fc =
funlab_get_funclo (flab)
val () =
if funclo_is_ptr(fc)
  then auxclo_create (out, flab, d2es)
// end of [if]
//
val () = auxall_end (out, flab, d2es)
//
in
  // nothing
end // end of [emit_funent_closure]

end // end of [local]

(* ****** ****** *)
//
extern
fun
emit_funlab_funarg
  (out: FILEref, flab: funlab): void
//
implement
emit_funlab_funarg (out, flab) = let
//
fun auxlst
(
  out: FILEref, hses: hisexplst, i: int
) : void = let
in
//
if glist_is_cons (hses) then let
    val hse = glist_head<hisexp> (hses)
    val hses = glist_tail<hisexp> (hses)
    val () =
      emit_text (out, "ATStmpdec(")
    // end of [val]
    val () = (
      emit_funarg (out, i); emit_text (out, ", "); emit_hisexp (out, hse)
    ) (* end of [val] *)
    val () = emit_text (out, ") ;\n")
  in
    auxlst (out, hses, i+1)
  end // end of [list_cons]
else () // end of [list_nil]
//
end // end of [auxlst]
//
val hses = funlab_get_type_arg (flab)
//
in
  auxlst (out, hses, 0(*i*))
end // end of [emit_funlab_funarg]
//
(* ****** ****** *)
//
extern
fun
emit_funlab_funapy
  (out: FILEref, flab: funlab): void
//
implement
emit_funlab_funapy
  (out, flab) = let
//
fun
auxlst
(
  out: FILEref, hses: hisexplst, i: int
) : void = let
in
//
if glist_is_cons (hses) then let
    val hse = glist_head<hisexp> (hses)
    val hses = glist_tail<hisexp> (hses)
    val () =
      emit_text(out, "ATStmpdec(")
    // end of [val]
    val () =
    (
      emit_funapy(out, i); emit_text(out, ", "); emit_hisexp(out, hse)
    ) (* end of [val] *)
    val () = emit_text(out, ") ;\n")
  in
    auxlst(out, hses, i+1)
  end // end of [list_cons]
else () // end of [list_nil]
//
end // end of [auxlst]
//
val hses = funlab_get_type_arg (flab)
//
in
  auxlst (out, hses, 0(*i*))
end // end of [emit_funlab_funapy]

(* ****** ****** *)

extern
fun
emit_funent_fundec
  (out: FILEref, fent: funent): void
implement
emit_funent_fundec
  (out, fent) = let
//
val flab = funent_get_lab(fent)
//
val tmpret = funent_get_tmpret(fent)
val ntlcal = tmpvar_get_tailcal(tmpret)
//
val () = emit_text (out, "/* tmpvardeclst(beg) */\n")
//
val () =
  if ntlcal >= 2 then emit_funlab_funapy(out, flab)
//
val () = emit_tmpdeclst(out, funent_get_tmpvarlst(fent))
//
val () = emit_text (out, "/* tmpvardeclst(end) */\n")
//
in
  // nothing
end // end of [emit_funent_fundec]

(* ****** ****** *)
//
extern
fun
emit_funent_funbody
  (out: FILEref, fent: funent): void
//
implement
emit_funent_funbody
  (out, fent) = let
//
val () = emit_text (out, "ATSfunbody_beg()\n")
val () = emit_instrlst_ln (out, funent_get_instrlst (fent))
val () = emit_text (out, "ATSfunbody_end()\n")
//
val tmpret = funent_get_tmpret (fent)
//
val () = let
  val isvoid = tmpvar_is_void (tmpret)
in
  if ~isvoid
    then emit_text(out, "ATSreturn(") else emit_text(out, "ATSreturn_void(")
  // end of [if]
end : void // end of [let] // end of [val]
//
val () = emit_tmpvar (out, tmpret)
//
val ((*closing*)) = emit_text (out, ") ;\n")
//
in
  // nothing
end // end of [emit_funent_funbody]

(* ****** ****** *)
//
extern
fun
emit_funent_fnxdeclst (out: FILEref, fent0: funent): void
extern
fun
emit_funent_fnxbodylst (out: FILEref, fent0: funent): void
//
(* ****** ****** *)

local

fun auxfl
(
  out: FILEref
, fent0: funent, fl: funlab
) : void = let
//
val opt = funlab_get_funent (fl)
//
in
//
case+ gopt_view (opt) of
| ~GOsome (fent) => let
    val () = emit_funlab_funarg (out, fl)
    val () = emit_funent_fundec (out, fent)
  in
    // nothing
  end // end of [Some]
| ~GOnone ((*void*)) => ()
//
end // end of [auxfl]

fun auxflist
(
  out: FILEref
, fent0: funent, fls: funlablst, i: int
) : void = let
in
//
if glist_is_cons (fls) then let
    val fl = glist_head<funlab> (fls)
    val fls = glist_tail<funlab> (fls)
    val () = emit_set_nfnx (i)
    val () = auxfl (out, fent0, fl)
    val () = emit_set_nfnx (0)
    val () = auxflist (out, fent0, fls, i+1)
  in
    // nothing
  end // end of [list_cons]
else () // end of [list_nil]
//
end // end of [auxflist]

in (* in of [local] *)

implement
emit_funent_fnxdeclst
  (out, fent0) = let
//
val fls = funent_get_fnxlablst(fent0)
//
val () = (
if glist_is_cons (fls) then
  emit_text(out, "/*\nemit_funent_fnxdeclst:\n*/\n")
else ((*void*))
) : void // end of [val]
//
in
//
if glist_is_cons (fls) then
  auxflist (out, fent0, glist_tail<funlab> (fls), 2(*i*))
  // end of [list_cons]
else ((*void*))
//
end // end of [emit_funent_fnxdeclst]

end // end of [local]

(* ****** ****** *)

local

fun auxfl
(
  out: FILEref
, fent0: funent, fl: funlab
) : void = let
//
val opt = funlab_get_funent(fl)
//
in
//
case+ gopt_view (opt) of
| ~GOsome (fent) =>
    emit_funent_funbody(out, fent)
| ~GOnone ((*void*)) => ((*void*))
//
end // end of [auxfl]

fun auxflist
(
  out: FILEref
, fent0: funent, fls: funlablst, i: int
) : void = let
in
//
if glist_is_cons (fls) then let
    val fl = glist_head<funlab> (fls)
    val fls = glist_tail<funlab> (fls)
    val () = emit_set_nfnx (i)
    val () = auxfl (out, fent0, fl)
    val () = emit_set_nfnx (0)
    val () = auxflist (out, fent0, fls, i+1)
  in
    // nothing
  end // end of [list_cons]
else () // end of [list_nil]
//
end // end of [auxflist]

in (* in of [local] *)

implement
emit_funent_fnxbodylst
  (out, fent0) = let
//
val fls = funent_get_fnxlablst (fent0)
//
val () = (
if glist_is_cons (fls) then
  emit_text (out, "/*\nemit_funent_fnxbodylst:\n*/\n")
else ((*void*))
) : void // end of [val]
//
in
//
if glist_is_cons (fls) then
  auxflist (out, fent0, glist_tail<funlab> (fls), 2(*i*))
  // end of [list_cons]
else ((*void*))
//
end // end of [emit_funent_fnxbodylst]

end // end of [local]

(* ****** ****** *)

local

fun auxtmp
(
  out: FILEref, fent: funent
) : void = let
//
val imparg = funent_get_imparg (fent)
val tmparg = funent_get_tmparg (fent)
val tsubopt = funent_get_tmpsub (fent)
//
val () = emit_text (out, "/*\n")
val () = emit_text (out, "imparg = ")
val () = fprint_s2varlst (out, imparg)
val () = emit_text (out, "\n")
val () = emit_text (out, "tmparg = ")
val () = fprint_s2explstlst (out, tmparg)
val () = emit_text (out, "\n")
val () = emit_text (out, "tmpsub = ")
val () = fprint_tmpsubopt (out, tsubopt)
val () = emit_text (out, "\n")
val () = emit_text (out, "*/\n")
//
in
  // nothing
end // end of [auxtmp]

in (* in of [local] *)

implement
emit_funent_implmnt
  (out, fent) = let
//
val loc0 = funent_get_loc (fent)
val flab = funent_get_lab (fent)
val d2es = funent_eval_d2envlst (fent)
//
val () = emit_text (out, "/*\n")
val () = $LOC.fprint_location (out, loc0)
val () = emit_text (out, "\n*/\n")
//
val () = emit_text (out, "/*\n")
val () = emit_text (out, "local: ")
val lfls0 = funent_get_flablst (fent)
val () = fprint_funlablst (out, lfls0)
val () = emit_newline (out)
val () = emit_text (out, "global: ")
val gfls0 = funent_eval_flablst (fent)
val () = fprint_funlablst (out, gfls0)
val () = emit_newline (out)
//
val () = emit_text (out, "local: ")
val ld2es = funent_eval_d2envlst (fent)
val () = fprint_d2envlst (out, ld2es)
val () = emit_newline (out)
val () = emit_text (out, "global: ")
val gd2es = funent_eval_d2envlst (fent)
val () = fprint_d2envlst (out, gd2es)
val () = emit_newline (out)
//
val () = emit_text (out, "*/\n")
//
val hse_res = funlab_get_type_res (flab)
val hses_arg = funlab_get_type_arg (flab)
//
// function header
//
val qopt = funlab_get_d2copt (flab)
val isext =
(
if gopt_is_some (qopt) then
    (if d2cst_is_static (gopt_unsome<d2cst>(qopt)) then false else true)
else false
) : bool // end of [val]
val flopt = funlab_get_origin (flab)
val isext =
(
  if gopt_is_some (flopt) then false else isext
) : bool // end of [val]
val issta = not (isext)
//
val () =
  if isext then emit_text (out, "ATSextern()\n")
val () =
  if issta then emit_text (out, "ATSstatic()\n")
//
val istmp = funent_is_tmplt (fent)
val () = if istmp then auxtmp (out, fent)
//
val () = emit_hisexp (out, hse_res)
val () = emit_text (out, "\n")
val () = emit_funlab (out, flab)
val () = emit_text (out, "(")
val nenv = emit_funenvlst (out, d2es)
val () = emit_funarglst (out, nenv, hses_arg)
val () = emit_text (out, ")\n")
//
// tmpvardec and funbody
//
val () = funent_varbindmap_initize (fent)
val () = funent_varbindmap_initize2 (fent)
//
val () = emit_text (out, "{\n")
//
val () = emit_funent_fundec (out, fent)
val () = emit_funent_fnxdeclst (out, fent)
//
val () = emit_funent_funbody (out, fent)
val () = emit_funent_fnxbodylst (out, fent)
//
val () = emit_text (out, "} /* end of [")
val () = emit_funlab (out, flab)
val () = emit_text (out, "] */\n")
//
val () = funent_varbindmap_uninitize (fent)
//
in
  // nothing
end // end of [emit_funent_implmnt]

end // end of [local]

(* ****** ****** *)

implement
emit_dynload
  (out, hid) = let
//
val-~HIDdynload (fil) = hidecl_node_view (hid.hidecl_node ())
//
val () = emit_text (out, "ATSdynloadfcall(")
val () =
(
  emit_filename (out, fil); emit_text (out, "__dynload")
)
val () = emit_text (out, ") ;\n")
//
in
  // nothing
end (* end of [emit_dynload] *)

(* ****** ****** *)

local
//
fun emit_primdec
  (out: FILEref, pmd: primdec) : void = let
in
//
case+ primdec_node_view (pmd.primdec_node ()) of
//
| ~PMDnone () => ()
//
| ~PMDlist (pmds) => emit_primdeclst (out, pmds)
//
| ~PMDsaspdec _ => ()
//
| ~PMDextvar
    (name, inss) =>
    emit_instrlst_ln (out, inss)
//
| ~PMDdatdecs _ => ()
| ~PMDexndecs _ => ()
//
| ~PMDimpdec (imp) => let
    val opt = hiimpdec_get_instrlstopt (imp)
  in
    case+ gopt_view (opt) of
    | ~GOsome (inss) => emit_instrlst_ln (out, inss)
    | ~GOnone () => ()
  end // end of [PMDimpdec]
//
| ~PMDfundecs _ => ()
//
| ~PMDvaldecs
    (knd, hvds, inss) =>
    emit_instrlst_ln (out, inss)
| ~PMDvaldecs_rec
    (knd, hvds, inss) =>
    emit_instrlst_ln (out, inss)
//
| ~PMDvardecs(hvds, inss) =>
    emit_instrlst_ln (out, inss)
//
| ~PMDinclude
    (pfil, pmds) => emit_primdeclst (out, pmds)
//
| ~PMDstaload _ => ()
//
| ~PMDstaloadloc
    (pfil, nspace, pmds) => emit_primdeclst (out, pmds)
//
| ~PMDdynload (cfil) => emit_dynload (out, cfil)
//
| ~PMDlocal
  (
    pmds_head, pmds_body
  ) => {
    val (
    ) = emit_text (out, "/* local */\n")
    val () = emit_primdeclst (out, pmds_head)
    val (
    ) = emit_text (out, "/* in of [local] */\n")
    val () = emit_primdeclst (out, pmds_body)
    val (
    ) = emit_text (out, "/* end of [local] */\n")
    // end of [val]
  } // end of [PMDlocal]
//
end // end of [emit_primdec]

in (* in of [local] *)

implement
emit_primdeclst
  (out, pmds) = let
in
//
if glist_is_cons (pmds) then let
    val pmd = glist_head<primdec> (pmds)
    val pmds = glist_tail<primdec> (pmds)
    val () =
      emit_primdec (out, pmd) in emit_primdeclst (out, pmds)
    // end of [val]
  end // end of [list_cons]
else () // end of [list_nil]
//
end // end of [emit_primdeclst]

end // end of [local]

(* ****** ****** *)

implement
emit_d2con_extdec
  (out, d2c) = let
//
val
isexn =
d2con_is_exn(d2c)
//
val () =
if isexn then {
//
val () =
emit_text
(out, "ATSdynexn_extdec")
//
val () = emit_text(out, "(")
val () = emit_d2con(out, d2c)
val () = emit_text(out, ") ;\n")
//
} // end of [if] // end of [val]
//
in
  // nothing
end // end of [emit_d2con_extdec]

implement
emit_d2conlst_extdec
  (out, d2cs) = let
in
//
if glist_is_cons (d2cs) then let
  val d2c = glist_head<d2con> (d2cs)
  val d2cs = glist_tail<d2con> (d2cs)
  val () = emit_d2con_extdec (out, d2c)
in
  emit_d2conlst_extdec (out, d2cs)
end else () // end of [list_nil]
//
end // end of [emit_d2conlst_extdec]

(* ****** ****** *)

implement
emit_d2conlst_initize
  (out, d2cs) = let
//
fun aux
(
  out: FILEref, d2c: d2con
) : void = let
//
val fil = d2con_get_fil (d2c)
val name = d2con_get_name (d2c)
//
val () = emit_text (out, "ATSdynexn_initize(")
val () = emit_d2con (out, d2c)
val () = emit_text (out, ", ")
val () = emit_text (out, "\"")
val () = $FIL.fprint_filename_full (out, fil)
val () = emit_text (out, ":")
val () = emit_text (out, name)
val () = emit_text (out, "\"")
val () = emit_text (out, ") ;\n")
//
in
  // nothing
end (* end of [aux] *)
//
in
//
if glist_is_cons (d2cs) then let
    val d2c = glist_head<d2con> (d2cs)
    val d2cs = glist_tail<d2con> (d2cs)
    val isexn = d2con_is_exn (d2c)
    val ((*void*)) = if isexn then aux (out, d2c)
  in
    emit_d2conlst_initize (out, d2cs)
  end // end of [list_cons]
else () // end of [list_nil]
//
end // end of [emit_d2conlst_initize]

(* ****** ****** *)

implement
emit_d2cst_extdec
  (out, d2c) = let
//
macdef
ismac = d2cst_is_mac
//
macdef
isfundec = d2cst_is_fundec
//
macdef
iscastfn = d2cst_is_castfn
//
in
//
if
ismac (d2c) then let
    val () = emit_text (out, "ATSdyncst_mac(")
    val () = emit_d2cst (out, d2c)
    val () = emit_text (out, ")\n")
  in
    // nothing
  end // end of [ismac]
else if
isfundec(d2c) then let
    val issta = d2cst_is_static (d2c)
    val () =
    (
      if issta then
        emit_text (out, "ATSdyncst_stafun(")
      else
        emit_text (out, "ATSdyncst_extfun(")
      // end of [if]
    ) : void // end of [val]
//
    val () = emit_d2cst (out, d2c)
    val () =
    {
      val () = emit_text (out, ", (")
      val hses = d2cst_get2_type_arg (d2c)
      val () = emit_hisexplst_sep (out, hses, ", ")
      val () = emit_text (out, "), ")
    } // end of [val]
//
    val () = let
      val hse =
        d2cst_get2_type_res (d2c) in emit_hisexp (out, hse)
      // end of [val]
    end // end of [val]
//
    val () = emit_text (out, ") ;\n")
//
  in
    // nothing
  end // end of [isfundec]
//
else if
iscastfn(d2c) then let
    val () = emit_text (out, "ATSdyncst_castfn(")
    val () = emit_d2cst (out, d2c)
    val () = emit_text (out, ")\n")
  in
    // nothing
  end // end of [castfn]
else let
    val-~GOsome(hse) = gopt_view (d2cst_get2_hisexp (d2c))
    val () = emit_text (out, "ATSdyncst_valdec(")
    val () = emit_d2cst (out, d2c)
    val () = emit_text (out, ", ")
    val () = emit_hisexp (out, hse)
    val () = emit_text (out, ") ;\n")
  in
    // nothing
  end // end of [_]
//
end // end of [emit_d2cst_extdec]

implement
emit_d2cstlst_extdec
  (out, d2cs) = let
in
//
if glist_is_cons (d2cs) then let
  val d2c = glist_head<d2cst> (d2cs)
  val d2cs = glist_tail<d2cst> (d2cs)
  val () = emit_d2cst_extdec (out, d2c)
in
  emit_d2cstlst_extdec (out, d2cs)
end else () // end of [list_nil]
//
end // end of [emit_d2cstlst_extdec]

(* ****** ****** *)

(* end of [pats_ccomp_emit3.dats] *)
