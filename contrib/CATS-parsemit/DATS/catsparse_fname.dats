(* ****** ****** *)
//
// CATS-parsemit
//
(* ****** ****** *)
//
// HX-2014-07-02: start
//
(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

#staload "libats/SATS/arena.sats"
#staload _ = "libats/DATS/arena.dats"
staload "./../SATS/catsparse.sats"

(* ****** ****** *)
//
//
// HX-2026-10: no GC
// a filename is a string that is never freed
// (a literal or a command-line argument)
//
assume filename_type = string
//
(* ****** ****** *)

implement
filename_dummy = ""
implement
filename_stdin = "__STDIN__"

(* ****** ****** *)

implement
filename_make(path) = path

(* ****** ****** *)

implement
fprint_filename
  (out, fil) = fprint_string (out, fil)
// end of [fprint_filename]

(* ****** ****** *)

(* end of [catsparse_fname.dats] *)
