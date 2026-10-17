#include "share/atspre_staload.hats"
staload "libats/SATS/arena.sats"
staload _ = "libats/DATS/arena.dats"
staload "../pats_utils.sats"
staload _ = "../pats_utils.dats"
dynload "../pats_utils.dats"
%{^
extern atsvoid_t0ype patsopt_PATSHOME_set() ;
extern atstype_ptr patsopt_PATSHOME_get() ;
%}
extern fun patsopt_PATSHOME_set (): void = "ext#patsopt_PATSHOME_set"
extern fun patsopt_PATSHOME_get (): Stropt = "ext#patsopt_PATSHOME_get"

fn cmpint (x: int, y: int): int = compare (x, y)
fun pr (out: FILEref, x: int): void = fprint_int (out, x)

implement main0 () = {
  val () = patsopt_PATSHOME_set ()
  val () = fprint_stropt (stdout_ref, patsopt_PATSHOME_get ()); val () = print_newline ()
  val () = assertloc (llint_make_string ("0x1F") = 31ll)
  val () = assertloc (llint_make_string ("-17") = ~17ll)
  val () = assertloc (intrep_get_base ("0x1F") = 16)
  val () = assertloc (intrep_get_nsfx ("12uLL") = 3u)
  val () = assertloc (float_get_nsfx ("1.5f") = 1u)
  val () = assertloc (double_make_string ("2.5") = 2.5)
  val d = dirpath_append ("a", "b", '/')
  val () = println! ($UNSAFE.castvwtp1{string}(d)); val () = strptr_free (d)
  val xs = lstord_insert<int> (lstord_insert<int> (lstord_sing<int> 3, 1, cmpint), 3, cmpint)
  val xs = lstord_insert<int> (xs, 2, cmpint)
  val dups = lstord_get_dups<int> (xs, cmpint)
  val () = fprintlst<int> (stdout_ref, lstord2list<int> xs, ",", pr); val () = print_newline ()
  val () = fprintlst<int> (stdout_ref, dups, ",", pr); val () = print_newline ()
  val cs = charset_add (charset_add (charset_sing 'b', 'a'), 'c')
  val () = assertloc (charset_is_member (cs, 'a') && ~charset_is_member (cs, 'z'))
  val () = fprint_charset (stdout_ref, cs); val () = print_newline ()
  val s = tostring_fprint<int> ("tmp", pr, 42)
  val () = println! ($UNSAFE.castvwtp1{string}(s)); val () = strptr_free (s)
  val () = fprintopt<int> (stdout_ref, gopt_some 5, pr); val () = print_newline ()
}
