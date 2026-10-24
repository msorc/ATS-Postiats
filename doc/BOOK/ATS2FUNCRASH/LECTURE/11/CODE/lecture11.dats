(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
staload UN = "prelude/SATS/unsafe.sats"
//
(* ****** ****** *)
//
#include "./../../05/CODE/listfun.hats"
#include "./../../10/CODE/streamfun.hats"
#include "./streamfun2.hats"
//
(* ****** ****** *)
//
// [f] is an envless function: it is captured by the closure
// that is stored in a stream
//
fun
ftally
(
n : int
,
f : (int) -> double
) : double =
  if n = 0 then 0.0 else ftally(n-1, f) + f(n)
//
(* ****** ****** *)
//
fun
ftally2
(
n : int
,
f : (int) -> double
) : double = let
//
val xs1 = int_stream_from(1)
val xs2 = stream_takeLte<int>(xs1, n)
val xs3 = stream_map<int><double>(xs2, lam(i) =<cloptr1> f(i))
//
var fopr = lam@(res: double, x: double): double => res + x
//
in
  stream_foldleft<double><double>(xs3, 0.0, fopr)
end // end of [ftally2]
//
(* ****** ****** *)
//
fun
inv_square(i: int): double = 1.0 / g0int2float_int_double(i * i)
//
val () = println! ("ftally(1000, inv_square) = ", ftally(1000, inv_square))
val () = println! ("ftally2(1000, inv_square) = ", ftally2(1000, inv_square))
//
(* ****** ****** *)
//
// [stream_takeLte] frees the rest of the stream, which is never evaluated
//
val xs = stream_takeLte<int>(int_stream_from(0), 5)
val ys = stream2list_vt<int>(xs)
val () = println! ("the first 5 integers: ", ys)
val () = list_vt_free<int>(ys)
//
(* ****** ****** *)

implement main0() = ()

(* ****** ****** *)

(* end of [lecture11.dats] *)
