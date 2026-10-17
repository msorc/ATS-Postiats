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
parse_s2cst
  (ar, tbls, jsnv0) = let
//
val stamp =
parse_stamp
(
  jsonval_get_field_exn(jsnv0, "s2cst_stamp")
) (* end of [val] *)
//
val opt =
  the_s2cstmap_search(ar, tbls, stamp)
//
in
//
case+ opt of
| ~Some_vt(s2c0) => s2c0
| ~None_vt((*void*)) => s2c0 where
  {
    val sym =
    parse_symbol
    (
      ar, tbls
    , jsonval_get_field_exn(jsnv0, "s2cst_sym")
    )
    val s2t =
    parse_s2rt
    (
      ar, tbls
    , jsonval_get_field_exn(jsnv0, "s2cst_srt")
    )
    val () = the_stamp_update(stamp)
    val x_extdef =
      jsonval_get_field_exn(jsnv0, "s2cst_extdef")
    val extdef =
    (
      if
      json_array_length(x_extdef) > 0
      then $UN.cast{ptr}
        (astring_make(ar, parse_string(json_array_get(x_extdef, 0))))
      else the_null_ptr
    ) : ptr // end of [val]
    val supcls =
    parse_s2explst
    (
      ar, tbls
    , jsonval_get_field_exn(jsnv0, "s2cst_supcls")
    )
    val s2c0 = s2cst_make(ar, sym, s2t, stamp, extdef)
    val ((*void*)) = the_s2cstmap_insert(ar, tbls, s2c0)
  } (* end of [None_vt] *)
//
end // end of [parse_s2cst]

(* ****** ****** *)

(* end of [patsolve_parsing_s2cst.dats] *)
