(*
** For testing
** intset implementation
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)
//
#staload
"./../SATS/basis_intset.sats"
#staload _ =
"./../DATS/basis_intset.dats"
//
// HX-2026-10: intsets are in the global arena
#staload _ = "libats/DATS/arena.dats"
//
(* ****** ****** *)

overload + with intset_add_elt

(* ****** ****** *)

overload + with intset_union
overload * with intset_intersect

(* ****** ****** *)

implement
main0() = () where
{
//
val () =
println!
  ("Hello from [intset]!")
//
#define N 10
//
val xs =
intset_nil{N}()
//
val xs = xs + 1
val xs = xs + 5
val xs = xs + 6
val xs = xs + 3
val () = println! ("xs = ", xs)
//
val xs = xs + xs
val () = println! ("xs = ", xs)
//
val xs = xs * xs
val () = println! ("xs = ", xs)
//
val ys =
  intset_ncomplement(xs, N)
//
val () = println! ("ys = (", ys, ")")
//
val () = println! ("xs * ys = (", xs * ys, ")")
val () = println! ("xs + ys = (", xs + ys, ")")
//
var fx = lam@(x: natLt(N)): void => println! ("x = ", x)
var fy = lam@(y: natLt(N)): void => println! ("y = ", y)
var fxy =
lam@(x: natLt(N), y: natLt(N)): void => println! ("(x, y) = (", x, ", ", y, ")")
//
val () = intset_foreach_clo(xs, fx)
val () = intset_foreach_clo(ys, fy)
//
val () = cintset_foreach_clo(N, xs, fx)
val () = cintset_foreach_clo(N, ys, fy)
//
val () = intset2_foreach_clo(xs, ys, fxy)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [intset.dats] *)
