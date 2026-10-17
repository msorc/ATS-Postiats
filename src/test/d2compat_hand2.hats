(* ATS2 part of the test of the level-2 dynamic syntax: after the leaf dumpers of d2common1.hats *)
//
fun mkscstextdef (k: int): scstextdef =
  if k mod 2 = 0 then scstextdef_SCSTEXTDEFnone () else scstextdef_SCSTEXTDEFsome ("ext")
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
fun dd_s2varord (x: s2varord): void = let
  fun loop (xs: glist(s2var), i: int): void =
    case+ glist_view (xs) of
    | ~GLcons (x, xs) => ((if i > 0 then dd_ps ","); dd_s2var x; loop (xs, i+1))
    | ~GLnil () => ()
in
  dd_ps "ord["; loop ($UT.lstord2list<s2var> (x), 0); dd_ps "]"
end
fun dd_d2varord (x: d2varord): void = let
  fun loop (xs: glist(d2var), i: int): void =
    case+ glist_view (xs) of
    | ~GLcons (x, xs) => ((if i > 0 then dd_ps ","); dd_d2var x; loop (xs, i+1))
    | ~GLnil () => ()
in
  dd_ps "ord["; loop ($UT.lstord2list<d2var> (x), 0); dd_ps "]"
end
