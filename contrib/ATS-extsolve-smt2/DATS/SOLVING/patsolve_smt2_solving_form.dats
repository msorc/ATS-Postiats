(*
##
## ATS-extsolve-smt2:
## Outputing ATS-constraints
## in the format of smt-lib2
##
*)

(* ****** ****** *)
//
#ifndef
PATSOLVE_SMT2_SOLVING
#include "./myheader.hats"
#endif // end of [ifndef]
//
(* ****** ****** *)
//
staload
UN = "prelude/SATS/unsafe.sats"
//
staload "./patsolve_smt2_solving_ctx.dats"
//
(* ****** ****** *)
//
#include "./patsolve_smt2_solving_gen.hats"

(* ****** ****** *)
//
implement
fprint_form
  (ar, out, x0) = (
//
case+
form_view(ar, x0)
of // case+
| ~FORMint(i) =>
  fprint! (out, "FORMint(", i, ")")
| ~FORMbool(b) =>
  fprint! (out, "FORMint(", b, ")")
| ~FORMintrep(rep) =>
  (
    fprint(out, "FORMintrep(");
    astring_fprint(ar, out, rep); fprint(out, ")")
  )
| ~FORMs2var(s2v) =>
  (
    fprint(out, "FORMs2var(");
    fprint_s2var(ar, out, s2v); fprint(out, ")")
  )
| ~FORMs2cst(s2c) =>
  (
    fprint(out, "FORMs2var(");
    fprint_s2cst(ar, out, s2c); fprint(out, ")")
  )
| ~FORMs2exp(s2e) =>
  (
    fprint(out, "FORMs2exp(");
    fprint_s2exp(ar, out, s2e); fprint(out, ")")
  )
| ~FORMnot(fml) =>
  (
    fprint (out, "FORMnot(");
    fprint_form(ar, out, fml); fprint (out, ")")
  )
| ~FORMconj(fml1, fml2) =>
  (
    fprint (out, "FORMconj(");
    fprint_form(ar, out, fml1);
    fprint_form(ar, out, fml2); fprint (out, ")")
  )
| ~FORMdisj(fml1, fml2) =>
  (
    fprint (out, "FORMdisj(");
    fprint_form(ar, out, fml1);
    fprint_form(ar, out, fml2); fprint (out, ")")
  )
| ~FORMimpl(fml1, fml2) =>
  (
    fprint (out, "FORMimpl(");
    fprint_form(ar, out, fml1);
    fprint_form(ar, out, fml2); fprint (out, ")")
  )
//
) (* end of [fprint_form] *)
//
(* ****** ****** *)

implement
formula_null(ar) = form_FORMint(ar, 0)

(* ****** ****** *)
//
implement
formula_true(ar) = form_FORMbool(ar, true)
implement
formula_false(ar) = form_FORMbool(ar, false)
//
(* ****** ****** *)
//
implement
formula_int
  (ar, int) = form_FORMint(ar, int)
implement
formula_intrep
  (ar, rep) = form_FORMintrep(ar, rep)
//  
(* ****** ****** *)
//
implement
formula_make_s2cst
  (ar, env, s2c0) = form_FORMs2cst(ar, s2c0)
implement
formula_make_s2var
  (ar, env, s2v0) = form_FORMs2var(ar, s2v0)
//
implement
formula_make_s2exp
  (ar, env, s2p0) = form_FORMs2exp(ar, s2p0)
//
(* ****** ****** *)

implement
formula_not(ar, s2p) = form_FORMnot(ar, s2p)

(* ****** ****** *)

implement
formula_conj_list
  {l}(ar, s2es) = let
//
fun
aux
(
  ar: !arena(l)
, s2e0: form(l), s2es: formlst(l)
) : form(l) =
(
if
alist_is_cons(s2es)
then
aux
(
  ar
, form_FORMconj(ar, s2e0, alist_head(ar, s2es))
, alist_tail(ar, s2es)
) (* end of [then] *)
else s2e0
) (* end of [aux] *)
//
in
//
if
alist_is_cons(s2es)
then aux(ar, alist_head(ar, s2es), alist_tail(ar, s2es))
else form_FORMbool(ar, true)
//
end // end of [formula_conj_list]

(* ****** ****** *)

implement
formula_conj_list1
  (ar, s2es_arg, s2e_res) =
(
if
alist_is_cons(s2es_arg)
then
form_FORMconj
  (ar, formula_conj_list(ar, s2es_arg), s2e_res)
else s2e_res
) (* end of [formula_conj_list1] *)

(* ****** ****** *)

implement
formula_impl_list1
  (ar, s2es_arg, s2e_res) =
(
if
alist_is_cons(s2es_arg)
then
form_FORMimpl
  (ar, formula_conj_list(ar, s2es_arg), s2e_res)
else s2e_res
) (* end of [formula_impl_list1] *)

(* ****** ****** *)

(* end of [patsolve_smt2_solving_form.dats] *)
