(* use after consumption *)
#include "share/atspre_staload.hats"
fun f (xs: list_vt(int, 1)): void =
  let val () = list_vt_free (xs) in list_vt_free (xs) end
