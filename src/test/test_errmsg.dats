#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "libats/SATS/arena.sats"
staload _ = "libats/DATS/arena.dats"
staload FIL = "../pats_filename.sats"
staload LOC = "../pats_location.sats"
staload "../pats_errmsg.sats"
staload _ = "../pats_errmsg.dats"
dynload "../pats_utils.dats"
dynload "../pats_symbol.dats"
dynload "../pats_filename.dats"
dynload "../pats_location.dats"
implement $FIL.pkgsrcname_relocatize (given, ngurl) = given
implement prerr_FILENAME<> () = prerr "test_errmsg"

implement main0 () = {
  val loc = $LOC.location_filename_origin ($FIL.filename_stdin)
  val () = prerr_ERROR_beg ()
  val () = prerr_error3_loc (loc)
  val () = prerr_interror_loc (loc)
  val () = prerr_warning1_loc (loc)
  val () = prerr_newline ()
  val () = prerr_ERROR_end ()
}
