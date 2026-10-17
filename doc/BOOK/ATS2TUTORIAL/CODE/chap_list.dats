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
// HX-2026-10: no GC
// lists are linear (list_vt): a function either
// borrows a list (!list_vt) or consumes it
//
fun
fromto
{m,n:int | m <= n}
(
  m: int(m), n: int(n)
) : list_vt(int, n-m) =
  if m < n
    then list_vt_cons(m, fromto(m+1, n)) else list_vt_nil()
  // end of [if]
//
fun
{a:t@ype}
list_length
  {n:nat}
(
  xs: !list_vt(a, n)
) : int(n) = let
//
fun
loop
{i,j:nat}
(
  xs: !list_vt(a, i), j: int(j)
) : int(i+j) =
(
case+ xs of
| list_vt_nil () => j
| list_vt_cons (_, xs) => loop(xs, j+1)
)
//
in
  loop (xs, 0)
end // end of [list_length]
//
fun
{a,b:t@ype}
list_foldleft
  {n:nat}
(
  f: (a, b) -> a, ini: a, xs: !list_vt(b, n)
) : a =
(
case+ xs of
| list_vt_nil () => ini
| list_vt_cons (x, xs) => list_foldleft (f, f(ini, x), xs)
) (* end of [list_foldleft] *)
//
fun
{a,b:t@ype}
list_foldright
  {n:nat}
(
  f: (a, b) -> b, xs: !list_vt(a, n), snk: b
) : b =
(
case+ xs of
| list_vt_nil () => snk
| list_vt_cons (x, xs) => f (x, list_foldright (f, xs, snk))
)
//
fun
{a:t@ype}
list_reverse
  {n:nat}
(
  xs: list_vt(a, n)
) : list_vt(a, n) = let
//
fun
loop{i,j:nat}
(
  xs: list_vt(a, i), ys: list_vt(a, j)
) : list_vt(a, i+j) =
  case+ xs of
  | ~list_vt_nil () => ys
  | ~list_vt_cons (x, xs) => loop (xs, list_vt_cons (x, ys))
//
in
  loop (xs, list_vt_nil)
end // end of [list_reverse]
//
fun
{a:t@ype}
list_append
  {m,n:nat}
(
  xs: list_vt(a,m), ys: list_vt(a,n)
) : list_vt(a,m+n) =
(
case+ xs of
| ~list_vt_nil () => ys
| ~list_vt_cons (x, xs) => list_vt_cons (x, list_append (xs, ys))
)
//
fun
{a:t@ype}
list_get_at
  {n:nat}
(
  xs: !list_vt(a, n), i: natLt(n)
) : a =
(
case+ xs of
| list_vt_cons (x, xs) =>
    if i > 0 then list_get_at(xs, i-1) else x
  // end of [list_vt_cons]
)
//
// HX: the list is updated in place
//
fun
{a:t@ype}
list_set_at
  {n:nat}
(
  xs: !list_vt(a, n), i: natLt(n), x0: a
) : void =
(
case+ xs of
| @list_vt_cons (x, xs1) =>
  (
    if i > 0
      then (list_set_at(xs1, i-1, x0); fold@ (xs))
      else (x := x0; fold@ (xs))
    // end of [if]
  )
)
//
val
digits = fromto(0, 10)
//
val () =
assertloc
(
list_foldleft<int,int> (lam (x, y) => x + y, 0, digits) = 45
) (* end of [val] *)
val () =
assertloc
(
list_foldright<int,int> (lam (x, y) => x + y, digits, 0) = 45
) (* end of [val] *)
//
val () =
println! ("digits[4] = ", list_get_at<int>(digits, 4))
val () =
println! ("digits[5] = ", list_get_at<int>(digits, 5))
val () = println! ("digits = ", digits)
//
val () = list_set_at<int> (digits, 4, 5)
val () = list_set_at<int> (digits, 5, 4)
//
val () =
println! ("digits[4] = ", list_get_at<int>(digits, 4))
val () =
println! ("digits[5] = ", list_get_at<int>(digits, 5))
val () = println! ("digits = ", digits)
//
val digits = list_reverse<int> (digits)
val digits = list_append<int> (digits, fromto(10, 12))
val () = println! ("digits = ", digits)
//
val () = list_vt_free (digits)
//
implement main0 () = {}

(* ****** ****** *)

(* end of [chap_list.dats] *)
