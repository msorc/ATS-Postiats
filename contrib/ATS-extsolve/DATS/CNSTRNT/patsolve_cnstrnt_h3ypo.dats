(*
** ATS-extsolve:
** For solving ATS-constraints
** with external SMT-solvers
*)

(* ****** ****** *)

(*
** Author: Hongwei Xi
** Authoremail: gmhwxiATgmailDOTcom
*)

(* ****** ****** *)

implement
h3ypo_make_node
  (ar, loc, node) = h3ypo_H3YPO(ar, loc, node)

(* ****** ****** *)

implement
fprint_h3ypo
  (ar, out, h3p) = let
//
macdef
prs(x) = fprint_string(out, ,(x))
//
in
//
case+
h3ypo_node_view
  (ar, h3ypo_get_node(ar, h3p))
of // case+
| ~H3YPOprop(s2e) =>
  (
    prs("H3YPOprop("); fprint_s2exp(ar, out, s2e); prs(")")
  )
| ~H3YPObind(s2v1, s2e2) =>
  (
    prs("H3YPObind(");
    fprint_s2var(ar, out, s2v1); prs(" -> ");
    fprint_s2exp(ar, out, s2e2); prs(")")
  )
| ~H3YPOeqeq(s2e1, s2e2) =>
  (
    prs("H3YPOeqeq(");
    fprint_s2exp(ar, out, s2e1); prs(" == ");
    fprint_s2exp(ar, out, s2e2); prs(")")
  )
//
end (* end of [fprint_h3ypo] *)

(* ****** ****** *)

(* end of [patsolve_cnstrnt_h3ypo.dats] *)
