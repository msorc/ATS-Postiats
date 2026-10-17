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

macdef
JAG(x0, i) = jsonval_array_get(,(x0), ,(i))

(* ****** ****** *)
//
extern
fun
parse_c3nstrkind{l:addr}
  (ar: !arena(l), tbls: ptables(l), jsnv: jsonval): c3nstrkind(l)
//
extern
fun
parse_c3nstr_node{l:addr}
  (ar: !arena(l), tbls: ptables(l), jsnv: jsonval): c3nstr_node(l)
//
(* ****** ****** *)

implement
parse_c3nstr
  (ar, tbls, jsnv0) = let
//
val loc =
parse_location
(
  ar, tbls
, jsonval_get_field_exn(jsnv0, "c3nstr_loc")
)
val c3tk =
parse_c3nstrkind
(
  ar, tbls
, jsonval_get_field_exn(jsnv0, "c3nstr_kind")
)
val node =
parse_c3nstr_node
(
  ar, tbls
, jsonval_get_field_exn(jsnv0, "c3nstr_node")
)
//
in
  c3nstr_make_node(ar, loc, c3tk, node)
end // end of [parse_c3nstr]

(* ****** ****** *)

implement
parse_c3nstrkind
  (ar, tbls, jsnv0) = let
//
val name = jsonval_get_name(jsnv0)
val jsnv2 = jsonval_get_value(jsnv0)
//
in
//
case+ name of
| "C3TKmain" => c3nstrkind_C3TKmain(ar)
| "C3TKtermet_isnat" => c3nstrkind_C3TKtermet_isnat(ar)
| "C3TKtermet_isdec" => c3nstrkind_C3TKtermet_isdec(ar)
| "C3TKsolver" =>
    c3nstrkind_C3TKsolver(ar, parse_int(jsnv2))
| _(*rest-of-c3nstrkind*) => c3nstrkind_C3TKignored(ar)
//
end // end of [parse_c3nstrkind]

(* ****** ****** *)

implement
parse_c3nstr_node
  (ar, tbls, jsnv0) = let
//
val name = jsonval_get_name(jsnv0)
val x0 = jsonval_get_value(jsnv0)
//
in
//
case+ name of
| "C3NSTRprop" =>
    c3nstr_node_C3NSTRprop
      (ar, parse_s2exp(ar, tbls, JAG(x0, 0)))
| "C3NSTRitmlst" =>
    c3nstr_node_C3NSTRitmlst
      (ar, parse_s3itmlst(ar, tbls, JAG(x0, 0)))
| "C3NSTRsolverify" =>
    c3nstr_node_C3NSTRsolverify
      (ar, parse_s2exp(ar, tbls, JAG(x0, 0)))
| _(*unrecognized*) =>
   let val () = assertloc(false) in exit(1) end
//
end // end of [parse_c3nstr_node]

(* ****** ****** *)

(* end of [patsolve_parsing_c3nstr.dats] *)
