(* free@ of a non-unfolded value *)
#include "share/atspre_staload.hats"
fun f (xs: list_vt(int, 1)): void = free@ (xs)
