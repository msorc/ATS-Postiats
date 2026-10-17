(* the part of the emit test (cadump.dats, cadump1.dats) that is written once for ATS1 and ATS2, before the staload of pats_ccomp.sats (see ca_gen.py) *)
(* ****** ****** *)
//
// Everything here is in the common subset of ATS1 and ATS2 (the API of the modules has the same names in both).
//
(* ****** ****** *)

fun dd_listvt_s2exp (xs: List0_vt (s2exp)): void = let
  fun loop (xs: List0_vt (s2exp), i: int): void =
    case+ xs of
    | ~list_vt_cons (x, xs) => ((if i > 0 then dd_ps ","); dd_s2exp x; loop (xs, i+1))
    | ~list_vt_nil () => ()
in
  dd_ps "["; loop (xs, 0); dd_ps "]"
end // end of [dd_listvt_s2exp]

fun dd_optvt_hifundec (x: Option_vt (hifundec)): void =
  case+ x of ~Some_vt (e) => (dd_ps "Some_vt("; dd_hifundec e; dd_ps ")") | ~None_vt () => dd_ps "None_vt()"

fun dd_optvt_funclo (x: Option_vt (funclo)): void =
  case+ x of ~Some_vt (e) => (dd_ps "Some_vt("; dd_funclo e; dd_ps ")") | ~None_vt () => dd_ps "None_vt()"

fun dd_optvt_unit (x: Option_vt (int)): void =
  case+ x of ~Some_vt (e) => (dd_ps "Some_vt("; dd_int e; dd_ps ")") | ~None_vt () => dd_ps "None_vt()"

(* ****** ****** *)

fun mksymname (s: string): symbol = $SYM.symbol_make_string (s)
