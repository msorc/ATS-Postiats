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
// HX-2026-10: no GC (ATS2 port of src/pats_ccomp_d2env.dats, see PORTING.md, "ccomp core modules")
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

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

staload "./pats_staexp2.sats"
staload "./pats_dynexp2.sats"

(* ****** ****** *)

staload "./pats_histaexp.sats"
staload "./pats_hidynexp.sats"

(* ****** ****** *)

staload "./pats_ccomp.sats"

(* ****** ****** *)

implement
d2env_get_var (d2e) = $effmask_all (d2env_var (d2e))

implement
d2env_get_type (d2e) = $effmask_all (d2env_type (d2e))

implement
d2env_make (d2v, hse) = d2env_new (d2v, hse)

(* ****** ****** *)

implement
d2var2env (d2v) = let
//
val opt = d2var_get2_hisexp (d2v)
//
val () = assertloc (gopt_is_some (opt)) // HX: val-Some(hse) = opt
val hse = gopt_unsome (opt)
//
in
  d2env_make (d2v, hse)
end // end of [d2var2env]

(* ****** ****** *)

local

staload
LS = "libats/SATS/linset_avltree.sats"
staload _ = "libats/DATS/linset_avltree.dats"

assume d2envset_vtype = $LS.set (d2env)

implement
$LS.compare_elt_elt<d2env> (d2e1, d2e2) = let
  val sgn = compare_d2var_d2var (d2env_get_var (d2e1), d2env_get_var (d2e2))
in
  $UN.cast{int}(sgn)
end // end of [compare_elt_elt]

in (* in of [local] *)

implement
d2envset_vt_nil () = $effmask_all ($LS.linset_make_nil ())

implement
d2envset_vt_free (xs) = $effmask_all ($LS.linset_free (xs))

implement
d2envset_vt_add
  (xs, x) = xs where {
  var xs = xs
  val _(*replaced*) = $effmask_wrt ($LS.linset_insert (xs, x))
} // end of [d2envset_vt_add]

implement
d2envset_vt_listize (xs) = $effmask_all ($LS.linset_listize ($LS.linset_copy (xs)))
implement
d2envset_vt_listize_free (xs) = $effmask_all ($LS.linset_listize (xs))

end // end of [local]

(* ****** ****** *)

implement
d2envlst2set (d2es) = let
//
fun loop
(
  d2es: d2envlst, res: d2envset_vt
) : d2envset_vt = let
in
//
if glist_is_cons (d2es)
  then loop (glist_tail (d2es), d2envset_vt_add (res, glist_head (d2es)))
  else res
//
end (* end of [loop] *)
//
in
  loop (d2es, d2envset_vt_nil ())
end (* end of [d2envlst2set] *)

(* ****** ****** *)

implement
fprint_d2env
  (out, d2e) = let
//
val d2v = d2env_get_var (d2e)
val hse = d2env_get_type (d2e)
//
val () = fprint_d2var (out, d2v)
val () =
(
  fprint_string (out, "("); fprint_hisexp (out, hse); fprint_string (out, ")")
)
//
in
  // nothing
end // end of [fprint_d2env]

(* ****** ****** *)

implement
fprint_d2envlst
  (out, d2es) = let
in
  $UT.fprintlst<d2env> (out, d2es, ", ", fprint_d2env)
end // end of [fprint_d2envlst]

(* ****** ****** *)

implement
fprint_d2envlstopt
  (out, opt) = let
in
//
if gopt_is_some (opt) then let
  val () = fprint_string (out, "Some(")
  val () = fprint_d2envlst (out, gopt_unsome (opt))
in
  fprint_string (out, ")")
end else fprint_string (out, "None()")
//
end // end of [fprint_d2envlstopt]

(* ****** ****** *)

(* end of [pats_ccomp_d2env.dats] *)
