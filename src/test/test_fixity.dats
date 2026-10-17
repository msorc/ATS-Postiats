#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "libats/SATS/arena.sats"
staload _ = "libats/DATS/arena.dats"
staload FIL = "../pats_filename.sats"
staload LOC = "../pats_location.sats"
staload "../pats_fixity.sats"
staload _ = "../pats_fixity_fxty.dats"
dynload "../pats_utils.dats"
dynload "../pats_symbol.dats"
dynload "../pats_filename.dats"
dynload "../pats_location.dats"
dynload "../pats_error.dats"
dynload "../pats_fixity_prec.dats"
dynload "../pats_fixity_fxty.dats"
implement $FIL.pkgsrcname_relocatize (given, ngurl) = given

fn locf (x: string): $LOC.location = $LOC.location_dummy

fn cat (a: string, b: string): string = let
  val s = string0_append (a, b)
  val r = the_garena_strdup ($UN.strptr2string s)
  val () = strptr_free (s)
in r end

fun join (xs: glist(string)): string =
  case+ glist_view (xs) of
  | ~GLnil () => ""
  | ~GLcons (x, xs) => cat (cat (" ", x), join xs)

fn appf (loc: $LOC.location, opr: string, loc2: $LOC.location, xs: glist(string)): string =
  cat (cat (cat ("(", opr), join xs), ")")

implement main0 () = {
  val add = fxopr_make<string> (locf, appf, "+", fxty_inf (prec_make_int 50, ASSOClft))
  val mul = fxopr_make<string> (locf, appf, "*", fxty_inf (prec_make_int 60, ASSOClft))
  val neg = fxopr_make<string> (locf, appf, "~", fxty_pre (prec_make_int 100))
  val app = fxitm_app<string> ($LOC.location_dummy, @($UN.cast{ptr}(0), lam (env, f, x) => fxitm_FXITMatm<string> (appf ($LOC.location_dummy, f, $LOC.location_dummy, glist_sing x))))
  val a = fxitm_FXITMatm<string> "a" and b = fxitm_FXITMatm<string> "b" and c = fxitm_FXITMatm<string> "c"
  // a + b * c
  val xs = glist_cons (a, glist_cons (add, glist_cons (b, glist_cons (mul, glist_sing c))))
  val r = fixity_resolve<string> ($LOC.location_dummy, locf, app, xs)
  val () = println! (r)
  // a * b + ~ c
  val xs = glist_cons (a, glist_cons (mul, glist_cons (b, glist_cons (add, glist_cons (neg, glist_sing c)))))
  val r = fixity_resolve<string> ($LOC.location_dummy, locf, app, xs)
  val () = println! (r)
  // a b + c  (application)
  val xs = glist_cons (a, glist_cons (b, glist_cons (add, glist_sing c)))
  val r = fixity_resolve<string> ($LOC.location_dummy, locf, app, xs)
  val () = println! (r)
  val () = fprint_fxty (stdout_ref, fxty_inf (prec_make_int 5, ASSOCnon)); val () = print_newline ()
  val () = assertloc (compare_prec_prec (app_prec, select_prec) = ~1)
}
