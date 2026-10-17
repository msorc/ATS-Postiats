(*
** For ATS2TUTORIAL
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

//
// HX-2026-10: no GC
// a function that captures nothing is passed as a
// plain function (fun1); a closure is linear (cloptr):
// it is borrowed by the callee and freed by the caller
//
fn find_root
(
  f: int -<fun1> int
) : int = let
//
fun loop
(
  f: int -<fun1> int, n: int
) : int =
  if f (n) = 0 then n else (
    if n <= 0 then loop (f, ~n + 1) else loop (f, ~n)
  ) // end of [else] // end of [if]
in
  loop (f, 0)
end // end of [find_root]

(* ****** ****** *)

val () = println!
(
  "root(x*x + x - 110) = ", find_root(lam(x) =<fun1> x*x + x - 110)
) (* end of [val] *)

(* ****** ****** *)

vtypedef
fdouble = double -<cloptr1> double
//
macdef epsilon = 1E-6 (* precision *)
//
// [f1] is the derivative of [f]
//
fun
newton_raphson
(
  f: !fdouble, f1: !fdouble, x0: double
) : double = let
  fun loop (
    f: !fdouble, f1: !fdouble, x0: double
  ) : double = let
    val y0 = f x0
  in
    if abs (y0 / x0) < epsilon then x0 else
      let val y1 = f1 x0 in loop (f, f1, x0 - y0 / y1) end
    // end of [if]
  end // end of [loop]
in
  loop (f, f1, x0)
end // end of [newton_raphson]
//
fn
fdouble_free(f: fdouble): void =
  cloptr_free ($UNSAFE.castvwtp0{cloptr(void)}(f))
//
// square root function
fn sqrt (c: double): double = let
  val f = lam (x: double): double =<cloptr1> x * x - c
  val f1 = lam (x: double): double =<cloptr1> 2.0 * x
  val res = newton_raphson (f, f1, 1.0)
in
  fdouble_free (f); fdouble_free (f1); res
end // end of [sqrt]
// cubic root function
fn cbrt (c: double): double = let
  val f = lam (x: double): double =<cloptr1> x * x * x - c
  val f1 = lam (x: double): double =<cloptr1> 3.0 * x * x
  val res = newton_raphson (f, f1, 1.0)
in
  fdouble_free (f); fdouble_free (f1); res
end // end of [cbrt]

(* ****** ****** *)

val sqrt_2 = sqrt(2.0)
val () = println! ("sqrt(2) = ", sqrt_2)
val () = println! ("(sqrt(2.0))^2 = ", sqrt_2 * sqrt_2)

val cbrt_2 = cbrt(2.0)
val () = println! ("cbrt(2) = ", cbrt_2)
val () = println! ("(cbrt(2.0))^3 = ", cbrt_2 * cbrt_2 * cbrt_2)

(* ****** ****** *)

implement main0 () = {}

(* ****** ****** *)

(* end of [chap_hordfun.dats] *)
