(* ****** ****** *)
//
// A port of the ATS3 test
//
//   prelude/TEST/CATS/JS/test00_prelude.dats
//
// The ATS3 version prints a greeting and then flushes its
// print store; ATS2 has no print store, so the printing is
// done directly.
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

implement
main0 () = println! ("Hello from [test00_prelude]!")

(* ****** ****** *)

(* end of [test00_prelude.dats] *)
