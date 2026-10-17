(* ATS2 leaf types of the level-3 test (t3_gen.py): the lists of pattern constraints, before the generated dumpers *)
(* ****** ****** *)
fun mkp2atcst0 (k: int): p2atcst = (
  case+ k mod 10 of
  | 0 => p2atcst_P2TCany ()
  | 1 => p2atcst_P2TCempty ()
  | 2 => p2atcst_P2TCint (mkintinf (k))
  | 3 => p2atcst_P2TCbool (k mod 2 = 0)
  | 4 => p2atcst_P2TCchar (mkchr (k))
  | 5 => p2atcst_P2TCstring ("s")
  | 6 => p2atcst_P2TCintc ($INT.intinfset_add ($INT.intinfset_sing (mkintinf (1)), mkintinf (k)))
  | 7 => p2atcst_P2TCcharc ($UT.charset_add ($UT.charset_sing ('a'), mkchr (k)))
  | 8 => p2atcst_P2TCfloat ("1.5")
  | _ => p2atcst_P2TCrec (0, glist_cons<labp2atcst> (labp2atcst_new (mklab (2), p2atcst_P2TCint (mkintinf (k))), glist_nil ()))
)
fun mkp2atcstlst (k: int): p2atcstlst =
  glist_cons<p2atcst> (mkp2atcst0 (k), glist_cons<p2atcst> (mkp2atcst0 (k+1), glist_nil ()))
fun dd_p2atcstlst (x: p2atcstlst): void = fprint_p2atcstlst (dd_out, x)
