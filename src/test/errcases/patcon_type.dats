(* constructor pattern of the wrong type *)
#include "share/atspre_staload.hats"
fun f (x: int): int = case+ x of list_vt_nil () => 1 | _ => 0
