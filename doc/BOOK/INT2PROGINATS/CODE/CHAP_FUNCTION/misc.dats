(*
** Copyright (C) 2011 Hongwei Xi, ATS Trustful Software, Inc.
**
** Permission is hereby granted, free of charge, to any person
** obtaining a copy of this software and associated documentation
** files (the "Software"), to deal in the Software without
** restriction, including without limitation the rights to use,
** copy, modify, merge, publish, distribute, sublicense, and/or sell
** copies of the Software, and to permit persons to whom the
** Software is furnished to do so, subject to the following
** conditions:
**
** The above copyright notice and this permission notice shall be
** included in all copies or substantial portions of the Software.
**
** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
** EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
** OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
** NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
** HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
** WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
** FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
** OTHER DEALINGS IN THE SOFTWARE.
*)

(* ****** ****** *)

(*
** Example: Higher-order functions
**
** Updated for the linear-only dialect of ATS2 (no GC):
** envless functions, flat closures and pointer closures
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

fun rtfind
  (f: int -> int): int = let
  fun loop (
    f: int -> int, n: int
  ) : int =
    if f(n) = 0 then n else loop (f, n+1)
  // end of [loop]
in
  loop (f, 0)
end // end of [rtfind]

(* ****** ****** *)
//
fun ifold
  (n: int, f: (int, int) -> int, ini: int): int =
  if n > 0 then f (ifold (n-1, f, ini), n) else ini
//
fun sum (n: int): int = ifold (n, lam (res, x) => res + x, 0)
fun prod (n: int): int = ifold (n, lam (res, x) => res * x, 1)
//
fun sqrsum (n: int): int = ifold (n, lam (res, x) => res + x * x, 0)
//
(* ****** ****** *)
//
// A flat closure (stored on the stack)
//
fun
ifold2
(
  n: int, f: &(int, int) -<clo1> int, ini: int
) : int =
  if n > 0 then let
    val res = ifold2 (n-1, f, ini)
  in
    f (res, n)
  end else ini
// end of [ifold2]
//
fun
sqrmodsum
(n: int, d: int): int = let
  var f = lam@ (res: int, x: int): int =>
    if x mod d = 0 then res + x * x else res
in
  ifold2 (n, f, 0)
end // end of [sqrmodsum]
//
(* ****** ****** *)
//
// A pointer closure (allocated in the heap): the creator frees it
//
fun
ifold3
(
  n: int, f: !(int, int) -<cloptr1> int, ini: int
) : int =
  if n > 0 then let
    val res = ifold3 (n-1, f, ini)
  in
    f (res, n)
  end else ini
// end of [ifold3]
//
fun
sqrmodsum3
(n: int, d: int): int = let
  val f = lam (res: int, x: int): int =<cloptr1>
    if x mod d = 0 then res + x * x else res
  val r = ifold3 (n, f, 0)
  val () = cloptr_free ($UNSAFE.castvwtp0{cloptr(void)}(f))
in
  r
end // end of [sqrmodsum3]
//
(* ****** ****** *)
//
fun addx (x: int): (int) -<cloptr1> int = lam y =<cloptr1> x + y
//
(* ****** ****** *)

implement
main0 () =
{
//
val () = assertloc (rtfind (lam x => x * x - x - 110) = 11)
val () = assertloc (sum (10) = 55)
val () = assertloc (prod (5) = 120)
val () = assertloc (sqrsum (3) = 14)
val () = assertloc (sqrmodsum (10, 2) = 220)
val () = assertloc (sqrmodsum3 (10, 2) = 220)
//
val plus1 = addx (1)
val () = assertloc (plus1 (0) = 1)
val () = cloptr_free ($UNSAFE.castvwtp0{cloptr(void)}(plus1))
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [misc.dats] *)
