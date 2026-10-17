(* the ATS1 part of the test of the level-2 static syntax that is not generated (see s2_gen.py, s2common1.hats) *)
(* ****** ****** *)
//
// the aliases of the ATS2 spec that do not exist in ATS1
//
typedef intlst = List (int)
typedef stringopt = Option (string)
typedef s2expoptopt = Option (s2expopt)
typedef d2conpair = @(d2con, d2con)
typedef d2conpairopt = Option (d2conpair)
typedef d2conopt = Option (d2con)
typedef d2conlstopt = Option (d2conlst)
typedef syms2rtlstlst = List (syms2rtlst)
typedef locs2explstlst = List (locs2explst)
//
fun mkloc (k: int): location = let
  var p1: $LOC.position
  var p2: $LOC.position
  val () = $LOC.position_init (p1, lint_of_int (k), k+1, k)
  val () = $LOC.position_init (p2, lint_of_int (k+3), k+1, k+3)
  val fil = $FIL.filename_make ("given", "part", "full")
in
  $LOC.location_make_fil_pos_pos (fil, p1, p2)
end
fun mkfilenv (k: int): filenv = $UN.cast{filenv} (0)
//
%{^
#include <stdio.h>
#define fflush_stdout() fflush(stdout)
%}
extern fun fflush_stdout (): void = "mac#fflush_stdout"
//
(* ****** ****** *)
fun mksize (k: int): size_t = size_of_int (k)
