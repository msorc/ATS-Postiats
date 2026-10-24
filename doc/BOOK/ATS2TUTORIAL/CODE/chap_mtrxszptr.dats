(*
** For ATS2TUTORIAL
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)
//
// HX-2026-10: no GC
// a matrix-with-size is a linear (boxed) record that must be freed
//
datavtype
mtrxszptr(a:vt0p) =
  | {m,n:nat} MTRXSZPTR of (matrixptr(a, m, n), size_t(m), size_t(n))
//
(* ****** ****** *)

fun{a:t0p}
mtrxszptr_make_elt
  (m: size_t, n: size_t, x0: a): mtrxszptr(a) = let
//
val m = g1ofg0(m) and n = g1ofg0(n)
val () = assertloc(m >= 0 && n >= 0)
//
in
  MTRXSZPTR(matrixptr_make_elt<a>(m, n, x0), m, n)
end // end of [mtrxszptr_make_elt]

(* ****** ****** *)

fun
mtrxszptr_free
  {a:t0p}
  (M: mtrxszptr(a)): void = let
  val ~MTRXSZPTR(M0, m, n) = M
in
  matrixptr_free(M0)
end // end of [mtrxszptr_free]

(* ****** ****** *)

fun{a:vt0p}
mtrxszptr_get_nrow
  (M: !mtrxszptr(a)): size_t = let
  val+ @MTRXSZPTR(_, m, _) = M
  val m = m
  prval () = fold@(M)
in
  m
end // end of [mtrxszptr_get_nrow]

fun{a:vt0p}
mtrxszptr_get_ncol
  (M: !mtrxszptr(a)): size_t = let
  val+ @MTRXSZPTR(_, _, n) = M
  val n = n
  prval () = fold@(M)
in
  n
end // end of [mtrxszptr_get_ncol]

(* ****** ****** *)

fun{a:t0p}
mtrxszptr_get_at
  (M: !mtrxszptr(a), i: size_t, j: size_t): (a) = let
//
val+ @MTRXSZPTR(M0, m, n) = M
val i = g1ofg0(i) and j = g1ofg0(j)
//
in
//
if i < m
  then (
    if j < n
      then let
        val x = matrixptr_get_at(M0, i, n, j)
        prval () = fold@(M)
      in
        x
      end // end of [then]
      else let
        prval () = fold@(M)
      in
        $raise MatrixSubscriptExn()
      end // end of [else]
  ) (* end of [then] *)
  else let
    prval () = fold@(M)
  in
    $raise MatrixSubscriptExn()
  end // end of [else]
//
end // end of [mtrxszptr_get_at]

fun{a:t0p}
mtrxszptr_set_at
  (M: !mtrxszptr(a), i: size_t, j: size_t, x: a): void = let
//
val+ @MTRXSZPTR(M0, m, n) = M
val i = g1ofg0(i) and j = g1ofg0(j)
//
in
//
if i < m
  then (
    if j < n
      then let
        val () = matrixptr_set_at(M0, i, n, j, x)
        prval () = fold@(M)
      in
        // nothing
      end // end of [then]
      else let
        prval () = fold@(M)
      in
        $raise MatrixSubscriptExn()
      end // end of [else]
  ) (* end of [then] *)
  else let
    prval () = fold@(M)
  in
    $raise MatrixSubscriptExn()
  end // end of [else]
//
end // end of [mtrxszptr_set_at]

(* ****** ****** *)
//
extern
fun{a:t0p}
mtrxszptr_transpose
  (M: !mtrxszptr(a)): void
//
implement
{a}(*tmp*)
mtrxszptr_transpose
  (M) = let
//
val n = mtrxszptr_get_nrow<a>(M)
//
val () = assertloc(n = mtrxszptr_get_ncol<a>(M))
//
fun loop
(
 M: !mtrxszptr(a), n: size_t, i: size_t, j: size_t
) : void =
(
if
(j < n)
then let
  val x = mtrxszptr_get_at<a>(M, i, j)
  val y = mtrxszptr_get_at<a>(M, j, i)
  val () = mtrxszptr_set_at<a>(M, i, j, y)
  val () = mtrxszptr_set_at<a>(M, j, i, x)
in
  loop(M, n, i, succ(j))
end // end of [then]
else let
  val i1 = succ(i)
in
  if i1 < n then loop(M, n, i1, succ(i1)) else ()
end // end of [else]
//
) (* end of [loop] *)
//
in
  if (n > 0) then loop(M, n, i2sz(0), i2sz(1)) else ()
end // end of [mtrxszptr_transpose]

(* ****** ****** *)

implement
main0 () = {
//
val M = mtrxszptr_make_elt<int>(i2sz(3), i2sz(3), 0)
//
val () = mtrxszptr_set_at<int>(M, i2sz(0), i2sz(1), 1)
val () = mtrxszptr_set_at<int>(M, i2sz(0), i2sz(2), 2)
val () = mtrxszptr_set_at<int>(M, i2sz(1), i2sz(2), 3)
val () = mtrxszptr_transpose<int>(M)
//
val () = println! ("M[1,0] = ", mtrxszptr_get_at<int>(M, i2sz(1), i2sz(0)))
val () = println! ("M[2,1] = ", mtrxszptr_get_at<int>(M, i2sz(2), i2sz(1)))
//
val x =
try
  mtrxszptr_get_at<int>(M, i2sz(3), i2sz(0))
with
  ~MatrixSubscriptExn() => ~1 // out-of-bounds subscripting is detected
//
val () = println! ("M[3,0] = ", x)
//
val () = mtrxszptr_free(M)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [chap_mtrxszptr.dats] *)
