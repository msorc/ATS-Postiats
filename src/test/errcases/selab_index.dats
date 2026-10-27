(* array subscript of the wrong type *)
#include "share/atspre_staload.hats"
fun f (a: @[int][3]): int = a[true]
