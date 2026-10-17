(* ATS2 part of the test of the level-2 dynamic syntax: after the leaf dumpers of d2common1.hats *)
//
fun dd_scstextdef (x: scstextdef): void = (
  case+ scstextdef_view (x) of
  | ~SCSTEXTDEFnone () => dd_ps "SCSTEXTDEFnone()"
  | ~SCSTEXTDEFsome (s) => (dd_ps "SCSTEXTDEFsome("; dd_string s; dd_ps ")")
)
fun dd_dcstextdef (x: dcstextdef): void = (
  case+ dcstextdef_view (x) of
  | ~DCSTEXTDEFnone (k) => (dd_ps "DCSTEXTDEFnone("; dd_int k; dd_ps ")")
  | ~DCSTEXTDEFsome_ext (s) => (dd_ps "DCSTEXTDEFsome_ext("; dd_string s; dd_ps ")")
  | ~DCSTEXTDEFsome_mac (s) => (dd_ps "DCSTEXTDEFsome_mac("; dd_string s; dd_ps ")")
  | ~DCSTEXTDEFsome_sta (s) => (dd_ps "DCSTEXTDEFsome_sta("; dd_string s; dd_ps ")")
)
fun dd_hisexp (x: hisexp): void = (dd_ps "hisexp#"; dd_int ($UN.cast{int} ($UN.cast{lint} (x))))
fun dd_funlab (x: funlab): void = (dd_ps "funlab#"; dd_int ($UN.cast{int} ($UN.cast{lint} (x))))
