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
** Genericity of template implementations
**
** Partially generic template implementations: updated for the linear-only dialect of ATS2 (no GC)
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

datavtype
mylist (a:t@ype+) =
  | mylist_nil of () | mylist_cons of (a, mylist a)
// end of [mylist]

(* ****** ****** *)

fun{a:t@ype}
mylist_free (xs: mylist a): void =
  case+ xs of
  | ~mylist_nil () => () | ~mylist_cons (_, xs) => mylist_free<a> (xs)

(* ****** ****** *)
//
// the argument is borrowed, and the type of the argument can be linear
//
extern
fun{a:vt@ype} myprint (x: !a): void

implement{a} myprint (x) = print_string "?"

implement myprint<int> (x) = print_int (x)

implement(a)
myprint<mylist(a)> (xs) =
(
case+ xs of
| mylist_nil () => ()
| mylist_cons (x, xs) =>
    (myprint<a> (x); myprint<mylist(a)> (xs))
)

(* ****** ****** *)

extern
fun{a:vt@ype} myprint2 (x: !a): int

(*
implement(a)
myprint2<mylist(a)> (xs) =
(
case+ xs of
| mylist_nil () => 0
| mylist_cons (x, xs) =>
    (myprint<a> (x); 1 + myprint2<mylist(a)> (xs))
) // a recursive instance
*)

implement(a)
myprint2<mylist(a)>
  (xs) = let
//
fun
aux
(xs: !mylist(a)): int =
//
case+ xs of
| mylist_nil () => 0
| mylist_cons (x, xs) => (myprint<a>(x); 1 + aux(xs))
//
in
  aux (xs)
end // end of [myprint2<mylist(a)>]

(* ****** ****** *)

implement
main0 () =
{
//
// The output is "01234"
//
val ys = mylist_cons (0, mylist_cons (1, mylist_cons (2, mylist_cons (3, mylist_cons (4, mylist_nil)))))
val ((*void*)) = myprint<mylist(int)> (ys)
val ((*void*)) = print_newline((*void*))
val () = assertloc (myprint2<mylist(int)> (ys) = 5)
val ((*void*)) = print_newline((*void*))
val () = mylist_free<int> (ys)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [myprint.dats] *)
