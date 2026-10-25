(*
**
** Some utility functions
** for manipulating the syntax of ATS2
**
** Contributed by Hongwei Xi (gmhwxiATgmailDOTcom)
**
** Start Time: June, 2012
**
*)

(* ****** ****** *)
//
#include "share/atspre_staload.hats"

(* ****** ****** *)

#define ATS_DYNLOADFLAG 0 // no initialization

(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of the ATS1 version of this file)
//
(* ****** ****** *)

staload
UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"
//
(* ****** ****** *)


(* ****** ****** *)

staload "./../SATS/libatsynmark.sats"

(* ****** ****** *)

local

#define
SMkeyword_beg "<span class=\"keyword\">"
#define SMkeyword_end "</span>"
#define
SMcomment_beg "<span class=\"comment\">"
#define SMcomment_end "</span>"
#define
SMextcode_beg "<span class=\"extcode\">"
#define SMextcode_end "</span>"

#define SMneuexp_beg "<span class=\"neuexp\">"
#define SMneuexp_end "</span>"

#define SMstaexp_beg "<span class=\"staexp\">"
#define SMstaexp_end "</span>"
#define SMprfexp_beg "<span class=\"prfexp\">"
#define SMprfexp_end "</span>"
#define SMdynexp_beg "<span class=\"dynexp\">"
#define SMdynexp_end "</span>"

#define SMstalab_beg "<span class=\"stalab\">"
#define SMstalab_end "</span>"
#define SMdynlab_beg "<span class=\"dynlab\">"
#define SMdynlab_end "</span>"

#define SMdynstr_beg "<span class=\"dynstr\">"
#define SMdynstr_end "</span>"

in (* in-of-local *)

implement
psynmark_process_xhtml_bground
  (psm, putc) = let
//
val @(p, sm, knd) = psm
val isbeg = knd <= 0
//
macdef
fpr_psynmark
  (_beg, _end) = let
  val x = (
    if isbeg then ,(_beg) else ,(_end)
  ) : string // end of [val]
  val _ = fstring_putc (x, putc)
in
  // nothing
end // end of [macdef]
//
in
//
case+ sm of
//
| SMkeyword() =>
    fpr_psynmark (SMkeyword_beg, SMkeyword_end)
| SMcomment() =>
    fpr_psynmark (SMcomment_beg, SMcomment_end)
| SMextcode() =>
    fpr_psynmark (SMextcode_beg, SMextcode_end)
//
| SMneuexp() => fpr_psynmark (SMneuexp_beg, SMneuexp_end)
| SMstaexp() => fpr_psynmark (SMstaexp_beg, SMstaexp_end)
| SMprfexp() => fpr_psynmark (SMprfexp_beg, SMprfexp_end)
| SMdynexp() => fpr_psynmark (SMdynexp_beg, SMdynexp_end)
//
| SMstalab() => fpr_psynmark (SMstalab_beg, SMstalab_end)
| SMdynlab() => fpr_psynmark (SMdynlab_beg, SMdynlab_end)
//
| SMdynstr() => fpr_psynmark (SMdynstr_beg, SMdynstr_end)
//
| _ => ()
//
end // end of [psynmark_process_xhtml_bground]

end // end of [local]

(* ****** ****** *)

local

#define
SMkeyword_beg "<span class=\"patsyntaxkeyword\">"
#define SMkeyword_end "</span>"
#define
SMcomment_beg "<span class=\"patsyntaxcomment\">"
#define SMcomment_end "</span>"
#define
SMextcode_beg "<span class=\"patsyntaxextcode\">"
#define SMextcode_end "</span>"

#define SMneuexp_beg "<span class=\"patsyntaxneuexp\">"
#define SMneuexp_end "</span>"

#define SMstaexp_beg "<span class=\"patsyntaxstaexp\">"
#define SMstaexp_end "</span>"
#define SMprfexp_beg "<span class=\"patsyntaxprfexp\">"
#define SMprfexp_end "</span>"
#define SMdynexp_beg "<span class=\"patsyntaxdynexp\">"
#define SMdynexp_end "</span>"

#define SMstalab_beg "<span class=\"patsyntaxstalab\">"
#define SMstalab_end "</span>"
#define SMdynlab_beg "<span class=\"patsyntaxdynlab\">"
#define SMdynlab_end "</span>"

#define SMdynstr_beg "<span class=\"patsyntaxdynstr\">"
#define SMdynstr_end "</span>"

in (* in of [local] *)

implement
psynmark_process_xhtml_embedded
  (psm, putc) = let
//
val @(p, sm, knd) = psm
val isbeg = knd <= 0
//
macdef
fpr_psynmark
  (_beg, _end) = let
  val x = (
    if isbeg then ,(_beg) else ,(_end)
  ) : string // end of [val]
  val _ = fstring_putc (x, putc)
in
  // nothing
end // end of [macdef]
//
in
//
case+ sm of
//
| SMkeyword() =>
    fpr_psynmark (SMkeyword_beg, SMkeyword_end)
| SMcomment() =>
    fpr_psynmark (SMcomment_beg, SMcomment_end)
| SMextcode() =>
    fpr_psynmark (SMextcode_beg, SMextcode_end)
//
| SMneuexp() => fpr_psynmark (SMneuexp_beg, SMneuexp_end)
| SMstaexp() => fpr_psynmark (SMstaexp_beg, SMstaexp_end)
| SMprfexp() => fpr_psynmark (SMprfexp_beg, SMprfexp_end)
| SMdynexp() => fpr_psynmark (SMdynexp_beg, SMdynexp_end)
//
| SMstalab() => fpr_psynmark (SMstalab_beg, SMstalab_end)
| SMdynlab() => fpr_psynmark (SMdynlab_beg, SMdynlab_end)
//
| SMdynstr() => fpr_psynmark (SMdynstr_beg, SMdynstr_end)
//
| _ => ()
//
end // end of [psynmark_process_xhtml_embedded]

end // end of [local]

(* ****** ****** *)

implement{}
string_pats2xhtmlize
  (stadyn, code) = let
//
val lbf = lexbufobj_make_string (code)
//
val psmss =
  lexbufobj_level1_psynmarkize (stadyn, lbf)
//
val env = libatsynmark_sbuf_make ()
val putc = putc_make (env, libatsynmark_sbuf_putc)
val () =
  string_psynmarklstlst_process<> (code, psmss, putc)
//
in
  libatsynmark_sbuf_takeout (env)
end // end of [string_pats2xhtmlize]

(* ****** ****** *)

implement{}
charlst_pats2xhtmlize
  (stadyn, code) = let
  val sbp = libatsynmark_strptr_make_charlst (code)
  val str = $UN.castvwtp1 {string} (sbp)
  val res = string_pats2xhtmlize<> (stadyn, str)
  val () = strptr_free (sbp)
in
  res
end // end of [charlst_pats2xhtmlize]

(* ****** ****** *)

(* end of [libatsynmark_pats2xhtml.dats] *)
