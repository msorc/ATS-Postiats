(*
** ATS-extsolve:
** For solving ATS-constraints
** with external SMT-solvers
*)

(* ****** ****** *)

(*
** Author: Hongwei Xi
** Authoremail: gmhwxiATgmailDOTcom
*)

(* ****** ****** *)

implement
location_make
  (ar, rep) = astring_make(ar, rep)

(* ****** ****** *)

implement
fprint_location
  (ar, out, loc) = astring_fprint(ar, out, loc)
// end of [fprint_location]

(* ****** ****** *)

(* end of [patsolve_cnstrnt_location.dats] *)
