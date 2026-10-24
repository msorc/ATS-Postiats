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
// an array-with-size is a linear (boxed) pair that must be freed
//
datavtype
arrszptr(a:vt0p) =
  | {n:nat} ARRSZPTR of (arrayptr(a, n), size_t(n))
//
(* ****** ****** *)

fun{a:vt0p}
arrszptr_make_arrpsz
  {n:nat}
  (psz: arrpsz(a, n)): arrszptr(a) = let
//
var n: size_t
val A0 = arrpsz_get_ptrsize(psz, n)
//
in
  ARRSZPTR(A0, n)
end // end of [arrszptr_make_arrpsz]

(* ****** ****** *)

fun
arrszptr_free
  {a:t0p}
  (A: arrszptr(a)): void = let
  val ~ARRSZPTR(A0, n) = A
in
  arrayptr_free(A0)
end // end of [arrszptr_free]

(* ****** ****** *)

fun{a:vt0p}
arrszptr_get_size
  (A: !arrszptr(a)): size_t = let
  val+ @ARRSZPTR(A0, n) = A
  val n = n
  prval () = fold@(A)
in
  n
end // end of [arrszptr_get_size]

(* ****** ****** *)

fun{a:t0p}
arrszptr_get_at
  (A: !arrszptr(a), i: size_t): (a) = let
//
val+ @ARRSZPTR(A0, n) = A
val i = g1ofg0(i)
//
in
//
if i < n
  then let
    val x = A0[i]
    prval () = fold@(A)
  in
    x
  end // end of [then]
  else let
    prval () = fold@(A)
  in
    $raise ArraySubscriptExn()
  end // end of [else]
//
end // end of [arrszptr_get_at]

fun{a:t0p}
arrszptr_set_at
  (A: !arrszptr(a), i: size_t, x: a): void = let
//
val+ @ARRSZPTR(A0, n) = A
val i = g1ofg0(i)
//
in
//
if i < n
  then let
    val () = A0[i] := x
    prval () = fold@(A)
  in
    // nothing
  end // end of [then]
  else let
    prval () = fold@(A)
  in
    $raise ArraySubscriptExn()
  end // end of [else]
//
end // end of [arrszptr_set_at]

(* ****** ****** *)

fun{a:vt0p}
arrszptr_reverse
  (A: !arrszptr(a)): void = let
//
val+ @ARRSZPTR(A0, n) = A
//
fun loop
  {n:nat}{i:nat | i <= n} .<n-i>.
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
val () = loop(A0, n, i2sz(0))
//
in
  fold@(A)
end // end of [arrszptr_reverse]

(* ****** ****** *)

implement
main0 () = {
//
val DIGITS =
  arrszptr_make_arrpsz($arrpsz{int}(0, 1, 2, 3, 4, 5, 6, 7, 8, 9))
//
val () = println! ("size(DIGITS) = ", arrszptr_get_size(DIGITS))
val () = println! ("DIGITS[3] = ", arrszptr_get_at<int>(DIGITS, i2sz(3)))
val () = arrszptr_set_at<int>(DIGITS, i2sz(3), 33)
val () = arrszptr_reverse(DIGITS)
val () = println! ("DIGITS[6] = ", arrszptr_get_at<int>(DIGITS, i2sz(6)))
//
val x =
try
  arrszptr_get_at<int>(DIGITS, i2sz(10))
with
  ~ArraySubscriptExn() => ~1 // out-of-bounds subscripting is detected
//
val () = println! ("DIGITS[10] = ", x)
//
val () = arrszptr_free(DIGITS)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [chap_arrszptr.dats] *)
