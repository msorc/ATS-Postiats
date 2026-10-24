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
** Example: templates for loop construction
**
** Updated for the linear-only dialect of ATS2 (no GC)
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

fun
tally
(
  n: int
) : int = loop (0, 0) where
{
  fun loop (i: int, res: int): int =
    if i < n then loop (i + 1, res + i) else res
}

(* ****** ****** *)
//
// An envless function cannot accumulate a result unless it
// makes use of a reference; as there is no way to create a
// reference in the body of a function, the environment is passed
// explicitly (by reference), and the closure is a flat closure.
//
fun{
env:t@ype
} for_loop2
(
  count: int, limit: int
, env: &env >> _, fwork: &(int, &env >> _) -<clo1> void
) : void = (
//
if
count < limit
then (
  fwork(count, env); for_loop2<env> (count+1, limit, env, fwork)
) else ()
// end of [if]
//
) (* end of [for_loop2] *)

fun
tally3
(
  n: int
) : int = let
  var res: int = 0
  var fwork = lam@ (i: int, res: &int >> _): void => res := res + i
in
  for_loop2<int> (0, n, res, fwork); res
end // end of [tally3]

(* ****** ****** *)

extern
fun{
env:t@ype
} for_loop3$fwork(count: int, env: &env >> _): void

fun{
env:t@ype
} for_loop3
(
  count: int, limit: int, env: &env >> _
) : void = (
//
if
count < limit
then (
  for_loop3$fwork<env>(count, env); for_loop3<env>(count+1, limit, env)
) else ()
// end of [if]
//
) (* end of [for_loop3] *)

fun
tally4
(
  n: int
) : int = let
//
var res: int = 0
//
implement
for_loop3$fwork<int> (i, res) = res := res + i
//
in
  for_loop3<int> (0, n, res); res
end // end of [tally4]

(* ****** ****** *)

implement
main0 () =
{
//
val () = assertloc (tally (100) = 4950)
val () = assertloc (tally3 (100) = 4950)
val () = assertloc (tally4 (100) = 4950)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [loopcons.dats] *)
