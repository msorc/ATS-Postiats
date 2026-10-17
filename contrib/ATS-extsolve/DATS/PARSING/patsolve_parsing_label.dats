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

implement
parse_label
  (ar, tbls, jsnv0) = let
//
val name = jsonval_get_name(jsnv0)
val jsnv2 = jsonval_get_value(jsnv0)
//
in
//
case+ name of
| "LABint" =>
    label_LABint(ar, parse_int(jsnv2))
| "LABsym" =>
    label_LABsym(ar, parse_symbol(ar, tbls, jsnv2))
| _(*unrecognized*) => 
  let
    val () =
    prerrln!
      ("parse_label: ", name)
    // end of [val]
    val ((*exit*)) = assertloc(false)
  in
    exit(1)
  end // end of [unrecognized]
//
end // end of [parse_label]

(* ****** ****** *)

(* end of [patsolve_parsing_label.dats] *)
