(* ****** ****** *)
(*
** The stream functions of LECTURE/11 (the library of the book).
** See LECTURE/10 for the beginning of the library.
*)
(* ****** ****** *)
//
extern
fun
{a:t@ype}
stream_takeLte
  (xs: stream_vt(a), n: int): stream_vt(a)
//
implement
{a}(*tmp*)
stream_takeLte
  (xs, n) = $ldelay
(
(
if
n > 0
then
(
case+ !xs of
| ~stream_vt_nil() =>
   stream_vt_nil()
| ~stream_vt_cons(x, xs) =>
   stream_vt_cons(x, stream_takeLte(xs, n-1))
)
else (~xs; stream_vt_nil((*void*)))
) : stream_vt_con(a)
,
~(xs) // called when the stream is freed
) (* end of [stream_takeLte] *)
//
(* ****** ****** *)
//
extern
fun
{res:t@ype}
{a:t@ype}
stream_foldleft
(
xs: stream_vt(a),
r0: res, fopr: &(res, a) -<clo1> res
) : res // end-of-function
//
implement
{res}{a}
stream_foldleft(xs, r0, fopr) =
(
//
case+ !xs of
| ~stream_vt_nil() => r0
| ~stream_vt_cons(x, xs) =>
   stream_foldleft<res><a>(xs, fopr(r0, x), fopr)
//
) (* end of [stream_foldleft] *)
//
(* ****** ****** *)

(* end of [streamfun2.hats] *)
