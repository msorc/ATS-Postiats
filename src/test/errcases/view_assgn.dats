(* assignment through a view of another type *)
#include "share/atspre_staload.hats"
fun f {l:addr} (pf: !int @ l | p: ptr l): void = !p := true
