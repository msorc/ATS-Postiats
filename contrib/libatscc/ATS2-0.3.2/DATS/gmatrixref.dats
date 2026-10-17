(*
** libatscc-common
*)

(* ****** ****** *)

(*
//
staload "./../SATS/matrixref.sats"
//
staload UN = "prelude/SATS/unsafe.sats"
//
*)

(* ****** ****** *)
//
//
// HX-2026-10: no GC
// A gmatrixref is represented as an array of 7 slots:
// [M, m0, n0, i0, j0, m, n]; boxed tuples are not available
// (as they could never be freed in C).
//
typedef gmrep = arrayref(ptr, 7)
//
assume gmatrixref(a, m, n) = gmrep
//
(* ****** ****** *)
//
extern
fun
gmrep_make
(
  M: ptr
, m0: int, n0: int, i0: int, j0: int, m: int, n: int
) : gmrep // end-of-function
//
implement
gmrep_make
(
  M, m0, n0, i0, j0, m, n
) = A where
{
  val A =
  arrayref_make_elt{ptr}(7, the_null_ptr)
  val () = A[0] := M
  val () = A[1] := $UN.cast{ptr}(m0)
  val () = A[2] := $UN.cast{ptr}(n0)
  val () = A[3] := $UN.cast{ptr}(i0)
  val () = A[4] := $UN.cast{ptr}(j0)
  val () = A[5] := $UN.cast{ptr}(m)
  val () = A[6] := $UN.cast{ptr}(n)
} (* end of [gmrep_make] *)
//
macdef
GMint(GM, k) = $UN.cast{int}(arrayref_get_at(,(GM), ,(k)))
//
(* ****** ****** *)
//
implement
gmatrixref_make_matrixref
  (M, m, n) =
  gmrep_make($UN.cast{ptr}(M), m, n, 0, 0, m, n)
//
(* ****** ****** *)
//
implement
gmatrixref_make_subregion
  (GM, i0, j0, m, n) =
(
  gmrep_make
  ( arrayref_get_at(GM, 0)
  , GMint(GM, 1), GMint(GM, 2)
  , GMint(GM, 3)+i0, GMint(GM, 4)+j0, m, n)
)
//
(* ****** ****** *)
//
implement
gmatrixref_get_at
  {a}{m,n}(GM, i, j) = let
  val M =
  $UN.cast{matrixref(a, 1, 1)}(arrayref_get_at(GM, 0))
in
  matrixref_get_at
  ( M
  , $UN.cast{natLt(1)}(GMint(GM, 3)+i)
  , $UN.cast{int(1)}(GMint(GM, 2))
  , $UN.cast{natLt(1)}(GMint(GM, 4)+j))
end // end of [gmatrixref_get_at]
//
implement
gmatrixref_set_at
  {a}{m,n}(GM, i, j, x) = let
  val M =
  $UN.cast{matrixref(a, 1, 1)}(arrayref_get_at(GM, 0))
in
  matrixref_set_at
  ( M
  , $UN.cast{natLt(1)}(GMint(GM, 3)+i)
  , $UN.cast{int(1)}(GMint(GM, 2))
  , $UN.cast{natLt(1)}(GMint(GM, 4)+j), x)
end // end of [gmatrixref_set_at]
//
(* ****** ****** *)
//
implement
gmatrixref_exists_cloptr
  (GM, f) =
(
  int2_exists_cloptr(GMint(GM, 5), GMint(GM, 6), $UN.castvwtp0{cfun2(int,int,bool)}(f))
)
implement
gmatrixref_forall_cloptr
  (GM, f) =
(
  int2_forall_cloptr(GMint(GM, 5), GMint(GM, 6), $UN.castvwtp0{cfun2(int,int,bool)}(f))
)
//
(* ****** ****** *)
//
implement
gmatrixref_foreach_cloptr
  (GM, f) =
(
  int2_foreach_cloptr(GMint(GM, 5), GMint(GM, 6), $UN.castvwtp0{cfun2(int,int,void)}(f))
)
//
(* ****** ****** *)

(* end of [matrixref.dats] *)
