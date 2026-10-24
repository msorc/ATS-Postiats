(* ****** ****** *)
//
// The 8-queen puzzle revisited: the nodes are enumerated lazily
//
(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
staload UN = "prelude/SATS/unsafe.sats"
//
(* ****** ****** *)
//
#include "./../../05/CODE/listfun.hats"
#include "./../../06/CODE/listfun2.hats"
#include "./../../10/CODE/streamfun.hats"
//
(* ****** ****** *)
//
// [node], [N], [node_init], [node_length], [node_free],
// [nodes_free], [test_safety] and [node_get_children]
// are those of the earlier chapter
//
#include "./../../06/CODE/queens.hats"
//
(* ****** ****** *)
//
extern
fun
node_dfsenum
  (nx0: node): stream_vt(node)
//
// a list of streams is flattened lazily into a stream
//
extern
fun
list_stream_concat
  (xss: List0_vt(stream_vt(node))): stream_vt(node)
//
// each node of a list of nodes is turned into the stream of
// the nodes of the tree rooted at the node (nothing is
// enumerated at this point)
//
extern
fun
nodes_dfsenum
  (nxs: List0_vt(node)): List0_vt(stream_vt(node))
//
(* ****** ****** *)
//
implement
node_dfsenum(nx0) = $ldelay
(
let
  val nxs = node_get_children(nx0)
  val xss = nodes_dfsenum(nxs)
in
  stream_vt_cons(nx0, list_stream_concat(xss))
end // end of [let]
,
node_free(nx0) // called when the stream is freed
) (* node_dfsenum *)
//
implement
nodes_dfsenum(nxs) =
(
case+ nxs of
| ~list_vt_nil() => list_vt_nil()
| ~list_vt_cons(nx, nxs) =>
  list_vt_cons(node_dfsenum(nx), nodes_dfsenum(nxs))
)
//
(* ****** ****** *)
//
fun
streams_free
(xss: List0_vt(stream_vt(node))): void =
(
case+ xss of
| ~list_vt_nil() => ()
| ~list_vt_cons(xs, xss) => (~xs; streams_free(xss))
)
//
//
// the version of [stream_append] for the streams of nodes
// (a node is linear)
//
fun
stream_append_nodes
(xs: stream_vt(node), ys: stream_vt(node)): stream_vt(node) = $ldelay
(
(
case+ !xs of
| ~stream_vt_nil() => !ys
| ~stream_vt_cons(x, xs) =>
  stream_vt_cons(x, stream_append_nodes(xs, ys))
) : stream_vt_con(node)
,
(~xs; ~ys)
)
//
implement
list_stream_concat(xss) = $ldelay
(
(
case+ xss of
| ~list_vt_nil() => stream_vt_nil()
| ~list_vt_cons(xs, xss) => !(stream_append_nodes(xs, list_stream_concat(xss)))
) : stream_vt_con(node)
,
streams_free(xss)
) (* list_stream_concat *)
//
(* ****** ****** *)
//
// Only the nodes of length N are kept: the others are freed
//
fun
keep_solutions
(nxs: stream_vt(node)): stream_vt(node) = $ldelay
(
(
case+ !nxs of
| ~stream_vt_nil() => stream_vt_nil()
| ~stream_vt_cons(nx, nxs) =>
  if node_length(nx) = N
    then stream_vt_cons(nx, keep_solutions(nxs))
    else (node_free(nx); !(keep_solutions(nxs)))
) : stream_vt_con(node)
,
~nxs
)
//
fun
QueenSolve(): stream_vt(node) =
keep_solutions(node_dfsenum(node_init()))
//
(* ****** ****** *)

implement
main0() = {
//
val sols = QueenSolve()
//
// the first solution is found without enumerating the others
//
val-~stream_vt_cons(nx, sols) = !sols
val () = println! ("the first solution: ", nx)
val () = node_free(nx)
//
// the other solutions are counted (and freed) one by one
//
fun
count(sols: stream_vt(node), res: int): int =
(
case+ !sols of
| ~stream_vt_nil() => res
| ~stream_vt_cons(nx, sols) => (node_free(nx); count(sols, res+1))
)
//
val () = println! ("the other solutions: ", count(sols, 0))
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [QueenPuzzle.dats] *)
