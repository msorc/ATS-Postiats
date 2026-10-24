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
#include "./streamfun.hats"
//
(* ****** ****** *)
//
// A stream can be used only once: its first million elements are
// consumed (and freed one by one) by [stream_get_at]
//
val xs = int_stream_from(0)
val x0 = stream_get_at<int>(xs, 1000000)
val () = println! ("x0 = ", x0)
//
(* ****** ****** *)
//
val xs123 = stream_make_list<int>($list_vt{int}(1, 2, 3))
val ys456 = stream_make_list<int>($list_vt{int}(4, 5, 6))
val xs123456 = stream_append<int>(xs123, ys456)
val zs = stream2list_vt<int>(xs123456)
val () = println! ("append: ", zs)
val () = list_vt_free<int>(zs)
//
(* ****** ****** *)
//
// The second implementation of [stream_make_list]: it is not fully lazy
// as it inspects the list before it constructs the thunk
//
fun
{a:t@ype}
stream_make_list2
  (xs: List0_vt(a)): stream_vt(a) =
(
case+ xs of
| ~list_vt_nil() =>
  $ldelay(stream_vt_nil())
| ~list_vt_cons(x, xs) =>
  $ldelay
  ( stream_vt_cons(x, stream_make_list2<a>(xs))
  , list_vt_free<a>(xs) // called when the stream is freed
  )
) (* end of [stream_make_list2] *)
//
// The third implementation of [stream_make_list]: the stream is
// not lazy at all (the whole list is turned into nodes of the
// stream before the function returns)
//
fun
{a:t@ype}
stream_make_list3
  (xs: List0_vt(a)): stream_vt(a) =
(
case+ xs of
| ~list_vt_nil() =>
  $ldelay(stream_vt_nil())
| ~list_vt_cons(x, xs) => let
    val xs = stream_make_list3<a>(xs)
  in
    $ldelay(stream_vt_cons(x, xs), ~xs)
  end // end of [list_vt_cons]
) (* end of [stream_make_list3] *)
//
val zs2 = stream2list_vt<int>(stream_make_list2<int>($list_vt{int}(1, 2, 3)))
val zs3 = stream2list_vt<int>(stream_make_list3<int>($list_vt{int}(1, 2, 3)))
val () = println! ("make_list2: ", zs2)
val () = println! ("make_list3: ", zs3)
val () = list_vt_free<int>(zs2)
val () = list_vt_free<int>(zs3)
//
(* ****** ****** *)
//
val xs = int_stream_from(1)
val ys = stream_map<int><int>(xs, lam(x) =<cloptr1> x * x)
val zs = stream_filter<int>(ys, lam(x) =<cloptr1> x % 2 = 0)
val z10 = stream_get_at<int>(zs, 10)
val () = println! ("the 11th even square: ", z10)
//
(* ****** ****** *)
//
val thePrimes = sieve()
val () = println! ("stream_get_at(thePrimes, 5000):")
val () = println! (stream_get_at<int>(thePrimes, 5000))
//
(* ****** ****** *)
//
// A stream that is not consumed is freed by [~] (or by [lazy_vt_free])
//
val xs = int_stream_from(0)
val () = ~xs
//
(* ****** ****** *)
//
// The standard implementation of [list_map] is not tail-recursive
//
fun
{a,b:t@ype}
list_map_stream
(xs: List0_vt(a), fopr: (a) -> b): List0_vt(b) = let
//
fun
auxmain
(
xs: List0_vt(a), fopr: (a) -> b
) : stream_vt(b) = $ldelay
(
(
case+ xs of
| ~list_vt_nil() => stream_vt_nil()
| ~list_vt_cons(x, xs) => stream_vt_cons(fopr(x), auxmain(xs, fopr))
) : stream_vt_con(b)
,
list_vt_free<a>(xs)
)
//
in
  stream2list_vt<b>(auxmain(xs, fopr))
end // end of [list_map_stream]
//
val xs = list_make_intrange(0, 1000000)
val ys = list_map_stream<int,int>(xs, lam(x) => x + 1)
val () = println! ("length(ys) = ", list_vt_length<int>(ys))
val () = list_vt_free<int>(ys)
//
(* ****** ****** *)

implement main0() = ()

(* ****** ****** *)

(* end of [lecture10.dats] *)
