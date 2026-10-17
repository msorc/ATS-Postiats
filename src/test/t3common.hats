(* the part of the level-3 test (t3dump.dats, t3dump1.dats) that is written once for ATS1 and ATS2, after the generated dumpers *)
(* ****** ****** *)
fun dd_listvt_s2exp (xs: List0_vt (s2exp)): void = let
  fun loop (xs: List0_vt (s2exp), i: int): void =
    case+ xs of
    | ~list_vt_cons (x, xs) => ((if i > 0 then dd_ps ","); dd_s2exp x; loop (xs, i+1))
    | ~list_vt_nil () => ()
in
  dd_ps "["; loop (xs, 0); dd_ps "]"
end // end of [dd_listvt_s2exp]
fun dd_listvt_s3itm (xs: List0_vt (s3itm)): void = let
  fun loop (xs: List0_vt (s3itm), i: int): void =
    case+ xs of
    | ~list_vt_cons (x, xs) => ((if i > 0 then dd_ps ","); fprint_s3itm (dd_out, x); loop (xs, i+1))
    | ~list_vt_nil () => ()
in
  dd_ps "["; loop (xs, 0); dd_ps "]"
end // end of [dd_listvt_s3itm]
fun dd_optvt_s2explst (x: Option_vt (s2explst)): void =
  case+ x of ~Some_vt (v) => (dd_ps "Some_vt("; dd_s2explst v; dd_ps ")") | ~None_vt () => dd_ps "None_vt()"
fun dd_optvt_p3atlst (x: Option_vt (p3atlst)): void =
  case+ x of ~Some_vt (v) => (dd_ps "Some_vt("; dd_p3atlst v; dd_ps ")") | ~None_vt () => dd_ps "None_vt()"
fun dd_optvt_lamlp (x: Option_vt (lamlp)): void =
  case+ x of ~Some_vt (v) => (dd_ps "Some_vt("; dd_lamlp v; dd_ps ")") | ~None_vt () => dd_ps "None_vt()"
fun dd_optvt_metfun (x: Option_vt (@(s2exp, s2rtlst))): void =
  case+ x of
  | ~Some_vt (v) => (dd_ps "Some_vt("; dd_s2exp (v.0); dd_ps ","; dd_s2rtlst (v.1); dd_ps ")")
  | ~None_vt () => dd_ps "None_vt()"
fun dd_optvt_pfobj (x: Option_vt (pfobj)): void =
  case+ x of
  | ~Some_vt (o) => (
    case+ o of ~PFOBJ (d2v, e1, e2, e3) => (dd_ps "PFOBJ("; dd_d2var d2v; dd_ps ","; dd_s2exp e1; dd_ps ","; dd_s2exp e2; dd_ps ","; dd_s2exp e3; dd_ps ")")
    )
  | ~None_vt () => dd_ps "None_vt()"
fun dd_listvt_s2cstx (xs: List0_vt (s2cst)): void = dd_listvt_s2cst (xs)
fun mksymname (s: string): symbol = $SYM.symbol_make_string (s)
fun mkeffect (k: int): effect = (
  case+ k mod 4 of 0 => $EFF.effect_exn | 1 => $EFF.effect_ntm | 2 => $EFF.effect_ref | _ => $EFF.effect_wrt
)
