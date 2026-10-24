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
** Example: binary search trees
** A tree is allocated in the heap; it is a linear value (datavtype)
** that is owned by the program and must be freed.
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

datavtype bstree =
  | E of () | B of (bstree, string, bstree)
// end of [bstree]

(* ****** ****** *)
//
// [t0] is borrowed: the tree is only read
//
fun
bstree_inord
(
  t0: !bstree, fwork: &(string) -<clo1> void
) : void =
(
case+ t0 of
| E () => ()
| B (t1, k, t2) =>
  {
    val () = bstree_inord (t1, fwork)
    val () = fwork (k)
    val () = bstree_inord (t2, fwork)
  }
) (* end of [bstree_inord] *)

(* ****** ****** *)

fun
bstree_search
(
  t0: !bstree, k0: string
) : bool =
(
//
case+ t0 of
| E () => false
| B (t1, k, t2) => let
    val sgn = compare (k0, k)
  in
    case+ 0 of
    | _ when sgn < 0 => bstree_search (t1, k0)
    | _ when sgn > 0 => bstree_search (t2, k0)
    | _ (*k0 = k*) => true
  end // end of [B]
//
) (* end of [bstree_search] *)

(* ****** ****** *)
//
// [t0] is consumed and a tree is returned: the nodes that are
// visited are released and the new nodes are allocated
//
fun
bstree_insert
(
  t0: bstree, k0: string
) : bstree =
(
//
case+ t0 of
| ~E () => B (E, k0, E)
| ~B (t1, k, t2) => let
    val sgn = compare (k0, k)
  in
    case+ 0 of
    | _ when sgn < 0 => B (bstree_insert (t1, k0), k, t2)
    | _ when sgn > 0 => B (t1, k, bstree_insert (t2, k0))
    | _ (*k0 = k*) => B (t1, k, t2) // [k0] found and no actual insertion
  end // end of [B]
//
) (* end of [bstree_insert] *)

(* ****** ****** *)

fun
bstree_free
  (t0: bstree): void =
(
case+ t0 of
| ~E () => ()
| ~B (t1, _, t2) => (bstree_free (t1); bstree_free (t2))
) (* end of [bstree_free] *)

(* ****** ****** *)

implement
main0 () =
{
//
val t0 = E ()
val t0 = bstree_insert (t0, "banana")
val t0 = bstree_insert (t0, "apple")
val t0 = bstree_insert (t0, "cherry")
val t0 = bstree_insert (t0, "apple")
//
val () = assertloc (bstree_search (t0, "apple"))
val () = assertloc (bstree_search (t0, "cherry"))
val () = assertloc (~bstree_search (t0, "durian"))
//
var fwork = lam@ (k: string): void => (print k; print_newline ())
val () = bstree_inord (t0, fwork) // apple, banana, cherry
//
val ((*freed*)) = bstree_free (t0)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [bstree.dats] *)
