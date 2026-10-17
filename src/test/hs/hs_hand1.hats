(* the ATS1 part of the test of pats_histaexp that is not generated (see hs_gen.py, hs_common.hats) *)
(* ****** ****** *)

(* ****** ****** *)

typedef stringopt = Option (string)
fun hs_none (): stringopt = None ()
fun hs_some (s: string): stringopt = Some (s)
fun dd_stringopt (x: stringopt): void = (
  case+ x of
  | None () => dd_ps "None"
  | Some (s) => (dd_ps "Some("; dd_string s; dd_ps ")")
)

fun hs_tk (k: int): tyreckind = (
  case+ k mod 5 of
  | 0 => TYRECKINDbox ()
  | 1 => TYRECKINDbox_lin ()
  | 2 => TYRECKINDflt0 ()
  | 3 => TYRECKINDflt1 ($STMP.tmplab_stamp_make ())
  | _ => TYRECKINDflt_ext ("nm")
)

fun hs_cst_named (id: symbol, s2t: s2rt): s2cst =
  s2cst_make (id, $LOC.location_dummy, $FIL.filename_dummy, s2t, Some (None ()), false, false, None (), None (), list_nil (), None ())
fun hs_cname (k: int): symbol = $SYM.symbol_make_string (
  case+ k of 0 => "hs_c0" | 1 => "hs_c1" | 2 => "hs_c2" | 3 => "hs_c3" | 4 => "hs_c4" | 5 => "hs_c5" | 6 => "hs_c6" | 7 => "hs_c7" | _ => "hs_c8"
)
fun hs_cst (k: int, s2t: s2rt): s2cst = hs_cst_named (hs_cname (k), s2t)
fun hs_dcon (k: int, c: s2cst): d2con =
  d2con_make ($LOC.location_dummy, $FIL.filename_dummy, hs_sym (k), c, 0, list_nil (), 0, list_nil (), None ())

fun hs_name (h: hisexp): hitnam = h.hisexp_name
fun hs_same (a: hisexp, b: hisexp): bool = ($UN.cast2ptr (a) = $UN.cast2ptr (b))
