(*
** ATS-extsolve:
** For solving ATS-constraints
** with external SMT-solvers
*)

(* ****** ****** *)

(*
** Author: Hongwei Xi
** Authoremail: gmhwxiATgmailDOTcom
** Start time: May, 2015
*)

(* ****** ****** *)

local

fun
aux_S2RTbas
  {l:addr}
(
  ar: !arena(l)
, tbls: ptables(l), x0: jsonval
) : s2rt(l) = let
//
val name =
  parse_string(jsonval_array_get(x0, 0))
//
in
//
case+ name of
//
| "int" => s2rt_S2RTint(ar)
| "addr" => s2rt_S2RTaddr(ar)
| "bool" => s2rt_S2RTbool(ar)
| "real" => s2rt_S2RTreal(ar)
//
| "cls" => s2rt_S2RTeff(ar)
| "eff" => s2rt_S2RTeff(ar)
//
| "type" => s2rt_S2RTtype(ar)
| "t@ype" => s2rt_S2RTt0ype(ar)
| "t0ype" => s2rt_S2RTt0ype(ar)
//
| "viewtype" => s2rt_S2RTvtype(ar)
| "viewt@ype" => s2rt_S2RTvt0ype(ar)
| "viewt0ype" => s2rt_S2RTvt0ype(ar)
//
| "prop" => s2rt_S2RTprop(ar)
| "view" => s2rt_S2RTview(ar)
//
| "tkind" => s2rt_S2RTtkind(ar)
//
| _(*rest*) =>
    s2rt_S2RTnamed
      (ar, symbol_make_name(ar, ptables_get_symtbl(ar, tbls), name))
    // s2rt_S2RTnamed
//
end // end of [aux_S2RTbas]

fun
aux_S2RTfun
  {l:addr}
(
  ar: !arena(l)
, tbls: ptables(l), x0: jsonval
) : s2rt(l) = let
//
val arg =
  parse_s2rtlst(ar, tbls, jsonval_array_get(x0, 0))
val res =
  parse_s2rt(ar, tbls, jsonval_array_get(x0, 1))
//
in
  s2rt_S2RTfun(ar, arg, res)
end // end of [aux_S2RTfun]

in (* in-of-local *)

implement
parse_s2rt
  (ar, tbls, jsnv0) = let
//
val name = jsonval_get_name(jsnv0)
val jsnv2 = jsonval_get_value(jsnv0)
//
in
//
case+ name of
| "S2RTbas" => aux_S2RTbas(ar, tbls, jsnv2)
| "S2RTfun" => aux_S2RTfun(ar, tbls, jsnv2)
| _(*rest-of-S2RT*) => s2rt_S2RTerror(ar)
//
end // end of [parse_s2rt]

end // end of [local]

(* ****** ****** *)

implement
parse_s2rtdat
  (ar, tbls, jsnv0) = let
//
val x1 =
  jsonval_get_field_exn(jsnv0, "s2rtdat_sym")
val x2 =
  jsonval_get_field_exn(jsnv0, "s2rtdat_stamp")
val x3 =
  jsonval_get_field_exn(jsnv0, "s2rtdat_sconlst")
//
val name = parse_symbol(ar, tbls, x1)
val stamp = parse_stamp(x2)
val s2cs0 = parse_s2cstlst(ar, tbls, x3)
//
in
  s2rtdat_make(ar, name, stamp, s2cs0)
end // end of [parse_s2rtdat]

(* ****** ****** *)

(* end of [patsolve_parsing_s2rt.dats] *)
