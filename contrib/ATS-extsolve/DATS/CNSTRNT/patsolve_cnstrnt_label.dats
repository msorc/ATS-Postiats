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
fprint_label
  (ar, out, lab) =
(
case+
label_view(ar, lab)
of // case+
| ~LABint(int) =>
    fprint! (out, "LABint(", int, ")")
| ~LABsym(sym) =>
  (
    fprint(out, "LABsym(");
    fprint_symbol(ar, out, sym); fprint(out, ")")
  )
) (* end of [fprint_label] *)

(* ****** ****** *)

(* end of [patsolve_cnstrnt_label.dats] *)
