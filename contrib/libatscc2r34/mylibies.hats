(*
** For writing ATS code
** that translates into R(stat)
*)

(* ****** ****** *)
//
// HX-2014-09-09
//
(* ****** ****** *)
//
#staload "./basics_r34.sats"
(*
#staload _ = "./DATS/basics.dats"
*)
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
#staload "./SATS/print.sats" // HX: printing to the console
//
(* ****** ****** *)
//
//
#staload "./SATS/list_vt.sats"
#staload _ = "./DATS/list_vt.dats"
//
(* ****** ****** *)
//
//
(* ****** ****** *)
//
//
#staload "./SATS/stream_vt.sats"
#staload _ = "./DATS/stream_vt.dats"
//
(* ****** ****** *)

#staload "./SATS/intrange.sats"

(* ****** ****** *)
//
#staload "./SATS/R34factor.sats"
(*
#staload _ = "./DATS/R34factor.dats"
*)
//
(* ****** ****** *)
//
#staload "./SATS/R34vector.sats"
#staload _ = "./DATS/R34vector.dats"
//
(* ****** ****** *)
//
#staload "./SATS/R34matrix.sats"
#staload _ = "./DATS/R34matrix.dats"
//
(* ****** ****** *)
//
#staload "./SATS/R34dframe.sats"
#staload _ = "./DATS/R34dframe.dats"
//
(* ****** ****** *)
//
//
(* ****** ****** *)

(* end of [mylibies.hats] *)
