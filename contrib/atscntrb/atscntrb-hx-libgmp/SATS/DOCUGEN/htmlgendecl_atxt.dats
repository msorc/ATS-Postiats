(*
/home/msorc/install/devel/lang/ats/ATS-Postiats/.claude/worktrees/agent-ad08599bb930c3f62/share/DOCUGEN/htmlgendecl.atxt: 1(line=1, offs=1) -- 1668(line=70, offs=3)
*)

//
staload "utils/libatsynmark/SATS/libatsynmark.sats"
//
// HX-2026-10: the initialization of libatsynmark/libatsopt (ATS1: dynload)
//
val () = libatsynmark_dynloadall ()
//
#include "utils/atsdoc/HATS/pats2xhtmlatxt.hats"
//
dynload "declatext.dats"
staload "declatext.sats"
dynload "htmlgendecl.dats"
staload "htmlgendecl.sats"
//
staload _(*anon*) = "prelude/DATS/list_vt.dats"
staload _(*anon*) = "prelude/DATS/reference.dats"
//
extern
fun
theDeclrepLst_initize (fil: FILEref): void
implement
theDeclrepLst_initize
  (filr) = let
  val cs = libatsynmark_char_list_vt_make_file (filr)
  val replst = charlst_declitemize (0(*sta*), cs)
in
  theDeclrepLst_set (replst)
end // end of [theDeclrepLst]
//
extern
fun srcfilename_get (): string
//
extern
fun htmlgendecl_initize (): void
//
val () = htmlgendecl_initize ()
//
#include "htmlgendecl_data_atxt.dats"
//
#ifndef
IMPLEMENT_HTMLGENDECL_INITIZE
//
implement
htmlgendecl_initize () = let
//
val name = srcfilename_get ()
val filr =
  libatsynmark_fopen_exn (name, "r")
val () = libatsynmark_filename_set_current (name)
val () = theDeclrepLst_initize (filr)
val () = fileref_close (filr)
//
in
  // nothing
end // end of [htmlgendecl_initize]
//
#endif // [IMPLEMENT_HTMLGENDECL_INITIZE]
//
val theDecltitle = theDecltitle_get ()
val theDeclpreamble = theDeclpreamble_get ()
val theDeclpostamble = theDeclpostamble_get ()
//
val theDeclnameLst_menu = theDeclnameLst_make_menu ()
val theDeclitemLst_content = theDeclitemLst_make_content ()
//
val () = theAtextMap_insert_str ("theDeclnameLst_menu", theDeclnameLst_menu)
val () = theAtextMap_insert_str ("theDeclitemLst_content", theDeclitemLst_content)
//

(*
/home/msorc/install/devel/lang/ats/ATS-Postiats/.claude/worktrees/agent-ad08599bb930c3f62/share/DOCUGEN/htmlgendecl.atxt: 1700(line=74, offs=2) -- 1719(line=74, offs=21)
*)
val __tok1 = title(theDecltitle)
val () = theAtextMap_insert_str ("__tok1", __tok1)

(*
/home/msorc/install/devel/lang/ats/ATS-Postiats/.claude/worktrees/agent-ad08599bb930c3f62/share/DOCUGEN/htmlgendecl.atxt: 1789(line=76, offs=2) -- 1806(line=76, offs=19)
*)
val __tok2 = patsyntax_style()
val () = theAtextMap_insert_str ("__tok2", __tok2)

(*
/home/msorc/install/devel/lang/ats/ATS-Postiats/.claude/worktrees/agent-ad08599bb930c3f62/share/DOCUGEN/htmlgendecl.atxt: 1808(line=77, offs=2) -- 1832(line=77, offs=26)
*)
val __tok3 = patscode_jquery_min_js()
val () = theAtextMap_insert_str ("__tok3", __tok3)

(*
/home/msorc/install/devel/lang/ats/ATS-Postiats/.claude/worktrees/agent-ad08599bb930c3f62/share/DOCUGEN/htmlgendecl.atxt: 1834(line=78, offs=2) -- 1862(line=78, offs=30)
*)
val __tok4 = patscode_tryit_bind_all_js()
val () = theAtextMap_insert_str ("__tok4", __tok4)

(*
/home/msorc/install/devel/lang/ats/ATS-Postiats/.claude/worktrees/agent-ad08599bb930c3f62/share/DOCUGEN/htmlgendecl.atxt: 1880(line=82, offs=2) -- 1896(line=82, offs=18)
*)
val __tok5 = H1(theDecltitle)
val () = theAtextMap_insert_str ("__tok5", __tok5)

(*
/home/msorc/install/devel/lang/ats/ATS-Postiats/.claude/worktrees/agent-ad08599bb930c3f62/share/DOCUGEN/htmlgendecl.atxt: 1899(line=84, offs=2) -- 1928(line=84, offs=31)
*)
val __tok6 = atext_strsub(theDeclpreamble)
val () = theAtextMap_insert_str ("__tok6", __tok6)

(*
/home/msorc/install/devel/lang/ats/ATS-Postiats/.claude/worktrees/agent-ad08599bb930c3f62/share/DOCUGEN/htmlgendecl.atxt: 1931(line=86, offs=2) -- 1936(line=86, offs=7)
*)
val __tok7 = HR(2)
val () = theAtextMap_insert_str ("__tok7", __tok7)

(*
/home/msorc/install/devel/lang/ats/ATS-Postiats/.claude/worktrees/agent-ad08599bb930c3f62/share/DOCUGEN/htmlgendecl.atxt: 1939(line=88, offs=2) -- 1977(line=88, offs=40)
*)
val __tok8 = atext_strsub("#theDeclnameLst_menu$")
val () = theAtextMap_insert_str ("__tok8", __tok8)

(*
/home/msorc/install/devel/lang/ats/ATS-Postiats/.claude/worktrees/agent-ad08599bb930c3f62/share/DOCUGEN/htmlgendecl.atxt: 1980(line=90, offs=2) -- 1985(line=90, offs=7)
*)
val __tok9 = HR(2)
val () = theAtextMap_insert_str ("__tok9", __tok9)

(*
/home/msorc/install/devel/lang/ats/ATS-Postiats/.claude/worktrees/agent-ad08599bb930c3f62/share/DOCUGEN/htmlgendecl.atxt: 1988(line=92, offs=2) -- 2029(line=92, offs=43)
*)
val __tok10 = atext_strsub("#theDeclitemLst_content$")
val () = theAtextMap_insert_str ("__tok10", __tok10)

(*
/home/msorc/install/devel/lang/ats/ATS-Postiats/.claude/worktrees/agent-ad08599bb930c3f62/share/DOCUGEN/htmlgendecl.atxt: 2032(line=94, offs=2) -- 2037(line=94, offs=7)
*)
val __tok11 = HR(2)
val () = theAtextMap_insert_str ("__tok11", __tok11)

(*
/home/msorc/install/devel/lang/ats/ATS-Postiats/.claude/worktrees/agent-ad08599bb930c3f62/share/DOCUGEN/htmlgendecl.atxt: 2040(line=96, offs=2) -- 2079(line=96, offs=41)
*)
val __tok12 = atext_filepath("theDeclpostamble.html")
val () = theAtextMap_insert_str ("__tok12", __tok12)

(*
/home/msorc/install/devel/lang/ats/ATS-Postiats/.claude/worktrees/agent-ad08599bb930c3f62/share/DOCUGEN/htmlgendecl.atxt: 2098(line=101, offs=1) -- 2175(line=103, offs=3)
*)

implement main0 () = fprint_filsub (stdout_ref, "htmlgendecl_atxt.txt")

