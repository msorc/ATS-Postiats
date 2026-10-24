(* ****** ****** *)
//
// The depth-first enumeration of the tree of the nodes
// (it uses [queens.hats])
//
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
