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

extern
fun
parse_h3ypo_node{l:addr}
  (ar: !arena(l), tbls: ptables(l), jsnv: jsonval): h3ypo_node(l)

(* ****** ****** *)

implement
parse_h3ypo
  (ar, tbls, jsnv0) = let
//
val loc =
parse_location
(
  ar, tbls
, jsonval_get_field_exn(jsnv0, "h3ypo_loc")
)
val node =
parse_h3ypo_node
(
  ar, tbls
, jsonval_get_field_exn(jsnv0, "h3ypo_node")
)
//
in
  h3ypo_make_node(ar, loc, node)
end // end of [parse_h3ypo]

(* ****** ****** *)

implement
parse_h3ypo_node
  (ar, tbls, jsnv0) = let
//
val name = jsonval_get_name(jsnv0)
val x0 = jsonval_get_value(jsnv0)
//
in
//
case+ name of
| "H3YPOprop" =>
    h3ypo_node_H3YPOprop(ar, parse_s2exp(ar, tbls, JAG(x0, 0)))
| "H3YPObind" => let
    val s2v1 = parse_s2var(ar, tbls, JAG(x0, 0))
    val s2e2 = parse_s2exp(ar, tbls, JAG(x0, 1))
  in
    h3ypo_node_H3YPObind(ar, s2v1, s2e2)
  end // end of [H3YPObind]
| "H3YPOeqeq" => let
    val s2e1 = parse_s2exp(ar, tbls, JAG(x0, 0))
    val s2e2 = parse_s2exp(ar, tbls, JAG(x0, 1))
  in
    h3ypo_node_H3YPOeqeq(ar, s2e1, s2e2)
  end // end of [H3YPOeqeq]
| _(*unrecognized*) =>
   let val () = assertloc(false) in exit(1) end
//
end // end of [parse_h3ypo_node]

(* ****** ****** *)

(* end of [patsolve_parsing_h3ypo.dats] *)
