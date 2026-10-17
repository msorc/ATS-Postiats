(*
** HX-2026-10: no GC
** Linear (heap-allocated) values that are supported;
** everything allocated here is also freed.
*)
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
//
// enumerations allocate nothing
//
datatype color = Red | Green | Blue
//
fun color2int (c: color): int =
  case+ c of Red () => 0 | Green () => 1 | Blue () => 2
//
// heap-allocated data must be linear
//
datavtype tree =
  | Leaf of () | Node of (tree, int, tree)
//
fun tree_sum (t: !tree): int =
  case+ t of
  | Leaf () => 0 | Node (l, x, r) => tree_sum (l) + x + tree_sum (r)
//
fun tree_free (t: tree): void =
  case+ t of
  | ~Leaf () => () | ~Node (l, _, r) => (tree_free (l); tree_free (r))
//
exception MyExn of (int)
//
implement
main0 () = {
//
val () = println! ("color = ", color2int (Blue))
//
val t = Node (Node (Leaf, 1, Leaf), 2, Node (Leaf, 3, Leaf))
val () = println! ("tree_sum = ", tree_sum (t))
val () = tree_free (t)
//
// $list builds a list_vt
//
val xs = $list{int}(1, 2, 3)
val () = (fprint_list_vt (stdout_ref, xs); print_newline ())
val () = list_vt_free (xs)
//
// flat tuples and records are not heap-allocated
//
val tup = @(1, 2)
val rcd = @{ a=3, b=4 }
val () = println! ("flat = ", tup.0 + tup.1 + rcd.a + rcd.b)
//
// a linear closure must be freed
//
val y = 10
val f = llam (x: int): int =<cloptr1> x + y
val () = println! ("cloptr = ", f (32))
val () = cloptr_free ($UN.castvwtp0{cloptr(void)}(f))
//
// a linear lazy value must be freed or evaluated
//
val z = $ldelay (40 + 2)
val () = println! ("ldelay = ", !z)
//
// exceptions are linear: a handler consumes them
//
val n =
(
  try $raise MyExn (42) with ~MyExn (n) => n
) : int // end of [val]
val () = println! ("exception = ", n)
//
} (* end of [main0] *)
