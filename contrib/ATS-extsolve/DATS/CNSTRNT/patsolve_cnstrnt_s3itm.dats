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
fprint_s3itm
  (ar, out, s3i) = let
//
macdef
prs(x) = fprint_string(out, ,(x))
//
in
//
case+
s3itm_view(ar, s3i)
of // case+
| ~S3ITMsvar(s2v) =>
  (
    prs("S3ITMsvar("); fprint_s2var(ar, out, s2v); prs(")")
  )
| ~S3ITMsVar(s2V) =>
  (
    prs("S3ITMsVar("); fprint_s2Var(ar, out, s2V); prs(")")
  )
| ~S3ITMhypo(h3p) =>
  (
    prs("S3ITMhypo("); fprint_h3ypo(ar, out, h3p); prs(")")
  )
| ~S3ITMcnstr(c3t) =>
  (
    prs("S3ITMcnstr("); fprint_c3nstr(ar, out, c3t); prs(")")
  )
| ~S3ITMcnstr_ref(loc, opt) =>
  (
    prs("S3ITMcnstr_ref("); fprint_c3nstropt(ar, out, opt); prs(")")
  )
| ~S3ITMdisj(s3iss) =>
  (
    prs("S3ITMdisj("); fprint_s3itmlstlst(ar, out, s3iss); prs(")")
  )
| ~S3ITMsolassert(s2e_prop) =>
  (
    prs("S3ITMsolassert("); fprint_s2exp(ar, out, s2e_prop); prs(")")
  )
//
end (* end of [fprint_s3itm] *)

(* ****** ****** *)
//
implement
fprint_s3itmlst
  (ar, out, xs) = fprint_alist_sep(ar, out, xs, ", ", fprint_s3itm)
//
implement
fprint_s3itmlstlst
  (ar, out, xss) = fprint_alist_sep(ar, out, xss, "; ", fprint_s3itmlst)
//
(* ****** ****** *)

(* end of [patsolve_cnstrnt_s3itm.dats] *)
