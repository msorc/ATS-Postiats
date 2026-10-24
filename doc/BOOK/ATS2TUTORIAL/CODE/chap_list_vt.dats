(*
** For ATS2TUTORIAL
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

(*
//
datavtype
list_vt(a:vt@ype) =
  | list_vt_nil (a, 0)
  | {n:nat}
    list_vt_cons (a, n+1) of (a, list_vt(a, n))
//
*)

(* ****** ****** *)

fun
{a:vt@ype}
list_vt_length
  {n:nat}(xs: !list_vt(a, n)): int(n) =
(
case+ xs of
| list_vt_nil() => 0
| list_vt_cons(x, xs2) => 1 + list_vt_length(xs2)
)

(* ****** ****** *)

fun
{a:vt@ype}
list_vt_foreach
  {n:nat}
(
  xs: !list_vt(a, n)
, fwork: !(&(a) >> _) -<cloptr1> void
) : void =
(
case+ xs of
| list_vt_nil() => ()
| @list_vt_cons(x, xs2) => (fwork(x); list_vt_foreach<a> (xs2, fwork); fold@(xs))
) (* end of [list_vt_foreach] *)

(* ****** ****** *)

fun
{a:vt@ype}
list_vt_append
  {m,n:nat}
(
  xs: list_vt(a, m), ys: list_vt(a, n)
) : list_vt(a, m+n) = let
//
fun
loop{m:nat}
(
  xs: &list_vt(a, m) >> list_vt(a, m+n), ys: list_vt(a, n)
) : void =
(
case+ xs of
| ~list_vt_nil() => (xs := ys)
| @list_vt_cons(x, xs2) => (loop(xs2, ys); fold@(xs))
)
//
in
  case+ xs of
  | ~list_vt_nil () => ys
  | @list_vt_cons (x, xs2) => (loop(xs2, ys); fold@(xs); xs)
end // end of [list_vt_append]

(* ****** ****** *)

fun
{a:vt@ype}
list_vt_free
  {n:nat}
(
  xs: list_vt(a?, n)
) : void =
(
case+ xs of
| ~list_vt_nil() => ()
| ~list_vt_cons(x, xs2) => list_vt_free<a> (xs2)
)

(* ****** ****** *)

implement
main0 () = {
//
// [list_vt_free] above is a template for a list of
// non-linear elements; the one in the prelude is used here
//
val xs = list_vt_cons(1, list_vt_cons(2, list_vt_nil()))
val ys = list_vt_cons(3, list_vt_nil())
val zs = list_vt_append<int>(xs, ys)
val () = println! ("length(zs) = ", list_vt_length<int>(zs))
//
val inc = lam (x: &int >> _): void =<cloptr1> (x := x + 1)
val () = list_vt_foreach<int>(zs, inc)
val () = cloptr_free($UNSAFE.castvwtp0{cloptr(void)}(inc))
//
val () = println! ("zs = ", zs)
val () = list_vt_free<int>(zs)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [chap_list_vt.dats] *)
