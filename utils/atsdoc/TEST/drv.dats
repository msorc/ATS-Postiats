(*
** drv.dats: a driver for the API of libatsdoc (libatsdoc_atext.sats): it reads
** commands (one per line) on its stdin and acts on theAtextMap. drv1.dats is the
** same program in ATS1 syntax (for the ATS1 libatsdoc.a): suite.py compares them.
**
**   str NAME TEXT           atext_strcst        sub NAME TEXT         atext_strsub
**   nil NAME / nl NAME      atext_nil / _newline
**   app2 NAME S1 TEXT       atext_appstr2       app3 NAME S1 S2 TEXT  atext_appstr3
**   txt2 NAME N1 N2         atext_apptxt2 (of the atexts named N1, N2)   txt3 NAME N1 N2 N3
**   cat NAME N1 N2 N3       atext_concatxt      cat0 NAME             (empty list)
**   catsep NAME SEP N1 N2 N3   atext_concatxtsep   catsep1 NAME SEP N1
**   catv, catsepv           the same with a list_vt (atext_concatxt_vt: ATS2 only)
**   ptr NAME TEXT / ptr0 NAME / strcstptr NAME TEXT / strsubptr NAME TEXT
**   file NAME PATH          atext_filepath
**   print NAME / search NAME   fprint_atext / theAtextMap_search
**   strsub TEXT / filsub PATH / tostr TEXT   fprint_strsub / fprint_filsub / tostring_strsub
** (in TEXT, \n and \t are the characters; the rest of the line is the text)
*)
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "libats/SATS/arena.sats"
staload _ = "libats/DATS/arena.dats"
staload "libatsdoc/SATS/libatsdoc_atext.sats"
staload SYM = "libatsdoc/SATS/libatsdoc_symbol.sats"
dynload "libatsdoc/dynloadall.dats"

extern fun fld (s: ptr, k: int): string = "ext#rt_fld"
extern fun fld1 (s: ptr, k: int): string = "ext#rt_fld1"
extern fun rt_readline (): ptr = "ext#rt_readline"

fun getatext (name: string): atext = let
  val sym = $SYM.symbol_make_string (name)
  val opt = theAtextMap_search (sym)
in
  case+ opt of
  | ~Some_vt x => x
  | ~None_vt () => atext_strcst ("<none>")
end

fun newstrptr (s: string): Strptr1 = string0_append (s, "")

fun loop (): void = let
  val p = rt_readline ()
in
  if $UN.cast{lint}(p) != 0L then let
      val ls = p
      val cmd = fld1 (ls, 0)
      val l1 = atext_nil ()
      fun g (n: int): atext = getatext (fld1 (ls, n))
      fun ins (n: int, x: atext): void = theAtextMap_insert_str (fld1 (ls, n), x)
    in
      (if cmd = "str" then ins (1, atext_strcst (fld (ls, 2)))
      else if cmd = "sub" then ins (1, atext_strsub (fld (ls, 2)))
      else if cmd = "nil" then ins (1, atext_nil ())
      else if cmd = "nl" then ins (1, atext_newline ())
      else if cmd = "app2" then ins (1, atext_appstr2 (fld1 (ls, 2), fld (ls, 3)))
      else if cmd = "app3" then ins (1, atext_appstr3 (fld1 (ls, 2), fld1 (ls, 3), fld (ls, 4)))
      else if cmd = "txt2" then ins (1, atext_apptxt2 (g 2, g 3))
      else if cmd = "txt3" then ins (1, atext_apptxt3 (g 2, g 3, g 4))
      else if cmd = "cat" then ins (1, atext_concatxt (glist_cons (g 2, glist_cons (g 3, glist_sing (g 4)))))
      else if cmd = "cat0" then ins (1, atext_concatxt (glist_nil ()))
      else if cmd = "catv" then ins (1, atext_concatxt_vt (list_vt_cons (g 2, list_vt_cons (g 3, list_vt_sing (g 4)))))
      else if cmd = "catsep" then ins (1, atext_concatxtsep (glist_cons (g 3, glist_cons (g 4, glist_sing (g 5))), g 2))
      else if cmd = "catsepv" then ins (1, atext_concatxtsep_vt (list_vt_cons (g 3, list_vt_cons (g 4, list_vt_sing (g 5))), g 2))
      else if cmd = "catsep1" then ins (1, atext_concatxtsep (glist_sing (g 3), g 2))
      else if cmd = "ptr" then ins (1, atext_strptr (newstrptr (fld (ls, 2))))
      else if cmd = "ptr0" then ins (1, atext_strptr0 (strptr_null ()))
      else if cmd = "strcstptr" then ins (1, atext_strcstptr (newstrptr (fld (ls, 2))))
      else if cmd = "strsubptr" then ins (1, atext_strsubptr (newstrptr (fld (ls, 2))))
      else if cmd = "file" then ins (1, atext_filepath (fld (ls, 2)))
      else if cmd = "print" then (fprint_atext (stdout_ref, getatext (fld (ls, 1))); print_newline ())
      else if cmd = "search" then let
          val sym = $SYM.symbol_make_string (fld (ls, 1))
          val opt = theAtextMap_search (sym)
        in
          case+ opt of
          | ~Some_vt x => (print "found: "; fprint_atext (stdout_ref, x); print_newline ())
          | ~None_vt () => (print "none"; print_newline ())
        end
      else if cmd = "strsub" then (fprint_strsub (stdout_ref, fld (ls, 1)); print_newline ())
      else if cmd = "filsub" then (fprint_filsub (stdout_ref, fld (ls, 1)); print_newline ())
      else if cmd = "tostr" then let
          val s = tostring_strsub (fld (ls, 1))
        in
          if strptr_isnot_null (s) then (print "tostr: "; print s; print_newline (); strptr_free s)
          else (print "tostr: null"; print_newline (); strptr_free s)
        end
      else (print "?"; print cmd; print_newline ()));
      loop ()
    end
  else ()
end

implement main0 () = loop ()
