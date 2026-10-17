#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "libats/SATS/arena.sats"
staload _ = "libats/DATS/arena.dats"
staload SYM = "../pats_symbol.sats"
staload "../pats_filename.sats"
staload _ = "../pats_utils.dats"
dynload "../pats_utils.dats"
dynload "../pats_symbol.dats"
dynload "../pats_filename.dats"
%{^
extern atsvoid_t0ype patsopt_PATSHOMELOCS_set() ;
%}
extern fun patsopt_PATSHOMELOCS_set (): void = "ext#patsopt_PATSHOMELOCS_set"
// stub for pats_filename_reloc.dats
implement pkgsrcname_relocatize (given, ngurl) = given

implement main0 () = {
  val () = patsopt_PATSHOMELOCS_set ()
  val p = path_normalize ("a/b/../c/./d.dats")
  val () = println! (p)
  val p = path_normalize ("../x/y/../../z")
  val () = println! (p)
  val f = filename_make ("./foo.sats", "./foo.sats", "/tmp/foo.sats")
  val () = fprint_filename_full (stdout_ref, f); val () = print_newline ()
  val () = assertloc (filename_is_sats f && ~filename_is_dats f)
  val () = assertloc (filename_is_dummy (filename_dummy) && filename_isnot_dummy (f))
  val () = assertloc (givename_get_ngurl ("{$PATSHOME}/x.sats") = 11)
  val () = assertloc (givename_srchknd ("./a") = 0 && givename_srchknd ("$PATSHOMELOCS/a/b") = 1)
  val () = assertloc (eq_filename_filename (f, f) && compare_filename_filename (f, filename_stdin) <> 0)
  val (pf | ()) = the_filenamelst_push (f)
  val () = assertloc (eq_filename_filename (filename_get_current (), f))
  val () = fprint_the_filenamelst (stdout_ref)
  val () = the_filenamelst_pop (pf | )
  val () = assertloc (filename_is_dummy (filename_get_current ()))
  val () = the_pathlst_ppush ("/usr/include")
  val opt = filenameopt_make_relative ("stdio.h", given2) where { var given2: string }
  val () = (case+ opt of ~Some_vt (f) => fprint_filename_full (stdout_ref, f) | ~None_vt () => print "none"); val () = print_newline ()
  val opt = filenameopt_make_local ("test_filename.dats")
  val () = (case+ opt of ~Some_vt (f) => fprint_filename_full (stdout_ref, f) | ~None_vt () => print "none"); val () = print_newline ()
  val () = print_pathlst (the_PATSHOMELOCS_get_pathlst ()); val () = print_newline ()
  val ful = filename_merge ("/a/b/c.dats", "d.sats")
  val () = println! ($UN.strptr2string ful); val () = strptr_free (ful)
}
