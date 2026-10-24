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
** Example: exceptions and Braun trees
**
** Updated for the linear-only dialect of ATS2 (no GC): trees are linear (datavtype)
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

exception FatalError0 of ()
exception FatalError1 of (string)

exception DivisionByZero of ()

fun
divexn(x: int, y: int): int =
  if y != 0 then x / y else $raise DivisionByZero()

fun prod1
(
  f: int -> int, i: int, n: int
) : int =
  if i < n then f(i) * prod1(f, i+1, n) else 1

fun prod2
(
  f: int -> int, i: int, n: int
) : int =
  if i < n then let
    val x = f(i)
  in
    if x = 0 then 0 else x * prod2(f, i+1, n)
  end else 1

fun prod3
(
  f: int -> int, n: int
) : int = let
  exception ZERO of ()
  fun aux(i: int): int =
    if i < n then let
      val x = f(i)
    in
      if x = 0 then $raise ZERO() else x * aux(i+1)
    end else 1
  // end of [aux]
in
  try aux(0) with ~ZERO() => 0
end // end of [prod3]

datavtype tree (a:t@ype) =
  | tree_nil of ((*void*))
  | tree_cons of (a, tree(a)(*left*), tree(a)(*right*))
// end of [tree] // end of [datavtype]

fun{
a:t@ype
} size
(
t0: !tree(a)
) : int =
(
case+ t0 of
| tree_nil() => 0
| tree_cons(_, tl, tr) => 1 + size(tl) + size(tr)
) (* end of [size] *)

fun{
a:t@ype
} brauntest0
(
t0: !tree(a)
) : bool =
(
case+ t0 of
| tree_nil() => true
| tree_cons(_, tl, tr) => let
    val test = brauntest0(tl) andalso brauntest0(tr)
  in
    if test
      then let
        val dif = size(tl)-size(tr) in (dif=0) orelse (dif=1)
      end else false
    // end of [if]
  end // end of [tree_cons]
) (* end of [brauntest0] *)

fun{
a:t@ype
} brauntest1
(
t0: !tree(a)
) : bool = let
//
// [aux] returns the size of a Braun tree or ~1 if the tree is not one
//
  fun
  aux
  (
  t0: !tree(a)
  ) : int =
  (
    case+ t0 of
    | tree_nil() => 0
    | tree_cons
        (_, tl, tr) => let
        val szl = aux(tl)
      in
        if szl < 0 then ~1 else let
          val szr = aux(tr)
        in
          if szr < 0 then ~1 else let
            val dif = szl - szr
          in
            if (dif=0 orelse dif=1) then 1+szl+szr else ~1
          end
        end
      end // end of [tree_cons]
  ) (* end of [aux] *)
//
in
  aux(t0) >= 0
end // end of [brauntest1]

fun{
a:t@ype
} tree_free
  (t0: tree(a)): void =
  case+ t0 of
  | ~tree_nil () => ()
  | ~tree_cons (_, tl, tr) => (tree_free<a> (tl); tree_free<a> (tr))

implement main0 () = {
  val () = println! (prod1 (lam i => 4 - i, 0, 6), " ", prod2 (lam i => 4 - i, 0, 6), " ", prod3 (lam i => 4 - i, 6))
  val t = tree_cons (1, tree_cons (2, tree_nil, tree_nil), tree_nil{int}())
  val () = println! (brauntest0<int> t, " ", brauntest1<int> t)
  val ((*freed*)) = tree_free<int> (t)
  val r = try divexn (1, 0) with ~DivisionByZero () => ~1
  val () = println! (r)
}

(* ****** ****** *)

(* end of [brauntest.dats] *)
