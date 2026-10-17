(*
** for highlighting/xreferencing ATS2 code
*)

(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of the ATS1 version of this file)
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

#define ATS_DYNLOADFLAG 0 // no initialization

(* ****** ****** *)
//
staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"
//
(* ****** ****** *)
//
staload
"utils/libatsynmark/SATS/libatsynmark.sats"
staload _(*anon*) =
"utils/libatsynmark/DATS/libatsynmark_psynmark.dats"
//
(* ****** ****** *)

staload "./../SATS/pats2xhtml.sats"

(* ****** ****** *)

local

implement
psynmark_process<>
  (psm, putc) =
(
  psynmark_process_xhtml_bground (psm, putc)
) // end of [psynmark_process<>]

in (* in of [local] *)

implement
pats2xhtml_level1_charlst
  (stadyn, cs, putc) = let
//
val cs2 = list_vt_copy (cs)
val lbf = lexbufobj_make_charlst_vt (cs2)
val psmss = lexbufobj_level1_psynmarkize (stadyn, lbf)
//
in
//
charlst_psynmarklstlst_process<> (cs, psmss, putc)
//
end // end of [pats2xhtml_level1_charlst]

(* ****** ****** *)

implement
pats2xhtml_level1_fileref
  (stadyn, inp, putc) = let
  val charlst = fileref2charlst (inp)
in
  pats2xhtml_level1_charlst (stadyn, charlst, putc)
end // end of [pats2xhtml_level1_fileref]

(* ****** ****** *)

end // end of [local]

(* ****** ****** *)

(* end of [pats2xhtml_level1.dats] *)
