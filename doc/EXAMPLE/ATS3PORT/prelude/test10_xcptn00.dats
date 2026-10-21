(* ****** ****** *)
//
// A port of the ATS3 test
//
//   prelude/TEST/CATS/JS/test10_xcptn00.dats
//
// ATS3 exceptions are declared with [datatype]; in ATS2 they
// are declared with [exception] (with the payload type in
// parentheses) and they are matched with a [~] pattern.
//
// The ATS3 test checks that a tree is an AVL tree; the check
// raises an exception as soon as a node is found to be
// unbalanced.  In ATS2 a [datavtype] is linear and its content
// is accessed through views, so a tree cannot be shared and
// cannot be traversed destructively.  The trees are therefore
// represented by the heights of the subtrees of their nodes
// (one pair per node, in pre-order), which is enough for the
// check.
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

staload "prelude/SATS/integer.sats"

(* ****** ****** *)

exception
ErrmsgExn of (string)

exception
NotAVL of ((*void*))

(* ****** ****** *)

fun
raise_it (): void = $raise ErrmsgExn ("ErrmsgExn")

(* ****** ****** *)

fun
abs (x: int): int =
  if x >= 0 then x else ~x

(* ****** ****** *)
//
// [raise_not_avl]: raising the exception [NotAVL].
//
fun
raise_not_avl (): void = $raise NotAVL ()

(* ****** ****** *)
//
// [check1]: checking that a node is balanced.
//
fun
check2 (A: @(int, int)): void =
  if abs (A.0 - A.1) <= 1 then () else raise_not_avl ()

(* ****** ****** *)
//
// [check2], [check3]: checking that all the nodes of a tree are
// balanced.
//
fun
check4 (A: @(int, int, int, int)): void =
(
  check2 (@(A.0, A.1)); check2 (@(A.2, A.3))
)

fun
check6 (A: @(int, int, int, int, int, int)): void =
(
  check2 (@(A.0, A.1)); check4 (@(A.2, A.3, A.4, A.5))
)

(* ****** ****** *)
//
// [tree_AVLq]: is the tree an AVL tree?
//
fun
tree_AVLq2 (A: @(int, int)): bool =
(
try
  let
    val () = check2 (A)
  in
    true
  end
with
  ~NotAVL () => false
) (* end of [tree_AVLq2] *)

fun
tree_AVLq4 (A: @(int, int, int, int)): bool =
(
try
  let
    val () = check4 (A)
  in
    true
  end
with
  ~NotAVL () => false
) (* end of [tree_AVLq4] *)

fun
tree_AVLq6 (A: @(int, int, int, int, int, int)): bool =
(
try
  let
    val () = check6 (A)
  in
    true
  end
with
  ~NotAVL () => false
) (* end of [tree_AVLq6] *)

(* ****** ****** *)

implement
main0 () = {
  val () =
  try
    let
      val () = raise_it ()
    in
      ()
    end
  with
    ~ErrmsgExn (msg) => println! ("msg = ", msg)
  // a tree with a single node whose two subtrees are empty
  val t1 = @(0, 0)
  // a tree with a node whose left subtree is empty and whose
  // right subtree is the tree [t1]
  val t2 = @(0, 1, 0, 0)
  // a tree with a node whose left subtree is empty and whose
  // right subtree is the tree [t2]
  val t3 = @(0, 2, 0, 1, 0, 0)
  val () = println! ("ans1 = ", tree_AVLq2 (t1))
  val () = println! ("ans2 = ", tree_AVLq4 (t2))
  val () = println! ("ans3 = ", tree_AVLq6 (t3))
} // end of [main0]

(* ****** ****** *)

(* end of [test10_xcptn00.dats] *)
