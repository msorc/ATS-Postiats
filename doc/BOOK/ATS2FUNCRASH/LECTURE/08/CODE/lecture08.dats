(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)
//
#include "./arrayfun.hats"
//
(* ****** ****** *)
//
// A reference can only be made from memory that is never freed:
// a toplevel variable here
//
var r0_var: int = 0
val r0 = ref_make_viewptr{int}(view@ r0_var | addr@ r0_var)
//
val () = println! (!r0)
val () = (!r0 := !r0 + 1)
val () = println! (!r0)
val () = (!r0 := !r0 + 2)
val () = println! (!r0)
//
var r1_var: int = 0
val r1 = ref_make_viewptr{int}(view@ r1_var | addr@ r1_var)
//
val () = println! (r1[])
val () = (r1[] := r1[] + 1)
val () = println! (r1[])
val () = (r1[] := r1[] + 2)
val () = println! (r1[])
//
(* ****** ****** *)
//
fun
fact_var
(n: int): int = let
//
var i: int = 0
var r: int = 1
//
fun
loop
(n: int, i: &int >> _, r: &int >> _): void =
  if i < n then (i := i + 1; r := r * i; loop(n, i, r))
//
val () = loop(n, i, r)
//
in
  r
end (* end of [fact_var] *)
//
val () = println! ("fact_var(10) = ", fact_var(10))
//
(* ****** ****** *)
//
val A =
arrayptr_make_elt<int>(i2sz(3), 0)
//
val () =
println! (A[0], A[1], A[2])
//
val () = A[0] := 1
val x0 = A[0]
val () = A[1] := x0 + 1
val x1 = A[1]
val () = A[2] := x1 + 1
//
val () =
println! (A[0], A[1], A[2])
//
(* ****** ****** *)
//
val () =
{
var fwork =
lam@(x: int): void => print!(x, ";")
val () = arrayptr_foreach<int>(A, 3, fwork)
val () = println! ()
}
//
val () =
{
var fopr = lam@(r: int, x: int): int => r * 10 + x
val () = println! ("foldleft = ", arrayptr_foldleft<int><int>(A, 3, 0, fopr))
}
//
val () =
{
var fopr = lam@(x: int, r: int): int => r * 10 + x
val () = println! ("foldright = ", arrayptr_foldright<int><int>(A, 3, fopr, 0))
}
//
val () = arrayptr_free(A)
//
(* ****** ****** *)
//
// The array is created by [arrayptr_tabulate], which calls
// [array_tabulate$fopr] to make the element of each index
//
implement
array_tabulate$fopr<int>(i) = sz2i(i) * sz2i(i)
//
val B = arrayptr_tabulate<int>(i2sz(5))
//
val () = (fprint_arrayptr<int>(stdout_ref, B, i2sz(5)); print_newline())
val () = arrayptr_free(B)
//
(* ****** ****** *)
//
val M = matrixptr_make_elt<int>(i2sz(2), i2sz(3), 0)
//
val () = M[0, 3, 1] := 5
val () = M[1, 3, 2] := 7
//
val () =
{
var fwork = lam@(x: int): void => print!(x, ";")
val () = matrixptr_foreach_clo<int>(M, 2, 3, fwork)
val () = println! ()
}
//
val () = matrixptr_free(M)
//
(* ****** ****** *)
//
implement
matrix_tabulate$fopr<int>(i, j) = sz2i(i) * 10 + sz2i(j)
//
val N = matrixptr_tabulate<int>(i2sz(2), i2sz(3))
//
val () = (fprint_matrixptr<int>(stdout_ref, N, i2sz(2), i2sz(3)); print_newline())
val () = matrixptr_free(N)
//
(* ****** ****** *)

implement main0() = ()

(* ****** ****** *)

(* end of [lecture08.dats] *)
