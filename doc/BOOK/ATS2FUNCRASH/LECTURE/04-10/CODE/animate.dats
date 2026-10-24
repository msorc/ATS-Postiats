(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)
//
#include "./eventloop.hats"
//
(* ****** ****** *)
//
extern
fun
animate(fwork: () -> void): void
//
extern
fun
sleep_animate
(ms: int, fwork: () -> void): void
//
(* ****** ****** *)
//
implement
animate(fwork) =
{
  val () = fwork()
  val () = sleep_animate(100(*ms*), fwork)
}
//
(* ****** ****** *)
//
implement
sleep_animate(ms, fwork) =
execute_after(llam() => animate(fwork), ms)
//
(* ****** ****** *)

var theCount_var: int = 0
val theCount =
ref_make_viewptr{int}(view@ theCount_var | addr@ theCount_var)

fun
tick(): void = let
  val n = !theCount
in
  !theCount := n + 1;
  println! ("tick ", n, " at ", eventloop_now(), "ms")
end // end of [tick]

(* ****** ****** *)
//
extern
fun
repeat_execute_after
( N: int,
  fwork: (int) -> void, ms: int) : void
//
implement
repeat_execute_after
(
N, fwork, ms
) = let
//
fun
auxmain(i: int): void =
if i >= N
  then auxmain(0)
  else (fwork(i); execute_after(llam() => auxmain(i+1), ms))
//
in
  auxmain(0)
end // end of [repeat_execute_after]
//
(* ****** ****** *)

implement
main0() = () where
{
//
val () = animate(lam() => tick())
val () = eventloop_run(450)
//
val () =
repeat_execute_after
(3, lam(i) => println! ("frame ", i, " at ", eventloop_now(), "ms"), 200)
val () = eventloop_run(1000)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [animate.dats] *)
