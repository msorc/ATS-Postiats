(* pattern of the wrong type *)
#include "share/atspre_staload.hats"
fun f (x: int): int = case+ x of true => 1 | _ => 0
