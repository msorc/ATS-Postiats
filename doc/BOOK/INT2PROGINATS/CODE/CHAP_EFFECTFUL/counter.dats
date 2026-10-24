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
** References, local variables and counters
**
** Updated for the linear-only dialect of ATS2 (no GC)
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

var count: int = 0
val intr = ref_make_viewptr{int}(view@count | addr@count)

val ((*void*)) = !intr := !intr + 1 // increase the integer at [intr] by 1

fun sumup (n: int): int = let
  var i: int = 1
  var res: int = 0
  fun loop (i: &int >> _, res: &int >> _, n: int): void =
    if i <= n then (res := res + i; i := i + 1; loop (i, res, n))
in
  loop (i, res, n); res
end

datavtype counter = Counter of (int)

fun counter_new (): counter = Counter (0)

fun counter_get (c: !counter): int = let
  val+ Counter (n) = c
in
  n
end

fun counter_inc (c: !counter): void = let
  val+ @Counter (n) = c
  val () = n := n + 1
  prval () = fold@ (c)
in
  ()
end

fun counter_reset (c: !counter): void = let
  val+ @Counter (n) = c
  val () = n := 0
  prval () = fold@ (c)
in
  ()
end

fun counter_free (c: counter): void = let
  val ~Counter (_) = c
in
  ()
end

implement main0 () = {
  val () = println! (!intr)
  val () = println! (ref_get_elt (intr))
  val () = println! (sumup (10))
  val c = counter_new ()
  val () = counter_inc (c)
  val () = counter_inc (c)
  val () = println! (counter_get (c))
  val () = counter_reset (c)
  val () = println! (counter_get (c))
  val () = counter_free (c)
}

(* ****** ****** *)

(* end of [counter.dats] *)
