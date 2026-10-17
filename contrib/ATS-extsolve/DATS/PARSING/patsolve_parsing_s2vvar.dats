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
parse_s2Var
  (ar, tbls, jsnv0) = let
//
val stamp =
parse_stamp
(
  jsonval_get_field_exn(jsnv0, "s2Var_stamp")
) (* end of [val] *)
//
val opt =
  the_s2Varmap_search(ar, tbls, stamp)
//
in
//
case+ opt of
| ~Some_vt(s2V) => s2V
| ~None_vt((*void*)) => s2V where
  {
    val () = the_stamp_update(stamp)
    val s2V = s2Var_make(ar, stamp)
    val ((*void*)) = the_s2Varmap_insert(ar, tbls, s2V)
  } (* end of [None_vt] *)
//
end // end of [parse_s2Var]

(* ****** ****** *)

(* end of [patsolve_parsing_s2vvar.dats] *)
