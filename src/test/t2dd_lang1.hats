(* ATS1: the aliases of the ATS2 spec that do not exist in ATS1, and the leaves *)
typedef intlst = List (int)
typedef stringopt = Option (string)
typedef s2expoptopt = Option (s2expopt)
typedef d2conpair = @(d2con, d2con)
typedef d2conpairopt = Option (d2conpair)
typedef d2conopt = Option (d2con)
typedef d2conlstopt = Option (d2conlst)
typedef syms2rtlstlst = List (syms2rtlst)
typedef locs2explstlst = List (locs2explst)
typedef s2varord = $UT.lstord (s2var)
typedef d2varord = $UT.lstord (d2var)
typedef d2varlstref = ref (d2varlst)
(* ATS1 part of the test of the level-2 dynamic syntax: after the leaf dumpers of d2common1.hats *)
//
fun dd_scstextdef (x: scstextdef): void = (
  case+ x of
  | SCSTEXTDEFnone () => dd_ps "SCSTEXTDEFnone()"
  | SCSTEXTDEFsome (s) => (dd_ps "SCSTEXTDEFsome("; dd_string s; dd_ps ")")
)
fun dd_dcstextdef (x: dcstextdef): void = (
  case+ x of
  | DCSTEXTDEFnone (k) => (dd_ps "DCSTEXTDEFnone("; dd_int k; dd_ps ")")
  | DCSTEXTDEFsome_ext (s) => (dd_ps "DCSTEXTDEFsome_ext("; dd_string s; dd_ps ")")
  | DCSTEXTDEFsome_mac (s) => (dd_ps "DCSTEXTDEFsome_mac("; dd_string s; dd_ps ")")
  | DCSTEXTDEFsome_sta (s) => (dd_ps "DCSTEXTDEFsome_sta("; dd_string s; dd_ps ")")
)
fun dd_hisexp (x: hisexp): void = (dd_ps "hisexp#"; dd_int ($UN.cast2int (x)))
fun dd_funlab (x: funlab): void = (dd_ps "funlab#"; dd_int ($UN.cast2int (x)))
