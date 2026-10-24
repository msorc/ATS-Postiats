(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)
//
#include "./intfun.hats"
//
(* ****** ****** *)
//
// The three kinds of function values:
// an envless function, a stack-allocated closure
// and a closure on heap (which is linear: it has to be freed)
//
val
square = lam(x: int): int => x * x
//
val fact =
fix f(x: int): int => if x > 0 then x * f(x-1) else 1
//
val () = println! ("square(7) = ", square(7))
val () = println! ("fact(5) = ", fact(5))
//
(* ****** ****** *)

fun
testfact(n: int): void = let
//
var fwork =
lam@(i: int): void => println!("fact(", i, ") = ", fact(i))
//
in
  int_foreach(n, fwork)
end // end of [testfact]

val () = testfact(5)

(* ****** ****** *)

fun
fact2(n: int): int = let
//
var fopr =
lam@(res: int, i: int): int => res * (i+1)
//
in
  int_foldleft<int>(n, 1, fopr)
end // end of [fact2]

val () = println! ("fact2(10) = ", fact2(10))

(* ****** ****** *)

fun
sq(i: int): int = i*i
fun
sqsum(n: int): int = let
//
var fopr =
lam@(res: int, i: int): int => res + sq(i+1)
//
in
  int_foldleft<int>(n, 0, fopr)
end // end of [sqsum]

val () = println! ("sqsum(10) = ", sqsum(10))

(* ****** ****** *)

//
// matrices are given by the addresses of their cells (in row-major order)
//
fun
{a:t@ype}
get_at(M: ptr, n: int, i: int, j: int): a =
$UNSAFE.ptr0_get_at_int<a>(M, i * n + j)
fun
{a:t@ype}
set_at(M: ptr, n: int, i: int, j: int, x: a): void =
$UNSAFE.ptr0_set_at_int<a>(M, i * n + j, x)
//
fun
{a:t@ype}
matrix_mulby
( p:int, q:int, r:int
, A:ptr, B:ptr, C:ptr
) : void = let
//
val add = gadd_val_val<a>
val mul = gmul_val_val<a>
//
var fwork =
lam@(i: int, j: int): void =>
{
  var fopr =
  lam@(res: a, k: int): a => add(res, mul(get_at<a>(A, q, i, k), get_at<a>(B, r, k, j)))
  val () = set_at<a>(C, r, i, j, int_foldleft<a>(q, get_at<a>(C, r, i, j), fopr))
}
//
in
  int_cross_foreach(p, r, fwork)
end // end of [matrix_mulby]

val () = let
  var A = @[int](1, 2, 3, 4, 5, 6) // 2 by 3
  var B = @[int](1, 0, 0, 1, 1, 1) // 3 by 2
  var C = @[int](0, 0, 0, 0)       // 2 by 2
  val () = matrix_mulby<int>(2, 3, 2, addr@A, addr@B, addr@C)
in
  println! ("C = ", C.[0], " ", C.[1], " ", C.[2], " ", C.[3])
end // end of [val]

(* ****** ****** *)
(* ****** ****** *)
//
fun fact3(n: int): int = let
  var fopr = lam@(res: int, i: int): int => res*(i+1)
in
  (n).foldleft(1, fopr)
end // end of [fact3]
//
fun testfact3(n: int): void = let
  var fwork =
    lam@(i: int): void => println! ("fact(", i+1, ") = ", fact3(i+1))
in
  (n).foreach(fwork)
end // end of [testfact3]
//
val () = testfact3(5)
//
(* ****** ****** *)
//
// A linear closure on heap: it is created by [lam] with the arrow
// [=<cloptr1>]; it has to be freed by the creator after the last use.
//
val
y = 10
val
add_y = lam (x: int): int =<cloptr1> x + y
val () = println! ("add_y(5) = ", add_y(5))
val () = cloptr_free($UNSAFE.castvwtp0{cloptr(void)}(add_y))
//
(* ****** ****** *)
//
implement main0() = ()
//
(* ****** ****** *)

(* end of [lecture04.dats] *)
