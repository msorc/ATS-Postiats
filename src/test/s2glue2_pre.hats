(* the ATS2 part of the test of the level-2 static syntax that is not generated (see s2_gen.py, s2common1.hats) *)
(* ****** ****** *)
//
fun mkloc (k: int): location = let
  var p1: $LOC.position
  var p2: $LOC.position
  val () = $LOC.position_init (p1, $UN.cast{lint} (k), k+1, k)
  val () = $LOC.position_init (p2, $UN.cast{lint} (k+3), k+1, k+3)
  val fil = $FIL.filename_make ("given", "part", "full")
in
  $LOC.location_make_fil_pos_pos (fil, p1, p2)
end
fun mkfilenv (k: int): filenv = $UN.cast{filenv} (the_null_ptr)
//
%{^
#include <stdio.h>
#define fflush_stdout() fflush(stdout)
%}
extern fun fflush_stdout (): void = "mac#fflush_stdout"
//
(* ****** ****** *)
fun mksize (k: int): size_t = $UN.cast{size_t} (k)
