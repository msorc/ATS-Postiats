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
**
** The values of the datavtype [mylist] are allocated in the heap and
** are owned: they have to be freed explicitly.
*)

(* ****** ****** *)

datavtype
mylist (a:t@ype+) =
  | mylist_nil of () | mylist_cons of (a, mylist a)
// end of [mylist]

(* ****** ****** *)
//
// the list is consumed
//
fun{a:t@ype}
mylist_free (xs: mylist a): void
//
// the list is borrowed
//
fun{a:t@ype}
mylist_length (xs: !mylist a): int
//
(* ****** ****** *)
//
// the list is borrowed (the elements are not linear)
//
fun{
a:t@ype}{b:t@ype
} mylist_fold_left
  (xs: !mylist b, f: &(a, b) -<clo1> a, init: a): a
//
(* ****** ****** *)
//
// the function [f] is a flat closure that is passed by reference
//
fun
{a,b:t0p}{c:t0p}
app2 (f: &(a, b) -<clo1> c, x: a, y: b): c
//
(* ****** ****** *)

(* end of [mylist.sats] *)
