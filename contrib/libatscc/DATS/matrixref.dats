(* ****** ****** *)
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
implement
matrixref_exists_cloptr
  (M, m, n, pred) =
(
int2_exists_cloptr
  (m, n, $UN.castvwtp0{cfun2(int,int,bool)}(pred))
// int2_exists_cloptr
) (* matrixref_exists_cloptr *)
//
(* ****** ****** *)
//
implement
matrixref_forall_cloptr
  (M, m, n, pred) =
(
int2_forall_cloptr
  (m, n, $UN.castvwtp0{cfun2(int,int,bool)}(pred))
// int2_forall_cloptr
) (* matrixref_forall_cloptr *)
//
(* ****** ****** *)
//
implement
matrixref_foreach_cloptr
  (M, m, n, fwork) =
(
int2_foreach_cloptr
  (m, n, $UN.castvwtp0{cfun2(int,int,void)}(fwork))
// int2_foreach_cloptr
) (* matrixref_foreach_cloptr *)
//
(* ****** ****** *)
//
implement
cbind_matrixref_matrixref
  (M1, M2, m0, n1, n2) = let
//
prval () = lemma_matrixref_param(M1)
prval () = lemma_matrixref_param(M2)
//
in
//
matrixref_tabulate_cloptr
( m0(*nrow*), n1+n2(*ncol*)
, lam(i, j) =<cloptr1>
  if j < n1 then M1[i,n1,j] else M2[i,n2,j-n1])
//
end (* end of [cbind_matrixref_matrixref] *)
//
(* ****** ****** *)
//
implement
rbind_matrixref_matrixref
  (M1, M2, m1, m2, n0) = let
//
prval () = lemma_matrixref_param(M1)
prval () = lemma_matrixref_param(M2)
//
in
//
matrixref_tabulate_cloptr
( m1+m2(*nrow*), n0(*ncol*)
, lam(i, j) =<cloptr1>
  if i < m1 then M1[i,n0,j] else M2[i-m1,n0,j])
//
end (* end of [cbind_matrixref_matrixref] *)
//
(* ****** ****** *)
//
// HX: matrix-with-size
//
(* ****** ****** *)
//
implement
mtrxszref_make_elt
{a}(m, n, x0) =
(
mtrxszref_make_matrixref
  (matrixref_make_elt{a}(m, n, x0), m, n)
// mtrxszref_make_matrixref
) (* end of [mtrxszref_make_elt] *)
//
(* ****** ****** *)
//
implement
mtrxszref_exists_cloptr
  (MSZ, ftest) = let
  val m = MSZ.nrow()
  val n = MSZ.ncol()
in
//
int2_exists_cloptr
  (m, n, $UN.castvwtp0{cfun2(int,int,bool)}(ftest))
//
end // end of [mtrxszref_exists_cloptr]
//
(* ****** ****** *)
//
implement
mtrxszref_forall_cloptr
  (MSZ, ftest) = let
  val m = MSZ.nrow()
  val n = MSZ.ncol()
in
//
int2_forall_cloptr
  (m, n, $UN.castvwtp0{cfun2(int,int,bool)}(ftest))
//
end // end of [mtrxszref_forall_cloptr]
//
(* ****** ****** *)
//
(* ****** ****** *)
//
implement
mtrxszref_foreach_cloptr
  (MSZ, fwork) = let
  val m = MSZ.nrow()
  val n = MSZ.ncol()
in
//
int2_foreach_cloptr
(m, n, $UN.castvwtp0{cfun2(int,int,void)}(fwork))
//
end // end of [mtrxszref_foreach_cloptr]
//
//
(* ****** ****** *)
//
implement
mtrxszref_foreach_row_cloptr
  (MSZ, fwork) = let
  val m = MSZ.nrow()
  val n = MSZ.ncol()
in
//
int2_foreach_cloptr
(m, n, $UN.castvwtp0{cfun2(int,int,void)}(fwork))
//
end // end of [mtrxszref_foreach_row_cloptr]
//
//
(* ****** ****** *)
//
implement
mtrxszref_foreach_col_cloptr
  (MSZ, fwork) = let
//
val m = MSZ.nrow()
val n = MSZ.ncol()
//
fun
loop1
(
  j: int, fwork: !(Nat, Nat) -<cloptr1> void
) : void =
  if j < n then (loop2(j, 0, fwork); loop1(j+1, fwork))
//
and
loop2
(
  j: int, i: int, fwork: !(Nat, Nat) -<cloptr1> void
) : void =
  if i < m then
  (
    fwork($UN.cast{Nat}(i), $UN.cast{Nat}(j)); loop2(j, i+1, fwork)
  ) (* end of [if] *)
//
val () = loop1(0, fwork)
//
in
  cfun_free(fwork)
end // end of [mtrxszref_foreach_col_cloptr]
//
//
(* ****** ****** *)
//
implement
mtrxszref_tabulate_cloptr
{a}{m,n}(m, n, fopr) = let
//
val fopr =
$UN.castvwtp0{(natLt(m), natLt(n)) -<cloptr1> a?}(fopr)
in
$UN.cast
(
mtrxszref_make_matrixref
  (matrixref_tabulate_cloptr{a?}(m, n, fopr), m, n)
)
end (* end of [mtrxszref_tabulate] *)
//
(* ****** ****** *)

(* end of [matrixref.dats] *)
