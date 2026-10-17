(*
** For writing ATS code
** that translates into Erlang
*)

(* ****** ****** *)
//
// HX-2014-07
//
(* ****** ****** *)
//
staload "./basics_erl.sats"
//
(* ****** ****** *)
//
staload "./SATS/integer.sats"
//
(* ****** ****** *)
//
staload "./SATS/bool.sats"
staload "./SATS/float.sats"
//
(* ****** ****** *)

staload "./SATS/print.sats"
staload _ = "./DATS/print.dats"

(* ****** ****** *)
//
staload "./SATS/list_vt.sats"
staload _ = "./DATS/list_vt.dats"
//
staload "./SATS/stream_vt.sats"
staload _ = "./DATS/stream_vt.dats"
//
staload "./SATS/intrange.sats"
staload _ = "./DATS/intrange.dats"
//
(* ****** ****** *)
//
//
(* ****** ****** *)
//
(*
*)
//
(* ****** ****** *)
//
staload "./SATS/reference.sats"
//
(* ****** ****** *)

(* end of [staloadall.hats] *)
