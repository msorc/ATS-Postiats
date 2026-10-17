(* ATS1 version of drv.dats (see there): link it with the ATS1 libatsdoc.a and rthelp.c *)
staload _ = "prelude/DATS/list.dats"
staload _ = "prelude/DATS/list_vt.dats"
staload _ = "prelude/DATS/reference.dats"
staload "libc/SATS/stdio.sats"
staload "libatsdoc/SATS/libatsdoc_atext.sats"
staload SYM = "libatsdoc/SATS/libatsdoc_symbol.sats"
dynload "libatsdoc/dynloadall.dats"

extern fun fld (s: string, k: int): string = "rt_fld"
extern fun fld1 (s: string, k: int): string = "rt_fld1"

fun getatext (name: string): atext = let
  val sym = $SYM.symbol_make_string (name)
  val opt = theAtextMap_search (sym)
in
  case+ opt of
  | ~Some_vt x => x
  | ~None_vt () => atext_strcst ("<none>")
end

extern fun rt_readline (): ptr = "rt_readline"
extern castfn p2s (p: ptr): string

fun loop (): void = let
  val p = rt_readline ()
in
  if p > null then let
      val ls = p2s p
      val cmd = fld1 (ls, 0)
    in
      (case+ cmd of
      | "str" => theAtextMap_insert_str (fld1 (ls, 1), atext_strcst (fld (ls, 2)))
      | "sub" => theAtextMap_insert_str (fld1 (ls, 1), atext_strsub (fld (ls, 2)))
      | "nil" => theAtextMap_insert_str (fld1 (ls, 1), atext_nil ())
      | "nl" => theAtextMap_insert_str (fld1 (ls, 1), atext_newline ())
      | "app2" => theAtextMap_insert_str (fld1 (ls, 1), atext_appstr2 (fld1 (ls, 2), fld (ls, 3)))
      | "app3" => theAtextMap_insert_str (fld1 (ls, 1), atext_appstr3 (fld1 (ls, 2), fld1 (ls, 3), fld (ls, 4)))
      | "txt2" => theAtextMap_insert_str (fld1 (ls, 1), atext_apptxt2 (getatext (fld1 (ls, 2)), getatext (fld1 (ls, 3))))
      | "txt3" => theAtextMap_insert_str (fld1 (ls, 1), atext_apptxt3 (getatext (fld1 (ls, 2)), getatext (fld1 (ls, 3)), getatext (fld1 (ls, 4))))
      | "cat" => theAtextMap_insert_str (fld1 (ls, 1), atext_concatxt (list_cons (getatext (fld1 (ls, 2)), list_cons (getatext (fld1 (ls, 3)), list_cons (getatext (fld1 (ls, 4)), list_nil)))))
      | "catv" => theAtextMap_insert_str (fld1 (ls, 1), atext_concatxt (list_cons (getatext (fld1 (ls, 2)), list_cons (getatext (fld1 (ls, 3)), list_cons (getatext (fld1 (ls, 4)), list_nil)))))
      | "catsepv" => theAtextMap_insert_str (fld1 (ls, 1), atext_concatxtsep (list_cons (getatext (fld1 (ls, 3)), list_cons (getatext (fld1 (ls, 4)), list_cons (getatext (fld1 (ls, 5)), list_nil))), getatext (fld1 (ls, 2))))
      | "cat0" => theAtextMap_insert_str (fld1 (ls, 1), atext_concatxt (list_nil))
      | "catsep" => theAtextMap_insert_str (fld1 (ls, 1), atext_concatxtsep (list_cons (getatext (fld1 (ls, 3)), list_cons (getatext (fld1 (ls, 4)), list_cons (getatext (fld1 (ls, 5)), list_nil))), getatext (fld1 (ls, 2))))
      | "catsep1" => theAtextMap_insert_str (fld1 (ls, 1), atext_concatxtsep (list_cons (getatext (fld1 (ls, 3)), list_nil), getatext (fld1 (ls, 2))))
      | "ptr" => theAtextMap_insert_str (fld1 (ls, 1), atext_strptr (sprintf ("%s", @(fld (ls, 2)))))
      | "ptr0" => theAtextMap_insert_str (fld1 (ls, 1), atext_strptr0 (strptr_null ()))
      | "strcstptr" => theAtextMap_insert_str (fld1 (ls, 1), atext_strcstptr (sprintf ("%s", @(fld (ls, 2)))))
      | "strsubptr" => theAtextMap_insert_str (fld1 (ls, 1), atext_strsubptr (sprintf ("%s", @(fld (ls, 2)))))
      | "file" => theAtextMap_insert_str (fld1 (ls, 1), atext_filepath (fld (ls, 2)))
      | "print" => (fprint_atext (stdout_ref, getatext (fld (ls, 1))); print_newline ())
      | "search" => let
          val sym = $SYM.symbol_make_string (fld (ls, 1))
          val opt = theAtextMap_search (sym)
        in
          case+ opt of
          | ~Some_vt x => (print "found: "; fprint_atext (stdout_ref, x); print_newline ())
          | ~None_vt () => (print "none"; print_newline ())
        end
      | "strsub" => (fprint_strsub (stdout_ref, fld (ls, 1)); print_newline ())
      | "filsub" => (fprint_filsub (stdout_ref, fld (ls, 1)); print_newline ())
      | "tostr" => let
          val s = tostring_strsub (fld (ls, 1))
        in
          if strptr_isnot_null (s) then (print "tostr: "; print s; print_newline (); strptr_free s)
          else (print "tostr: null"; print_newline (); strptr_free (s))
        end
      | _ => (print "?"; print cmd; print_newline ()));
      loop ()
    end
  else ()
end

implement main () = loop ()
