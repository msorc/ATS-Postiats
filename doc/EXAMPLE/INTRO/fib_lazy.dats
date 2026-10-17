//usr/bin/env myatscc "$0"; exit
(* ****** ****** *)
//
// Lazy-evaluation
//
(* ****** ****** *)
(*
//
// HX-2017-05-22:
// For remote typechecking only!
//
##myatsccdef=\
curl --data-urlencode mycode@$1 \
http://www.ats-lang.org/SERVER/MYCODE/atslangweb_patsopt_tcats_0_.php | \
php -R 'if (\$argn != \"\") echo(json_decode(urldecode(\$argn))[1].\"\\n\");'
//
*)
(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

//
// HX-2026-10: no GC
// the stream is linear: the part that is
// not needed is freed explicitly
//
fun
fibs
(
  x0: int, x1: int
) : stream_vt(int) =
  $ldelay(stream_vt_cons{int}(x0, fibs(x1, x0+x1)))
//
fun
stream_vt_nth
(
  xs: stream_vt(int), n: int
) : int =
(
case+ !xs of
| ~stream_vt_nil() => ~1 // HX: deadcode
| ~stream_vt_cons(x, xs) =>
    if n > 0 then stream_vt_nth(xs, n-1) else (~xs; x)
  // end of [stream_vt_cons]
) (* end of [stream_vt_nth] *)

(* ****** ****** *)

implement
main0 () =
{
//
val _55 = stream_vt_nth (fibs(0, 1), 10)
val- 55 = _55
val () =
println! ("Fibonacci(10) = ", _55)
//
val _6765 = stream_vt_nth (fibs(0, 1), 20)
val- 6765 = _6765
val () =
println! ("Fibonacci(20) = ",  _6765)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [fib_lazy.dats] *)
