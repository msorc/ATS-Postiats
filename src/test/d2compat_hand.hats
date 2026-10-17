(* the ATS2 part of the test of the level-2 dynamic syntax that is not generated (see d2_gen.py, d2common1.hats) *)
(* ****** ****** *)
//
fun mkloc (k: int): location = let
  var p1: $LOC.position
  var p2: $LOC.position
  val () = $LOC.position_init (p1, $UN.cast{lint} (k), k+1, k)
  val () = $LOC.position_init (p2, $UN.cast{lint} (k+3), k+1, k+3)
  val fil = $FIL.filename_make ("given", "part", "full")
in
  $LOC.location_make_fil_pos_pos (fil, p1, p2)
end
fun mkfilenv (k: int): filenv = $UN.cast{filenv} ($UN.cast{lint} (k))
//
%{^
#include <stdio.h>
#define fflush_stdout() fflush(stdout)
%}
extern fun fflush_stdout (): void = "mac#fflush_stdout"
//
fun mktnode_int (k: int): tnode =
  token_node_T_INT (10, (case+ k mod 3 of 0 => "0" | 1 => "42" | _ => "7"), 0u)
fun mktnode_char (k: int): tnode = token_node_T_CHAR (if k mod 2 = 0 then 'a' else 'Z')
fun mktnode_float (k: int): tnode =
  token_node_T_FLOAT (10, (if k mod 2 = 0 then "3.14" else "2.0"), 0u)
fun mktnode_string (k: int): tnode =
  token_node_T_STRING (if k mod 2 = 0 then "str" else "")
//
fun mkdcstkind (k: int): dcstkind = (
  case+ k mod 6 of
  | 0 => DCKfun | 1 => DCKval | 2 => DCKpraxi | 3 => DCKprfun | 4 => DCKprval | _ => DCKcastfn
)
fun mkfunkind (k: int): funkind = (
  case+ k mod 7 of
  | 0 => FK_fn | 1 => FK_fnx | 2 => FK_fun | 3 => FK_prfn | 4 => FK_prfun | 5 => FK_praxi | _ => FK_castfn
)
fun mkvalkind (k: int): valkind = (
  case+ k mod 4 of
  | 0 => VK_val | 1 => VK_val_pos | 2 => VK_val_neg | _ => VK_prval
)
fun mkcaskind (k: int): caskind = (
  case+ k mod 3 of 0 => CK_case | 1 => CK_case_pos | _ => CK_case_neg
)
fun mkpckind (k: int): pckind = (
  case+ k mod 4 of 0 => PCKcon | 1 => PCKlincon | 2 => PCKfree | _ => PCKunfold
)
fun mkcstsp (k: int): cstsp = (
  case+ k mod 3 of 0 => CSTSPmyfil | 1 => CSTSPmyloc | _ => CSTSPmyfun
)
fun mkmacsynkind (k: int): macsynkind = (
  case+ k mod 3 of 0 => MSKencode | 1 => MSKdecode | _ => MSKxstage
)
fun mkdcstextdef (k: int): dcstextdef = (
  case+ k mod 5 of
  | 0 => dcstextdef_DCSTEXTDEFnone (0)
  | 1 => dcstextdef_DCSTEXTDEFnone (1)
  | 2 => dcstextdef_DCSTEXTDEFsome_ext ("ext")
  | 3 => dcstextdef_DCSTEXTDEFsome_mac ("mac")
  | _ => dcstextdef_DCSTEXTDEFsome_sta ("sta")
)
fun mkhisexp (k: int): hisexp = $UN.cast{hisexp} ($UN.cast{lint} (k + 1))
fun mkfunlab (k: int): funlab = $UN.cast{funlab} ($UN.cast{lint} (k + 1))
