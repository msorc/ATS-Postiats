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
** Example: a recursively defined datatype
** The values of a recursive datatype are allocated in the heap
** and must be owned: this is a datavtype (a linear datatype).
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

datavtype charlst =
  | charlst_nil of ()
  | charlst_cons of (char, charlst)
// end of [charlst]

(* ****** ****** *)
//
// A borrowed list (of the type !charlst) is only read
//
fun
charlst_length
(
  cs: !charlst
) : int =
  case+ cs of
  | charlst_nil() => 0
  | charlst_cons(_, cs) => 1 + charlst_length(cs)
// end of [charlst_length]

(* ****** ****** *)

fun
charlst_length2
  (cs: !charlst): int = let
//
fun loop
  (cs: !charlst, n: int): int = case+ cs of
  | charlst_nil() => n | charlst_cons (_, cs) => loop(cs, n+1)
// end of [loop]
//
in
  loop (cs, 0)
end // end of [charlst_length2]

(* ****** ****** *)
//
// A list that is passed by value is consumed: it must be freed
//
fun
charlst_free
  (cs: charlst): void =
  case+ cs of
  | ~charlst_nil() => ()
  | ~charlst_cons(_, cs) => charlst_free(cs)
// end of [charlst_free]

(* ****** ****** *)

fun
charlst_last
  (cs: !charlst): char =
(
  case cs of
  | charlst_cons (c, charlst_nil ()) => c
  | charlst_cons (_, cs1) => charlst_last (cs1)
) (* end of [charlst_last] *)

(* ****** ****** *)

fun
charlst_last2
  (cs: !charlst): char =
(
  case cs of
  | charlst_cons (c, cs1) =>
    (
      case+ cs1 of
      | charlst_nil () => c | charlst_cons _ => charlst_last2 (cs1)
    ) // end of [charlst_cons]
) // end of [charlst_last2]

(* ****** ****** *)

fun
charlst_last3
  (cs: !charlst): char = let
  val charlst_cons (c, cs1) = cs in case+ cs1 of
  | charlst_nil () => c | charlst_cons _ => charlst_last3 (cs1)
end // end of [charlst_last3]

(* ****** ****** *)

implement
main0 () =
{
//
val cs =
  charlst_cons('a', charlst_cons('b', charlst_cons('c', charlst_nil())))
//
val () = assertloc (charlst_length (cs) = 3)
val () = assertloc (charlst_length2 (cs) = 3)
val () = assertloc (charlst_last (cs) = 'c')
val () = assertloc (charlst_last2 (cs) = 'c')
val () = assertloc (charlst_last3 (cs) = 'c')
//
val () = charlst_free (cs)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [charlst.dats] *)
