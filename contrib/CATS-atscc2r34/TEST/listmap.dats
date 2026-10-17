(* ****** ****** *)
//
// HX-2014-08:
// A running example
// from ATS2 to Node.js
//
(* ****** ****** *)
//
#define
ATS_DYNLOADFLAG 0
//
(* ****** ****** *)
//
#define
LIBATSCC2R34_targetloc
"$PATSHOME/contrib/libatscc2r34"
//
(* ****** ****** *)
//
staload
"{$LIBATSCC2R34}/basics_r34.sats"
staload
"{$LIBATSCC2R34}/SATS/integer.sats"
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
######
options(expressions=100000);
######
if
(
!(exists("libatscc2r34.is.loaded"))
)
{
  assign("libatscc2r34.is.loaded", FALSE)
}
######
if
(
!(libatscc2r34.is.loaded)
)
{
  sys.source("./libatscc2r34/libatscc2r34_all.R", envir = globalenv())
}
######
%} // end of [%{^]

(* ****** ****** *)

%{$
xs <- fromto(0, 10)
message("mytest(5, 10) =", mytest(5, 10))
%} // end of [%{$]

(* ****** ****** *)

(* end of [listmap.dats] *)
