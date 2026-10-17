(* ****** ****** *)
//
// HX-2016-07:
// A running example
// from ATS2 to Clojure
//
(* ****** ****** *)
//
#define ATS_DYNLOADFLAG 0
//
(* ****** ****** *)
//
#define
LIBATSCC2CLJ_targetloc
"$PATSHOME\
/contrib/libatscc2clj/ATS2-0.3.2"
//
(* ****** ****** *)
//
#include
"{$LIBATSCC2CLJ}/staloadall.hats"
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
(* ****** ****** *)
//
fun
print_intlist
  (xs: !List0_vt(int)): void = let
//
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
//
in
  loop(xs, 0)
end // end of [print_intlist]


(* ****** ****** *)

extern
fun
main0_ats
  : () -> void = "mac#listmap_main0_ats"
implement
main0_ats () =
{
//
val xs = mytest(5, 10)
val () = print("mytest(5, 10) = ")
val () = print_intlist(xs)
val () = print_newline()
val () = list_vt_free(xs)
//
} (* end of [main0_ats] *)

(* ****** ****** *)

%{$
;;
(listmap_main0_ats)
;;
%} // end of [%{]

(* ****** ****** *)

(* end of [listmap.dats] *)
