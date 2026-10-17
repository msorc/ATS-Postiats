#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "libats/SATS/arena.sats"
staload _ = "libats/DATS/arena.dats"
staload FIL = "../pats_filename.sats"
staload "../pats_location.sats"
dynload "../pats_utils.dats"
dynload "../pats_symbol.dats"
dynload "../pats_filename.dats"
dynload "../pats_location.dats"
implement $FIL.pkgsrcname_relocatize (given, ngurl) = given

implement main0 () = {
  var p1: position
  var p2: position
  val () = position_init (p1, 0L, 0, 0)
  val () = position_copy (p2, p1)
  val () = position_incby_char (p2, char2int0 'a')
  val () = position_incby_char (p2, char2int0 '\n')
  val () = position_incby_count (p2, 3u)
  val () = assertloc (position_get_nrow (p2) = 1 && position_get_ncol (p2) = 3 && position_get_ntot (p2) = 5L)
  val () = fprint_position (stdout_ref, p2); val () = print_newline ()
  val fil = $FIL.filename_make ("./a.dats", "./a.dats", "/x/a.dats")
  val loc1 = location_make_fil_pos_pos (fil, p1, p2)
  val () = fprint_location (stdout_ref, loc1); val () = print_newline ()
  val loc2 = location_make_fil_pos_pos (fil, p2, p2)
  val loc = location_combine (loc1, loc2)
  val () = fprint_locrange (stdout_ref, loc); val () = print_newline ()
  val () = fprint_location (stdout_ref, location_dummy); val () = print_newline ()
  val () = the_location_pragma_push ()
  val () = the_location_pragma_set (locpragma1_make "x:1")
  val loc3 = location_leftmost (location_make_fil_pos_pos (fil, p1, p2))
  val () = fprint_location (stdout_ref, loc3); val () = print_newline ()
  val () = the_location_pragma_pop ()
  val () = assertloc (location_beg_ntot (loc) = 0L && location_end_ntot (loc) = 5L)
  val () = fprint_line_pragma (stdout_ref, location_rightmost loc)
  val () = fprint2_location (stdout_ref, location_filename_origin fil); val () = print_newline ()
}
