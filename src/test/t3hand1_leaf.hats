(* ATS1 leaf types of the level-3 test (t3_gen.py): the lists of pattern constraints, before the generated dumpers *)
(* ****** ****** *)
fun mkp2atcst0 (k: int): p2atcst = (
  case+ k mod 10 of
  | 0 => P2TCany ()
  | 1 => P2TCempty ()
  | 2 => P2TCint (mkintinf (k))
  | 3 => P2TCbool (k mod 2 = 0)
  | 4 => P2TCchar (mkchr (k))
  | 5 => P2TCstring ("s")
  | 6 => P2TCintc ($INT.intinfset_add ($INT.intinfset_sing (mkintinf (1)), mkintinf (k)))
  | 7 => P2TCcharc ($UT.charset_add ($UT.charset_sing ('a'), mkchr (k)))
  | 8 => P2TCfloat ("1.5")
  | _ => P2TCrec (0, list_cons (LABP2ATCST (mklab (2), P2TCint (mkintinf (k))), list_nil ()))
)
fun mkp2atcstlst (k: int): p2atcstlst =
  list_cons (mkp2atcst0 (k), list_cons (mkp2atcst0 (k+1), list_nil ()))
fun dd_p2atcstlst (x: p2atcstlst): void = fprint_p2atcstlst (dd_out, x)
typedef lamlplst = List (lamlp)
