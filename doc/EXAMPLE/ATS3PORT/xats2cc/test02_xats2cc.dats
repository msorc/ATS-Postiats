(* ****** ****** *)
//
// A port of the ATS3 test
//
//   srcgen2/xats2cc/srcgen1/TEST/test02_xats2cc.dats
//
// The test exercises the closures ([lam]), the recursive
// closures ([fix]), the mutually recursive functions and the
// [extern]/[implement] pair.
//
// In ATS2 a [lam] that captures no variable is an ordinary
// function, while a [lam@] that captures flat variables is a
// flat closure, which is held in a variable.  The recursive
// closure of the ATS3 test (which captures its own argument)
// is dropped: in ATS2 a closure cannot be returned by a
// function without giving it a closure type.
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

staload "prelude/SATS/integer.sats"
staload "prelude/SATS/list_vt.sats"

(* ****** ****** *)

val
x = 1000

val
y = (x + x)

(* ****** ****** *)

fun
fact1 (n: int): int =
(
  loop (0, 1)) where {
  fun
  loop (i: int, r: int): int =
    if i >= n then r
    else let
      val i1 = i + 1
    in
      loop (i1, i1 * r)
    end
} (* end of [fact1] *)

(* ****** ****** *)

fun
fxyz (nn: int, tt: bool, ff: bool): bool =
(
  isevn (nn)) where {
  fun
  isevn (n: int): bool =
    if n = 0 then tt else isodd (n - 1)
  and
  isodd (n: int): bool =
    if n = 0 then ff else isevn (n - 1)
} (* end of [fxyz] *)

(* ****** ****** *)

extern
fun
fact (n0: int): int

implement
fact (n0) =
  if n0 > 0 then n0 * fact (n0 - 1) else 1

(* ****** ****** *)

implement
main0 () = {
  var foo = lam@ (w: int): int => w + x + y
  val () = println! ("foo = ", foo (1))
  val () = println! ("fact1 = ", fact1 (5))
  val () = println! ("fact = ", fact (5))
  val () = println! ("fxyz = ", fxyz (4, true, false))
} // end of [main0]

(* ****** ****** *)

(* end of [test02_xats2cc.dats] *)
