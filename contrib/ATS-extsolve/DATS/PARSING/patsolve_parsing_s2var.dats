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
parse_s2var
  (ar, tbls, jsnv0) = let
//
val stamp =
parse_stamp
(
  jsonval_get_field_exn(jsnv0, "s2var_stamp")
) (* end of [val] *)
//
val opt =
  the_s2varmap_search(ar, tbls, stamp)
//
in
//
case+ opt of
| ~Some_vt(s2v) => s2v
| ~None_vt((*void*)) => s2v where
  {
    val sym =
    parse_symbol
    (
      ar, tbls
    , jsonval_get_field_exn(jsnv0, "s2var_sym")
    )
    val s2t =
    parse_s2rt
    (
      ar, tbls
    , jsonval_get_field_exn(jsnv0, "s2var_srt")
    )
    val () = the_stamp_update(stamp)
    val s2v = s2var_make(ar, sym, s2t, stamp)
    val ((*void*)) = the_s2varmap_insert(ar, tbls, s2v)
  } (* end of [None_vt] *)
//
end // end of [parse_s2var]

(* ****** ****** *)

(* end of [patsolve_parsing_s2var.dats] *)
