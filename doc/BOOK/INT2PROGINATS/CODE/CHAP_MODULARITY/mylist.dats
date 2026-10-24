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
** A package for linear lists
*)

(* ****** ****** *)
//
#define ATS_DYNLOADFLAG 0 // no need for dynloading at run-time
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

staload "./mylist.sats"

(* ****** ****** *)

implement{a}
mylist_free (xs) =
(
  case+ xs of
  | ~mylist_cons (_, xs) => mylist_free<a> (xs) | ~mylist_nil () => ()
) (* end of [mylist_free] *)

(* ****** ****** *)

implement{a}
mylist_length (xs) =
(
  case+ xs of
  | mylist_cons (_, xs) => 1 + mylist_length<a> (xs) | mylist_nil () => 0
) (* end of [mylist_length] *)

(* ****** ****** *)

implement{a}{b}
mylist_fold_left
  (xs, f, init) = let
//
fun loop
(
  xs: !mylist b, f: &(a, b) -<clo1> a, res: a
) : a =
(
  case+ xs of
  | mylist_nil () => res
  | mylist_cons (x, xs) => let
      val res = f (res, x) in loop (xs, f, res)
    end // end of [mylist_cons]
) (* end of [loop] *)
//
in
  loop (xs, f, init)
end // end of [mylist_fold_left]

(* ****** ****** *)
//
// Template parameters can also be passed sequentially
//
implement{a,b}{c} app2 (f, x, y) = f (x, y)

(* ****** ****** *)

(* end of [mylist.dats] *)
