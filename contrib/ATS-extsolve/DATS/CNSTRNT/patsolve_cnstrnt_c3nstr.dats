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
c3nstr_make_node
  (ar, loc, c3tk, node) = c3nstr_C3NSTR(ar, loc, c3tk, node)

(* ****** ****** *)

implement
fprint_c3nstr
  (ar, out, c3t) = let
//
macdef
prs(x) = fprint_string(out, ,(x))
//
in
//
case+
c3nstr_node_view
  (ar, c3nstr_get_node(ar, c3t))
of // case+
| ~C3NSTRprop(s2e) =>
  (
    prs("C3NSTRprop("); fprint_s2exp(ar, out, s2e); prs(")")
  )
| ~C3NSTRitmlst(s3is) =>
  (
    prs("C3NSTRitmlst("); fprint_s3itmlst(ar, out, s3is); prs(")")
  )
| ~C3NSTRsolverify(s2e_prop) =>
  (
    prs("C3NSTRsolverify("); fprint_s2exp(ar, out, s2e_prop); prs(")")
  )
//
end (* end of [fprint_c3nstr] *)

(* ****** ****** *)

implement
fprint_c3nstropt
  (ar, out, opt) =
(
case+
c3nstropt_view(ar, opt)
of // case+
| ~C3NSTRnone() => fprint_string(out, "None()")
| ~C3NSTRsome(c3t) =>
  (
    fprint_string(out, "Some(");
    fprint_c3nstr(ar, out, c3t); fprint_string(out, ")")
  )
) (* end of [fprint_c3nstropt] *)

(* ****** ****** *)
//
// HX-2015-05: pretty-printing
//
implement
fpprint_c3nstr
  {l}(ar, out, c3t0) = let
//
macdef
prs(x) = fprint_string(out, ,(x))
//
fun
aux_indent
  (ind: int): void =
(
if
ind > 0
then
(
  fprint(out, ' '); aux_indent(ind-1)
) (* end of [then] *)
) (* end of [aux_indent] *)
//
fun
auxln_indent
  (ind: int): void =
  (fprint(out, '\n'); aux_indent(ind))
//
fun
aux_c3nstr
(
  ar: !arena(l), ind: int, c3t0: c3nstr(l)
) : void = let
//
val () = aux_indent(ind)
//
in
//
case+
c3nstr_node_view
  (ar, c3nstr_get_node(ar, c3t0))
of // case+
| ~C3NSTRprop(s2e) =>
  (
    prs("C3NSTRprop("); fprint_s2exp(ar, out, s2e); prs(")")
  )
| ~C3NSTRitmlst(s3is) =>
  {
    val () = prs("C3NSTRitmlst(\n")
    val () = aux_s3itmlst(ar, ind+2, s3is)
    val () =
    (
      aux_indent(ind); prs(") (* C3NSTRitmlst *)")
    ) (* end of [val] *)
  }
| ~C3NSTRsolverify(s2e_prop) =>
  (
    prs("C3NSTRsolverify("); fprint_s2exp(ar, out, s2e_prop); prs(")")
  )
//
end (* end of [aux_c3nstr] *)
//
and
aux_s3itm
(
  ar: !arena(l), ind: int, s3i0: s3itm(l)
) : void = let
//
val () = aux_indent(ind)
//
in
//
case+
s3itm_view(ar, s3i0)
of // case+
| ~S3ITMcnstr(c3t) =>
  {
    val () = prs("S3ITMcnstr(\n")
    val () = aux_c3nstr(ar, ind+2, c3t)
    val () =
    (
      auxln_indent(ind); prs(") (* S3ITMcnstr *)")
    ) (* end of [val] *)
  }
| v0(*rest-of-s3itm*) =>
  (
    s3itm_view_free(v0); fprint_s3itm(ar, out, s3i0)
  )
//
end // end of [aux_s3itm]
//
and
aux_s3itmlst
(
  ar: !arena(l), ind: int, s3is: s3itmlst(l)
) : void =
(
if
alist_is_cons(s3is)
then
(
  aux_s3itm(ar, ind, alist_head(ar, s3is));
  fprint(out, '\n'); aux_s3itmlst(ar, ind, alist_tail(ar, s3is))
) (* end of [then] *)
) (* end of [aux_s3itmlst] *)
//
in
  aux_c3nstr(ar, 0(*indent*), c3t0)
end (* end of [fpprint_c3nstr] *)

(* ****** ****** *)

(* end of [patsolve_cnstrnt_c3nstr.dats] *)
