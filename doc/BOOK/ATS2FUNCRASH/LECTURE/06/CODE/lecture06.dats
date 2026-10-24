(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)
//
#include "./../../04/CODE/intfun.hats"
#include "./../../05/CODE/listfun.hats"
#include "./listfun2.hats"
//
(* ****** ****** *)

val xs = $list_vt{int}(1, 10, 100)

(* ****** ****** *)
//
val () = println! ("head = ", list_head<int>(xs))
//
val nil = list_vt_nil{int}()
val opt = list_head_opt<int>(nil)
val () = println! ("the empty list has a head: ", isneqz(opt))
val () = option_vt_free<int>(opt)
val () = list_vt_free<int>(nil)
//
val opt = list_head_opt<int>(xs)
val () = println! ("is some: ", isneqz(opt))
val () = option_vt_free<int>(opt)
//
val opt = list_last_opt<int>(xs)
val-~Some_vt(last) = opt
val () = println! ("last = ", last)
//
val () = println! ("get_at(xs, 1) = ", list_get_at<int>(xs, 1))
//
val () = println! ("tally1 = ", list_tally1(xs))
val () = println! ("tally2 = ", list_tally2(xs))
//
(* ****** ****** *)

val xs5 = $list_vt{int}(1, 2, 3, 4, 5)

val sq =
let
  var fopr = lam@(x: int): int => x * x
in
  list_map<int><int>(xs5, fopr)
end
val () = println! ("squares = ", sq)
val () = list_vt_free<int>(sq)

(* ****** ****** *)

val ys = $list_vt{int}(0, 1)
val zs = $list_vt{int}(2, 3, 4)
val yzs = list_cross<int,int>(ys, zs)
val () = println! ("cross: ", yzs)
val () = list_vt_free<@(int,int)>(yzs)
val () = list_vt_free<int>(ys)
val () = list_vt_free<int>(zs)

(* ****** ****** *)

val () =
{
var fwork = lam@(x: int): void => print!(x, ";")
val () = list_foreach<int>(xs5, fwork)
val () = println! ()
}

(* ****** ****** *)

val evens =
let
  var test = lam@(x: int): bool => x % 2 = 0
in
  list_filter<int>(xs5, test)
end
val () = println! ("even: ", evens)
val () = list_vt_free<int>(evens)

(* ****** ****** *)

val dups = $list_vt{int}(1, 2, 1, 3, 2, 4)
val nodups = list_remdup<int>(dups, lam(x, y) => x = y)
val () = println! ("remdup: ", nodups)
val () = list_vt_free<int>(dups)
val () = list_vt_free<int>(nodups)

(* ****** ****** *)

val xs123 = $list_vt{int}(1, 2, 3)

val () =
{
var test = lam@(x: int): bool => x % 2 = 0
val () = println! ("find_index = ", list_find_index<int>(xs123, test))
val () = println! ("exists = ", list_exists<int>(xs123, test))
val () = println! ("forall = ", list_forall<int>(xs123, test))
}

val imapped =
let
  var fopr = lam@(i: int, x: int): int => i * x
in
  list_imap<int><int>(xs123, fopr)
end
val () = println! ("imap = ", imapped)
val () = list_vt_free<int>(imapped)

(* ****** ****** *)

val () = list_vt_free<int>(xs123)
val () = list_vt_free<int>(xs5)
val () = list_vt_free<int>(xs)

(* ****** ****** *)
//
// 8-queen puzzle
//
#include "./queens.hats"
#include "./queens_dfs.hats"
//
val () = println! ("the number of solutions of the puzzle is ", QueenCount())
//
(* ****** ****** *)

implement main0() = ()

(* ****** ****** *)

(* end of [lecture06.dats] *)
