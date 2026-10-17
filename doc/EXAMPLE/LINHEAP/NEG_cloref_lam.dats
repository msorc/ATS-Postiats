(*
** a cloref closure
*)
#include "share/atspre_staload.hats"
implement main0 () = {
  val y = 1
  val f = lam (x: int): int =<cloref1> x + y
  val () = println! (f(1))
}
