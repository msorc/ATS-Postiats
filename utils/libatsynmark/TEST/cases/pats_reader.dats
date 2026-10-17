(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-2013 Hongwei Xi, ATS Trustful Software, Inc.
** All rights reserved
**
** ATS is free software;  you can  redistribute it and/or modify it under
** the terms of  the GNU GENERAL PUBLIC LICENSE (GPL) as published by the
** Free Software Foundation; either version 3, or (at  your  option)  any
** later version.
** 
** ATS is distributed in the hope that it will be useful, but WITHOUT ANY
** WARRANTY; without  even  the  implied  warranty  of MERCHANTABILITY or
** FITNESS FOR A PARTICULAR PURPOSE.  See the  GNU General Public License
** for more details.
** 
** You  should  have  received  a  copy of the GNU General Public License
** along  with  ATS;  see the  file COPYING.  If not, please write to the
** Free Software Foundation,  51 Franklin Street, Fifth Floor, Boston, MA
** 02110-1301, USA.
*)

(* ****** ****** *)
//
// Author: Hongwei Xi
// Authoremail: gmhwxi AT gmail DOT com
// Start Time: March, 2011
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"
staload "libats/libc/SATS/stdio.sats"

(* ****** ****** *)

staload "./pats_reader.sats"

(* ****** ****** *)

#define KIND_FILP 0
#define KIND_GETC 1
#define KIND_STRING 2
#define KIND_CHARLST 3

(* ****** ****** *)

vtypedef
freader =
$extype_struct
"pats_reader_struct" of {
  rkind= int, rptr= ptr, ridx= size_t
} (* end of [freader] *)

assume reader_vt0ype = freader

(* ****** ****** *)

extern
fun
reader_set
(
  r: &reader? >> reader, knd: int, p: ptr
) : void = "mac#patsopt_reader_set"

%{^
#define patsopt_reader_set(r, knd, p) \
  do { ((pats_reader_struct*)(r))->rkind = (knd) ; \
       ((pats_reader_struct*)(r))->rptr = (p) ; \
       ((pats_reader_struct*)(r))->ridx = 0 ; } while (0)
%} // end of [%{^]

(* ****** ****** *)

implement
reader_initize_filp
  (r, fp) = reader_set (r, KIND_FILP, $UN.cast{ptr}(fp))
// end of [reader_initize_filp]

implement
reader_initize_getc
  (r, getc) = reader_set (r, KIND_GETC, $UN.castvwtp0{ptr}(getc))
// end of [reader_initize_getc]

implement
reader_initize_string
  (r, inp) = reader_set (r, KIND_STRING, $UN.cast{ptr}(inp))
// end of [reader_initize_string]

implement
reader_initize_charlst_vt
  (r, inp) = reader_set (r, KIND_CHARLST, $UN.castvwtp0{ptr}(inp))
// end of [reader_initize_charlst_vt]

(* ****** ****** *)

implement
reader_get_char (r) = let
  val knd = r.rkind
in
//
case+ 0 of
| _ when knd = KIND_FILP =>
    fgetc0 ($UN.cast{FILEref}(r.rptr))
| _ when knd = KIND_GETC => let
    val f = $UN.castvwtp0{() -<lincloptr1> int}(r.rptr)
    val i = f ()
    val _ = $UN.castvwtp0{ptr}(f)
  in
    i
  end // end of [KIND_GETC]
| _ when knd = KIND_STRING => let
    val p = $UN.cast{ptr}(r.rptr)
    val i = r.ridx
    val c = $UN.ptr0_get<char> (ptr0_add_guint<char> (p, i))
  in
    if (c != '\000')
      then let
        val () = r.ridx := succ(i)
      in
        char2int0 (c)
      end // end of [then]
      else ~1 (*EOF*) // end of [else]
  end // end of [KIND_STRING]
| _ (* KIND_CHARLST *) => let
    val cs = $UN.castvwtp0{List0_vt(char)}(r.rptr)
  in
    case+ cs of
    | ~list_vt_cons (c, cs) => let
        val () = r.rptr := $UN.castvwtp0{ptr}(cs)
      in
        uchar2int0 (char2uchar0 (c))
      end // end of [list_vt_cons]
    | ~list_vt_nil () => let
        val () = r.rptr := $UN.castvwtp0{ptr}(list_vt_nil{char}())
      in
        ~1 (*EOF*)
      end // end of [list_vt_nil]
  end // end of [KIND_CHARLST]
//
end // end of [reader_get_char]

(* ****** ****** *)

implement
reader_uninitize (r) = let
  val knd = r.rkind
  val () =
  (
  case+ 0 of
  | _ when knd = KIND_FILP => let
      val () = fileref_close ($UN.cast{FILEref}(r.rptr)) in (*nothing*)
    end
  | _ when knd = KIND_GETC => let
      val f = $UN.castvwtp0{() -<lincloptr1> int}(r.rptr)
    in
      cloptr_free ($UN.castvwtp0{cloptr(void)}(f))
    end
  | _ when knd = KIND_CHARLST => let
      val cs = $UN.castvwtp0{List0_vt(char)}(r.rptr)
    in
      list_vt_free (cs)
    end
  | _ (* KIND_STRING *) => ()
  ) : void
in
  $UN.castvwtp0{void}(r)
end // end of [reader_uninitize]

(* ****** ****** *)

(* end of [pats_reader.dats] *)
