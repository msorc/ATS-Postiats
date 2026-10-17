(* ATS1 part of the test of the level-2 static syntax: after the leaf dumpers of s2common1.hats *)
//
fun mkscstextdef (k: int): scstextdef =
  if k mod 2 = 0 then SCSTEXTDEFnone () else SCSTEXTDEFsome ("ext")
fun dd_scstextdef (x: scstextdef): void = (
  case+ x of
  | SCSTEXTDEFnone () => dd_ps "SCSTEXTDEFnone()"
  | SCSTEXTDEFsome (s) => (dd_ps "SCSTEXTDEFsome("; dd_string s; dd_ps ")")
)
