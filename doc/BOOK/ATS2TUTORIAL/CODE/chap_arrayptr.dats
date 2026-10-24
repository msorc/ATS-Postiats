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
// arrays are linear ([arrayptr]) and must be freed
//
(* ****** ****** *)

fun{a:t0p}
arrayptr_reverse{n:nat}
(
  A: !arrayptr(a, n), n: size_t(n)
) : void = let
//
fun loop
  {i: nat | i <= n} .<n-i>.
(
  A: !arrayptr(a, n), n: size_t n, i: size_t i
) : void = let
  val n2 = half (n)
in
  if i < n2 then let
    val tmp = A[i]
    val ni = pred(n)-i
    val x = A[ni]
    val () = A[i] := x
    val () = A[ni] := tmp
  in
    loop(A, n, succ(i))
  end else () // end of [if]
end // end of [loop]
//
in
  loop(A, n, i2sz(0))
end // end of [arrayptr_reverse]

(* ****** ****** *)

fun{a:vt0p}
arrayptr_reverse_lin{n:nat}
(
  A: !arrayptr(a, n), n: size_t(n)
) : void = let
//
fun loop
  {i: nat | i <= n} .<n-i>.
(
  A: !arrayptr(a, n), n: size_t n, i: size_t i
) : void = let
  val n2 = half (n)
in
  if i < n2 then let
    val () = arrayptr_interchange(A, i, pred(n)-i) in loop(A, n, succ(i))
  end else () // end of [if]
end // end of [loop]
//
in
  loop(A, n, i2sz(0))
end // end of [arrayptr_reverse_lin]

(* ****** ****** *)

fun{a,b:t0p}
arrayptr_foldleft{n:nat}
(
  f: (a, b) -> a, x: a, A: !arrayptr(b, n), n: size_t(n)
) : a = let
//
fun loop
  {i: nat | i <= n} .<n-i>.
(
  f: (a, b) -> a
, x: a, A: !arrayptr(b, n), n: size_t(n), i: size_t(i)
) : a =
(
if i < n
  then loop(f, f(x, A[i]), A, n, succ(i)) else x
) (* end of [loop] *)
//
in
  loop(f, x, A, n, i2sz(0))
end // end of [arrayptr_foldleft]

(* ****** ****** *)

implement
main0 () = {
//
val n = i2sz(10)
val A = arrayptr_make_elt<int>(n, 0)
//
fun
fill{n:nat}{i:nat | i <= n} .<n-i>.
  (A: !arrayptr(int, n), n: size_t(n), i: size_t(i)): void =
  if i < n then (A[i] := sz2i(i); fill(A, n, succ(i)))
//
val () = fill(A, n, i2sz(0))
val () = arrayptr_reverse(A, n)
val () = (fprint_arrayptr<int>(stdout_ref, A, n); print_newline())
val () = arrayptr_reverse_lin(A, n)
val () = (fprint_arrayptr<int>(stdout_ref, A, n); print_newline())
val sum = arrayptr_foldleft<int,int>(lam (x, y) => x + y, 0, A, n)
val () = println! ("sum(A) = ", sum)
val () = arrayptr_free(A)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [chap_arrayptr.dats] *)
