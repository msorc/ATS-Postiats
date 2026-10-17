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
// Start Time: October, 2012
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_ccomp_funlab.dats, see PORTING.md, "ccomp core modules")
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

staload UT = "./pats_utils.sats"
staload _(*anon*) = "./pats_utils.dats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)

staload ERR = "./pats_error.sats"
staload _(*anon*) = "./pats_error.dats"

(* ****** ****** *)
//
staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
//
implement
prerr_FILENAME<>
  ((*void*)) = prerr "pats_ccomp_funlab"
//
(* ****** ****** *)

staload
STMP = "./pats_stamp.sats"
typedef stamp = $STMP.stamp

(* ****** ****** *)

staload GLOB = "./pats_global.sats"

(* ****** ****** *)

staload SYM = "./pats_symbol.sats"
staload SYN = "./pats_syntax.sats"

(* ****** ****** *)

staload "./pats_staexp2.sats"
staload "./pats_dynexp2.sats"

(* ****** ****** *)

staload "./pats_trans2_env.sats"

(* ****** ****** *)

staload "./pats_histaexp.sats"
staload "./pats_hidynexp.sats"

(* ****** ****** *)

staload "./pats_ccomp.sats"

(* ****** ****** *)

local

fn
strptr2gstring
  (str: Strptr1): string = let
  val res = the_garena_strdup ($UN.castvwtp1{string}(str))
  val ((*freed*)) = strptr_free (str)
in
  res
end // end of [strptr2gstring]

in (* in-of-local *)

fn
string_app2
  (x1: string, x2: string): string =
  strptr2gstring (string0_append (x1, x2))
// end of [string_app2]

fn
string_app3
  (x1: string, x2: string, x3: string): string =
  strptr2gstring (string0_append3 (x1, x2, x3))
// end of [string_app3]

end // end of [local]

(* ****** ****** *)

implement
funlab_make
(
  name, level, hse, fcopt, qopt, sopt, t2mas, stamp
) = let
//
val fc =
(
case+ fcopt of
| ~Some_vt (fc) => fc
| ~None_vt () => (
  case+ hisexp_node_view (hse.hisexp_node ()) of
  | ~HSEfun (fc, _, _) => fc
  | v => (hisexp_node_view_free (v); FUNCLOfun ())
  ) // end of [None_vt]
) : funclo // end of [val]
//
in
//
funlab_new
(
  name, level, fc, hse
, ~1 (*tmpknd*)
, qopt (*global*), sopt (*static*)
, 0 (*ncopy*), gopt_none((*void*)) (*origin*), 0 (*suffix*)
, t2mas
, gopt_none((*void*)) (*funent*)
, stamp
) (* end of [funlab_new] *)
//
end // end of [funlab_make]

(* ****** ****** *)

implement
funlab_get_name (flab) = funlab_name (flab)

(* HX-2026-10: [pats_histaexp_funlab.dats] (the placeholder funlab) calls this C function *)
extern
fun funlab_get_name_c (flab: funlab): string = "ext#patsopt_funlab_get_name"
implement
funlab_get_name_c (flab) = funlab_name (flab)

implement
funlab_get_level (flab) = funlab_level (flab)

implement
funlab_get_type (flab) = funlab_type (flab)

implement
funlab_get_funclo (flab) = funlab_funclo (flab)

implement
funlab_get_tmpknd (flab) = funlab_tmpknd (flab)
implement
funlab_set_tmpknd (flab, knd) = set_funlab_tmpknd (flab, knd)

implement
funlab_get_d2copt (flab) = funlab_d2copt (flab)
implement
funlab_get_d2vopt (flab) = funlab_d2vopt (flab)

implement
funlab_get_ncopy (flab) = funlab_ncopy (flab)
implement
funlab_set_ncopy (flab, cnt) = set_funlab_ncopy (flab, cnt)

implement
funlab_get_origin (flab) = funlab_origin (flab)
implement
funlab_set_origin (flab, opt) = set_funlab_origin (flab, opt)

implement
funlab_get_suffix (flab) = funlab_suffix (flab)
implement
funlab_set_suffix (flab, sfx) = set_funlab_suffix (flab, sfx)

implement
funlab_get_tmparg (flab) = funlab_tmparg (flab)

implement
funlab_get_funent (flab) = funlab_funent (flab)
implement
funlab_set_funent (flab, opt) = set_funlab_funent (flab, opt)

implement
funlab_get_stamp
  (flab) = $effmask_all (funlab_stamp (flab))

(* ****** ****** *)

implement
funlab_get_type_arg
  (flab) = let
  val hse = funlab_get_type (flab)
in
//
case+ hisexp_node_view (hse.hisexp_node ()) of
| ~HSEfun (
    _(*fc*), _arg, _(*res*)
  ) => _arg
| v => let
    val () = hisexp_node_view_free (v)
    val () = prerr_interror ()
    val () = prerr_string (": funlab_get_type_arg: hse = ")
    val () = prerr_hisexp (hse)
    val () = prerr_newline ()
    val () = assertloc (false)
  in
    $ERR.abort_interr<hisexplst> () // HX: this is deadcode
  end (* end of [_] *)
//
end // end of [funlab_get_type_arg]

implement
funlab_get_type_res
  (flab) = let
  val hse = funlab_get_type (flab)
in
//
case+ hisexp_node_view (hse.hisexp_node ()) of
| ~HSEfun (
    _(*fc*), _(*arg*), _res
  ) => _res
| v => let
    val () = hisexp_node_view_free (v)
    val () = prerr_interror ()
    val () = prerr_string (": funlab_get_type_arg: hse = ")
    val () = prerr_hisexp (hse)
    val () = prerr_newline ()
    val () = assertloc (false)
  in
    $ERR.abort_interr<hisexp> () // HX: this is deadcode
  end (* end of [_] *)
//
end // end of [funlab_get_type_res]

(* ****** ****** *)

implement
funlab_incget_ncopy
  (flab) = cnt1 where {
  val cnt = funlab_get_ncopy (flab)
  val cnt1 = cnt + 1
  val () = funlab_set_ncopy (flab, cnt1)
} // end of [funlab_incget_ncopy]

(* ****** ****** *)

implement
funlab_make_type
  (hse) = let
  val lvl0 = the_d2varlev_get ()
  val fcopt = None_vt() // HX: by [hse]
  val stamp = $STMP.funlab_stamp_make ()
  val opt = $GLOB.the_STATIC_PREFIX_get ()
  val flname =
  (
    if stropt_is_some(opt)
      then string_app2 (stropt_unsome(opt), "patsfun_") else "__patsfun_"
    // end of [if]
  ) : string // end of [val]
  val flname2 = $STMP.tostring_prefix_stamp (flname, stamp)
in
//
funlab_make
(
  flname2, lvl0, hse, fcopt, gopt_none((*qopt*)), gopt_none((*sopt*)), glist_nil((*t2mas*)), stamp
)
//
end // end of [funlab_make_type]

(* ****** ****** *)

local

fun
d2cst_get_gname
  (d2c: d2cst): string = let
  val extdef = d2cst_get_extdef (d2c)
in
  case+ $SYN.dcstextdef_view (extdef) of
//
  | ~$SYN.DCSTEXTDEFnone (knd) => let
      val sym = d2cst_get_sym (d2c) in $SYM.symbol_get_name (sym)
    end // end of [DCSTEXTDEFnone]
//
  | ~$SYN.DCSTEXTDEFsome_ext (name) => name
  | ~$SYN.DCSTEXTDEFsome_mac (name) => name
  | ~$SYN.DCSTEXTDEFsome_sta (name) => name
//
end // end of [d2cst_get_gname]

fun flname_make
(
  d2c: d2cst, stamp: stamp
) : string = let
  val d2c2 = d2cst_get_gname (d2c)
  val stamp2 = $STMP.tostring_stamp (stamp)
in
  string_app3 (d2c2, "$", stamp2)
end // end of [flname_make]

in (* in of [local] *)

implement
funlab_make_dcst_type
  (d2c, hse, fcopt) = let
  val lvl0 = the_d2varlev_get ()
  val qopt = gopt_some (d2c)
  val t2mas = glist_nil ()
  val stamp = $STMP.funlab_stamp_make ()
  val flname = flname_make (d2c, stamp)
in
//
funlab_make
(
  flname, lvl0, hse, fcopt, qopt, gopt_none((*sopt*)), t2mas, stamp
)
//
end // end of [funlab_make_dcst_type]

implement
funlab_make_tmpcst_type
(
  d2c, t2mas, hse, fcopt
) = let
  val lvl0 = the_d2varlev_get ()
  val qopt = gopt_some (d2c)
  val stamp = $STMP.funlab_stamp_make ()
  val flname = flname_make (d2c, stamp)
in
//
funlab_make
(
  flname, lvl0, hse, fcopt, qopt, gopt_none((*sopt*)), t2mas, stamp
) (* end of [funlab_make] *)
//
end // end of [funlab_make_tmpcst_type]

end // end of [local]

(* ****** ****** *)

local

fun
flname_make
(
  d2v: d2var, stamp: stamp
) : string = let
//
  val opt =
    $GLOB.the_STATIC_PREFIX_get ()
  val issome = stropt_is_some (opt)
//
  val d2v2 =
    $SYM.symbol_get_name (d2var_get_sym (d2v))
  // end of [val]
  val stamp2 = $STMP.tostring_stamp (stamp)
//
  val d2v3 = string_app3 (d2v2, "_", stamp2)
//
in
//
if
issome
then string_app2 (stropt_unsome(opt), d2v3) else d2v3
//
end // end of [flname_make]

in (* in of [local] *)

implement
funlab_make_dvar_type
  (d2v, hse, fcopt) = let
  val lvl0 = the_d2varlev_get ()
  val sopt = gopt_some (d2v)
  val t2mas = glist_nil ()
  val stamp = $STMP.funlab_stamp_make ()
  val flname = flname_make (d2v, stamp)
in
//
funlab_make
(
  flname, lvl0, hse, fcopt, gopt_none((*qopt*)), sopt, t2mas, stamp
) (* end of [funlab] *)
//
end // end of [funlab_make_dvar_type]

end // end of [local]

(* ****** ****** *)

implement
fprint_funlab
  (out, flab) = let
  val name = funlab_get_name (flab)
  val () = fprint_string (out, name)
  val sfx = funlab_get_suffix (flab)
  val () = fprint_string (out, "$")
  val () = fprint_int (out, sfx)
  val flev = funlab_get_level (flab)
  val () = fprint_string (out, "(level=")
  val () = fprint_int (out, flev)
  val () = fprint_string (out, ")")
in
  // nothing
end // end of [fprint_funlab]

implement
print_funlab (flab) = fprint_funlab (stdout_ref, flab)
implement
prerr_funlab (flab) = fprint_funlab (stderr_ref, flab)

(* ****** ****** *)

implement
fprint_funlablst
  (out, fls) = let
//
val () = $UT.fprintlst<funlab> (out, fls, ", ", fprint_funlab)
//
in
  // nothing
end // end of [fprint_funlablst]

(* ****** ****** *)

implement
fprint_funlablstopt
  (out, opt) = let
in
//
if gopt_is_some (opt) then let
  val () = fprint_string (out, "Some(")
  val () = fprint_funlablst (out, gopt_unsome (opt))
in
  fprint_string (out, ")")
end else fprint_string (out, "None()")
//
end // end of [fprint_funlablstopt]

(* ****** ****** *)

local

staload
LS = "libats/SATS/linset_avltree.sats"
staload
_(*anon*) = "libats/DATS/linset_avltree.dats"

assume funlabset_vtype = $LS.set (funlab)

implement
$LS.compare_elt_elt<funlab> (x, y) = let
  val sgn = $STMP.compare_stamp_stamp (funlab_get_stamp (x), funlab_get_stamp (y))
in
  $UN.cast{int}(sgn)
end // end of [compare_elt_elt]

in (* in of [local] *)

implement
funlabset_vt_nil () = $LS.linset_make_nil ()

implement
funlabset_vt_free (fls) = $LS.linset_free (fls)

implement
funlabset_vt_ismem
  (fls, fl) = $LS.linset_is_member (fls, fl)
// end of [funlabset_vt_ismem]

implement
funlabset_vt_add
  (fls, fl) = fls where
{
  var fls = fls
  val _(*exists*) = $LS.linset_insert (fls, fl)
} // end of [funlabset_vt_add]

implement
funlabset_vt_listize (fls) = $LS.linset_listize ($LS.linset_copy (fls))
implement
funlabset_vt_listize_free (fls) = $LS.linset_listize (fls)

end // end of [local]

implement
funlablst2set (fls) = let
//
fun loop
(
  fls: funlablst, res: funlabset_vt
) : funlabset_vt = let
in
//
if glist_is_cons (fls) then let
  val res = funlabset_vt_add (res, glist_head (fls)) in loop (glist_tail (fls), res)
end else res
//
end (* end of [loop] *)
//
in
  loop (fls, funlabset_vt_nil ())
end // end of [funlablst2set]

(* ****** ****** *)

implement
fprint_funlabset_vt
  (out, fls) = let
  val fls = funlabset_vt_listize (fls)
  val ((*void*)) = fprint_funlablst (out, glist_make_list_vt (fls))
in
  // nothing
end // end of [fprint_funlabset_vt]

(* ****** ****** *)

(* end of [pats_ccomp_funlab.dats] *)
