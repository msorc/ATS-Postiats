(* ****** ****** *)
//
// The 8-queen puzzle: a node is a linear list
// of integers (the columns of the queens, the last queen first)
//
#define N 8
//
vtypedef node = List0_vt(int)
//
(* ****** ****** *)
//
fun
node_init(): node = list_vt_nil()
//
fun
node_length(nx: !node): int = list_length<int>(nx)
//
fun
node_free(nx: node): void = list_vt_free<int>(nx)
//
fun
nodes_free(nxs: List0_vt(node)): void =
(
case+ nxs of
| ~list_vt_nil() => ()
| ~list_vt_cons(nx, nxs) => (node_free(nx); nodes_free(nxs))
)
//
(* ****** ****** *)
//
fun
test_safety
(
xs: !List0_vt(int)
) : bool = let
//
in
//
case+ xs of
| list_vt_nil() => true
| list_vt_cons(x0, xs) => let
    var test = // abs: absolute value
    lam@(i: int, x: int): bool => (x0 != x && abs(x0-x) != (i+1))
  in
    list_iforall<int>(xs, test)
  end // end of [list_vt_cons]
//
end // end of [test_safety]
//
(* ****** ****** *)
//
// The children of a node: the nodes that extend it
// with a queen in a safe column. A node that is not safe is freed.
//
fun
node_get_children
  (nx: !node): List0_vt(node) = let
//
fun
loop(nx: !node, x: int): List0_vt(node) =
if
(x >= N)
then list_vt_nil()
else let
  val nx1 = list_vt_cons(x, list_vt_copy<int>(nx))
in
  if test_safety(nx1)
    then list_vt_cons(nx1, loop(nx, x+1))
    else (node_free(nx1); loop(nx, x+1))
end // end of [else]
//
in
  loop(nx, 0)
end // end of [node_get_children]
//
(* ****** ****** *)
//
// All of the nodes in the tree rooted at a given node, listed in the
// depth-first order. The given node is consumed: it becomes the head of
// the result.
//
fun
node_dfsenum
(nx0: node): List0_vt(node) = let
  val nxs = node_get_children(nx0)
in
  list_vt_cons(nx0, auxlst(nxs))
end // end of [node_dfsenum]
//
and
auxlst
(nxs: List0_vt(node)): List0_vt(node) =
(
case+ nxs of
| ~list_vt_nil() => list_vt_nil()
| ~list_vt_cons(nx, nxs) =>
  list_vt_append<node>(node_dfsenum(nx), auxlst(nxs))
)
//
(* ****** ****** *)
//
// Only the nodes of length N are kept: the others are freed.
//
fun
keep_solutions
(nxs: List0_vt(node)): List0_vt(node) =
(
case+ nxs of
| ~list_vt_nil() => list_vt_nil()
| ~list_vt_cons(nx, nxs) =>
  if node_length(nx) = N
    then list_vt_cons(nx, keep_solutions(nxs))
    else (node_free(nx); keep_solutions(nxs))
)
//
fun
QueenSolve(): List0_vt(node) =
keep_solutions(node_dfsenum(node_init()))
//
fun
QueenCount(): int = let
  val nxs = QueenSolve()
  val n = list_vt_length<node>(nxs)
in
  nodes_free(nxs); n
end // end of [QueenCount]
//
(* ****** ****** *)

(* end of [queens.hats] *)
