(*
** SPDX-FileCopyrightText: 2026 Mikhail Sorochan
** SPDX-License-Identifier: GPL-3.0-or-later
*)

(* ****** ****** *)
//
// patslint: the rules on the syntax tree (level 0)
//
// The text is parsed by the parser of the compiler (p_toplevel_sta
// or p_toplevel_dyn: an error is recorded and the parser resumes at
// the next declaration), then the tree is walked:
//
// parse-error: the first error of the parser (when the lexer found
//   no error)
// staload-dup: the same file staloaded twice (with the same name)
// staload-unused: a named staload (X = ...) whose $X is not used in
//   the file (not checked in a .hats file: its includer may use it)
// let-empty: let in E end
// case-single: a case with one clause
// case-unchecked: a case that is not case+ or case-
// end-comment: an [end of [NAME]] comment right after a function or
//   an implementation that names another function of the file
// fnx-template: fnx on a template (the compiler makes it a fun)
// if-const: an if on true or false
// naming: a linear type (datavtype, vtypedef, absvtype) whose name
//   has no _vt, a view (dataview, viewdef, absview) without _v
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

#define ATS_DYNLOADFLAG 0 // no initialization

(* ****** ****** *)
//
staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"
//
(* ****** ****** *)
//
staload SYM = "src/pats_symbol.sats"
staload LOC = "src/pats_location.sats"
staload FIL = "src/pats_filename.sats"
staload BAS = "src/pats_basics.sats"
staload LBF = "src/pats_lexbuf.sats"
staload TBF = "src/pats_tokbuf.sats"
staload PAR = "src/pats_parsing.sats"
//
staload "src/pats_lexing.sats"
staload "src/pats_syntax.sats"
//
#include "src/pats_basics.hats"
//
(* ****** ****** *)

staload "./../SATS/patslint.sats"

(* ****** ****** *)

fn
loc_beg (loc: location): int =
  g0int2int_lint_int ($LOC.location_beg_ntot (loc))
fn
loc_end (loc: location): int =
  g0int2int_lint_int ($LOC.location_end_ntot (loc))

fn
symbol_name
  (sym: symbol): string = $SYM.symbol_get_name (sym)

(* ****** ****** *)
//
// what the walk collects for the checks at the end
//
typedef stlitem = @(string(*name*), string(*path*), int(*offset*), int(*depth*))
typedef funitem = @(string(*name*), int(*end*))
//
datavtype
tctx =
TCTX of
(
  string(*path*)
, int(*depth: the number of enclosing let, where, ...*)
, List0_vt(stlitem)(*stls*)
, List0_vt(funitem)(*funs*)
) (* end of [tctx] *)
//
fn
ctx_get_path
  (ctx: !tctx): string = let
  val+TCTX (path, _, _, _) = ctx in path
end // end of [ctx_get_path]
//
fn
ctx_get_depth
  (ctx: !tctx): int = let
  val+TCTX (_, depth, _, _) = ctx in depth
end // end of [ctx_get_depth]
//
fn
ctx_add_depth
  (ctx: !tctx, k: int): void = let
  val+@TCTX (_, depth, _, _) = ctx
  val () = depth := depth + k
  prval () = fold@ (ctx)
in
  // nothing
end // end of [ctx_add_depth]
//
fn
ctx_add_stl
  (ctx: !tctx, x: stlitem): void = let
  val+@TCTX (_, _, stls, _) = ctx
  val () = stls := list_vt_cons (x, stls)
  prval () = fold@ (ctx)
in
  // nothing
end // end of [ctx_add_stl]
//
fn
ctx_add_fun
  (ctx: !tctx, x: funitem): void = let
  val+@TCTX (_, _, _, funs) = ctx
  val () = funs := list_vt_cons (x, funs)
  prval () = fold@ (ctx)
in
  // nothing
end // end of [ctx_add_fun]
//
(* ****** ****** *)
//
extern fun d0ecl_walk (ctx: !tctx, buf: !textbuf, x: d0ecl): void
extern fun d0eclist_walk (ctx: !tctx, buf: !textbuf, xs: d0eclist): void
extern fun d0exp_walk (ctx: !tctx, buf: !textbuf, x: d0exp): void
extern fun d0explst_walk (ctx: !tctx, buf: !textbuf, xs: d0explst): void
extern fun d0expopt_walk (ctx: !tctx, buf: !textbuf, opt: d0expopt): void
extern fun d0explstlst_walk (ctx: !tctx, buf: !textbuf, xss: d0explstlst): void
extern fun c0laulst_walk (ctx: !tctx, buf: !textbuf, xs: c0laulst): void
//
(* ****** ****** *)

fn
ctx_report
(
  ctx: !tctx, buf: !textbuf
, loc: location, rule: int, msg: string
) : void = report_at (ctx_get_path (ctx), buf, loc_beg (loc), rule, msg)

(* ****** ****** *)
//
// the bytes after the keyword [case] of a case expression
//
fn
case_is_checked
  (buf: !textbuf, tok: token): bool = let
  val i = loc_beg (tok.token_loc ())
  val c = textbuf_get_char (buf, i + 4)
in
  c = 43(*plus*) || c = 45(*minus*)
end // end of [case_is_checked]

(* ****** ****** *)
//
// [s] ends with [t]
//
fn
string_has_suffix
  (s: string, t: string): bool = let
  val n = g0uint2int_size_int (string_length (s))
  val k = g0uint2int_size_int (string_length (t))
  extern fun
  strcmp_at (s: string, i: int, t: string): int = "mac#patslint_strcmp_at"
in
  n >= k && strcmp_at (s, n - k, t) = 0
end // end of [string_has_suffix]

fn
check_naming
(
  ctx: !tctx, buf: !textbuf
, loc: location, knd: int, name: string
) : void =
(
if knd = VIEWTYPE_int || knd = VIEWT0YPE_int then
(
  if ~(string_has_suffix (name, "_vt")
       || string_has_suffix (name, "_vtype")
       || string_has_suffix (name, "_vt0ype")
       || string_has_suffix (name, "_vt0p")
       || string_has_suffix (name, "_vtbox")) then
    ctx_report
    ( ctx, buf, loc, RULE_naming
    , msg_format2s ("the linear type [%s] has no _vt suffix%s", name, "")
    ) (* end of [ctx_report] *)
) else if knd = VIEW_int then
(
  if ~(string_has_suffix (name, "_v")
       || string_has_suffix (name, "_view")) then
    ctx_report
    ( ctx, buf, loc, RULE_naming
    , msg_format2s ("the view [%s] has no _v suffix%s", name, "")
    ) (* end of [ctx_report] *)
) (* end of [if] *)
) (* end of [check_naming] *)

(* ****** ****** *)

implement
d0eclist_walk
  (ctx, buf, xs) =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) => (d0ecl_walk (ctx, buf, x); d0eclist_walk (ctx, buf, xs))
| ~GLnil() => ()
) (* end of [d0eclist_walk] *)

(* ****** ****** *)

fun
guad0ecl_node_walk
(
  ctx: !tctx, buf: !textbuf, x: guad0ecl_node
) : void =
(
case+ guad0ecl_node_view(x) of
| ~GD0Cone(_, ds) => d0eclist_walk (ctx, buf, ds)
| ~GD0Ctwo(_, ds1, ds2) =>
  (d0eclist_walk (ctx, buf, ds1); d0eclist_walk (ctx, buf, ds2))
| ~GD0Ccons(_, ds, _, x2) =>
  (d0eclist_walk (ctx, buf, ds); guad0ecl_node_walk (ctx, buf, x2))
) (* end of [guad0ecl_node_walk] *)

(* ****** ****** *)

fun
f0undeclst_walk
(
  ctx: !tctx, buf: !textbuf, xs: f0undeclst
) : void =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) => let
    val name = symbol_name (x.f0undec_sym ())
    val () = ctx_add_fun (ctx, @(name, loc_end (x.f0undec_loc ())))
    val () = d0exp_walk (ctx, buf, x.f0undec_def ())
  in
    f0undeclst_walk (ctx, buf, xs)
  end // end of [GLcons]
| ~GLnil() => ()
) (* end of [f0undeclst_walk] *)

fun
v0aldeclst_walk
(
  ctx: !tctx, buf: !textbuf, xs: v0aldeclst
) : void =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) =>
  (d0exp_walk (ctx, buf, x.v0aldec_def ()); v0aldeclst_walk (ctx, buf, xs))
| ~GLnil() => ()
) (* end of [v0aldeclst_walk] *)

fun
v0ardeclst_walk
(
  ctx: !tctx, buf: !textbuf, xs: v0ardeclst
) : void =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) =>
  (d0expopt_walk (ctx, buf, x.v0ardec_init ()); v0ardeclst_walk (ctx, buf, xs))
| ~GLnil() => ()
) (* end of [v0ardeclst_walk] *)

fun
m0acdeflst_walk
(
  ctx: !tctx, buf: !textbuf, xs: m0acdeflst
) : void =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) =>
  (d0exp_walk (ctx, buf, x.m0acdef_def ()); m0acdeflst_walk (ctx, buf, xs))
| ~GLnil() => ()
) (* end of [m0acdeflst_walk] *)

fun
d0atdeclst_naming
(
  ctx: !tctx, buf: !textbuf, knd: int, xs: d0atdeclst
) : void =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) => let
    val () =
      check_naming
        (ctx, buf, x.d0atdec_loc (), knd, symbol_name (x.d0atdec_sym ()))
  in
    d0atdeclst_naming (ctx, buf, knd, xs)
  end // end of [GLcons]
| ~GLnil() => ()
) (* end of [d0atdeclst_naming] *)

fun
s0expdeflst_naming
(
  ctx: !tctx, buf: !textbuf, knd: int, xs: s0expdeflst
) : void =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) => let
    val () =
      check_naming
        (ctx, buf, x.s0expdef_loc (), knd, symbol_name (x.s0expdef_sym ()))
  in
    s0expdeflst_naming (ctx, buf, knd, xs)
  end // end of [GLcons]
| ~GLnil() => ()
) (* end of [s0expdeflst_naming] *)

fun
s0taconlst_naming
(
  ctx: !tctx, buf: !textbuf, knd: int, xs: s0taconlst
) : void =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) => let
    val () =
      check_naming
        (ctx, buf, x.s0tacon_loc (), knd, symbol_name (x.s0tacon_sym ()))
  in
    s0taconlst_naming (ctx, buf, knd, xs)
  end // end of [GLcons]
| ~GLnil() => ()
) (* end of [s0taconlst_naming] *)

(* ****** ****** *)

implement
d0ecl_walk
  (ctx, buf, x) = let
//
val loc0 = x.d0ecl_loc ()
//
in
//
case+ d0ecl_node_view(x.d0ecl_node ()) of
//
| ~D0Cstaload(_, nameopt, fpath) => let
    //
    // the name is kept with its [$] ([$_] for staload _ = ...)
    //
    val name =
    (
      case+ gopt_view(nameopt) of
      | ~GOsome(sym) => symbol_name (sym) | ~GOnone() => ""
    ) : string
  in
    ctx_add_stl (ctx, @(name, fpath, loc_beg (loc0), ctx_get_depth (ctx)))
  end // end of [D0Cstaload]
| ~D0Cstaloadloc(_, _, ds) => d0eclist_walk (ctx, buf, ds)
//
| ~D0Cextvar(_, d0e) => d0exp_walk (ctx, buf, d0e)
//
| ~D0Cimpdec(_, _, dec) => let
    val qid = dec.i0mpdec_qid ()
    val name = symbol_name (qid.impqi0de_sym ())
    val () = ctx_add_fun (ctx, @(name, loc_end (dec.i0mpdec_loc ())))
  in
    d0exp_walk (ctx, buf, dec.i0mpdec_def ())
  end // end of [D0Cimpdec]
//
| ~D0Cmacdefs(_, _, defs) => m0acdeflst_walk (ctx, buf, defs)
//
| ~D0Cfundecs(fk, qmas, decs) => let
    val () =
      if $BAS.funkind_is_mutailrec (fk) && glist_is_cons (qmas) then
        ctx_report
        ( ctx, buf, loc0, RULE_fnx_template
        , "fnx on a template: the compiler treats it as fun"
        ) (* end of [ctx_report] *)
      // end of [if]
  in
    f0undeclst_walk (ctx, buf, decs)
  end // end of [D0Cfundecs]
//
| ~D0Cvaldecs(_, _, decs) => v0aldeclst_walk (ctx, buf, decs)
| ~D0Cvardecs(_, decs) => v0ardeclst_walk (ctx, buf, decs)
//
| ~D0Clocal(ds1, ds2) =>
  (d0eclist_walk (ctx, buf, ds1); d0eclist_walk (ctx, buf, ds2))
| ~D0Cguadecl(_, gd) => guad0ecl_node_walk (ctx, buf, gd.guad0ecl_node ())
//
| ~D0Cdatdecs(knd, decs, defs) => let
    val () = d0atdeclst_naming (ctx, buf, knd, decs)
  in
    s0expdeflst_naming (ctx, buf, knd, defs)
  end // end of [D0Cdatdecs]
| ~D0Csexpdefs(knd, defs) => s0expdeflst_naming (ctx, buf, knd, defs)
| ~D0Cstacons(knd, cons) => s0taconlst_naming (ctx, buf, knd, cons)
//
| v (*rest*) => d0ecl_node_view_free (v)
//
end // end of [d0ecl_walk]

(* ****** ****** *)

implement
d0explst_walk
  (ctx, buf, xs) =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) => (d0exp_walk (ctx, buf, x); d0explst_walk (ctx, buf, xs))
| ~GLnil() => ()
) (* end of [d0explst_walk] *)

implement
d0expopt_walk
  (ctx, buf, opt) =
(
case+ gopt_view(opt) of
| ~GOsome(x) => d0exp_walk (ctx, buf, x) | ~GOnone() => ()
) (* end of [d0expopt_walk] *)

implement
d0explstlst_walk
  (ctx, buf, xss) =
(
case+ glist_view(xss) of
| ~GLcons(xs, xss) =>
  (d0explst_walk (ctx, buf, xs); d0explstlst_walk (ctx, buf, xss))
| ~GLnil() => ()
) (* end of [d0explstlst_walk] *)

fun
labd0explst_walk
(
  ctx: !tctx, buf: !textbuf, xs: labd0explst
) : void =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) =>
  (d0exp_walk (ctx, buf, x.labd0exp_elt ()); labd0explst_walk (ctx, buf, xs))
| ~GLnil() => ()
) (* end of [labd0explst_walk] *)

fun
gm0atlst_walk
(
  ctx: !tctx, buf: !textbuf, xs: gm0atlst
) : void =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) =>
  (d0exp_walk (ctx, buf, x.gm0at_exp ()); gm0atlst_walk (ctx, buf, xs))
| ~GLnil() => ()
) (* end of [gm0atlst_walk] *)

implement
c0laulst_walk
  (ctx, buf, xs) =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) => let
    val pat = x.c0lau_pat ()
    val () = gm0atlst_walk (ctx, buf, pat.guap0at_gua ())
    val () = d0exp_walk (ctx, buf, x.c0lau_body ())
  in
    c0laulst_walk (ctx, buf, xs)
  end // end of [GLcons]
| ~GLnil() => ()
) (* end of [c0laulst_walk] *)

fun
sc0laulst_walk
(
  ctx: !tctx, buf: !textbuf, xs: sc0laulst
) : void =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) =>
  (d0exp_walk (ctx, buf, x.sc0lau_body ()); sc0laulst_walk (ctx, buf, xs))
| ~GLnil() => ()
) (* end of [sc0laulst_walk] *)

fun
i0fclist_walk
(
  ctx: !tctx, buf: !textbuf, xs: i0fclist
) : void =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) => let
    val () = d0exp_walk (ctx, buf, x.i0fcl_test ())
    val () = d0exp_walk (ctx, buf, x.i0fcl_body ())
  in
    i0fclist_walk (ctx, buf, xs)
  end // end of [GLcons]
| ~GLnil() => ()
) (* end of [i0fclist_walk] *)

(* ****** ****** *)
//
// [x] is the identifier [true] or [false]
//
fn
d0exp_is_bool
  (x: d0exp): bool =
(
case+ d0exp_node_view(x.d0exp_node ()) of
| ~D0Eide(sym) => let
    val name = symbol_name (sym) in name = "true" || name = "false"
  end // end of [D0Eide]
| v (*rest*) => (d0exp_node_view_free (v); false)
) (* end of [d0exp_is_bool] *)

(* ****** ****** *)

implement
d0exp_walk
  (ctx, buf, x) = let
//
val loc0 = x.d0exp_loc ()
//
in
//
case+ d0exp_node_view(x.d0exp_node ()) of
//
| ~D0Eliteral(e) => d0exp_walk (ctx, buf, e)
| ~D0Eextfcall(_, _, es) => d0explst_walk (ctx, buf, es)
| ~D0Eextmcall(_, e, _, es) =>
  (d0exp_walk (ctx, buf, e); d0explst_walk (ctx, buf, es))
| ~D0Efoldat(es) => d0explst_walk (ctx, buf, es)
| ~D0Efreeat(es) => d0explst_walk (ctx, buf, es)
//
| ~D0Elet(ds, e) => let
    val () =
      if glist_is_nil (ds) then
        ctx_report
        ( ctx, buf, loc0, RULE_let_empty
        , "let with no declarations"
        ) (* end of [ctx_report] *)
      // end of [if]
    val () = ctx_add_depth (ctx, 1)
    val () = d0eclist_walk (ctx, buf, ds)
    val () = ctx_add_depth (ctx, ~1)
  in
    d0exp_walk (ctx, buf, e)
  end // end of [D0Elet]
| ~D0Edeclseq(ds) => let
    val () = ctx_add_depth (ctx, 1)
    val () = d0eclist_walk (ctx, buf, ds)
  in
    ctx_add_depth (ctx, ~1)
  end // end of [D0Edeclseq]
| ~D0Ewhere(e, ds) => let
    val () = d0exp_walk (ctx, buf, e)
    val () = ctx_add_depth (ctx, 1)
    val () = d0eclist_walk (ctx, buf, ds)
  in
    ctx_add_depth (ctx, ~1)
  end // end of [D0Ewhere]
//
| ~D0Eapp(e1, e2) => (d0exp_walk (ctx, buf, e1); d0exp_walk (ctx, buf, e2))
| ~D0Elist(_, es) => d0explst_walk (ctx, buf, es)
//
| ~D0Eifhead(_, e1, e2, opt) => let
    val () =
      if d0exp_is_bool (e1) then
        ctx_report
        ( ctx, buf, e1.d0exp_loc (), RULE_if_const
        , "the condition of the if is a constant"
        ) (* end of [ctx_report] *)
      // end of [if]
    val () = d0exp_walk (ctx, buf, e1)
    val () = d0exp_walk (ctx, buf, e2)
  in
    d0expopt_walk (ctx, buf, opt)
  end // end of [D0Eifhead]
| ~D0Esifhead(_, _, e1, e2) =>
  (d0exp_walk (ctx, buf, e1); d0exp_walk (ctx, buf, e2))
| ~D0Eifcasehd(_, cls) => i0fclist_walk (ctx, buf, cls)
//
| ~D0Ecasehead(hd, e, cls) => let
    val () =
      if glist_length (cls) = 1 then
        ctx_report
        ( ctx, buf, loc0, RULE_case_single
        , "a case with one clause (a val may do)"
        ) (* end of [ctx_report] *)
      // end of [if]
    val () =
      if ~case_is_checked (buf, hd.casehead_tok ()) then
        ctx_report
        ( ctx, buf, loc0, RULE_case_unchecked
        , "a case that is not case+ (the clauses are not checked)"
        ) (* end of [ctx_report] *)
      // end of [if]
  in
    (d0exp_walk (ctx, buf, e); c0laulst_walk (ctx, buf, cls))
  end // end of [D0Ecasehead]
| ~D0Escasehead(_, _, cls) => sc0laulst_walk (ctx, buf, cls)
//
| ~D0Elst(_, _, e) => d0exp_walk (ctx, buf, e)
| ~D0Etup(_, _, es) => d0explst_walk (ctx, buf, es)
| ~D0Erec(_, _, les) => labd0explst_walk (ctx, buf, les)
| ~D0Eseq(es) => d0explst_walk (ctx, buf, es)
| ~D0Earrsub(_, _, ess) => d0explstlst_walk (ctx, buf, ess)
| ~D0Earrpsz(_, e) => d0exp_walk (ctx, buf, e)
| ~D0Earrinit(_, opt, es) =>
  (d0expopt_walk (ctx, buf, opt); d0explst_walk (ctx, buf, es))
| ~D0Esel_ind(_, ess) => d0explstlst_walk (ctx, buf, ess)
| ~D0Eraise(e) => d0exp_walk (ctx, buf, e)
| ~D0Eeffmask(_, e) => d0exp_walk (ctx, buf, e)
| ~D0Eeffmask_arg(_, e) => d0exp_walk (ctx, buf, e)
| ~D0Evararg(es) => d0explst_walk (ctx, buf, es)
| ~D0Evcopyenv(_, e) => d0exp_walk (ctx, buf, e)
| ~D0Eshowtype(e) => d0exp_walk (ctx, buf, e)
| ~D0Etempenver(e) => d0exp_walk (ctx, buf, e)
| ~D0Eexist(_, _, e) => d0exp_walk (ctx, buf, e)
| ~D0Eann(e, _) => d0exp_walk (ctx, buf, e)
| ~D0Elam(_, _, _, _, e) => d0exp_walk (ctx, buf, e)
| ~D0Efix(_, _, _, _, _, e) => d0exp_walk (ctx, buf, e)
| ~D0Edelay(_, e) => d0exp_walk (ctx, buf, e)
| ~D0Efor(_, _, itp, e) => let
    val () = d0exp_walk (ctx, buf, itp.itp_init ())
    val () = d0exp_walk (ctx, buf, itp.itp_test ())
    val () = d0exp_walk (ctx, buf, itp.itp_post ())
  in
    d0exp_walk (ctx, buf, e)
  end // end of [D0Efor]
| ~D0Ewhile(_, _, e1, e2) =>
  (d0exp_walk (ctx, buf, e1); d0exp_walk (ctx, buf, e2))
| ~D0Etrywith(_, e, cls) =>
  (d0exp_walk (ctx, buf, e); c0laulst_walk (ctx, buf, cls))
| ~D0Emacsyn(_, e) => d0exp_walk (ctx, buf, e)
| ~D0Esolassert(e) => d0exp_walk (ctx, buf, e)
//
| v (*rest*) => d0exp_node_view_free (v)
//
end // end of [d0exp_walk]

(* ****** ****** *)
//
// staload-dup and staload-unused
//
fun
stls_find_dup
(
  xs: !List0_vt(stlitem), x: stlitem
) : int(*offset*) =
(
case+ xs of
| list_vt_cons (y, ys) =>
  (
    if x.3 = 0 && y.3 = 0
       && y.2 < x.2 && y.0 = x.0 && y.1 = x.1
      then y.2 else stls_find_dup (ys, x)
  )
| list_vt_nil () => ~1
) (* end of [stls_find_dup] *)

fun
textbuf_count_dlr
(
  buf: !textbuf, name: string, i: int, n: int
) : int =
  if i < textbuf_get_ntok (buf) then let
    val n =
    (
      if textbuf_tok_kind (buf, i) = TOK_ident_dlr
         && textbuf_eq
            (buf, textbuf_tok_beg (buf, i), textbuf_tok_end (buf, i), name)
        then n + 1 else n
    ) : int
  in
    textbuf_count_dlr (buf, name, i + 1, n)
  end else n
// end of [textbuf_count_dlr]

fun
check_staloads
  {n1,n2:nat}
(
  path: string, buf: !textbuf
, all: !list_vt(stlitem, n1), xs: !list_vt(stlitem, n2), ishats: bool
) : void =
(
case+ xs of
| list_vt_cons (x, xs1) => let
    val dup = stls_find_dup (all, x)
    val () =
      if dup >= 0 then
        report_at
        ( path, buf, x.2, RULE_staload_dup
        , msg_format2
          ( "the file is staloaded again (line %d)%.0d"
          , textbuf_line_of (buf, dup), 0
          ) (* end of [msg_format2] *)
        ) (* end of [report_at] *)
      // end of [if]
    val name = x.0
    val () =
      if ~ishats && dup < 0
         && name != "" && name != "_" && name != "$_"
         && textbuf_count_dlr (buf, name, 0, 0) = 0 then
        report_at
        ( path, buf, x.2, RULE_staload_unused
        , msg_format2s ("%s is never used%s", name, "")
        ) (* end of [report_at] *)
      // end of [if]
  in
    check_staloads (path, buf, all, xs1, ishats)
  end // end of [list_vt_cons]
| list_vt_nil () => ()
) (* end of [check_staloads] *)

(* ****** ****** *)
//
// end-comment: the comment right after the end of a function (on
// its last line) that says [end of [X]], with X the name of another
// function of the file
//
fun
funs_has_name
  (xs: !List0_vt(funitem), name: string): bool =
(
case+ xs of
| list_vt_cons (x, xs) =>
    if x.0 = name then true else funs_has_name (xs, name)
| list_vt_nil () => false
) (* end of [funs_has_name] *)

fun
check_end_comments
  {n1,n2:nat}
(
  path: string, buf: !textbuf
, all: !list_vt(funitem, n1), xs: !list_vt(funitem, n2)
) : void =
(
case+ xs of
| list_vt_cons (x, xs1) => let
    val j = textbuf_tok_index (buf, x.1)
    val beg = textbuf_tok_beg (buf, j)
    val fin = textbuf_tok_end (buf, j)
    val samelin =
      x.1 > 0 && textbuf_line_of (buf, beg) = textbuf_line_of (buf, x.1 - 1)
    val () =
      if j < textbuf_get_ntok (buf)
         && textbuf_tok_kind (buf, j) = TOK_comment && samelin then let
        val i = textbuf_find (buf, beg, fin, "end of [")
        val e =
        (
          if i >= 0 then textbuf_find (buf, i + 8, fin, "]") else ~1
        ) : int
      in
        if e > i + 8 then let
          val other = textbuf_substr (buf, i + 8, e)
        in
          if other != x.0 && funs_has_name (all, other) then
            report_at
            ( path, buf, i, RULE_end_comment
            , msg_format2s
              ("the comment names [%s], the function is [%s]", other, x.0)
            ) (* end of [report_at] *)
          // end of [if]
        end // end of [if]
      end // end of [if]
  in
    check_end_comments (path, buf, all, xs1)
  end // end of [list_vt_cons]
| list_vt_nil () => ()
) (* end of [check_end_comments] *)

(* ****** ****** *)
//
// the first error of the parser (the messages from [i] on)
//
fun
first_parse_error
  (buf: !textbuf, i: int, best: int): int =
  if i < textbuf_get_nerr (buf) then let
    val best =
    (
      if best < 0 && textbuf_err_rule (buf, i) = RULE_parse_error
        then i else best
    ) : int
  in
    first_parse_error (buf, i + 1, best)
  end else best
// end of [first_parse_error]

fun
has_lex_error
  (buf: !textbuf, i: int): bool =
  if i < textbuf_get_nerr (buf) then
  (
    if textbuf_err_rule (buf, i) = RULE_lex_error
      then true else has_lex_error (buf, i + 1)
  ) else false
// end of [has_lex_error]

(* ****** ****** *)
//
// whether one of the rules of this module is on (the parse is skipped
// otherwise)
//
fn
tree_rules_on (): bool = let
  fun loop (id: int): bool =
    if id <= RULE_naming then
    (
      if the_rule_get_sev (id) >= SEV_info then true else loop (id + 1)
    ) else false
in
  the_rule_get_sev (RULE_parse_error) >= SEV_info || loop (RULE_staload_dup)
end // end of [tree_rules_on]

(* ****** ****** *)

//
// a parse of the text: the tree and the number of errors; the
// messages of the parser are recorded with [rule] (dropped if it is
// negative)
//
fn
parse_text
(
  path: string, buf: !textbuf, stadyn: int, rule: int
) : @(d0eclist, int) = let
  val opt = $FIL.filenameopt_make_local (path)
in
//
case+ opt of
| ~Some_vt (fil) => let
    val (pfpush | ()) = $FIL.the_filenamelst_push (fil)
    var lbf: $LBF.lexbuf
    val () = $LBF.lexbuf_initize_charlst_vt (lbf, textbuf_charlst (buf))
    var tbf: $TBF.tokbuf
    val () = $TBF.tokbuf_initize_lexbuf (tbf, lbf)
    val () = the_lexerrlst_clear ()
    val () = $PAR.the_parerrlst_clear ()
    var nerr: int
    val d0cs =
    (
      if stadyn = 0
        then $PAR.p_toplevel_sta (tbf, nerr)
        else $PAR.p_toplevel_dyn (tbf, nerr)
    ) : d0eclist
    val nerr = nerr
    val () = $TBF.tokbuf_uninitize (tbf)
    val () = the_lexerrlst_clear ()
    val out = memout_open ()
    val nerr2 = $PAR.fprint_the_parerrlst (out)
    val () = memout_close (buf, out, rule)
    val () = $FIL.the_filenamelst_pop (pfpush | (*none*))
  in
    @(d0cs, nerr + nerr2)
  end // end of [Some_vt]
| ~None_vt () => @(glist_nil (), 0)
//
end // end of [parse_text]

(* ****** ****** *)

implement
patslint_tree
  (path, buf, stadyn) =
if tree_rules_on () then let
//
val ishats = string_has_suffix (path, ".hats")
//
// a .hats file may be included in a .sats file: it is parsed as
// static code if it is not dynamic code
//
val d0cs =
(
if ishats then let
  val r1 = parse_text (path, buf, 1, ~1)
in
  if r1.1 = 0 then r1.0 else let
    val r2 = parse_text (path, buf, 0, ~1)
  in
    if r2.1 = 0 then r2.0
      else (parse_text (path, buf, 1, RULE_parse_error)).0
    // end of [if]
  end
end else (parse_text (path, buf, stadyn, RULE_parse_error)).0
) : d0eclist
//
val () =
  if ~has_lex_error (buf, 0) then let
    val i = first_parse_error (buf, 0, ~1)
  in
    if i >= 0 then
      report_at
      ( path, buf
      , textbuf_err_off (buf, i), RULE_parse_error, textbuf_err_msg (buf, i)
      ) (* end of [report_at] *)
  end // end of [if]
//
val ctx = TCTX (path, 0, list_vt_nil (), list_vt_nil ())
//
val () = d0eclist_walk (ctx, buf, d0cs)
//
val+~TCTX (_, _, stls, funs) = ctx
val stls = list_vt_reverse (stls)
val stls2 = list_vt_copy (stls)
val () = check_staloads (path, buf, stls2, stls, ishats)
val () = list_vt_free (stls)
val () = list_vt_free (stls2)
//
val funs2 = list_vt_copy (funs)
val () = check_end_comments (path, buf, funs2, funs)
val () = list_vt_free (funs)
val () = list_vt_free (funs2)
//
in
  // nothing
end // end of [patslint_tree]

(* ****** ****** *)

(* end of [patslint_tree.dats] *)
