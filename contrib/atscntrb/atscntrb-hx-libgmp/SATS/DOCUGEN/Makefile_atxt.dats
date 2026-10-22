(*
Makefile.atxt: 1(line=1, offs=1) -- 241(line=13, offs=3)
*)

//
staload
STDIO = "libats/libc/SATS/stdio.sats"
staload TIME = "libats/libc/SATS/time.sats"
//
dynload "libatsdoc/dynloadall.dats"
//
staload "libatsdoc/SATS/libatsdoc_atext.sats"
//
#include "utils/atsdoc/HATS/atsdoc_compat.hats"
//

(*
Makefile.atxt: 243(line=14, offs=1) -- 1100(line=44, offs=3)
*)


fun comment
  (x: string): atext = atext_nil ()
// end of [comment]

fun make_entry
  (nm: string): atext = let
//
val ent = sprintf ("\
all_html:: HTML/%s.html\n\
HTML/%s.html: \
  %s_atxt.exe ; ./$< > $@
%s_atxt.txt: %s.atxt ; $(CAT) $< | \
  $(ATSDOC) --prefix __datatok --outcode htmlgendecl_data_atxt.dats > $@
%s_atxt.exe: htmlgendecl_atxt.dats \
  %s_atxt.txt $(DECLATEXT) $(HTMLGENDECL) ; \
  $(PATSCC) $(INCLUDE) $(INCLATS) $(PATSCCFLAGS) -o $@ $< \
    $(DECLATEXT) $(HTMLGENDECL) $(LDPATH) -latsynmark -latsdoc -latslib -latsopt -lgmp
upload_%s:: ; \
  scp HTML/%s.html ats-hwxi,ats-lang@web.sourceforge.net:htdocs/LIBRARY/contrib/libgmp/SATS/DOCUGEN/HTML
clean:: ; $(RMF) %s_atxt.exe
cleanall:: ; $(RMF) HTML/%s.html
", @(nm, nm, nm, nm, nm, nm, nm, nm, nm, nm, nm)
) // end of [val]
//
in
  atext_strptr (ent)
end // end of [make_entry]


(*
Makefile.atxt: 2073(line=112, offs=2) -- 2090(line=112, offs=19)
*)
val __tok1 = make_entry("gmp")
val () = theAtextMap_insert_str ("__tok1", __tok1)

(*
Makefile.atxt: 2417(line=135, offs=1) -- 2491(line=137, offs=3)
*)

implement main0 () = fprint_filsub (stdout_ref, "Makefile_atxt.txt")

