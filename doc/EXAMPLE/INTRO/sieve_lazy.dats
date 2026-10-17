//usr/bin/env myatscc "$0"; exit
(* ****** ****** *)
(*
// Lazy-evaluation:
// Erathosthene's sieve for primes
*)
(* ****** ****** *)
//
// Author: Hongwei Xi
// Authoremail: gmhwxiATgmailDOTcom
// Start time: September, 2007
//
(* ****** ****** *)

(*
** Ported to ATS2 by HX-2013-09
*)

(* ****** ****** *)
//
(*
##myatsccdef=\
patsopt --constraint-ignore --dynamic $1 | \
tcc -run -DATS_MEMALLOC_LIBC -I${PATSHOME} -I${PATSHOME}/ccomp/runtime -
*)
//
(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

(* ****** ****** *)
//
// HX-2026-10: no GC
// The streams are linear: each suspension owns the
// stream it is built on and frees it if it is freed.
//
(* ****** ****** *)
//
fun
from{n:int}
(
  n: int n
) : stream_vt (intGte(n)) =
  $ldelay (stream_vt_cons{intGte(n)}(n, from (n+1)))
//
typedef N2 = intGte(2)
//
fun sieve
(
  ns: stream_vt N2
) : stream_vt (N2) = $ldelay
(
(
case+ !ns of
| ~stream_vt_nil() => stream_vt_nil()
| ~stream_vt_cons(n, ns) =>
  stream_vt_cons{N2}
  (
    n
  , sieve
    (
      stream_vt_filter_cloptr<N2>
        (ns, lam (x) =<cloptr1> g1int_nmod(x, n) > 0)
    )
  ) (* stream_vt_cons *)
)
,
~ns // HX: called if the stream is freed
) (* end of [sieve] *)
//
fun
stream_vt_nth
(
  xs: stream_vt(N2), n: int
) : int =
(
case+ !xs of
| ~stream_vt_nil() => ~1 // HX: deadcode
| ~stream_vt_cons(x, xs) =>
    if n > 0 then stream_vt_nth(xs, n-1) else (~xs; x)
  // end of [stream_vt_cons]
) (* end of [stream_vt_nth] *)
//
macdef
prime_get (n) = stream_vt_nth (sieve (from(2)), ,(n))
//
(* ****** ****** *)

implement
main0 () = begin
//
println! ("prime 1000 = ", prime_get (1000)) ; // = 7927
(*
println! ("prime 5000 = ", prime_get (5000)) ; // = 48619
println! ("prime 10000 = ", prime_get (10000)) ; // = 104743
*)
//
end // end of [main0]

(* ****** ****** *)

(* end of [sieve_lazy.dats] *)
