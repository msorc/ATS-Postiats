(* the second part of the common part of the test of the constraint solver (c3dump.dats, c3dump1.dats), after the language specific part *)
(* ****** ****** *)
fun pk_x (d: int, x: s3exp): void = (pr_x ("raw", x); p_X (d, x))
fun pk_x2 (d: int, tag: string, x: s3exp): void = (pr_x (tag, x); p_X (d, x))
//
fun mk_ccase (loc: location, ck: caskind, k: int): c3nstr = let
  val p = mk_p2tcs_vt (k)
  val c = c3nstr_case_exhaustiveness (loc, ck, p)
  val () = list_vt_free (p)
in c end
//
