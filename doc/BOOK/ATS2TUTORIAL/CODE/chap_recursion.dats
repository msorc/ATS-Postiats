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
fun fact (x: int): int =
  if x > 0 then x * fact(x-1) else 1
//
(* ****** ****** *)
//
fn square(x: int): int = x * x
//
val square = lam (x: int): int => x * x
//
(* ****** ****** *)

fn
fact(x: int): int =
  if x > 0 then x * fact(x-1) else 1
(* end of [fact] *)

(* ****** ****** *)
//
val
rec
fact : int -> int =
  lam (x) => if x > 0 then x * fact(x-1) else 1
//
(* ****** ****** *)

(*
HX-2026-10:
recursion through a reference is no longer
shown here as [ref] is no longer available
*)

(* ****** ****** *)

val
fact =
fix f(x: int): int =>
  if x > 0 then x * f(x-1) else 1
(* end of [fact] *)

(* ****** ****** *)

val double = lam(x:int):int => x + x
val double = fix _(x:int):int => x + x

(* ****** ****** *)
//
fun
isevn(x: int): bool =
  if x > 0 then isodd(x-1) else true
and
isodd(x: int): bool =
  if x > 0 then isevn(x-1) else false
//
val
rec
isevn2 : int -> bool =
  lam (x) => if x > 0 then isodd2(x-1) else true
and
isodd2 : int -> bool =
  lam (x) => if x > 0 then isevn2(x-1) else false
//
(* ****** ****** *)
//
extern fun fact (x: int): int
//
implement
fact (x) =
  if x > 0 then x * fact(x-1) else 1
// end of [fact]
//
extern fun fact2 (x: int): int
implmnt fact2(x) = if x > 0 then x * fact2(x-1) else 1
//
(* ****** ****** *)

implement
main0 () = {
  val () = assertloc (fact(5) = 120)
  val () = assertloc (fact2(5) = 120)
  val () = assertloc (isevn(10) && isodd(7) && ~isevn(7))
  val () = assertloc (isevn2(10) && isodd2(7) && ~isevn2(7))
}

(* ****** ****** *)

(* end of [chap_recursion.dats] *)

