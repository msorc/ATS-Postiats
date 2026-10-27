(* the state of a linear variable at the end of a loop *)
#include "share/atspre_staload.hats"
fun f (xs: list_vt(int, 1)): void = let
  var i: int = 0
  val () = while (i < 3) (list_vt_free (xs); i := i + 1)
in () end
