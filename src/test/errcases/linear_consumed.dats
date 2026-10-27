(* a linear variable is consumed twice by one call *)
#include "share/atspre_staload.hats"
extern fun g (xs: list_vt(int, 1), ys: list_vt(int, 1)): void
fun f (xs: list_vt(int, 1)): void = g (xs, xs)
