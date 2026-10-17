(* the third part of the common part of the test of the constraint solver: the loop over the problems, after the generated operations *)
(* ****** ****** *)
fun run_ops (): void =
  if c3_more () > 0 then let
    val opc = c3_int ()
    val () = exec_op (opc)
  in run_ops () end else ()
implement run_line () = run_ops ()
//
fun run_all (): void =
  if c3_line () > 0 then let
    val () = dd_ps "# "
    val () = dd_int (c3_lineno ())
    val () = dd_nl ()
    val () = drv_safe_line ()
  in run_all () end else ()
