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

local
//
assume
s2Var_type(l:addr) = aref(l, stamp)
//
in (* in-of-local *)

implement
s2Var_make
  (ar, stamp) = aref_make<stamp>(ar, stamp)

implement
s2Var_get_stamp
  (ar, s2V) = aref_get<stamp>(ar, s2V)

end // end of [local]

(* ****** ****** *)

implement
fprint_s2Var
  (ar, out, s2V) =
  fprint! (out, "s2Var(", s2Var_get_stamp(ar, s2V), ")")
// end of [fprint_s2Var]

(* ****** ****** *)

(* end of [patsolve_cnstrnt_s2vvar.dats] *)
