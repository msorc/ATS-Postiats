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
// the non-linear lazy streams ([$delay], [stream]) are removed;
// a linear stream ([$ldelay], [stream_vt]) takes their place
//
(* ****** ****** *)
//
fun
fibs
(
a: int, b: int
) : stream_vt(int) =
  $ldelay(stream_vt_cons(a, fibs(b, a+b)))
//
(* ****** ****** *)
//
implement
main0 () = {
//
// the first 10 Fibonacci numbers are
// put in a list, and the rest of the
// stream is freed by [takeLte]
//
val xs =
stream2list_vt(stream_vt_takeLte(fibs(0, 1), 10))
val ((*void*)) = println! ("xs = ", xs)
val ((*void*)) = list_vt_free(xs)
//
// a stream that is not needed any more must be freed
//
val fs = fibs(0, 1)
val ((*void*)) = println! ("fibs(7) = ", (stream_vt_drop_exn(fs, 7)).head())
//
// an unforced stream is freed with [~]
//
val fs2 = fibs(0, 1)
val ((*void*)) = ~fs2
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [chap_stream.dats] *)
