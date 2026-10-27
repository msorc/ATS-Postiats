(* a ! parameter is consumed *)
#include "share/atspre_staload.hats"
fun f (xs: !list_vt(int, 1)): void = list_vt_free (xs)
