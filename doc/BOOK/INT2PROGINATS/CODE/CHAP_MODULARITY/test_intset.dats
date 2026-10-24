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
staload "./intset.sats"

(* ****** ****** *)

fun
print_intset
  (xs: intset): void = let
//
fun loop (xs: !mylist(int)): void =
  case+ xs of
  | mylist_nil () => ()
  | mylist_cons (x, xs) => (print x; print ' '; loop (xs))
//
val xs = intset_listize (xs)
//
in
  loop (xs); print_newline (); mylist_free<int> (xs)
end // end of [print_intset]

(* ****** ****** *)

implement
main0 () =
{
//
val xs = mylist_cons (3, mylist_cons (1, mylist_cons (2, mylist_cons (3, mylist_nil ()))))
val s1 = intset_make_list (xs) // {1, 2, 3}
val () = assertloc (intset_size (s1) = 3)
val () = assertloc (intset_ismem (s1, 2))
val () = assertloc (~intset_ismem (s1, 4))
//
val s2 = intset_add (intset_make_sing (4), 2) // {2, 4}
//
val s3 = intset_union (s1, s2) // {1, 2, 3, 4}
val () = assertloc (intset_size (s3) = 4)
val () = print_intset (s3)
//
val s4 = intset_inter (intset_add (intset_add (intset_make_nil (), 2), 5), intset_add (intset_make_sing (2), 4)) // {2}
val () = assertloc (intset_size (s4) = 1)
val () = intset_free (s4)
//
val s5 = intset_del (intset_add (intset_add (intset_make_nil (), 1), 2), 2) // {1}
val () = assertloc (intset_size (s5) = 1)
val () = intset_free (s5)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [test_intset.dats] *)
