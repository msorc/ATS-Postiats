(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)
//
#include "./../../05/CODE/listfun.hats"
#include "./../../06/CODE/listfun2.hats"
#include "./listfun3.hats"
//
(* ****** ****** *)
//
// printing a list of lists (a line for each list)
//
fun
lists_print
(xss: !List0_vt(List0_vt(int))): void =
(
case+ xss of
| list_vt_nil() => ()
| list_vt_cons(xs, xss) => (println! (" ", xs); lists_print(xss))
)
//
(* ****** ****** *)
//
val xs135 = $list_vt{int}(1, 3, 5)
val ys24 = $list_vt{int}(2, 4)
val ys246 = $list_vt{int}(2, 4, 6)
//
val zs = list_zip<int,int>(xs135, ys24)
val () = println! ("zip = ", zs)
val () = list_vt_free<@(int,int)>(zs)
//
val zs =
let
  var fopr = lam@(x: int, y: int): int => x * y
in
  list_map2<int,int><int>(xs135, ys246, fopr)
end
val () = println! ("map2 = ", zs)
val () = list_vt_free<int>(zs)
//
(* ****** ****** *)
//
var cmp = lam@(x: int, y: int): int => compare(x, y)
//
val zs = list_merge<int>(xs135, ys246, cmp)
val () = println! ("merge = ", zs)
val () = list_vt_free<int>(zs)
//
val xs = $list_vt{int}(3, 1, 5, 2, 4, 9, 7, 8, 6, 0)
val zs = list_mergesort<int>(xs, cmp)
val () = println! ("mergesort = ", zs)
val () = list_vt_free<int>(zs)
val () = list_vt_free<int>(xs)
//
(* ****** ****** *)
//
val xs123 = $list_vt{int}(1, 2, 3)
//
val zs = list_choose2<int>(xs123)
val () = println! ("choose2 = ", zs)
val () = list_vt_free<@(int,int)>(zs)
//
val zss = list_nchoose<int>(xs123, 2)
val () = println! ("nchoose:")
val () = lists_print(zss)
val () = lists_free<int>(zss)
//
val zzs = list_nchoose_rest<int>(xs123, 2)
val () = println! ("the number of nchoose_rest = ", list_vt_length<@(List0_vt(int), List0_vt(int))>(zzs))
val () =
let
  fun
  free(zzs: List0_vt(@(List0_vt(int), List0_vt(int)))): void =
  (
    case+ zzs of
    | ~list_vt_nil() => ()
    | ~list_vt_cons(@(xs, ys), zzs) =>
      (list_vt_free<int>(xs); list_vt_free<int>(ys); free(zzs))
  )
in
  free(zzs)
end
//
val zss = list_permute<int>(xs123)
val () = println! ("permute:")
val () = lists_print(zss)
val () = lists_free<int>(zss)
//
val () = list_vt_free<int>(xs123)
val () = list_vt_free<int>(xs135)
val () = list_vt_free<int>(ys24)
val () = list_vt_free<int>(ys246)
//
(* ****** ****** *)

implement main0() = ()

(* ****** ****** *)

(* end of [lecture07.dats] *)
