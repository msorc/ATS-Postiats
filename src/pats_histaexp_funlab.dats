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
// Start Time: July, 2012
//
(* ****** ****** *)
//
// HX-2012-10:
// Note that [funlab_type] is assumed in [pats_ccomp.sats]
//
(* ****** ****** *)

(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_histaexp_funlab.dats)
//
#include "share/atspre_staload.hats"
//
(* ****** ****** *)

staload "./pats_histaexp.sats"

(* ****** ****** *)
//
// HX-2026-10: [pats_ccomp.sats] is not ported yet: the name of a funlab
// is obtained through a C function that [pats_ccomp.dats] will implement
// (it is [funlab_get_name] there); the tests give it in C.
//
%{^
extern atstype_ptr patsopt_funlab_get_name (atstype_ptr) ;
%}
extern
fun funlab_get_name
  (fl: funlab): string = "ext#patsopt_funlab_get_name"
// end of [funlab_get_name]

(* ****** ****** *)

implement
fprint_funlab
  (out, fl) = let
  val name = funlab_get_name (fl)
in
  fprint_string (out, name)
end // end of [fprint_funlab]

implement
print_funlab (fl) = fprint_funlab (stdout_ref, fl)
implement
prerr_funlab (fl) = fprint_funlab (stderr_ref, fl)

(* ****** ****** *)

(* end of [pats_histaexp_funlab.dats] *)
