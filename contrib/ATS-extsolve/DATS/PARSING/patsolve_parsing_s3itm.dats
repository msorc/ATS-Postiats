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

implement
parse_s3itm
  (ar, tbls, jsnv0) = let
//
val name = jsonval_get_name(jsnv0)
val x0 = jsonval_get_value(jsnv0)
//
in
//
case+ name of
| "S3ITMsvar" =>
    s3itm_S3ITMsvar(ar, parse_s2var(ar, tbls, JAG(x0, 0)))
| "S3ITMsVar" =>
    s3itm_S3ITMsVar(ar, parse_s2Var(ar, tbls, JAG(x0, 0)))
| "S3ITMhypo" =>
    s3itm_S3ITMhypo(ar, parse_h3ypo(ar, tbls, JAG(x0, 0)))
| "S3ITMcnstr" =>
    s3itm_S3ITMcnstr(ar, parse_c3nstr(ar, tbls, JAG(x0, 0)))
| "S3ITMcnstr_ref" => let
    val loc =
      parse_location(ar, tbls, JAG(x0, 0))
    val opt =
      parse_c3nstropt(ar, tbls, JAG(x0, 1))
  in
    s3itm_S3ITMcnstr_ref(ar, loc, opt)
  end // end of [S3ITMcnstr_ref]
| "S3ITMdisj" =>
    s3itm_S3ITMdisj(ar, parse_s3itmlstlst(ar, tbls, JAG(x0, 0)))
| "S3ITMsolassert" =>
    s3itm_S3ITMsolassert(ar, parse_s2exp(ar, tbls, JAG(x0, 0)))
| _(*unrecognized*) =>
  let
    val () =
    prerrln!
      ("parse_s3itm: ", name)
    // end of [val]
    val ((*exit*)) = assertloc(false)
  in
    exit(1)
  end // end of [unrecognized]
//
end // end of [parse_s3itm]

(* ****** ****** *)

(* end of [patsolve_parsing_s3itm.dats] *)
