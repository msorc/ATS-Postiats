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
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

staload "./mylist.sats"
staload _(*anon*) = "./mylist.dats"

(* ****** ****** *)

implement
main0 () =
{
//
val xs = mylist_cons (1, mylist_cons (2, mylist_cons (3, mylist_nil ())))
//
val () = assertloc (mylist_length (xs) = 3)
//
var f = lam@ (res: int, x: int): int => res * 10 + x
val res = mylist_fold_left<int><int> (xs, f, 0)
val () = assertloc (res = 123)
//
var g = lam@ (x: int, y: int): int => x + y
val res = app2<int,int><int> (g, 1, 2)
val () = assertloc (res = 3)
//
val () = mylist_free (xs)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [test_mylist.dats] *)
