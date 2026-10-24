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
//
fun
from(n: int): stream_vt(int) =
  $ldelay(stream_vt_cons(n, from(n+1)))
//
fun
sieve
(
ns: stream_vt(int)
) : stream_vt(int) = $ldelay
(
let
//
(*
[val-]: no warning message
*)
//
  val
  ns_con = !ns
  val-
  @stream_vt_cons(n0, ns1) = ns_con
//
  val n0_val = n0
  val ns1_val = ns1
//
  val ((*void*)) =
    (ns1 := sieve(stream_vt_filter_cloptr<int>(ns1_val, lam x => x mod n0_val > 0)))
  // end of [val]
//
  prval ((*folded*)) = fold@(ns_con)
//
in
  ns_con
end // end of [let]
,
~ns // [ns] is freed
) (* end of [$ldelay] *) // end of [sieve]
//
val thePrimes = sieve(from(2))
//
(* ****** ****** *)
//
val
p1000 =
(stream_vt_drop_exn(thePrimes, 1000)).head()
//
(* ****** ****** *)

val ((*void*)) = println! ("p1000 = ", p1000)

(* ****** ****** *)
//
extern
fun
{a:t0p}
{b:t0p}
list_vt_map$fopr(x: a): b
//
fun
{a:t0p}
{b:t0p}
list_vt_map
(
xs: List0_vt(a)
) : List0_vt(b) =
  auxlst(xs) where
{
//
fun
auxlst
(xs: List0_vt(a)): List0_vt(b) =
(
case+ xs of
| ~list_vt_nil() =>
  list_vt_nil()
| ~list_vt_cons(x, xs) =>
  list_vt_cons(list_vt_map$fopr<a><b>(x), auxlst(xs))
)
} (* end of [list_vt_map] *)
//
fun
{a:t0p}
{b:t0p}
list_vt_map_stream
  (xs: List0_vt(a)): List0_vt(b) = let
//
fun
auxlst
(
xs: List0_vt(a)
) : stream_vt(b) = $ldelay
(
(
case+ xs of
| ~list_vt_nil() =>
  stream_vt_nil()
| ~list_vt_cons(x, xs) =>
  stream_vt_cons(list_vt_map$fopr<a><b>(x), auxlst(xs))
) : stream_vt_con(b)
,
list_vt_free(xs) // [xs] is freed
) (* end of [$ldelay] *)
//
in
  stream2list_vt<b>(auxlst(xs))
end (* end of [list_vt_map_stream] *)
//
(* ****** ****** *)
//
implement
main0 () = {
//
val xs = list_make_intrange(0, 1000000)
//
implement
list_vt_map$fopr<int><int>(x) = x + 1
//
val zs = list_vt_map<int><int>(list_make_intrange(0, 10))
val ((*void*)) = println! ("zs = ", zs)
val ((*void*)) = list_vt_free(zs)
//
val ys = list_vt_map_stream<int><int>(xs)
val ((*void*)) = println! ("length(ys) = ", list_vt_length(ys))
val ((*void*)) = list_vt_free(ys)
//
} (* end of [main0] *)
//
(* ****** ****** *)

(* end of [chap_stream_vt.dats] *)
