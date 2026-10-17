(* the part of the macro test (m2dump.dats, m2dump1.dats) that is written once for ATS1 and ATS2, after the dumpers *)
(* ****** ****** *)
//
fun dd_optvt_d2var (x: Option_vt (d2var)): void =
  case+ x of ~Some_vt (v) => (dd_ps "Some_vt("; dd_d2var v; dd_ps ")") | ~None_vt () => dd_ps "None_vt()"
fun dd_optvt_s2var (x: Option_vt (s2var)): void =
  case+ x of ~Some_vt (v) => (dd_ps "Some_vt("; dd_s2var v; dd_ps ")") | ~None_vt () => dd_ps "None_vt()"
fun dd_optvt_m2val (x: Option_vt (m2val)): void =
  case+ x of ~Some_vt (v) => (dd_ps "Some_vt("; dd_m2val v; dd_ps ")") | ~None_vt () => dd_ps "None_vt()"
//
fun mkdsym (loc: location, name: string): d2sym = d2sym_make (loc, d0ynq_none (loc), $SYM.symbol_make_string (name), LN_d2pitmlst ())
fun mkdsymq (loc: location, name: string): d2sym = d2sym_make (loc, mkdq1 (1), $SYM.symbol_make_string (name), LN_d2pitmlst ())
//
(* ****** ****** *)
