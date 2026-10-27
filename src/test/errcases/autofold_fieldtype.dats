(* the fold on demand fails: a field has a wrong type *)
#include "share/atspre_staload.hats"
fun f {n:pos} (xs: list_vt(int, n)): List0_vt(int) =
  case+ xs of
  | @list_vt_cons (_, xs1) => let
      val () = list_vt_free (xs1)
      val () = xs1 := 0
    in xs end
