(* ****** ****** *)
//
// For testing libatscc2php
//
(* ****** ****** *)
//
#define
ATS_MAINATSFLAG 1
#define
ATS_STATIC_PREFIX "_test04_"
#define
ATS_DYNLOADNAME "test04_dynload"
//
(* ****** ****** *)
//
#include "./../staloadall.hats"
//
(* ****** ****** *)

%{$
test04_dynload();
%} (* end of [%{$] *)

(* ****** ****** *)
//
//
// HX-2026-10: no GC (linear closures)
//
val A0 =
arrayref_make_elt{int}(10, 0)
val () =
arrayref_foreach_cloptr
(A0, 10, lam(i) =<cloptr1> A0[i] := i*i)
val () =
arrayref_foreach_cloptr
(A0, 10, lam(i) =<cloptr1> println!("A0[",i,"]=",A0[i]))
//
(* ****** ****** *)
//
val A1 =
arrszref_make_elt{int}(10, 0)
val () =
arrszref_foreach_cloptr
(A1, lam(i) =<cloptr1> A1[i] := i*i)
val () =
arrszref_foreach_cloptr
(A1, lam(i) =<cloptr1> println!("A1[",i,"]=",A1[i]))
//
(* ****** ****** *)
//
val M0 =
matrixref_make_elt{int}(2, 5, 0)
val () =
matrixref_foreach_cloptr
(M0, 2, 5, lam(i, j) =<cloptr1> M0[i,5,j] := i*j)
val () =
matrixref_foreach_cloptr
( M0, 2, 5
, lam(i, j) =<cloptr1>
  println!("M0[", i, ",", j, "]=", M0[i,5,j]))
//
(* ****** ****** *)
//
val M1 =
mtrxszref_make_elt{int}(2, 5, 0)
val () =
mtrxszref_foreach_cloptr
(M1, lam(i, j) =<cloptr1> M1[i,j] := i*j)
val () =
mtrxszref_foreach_cloptr
(M1, lam(i, j) =<cloptr1> println!("M1[", i, ",", j, "]=", M1[i,j]))
//
(* ****** ****** *)

%{^
include "./../output/libatscc2php_all.php";
%} (* end of [%{^] *)

(* ****** ****** *)

(* end of [test04.dats] *)
