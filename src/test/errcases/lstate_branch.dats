(* a linear variable is freed in one branch *)
#include "share/atspre_staload.hats"
fun f (b: bool, xs: list_vt(int, 1)): void =
  if b then list_vt_free (xs) else ()
