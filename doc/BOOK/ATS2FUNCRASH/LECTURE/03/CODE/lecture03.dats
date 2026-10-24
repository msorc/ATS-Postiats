(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

fun
fact(n: int): int =
if n > 0 then n * fact(n-1) else 1

val () = println! ("fact(10) = ", fact(10))

(* ****** ****** *)

fun
fact2(n: int): int = let
//
fun
loop(i: int, res: int): int =
if i < n
  then loop(i+1, (i+1)*res) else res
// end of [if]
//
in
  loop(0, 1)
end // end of [fact2]

(* ****** ****** *)

val () =
println! ("fact2(10) = ", fact2(10))

(* ****** ****** *)

fun
testfact2
(n: int): void = let
  fun
  loop(i: int): void =
  if i < n then
  (
    println! ("fact(", i, ") = ", fact2(i)); loop(i+1)
  ) (* end of [if] *)
in
  loop(0)
end // end of [testfact2]

(* ****** ****** *)

val () = testfact2(100)

(* ****** ****** *)

fun
f91(n: int): int =
  if n > 100 then n-10 else f91(f91(n+11))

val () = println! ("f91(50) = ", f91(50))

(* ****** ****** *)

fnx
isevn(n: int): bool =
if n > 0 then isodd(n-1) else true
//
and
isodd(n: int): bool =
if n > 0 then isevn(n-1) else false

val () = println! ("isevn(1000000) = ", isevn(1000000))

(* ****** ****** *)

implement main0() = () // a dummy for [main]

(* ****** ****** *)

(* end of [lecture03.dats] *)
