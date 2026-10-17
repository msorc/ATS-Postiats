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
staload
"{$LIBATSCC2PY3}/SATS/PYlist.sats"
//
(* ****** ****** *)

//
// HX-2026-10: no GC
// the conversions return linear lists (they are
// implemented in the runtime as PYlist2list_vt[_rev])
//
extern
fun
PYlist2list
  : {a:t0p} PYlist(a) -> List0_vt(a) = "mac#"
//
implement
PYlist2list{a}(xs) = PYlist2list_vt{a}(xs)
//
extern
fun
PYlist2list_rev
  : {a:t0p} PYlist(a) -> List0_vt(a) = "mac#"
//
implement
PYlist2list_rev{a}(xs) = PYlist2list_vt_rev{a}(xs)
//
(* ****** ****** *)
//
extern
fun
PYlist_evnodd(PYlist(int)): void = "mac#"
//
implement
PYlist_evnodd(xs) =
  PYlist_sort_2(xs, lam(x, y) =<cloptr1> (x%2 - y%2))
//
(* ****** ****** *)

%{^
import sys
######
from libatscc2py3_all import *
######
sys.setrecursionlimit(1000000)
######
%} // end of [%{^]

(* ****** ****** *)

%{$

def fromto(m, n):
  res = []
  for i in range(m, n): res.append (i)
  res.reverse
  return res

xs = fromto(0,10); print("xs =", xs)
PYlist_evnodd(xs); print("xs =", xs)
ys = PYlist2list(xs); print("ys =", ys)
ys_rev = PYlist2list_rev(xs); print("ys_rev =", ys_rev)

%} // end of [%{$]

(* ****** ****** *)

(* end of [PYlist_test.dats] *)
