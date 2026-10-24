(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
staload UN = "prelude/SATS/unsafe.sats"
//
(* ****** ****** *)
//
// the simulated event loop of the chapter on animation
//
#include "./../../04-10/CODE/eventloop.hats"
//
#include "./../../05/CODE/listfun.hats"
#include "./../../10/CODE/streamfun.hats"
//
(* ****** ****** *)
//
// A continuation is called at most once. It is a linear closure,
// which is freed after the call (a call does not consume it).
//
vtypedef cont0 = () -<lincloptr1> void
vtypedef cont1(res:vt@ype) = (res) -<lincloptr1> void
//
fun
cont0_call(k: cont0): void =
(k(); cloptr_free($UNSAFE.castvwtp0{cloptr(void)}(k)))
//
fun
{res:vt@ype}
cont1_call(k: cont1(res), x: res): void =
(k(x); cloptr_free($UNSAFE.castvwtp0{cloptr(void)}(k)))
//
(* ****** ****** *)
//
// The work that is scheduled for [do_async1] and [do_async2]
// is simulated by a call to [execute_after]
//
fun
do_async1_cont(k: cont0): void =
execute_after
(llam() => (println! ("do_async1 is done"); cont0_call(k)), 100)
//
fun
do_async2_cont(k: cont0): void =
execute_after
(llam() => (println! ("do_async2 is done"); cont0_call(k)), 100)
//
(* ****** ****** *)
//
fun
do_async1
(
// argless
) : void = do_async1_cont(llam() => ())
//
fun
do_async2
(
// argless
) : void = do_async2_cont(llam() => ())
//
(* ****** ****** *)
//
fun
do_async12(): void =
{
  val () = do_async1(); val () = do_async2()
} (* end of [do_async12] *)
//
fun
do_async12_cps(): void =
{
  val () = do_async1_cont(llam() => do_async2())
} (* end of [do_async12_cps] *)
//
fun
do_async12_cont
  (k: cont0): void =
{
  val () = do_async1_cont(llam() => do_async2_cont(k))
} (* end of [do_async12_cont] *)
//
val () = do_async12()
val () = eventloop_run(1000)
val () = do_async12_cps()
val () = eventloop_run(2000)
val () = do_async12_cont(llam() => println! ("do_async12 is done"))
val () = eventloop_run(3000)
//
(* ****** ****** *)
//
fun
fact
(
n : int
) : int =
if n > 0 then n * fact(n-1) else 1
//
(* ****** ****** *)
//
fun
k_fact
(
n : int
,
k : cont1(int)
) : void = (
//
if
(n > 0)
then k_fact(n-1, llam(res) => cont1_call<int>(k, n*res))
else cont1_call<int>(k, 1)
// end of [if]
) (* end of [k_fact] *)
//
val () = println! ("fact(10) = ", fact(10))
val () = k_fact(10, llam(res) => println! ("k_fact(10) = ", res))
//
(* ****** ****** *)
//
fun
fibo
(
n : int
) : int =
if n >= 2 then fibo(n-1)+fibo(n-2) else n
//
(* ****** ****** *)
//
fun
k_fibo
(
n : int
,
k : cont1(int)
) : void = (
//
if
(n >= 2)
then
k_fibo
( n-1
, llam(r1) => k_fibo(n-2, llam(r2) => cont1_call<int>(k, r1+r2))
) (* end of [then] *)
else cont1_call<int>(k, n) // end of [else]
// end of [if]
) (* end of [k_fibo] *)
//
val () = println! ("fibo(20) = ", fibo(20))
val () = k_fibo(20, llam(res) => println! ("k_fibo(20) = ", res))
//
(* ****** ****** *)
//
fun
fact2
(n : int, res: int): int =
if n > 0 then fact2(n-1, n*res) else res
//
(* ****** ****** *)
//
fun
k_fact2
(n: int, res: int, k: cont1(int)): void  =
if n > 0 then k_fact2(n-1, n*res, k) else cont1_call<int>(k, res)
//
val () = k_fact2(10, 1, llam(res) => println! ("k_fact2(10) = ", res))
//
(* ****** ****** *)
//
// The function [f0] is an envless function, as it is called for
// each element; the list is consumed.
//
extern
fun
{a,b:t@ype}
list_kmap
( xs: List0_vt(a)
, f0: (a, cont1(b)) -> void, k0: cont1(List0_vt(b))): void
//
implement
{a,b}(*tmp*)
list_kmap(xs, f0, k0) =
(
case+ xs of
| ~list_vt_nil() =>
  cont1_call<List0_vt(b)>(k0, list_vt_nil())
| ~list_vt_cons(x, xs) =>
  f0(x, llam(y) =>
  list_kmap<a,b>(xs, f0, llam(ys) => cont1_call<List0_vt(b)>(k0, list_vt_cons(y, ys))))
)
//
val () =
list_kmap<int,int>
( $list_vt{int}(1, 2, 3)
, lam(x, k) => cont1_call<int>(k, x * x)
, llam(ys) => (println! ("list_kmap: ", ys); list_vt_free<int>(ys))
)
//
(* ****** ****** *)
//
extern
fun
{a:t@ype}
stream_kforeach
( xs: stream_vt(a)
, f0: (a, cont1(bool)) -> void, k0: cont0): void
//
implement
{a}(*tmp*)
stream_kforeach(xs, f0, k0) =
(
case+ !xs of
| ~stream_vt_nil() => cont0_call(k0)
| ~stream_vt_cons(x, xs) =>
  f0(x, llam(y) =>
  if y then stream_kforeach<a>(xs, f0, k0) else (~xs; cont0_call(k0)))
)
//
// the primes that are less than 30 are printed
//
val () =
stream_kforeach<int>
( sieve()
, lam(p, k) => if p < 30 then (print!(p, " "); cont1_call<bool>(k, true)) else cont1_call<bool>(k, false)
, llam() => println! ("(done)")
)
//
(* ****** ****** *)

implement main0() = ()

(* ****** ****** *)

(* end of [lecture12.dats] *)
