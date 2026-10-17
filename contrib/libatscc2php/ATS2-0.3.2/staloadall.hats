(*
** For writing ATS code
** that translates into PHP
*)

(* ****** ****** *)
//
// HX-2014-09-09
//
(* ****** ****** *)
//
#staload "./basics_php.sats"
//
(* ****** ****** *)
//
#staload "./SATS/integer.sats"
//
(* ****** ****** *)
//
#staload "./SATS/bool.sats"
#staload "./SATS/float.sats"
#staload "./SATS/string.sats"
//
(* ****** ****** *)
//
#staload
_(*anon*) = "./DATS/basics.dats"
//
(* ****** ****** *)
//
#staload "./SATS/print.sats"
#staload _ = "./DATS/print.dats"
//
(* ****** ****** *)
//
#staload "./SATS/filebas.sats"
//
(* ****** ****** *)
//
//
(* ****** ****** *)
//
//
#staload "./SATS/list_vt.sats"
#staload _ = "./DATS/list_vt.dats"
//
#staload "./SATS/stream_vt.sats"
#staload _ = "./DATS/stream_vt.dats"
//
(* ****** ****** *)
//
#staload "./SATS/intrange.sats"
#staload "./SATS/reference.sats"
//
(* ****** ****** *)
//
#staload "./SATS/PHPref.sats"
#staload "./SATS/PHParray.sats"
#staload "./SATS/PHParref.sats"
//
(* ****** ****** *)

#staload "./SATS/arrayref.sats"
#staload "./SATS/matrixref.sats"

(* ****** ****** *)
//
// one-list-based stack
// two-list-based queue
//
#staload "./SATS/slistref.sats"
#staload "./SATS/qlistref.sats"
//
(* ****** ****** *)
//
// HX: un-indexed list
// HX: un-indexed array
//
//
//
(* ****** ****** *)

(* end of [staloadall.hats] *)
