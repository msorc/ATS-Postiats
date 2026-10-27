(* a linear variable is not consumed *)
#include "share/atspre_staload.hats"
fun leak (): void =
  let val xs = $list_vt{int}(1, 2, 3) in () end
