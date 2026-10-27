(* dereference without a view *)
#include "share/atspre_staload.hats"
fun f (p: ptr): void = !p := true
