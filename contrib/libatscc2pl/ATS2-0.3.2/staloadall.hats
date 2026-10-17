(*
** For writing ATS code
** that translates into Perl
*)

(* ****** ****** *)
//
// HX-2014-09-09
//
(* ****** ****** *)
//
staload "./basics_pl.sats"
//
(* ****** ****** *)
//
staload "./SATS/integer.sats"
//
(* ****** ****** *)
//
staload "./SATS/bool.sats"
staload "./SATS/float.sats"
staload "./SATS/string.sats"
//
(* ****** ****** *)
//
staload "./SATS/print.sats"
staload _ = "./DATS/print.dats"
//
(* ****** ****** *)
//
staload "./SATS/filebas.sats"
//
(* ****** ****** *)

staload "./SATS/PLarray.sats"

(* ****** ****** *)
//
//
(* ****** ****** *)
//
//
(* ****** ****** *)
//
staload "./SATS/list_vt.sats"
staload _ = "./DATS/list_vt.dats"
//
staload "./SATS/stream_vt.sats"
//
staload _ = "./DATS/stream_vt.dats"
//
(* ****** ****** *)
//
staload "./SATS/intrange.sats"
(*
staload _(*anon*) = "./DATS/intrange.dats"
*)
//
(* ****** ****** *)

staload "./SATS/reference.sats"

(* ****** ****** *)
//
// HX: one-list-based
// HX: two-list-based
//
staload "./SATS/slistref.sats"
staload "./SATS/qlistref.sats"
//
(* ****** ****** *)
//
// HX: un-indexed list
//
//
(* ****** ****** *)

(* end of [staloadall.hats] *)
