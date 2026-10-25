(*
** Copyright (C) 2011 Hongwei Xi, Boston University
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
** Example:
** A Functional Implementation of Mergesort
*)

(* ****** ****** *)

(*
**
** Author: Hongwei Xi
** Authoremail: hwxiATcsDOTbuDOTedu
** Time: January, 2011
*)

(* ****** ****** *)

(*
** Ported to ATS2 by HX-2013-09
*)

(* ****** ****** *)

(*
** Ported to ATSCC2JS by HX-2014-10-12
*)

(* ****** ****** *)
//
#define
LIBATSCC2JS_targetloc
"$PATSHOME/contrib/libatscc2js"
//
(* ****** ****** *)
//
#include
"{$LIBATSCC2JS}/mylibies.hats"
staload
"{$LIBATSCC2JS}/SATS/print.sats"
staload _(*anon*) =
"{$LIBATSCC2JS}/DATS/print.dats"
//
(* ****** ****** *)

#define ATS_MAINATSFLAG 1
#define ATS_DYNLOADNAME "my_dynload"

(* ****** ****** *)
//
//
// HX-2026-10: no GC
// the lists are linear (they are consumed by sorting)
//
vtypedef
list0 (a:t@ype) = List0_vt (a)
//
typedef lte (a:t@ype) = (a, a) -> bool
//
(* ****** ****** *)

fun{
a:t@ype
} merge (
  xs: list0 a, ys: list0 a, lte: lte a
) : list0 a =
(
  case+ xs of
  | ~list_vt_nil () => ys
  | ~list_vt_cons (x, xs1) => (
    case+ ys of
    | ~list_vt_nil () => list_vt_cons (x, xs1)
    | ~list_vt_cons (y, ys1) =>
        if x \lte y then
          list_vt_cons{a}(x, merge<a> (xs1, list_vt_cons (y, ys1), lte))
        else
          list_vt_cons{a}(y, merge<a> (list_vt_cons (x, xs1), ys1, lte))
        // end of [if]
    ) // end of [list_vt_cons]
) (* end of [merge] *)

(* ****** ****** *)

fun{
a:t@ype
} mergesort
(
  xs: list0 a, lte: lte a
) : list0 a = let
//
val n = list_vt_length (xs)
//
fun msort
(
  xs: list0 a, n: int, lte: lte a
) : list0 a =
  if n >= 2 then split (xs, n, lte, n/2, list_vt_nil) else xs
//
and split
(
  xs: list0 a, n: int, lte: lte a, i: int, xsf: list0 a
) : list0 a = (
//
if
i > 0
then let
  val-~list_vt_cons (x, xs) = xs
in
  split (xs, n, lte, i-1, list_vt_cons{a}(x, xsf))
end // end of [then]
else let
  val xsf = list_vt_reverse (xsf) // make sorting stable!
  val xsf = msort (xsf, n/2, lte)
  val xs = msort (xs, n-n/2, lte)
in
  merge<a> (xsf, xs, lte)
end // end of [else]
//
) (* end of [split] *)
//
in
  msort (xs, n, lte)
end // end of [mergesort]

(* ****** ****** *)
//
fun{
a:t@ype
} print_list0
(
  xs: !list0 a
) : void = let
//
fun
loop
{n:int}
(
  xs: !list_vt(a, n), i: int
) : void =
(
case+ xs of
| list_vt_nil () => ()
| list_vt_cons (x, xs1) =>
  (
    if i > 0 then print! (", "); print_val<a> (x); loop (xs1, i+1)
  )
)
//
in
  loop (xs, 0)
end // end of [print_list0]
//
(* ****** ****** *)
//
extern
fun
main_js
(
// argumentless
) : void = "mac#"
//
implement
main_js ((*void*)) =
{
//
val xs =
(
list_vt_cons{int}(5, list_vt_cons{int}(3, list_vt_cons{int}(4, list_vt_cons{int}(6, list_vt_cons{int}(8, list_vt_cons{int}(0, list_vt_cons{int}(7, list_vt_cons{int}(1, list_vt_cons{int}(9, list_vt_cons{int}(2, list_vt_nil()))))))))))
) : list0(int)
//
val () = print! ("xs = ")
val () = print_list0<int> (xs)
val () = println! ()
val ys = mergesort<int> (xs, lam (x, y) => x <= y)
val () = print! ("mergesort(xs) = ")
val () = print_list0<int> (ys)
val () = println! ()
val () = list_vt_free (ys)
//
(* ****** ****** *)
//
val xs =
(
list_vt_cons{string}("5", list_vt_cons{string}("3", list_vt_cons{string}("4", list_vt_cons{string}("6", list_vt_cons{string}("8", list_vt_cons{string}("0", list_vt_cons{string}("7", list_vt_cons{string}("1", list_vt_cons{string}("9", list_vt_cons{string}("2", list_vt_nil()))))))))))
) : list0(string)
//
implement
print_val<string>
  (x) = print! ("\"", x, "\"")
//
val () = print! ("xs = ")
val () = print_list0<string> (xs)
val () = println! ()
val ys = mergesort<string> (xs, lam (x, y) => x <= y)
val () = print! ("mergesort(xs) = ")
val () = print_list0<string> (ys)
val () = println! ()
val () = list_vt_free (ys)
//
} (* end of [main_js] *)
//
(* ****** ****** *)

%{^
//
// file inclusion
//
var fs = require('fs');
eval(fs.readFileSync('./libatscc2js/CATS/basics_cats.js').toString());
eval(fs.readFileSync('./libatscc2js/CATS/integer_cats.js').toString());
eval(fs.readFileSync('./libatscc2js/CATS/string_cats.js').toString());
//
eval(fs.readFileSync('./libatscc2js/DATS/list_vt_dats.js').toString());
//
eval(fs.readFileSync('./libatscc2js/CATS/Node.js/basics_cats.js').toString());
eval(fs.readFileSync('./libatscc2js/CATS/Node.js/fprint_cats.js').toString());
//
%} // end of [%{^]

(* ****** ****** *)

%{$
//
main_js()
//
%} // end of [%{$]

(* ****** ****** *)

(* end of [mergesort.dats] *)
