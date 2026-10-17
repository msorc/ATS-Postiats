(* ****** ****** *)
//
// HX-2017-01-28:
// For downstream staloading
//
(* ****** ****** *)
//
#staload
INTINF = "./SATS/intinf.sats"
#staload
INTINF_vt = "./SATS/intinf_vt.sats"
//
(* ****** ****** *)
//
#staload
_(*INTINF_vt*) = "./DATS/intinf_vt.dats"
//
// HX-2026-10: no GC
// the nonlinear [intinf_t] is removed;
// please use the linear [intinf_vt]
//
(* ****** ****** *)

(* end of [mylibies.hats] *)
