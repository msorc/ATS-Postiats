(* ****** ****** *)
//
// Estimating pi: the Monte Carlo method
//
(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
staload "libats/libc/SATS/stdlib.sats"
//
(* ****** ****** *)
//
#include "./../../05/CODE/listfun.hats"
//
(* ****** ****** *)
//
#define N 1024
stadef N = 1024
//
typedef
point = @(double, double)
//
vtypedef points = List0_vt(point)
//
(* ****** ****** *)
//
// The points that were chosen up to now are stored in the lists of
// the grid: each list is linear and so is the grid, which is a
// matrix of lists (each list is empty to begin with).
//
implement
matrix_tabulate$fopr<points>(i, j) = list_vt_nil()
//
(* ****** ****** *)
//
// the square of the distance (no need of the square root)
fun
dist2(p1: point, p2: point): double = let
  val dx = p1.0 - p2.0 and dy = p1.1 - p2.1
in
  dx*dx + dy*dy
end // end of [dist2]
//
fun
randfloat(): double = drand48()
//
(* ****** ****** *)
//
fun
hit_point_point
(
p1: point, p2: point
) : int =
(
if dist2(p1, p2) <= 1.0 then 1 else 0
)
//
fun
hit_point_points
(
p0: point, ps: !points
) : int = let
  var fopr =
  lam@(res: int, p1: point): int => res + hit_point_point(p0, p1)
in
  list_foldleft<int><point>(ps, 0, fopr)
end // end of [hit_point_points]
//
(* ****** ****** *)
//
// A grid cell holds a linear list of points. In order to read a list,
// it is taken out of the cell (and the cell holds the empty list for a
// moment), and it is put back after the reading.
//
fun
hit_point_cell
(
p0: point, grid: !matrixptr(points, N, N), i: int, j: int
) : int = let
//
val i = g1ofg0(i) and j = g1ofg0(j)
//
in
//
if
(i >= 0)
then if
(i < N)
then if
(j >= 0)
then if
(j < N)
then let
  var ps: points = list_vt_nil()
  val () = matrixptr_exch_at_int(grid, i, N, j, ps)
  val nhit = hit_point_points(p0, ps)
  val () = matrixptr_exch_at_int(grid, i, N, j, ps)
  val-~list_vt_nil() = ps
in
  nhit
end // end of [then]
else 0 else 0 else 0 else 0 // the position is not valid
//
end // end of [hit_point_cell]
//
(* ****** ****** *)
//
// Given a unit square at (i, j), the entire neighbors of the unit square
// are the 9 unit squares at (i+di, j+dj) for di and dj in {-1, 0, 1}.
//
fun
hit_point_neighbors
(
p0: point
, grid: !matrixptr(points, N, N), i: int, j: int
) : int = let
//
fun
loop
(grid: !matrixptr(points, N, N), k: int, res: int): int =
if k >= 9
  then res
  else loop(grid, k+1, res + hit_point_cell(p0, grid, i + k/3 - 1, j + k%3 - 1))
//
in
  loop(grid, 0, 0)
end // end of [hit_point_neighbors]
//
(* ****** ****** *)
//
// A point is added to the list of its cell
//
fun
theGrid_add_point
(
grid: !matrixptr(points, N, N), i: int, j: int, p: point
) : void = let
//
val i = g1ofg0(i) and j = g1ofg0(j)
//
in
//
if
(i >= 0)
then if
(i < N)
then if
(j >= 0)
then if
(j < N)
then let
  var ps: points = list_vt_nil()
  val () = matrixptr_exch_at_int(grid, i, N, j, ps)
  val () = ps := list_vt_cons(p, ps)
  val () = matrixptr_exch_at_int(grid, i, N, j, ps)
  val-~list_vt_nil() = ps
in
  // nothing
end // end of [then]
else () else () else () else () // the position is not valid
//
end // end of [theGrid_add_point]
//
(* ****** ****** *)
//
fun
do_one
(
grid: !matrixptr(points, N, N)
) : int = let
//
val x =
N * randfloat()
val y =
N * randfloat()
//
val p = @(x, y)
//
val i =
g0float2int_double_int(x)
val j =
g0float2int_double_int(y)
//
val nhit =
hit_point_neighbors(p, grid, i, j)
//
val () = theGrid_add_point(grid, i, j, p)
//
in
  nhit
end // end of [do_one]
//
(* ****** ****** *)
//
fun
do_all
(
grid: !matrixptr(points, N, N), K: int
) : int = let
//
fun
loop
(
grid: !matrixptr(points, N, N), i: int, res: int
) : int =
  if i < K then loop(grid, i+1, do_one(grid) + res) else res
//
in
  loop(grid, 0, 0)
end // end of [do_all]
//
(* ****** ****** *)
//
implement
matrix_uninitize$clear<points>(i, j, x) = list_vt_free<point>(x)
//
(* ****** ****** *)

implement
main0() = {
//
val () = srand48(0L)
//
val theGrid = matrixptr_tabulate<points>(i2sz(N), i2sz(N))
//
val total = do_all(theGrid, N*N)
val () =
println! ("do_all(N*N)/(N*N) = ", g0int2float_int_double(total) / (N*N), " (pi/2 = ", 3.14159265/2, ")")
//
val () = matrixptr_freelin<points>(theGrid, i2sz(N), i2sz(N))
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [EstimatePi.dats] *)
