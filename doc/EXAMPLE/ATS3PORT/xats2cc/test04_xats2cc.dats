(* ****** ****** *)
//
// A port of the ATS3 test
//
//   srcgen2/xats2cc/srcgen1/TEST/test04_xats2cc.dats
//
// The test exercises the user-defined datatypes and the
// pattern matching over them.
//
// In ATS2 a [datatype] with a non-nullary constructor is
// rejected (there is no garbage collector) and a [datavtype]
// is a linear heap-allocated structure that cannot be consumed
// (there is no way of freeing it outside the prelude).  The
// trees are therefore represented by a [list_vt] of nodes,
// each node being a triple of the heights of the two subtrees
// of the node and of the value of the node.
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

staload "prelude/SATS/integer.sats"
staload "prelude/SATS/list_vt.sats"

(* ****** ****** *)

fun
tsize {n:int} (xs: !list_vt(@(int, int, int), n)): int =
(
case+ xs of
| list_vt_nil () => 0
| list_vt_cons (x, xs1) => 1 + tsize (xs1)
) (* end of [tsize] *)

(* ****** ****** *)

implement
main0 () = {
  val the_tree = $list_vt{@(int, int, int)} (@(0, 0, 7), @(0, 1, 1), @(0, 0, 1))
  val the_size = tsize (the_tree)
  val () = println! ("the_size = ", the_size)
  val () = list_vt_free (the_tree)
} // end of [main0]

(* ****** ****** *)

(* end of [test04_xats2cc.dats] *)
