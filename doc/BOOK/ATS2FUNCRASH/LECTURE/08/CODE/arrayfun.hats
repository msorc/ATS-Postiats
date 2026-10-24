(* ****** ****** *)
(*
** The array and matrix combinators of LECTURE/08 (the library
** of the book). An array is a linear value (arrayptr) that is
** freed by its owner, and its size is not stored in it:
** the size is passed along (as an integer of a singleton type).
** The function arguments are flat closures that are passed by reference.
*)
(* ****** ****** *)
//
extern
fun
{a:t0p}
arrayptr_foreach
  {n:nat}
(
A: !arrayptr(a, n), asz: int(n), fwork: &(a) -<clo1> void
) : void // end of [arrayptr_foreach]
//
implement
{a}(*tmp*)
arrayptr_foreach{n}(A, asz, fwork) =
loop(A, 0, fwork) where
{
fun
loop
{i:nat | i <= n}
(
A: !arrayptr(a, n), i: int(i), fwork: &(a) -<clo1> void
) : void =
  if i < asz then (fwork(A[i]); loop(A, i+1, fwork)) else ()
} (* end of [arrayptr_foreach] *)
//
(* ****** ****** *)
//
extern
fun
{r:t0p}
{a:t0p}
arrayptr_foldleft
  {n:nat}
(
A: !arrayptr(a, n), asz: int(n), r0: r, fopr: &(r, a) -<clo1> r
) : r // end of [arrayptr_foldleft]
//
implement
{r}{a}
arrayptr_foldleft
  {n}(A, asz, r0, fopr) =
loop(A, 0, r0, fopr) where
{
fun
loop
{i:nat | i <= n}
(
A: !arrayptr(a, n), i: int(i), r0: r, fopr: &(r, a) -<clo1> r
) : r =
  if i < asz then loop(A, i+1, fopr(r0, A[i]), fopr) else r0
} (* end of [arrayptr_foldleft] *)
//
(* ****** ****** *)
//
extern
fun
{r:t0p}
{a:t0p}
arrayptr_foldright
  {n:nat}
(
A: !arrayptr(a, n), asz: int(n), fopr: &(a, r) -<clo1> r, r0: r
) : r // end of [arrayptr_foldright]
//
implement
{r}{a}
arrayptr_foldright
  {n}(A, asz, fopr, r0) =
loop(A, asz, fopr, r0) where
{
fun
loop
{i:nat | i <= n}
(
A: !arrayptr(a, n), i: int(i), fopr: &(a, r) -<clo1> r, r0: r
) : r =
  if i > 0 then loop(A, i-1, fopr, fopr(A[i-1], r0)) else r0
} (* end of [arrayptr_foldright] *)
//
(* ****** ****** *)
//
extern
fun
{a:t0p}
matrixptr_foreach_clo
  {m,n:nat}
(
M: !matrixptr(a, m, n)
, nrow: int(m), ncol: int(n), fwork: &(a) -<clo1> void
) : void // end of [matrixptr_foreach_clo]
//
implement
{a}(*tmp*)
matrixptr_foreach_clo
  {m,n}(M, nrow, ncol, fwork) =
loop1(M, 0, fwork) where
{
//
fun
loop2
{i:nat | i < m}{j:nat | j <= n}
(
M: !matrixptr(a, m, n), i: int(i), j: int(j), fwork: &(a) -<clo1> void
) : void =
  if j < ncol then (fwork(M[i, ncol, j]); loop2(M, i, j+1, fwork)) else ()
//
fun
loop1
{i:nat | i <= m}
(
M: !matrixptr(a, m, n), i: int(i), fwork: &(a) -<clo1> void
) : void =
  if i < nrow then (loop2(M, i, 0, fwork); loop1(M, i+1, fwork)) else ()
//
} (* end of [matrixptr_foreach_clo] *)
//
(* ****** ****** *)

(* end of [arrayfun.hats] *)
