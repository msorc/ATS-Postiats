(*
** Obtaining postion-synmarks from STDIN
**
** Author: Hongwei Xi (gmhwxi AT gmail DOT com)
** Start Time: June 5, 2012
*)

(* ****** ****** *)
//
// HX: this example shows how to get position-synmarks
//
// HX-2026-10: no GC (ATS2 port of the ATS1 version of this file)
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)
//
staload
"./../SATS/libatsynmark.sats"
//
(* ****** ****** *)
//
extern
fun
libatsynmark_dynloadall(): void = "ext#libatsynmark_dynloadall"
//
(* ****** ****** *)

fun
fileref_get_tokenlst
  (inp: FILEref): tokenlst_vt = let
//
val cs = libatsynmark_char_list_vt_make_file (inp)
//
val lbf = lexbufobj_make_charlst_vt (cs)
//
val toks = lexbufobj_get_tokenlst (lbf)
//
val ((*void*)) = lexbufobj_free (lbf) 
//
in
  toks
end // end of [fileref_get_tokenlst]

(* ****** ****** *)

implement
main0( argc
     , argv ) = let
//
val () = libatsynmark_dynloadall ()
//
fun loop (
  xs: psynmarklst_vt
) : void = let
  val out = stdout_ref
in
  case+ xs of
  | ~list_vt_cons
      (x, xs) => let
      val () =
        fprint_psynmark (out, x)
      val () = fprint_newline (out)
    in
      loop (xs)
    end // end of [list_vt_cons]
  | ~list_vt_nil () => ()
end // end of [loop]
//
var stadyn: int = 1
val () = (
  if argc >= 2 then let
    val a1 = argv[1]
  in
    if a1 = "-s" then stadyn := 0
    else if a1 = "-d" then stadyn := 1
    else if a1 = "--static" then stadyn := 0
    else if a1 = "--dynamic" then stadyn := 1
    else ((*void*))
  end // end of [if]
) : void // end of [val]
//
val inp = stdin_ref
//
val toks =
  fileref_get_tokenlst (inp)
val psms =
  listize_token2psynmark (toks)
//
val ((*void*)) = list_vt_free (toks)
val ((*void*)) = loop (psms)
//
in
  // nothing
end // end of [main0]

(* ****** ****** *)

(* end of [test02.dats] *)
