(* ****** ****** *)
//
// Hanoi Towers: the direct style, the CPS-style and the animation
//
(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
staload UN = "prelude/SATS/unsafe.sats"
//
(* ****** ****** *)
//
vtypedef cont0 = () -<lincloptr1> void
//
fun
cont0_call(k: cont0): void =
(k(); cloptr_free($UNSAFE.castvwtp0{cloptr(void)}(k)))
//
(* ****** ****** *)
//
typedef pole = int // 1, 2 or 3
//
var theMoves_var: int = 0 // the number of the moves
val theMoves =
ref_make_viewptr{int}(view@ theMoves_var | addr@ theMoves_var)
//
fun
move(src: pole, dst: pole): void =
(
!theMoves := !theMoves + 1;
println! ("move ", !theMoves, ": a disk from pole ", src, " to pole ", dst)
)
//
(* ****** ****** *)
//
extern
fun
nmove(n: int, src: pole, dst: pole, tmp: pole): void
//
(* ****** ****** *)
//
implement
nmove
( n
, src, dst, tmp) =
if
(n > 0)
then
(
nmove(n-1, src, tmp, dst); move(src, dst); nmove(n-1, tmp, dst, src);
)
// end of [if] // end of [nmove]
//
(* ****** ****** *)
//
extern
fun
k_move(src: pole, dst: pole, k: cont0): void
//
extern
fun
k_nmove(n: int, src: pole, dst: pole, tmp: pole, k: cont0): void
//
(* ****** ****** *)
//
implement
k_nmove
( n
, src, dst, tmp
, k0 ) =
if
(n > 0)
then
(
k_nmove
( n-1, src, tmp, dst
, llam() => k_move(src, dst, llam() => k_nmove(n-1, tmp, dst, src, k0)))
)
else cont0_call(k0)
// end of [if] // end of [k_nmove]
//
(* ****** ****** *)
//
// the usual implementation of [k_move]
//
implement
k_move
(src, dst, k0) = let
  val () = move(src, dst) in cont0_call(k0)
end // end of [k_move]
//
val () = println! ("-- direct style --")
val () = nmove(3, 1, 2, 3)
//
val () = !theMoves := 0
val () = println! ("-- CPS-style --")
val () = k_nmove(3, 1, 2, 3, llam() => println! ("done"))
//
(* ****** ****** *)
//
// The continuation is saved, instead of being called: the next
// step of the animation is taken when [step] is called.
//
var theSaved_var: ptr = the_null_ptr
val theSaved =
ref_make_viewptr{ptr}(view@ theSaved_var | addr@ theSaved_var)
//
fun
save_cont(k0: cont0): void =
!theSaved := $UNSAFE.castvwtp0{ptr}(k0)
//
// [step] returns false if there is no continuation to continue with
//
fun
step(): bool = let
  val p = !theSaved
in
  if iseqz(p)
    then false
    else let
      val () = !theSaved := the_null_ptr
      val () = cont0_call($UNSAFE.castvwtp0{cont0}(p))
    in
      true
    end // end of [else]
end // end of [step]
//
fun
steps(): void = if step() then steps() else ()
//
(* ****** ****** *)
//
// The version of [k_move] for the animation
//
extern
fun
k_move2(src: pole, dst: pole, k: cont0): void
//
implement
k_move2
(src, dst, k0) = let
  val () = move(src, dst) in save_cont(k0)
end // end of [k_move2]
//
(* ****** ****** *)
//
// [k_nmove2] is [k_nmove] in which [k_move2] is called
//
extern
fun
k_nmove2(n: int, src: pole, dst: pole, tmp: pole, k: cont0): void
//
implement
k_nmove2
( n
, src, dst, tmp
, k0 ) =
if
(n > 0)
then
(
k_nmove2
( n-1, src, tmp, dst
, llam() => k_move2(src, dst, llam() => k_nmove2(n-1, tmp, dst, src, k0)))
)
else cont0_call(k0)
// end of [if] // end of [k_nmove2]
//
(* ****** ****** *)

implement
main0() = {
//
val () = !theMoves := 0
val () = println! ("-- animation: one step at a time --")
//
// the first call returns after the first move
//
val () = k_nmove2(3, 1, 2, 3, llam() => println! ("done"))
val () = println! ("(the first move is made, the rest is saved)")
//
val-true = step()
val-true = step()
//
val () = println! ("(two more moves are made, the rest is saved)")
//
val () = steps()
//
val () = println! ("the number of the moves: ", !theMoves)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [HanoiTowers.dats] *)
