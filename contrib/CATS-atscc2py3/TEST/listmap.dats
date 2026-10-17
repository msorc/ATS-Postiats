(* ****** ****** *)
//
// HX-2014-08:
// A running example
// from ATS2 to Python3
//
(* ****** ****** *)
//
#define
LIBATSCC2PY3_targetloc
"$PATSHOME\
/contrib/libatscc2py3/ATS2-0.3.2"
//
(* ****** ****** *)
//
staload
"{$LIBATSCC2PY3}/basics_py.sats"
staload
"{$LIBATSCC2PY3}/SATS/integer.sats"
//
(* ****** ****** *)
//
//
// HX-2026-10: no GC (linear lists and closures)
//
fun
{a:t0p}
{b:t0p}
list_vt_map0
(
  xs: List0_vt(a), f: !(a) -<cloptr1> b
) : List0_vt(b) =
(
case+ xs of
| ~list_vt_nil () => list_vt_nil ()
| ~list_vt_cons (x, xs) =>
    let val y = f(x) in list_vt_cons (y, list_vt_map0<a><b> (xs, f)) end
) (* end of [list_vt_map0] *)
//
(* ****** ****** *)
//
extern
fun
fromto
  : (int, int) -> List0_vt (int) = "mac#fromto"
//
implement
fromto(m, n) =
if m < n
  then list_vt_cons(m, fromto(m+1, n)) else list_vt_nil()
// end of [if]
//
(* ****** ****** *)
//
extern
fun
mytest
  : (int, int) -> List0_vt(int) = "mac#mytest"
//
implement
mytest (m, n) = let
  val xs = fromto (m, n)
  val f = lam (x: int): int =<cloptr1> m * n * x
  val ys = list_vt_map0<int><int> (xs, f)
in
  cfun_free(f); ys
end // end of [mytest]
//
//
(* ****** ****** *)

%{^
import sys
######
from libatscc2py3_all import *
######
sys.setrecursionlimit(1000000)
######
%}

(* ****** ****** *)

%{$
//
print("mytest(5, 10) = ", mytest(5, 10), sep='')
//
%} // end of [%{$]

(* ****** ****** *)

(* end of [listmap.dats] *)
