(* a linear closure that leaves the captured linear variable preserved: an internal error that ends the translation *)
#include "share/atspre_staload.hats"
datavtype dvt = DVT of (int)
fun f7 (x: dvt): () -<lincloptr1> void = llam () => (let val+ DVT (n) = x in () end)
