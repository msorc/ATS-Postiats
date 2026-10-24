(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)
//
#include "./listfun.hats"
//
(* ****** ****** *)
//
// Constructing a list: every list has to be freed
//
val xs0 = list_vt_nil{int}() // xs = ()
val xs1 = list_vt_cons{int}(1, xs0) // xs = (1)
val xs2 = list_vt_cons{int}(2, xs1) // xs = (2, 1)
val xs3 = list_vt_cons{int}(3, xs2) // xs = (3, 2, 1)
//
val () = println! ("xs3 = ", xs3)
val () = println! ("length(xs3) = ", list_length<int>(xs3))
//
val () = list_vt_free<int>(xs3)
//
(* ****** ****** *)
//
val xs123 = $list_vt{int}(1, 2, 3) // xs123 = (1, 2, 3)
val ys123 = $list_vt{string}("1", "2", "3") // ys123 = ("1", "2", "3")
//
val () = println! ("xs123 = ", xs123)
val () = println! ("ys123 = ", ys123)
//
val () = list_vt_free<string>(ys123)
//
(* ****** ****** *)

val xs456 = $list_vt{int}(4, 5, 6)
val xs123456 = list_append<int>(xs123, xs456)
val () = println! ("append = ", xs123456)
val rev = list_reverse<int>(xs123456)
val () = println! ("reverse = ", rev)
val rev2 = list_reverse2<int>(xs123456)
val () = println! ("reverse2 = ", rev2)
val () = println! ("length2 = ", list_length2<int>(rev))
val ys0 = list_revappend2<int>(xs123, $list_vt{int}(0))
val () = println! ("revappend2 = ", ys0)
val ys1 = list_append2<int>(ys0, xs456)
val () = println! ("append2 = ", ys1)
//
val () = list_vt_free<int>(ys0)
val () = list_vt_free<int>(ys1)
val () = list_vt_free<int>(rev)
val () = list_vt_free<int>(rev2)
val () = list_vt_free<int>(xs456)
val () = list_vt_free<int>(xs123456)

(* ****** ****** *)
//
val xss =
$list_vt{List0_vt(int)}($list_vt{int}(1, 2), $list_vt{int}(3), $list_vt{int}(4, 5))
val xs12345 = list_concat<int>(xss)
val () = println! ("concat = ", xs12345)
val () = list_vt_free<int>(xs12345)
//
(* ****** ****** *)
//
val xs = $list_vt{int}(3, 1, 5, 2, 4)
//
var cmp = lam@(x: int, y: int): int => compare(x, y)
val ys = list_insertion_sort<int>(xs, cmp)
val () = println! ("sorted = ", ys)
//
val () = list_vt_free<int>(xs)
val () = list_vt_free<int>(ys)
val () = list_vt_free<int>(xs123)
//
(* ****** ****** *)

implement main0() = ()

(* ****** ****** *)

(* end of [lecture05.dats] *)
