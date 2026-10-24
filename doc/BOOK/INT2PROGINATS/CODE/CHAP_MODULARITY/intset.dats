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
#define ATS_DYNLOADFLAG 0 // no need for dynloading at run-time
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

staload "./mylist.sats"
staload _(*anon*) = "./mylist.dats"
staload "./intset.sats"

(* ****** ****** *)
//
// A set of integers is represented as an ordered list of integers
//
assume intset_vtype = mylist (int)
//
(* ****** ****** *)

implement intset_make_nil () = mylist_nil ()

implement intset_make_sing (x) = mylist_cons (x, mylist_nil ())

implement intset_free (xs) = mylist_free<int> (xs)

implement intset_size (xs) = mylist_length<int> (xs)

implement intset_listize (xs) = xs

(* ****** ****** *)

implement
intset_ismem
  (xs, x0) = (
case+ xs of
| mylist_nil () => false
| mylist_cons (x, xs) => let
    val sgn = compare (x0, x)
  in
    if sgn > 0 then intset_ismem (xs, x0) else (sgn = 0)
  end // end of [mylist_cons]
) (* end of [intset_ismem] *)

(* ****** ****** *)

implement
intset_union
  (xs1, xs2) = (
case+ xs1 of
| ~mylist_cons (x1, xs11) =>
  (
    case+ xs2 of
    | ~mylist_cons (x2, xs21) => let
        val sgn = compare (x1, x2)
      in
        case+ 0 of
        | _ when sgn < 0 =>
            mylist_cons{int}(x1, intset_union (xs11, mylist_cons{int}(x2, xs21)))
        | _ when sgn > 0 =>
            mylist_cons{int}(x2, intset_union (mylist_cons{int}(x1, xs11), xs21))
        | _ (* sgn = 0 *) =>
            mylist_cons{int}(x1, intset_union (xs11, xs21))
        // end of [case]
      end // end of [(cons, cons)]
    | ~mylist_nil () => mylist_cons{int}(x1, xs11)
  ) (* end of [mylist_cons] *)
| ~mylist_nil () => xs2
) (* end of [intset_union] *)

(* ****** ****** *)

implement
intset_inter
  (xs1, xs2) = (
case+ xs1 of
| ~mylist_cons (x1, xs11) =>
  (
    case+ xs2 of
    | ~mylist_cons (x2, xs21) => let
        val sgn = compare (x1, x2)
      in
        case+ 0 of
        | _ when sgn < 0 =>
            intset_inter (xs11, mylist_cons{int}(x2, xs21))
        | _ when sgn > 0 =>
            intset_inter (mylist_cons{int}(x1, xs11), xs21)
        | _ (* sgn = 0 *) =>
            mylist_cons{int}(x1, intset_inter (xs11, xs21))
        // end of [case]
      end // end of [(cons, cons)]
    | ~mylist_nil () => (mylist_free<int> (xs11); mylist_nil ())
  ) (* end of [mylist_cons] *)
| ~mylist_nil () => (mylist_free<int> (xs2); mylist_nil ())
) (* end of [intset_inter] *)

(* ****** ****** *)

implement
intset_differ
  (xs1, xs2) = (
case+ xs1 of
| ~mylist_cons (x1, xs11) =>
  (
    case+ xs2 of
    | ~mylist_cons (x2, xs21) => let
        val sgn = compare (x1, x2)
      in
        case+ 0 of
        | _ when sgn < 0 =>
            mylist_cons{int}(x1, intset_differ (xs11, mylist_cons{int}(x2, xs21)))
        | _ when sgn > 0 =>
            intset_differ (mylist_cons{int}(x1, xs11), xs21)
        | _ (* sgn = 0 *) =>
            intset_differ (xs11, xs21)
        // end of [case]
      end // end of [(cons, cons)]
    | ~mylist_nil () => mylist_cons{int}(x1, xs11)
  ) (* end of [mylist_cons] *)
| ~mylist_nil () => (mylist_free<int> (xs2); mylist_nil ())
) (* end of [intset_differ] *)

(* ****** ****** *)

implement intset_add (xs, x) = intset_union (xs, intset_make_sing (x))

implement intset_del (xs, x) = intset_differ (xs, intset_make_sing (x))

(* ****** ****** *)

implement
intset_make_list
  (xs) = (
case+ xs of
| ~mylist_nil () => mylist_nil ()
| ~mylist_cons (x, xs) => intset_add (intset_make_list (xs), x)
) (* end of [intset_make_list] *)

(* ****** ****** *)

(* end of [intset.dats] *)
