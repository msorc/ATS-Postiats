(* ****** ****** *)
//
// HX-2014-11:
// A running example
// from ATS2 to Perl5
//
(* ****** ****** *)
//
#define
LIBATSCC2PL_targetloc
"$PATSHOME\
/contrib/libatscc2pl/ATS2-0.3.2"
//
(* ****** ****** *)
//
#include
"{$LIBATSCC2PL}/staloadall.hats"
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

extern
fun
main0_pl : () -> void = "mac#"
implement
main0_pl () =
{
//
val xs = mytest(5, 10)
val () = print("mytest(5, 10) = ")
val () = loop(xs, 0) where
{
fun
loop
(
  xs: !List0_vt(int), i: int
) : void =
(
case+ xs of
| list_vt_nil() => ()
| list_vt_cons(x, xs1) =>
  (if i > 0 then print(", "); print(x); loop(xs1, i+1))
)
}
val () = print_newline()
val () = list_vt_free(xs)
//
} (* end of [main0_pl] *)

(* ****** ****** *)

%{^
require "./libatscc2pl/libatscc2pl_all.pl";
%}

(* ****** ****** *)

%{$
main0_pl();
%} // end of [%{$]

(* ****** ****** *)

(* end of [listmap.dats] *)
