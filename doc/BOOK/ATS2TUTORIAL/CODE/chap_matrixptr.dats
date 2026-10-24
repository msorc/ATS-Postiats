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
// matrices are linear ([matrixptr]) and must be freed
//
(* ****** ****** *)
//
extern
fun{a:t0p}
matrixptr_transpose
  {n:nat}
(
  M: !matrixptr(a, n, n), n: size_t(n)
) : void // end of [matrixptr_transpose]
//
implement
{a}(*tmp*)
matrixptr_transpose
  {n}(M, n) = let
//
fun
loop
{i,j:nat |
 i < j; j <= n
} .<n-i,n-j>.
(
 M: !matrixptr(a, n, n), i: size_t(i), j: size_t(j)
) : void = (
//
if
(j < n)
then let
  val x = matrixptr_get_at(M, i, n, j)
  val y = matrixptr_get_at(M, j, n, i)
  val () = matrixptr_set_at(M, i, n, j, y)
  val () = matrixptr_set_at(M, j, n, i, x)
in
  loop (M, i, succ(j))
end // end of [then]
else let
  val i1 = succ (i)
in
//
if i1 < n then loop(M, i1, succ(i1)) else ()
//
end // end of [else]
//
) (* end of [loop] *)
//
in
  if (n > 0) then loop(M, i2sz(0), i2sz(1)) else ()
end // end of [matrixptr_transpose]

(* ****** ****** *)

implement
main0 () = {
//
val n = i2sz(3)
val M = matrixptr_make_elt<int>(n, n, 0)
//
val () = matrixptr_set_at(M, i2sz(0), n, i2sz(1), 1)
val () = matrixptr_set_at(M, i2sz(0), n, i2sz(2), 2)
val () = matrixptr_set_at(M, i2sz(1), n, i2sz(2), 3)
//
val () = fprint_matrixptr<int>(stdout_ref, M, n, n)
val () = print_newline()
//
val () = matrixptr_transpose<int>(M, n)
//
val () = fprint_matrixptr<int>(stdout_ref, M, n, n)
val () = print_newline()
//
val () = matrixptr_free(M)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [chap_matrixptr.dats] *)
