(* wrong number of proof arguments *)
#include "share/atspre_staload.hats"
extern fun g {l:addr} (pf: int @ l | p: ptr l): void
fun f {l:addr} (p: ptr l): void = g (p)
