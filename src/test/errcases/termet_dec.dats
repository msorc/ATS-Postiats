(* termination metric does not decrease *)
#include "share/atspre_staload.hats"
fun f {n:nat} .<n>. (n: int n): int =
  if n > 0 then f (n+1) else 0
