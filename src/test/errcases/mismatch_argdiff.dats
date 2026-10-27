(* type mismatch with differing type arguments *)
#include "share/atspre_staload.hats"
fun f (xs: list_vt(int, 3)): list_vt(bool, 3) = xs
