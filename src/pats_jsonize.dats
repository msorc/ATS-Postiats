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
// Start Time: November, 2013
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_jsonize.dats)
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)
//
staload
UN = "prelude/SATS/unsafe.sats"
//
(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)

staload
INTINF = "./pats_intinf.sats"

(* ****** ****** *)

staload STA = "./pats_stamp.sats"
staload SYM = "./pats_symbol.sats"
staload LOC = "./pats_location.sats"
staload FIL = "./pats_filename.sats"

(* ****** ****** *)

staload LAB = "./pats_label.sats"

(* ****** ****** *)

staload "./pats_jsonize.sats"

(* ****** ****** *)

#include "./pats_jsonize_gen_dats.hats"

(* ****** ****** *)

implement
jsonval_int (i) = jsonval_JSONint (i)

implement
jsonval_intinf (i) = jsonval_JSONintinf (i)

implement
jsonval_bool (b) = jsonval_JSONbool (b)

implement
jsonval_double (d) = jsonval_JSONfloat (d)

implement
jsonval_string (str) = jsonval_JSONstring (str)

(* ****** ****** *)

implement
jsonval_location (loc) = jsonval_JSONlocation (loc)
implement
jsonval_filename (fil) = jsonval_JSONfilename (fil)

(* ****** ****** *)

implement
jsonval_sing (x) = jsonval_JSONlist (glist_sing(x))
implement
jsonval_pair (x1, x2) =
  jsonval_JSONlist (glist_cons(x1, glist_sing(x2)))

(* ****** ****** *)
//
fn lv
(
  l: string, x: jsonval, lxs: labjsonvalist
) : labjsonvalist = glist_cons(labjsonval_new(l, x), lxs)
//
implement
jsonval_labval1 (l, x) =
  jsonval_JSONlablist (glist_sing(labjsonval_new(l, x)))
implement
jsonval_labval2 (l1, x1, l2, x2) =
  jsonval_JSONlablist
    (lv(l1, x1, glist_sing(labjsonval_new(l2, x2))))
implement
jsonval_labval3
(
  l1, x1, l2, x2, l3, x3
) = jsonval_JSONlablist
(
  lv(l1, x1, lv(l2, x2, glist_sing(labjsonval_new(l3, x3))))
)
implement
jsonval_labval4
(
  l1, x1, l2, x2, l3, x3, l4, x4
) = jsonval_JSONlablist
(
  lv(l1, x1, lv(l2, x2, lv(l3, x3, glist_sing(labjsonval_new(l4, x4)))))
)
//
implement
jsonval_labval5
(
  l1, x1, l2, x2, l3, x3, l4, x4, l5, x5
) = jsonval_JSONlablist
(
  lv(l1, x1, lv(l2, x2, lv(l3, x3, lv(l4, x4,
    glist_sing(labjsonval_new(l5, x5))))))
)
implement
jsonval_labval6
(
  l1, x1, l2, x2, l3, x3, l4, x4, l5, x5, l6, x6
) = jsonval_JSONlablist
(
  lv(l1, x1, lv(l2, x2, lv(l3, x3, lv(l4, x4, lv(l5, x5,
    glist_sing(labjsonval_new(l6, x6)))))))
)
implement
jsonval_labval7
(
  l1, x1, l2, x2, l3, x3, l4, x4, l5, x5, l6, x6, l7, x7
) = jsonval_JSONlablist
(
  lv(l1, x1, lv(l2, x2, lv(l3, x3, lv(l4, x4, lv(l5, x5, lv(l6, x6,
    glist_sing(labjsonval_new(l7, x7))))))))
)
implement
jsonval_labval8
(
  l1, x1, l2, x2, l3, x3, l4, x4, l5, x5, l6, x6, l7, x7, l8, x8
) = jsonval_JSONlablist
(
  lv(l1, x1, lv(l2, x2, lv(l3, x3, lv(l4, x4, lv(l5, x5, lv(l6, x6, lv(l7, x7,
    glist_sing(labjsonval_new(l8, x8)))))))))
)
//
(* ****** ****** *)
//
implement
jsonval_conarg0
  (con) = jsonval_conarglst (con, glist_nil((*void*)))
implement
jsonval_conarg1
  (con, arg1) =
  jsonval_conarglst (con, glist_sing (arg1))
implement
jsonval_conarg2
  (con, arg1, arg2) =
  jsonval_conarglst (con, glist_cons (arg1, glist_sing (arg2)))
implement
jsonval_conarg3
  (con, arg1, arg2, arg3) =
  jsonval_conarglst
    (con, glist_cons (arg1, glist_cons (arg2, glist_sing (arg3))))
implement
jsonval_conarg4
  (con, arg1, arg2, arg3, arg4) =
  jsonval_conarglst
  (
    con
  , glist_cons (arg1, glist_cons (arg2, glist_cons (arg3, glist_sing (arg4))))
  )
//
implement
jsonval_conarglst
  (con, arglst) = jsonval_labval1 (con, jsonval_JSONlist (arglst))
// end of [jsonval_conarglst]
  
(* ****** ****** *)
//
implement
jsonval_none () = jsonval_JSONoption (gopt_none((*void*)))
implement
jsonval_some (x) = jsonval_JSONoption (gopt_some(x))
//
(* ****** ****** *)

local

fn
fprint_hex2
(
  out: FILEref, i: int
) : void = let
  fn hex (d: int): char =
    if d < 10 then int2char0(char2int0('0') + d)
    else int2char0(char2int0('A') + (d - 10))
in
  fprint_char (out, hex (i / 16)); fprint_char (out, hex (i mod 16))
end // end of [fprint_hex2]

fun
fprint_jsonval_string
(
  out: FILEref, str: string
) : void = let
//
fun
auxch
(
  out: FILEref, c: char
) : void = let
in
//
case+ c of
| '"' => fprint_string (out, "\\\"")
| '\\' => fprint_string (out, "\\\\")
| '\n' => fprint_string (out, "\\n")
| '\r' => fprint_string (out, "\\r")
| '\t' => fprint_string (out, "\\t")
| '\b' => fprint_string (out, "\\b")
| '\f' => fprint_string (out, "\\f")
| _ (*rest-of-char*) =>
  (
    if isprint_char(c)
      then fprint_char(out, c)
      else let
        val uc = char2int0(c)
        val uc = (if uc < 0 then uc + 256 else uc): int
      in
        fprint_string (out, "\\u00"); fprint_hex2 (out, uc)
      end // end of [else]
    // end of [if]
  ) (* end of [_] *)
//
end // end of [auxch]
//
fun
loop
(
  out: FILEref, p: ptr
) : void = let
//
val c = $UN.ptr0_get<char> (p)
//
in
//
if
c != '\000'
then (auxch(out, c); loop (out, ptr0_succ<char> (p))) else ()
//
end // end of [loop]
//
in
//
fprint_char (out, '"');
loop (out, $UN.cast{ptr}(str));
fprint_char (out, '"');
//
end // end of [fprint_jsonval_string]

in (* in-of-local *)

implement
fprint_jsonval
  (out, x0) = let
//
macdef
prstr (str) = fprint_string (out, ,(str))
//
in
//
case+ jsonval_view(x0) of
//
| ~JSONnul () => prstr "{}"
//
| ~JSONint (i) => fprint_int (out, i)
| ~JSONintinf (i) =>
  {
    val () = fprint_char (out, '"')
    val () = $INTINF.fprint_intinf (out, i)
    val () = fprint_char (out, '"')
  }
//
| ~JSONbool (b) => fprint_bool (out, b)
| ~JSONfloat (d) => fprint_double (out, d)
//
| ~JSONstring (str) => fprint_jsonval_string (out, str)
//
| ~JSONlocation (loc) =>
  {
    val () = prstr "\""
    val () = $LOC.fprint_location (out, loc)
    val () = prstr "\""
  } (* end of [JSONlocation] *)
| ~JSONfilename (fil) =>
  {
    val () = prstr "\""
    val () = $FIL.fprint_filename_full (out, fil)
    val () = prstr "\""
  } (* end of [JSONfilename] *)
//
| ~JSONlist (xs) =>
  {
    val () = prstr "["
    val () = fprint_jsonvalist (out, xs)
    val () = prstr "]"
  }
| ~JSONlablist (lxs) =>
  {
    val () = prstr "{"
    val () = fprint_labjsonvalist (out, lxs)
    val () = prstr "}"
  }
//
| ~JSONoption (opt) =>
  {
    val () = prstr "["
    val () =
    (
      case+ gopt_view(opt) of
      | ~GOsome x => fprint_jsonval (out, x) | ~GOnone () => ()
    ) : void // end of [val]
    val () = prstr "]"
  }
//
end // end of [fprint_jsonval]

end // end of [local]

(* ****** ****** *)

implement
fprint_jsonvalist
  (out, xs0) = let
//
fun aux
(
  out: FILEref
, xs0: jsonvalist, i: int
) : void = let
in
//
case+ glist_view(xs0) of
| ~GLnil () => ()
| ~GLcons (x, xs) => let
    val () =
      if i > 0
        then fprint_string (out, ", ")
      // end of [if]
    val () = fprint_jsonval (out, x)
  in
    aux (out, xs, i+1)
  end // end of [GLcons]
//
end // end of [aux]
//
in
  aux (out, xs0, 0)
end // end of [fprint_jsonvalist]

(* ****** ****** *)

implement
fprint_labjsonvalist
  (out, lxs0) = let
//
fun aux
(
  out: FILEref
, lxs0: labjsonvalist, i: int
) : void = let
in
//
case+ glist_view(lxs0) of
| ~GLnil () => ()
| ~GLcons
    (lx, lxs) => let
    val () =
      if i > 0
        then fprint_string (out, ", ")
      // end of [if]
    val () = fprint_char (out, '"')
    val () = fprint_string (out, lx.labjsonval_lab())
    val () = fprint_char (out, '"')
    val () = fprint_string (out, ": ")
    val () = fprint_jsonval (out, lx.labjsonval_val())
  in
    aux (out, lxs, i+1)
  end // end of [GLcons]
//
end // end of [aux]
//
in
  aux (out, lxs0, 0)
end // end of [fprint_labjsonvalist]

(* ****** ****** *)

local

fn aux0
(
  name: string
) : jsonval = let
  val name = jsonval_string (name)
  val arglst = jsonval_JSONlist (glist_nil((*void*)))
in
  jsonval_labval2 ("funclo_name", name, "funclo_arglst", arglst)
end // end of [aux0]

fn aux1
(
  name: string, arg: jsonval
) : jsonval = let
  val name = jsonval_string (name)
  val arglst = jsonval_sing (arg)
in
  jsonval_labval2 ("funclo_name", name, "funclo_arglst", arglst)
end // end of [aux1]

in (* in of [local] *)

implement
jsonize_funclo (fc) =
(
  case+ fc of
  | FUNCLOfun () => aux0 ("FUNCLOfun")
  | _ (*FUNCLOclo*) =>
      aux1 ("FUNCLOclo", jsonval_int (funclo_get_clokind (fc)))
) (* end of [jsonize_funclo] *)

end // end of [local]

(* ****** ****** *)

implement
jsonize_caskind(knd) = (
//
case+ knd of
| CK_case () => jsonval_string "CK_case"
| CK_case_pos () => jsonval_string "CK_case_pos"
| CK_case_neg () => jsonval_string "CK_case_neg"
//
) (* end of [jsonize_caskind] *)

(* ****** ****** *)

implement
jsonize_funkind(knd) = (
//
case+ knd of
//
| FK_fn () => jsonval_string "FK_fn"
| FK_fnx () => jsonval_string "FK_fnx"
| FK_fun () => jsonval_string "FK_fun"
//
| FK_prfn () => jsonval_string "FK_prfn"
| FK_prfun () => jsonval_string "FK_prfun"
//
| FK_praxi () => jsonval_string "FK_praxi"
//
| FK_castfn () => jsonval_string "FK_castfn"
//
) (* end of [jsonize_funkind] *)

(* ****** ****** *)

implement
jsonize_valkind(knd) = (
//
case+ knd of
| VK_val () => jsonval_string "VK_val"
| VK_prval () => jsonval_string "VK_prval"
| VK_val_pos () => jsonval_string "VK_val_pos"
| VK_val_neg () => jsonval_string "VK_val_neg"
//
) (* end of [jsonize_valkind] *)

(* ****** ****** *)

implement
jsonize_dcstkind(knd) = (
//
case+ knd of
| DCKfun () => jsonval_string "DCKfun"
| DCKval () => jsonval_string "DCKval"
| DCKpraxi () => jsonval_string "DCKpraxi"
| DCKprfun () => jsonval_string "DCKprfun"
| DCKprval () => jsonval_string "DCKprval"
| DCKcastfn () => jsonval_string "DCKcastfn"
//
) (* end of [jsonize_dcstkind] *)

(* ****** ****** *)
//
implement
jsonize_stamp(x0) =
  jsonval_int($STA.stamp_get_int(x0))
//
(* ****** ****** *)
//
implement
jsonize_symbol(sym) =
  jsonval_string($SYM.symbol_get_name(sym))
implement
jsonize_symbolopt(opt) =
(
//
case+ gopt_view(opt) of
| ~GOnone() => jsonval_none()
| ~GOsome(x) => jsonval_some(jsonize_symbol(x))
//
) (* end of [jsonize_symbolopt] *)
//
(* ****** ****** *)
//
implement
jsonize_location(loc) = jsonval_location (loc)
implement
jsonize_filename(fil) = jsonval_filename (fil)
//
(* ****** ****** *)

implement
jsonize_label(lab) = let
//
val opt = $LAB.label_get_int(lab)
//
in
//
case+ opt of
| ~Some_vt (x) => let
    val jsv = jsonval_int (x)
  in
    jsonval_labval1 ("LABint", jsv)
  end (* end of [Some_vt] *)
| ~None_vt ((*void*)) => let
    val opt = $LAB.label_get_sym (lab)
  in
    case+ opt of
    | ~Some_vt (sym) => let
        val jsv = jsonize_symbol (sym)
      in
        jsonval_labval1 ("LABsym", jsv)
      end // end of [Some_vt]
    | ~None_vt ((*void*)) => jsonval_JSONnul ((*void*))
  end (* end of [None_vt] *)
//
end // end of [jsonize_label]

(* ****** ****** *)
//
implement
{a}(*tmp*)
jsonize_ignored(x0) = jsonval_JSONnul((*void*))
//
(* ****** ****** *)
//
// HX: the elements are mapped from the head, as [list_map_fun] of ATS1
//
fun{a:t@ype}
jsonize_list_loop
(
  xs: glist(a), f: jsonize_ftype (a), res: List0_vt(jsonval)
) : List0_vt(jsonval) =
(
  case+ glist_view (xs) of
  | ~GLnil () => list_vt_reverse (res)
  | ~GLcons (x, xs1) => let
      val y = f (x) in jsonize_list_loop<a> (xs1, f, list_vt_cons (y, res))
    end // end of [GLcons]
) (* end of [jsonize_list_loop] *)

implement
{a}(*tmp*)
jsonize_list_fun(xs, f) =
  jsonval_JSONlist
    (glist_make_list_vt (jsonize_list_loop<a> (xs, f, list_vt_nil ())))
// end of [jsonize_list_fun]

(* ****** ****** *)

implement
{a}(*tmp*)
jsonize_option_fun(opt, f) = let
//
in
//
case+ gopt_view(opt) of
| ~GOnone() => jsonval_none() | ~GOsome(x) => jsonval_some(f(x))
//
end // end of [jsonize_option_fun]

(* ****** ****** *)

(* end of [pats_jsonize.dats] *)
