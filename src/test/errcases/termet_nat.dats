(* termination metric is not a natural number *)
#include "share/atspre_staload.hats"
fun f {n:int} .<n>. (n: int n): int =
  if n > 0 then f (n-1) else 0
