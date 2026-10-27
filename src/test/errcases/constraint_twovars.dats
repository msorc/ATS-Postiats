(* two variables named n in one message *)
#include "share/atspre_staload.hats"
fun g {n:nat} (x: int n): void = let
  fun h {n:nat} (y: int n): int n = x
in () end
