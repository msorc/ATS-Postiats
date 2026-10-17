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
s2exp_make_node
  (ar, s2t, s2en) = s2exp_S2EXP(ar, s2t, s2en)

(* ****** ****** *)
//
implement
s2exp_var(ar, s2v) =
s2exp_make_node
(
  ar, s2var_get_srt(ar, s2v), s2exp_node_S2Evar(ar, s2v)
) (* end of [s2exp_var] *)
//
implement
s2exp_eqeq(ar, s2e1, s2e2) =
s2exp_make_node
(
  ar, s2rt_bool(ar), s2exp_node_S2Eeqeq(ar, s2e1, s2e2)
) (* end of [s2exp_eqeq] *)
//
(* ****** ****** *)

implement
s2exp_is_impred
  (ar, s2e0) =
  s2rt_is_impred(ar, s2exp_get_srt(ar, s2e0))

(* ****** ****** *)

implement
fprint_tyreckind
  (ar, out, knd) = (
//
case+
tyreckind_view(ar, knd)
of // case+
| ~TYRECKINDbox() =>
    fprint! (out, "TYRECKINDbox(", ")")
| ~TYRECKINDbox_lin() =>
    fprint! (out, "TYRECKINDbox_lin(", ")")
| ~TYRECKINDflt0() =>
    fprint! (out, "TYRECKINDflt0(", ")")
| ~TYRECKINDflt1(stamp) =>
    fprint! (out, "TYRECKINDflt1(", stamp, ")")
| ~TYRECKINDflt_ext(name) =>
  (
    fprint(out, "TYRECKINDflt_ext(");
    astring_fprint(ar, out, name); fprint(out, ")")
  )
//
) (* end of [fprint_tyreckind] *)

(* ****** ****** *)

implement
fprint_s2exp
  (ar, out, s2e) = let
//
macdef
prs(x) = fprint_string(out, ,(x))
//
in
//
case+
s2exp_node_view
  (ar, s2exp_get_node(ar, s2e))
of // case+
| ~S2Eint(i) =>
    fprint! (out, "S2Eint(", i, ")")
| ~S2Eintinf(i) =>
  (
    prs("S2Eintinf("); astring_fprint(ar, out, i); prs(")")
  )
| ~S2Ecst(s2c) =>
  (
    prs("S2Ecst("); fprint_s2cst(ar, out, s2c); prs(")")
  )
| ~S2Evar(s2v) =>
  (
    prs("S2Evar("); fprint_s2var(ar, out, s2v); prs(")")
  )
| ~S2EVar(s2V) =>
  (
    prs("S2EVar("); fprint_s2Var(ar, out, s2V); prs(")")
  )
| ~S2Eeqeq(s2e1, s2e2) =>
  (
    prs("S2Eeqeq(");
    fprint_s2exp(ar, out, s2e1); prs(", ");
    fprint_s2exp(ar, out, s2e2); prs(")")
  )
| ~S2Esizeof(s2e) =>
  (
    prs("S2Esizeof("); fprint_s2exp(ar, out, s2e); prs(")")
  )
| ~S2Eapp(s2e_fun, s2es_arg) =>
  (
    prs("S2Eapp(");
    fprint_s2exp(ar, out, s2e_fun); prs("; ");
    fprint_s2explst(ar, out, s2es_arg); prs(")")
  )
| ~S2Emetdec(s2es_met, s2es_bound) =>
  (
    prs("S2Emetdec(");
    fprint_s2explst(ar, out, s2es_met); prs("; ");
    fprint_s2explst(ar, out, s2es_bound); prs(")")
  )
| ~S2Etop(knd, s2e) =>
  (
    fprint!(out, "S2Etop(", knd, ", ");
    fprint_s2exp(ar, out, s2e); prs(")")
  )
| ~S2Einvar(s2e) =>
  (
    prs("S2Einvar("); fprint_s2exp(ar, out, s2e); prs(")")
  )
| ~S2Efun(nof, s2es, s2e) =>
  (
    prs("S2Efun(");
    fprint_s2explst(ar, out, s2es); prs("; ");
    fprint_s2exp(ar, out, s2e); prs(")")
  )
| ~S2Euni(s2vs, s2ps, s2e) =>
  (
    prs("S2Euni(");
    fprint_s2varlst(ar, out, s2vs); prs("; ");
    fprint_s2explst(ar, out, s2ps); prs("; ");
    fprint_s2exp(ar, out, s2e); prs(")")
  )
| ~S2Eexi(s2vs, s2ps, s2e) =>
  (
    prs("S2Eexi(");
    fprint_s2varlst(ar, out, s2vs); prs("; ");
    fprint_s2explst(ar, out, s2ps); prs("; ");
    fprint_s2exp(ar, out, s2e); prs(")")
  )
| ~S2Etyrec(knd, npf, s2es_elt) =>
  (
    prs("S2Etyrec(");
    fprint_tyreckind(ar, out, knd); prs("; ");
    fprint_labs2explst(ar, out, s2es_elt); prs(")")
  )
| ~S2Eextype(name) =>
  (
    prs("S2Eextype("); fprint_symbol(ar, out, name); prs(")")
  )
| ~S2Eextkind(name) =>
  (
    prs("S2Eextkind("); fprint_symbol(ar, out, name); prs(")")
  )
| ~S2Eerror((*void*)) => prs("S2Eerror()")
//
end // end of [fprint_s2exp]

(* ****** ****** *)

implement
fprint_s2explst
  (ar, out, xs) = fprint_alist_sep(ar, out, xs, ", ", fprint_s2exp)

(* ****** ****** *)

implement
fprint_labs2exp
  (ar, out, ls2e) =
(
  fprint_label(ar, out, labs2exp_get_lab(ar, ls2e));
  fprint_string(out, "->");
  fprint_s2exp(ar, out, labs2exp_get_exp(ar, ls2e))
) (* end of [fprint_labs2exp] *)

(* ****** ****** *)

implement
fprint_labs2explst
  (ar, out, xs) = fprint_alist_sep(ar, out, xs, ", ", fprint_labs2exp)

(* ****** ****** *)

(* end of [patsolve_cnstrnt_s2exp.dats] *)
