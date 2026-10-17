(*
** The test of pats_histaexp, in the common subset of ATS1 and ATS2: the leaf dumpers. Included by hsdrv1.dats / hsdrv2.dats after
** the staloads and before the language specific layer (hs_hand1.hats / hs_hand2.hats), the generated one (hs_compat1.hats /
** hs_compat2.hats) and hs_common.hats (the objects, [hs_all]), then the cases (hs_cases.hats).
*)
(* ****** ****** *)

macdef dd_out = stdout_ref
fun dd_ps (s: string): void = fprint_string (dd_out, s)
fun dd_nl (): void = fprint_newline (dd_out)
fun dd_int (x: int): void = fprint_int (dd_out, x)
fun dd_bool (x: bool): void = fprint_bool (dd_out, x)
fun dd_string (x: string): void = (dd_ps "\""; fprint_string (dd_out, x); dd_ps "\"")
fun dd_symbol (x: symbol): void = $SYM.fprint_symbol (dd_out, x)
fun dd_label (x: label): void = $LAB.fprint_label (dd_out, x)
fun dd_funclo (x: funclo): void = fprint_funclo (dd_out, x)
fun dd_s2cst (x: s2cst): void = (dd_symbol (s2cst_get_sym x); dd_ps "#"; $STMP.fprint_stamp (dd_out, s2cst_get_stamp x))
fun dd_s2var (x: s2var): void = (dd_symbol (s2var_get_sym x); dd_ps "#"; $STMP.fprint_stamp (dd_out, s2var_get_stamp x))
fun dd_d2con (x: d2con): void = (dd_symbol (d2con_get_sym x); dd_ps "#"; $STMP.fprint_stamp (dd_out, d2con_get_stamp x))
fun dd_s2exp (x: s2exp): void = fprint_s2exp (dd_out, x)
fun dd_s2explst (xs: s2explst): void = fprint_s2explst (dd_out, xs)
fun dd_s2zexp (x: s2zexp): void = fprint_s2zexp (dd_out, x)
fun dd_tyreckind (x: tyreckind): void = fprint_tyreckind (dd_out, x)
fun dd_funlab (x: funlab): void = fprint_funlab (dd_out, x)
%{^
#include <stdio.h>
#define fflush_stdout() fflush(stdout)
%}
extern fun fflush_stdout (): void = "mac#fflush_stdout"

(* ****** ****** *)

fun dd_flush (): void = fflush_stdout ()

(* ****** ****** *)

fun hs_sym (k: int): symbol = $SYM.symbol_make_string (
  case+ k mod 5 of 0 => "a" | 1 => "bb" | 2 => "+" | 3 => "x_y" | _ => "S"
)
fun hs_lab (k: int): label = if k mod 2 = 0 then $LAB.label_make_int (k) else $LAB.label_make_string ("lab")

