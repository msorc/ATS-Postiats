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
// HX-2026-10: no GC (ATS2 port of src/pats_trans1_decl.dats)
//
(* ****** ****** *)

#include "share/atspre_staload.hats"
#include "./pats_assert.hats"

(* ****** ****** *)
//
staload
UN = "prelude/SATS/unsafe.sats"
//
(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

#include "./mylibies.hats"
#include "./pats_trans1.hats"

(* ****** ****** *)

staload UT = "./pats_utils.sats"

(* ****** ****** *)

staload ERR = "./pats_error.sats"
staload _(*anon*) = "./pats_error.dats"
staload GLOB = "./pats_global.sats"

(* ****** ****** *)
//
staload LOC = "./pats_location.sats"
//
staload
SYM = "./pats_symbol.sats"
//
overload = with $SYM.eq_symbol_symbol
//
overload print with $SYM.print_symbol
overload prerr with $SYM.prerr_symbol
overload fprint with $SYM.fprint_symbol
//
macdef ADD = $SYM.symbol_ADD
macdef SUB = $SYM.symbol_SUB
//
macdef ATS_PACKNAME = $SYM.symbol_ATS_PACKNAME
//
macdef ATS_DYNLOADFLAG = $SYM.symbol_ATS_DYNLOADFLAG
macdef ATS_DYNLOADNAME = $SYM.symbol_ATS_DYNLOADNAME
//
macdef ATS_STATIC_PREFIX = $SYM.symbol_ATS_STATIC_PREFIX
//
macdef ATS_MAINATSFLAG = $SYM.symbol_ATS_MAINATSFLAG
//
(* ****** ****** *)

staload
FIL = "./pats_filename.sats"

(* ****** ****** *)

staload PAR = "./pats_parsing.sats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)

staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
implement prerr_FILENAME<> () = prerr "pats_trans1_decl"

(* ****** ****** *)

staload "./pats_lexing.sats"
staload "./pats_fixity.sats"
staload _(*anon*) = "./pats_fixity_fxty.dats"
staload "./pats_syntax.sats"
staload "./pats_staexp1.sats"
staload "./pats_dynexp1.sats"

(* ****** ****** *)

staload "./pats_trans1.sats"
staload "./pats_trans1_env.sats"
staload "./pats_e1xpval.sats"

(* ****** ****** *)

#include "./pats_syntax_token.hats"

(* ****** ****** *)

local

fn
prec_make_err
  ((*void*)) = prec_make_int(0)

fn
prec_tr_errmsg_fxty
  (opr: i0de): void = let
  val () =
  prerr_error1_loc(opr.i0de_loc ())
  val () = prerrln! (": the operator [", opr.i0de_sym (), "] is given no fixity")
  val () = the_trans1errlst_add (trans1err_T1E_prec_tr (opr))
in
  // nothing
end // end of [prec_tr_errmsg_fxty]

fn
prec_tr_errmsg_adj
  (opr: i0de): void = let
  val () =
  prerr_error1_loc(opr.i0de_loc ())
  val () = prerrln! ": the operator for adjusting precedence can only be [+] or [-]."
  val () = the_trans1errlst_add (trans1err_T1E_prec_tr (opr))
in
  // nothing
end // end of [prec_tr_errmsg_adj]

fn
precfnd
  (id: i0de): prec = let
  val fxtyopt = the_fxtyenv_find (id.i0de_sym ())
in
  case+ fxtyopt of
  | ~Some_vt fxty => let
      val precopt = fxty_get_prec (fxty)
    in
      case+ precopt of
      | ~Some_vt prec => prec
      | ~None_vt () => let
          val () = prec_tr_errmsg_fxty (id) in prec_make_err ()
        end (* end of [None_vt] *)
    end // end of [Some_vt]
  | ~None_vt () => let
      val () = prec_tr_errmsg_fxty (id) in prec_make_err ()
    end (* end of [None_vt] *)
end // end of [precfnd]

fn
p0rec_tr
  (p0: p0rec): prec = let
in
  case+ p0rec_view (p0) of
  | ~P0RECint int =>
      prec_make_int(int)
    // end of [P0RECint]
  | ~P0RECi0de id => precfnd id
  | ~P0RECi0de_adj
      (id, opr, int) => let
      val sym = opr.i0de_sym () in
      if sym = ADD then precedence_inc(precfnd id, int)
      else if sym = SUB then precedence_dec(precfnd id, int)
      else let
        val () = prec_tr_errmsg_adj(opr) in prec_make_err()
      end (* end of [_] *)
    end // end of [P0RECi0de_adj]
end // end of [p0rec_tr]

fn f0xty_tr
  (f0xty: f0xty): fxty =
(
  case+ f0xty_view (f0xty) of
  | ~F0XTYinf (p0, a) =>
      let val p1 = p0rec_tr p0 in fxty_inf (p1, a) end
    // F0XTYinf
  | ~F0XTYpre p0 => let val p1 = p0rec_tr p0 in fxty_pre p1 end
  | ~F0XTYpos p0 => let val p1 = p0rec_tr p0 in fxty_pos p1 end
) (* end of [f0xty_tr] *)

in (* in of [local] *)

implement
d0ecl_fixity_tr (f0xty, ids) = let
//
fun loop (
  fxty: fxty, ids: i0delst
) : void =
  case+ glist_view (ids) of
  | ~GLcons (id, ids) => let
      val () = the_fxtyenv_add (id.i0de_sym (), fxty)
    in
      loop (fxty, ids)
    end
  | ~GLnil () => ()
// end of [loop]
in
  loop (f0xty_tr f0xty, ids)
end // end of [d0ecl_fixity_tr]

implement
d0ecl_nonfix_tr (ids) = let
  fun loop (ids: i0delst): void = case+ glist_view (ids) of
    | ~GLcons (id, ids) => begin
        the_fxtyenv_add (id.i0de_sym (), fxty_non); loop ids
      end // end of [cons]
    | ~GLnil () => () // end of [list_nil]
  // end of [loop]
in
  loop (ids)
end // end of [d0ecl_nonfix_tr]

end // end of [local]

(* ****** ****** *)

implement
s0tacst_tr
  (d0c) = let
  val loc = d0c.s0tacst_loc ()
  val sym = d0c.s0tacst_sym ()
  val fil = $FIL.filename_get_current()
  val arg = a0msrtlst_tr(d0c.s0tacst_arg ())
  val res: s1rt = s0rt_tr(d0c.s0tacst_res ())
  val extdef =
    scstextdef_tr(d0c, sym, d0c.s0tacst_extopt ())
  // end of [val]
in
//
s1tacst_make
  (loc, fil, d0c.s0tacst_sym (), arg, res, extdef)
//
end // end of [s0tacst_tr]

(* ****** ****** *)

implement
s0tacon_tr (d) = let
  val fil = $FIL.filename_get_current ()
  val arg = a0msrtlst_tr (d.s0tacon_arg ())
  val def: s1expopt = s0expopt_tr (d.s0tacon_def ())
in
  s1tacon_make (d.s0tacon_loc (), fil, d.s0tacon_sym (), arg, def)
end // end of [s0tacon_tr]

(* ****** ****** *)

implement
s0rtdef_tr (d) = let
  val s1te = s0rtext_tr (d.s0rtdef_def ())
in
  s1rtdef_make (d.s0rtdef_loc (), d.s0rtdef_sym (), s1te)
end // end of [s0rtdef_tr]

(* ****** ****** *)

implement
t0kindef_tr (d) = let
  val loc = d.t0kindef_loc ()
  val id = d.t0kindef_sym ()
  val loc_id = d.t0kindef_loc_id ()
  val def = s0exp_tr (d.t0kindef_def ())
in
  t1kindef_make (loc, id, loc_id, def)
end // end of [t0kindef_tr]

(* ****** ****** *)

implement
s0expdef_tr (d) = let
  val loc = d.s0expdef_loc ()
  val id = d.s0expdef_sym ()
  val loc_id = d.s0expdef_loc_id ()
  val arg = s0marglst_tr (d.s0expdef_arg ())
  val res = s0rtopt_tr (d.s0expdef_res ())
  val def = s0exp_tr (d.s0expdef_def ())
in
  s1expdef_make (loc, id, loc_id, arg, res, def)
end // end of [s0expdef_tr]

(* ****** ****** *)

implement
s0aspdec_tr (d) = let
  val arg =
    s0marglst_tr (d.s0aspdec_arg ())
  // end of [val]
  val res = s0rtopt_tr (d.s0aspdec_res ())
  val def = s0exp_tr (d.s0aspdec_def ())
in
  s1aspdec_make (d.s0aspdec_loc (), d.s0aspdec_qid (), arg, res, def)
end // end of [s0aspdec_tr]

(* ****** ****** *)

implement
d0atdec_tr (d) = let
  val arg = a0msrtlst_tr (d.d0atdec_arg ())
  val con = glist_map_fun<d0atcon,d1atcon> (d.d0atdec_con (), d0atcon_tr)
in
  d1atdec_make (
    d.d0atdec_loc (), d.d0atdec_fil (), d.d0atdec_sym (), arg, con
  ) // end of [d1atdec_make]
end // end of [d0atdec_tr]

(* ****** ****** *)

implement
e0xndec_tr (d) = let
  val qua = d.e0xndec_qua ()
  val qua = q0marglst_tr (qua)
  var npf0: int = ~1 // HX: default
  val arg = (case+ gopt_view (d.e0xndec_arg ()) of
    | ~GOsome s0e => let
        val s1e = s0exp_tr s0e in
        case+ s1exp_node_view (s1e.s1exp_node ()) of
        | ~S1Elist (npf, s1es) => (npf0 := npf; s1es)
        | v => (s1exp_node_view_free (v); glist_cons (s1e, glist_nil ()))
      end // end of [Some]
    | ~GOnone () => glist_nil ()
  ) : s1explst // end of [val]
in
  e1xndec_make (
    d.e0xndec_loc (), d.e0xndec_fil (), d.e0xndec_sym (), qua, npf0, arg
  ) // end of [e1xndec_make]
end // end of [e0xndec_tr]

(* ****** ****** *)

fun
token_get_dcstkind
  (tok: token): dcstkind = let
in
//
case+
  token_node_view (tok.token_node ()) of
| ~T_FUN (fk) => (
  case+ fk of
//
  | FK_fn () => DCKfun
  | FK_fun () => DCKfun
  | FK_fnx () => DCKfun
//
  | FK_prfn () => DCKprfun
  | FK_prfun () => DCKprfun
  | FK_praxi () => DCKpraxi
//
  | FK_castfn () => DCKcastfn
//
  ) // end of [T_FUN]
| ~T_VAL (vk) => (
  case+ vk of
//
  | VK_val () => DCKval
//
  | VK_prval () => DCKprval
//
  | VK_val_pos () => DCKval
  | VK_val_neg () => DCKval
//
  ) // end of [T_VAL]
| v => let
    val () = token_node_view_free (v)
    val () = assertloc (false) in DCKfun
  end // end of [_]
//
end // end of [token_get_dcstkind]

(* ****** ****** *)

fn m0acdef_tr
  (d: m0acdef): m1acdef = let
  val loc = d.m0acdef_loc ()
  val sym = d.m0acdef_sym ()
  val arg = m0acarglst_tr (d.m0acdef_arg ())
  val def = d0exp_tr (d.m0acdef_def ())
in
  m1acdef_make (loc, sym, arg, def)
end // end of [m0acdef_tr]

(* ****** ****** *)

fn v0aldec_tr
  (d: v0aldec): v1aldec = let
  val p1t = p0at_tr (d.v0aldec_pat ())
  val d1e = d0exp_tr (d.v0aldec_def ())
  val ann = witht0ype_tr (d.v0aldec_ann ())
in
  v1aldec_make (d.v0aldec_loc (), p1t, d1e, ann)
end // end of [v0aldec_tr]

(* ****** ****** *)

fn f0undec_tr
(
  isprf: bool, isrec: bool, d: f0undec
) : f1undec = let
//
val loc = d.f0undec_loc ()
//
val effopt = d.f0undec_eff ()
val @(
  fcopt, efcopt
) = (
  case+ gopt_view (effopt) of
  | ~GOsome eff => let
      val (fcopt, lin, prf, efc) = e0fftaglst_tr (eff)
    in
      @(fcopt, gopt_some efc)
    end (* end of [Some] *)
  | ~GOnone ((*void*)) => let
      val efc = (
        if isprf then effcst_EFFCSTnil () else effcst_EFFCSTall ()
      ) : effcst // end of [val]
    in
      @(None_vt ((*fcopt*)), gopt_some efc)
    end (* end of [None] *)
) : @(fcopt, effcstopt)
//
val d1e_def =
d0exp_tr_lams_dyn
(
  LAMKINDifix
, gopt_none ((*locopt*))
, fcopt, 0 (*lin*)
, d.f0undec_arg (), d.f0undec_res (), efcopt
, d.f0undec_def ()
) (* end of [d0exp_lams_dyn_tr] *) // end of [val]
//
val () =
if isrec then
  termet_check (loc, d1exp_is_metric d1e_def, efcopt)
// end of [if] // end of [val]
//
val ann = witht0ype_tr (d.f0undec_ann ())
//
in
  f1undec_make (loc, d.f0undec_sym (), d.f0undec_sym_loc (), d1e_def, ann)
end // end of [f0undec_tr]

(* ****** ****** *)

fun
f0undeclst_tr
(
  fk: funkind, ds: f0undeclst
) : f1undeclst = let
  val isprf = funkind_is_proof fk
  and isrec = funkind_is_recursive fk
in
//
case+ glist_view (ds) of
| ~GLnil () => glist_nil ()
| ~GLcons (d, ds) => let
    val d1 = f0undec_tr (isprf, isrec, d)
  in
    glist_cons (d1, f0undeclst_tr (fk, ds))
  end (* end of [cons] *)
//
end // end of [f0undeclst_tr]

(* ****** ****** *)

fn
v0ardec_tr
(
  d: v0ardec
) : v1ardec = let
  val loc = d.v0ardec_loc ()
  val knd = d.v0ardec_knd ()
  val pfat = d.v0ardec_pfat () // i0deopt
  val s1eopt = s0expopt_tr (d.v0ardec_type ())
  val d1eopt = d0expopt_tr (d.v0ardec_init ())
in
//
v1ardec_make
(
  loc, knd, d.v0ardec_sym (), d.v0ardec_sym_loc (), pfat, s1eopt, d1eopt
) (* end of [v1ardec_make] *)
//
end // end of [v0ardec_tr]

(* ****** ****** *)

fn
i0mpdec_tr
(
  d: i0mpdec
) : i1mpdec = let
  val loc = d.i0mpdec_loc ()
  val qid = d.i0mpdec_qid ()
  val tmparg = glist_map_fun<t0mpmarg,t1mpmarg> (qid.impqi0de_arg (), t0mpmarg_tr)
  val def =
    d0exp_tr_lams_dyn (
      LAMKINDifix
    , gopt_none((*locopt*)), None_vt((*fcopt*)), 0(*lin*)
    , d.i0mpdec_arg (), d.i0mpdec_res (), gopt_none((*efcopt*))
    , d.i0mpdec_def ()
    ) // end of [d0exp_lams_dyn_tr]
  // end of [val]
in
  i1mpdec_make (d.i0mpdec_loc (), qid, tmparg, def)
end // end of [i0mpdec_tr]

(* ****** ****** *)
//
fun
the_ATSRELOC_set_decl
  (d0c0: d0ecl): void =
  $GLOB.the_ATSRELOC_set_decl($UN.cast{ptr}(d0c0))
//
fun
the_ATSRELOC_set_decl_if
  (d0c0: d0ecl): void = () where
{
//
val srcloc = $GLOB.the_ATSRELOC_get()
val () = if srcloc > 0 then the_ATSRELOC_set_decl(d0c0)
//
} (* end of [the_ATSRELOC_set_decl_if] *)
//
(* ****** ****** *)

extern
fun
i0nclude_tr
(
  d0c0: d0ecl
, stadyn: int, given: string
) : d1eclist // endfun

implement
i0nclude_tr
(
  d0c0, stadyn, given
) = d1cs where
{
//
val
loc0 = d0c0.d0ecl_loc ()
//
val
((*void*)) =
the_ATSRELOC_set_decl_if(d0c0)
//
var
given2: string (* uninitized *)
//
val opt =
  $FIL.filenameopt_make_relative(given, given2)
//
val fil =
(
case+ opt of
| ~Some_vt (fil) => fil
| ~None_vt ((*void*)) => let
    val srcloc =
      $GLOB.the_ATSRELOC_get ()
    val () =
    if (
    srcloc = 0
    ) then {
//
      val () =
      prerr_error1_loc (loc0)
//
      val () =
      prerrln! (": the file [", given2, "] is not available for inclusion.")
//
      val () = the_trans1errlst_add(trans1err_T1E_i0nclude_tr(d0c0))
//
    } (* end of [if] *) // end of [val]
  in
    $FIL.filename_dummy
  end // end of [None_vt]
) : filename // end of [val]
//
val
d0cs =
$PAR.parse_from_filename_toplevel2
  (stadyn, fil)
//
val
(pfpush | isexi) =
$FIL.the_filenamelst_push_check(fil)
val () =
if isexi then let
  val () =
    $LOC.prerr_errloc(loc0)
  // end of [val]
  val () = prerr (": error(0)")
  val () = prerr (": including the file [");
  val () = $FIL.prerr_filename_full (fil)
  val () = prerr ("] generates the following looping trace:\n")
  val () = $FIL.fprint_the_filenamelst (stderr_ref)
  val () = the_trans1errlst_add (trans1err_T1E_i0nclude_tr (d0c0))
in
  $ERR.abort<void>((*reachable*))
end // end of [if] // end of [val]
val () = $FIL.the_filenamelst_pop(pfpush | (*none*))
//
val d1cs = d0eclist_tr (d0cs)
//
} // end of [i0nclude_tr]

(* ****** ****** *)

fun
ats_filename_get
  ((*void*)): string = let
//
val fil = $FIL.filename_get_current ()
val fname = $FIL.filename_get_fullname (fil)
//
in
  $SYM.symbol_get_name (fname)
end // end of [ats_filename_get]

(* ****** ****** *)

fun
ats_packname_get
  ((*void*)): Stropt = let
//
val opt = the_e1xpenv_find (ATS_PACKNAME)
//
in
//
case+ opt of
| ~Some_vt (exp) => (
  case+ e1xp_node_view (exp.e1xp_node ()) of
  | ~E1XPstring (ns) => stropt_some (ns)
  | v => let
      val () = e1xp_node_view_free (v)
      val () = prerr_warning1_loc (exp.e1xp_loc ())
      val () = prerrln! ": a string definition is required for [ATS_PACKNAME]."
    in
      stropt_none ((*void*))
    end // end of [_]
  ) // end of [Some_vt]
| ~None_vt ((*void*)) => stropt_none ((*void*))
//
end // end of [ats_packname_get]

(* ****** ****** *)

fun
ats_packname_get2
(
  opt: Stropt, nspace: symbol
) : Stropt = let
//
val opt2 = ats_packname_get ()
val issome = stropt_is_some (opt2)
//
in
//
if issome
  then opt2
  else let
    val issome = stropt_is_some (opt)
  in
    if issome
      then let
        val name = stropt_unsome (opt)
        val nspace = $SYM.symbol_get_name (nspace)
        val name = string0_append (name, nspace)
        val name = trans1_strptr2gstring (name)
      in
        stropt_some (name)
      end // end of [then]
      else let
        val name = ats_filename_get ()
        val nspace = $SYM.symbol_get_name (nspace)
        val name = string0_append (name, nspace)
        val name = trans1_strptr2gstring (name)
      in
        stropt_some (name)
      end // end of [else]
    // end of [if]
  end // end of [else]
//
end // end of [ats_packname_get2]

(* ****** ****** *)

%{^
//
#include <string.h>
//
static
atstype_bool
patsopt_string_suffix_is_dats
  (atstype_ptr s0) {
  char *s = strrchr ((char*)s0, '.') ;
  if (!s) return atsbool_false ;
  if (strcmp (s, ".dats") != 0) return atsbool_false ;
  return atsbool_true ;
} // end of [patsopt_string_suffix_is_dats]
//
%} // end of [%{^]

extern fun string_suffix_is_dats
  (s: string): bool = "mac#patsopt_string_suffix_is_dats"
// end of [string_suffix_is_dats]

(* ****** ****** *)

extern
fun
s0taload_tr
(
  d0c0: d0ecl
, idopt: symbolopt, given: string
, ldflag: &int? >> int
, filref: &filename? >> filename
) : d1eclist // end of [s0taload_tr]

(* ****** ****** *)

local

fun auxload
(
  fil: filename, ldflag: &int >> int
) : d1eclist = let
//
val
pname =
  $FIL.filename_get_partname(fil)
//
val
isdats = string_suffix_is_dats(pname)
//
val
flag =
(
  if isdats then 1(*dyn*) else 0(*sta*)
) : int // end of [val]
//
val
d0cs =
$PAR.parse_from_filename_toplevel2
  (flag, fil)
//
val () = the_trans1_env_save()
//
val (pfpush | ()) = $FIL.the_filenamelst_push(fil)
//
val d1cs = d0eclist_tr(d0cs) // HX: it is done in [fil]
//
val ((*void*)) = $FIL.the_filenamelst_pop(pfpush | (*none*))
//
val pack = ats_packname_get()
//
val
d1c_pack = d1ecl_packname(pack)
//
val d1cs = glist_cons(d1c_pack, d1cs)
//
val () = the_trans1_env_restore()
//
val ((*void*)) = staload_file_insert(fil, ldflag, d1cs)
//
in
  d1cs
end // end of [auxload]

in (* in of [local] *)

implement
s0taload_tr
(
  d0c0, idopt, given, ldflag, filref
) = let
//
val
loc0 = d0c0.d0ecl_loc ()
//
// HX-2014-06-06:
// [ldflag] is no longer in use for
val () = (ldflag := 0) // ATS_STALOADFLAG
//
val
((*void*)) =
the_ATSRELOC_set_decl_if(d0c0)
//
var
given2: string (* uninitized *)
//
val opt =
  $FIL.filenameopt_make_relative(given, given2)
//
val fil =
(
case+ opt of
| ~Some_vt(fil) => fil
| ~None_vt((*void*)) => let
//
    val
    srcloc =
    $GLOB.the_ATSRELOC_get()
//
    val () =
    if
    (srcloc = 0)
    then {
//
      val () =
      prerr_error1_loc(loc0)
//
      val () =
      prerrln! (": the file [", given2, "] is not available for staloading.")
//
      val () = the_trans1errlst_add(trans1err_T1E_s0taload_tr(d0c0))
//
    } (* end of [if] *) // end of [val]
  in
    $FIL.filename_dummy
  end // end of [None_vt]
) : filename // end of [val]
//
val
(pfpush | isexi) =
$FIL.the_filenamelst_push_check(fil)
//
val
((*void*)) =
if isexi then
{
  val () = $LOC.prerr_errloc (loc0)
  val () = prerr (": error(0)")
  val () = prerr (": staloading the file [");
  val () = $FIL.prerr_filename_full (fil)
  val () = prerr ("] generates the following looping trace:\n")
  val () = $FIL.fprint_the_filenamelst (stderr_ref)
  val () = the_trans1errlst_add (trans1err_T1E_s0taload_tr (d0c0))
  val () = $ERR.abort<void>((*reachable*))
} (* end of [if] *) // end of [val]
//
val
((*void*)) =
$FIL.the_filenamelst_pop(pfpush | (*none*))
//
val () = filref := fil
//
val opt = staload_file_search(fil)
//
in
//
case+ opt of
| ~Some_vt
  (
    flagd1cs
  ) => flagd1cs.1 where
  {
    val () = ldflag := flagd1cs.0
  } (* end of [Some_vt] *)
| ~None_vt() => auxload (fil, ldflag)
//
end // end of [s0taload_tr]

end // end of [local]

(* ****** ****** *)

extern
fun r0equire_tr
  (d0c0: d0ecl, given: string): filename
// end of [r0equire_tr]
extern
fun r0equire_tr_if
  (d0c0: d0ecl, given: string): filename
// end of [r0equire_tr_if]

implement
r0equire_tr
  (d0c0, given) = let
//
val srcloc = $GLOB.the_ATSRELOC_get ()
//
in
//
if srcloc > 0
  then r0equire_tr_if(d0c0, given) else $FIL.filename_dummy
//
end // end of [r0equire_tr]

implement
r0equire_tr_if
  (d0c0, given) = let
//
val
loc0 = d0c0.d0ecl_loc ()
//
val
((*void*)) =
the_ATSRELOC_set_decl(d0c0)
//
var
given2: string (* uninitized *)
//
val
filopt =
$FIL.filenameopt_make_relative(given, given2)
//
val
dbgflag = $GLOB.the_DEBUGATS_dbgflag_get((*void*))
val
((*void*)) =
(
//
// HX: generating debugging information
//
if
(dbgflag > 0)
then
(
prerr_error1_loc(loc0);
prerrln! (": the file [", given2, "] is required.")
) (* end of [if] *)
//
) (* end of [val] *)
//
in
//
case+ filopt of
| ~Some_vt(fil) => fil
| ~None_vt((*void*)) => $FIL.filename_dummy(*void*)
//
end // end of [r0equire_tr_if]

(* ****** ****** *)

extern
fun d0ynload_tr
  (d0c0: d0ecl, given: string): filename
// end of [d0ynload_tr]

implement
d0ynload_tr
  (d0c0, given) = let
//
val
loc0 = d0c0.d0ecl_loc ()
//
val
((*void*)) =
the_ATSRELOC_set_decl_if(d0c0)
//
var
given2: string (* uninitized *)
//
val opt =
  $FIL.filenameopt_make_relative(given, given2)
//
in
//
case+ opt of
| ~Some_vt (fil) => fil
| ~None_vt ((*void*)) => let
//
    val
    srcloc =
    $GLOB.the_ATSRELOC_get ()
//
    val () =
    if srcloc = 0 then {
//
      val () =
      prerr_error1_loc (loc0)
//
      val () =
      prerrln! (": the file [", given2, "] is not available for dynloading")
//
      val () = the_trans1errlst_add(trans1err_T1E_d0ynload_tr(d0c0))
//
    } (* end of [if] *) // end of [val]
  in
    $FIL.filename_dummy
  end // end of [None_vt]
//
end // end of [d0ynload_tr]

(* ****** ****** *)

fun
guad0ecl_tr
(
  knd: srpifkind, gd: guad0ecl
) : d1eclist = let
  fun loop (
    knd: srpifkind, gdn: guad0ecl_node
  ) : d1eclist =
    case+ guad0ecl_node_view (gdn) of
    | ~GD0Cone (e0xp, d0cs) => let
        val v1al = e1xp_valize_if (knd, e0xp_tr e0xp) in
        if v1al_is_true (v1al) then d0eclist_tr d0cs else glist_nil ()
      end // end of [GD0Cone]
    | ~GD0Ctwo (
        e0xp, d0cs_then, d0cs_else
      ) => let
        val v1al = e1xp_valize_if (knd, e0xp_tr e0xp)
      in
        if v1al_is_true v1al then
          d0eclist_tr d0cs_then else d0eclist_tr d0cs_else
        // end of [if]
      end // end of [GD0Ctwo]
    | ~GD0Ccons (
        e0xp, d0cs_then, knd_elif, gdn_else
      ) => let
        val v1al = e1xp_valize_if (knd, e0xp_tr e0xp)
      in
        if v1al_is_true v1al then
          d0eclist_tr d0cs_then else loop (knd_elif, gdn_else)
        // end of [if]
      end // end of [GD0Ccons]
  // end of [loop]
in
  loop (knd, gd.guad0ecl_node ())
end // end of [guad0ecl_tr]

(* ****** ****** *)

implement
d0ecl_tr (d0c0) = let
//
val loc0 = d0c0.d0ecl_loc ()
in
//
case+ d0ecl_node_view (d0c0.d0ecl_node ()) of
//
| ~D0Cfixity
    (f0xty, ids) => (
    d0ecl_fixity_tr (f0xty, ids); d1ecl_none (loc0)
  ) // end of [D0Cfixity]
| ~D0Cnonfix (ids) => let
    val () = d0ecl_nonfix_tr (ids) in d1ecl_none (loc0)
  end // end of [D0Cnonfix]
//
| ~D0Csymintr (ids) => d1ecl_symintr (loc0, ids)
| ~D0Csymelim (ids) => d1ecl_symelim (loc0, ids)
//
| ~D0Coverload
    (id, qid, pval) => d1ecl_overload (loc0, id, qid, pval)
  // end of [D0Coverload]
//
| ~D0Ce0xpdef
    (id, def) => let
    val def = (
      case+ gopt_view (def) of
      | ~GOsome e0xp => e0xp_tr e0xp | ~GOnone () => e1xp_none (loc0)
    ) : e1xp // end of [val]
    val () = the_e1xpenv_add (id, def)
  in
//
// HX-2011-04-27: [def] should not be normalized
    d1ecl_e1xpdef (loc0, id, def) // as dynamic-binding is assumed.
  end // end of [D0Ce0xpdef]
| ~D0Ce0xpundef (id) => let
    val def = e1xp_undef (loc0)
    val ((*void*)) = the_e1xpenv_add (id, def)
  in
    d1ecl_e1xpundef (loc0, id, def)
  end // end of [D0Ce0xpundef]
//
| ~D0Ce0xpact
    (knd, e0xp) => let
    val e1xp = e0xp_tr (e0xp)
    val v1al = e1xp_valize (e1xp)
    val () =
    ( case+ knd of
      | E0XPACTerror() =>
          do_e0xpact_error(e0xp.e0xp_loc (), v1al)
        // end of [E0XPACTerror]
      | E0XPACTprerr() => do_e0xpact_prerr(v1al)
      | E0XPACTprint() => do_e0xpact_print(v1al)
      | E0XPACTassert() =>
          do_e0xpact_assert (e0xp.e0xp_loc (), v1al)
        // end of [E0XPACTassert]
    ) : void // end of [val]
  in
    d1ecl_none (loc0)
  end // end of [D0Ce0xpact]
//
| ~D0Cpragma
    (e0xps) => let
    val
    e1xps =
    e0xplst_tr(e0xps)
  in
    d1ecl_pragma(loc0, e1xps)
  end // end of [D0Cpragma]
| ~D0Ccodegen
    (knd, e0xps) => let
    val
    e1xps = e0xplst_tr(e0xps)
  in
    d1ecl_codegen(loc0, knd, e1xps)
  end // end of [D0Ccodegen]
//
| ~D0Cdatsrts (d0cs) => let
    val d1cs =
    glist_map_fun<d0atsrtdec,d1atsrtdec>
      (d0cs, d0atsrtdec_tr)
    // end of [val]
  in
    d1ecl_datsrts (loc0, d1cs)
  end // end of [D0Cdatsrts]
| ~D0Csrtdefs (d0cs) => let
    val d1cs =
    glist_map_fun<s0rtdef,s1rtdef>(d0cs, s0rtdef_tr)
  in
    d1ecl_srtdefs (loc0, d1cs)
  end // end of [D0Csrtdefs]
//
| ~D0Cstacsts (d0cs) => let
    val d1cs =
    glist_map_fun<s0tacst,s1tacst>(d0cs, s0tacst_tr)
  in
    d1ecl_stacsts (loc0, d1cs)
  end // end of [D0Cstacsts]
| ~D0Cstacons (knd, d0cs) => let
    val d1cs =
    glist_map_fun<s0tacon,s1tacon>(d0cs, s0tacon_tr)
  in
    d1ecl_stacons (loc0, knd, d1cs)
  end // end of [D0Cstacons]
//
| ~D0Ctkindef (d0c) =>
    d1ecl_tkindef (loc0, t0kindef_tr d0c)
| ~D0Csexpdefs (knd, d0cs) => let
    val d1cs =
    glist_map_fun<s0expdef,s1expdef>(d0cs, s0expdef_tr)
  in
    d1ecl_sexpdefs (loc0, knd, d1cs)
  end // end of [D0Csexpdefs]
//
| ~D0Csaspdec(d0c) =>
    d1ecl_saspdec(loc0, s0aspdec_tr (d0c))
  // end of [D0Csaspdec]
//
| ~D0Creassume(qid) => d1ecl_reassume(loc0, qid)
//
| ~D0Cexndecs(d0cs) => let
    val d1cs =
    glist_map_fun<e0xndec,e1xndec>(d0cs, e0xndec_tr)
  in
    d1ecl_exndecs(loc0, d1cs)
  end // end of [D0Cexndecs]
| ~D0Cdatdecs(knd, d0cs1, d0cs2) => let
    val d1cs1 = glist_map_fun<d0atdec,d1atdec>(d0cs1, d0atdec_tr)
    val d1cs2 = glist_map_fun<s0expdef,s1expdef>(d0cs2, s0expdef_tr)
  in
    d1ecl_datdecs(loc0, knd, d1cs1, d1cs2)
  end // end of [D0Cdatdecs]
//
| ~D0Cclassdec (id, sup) => let
    val sup = s0expopt_tr (sup) in d1ecl_classdec (loc0, id, sup)
  end // end of [D0Cclassdec]
//
| ~D0Cextype (name, def) => let
    val def = s0exp_tr (def) in d1ecl_extype (loc0, name, def)
  end // end of [D0Cextype]
| ~D0Cextype2 (knd, name, def) => let
    val def = s0exp_tr (def) in d1ecl_extype2 (loc0, knd, name, def)
  end // end of [D0Cextype]
| ~D0Cextvar (name, def) => let
    val def = d0exp_tr (def) in d1ecl_extvar (loc0, name, def)
  end // end of [D0Cextvar]
| ~D0Cextcode (knd, pos, code) => d1ecl_extcode (loc0, knd, pos, code)
//
| ~D0Cdcstdecs
  (
    knd, tok, qarg, d0cs // knd: 0/1: static/dynamic
  ) => let
//
    val dck =
      token_get_dcstkind(tok)
    // end of [val]
//
    val isfun = dcstkind_is_fun(dck)
    and isprf = dcstkind_is_proof(dck)
//
    val qarg = q0marglst_tr(qarg)
    val d1cs = d0cstdeclst_tr(isfun, isprf, d0cs)
  in
    d1ecl_dcstdecs(loc0, knd, dck, qarg, d1cs)
  end // end of [D0Cdcstdecs]
//
| ~D0Cmacdefs
    (knd, isrec, d0cs) => let
    // knd: 0/1 => short/long
    val d1cs =
    glist_map_fun<m0acdef,m1acdef> (d0cs, m0acdef_tr)
  in
    d1ecl_macdefs (loc0, knd, isrec, d1cs)
  end // end of [D0Cmacdefs]
//
| ~D0Cfundecs (knd, qarg, d0cs) => let
    val qarg = q0marglst_tr (qarg)
    val d1cs = f0undeclst_tr (knd, d0cs)
  in
    d1ecl_fundecs (loc0, knd, qarg, d1cs)
  end // end of [D0Cfundecs]
| ~D0Cvaldecs (knd, isrec, d0cs) => let
    val d1cs = glist_map_fun<v0aldec,v1aldec> (d0cs, v0aldec_tr)
  in
    d1ecl_valdecs (loc0, knd, isrec, d1cs)
  end // end of [D0Cvaldecs]
| ~D0Cvardecs (knd, d0cs) => let
    val d1cs =
    glist_map_fun<v0ardec,v1ardec> (d0cs, v0ardec_tr)
  in
    d1ecl_vardecs (loc0, knd, d1cs)
  end // end of [D0Cvardecs]
//
| ~D0Cimpdec
    (knd, i0mparg, d0c) => let
    val i1mparg = i0mparg_tr (i0mparg) in
    d1ecl_impdec (loc0, knd, i1mparg, i0mpdec_tr d0c)
  end (* end of [D0Cimpdec] *)
//
| ~D0Cinclude
    (pfil, stadyn, given) => let
//
    val
    (pfpush | ()) =
    $FIL.the_filenamelst_push(pfil)
//
    val d1cs = i0nclude_tr(d0c0, stadyn, given)
//
    val ((*void*)) =
      $FIL.the_filenamelst_pop(pfpush | (*none*))
    // end of [val]
//
  in
    d1ecl_include(loc0, stadyn, d1cs)
  end // end of [D0Cinclude]
//
| ~D0Cstaload
  (
    pfil, idopt, given
  ) => let
//
    var ldflag: int // unitialized
    var fil: filename // unitialized
//
    val
    (pfpush | ()) =
    $FIL.the_filenamelst_push(pfil)
//
    val
    d1cs =
    s0taload_tr(d0c0, idopt, given, ldflag, fil)
//
    val ((*void*)) =
      $FIL.the_filenamelst_pop(pfpush | (*none*))
    // end of [val]
//
  in
    d1ecl_staload(loc0, idopt, fil, ldflag, d1cs)
  end // end of [D0Cstaload]
//
| ~D0Cstaloadnm
    (pfil, name, nspace) =>
    d1ecl_staloadnm(loc0, name(*=alias*), nspace)
  // end of [D0Cstaloadnm]
//
| ~D0Cstaloadloc
  (
    pfil, nspace, d0cs
  ) => let
//
    val opt = ats_packname_get()
//
    val () = the_trans1_env_save((*void*))
//
    val d1cs = d0eclist_tr(d0cs) // HX: done in [pfil]
//
    val pack =
      ats_packname_get2(opt, nspace)
    // end of [val]
//
// HX: [d1c_pack]: treated as a special decl
//
    val d1c_pack = d1ecl_packname(pack)
    val d1cs_new = glist_cons(d1c_pack, d1cs)
//
    val ((*void*)) =
      the_trans1_env_restore((*none*))
    // end of [val]
  in
    d1ecl_staloadloc(loc0, pfil, nspace, d1cs_new)
  end // end of [D0Cstaloadloc]
//
| ~D0Crequire
    (pfil, given) => let
    val cfil =
      r0equire_tr(d0c0, given) in d1ecl_none(loc0)
    // end of [val]
  end // end of [D0Crequire]
//
| ~D0Cdynload
    (pfil, given) =>
    d1ecl_dynload(loc0, cfil) where
  {
//
    val
    (pfpush | ()) =
    $FIL.the_filenamelst_push(pfil)
//
    val cfil = d0ynload_tr (d0c0, given)
//
    val ((*void*)) =
      $FIL.the_filenamelst_pop(pfpush | (*none*))
    // end of [val]
//
  } (* end of [D0Cdynload] *)
//
| ~D0Clocal
  (
    d0cs_head, d0cs_body
  ) => let
    val () = the_trans1_env_push ()
    val d1cs_head = d0eclist_tr (d0cs_head)
    val () = the_trans1_env_push ((*none*))
    val d1cs_body = d0eclist_tr (d0cs_body)
    val () = the_trans1_env_localjoin ((*none*))
  in
    d1ecl_local (d0c0.d0ecl_loc (), d1cs_head, d1cs_body)
  end // end of [D0Clocal]
//
| ~D0Cguadecl (knd, gd0c) => let
    val d1cs = guad0ecl_tr (knd, gd0c) in d1ecl_list (loc0, d1cs)
  end (* end of [D0Cguadecl] *)
//
end // end of [d0ecl_tr]

implement
d0eclist_tr (d0cs) =
  glist_map_fun_g<d0ecl,d1ecl> (d0cs, d0ecl_tr)
// end of [d0eclist_tr]

(* ****** ****** *)

implement
d0eclist_tr_errck
  (d0cs) = d1cs where
{
//
val d1cs = d0eclist_tr (d0cs)
//
val opt = ats_packname_get ()
val isnone = stropt_is_none (opt)
//
val d1cs =
(
//
// HX-2013-06:
// for [PACKNAME] to be set externally
//
if isnone
  then d1cs
  else let
    val d1c_pack =
      d1ecl_packname (opt)
    // end of [val]
  in
    glist_cons (d1c_pack, d1cs)
  end // end of [else]
// end of [if]
) : d1eclist // end of [val]
//
val () = the_trans1errlst_finalize()
//
} // end of [d0eclist_tr_errck]

(* ****** ****** *)

local

fun
intrep2int
  (rep: string): int = let
//
val x =
$UT.llint_make_string(rep) in $UN.cast{int}(x)
//
end // end of [intrep2int]

fun
aux_dynloadflag(): void = let
  val opt = the_e1xpenv_find( ATS_DYNLOADFLAG )
in
//
case+ opt of
| ~Some_vt(e) =>
  (
  case+ e1xp_node_view (e.e1xp_node ()) of
  | ~E1XPint(x) =>
      $GLOB.the_DYNLOADFLAG_set(x)
  | ~E1XPintrep(rep) =>
      $GLOB.the_DYNLOADFLAG_set(intrep2int(rep))
  | v (*rest-of-e1xp*) => let
      val () = e1xp_node_view_free (v)
      val () =
      prerr_error1_loc(e.e1xp_loc ())
      val () =
      prerrln! (": non-integer definition for [ATS_DYNLOADFLAG].")
    in
      $ERR.abort<void>((*reachable*)) // HX: is it meaningful to continue?
    end // end of [_]
  ) (* end of [Some_vt] *)
//
// HX: [ATS_DYNLOADFLAG] is set to 1 by default
//
| ~None_vt((*void*)) => ()
//
end // end of [aux_dynloadflag]

fun
aux_dynloadname
(
) : void = let
//
val opt =
the_e1xpenv_find(ATS_DYNLOADNAME)
//
in
//
case+ opt of
| ~Some_vt(e) =>
  (
  case+ e1xp_node_view (e.e1xp_node ()) of
  | ~E1XPstring(x) =>
    $GLOB.the_DYNLOADNAME_set_name(x)
  | v (*non-E1XPstring*) => let
      val () = e1xp_node_view_free (v)
      val () =
        prerr_error1_loc( e.e1xp_loc () )
      val () =
        prerrln!(": non-string definition for [ATS_DYNLOADNAME].")
    in
       $ERR.abort<void>((*reachable*)) // HX: is it meaningful to continue?
    end // end of [_]
  ) (* end of [Some_vt] *)
//
// HX: the [ATS_DYNLOADNAME] is set to stropt_none
//
| ~None_vt((*void*)) => ()
//
end // end of [aux_dynloadname]

fun
aux_mainatsflag
(
// argless
) : void = let
//
val opt =
  the_e1xpenv_find(ATS_MAINATSFLAG)
//
in
//
case+ opt of
| ~Some_vt(e) =>
  (
  case+ e1xp_node_view (e.e1xp_node ()) of
  | ~E1XPint(x) =>
      $GLOB.the_MAINATSFLAG_set (x)
  | ~E1XPintrep(rep) =>
      $GLOB.the_MAINATSFLAG_set (intrep2int(rep))
  | v (* rest-of-e1xp *)=> let
      val () = e1xp_node_view_free (v)
      val () =
      prerr_error1_loc(e.e1xp_loc ())
      val () =
      prerrln! (": non-integer definition for [ATS_MAINATSFLAG].")
    in
       $ERR.abort<void>((*reachable*)) // HX: is it meaningful to continue?
    end // end of [_]
  ) (* end of [Some_vt] *)
//
// HX: the [ATS_MAINATSFLAG] is set to 0 by default
//
| ~None_vt ((*void*)) => ()
//
end // end of [aux_mainatsflag]

fun
aux_static_prefix
(
// argless
) : void = let
  val opt =
  the_e1xpenv_find(ATS_STATIC_PREFIX)
in
//
case+ opt of
| ~Some_vt(e) =>
  (
  case+ e1xp_node_view (e.e1xp_node ()) of
  | ~E1XPstring(x) =>
    $GLOB.the_STATIC_PREFIX_set_name(x)
  | v (* non-E1XPstring *) => let
      val () = e1xp_node_view_free (v)
      val () =
        prerr_error1_loc( e.e1xp_loc () )
      val () =
        prerrln!(": non-string definition for [ATS_STATIC_PREFIX].")
    in
       $ERR.abort<void>((*reachable*)) // HX: is it meaningful to continue?
    end // end of [_]
  ) (* end of [Some_vt] *)
//
// HX: the [ATS_STATIC_PREFIX] is set to stropt_none
//
| ~None_vt((*void*)) => ()
//
end // end of [aux_static_prefix]

in (* in of [local] *)

implement
trans1_finalize() =
{
//
  val () = aux_dynloadflag()
  val () = aux_dynloadname()
  val () = aux_mainatsflag()
  val () = aux_static_prefix()
//
  val () = $FIL.the_filenamelst_ppop((*void*))
//
} (* end of [trans1_finalize] *)

end // end of [local]

(* ****** ****** *)

(* end of [pats_trans1_decl.dats] *)
