(*
** For writing ATS code
** that translates into Clojure
*)

(* ****** ****** *)
//
// HX-2014-07
//
(* ****** ****** *)
//
staload "./basics_clj.sats"
staload _ = "./DATS/basics.dats"
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
//
staload "./SATS/print.sats"
staload "./SATS/filebas.sats"
//
staload _(*anon*) = "./DATS/print.dats"
//
(* ****** ****** *)

staload "./SATS/gprint.sats"
staload _(*anon*) = "./DATS/gprint.dats"

(* ****** ****** *)
//
(*
staload "./SATS/intrange.sats"
staload _(*anon*) = "./DATS/intrange.dats"
*)
//
(* ****** ****** *)
//
staload "./SATS/CLJlist.sats"
//
(* ****** ****** *)
//
staload "./SATS/list_vt.sats"
staload _ = "./DATS/list_vt.dats"
//
staload "./SATS/stream_vt.sats"
//
(* ****** ****** *)

staload "./SATS/intrange.sats"

(* ****** ****** *)
//
staload "./SATS/reference.sats"
//
(* ****** ****** *)
//
//
staload _(*anon*) = "./DATS/CLJlist.dats"
//
//
(* ****** ****** *)
//
staload "./SATS/slistref.sats" // list-based stack
staload "./SATS/qlistref.sats" // list-based queue
//
(* ****** ****** *)


(* ****** ****** *)

(* end of [staloadall.hats] *)
