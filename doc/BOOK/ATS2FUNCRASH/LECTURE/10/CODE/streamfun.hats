(* ****** ****** *)
(*
** The stream functions of LECTURE/10 (the library of the book).
** A stream is a linear stream, stream_vt(a): it can be used only once,
** and a stream that is not needed any more has to be freed.
** A function argument that is stored in a stream is a linear
** closure (the arrow [-<cloptr1>]), which belongs to the stream.
*)
(* ****** ****** *)
//
// a linear closure is freed by this function
//
fun
{a,b:t@ype}
cfun_free
(f: (a) -<cloptr1> b): void =
cloptr_free($UNSAFE.castvwtp0{cloptr(void)}(f))
//
(* ****** ****** *)
//
extern
fun
int_stream_from(n: int): stream_vt(int)
//
implement
int_stream_from(n) =
$ldelay(stream_vt_cons(n, int_stream_from(n+1)))
//
(* ****** ****** *)
//
extern
fun
{a:t@ype}
stream_get_at
(xs: stream_vt(a), n: int): a
//
implement
{a}(*tmp*)
stream_get_at(xs, n) =
(
case+ !xs of
| ~stream_vt_nil() =>
  (
    $raise StreamSubscriptExn()
  )
| ~stream_vt_cons(x, xs) =>
  (
    if n <= 0 then (~xs; x) else stream_get_at<a>(xs, n-1)
  )
)
//
(* ****** ****** *)
//
extern
fun
{a:t@ype}
stream_append
(xs: stream_vt(a), ys: stream_vt(a)): stream_vt(a)
//
implement
{a}(*tmp*)
stream_append
(xs, ys) = $ldelay
(
(
case+ !xs of
| ~stream_vt_nil() => !ys
| ~stream_vt_cons(x, xs) =>
  stream_vt_cons(x, stream_append<a>(xs, ys))
) : stream_vt_con(a)
,
(~xs; ~ys) // called when the stream is freed
)
//
(* ****** ****** *)
//
extern
fun
{a:t@ype}
stream_make_list(xs: List0_vt(a)): stream_vt(a)
//
implement
{a}(*tmp*)
stream_make_list
  (xs) = $ldelay
(
(
case+ xs of
| ~list_vt_nil() =>
  stream_vt_nil()
| ~list_vt_cons(x, xs) =>
  stream_vt_cons(x, stream_make_list<a>(xs))
) : stream_vt_con(a)
,
list_vt_free<a>(xs)
) (* end of [stream_make_list] *)
//
(* ****** ****** *)
//
extern
fun
{a:t@ype}
{b:t@ype}
stream_map
(xs: stream_vt(a), fopr: (a) -<cloptr1> b): stream_vt(b)
//
implement
{a}{b}
stream_map
  (xs, fopr) = $ldelay
(
(
case+ !xs of
| ~stream_vt_nil() =>
  (cfun_free<a,b>(fopr); stream_vt_nil())
| ~stream_vt_cons(x, xs) =>
  stream_vt_cons(fopr(x), stream_map<a><b>(xs, fopr))
) : stream_vt_con(b)
,
(~xs; cfun_free<a,b>(fopr))
)
//
(* ****** ****** *)
//
extern
fun
{a:t@ype}
stream_filter
(xs: stream_vt(a), test: (a) -<cloptr1> bool): stream_vt(a)
//
implement
{a}(*tmp*)
stream_filter
  (xs, test) = $ldelay
(
(
case+ !xs of
| ~stream_vt_nil() =>
  (cfun_free<a,bool>(test); stream_vt_nil())
| ~stream_vt_cons(x, xs) =>
  if test(x)
    then
    stream_vt_cons
      (x, stream_filter<a>(xs, test))
    // end of [then]
    else !(stream_filter<a>(xs, test))
  // end of [if]
) : stream_vt_con(a)
,
(~xs; cfun_free<a,bool>(test))
)
//
(* ****** ****** *)
//
extern
fun
sieve(): stream_vt(int)
//
implement
sieve() = let
//
fun
auxmain
(
xs: stream_vt(int)
) : stream_vt(int) = $ldelay
(
(
case+ !xs of
| ~stream_vt_nil() => stream_vt_nil()
| ~stream_vt_cons(x0, xs) =>
  stream_vt_cons
  ( x0
  , auxmain(stream_filter<int>(xs, lam(x) =<cloptr1> x % x0 > 0))
  ) // end of [stream_vt_cons]
) : stream_vt_con(int)
,
~xs
)
//
in
  auxmain(int_stream_from(2))
end // end of [sieve]
//
(* ****** ****** *)

(* end of [streamfun.hats] *)
