(* nonexhaustive case *)
#include "share/atspre_staload.hats"
fun f (xs: List0_vt(int)): int =
  case+ xs of ~list_vt_cons (x, xs) => (free(xs); x)
