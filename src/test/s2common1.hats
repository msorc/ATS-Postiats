(* the part of the test of the level-2 static syntax (s2dump.dats, s2dump1.dats) that is written once for ATS1 and ATS2, before the generated dumpers (see s2_gen.py) *)
(* ****** ****** *)
//
// Everything here is in the common subset of ATS1 and ATS2: the API of pats_staexp2.sats has the same names in both.
// The including driver provides: dd_out, the staload aliases $SYM $LAB $LOC $FIL $STMP $INT $CNTR $EFF $UT $S1 $GLOB,
// the constructors K_x (s2compat_gen.hats) and the language specific part (s2glue2_*.hats / s2glue1_*.hats).
//
(* ****** ****** *)

fun dd_ps (s: string): void = fprint_string (dd_out, s)
fun dd_nl (): void = fprint_newline (dd_out)
fun dd_flush (): void = fflush_stdout ()

fun dd_int (x: int): void = fprint_int (dd_out, x)
fun dd_bool (x: bool): void = fprint_bool (dd_out, x)
fun dd_char (x: char): void = fprint_char (dd_out, x)
fun dd_string (x: string): void = (dd_ps "\""; fprint_string (dd_out, x); dd_ps "\"")
fun dd_symbol (x: symbol): void = $SYM.fprint_symbol (dd_out, x)
fun dd_label (x: label): void = $LAB.fprint_label (dd_out, x)
fun dd_location (x: location): void = $LOC.fprint_location (dd_out, x)
fun dd_filename (x: filename): void = $FIL.fprint_filename_full (dd_out, x)
fun dd_stamp (x: stamp): void = $STMP.fprint_stamp (dd_out, x)
fun dd_count (x: count): void = $CNTR.fprint_count (dd_out, x)
fun dd_intinf (x: intinf): void = $INT.fprint_intinf (dd_out, x)
fun dd_funclo (x: funclo): void = fprint_funclo (dd_out, x)
fun dd_effset (x: effset): void = $EFF.fprint_effset (dd_out, x)
fun dd_Stropt (x: Stropt): void = $UT.fprint_stropt (dd_out, x)
fun dd_e1xp (x: e1xp): void = fprint_e1xp (dd_out, x)
fun dd_filenv (x: filenv): void = dd_ps "filenv(...)"

(* ****** ****** *)
//
// the short forms of the cells (identity: name and stamp)
//
fun dd_s2cst (x: s2cst): void = (dd_symbol (s2cst_get_sym x); dd_ps "#"; dd_stamp (s2cst_get_stamp x))
fun dd_s2var (x: s2var): void = (dd_symbol (s2var_get_sym x); dd_ps "#"; dd_stamp (s2var_get_stamp x))
fun dd_s2Var (x: s2Var): void = (dd_ps "V"; dd_count (s2Var_get_cnt x); dd_ps "#"; dd_stamp (s2Var_get_stamp x))
fun dd_s2hole (x: s2hole): void = (dd_ps "H#"; dd_stamp (s2hole_get_stamp x))
fun dd_d2con (x: d2con): void = (dd_symbol (d2con_get_sym x); dd_ps "#"; dd_stamp (d2con_get_stamp x))
fun dd_s2rtdat (x: s2rtdat): void = (dd_symbol (s2rtdat_get_sym x); dd_ps "#"; dd_stamp (s2rtdat_get_stamp x))
fun dd_s2ctxt (x: s2ctxt): void = dd_ps "s2ctxt(...)"

(* ****** ****** *)

fun mksym (k: int): symbol = $SYM.symbol_make_string (
  case+ k mod 7 of 0 => "a" | 1 => "bb" | 2 => "+" | 3 => "x_y" | 4 => "z" | 5 => "S" | _ => "w1"
)
fun mklab (k: int): label = if k mod 2 = 0 then $LAB.label_make_int (k) else $LAB.label_make_string ("lab")
fun mkfil (k: int): filename = $FIL.filename_make ("g", "p", "f")
fun mkchr (k: int): char = if k mod 2 = 0 then 'a' else 'Z'
fun mkintinf (k: int): intinf = $INT.intinf_make_int (k)
fun mkstamp (k: int): stamp = $STMP.tmplab_stamp_make ()
fun mkfunclo (k: int): funclo = (
  case+ k mod 4 of 0 => FUNCLOfun () | 1 => FUNCLOclo (1) | 2 => FUNCLOclo (0) | _ => FUNCLOclo (~1)
)
fun mkeffset (k: int): effset = (
  case+ k mod 5 of
  | 0 => $EFF.effset_nil | 1 => $EFF.effset_all | 2 => $EFF.effset_ntm
  | 3 => $EFF.effset_union ($EFF.effset_exn, $EFF.effset_wrt)
  | _ => $EFF.effset_add ($EFF.effset_nil, $EFF.effect_ref)
)
fun mke1xp (k: int): e1xp = e1xp_int (mkloc (k), k)


(* ****** ****** *)
//
// (slice 2) the names of the pervasive constants, an optional int
//
fun mksymname (s: string): symbol = $SYM.symbol_make_string (s)
fun dd_optvt_int (x: Option_vt (int)): void =
  case+ x of ~Some_vt (i) => (dd_ps "Some_vt("; dd_int i; dd_ps ")") | ~None_vt () => dd_ps "None_vt()"
