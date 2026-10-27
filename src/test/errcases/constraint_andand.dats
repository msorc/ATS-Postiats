(* unsolved constraint with && *)
#include "share/atspre_staload.hats"
fun f {a:int} (x: int a): [c:int | c > 0 && c < 10] int c = x
