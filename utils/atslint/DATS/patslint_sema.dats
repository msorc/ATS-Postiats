(*
** SPDX-FileCopyrightText: 2026 Mikhail Sorochan
** SPDX-License-Identifier: GPL-3.0-or-later
*)

(* ****** ****** *)
//
// patslint: the rules after the binding of the names (--semantic)
//
// The file is translated as patsopt does up to the binding of the
// names (trans1 and trans2, with the prelude loaded once): every
// name then refers to its variable (d2var). The walk of the tree of
// level 2 counts the uses of each variable (in its [utimes] field,
// which only the type erasure would set otherwise) and records the
// local bindings; then:
//
// unused-var: a local val, var or pattern variable never used
// unused-fun: a local function never used (its recursive calls
//   count as uses)
// unused-arg: an argument of a function or a lambda never used
// shadow: a local name that hides a local name of an enclosing
//   block (a rebinding in the same block, as in val x = f (x), is
//   the usual way of threading a value and is not reported)
// nonexhaustive: the clauses of a plain [case] (or the pattern of a
//   plain [val]) that do not cover all the constructors; the types
//   may still rule out what is missing (case+ is checked with them
//   by the compiler, case- not at all)
//
// A name that starts with [_] is never reported. A file with errors
// (of the compiler) is skipped, with a note on stderr. Macros (macdef)
// that use a variable count as its uses where they are used.
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
staload UN = "prelude/SATS/unsafe.sats"
//
staload SYM = "src/pats_symbol.sats"
staload LOC = "src/pats_location.sats"
staload FIL = "src/pats_filename.sats"
staload ERR = "src/pats_error.sats"
staload LBF = "src/pats_lexbuf.sats"
staload TBF = "src/pats_tokbuf.sats"
staload PAR = "src/pats_parsing.sats"
staload TRANS1 = "src/pats_trans1.sats"
staload DYNEXP1 = "src/pats_dynexp1.sats"
typedef d1eclist = $DYNEXP1.d1eclist
staload TRENV1 = "src/pats_trans1_env.sats"
staload TRANS2 = "src/pats_trans2.sats"
staload TRENV2 = "src/pats_trans2_env.sats"
staload PATCST2 = "src/pats_patcst2.sats"
//
staload "src/pats_basics.sats"
staload "src/pats_lexing.sats"
staload "src/pats_syntax.sats"
staload "src/pats_dynexp2.sats"
//
(* ****** ****** *)

staload "./../SATS/patslint.sats"

(* ****** ****** *)

fn
loc_beg (loc: location): int =
  g0int2int_lint_int ($LOC.location_beg_ntot (loc))

fn
d2var_name
  (d2v: d2var): string = $SYM.symbol_get_name (d2var_get_sym (d2v))

(* ****** ****** *)
//
// the kinds of the bindings
//
#define BIND_var 0
#define BIND_fun 1
#define BIND_arg 2
//
typedef binder = @(d2var, int(*kind*))
typedef scoped = @(string(*name*), int(*block*))
//
datavtype
sctx =
SCTX of
(
  string(*path*)
, int(*depth: 0 at the top level*)
, int(*nobind: in an included file*)
, int(*block: the current block*)
, int(*the number of blocks*)
, List0_vt(binder)(*the local bindings*)
, List0_vt(scoped)(*the names in scope (the last one first)*)
, List0_vt(ptr)(*the macros whose bodies are walked*)
) (* end of [sctx] *)
//
(* ****** ****** *)

fn
ctx_path
  (ctx: !sctx): string = let
  val+SCTX (path, _, _, _, _, _, _, _) = ctx in path
end // end of [ctx_path]

fn
ctx_depth
  (ctx: !sctx): int = let
  val+SCTX (_, depth, _, _, _, _, _, _) = ctx in depth
end // end of [ctx_depth]

fn
ctx_nobind
  (ctx: !sctx): int = let
  val+SCTX (_, _, nobind, _, _, _, _, _) = ctx in nobind
end // end of [ctx_nobind]

fn
ctx_add_depth
  (ctx: !sctx, k: int): void = let
  val+@SCTX (_, depth, _, _, _, _, _, _) = ctx
  val () = depth := depth + k
  prval () = fold@ (ctx)
in
  // nothing
end // end of [ctx_add_depth]

fn
ctx_add_nobind
  (ctx: !sctx, k: int): void = let
  val+@SCTX (_, _, nobind, _, _, _, _, _) = ctx
  val () = nobind := nobind + k
  prval () = fold@ (ctx)
in
  // nothing
end // end of [ctx_add_nobind]

(* ****** ****** *)
//
// the blocks: a new block is entered with [ctx_block_enter], which
// returns what [ctx_block_leave] needs to restore the enclosing one
//
fn
ctx_block_enter
  (ctx: !sctx): @(int, int) = let
  val+@SCTX (_, _, _, block, nblock, _, scope, _) = ctx
  val saved = @(block, list_vt_length (scope))
  val () = nblock := nblock + 1
  val () = block := nblock
  prval () = fold@ (ctx)
in
  saved
end // end of [ctx_block_enter]

fun
scope_drop
  (xs: List0_vt(scoped), k: int): List0_vt(scoped) =
  if k > 0 then
  (
    case+ xs of
    | ~list_vt_cons (_, xs) => scope_drop (xs, k - 1)
    | ~list_vt_nil () => list_vt_nil ()
  ) else xs
// end of [scope_drop]

fn
ctx_block_leave
  (ctx: !sctx, saved: @(int, int)): void = let
  val+@SCTX (_, _, _, block, _, _, scope, _) = ctx
  val n = list_vt_length (scope)
  val () = scope := scope_drop (scope, n - saved.1)
  val () = block := saved.0
  prval () = fold@ (ctx)
in
  // nothing
end // end of [ctx_block_leave]

(* ****** ****** *)

//
// a name that is empty, starts with [_] or has a [$] (a name made by
// the compiler) is not reported
//
extern fun
name_is_ignored (name: string): bool = "mac#patslint_name_ignored"

fun
scope_find_other
(
  xs: !List0_vt(scoped), name: string, block: int
) : bool =
(
case+ xs of
| list_vt_cons (x, xs1) =>
  (
    if x.0 = name
      then x.1 != block else scope_find_other (xs1, name, block)
  )
| list_vt_nil () => false
) (* end of [scope_find_other] *)

(* ****** ****** *)

fn
binds_add
  {n:nat}
(
  c: bool, x: binder, xs: list_vt(binder, n)
) : List0_vt(binder) = if c then list_vt_cons (x, xs) else xs

fn
ptrs_add
  {n:nat}
(
  c: bool, x: ptr, xs: list_vt(ptr, n)
) : List0_vt(ptr) = if c then list_vt_cons (x, xs) else xs

(* ****** ****** *)
//
// a binding: it is recorded if it is local (and not in an included
// file), and its name is checked against the enclosing blocks
//
fn
ctx_bind
(
  ctx: !sctx, buf: !textbuf, d2v: d2var, kind: int
) : void = let
//
val name = d2var_name (d2v)
//
in
//
if ~name_is_ignored (name) && ctx_nobind (ctx) = 0 then let
  val path = ctx_path (ctx)
  val islocal = ctx_depth (ctx) > 0
  val+@SCTX (_, _, _, block, _, binds, scope, _) = ctx
  val () =
    if islocal && scope_find_other (scope, name, block) then
      report_at
      ( path, buf, loc_beg (d2var_get_loc (d2v)), RULE_shadow
      , msg_format2s ("[%s] hides an enclosing [%s]", name, name)
      ) (* end of [report_at] *)
    // end of [if]
  val () = binds := binds_add (islocal || kind = BIND_arg, @(d2v, kind), binds)
  val () = scope := list_vt_cons (@(name, block), scope)
  prval () = fold@ (ctx)
in
  // nothing
end // end of [if]
//
end // end of [ctx_bind]

(* ****** ****** *)
//
// a macro is walked at its first use only
//
fun
ptrlst_mem
  (xs: !List0_vt(ptr), p: ptr): bool =
(
case+ xs of
| list_vt_cons (x, xs1) => if x = p then true else ptrlst_mem (xs1, p)
| list_vt_nil () => false
) (* end of [ptrlst_mem] *)

fn
ctx_mac_first
  (ctx: !sctx, m: d2mac): bool = let
  val p = $UN.cast{ptr}(m)
  val+@SCTX (_, _, _, _, _, _, _, macs) = ctx
  val isnew = ~ptrlst_mem (macs, p)
  val () = macs := ptrs_add (isnew, p, macs)
  prval () = fold@ (ctx)
in
  isnew
end // end of [ctx_mac_first]

(* ****** ****** *)
//
extern fun d2ecl_walk (ctx: !sctx, buf: !textbuf, x: d2ecl): void
extern fun d2eclist_walk (ctx: !sctx, buf: !textbuf, xs: d2eclist): void
extern fun d2exp_walk (ctx: !sctx, buf: !textbuf, x: d2exp): void
extern fun d2explst_walk (ctx: !sctx, buf: !textbuf, xs: d2explst): void
extern fun d2expopt_walk (ctx: !sctx, buf: !textbuf, opt: d2expopt): void
extern fun p2at_bind (ctx: !sctx, buf: !textbuf, x: p2at, kind: int): void
extern fun p2atlst_bind
  (ctx: !sctx, buf: !textbuf, xs: p2atlst, kind: int): void
//

implement
p2atlst_bind
  (ctx, buf, xs, kind) =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) =>
  (p2at_bind (ctx, buf, x, kind); p2atlst_bind (ctx, buf, xs, kind))
| ~GLnil() => ()
) (* end of [p2atlst_bind] *)

fun
labp2atlst_bind
(
  ctx: !sctx, buf: !textbuf, xs: labp2atlst, kind: int
) : void =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) => let
    val () =
    (
      case+ labp2at_view(x) of
      | ~LABP2ATnorm(_, p) => p2at_bind (ctx, buf, p, kind)
      | ~LABP2ATomit(_) => ()
    ) : void
  in
    labp2atlst_bind (ctx, buf, xs, kind)
  end // end of [GLcons]
| ~GLnil() => ()
) (* end of [labp2atlst_bind] *)

implement
p2at_bind
  (ctx, buf, x, kind) =
(
case+ p2at_node_view(x.p2at_node ()) of
| ~P2Tvar(d2v) => ctx_bind (ctx, buf, d2v, kind)
| ~P2Tcon(_, _, _, _, _, ps) => p2atlst_bind (ctx, buf, ps, kind)
| ~P2Tlst(_, ps) => p2atlst_bind (ctx, buf, ps, kind)
| ~P2Trec(_, _, lps) => labp2atlst_bind (ctx, buf, lps, kind)
| ~P2Trefas(d2v, p) =>
  (ctx_bind (ctx, buf, d2v, kind); p2at_bind (ctx, buf, p, kind))
| ~P2Texist(_, p) => p2at_bind (ctx, buf, p, kind)
| ~P2Tvbox(d2v) => ctx_bind (ctx, buf, d2v, kind)
| ~P2Tann(p, _) => p2at_bind (ctx, buf, p, kind)
| ~P2Tlist(_, ps) => p2atlst_bind (ctx, buf, ps, kind)
| v (*rest*) => p2at_node_view_free (v)
) (* end of [p2at_bind] *)

(* ****** ****** *)
//
// nonexhaustive: the first pattern that the clauses miss is printed
// in the message
//
//
// the rows of patterns that are missed (three at most) are printed
// in the message
//
fun
fprint_rows
(
  out: FILEref, xss: !$PATCST2.p2atcstlstlst_vt, k: int
) : void =
(
case+ xss of
| list_vt_cons (xs, xss1) =>
  (
    if k >= 3 then fprint_string (out, " | ...") else let
      val () = if k > 0 then fprint_string (out, " | ")
      val () =
        $PATCST2.fprint_p2atcstlst (out, $PATCST2.p2atcstlst_of_vt (xs))
    in
      fprint_rows (out, xss1, k + 1)
    end
  )
| list_vt_nil () => ()
) (* end of [fprint_rows] *)

fn
report_missing
(
  ctx: !sctx, buf: !textbuf, loc: location, xss: !$PATCST2.p2atcstlstlst_vt
) : void = let
  val out = memstr_open ()
  val () = fprint_rows (out, xss, 0)
  val pat = memstr_close (out)
in
  report_at
  ( ctx_path (ctx), buf, loc_beg (loc), RULE_nonexhaustive
  , msg_format2s ("the patterns do not cover %s%s", pat, "")
  ) (* end of [report_at] *)
end // end of [report_missing]

fun
patcst_diff_loop
(
  xss: $PATCST2.p2atcstlstlst_vt
, p2tcs: $PATCST2.p2atcstlst, res: $PATCST2.p2atcstlstlst_vt
) : $PATCST2.p2atcstlstlst_vt =
(
case+ xss of
| ~list_vt_cons (xs, xss) => let
    val diff =
      $PATCST2.p2atcstlst_diff ($PATCST2.p2atcstlst_of_vt (xs), p2tcs)
    val () = list_vt_free (xs)
  in
    patcst_diff_loop (xss, p2tcs, list_vt_reverse_append (diff, res))
  end // end of [list_vt_cons]
| ~list_vt_nil () => list_vt_reverse (res)
) (* end of [patcst_diff_loop] *)

fun
c2laulst_uncovered
(
  cls: c2laulst, cp: $PATCST2.p2atcstlstlst_vt
) : $PATCST2.p2atcstlstlst_vt =
(
case+ glist_view(cls) of
| ~GLcons(c2l, cls) =>
  (
    if glist_is_nil (c2l.c2lau_gua ()) then let
      val p2tcs = $PATCST2.p2at2cstlst (c2l.c2lau_pat ())
    in
      c2laulst_uncovered (cls, patcst_diff_loop (cp, p2tcs, list_vt_nil ()))
    end else c2laulst_uncovered (cls, cp)
  )
| ~GLnil() => cp
) (* end of [c2laulst_uncovered] *)

fn
check_case
(
  ctx: !sctx, buf: !textbuf, loc: location, cls: c2laulst
) : void =
(
case+ glist_view(cls) of
| ~GLcons(c2l, rest) => let
    val cp0 = $PATCST2.c2lau_pat_comp (c2l)
    val cp = c2laulst_uncovered (rest, cp0)
    val () =
      if list_vt_is_cons (cp) then report_missing (ctx, buf, loc, cp)
    // end of [val]
  in
    $PATCST2.p2atcstlstlst_vt_free (cp)
  end // end of [GLcons]
| ~GLnil() => ()
) (* end of [check_case] *)

fn
check_valpat
(
  ctx: !sctx, buf: !textbuf, p2t: p2at
) : void = let
  val cp = $PATCST2.p2atcst_comp ($PATCST2.p2at2cst (p2t))
  //
  // each alternative is a row of one pattern
  //
  fun rows
  (
    xs: List0_vt($PATCST2.p2atcst), res: $PATCST2.p2atcstlstlst_vt
  ) : $PATCST2.p2atcstlstlst_vt =
  (
    case+ xs of
    | ~list_vt_cons (x, xs) => rows (xs, list_vt_cons (list_vt_sing (x), res))
    | ~list_vt_nil () => list_vt_reverse (res)
  )
  val cp = rows (cp, list_vt_nil ())
  val () =
    if list_vt_is_cons (cp)
      then report_missing (ctx, buf, p2t.p2at_loc (), cp)
    // end of [if]
in
  $PATCST2.p2atcstlstlst_vt_free (cp)
end // end of [check_valpat]

(* ****** ****** *)

implement
d2eclist_walk
  (ctx, buf, xs) =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) => (d2ecl_walk (ctx, buf, x); d2eclist_walk (ctx, buf, xs))
| ~GLnil() => ()
) (* end of [d2eclist_walk] *)

fun
f2undeclst_bind
(
  ctx: !sctx, buf: !textbuf, xs: f2undeclst
) : void =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) =>
  let
    val () = ctx_bind (ctx, buf, x.f2undec_var (), BIND_fun)
  in
    f2undeclst_bind (ctx, buf, xs)
  end
| ~GLnil() => ()
) (* end of [f2undeclst_bind] *)

fun
f2undeclst_walk
(
  ctx: !sctx, buf: !textbuf, xs: f2undeclst
) : void =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) =>
  (d2exp_walk (ctx, buf, x.f2undec_def ()); f2undeclst_walk (ctx, buf, xs))
| ~GLnil() => ()
) (* end of [f2undeclst_walk] *)

fun
v2aldeclst_walk
(
  ctx: !sctx, buf: !textbuf, xs: v2aldeclst, knd: valkind
) : void =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) => let
    val p2t = x.v2aldec_pat ()
    val () = d2exp_walk (ctx, buf, x.v2aldec_def ())
    val () =
    (
      case+ knd of
      | VK_val () => check_valpat (ctx, buf, p2t) | _ => ()
    ) : void
    val () = p2at_bind (ctx, buf, p2t, BIND_var)
  in
    v2aldeclst_walk (ctx, buf, xs, knd)
  end // end of [GLcons]
| ~GLnil() => ()
) (* end of [v2aldeclst_walk] *)

fun
v2ardeclst_walk
(
  ctx: !sctx, buf: !textbuf, xs: v2ardeclst
) : void =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) => let
    val () = d2expopt_walk (ctx, buf, x.v2ardec_init ())
    val () = ctx_bind (ctx, buf, x.v2ardec_dvar (), BIND_var)
  in
    v2ardeclst_walk (ctx, buf, xs)
  end // end of [GLcons]
| ~GLnil() => ()
) (* end of [v2ardeclst_walk] *)

fun
prv2ardeclst_walk
(
  ctx: !sctx, buf: !textbuf, xs: prv2ardeclst
) : void =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) =>
  let
    val () = d2expopt_walk (ctx, buf, x.prv2ardec_init ())
  in
    prv2ardeclst_walk (ctx, buf, xs)
  end
| ~GLnil() => ()
) (* end of [prv2ardeclst_walk] *)

implement
d2ecl_walk
  (ctx, buf, x) =
(
case+ d2ecl_node_view(x.d2ecl_node ()) of
//
| ~D2Clist(ds) => d2eclist_walk (ctx, buf, ds)
| ~D2Cextvar(_, e) => d2exp_walk (ctx, buf, e)
| ~D2Cimpdec(_, dec) => d2exp_walk (ctx, buf, dec.i2mpdec_def ())
//
// the functions are bound before their bodies (they may be
// mutually recursive)
//
| ~D2Cfundecs(_, _, decs) =>
  (f2undeclst_bind (ctx, buf, decs); f2undeclst_walk (ctx, buf, decs))
//
| ~D2Cvaldecs(knd, decs) => v2aldeclst_walk (ctx, buf, decs, knd)
| ~D2Cvaldecs_rec(knd, decs) => v2aldeclst_walk (ctx, buf, decs, knd)
| ~D2Cvardecs(decs) => v2ardeclst_walk (ctx, buf, decs)
| ~D2Cprvardecs(decs) => prv2ardeclst_walk (ctx, buf, decs)
//
| ~D2Cinclude(_, ds) => let
    val () = ctx_add_nobind (ctx, 1)
    val () = d2eclist_walk (ctx, buf, ds)
  in
    ctx_add_nobind (ctx, ~1)
  end // end of [D2Cinclude]
//
| ~D2Clocal(ds1, ds2) => let
    val () = ctx_add_depth (ctx, 1)
    val () = d2eclist_walk (ctx, buf, ds1)
    val () = ctx_add_depth (ctx, ~1)
  in
    d2eclist_walk (ctx, buf, ds2)
  end // end of [D2Clocal]
//
| v (*rest*) => d2ecl_node_view_free (v)
//
) (* end of [d2ecl_walk] *)

(* ****** ****** *)

implement
d2explst_walk
  (ctx, buf, xs) =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) => (d2exp_walk (ctx, buf, x); d2explst_walk (ctx, buf, xs))
| ~GLnil() => ()
) (* end of [d2explst_walk] *)

implement
d2expopt_walk
  (ctx, buf, opt) =
(
case+ gopt_view(opt) of
| ~GOsome(x) => d2exp_walk (ctx, buf, x) | ~GOnone() => ()
) (* end of [d2expopt_walk] *)

fun
d2varlst_use
  (xs: d2varlst): void =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) => (d2var_inc_utimes (x); d2varlst_use (xs))
| ~GLnil() => ()
) (* end of [d2varlst_use] *)

fun
i2nvarglst_use
  (xs: i2nvarglst): void =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) => (d2var_inc_utimes (x.i2nvarg_var ()); i2nvarglst_use (xs))
| ~GLnil() => ()
) (* end of [i2nvarglst_use] *)

fn
i2nvresstate_use
  (x: i2nvresstate): void = i2nvarglst_use (x.i2nvresstate_arg ())

fn
loopi2nv_use
  (x: loopi2nv): void = let
  val () = i2nvarglst_use (x.loopi2nv_arg ())
in
  i2nvresstate_use (x.loopi2nv_res ())
end // end of [loopi2nv_use]

fun
labd2explst_walk
(
  ctx: !sctx, buf: !textbuf, xs: labd2explst
) : void =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) =>
  (d2exp_walk (ctx, buf, x.labd2exp_elt ()); labd2explst_walk (ctx, buf, xs))
| ~GLnil() => ()
) (* end of [labd2explst_walk] *)

fun
d2exparglst_walk
(
  ctx: !sctx, buf: !textbuf, xs: d2exparglst
) : void =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) => let
    val () =
    (
      case+ d2exparg_view(x) of
      | ~D2EXPARGdyn(_, _, es) => d2explst_walk (ctx, buf, es)
      | ~D2EXPARGsta(_, _) => ()
    ) : void
  in
    d2exparglst_walk (ctx, buf, xs)
  end // end of [GLcons]
| ~GLnil() => ()
) (* end of [d2exparglst_walk] *)

fun
d2lablst_walk
(
  ctx: !sctx, buf: !textbuf, xs: d2lablst
) : void =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) => let
    val () =
    (
      case+ d2lab_node_view(x.d2lab_node ()) of
      | ~D2LABind(es) => d2explst_walk (ctx, buf, es)
      | ~D2LABlab(_) => ()
    ) : void
  in
    d2lablst_walk (ctx, buf, xs)
  end // end of [GLcons]
| ~GLnil() => ()
) (* end of [d2lablst_walk] *)

fun
gm2atlst_walk
(
  ctx: !sctx, buf: !textbuf, xs: gm2atlst
) : void =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) => let
    val () = d2exp_walk (ctx, buf, x.gm2at_exp ())
    val () =
    (
      case+ gopt_view(x.gm2at_pat ()) of
      | ~GOsome(p) => p2at_bind (ctx, buf, p, BIND_var)
      | ~GOnone() => ()
    ) : void
  in
    gm2atlst_walk (ctx, buf, xs)
  end // end of [GLcons]
| ~GLnil() => ()
) (* end of [gm2atlst_walk] *)

fun
c2laulst_walk
(
  ctx: !sctx, buf: !textbuf, xs: c2laulst
) : void =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) => let
    val saved = ctx_block_enter (ctx)
    val () = p2atlst_bind (ctx, buf, x.c2lau_pat (), BIND_var)
    val () = gm2atlst_walk (ctx, buf, x.c2lau_gua ())
    val () = d2exp_walk (ctx, buf, x.c2lau_body ())
    val () = ctx_block_leave (ctx, saved)
  in
    c2laulst_walk (ctx, buf, xs)
  end // end of [GLcons]
| ~GLnil() => ()
) (* end of [c2laulst_walk] *)

fun
sc2laulst_walk
(
  ctx: !sctx, buf: !textbuf, xs: sc2laulst
) : void =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) =>
  (d2exp_walk (ctx, buf, x.sc2lau_body ()); sc2laulst_walk (ctx, buf, xs))
| ~GLnil() => ()
) (* end of [sc2laulst_walk] *)

fun
i2fclist_walk
(
  ctx: !sctx, buf: !textbuf, xs: i2fclist
) : void =
(
case+ glist_view(xs) of
| ~GLcons(x, xs) => let
    val () = d2exp_walk (ctx, buf, x.i2fcl_test ())
    val () = d2exp_walk (ctx, buf, x.i2fcl_body ())
  in
    i2fclist_walk (ctx, buf, xs)
  end // end of [GLcons]
| ~GLnil() => ()
) (* end of [i2fclist_walk] *)

(* ****** ****** *)
//
// a lambda: its arguments are bound in a new block, at a depth > 0
//
fn
lam_walk
(
  ctx: !sctx, buf: !textbuf, ps: p2atlst, body: d2exp
) : void = let
  val saved = ctx_block_enter (ctx)
  val () = ctx_add_depth (ctx, 1)
  val () = p2atlst_bind (ctx, buf, ps, BIND_arg)
  val () = d2exp_walk (ctx, buf, body)
  val () = ctx_add_depth (ctx, ~1)
in
  ctx_block_leave (ctx, saved)
end // end of [lam_walk]

implement
d2exp_walk
  (ctx, buf, x) = let
//
val loc0 = x.d2exp_loc ()
//
in
//
case+ d2exp_node_view(x.d2exp_node ()) of
//
| ~D2Evar(d2v) => d2var_inc_utimes (d2v)
//
| ~D2Eliteral(e) => d2exp_walk (ctx, buf, e)
| ~D2Eextfcall(_, _, es) => d2explst_walk (ctx, buf, es)
| ~D2Eextmcall(_, e, _, es) =>
  (d2exp_walk (ctx, buf, e); d2explst_walk (ctx, buf, es))
| ~D2Econ(_, _, _, _, _, es) => d2explst_walk (ctx, buf, es)
| ~D2Efoldat(_, e) => d2exp_walk (ctx, buf, e)
| ~D2Efreeat(_, e) => d2exp_walk (ctx, buf, e)
| ~D2Etmpid(e, _) => d2exp_walk (ctx, buf, e)
//
| ~D2Elet(ds, e) => let
    val saved = ctx_block_enter (ctx)
    val () = ctx_add_depth (ctx, 1)
    val () = d2eclist_walk (ctx, buf, ds)
    val () = d2exp_walk (ctx, buf, e)
    val () = ctx_add_depth (ctx, ~1)
  in
    ctx_block_leave (ctx, saved)
  end // end of [D2Elet]
| ~D2Ewhere(e, ds) => let
    val saved = ctx_block_enter (ctx)
    val () = ctx_add_depth (ctx, 1)
    val () = d2eclist_walk (ctx, buf, ds)
    val () = d2exp_walk (ctx, buf, e)
    val () = ctx_add_depth (ctx, ~1)
  in
    ctx_block_leave (ctx, saved)
  end // end of [D2Ewhere]
//
| ~D2Eapplst(e, args) =>
  (d2exp_walk (ctx, buf, e); d2exparglst_walk (ctx, buf, args))
| ~D2Eifhead(inv, e1, e2, opt) => let
    val () = i2nvresstate_use (inv)
    val () = d2exp_walk (ctx, buf, e1)
    val () = d2exp_walk (ctx, buf, e2)
  in
    d2expopt_walk (ctx, buf, opt)
  end // end of [D2Eifhead]
| ~D2Esifhead(inv, _, e1, e2) =>
  (i2nvresstate_use (inv); d2exp_walk (ctx, buf, e1); d2exp_walk (ctx, buf, e2))
| ~D2Eifcasehd(_, inv, cls) =>
  (i2nvresstate_use (inv); i2fclist_walk (ctx, buf, cls))
| ~D2Ecasehead(knd, inv, es, cls) => let
    val () = i2nvresstate_use (inv)
    val () = d2explst_walk (ctx, buf, es)
    val () =
    (
      case+ knd of
      | CK_case () => check_case (ctx, buf, loc0, cls) | _ => ()
    ) : void
  in
    c2laulst_walk (ctx, buf, cls)
  end // end of [D2Ecasehead]
| ~D2Escasehead(inv, _, cls) =>
  (i2nvresstate_use (inv); sc2laulst_walk (ctx, buf, cls))
//
| ~D2Esing(e) => d2exp_walk (ctx, buf, e)
| ~D2Elist(_, es) => d2explst_walk (ctx, buf, es)
| ~D2Elst(_, _, es) => d2explst_walk (ctx, buf, es)
| ~D2Etup(_, _, es) => d2explst_walk (ctx, buf, es)
| ~D2Erec(_, _, les) => labd2explst_walk (ctx, buf, les)
| ~D2Eseq(es) => d2explst_walk (ctx, buf, es)
| ~D2Eselab(e, labs) =>
  (d2exp_walk (ctx, buf, e); d2lablst_walk (ctx, buf, labs))
| ~D2Eptrof(e) => d2exp_walk (ctx, buf, e)
| ~D2Eviewat(e) => d2exp_walk (ctx, buf, e)
| ~D2Ederef(_, e) => d2exp_walk (ctx, buf, e)
| ~D2Eassgn(e1, e2) => (d2exp_walk (ctx, buf, e1); d2exp_walk (ctx, buf, e2))
| ~D2Exchng(e1, e2) => (d2exp_walk (ctx, buf, e1); d2exp_walk (ctx, buf, e2))
| ~D2Earrsub(_, e, _, es) =>
  (d2exp_walk (ctx, buf, e); d2explst_walk (ctx, buf, es))
| ~D2Earrpsz(_, es) => d2explst_walk (ctx, buf, es)
| ~D2Earrinit(_, opt, es) =>
  (d2expopt_walk (ctx, buf, opt); d2explst_walk (ctx, buf, es))
| ~D2Eraise(e) => d2exp_walk (ctx, buf, e)
| ~D2Eeffmask(_, e) => d2exp_walk (ctx, buf, e)
| ~D2Evararg(es) => d2explst_walk (ctx, buf, es)
| ~D2Evcopyenv(_, e) => d2exp_walk (ctx, buf, e)
| ~D2Eshowtype(e) => d2exp_walk (ctx, buf, e)
| ~D2Etempenver(d2vs) => d2varlst_use (d2vs)
| ~D2Eexist(_, e) => d2exp_walk (ctx, buf, e)
//
| ~D2Elam_dyn(_, _, ps, e) => lam_walk (ctx, buf, ps, e)
| ~D2Elaminit_dyn(_, _, ps, e) => lam_walk (ctx, buf, ps, e)
| ~D2Elam_sta(_, _, e) => d2exp_walk (ctx, buf, e)
| ~D2Elam_met(_, _, e) => d2exp_walk (ctx, buf, e)
| ~D2Efix(_, _, e) => d2exp_walk (ctx, buf, e)
| ~D2Edelay(e) => d2exp_walk (ctx, buf, e)
| ~D2Eldelay(e, opt) =>
  (d2exp_walk (ctx, buf, e); d2expopt_walk (ctx, buf, opt))
| ~D2Efor(inv, e1, e2, e3, e4) => let
    val () = loopi2nv_use (inv)
    val () = d2exp_walk (ctx, buf, e1)
    val () = d2exp_walk (ctx, buf, e2)
    val () = d2exp_walk (ctx, buf, e3)
  in
    d2exp_walk (ctx, buf, e4)
  end // end of [D2Efor]
| ~D2Ewhile(inv, e1, e2) =>
  (loopi2nv_use (inv); d2exp_walk (ctx, buf, e1); d2exp_walk (ctx, buf, e2))
| ~D2Etrywith(inv, e, cls) =>
  let
    val () = i2nvresstate_use (inv)
    val () = d2exp_walk (ctx, buf, e)
  in
    c2laulst_walk (ctx, buf, cls)
  end
| ~D2Eann_type(e, _) => d2exp_walk (ctx, buf, e)
| ~D2Eann_seff(e, _) => d2exp_walk (ctx, buf, e)
| ~D2Eann_funclo(e, _) => d2exp_walk (ctx, buf, e)
//
| ~D2Emac(m) =>
    if ctx_mac_first (ctx, m) then d2exp_walk (ctx, buf, d2mac_get_def (m))
| ~D2Emacsyn(_, e) => d2exp_walk (ctx, buf, e)
| ~D2Emacfun(_, es) => d2explst_walk (ctx, buf, es)
| ~D2Esolassert(e) => d2exp_walk (ctx, buf, e)
//
| v (*rest*) => d2exp_node_view_free (v)
//
end // end of [d2exp_walk]

(* ****** ****** *)

fun
report_unused
(
  path: string, buf: !textbuf, xs: List0_vt(binder)
) : void =
(
case+ xs of
| ~list_vt_cons (x, xs) => let
    val d2v = x.0
    val () =
      if d2var_get_utimes (d2v) = 0 then let
        val name = d2var_name (d2v)
        val rule =
        (
          case+ x.1 of
          | BIND_fun => RULE_unused_fun
          | BIND_arg => RULE_unused_arg
          | _ (*var*) => RULE_unused_var
        ) : int
      in
        report_at
        ( path, buf, loc_beg (d2var_get_loc (d2v)), rule
        , msg_format2s ("[%s] is never used%s", name, "")
        ) (* end of [report_at] *)
      end // end of [if]
  in
    report_unused (path, buf, xs)
  end // end of [list_vt_cons]
| ~list_vt_nil () => ()
) (* end of [report_unused] *)

(* ****** ****** *)
//
// the set-up of the compiler, once: PATSHOME and the prelude
//
%{^
extern void patsopt_PATSHOME_set(void);
extern char *patsopt_PATSHOME_get(void);
extern void patsopt_PATSCONTRIB_set(void);
extern void patsopt_PATSRELOCROOT_set(void);
extern void patsopt_PATSHOMELOCS_set(void);
extern void libatsopt_the_prelude_load(void *PATSHOME);
static int patslint_sema_state = 0; /* 0: to do, 1: done, -1: failed */
static int patslint_sema_state_get(void) { return patslint_sema_state; }
static void patslint_sema_state_set(int k) { patslint_sema_state = k; }
%}
//
extern fun sema_state_get (): int = "mac#patslint_sema_state_get"
extern fun sema_state_set (k: int): void = "mac#patslint_sema_state_set"
//
fn
sema_setup (): bool = let
  val st = sema_state_get ()
in
//
if st != 0 then st > 0 else let
  extern fun set1 (): void = "mac#patsopt_PATSHOME_set"
  extern fun set2 (): void = "mac#patsopt_PATSCONTRIB_set"
  extern fun set3 (): void = "mac#patsopt_PATSRELOCROOT_set"
  extern fun set4 (): void = "mac#patsopt_PATSHOMELOCS_set"
  extern fun get (): Stropt = "mac#patsopt_PATSHOME_get"
  extern fun
  prelude_load (home: string): void = "mac#libatsopt_the_prelude_load"
  val () = (set1 (); set2 (); set3 (); set4 ())
  val opt = get ()
in
  if stropt_is_none (opt) then let
    val () = sema_state_set (~1)
    val () = prerrln! ("patslint: --semantic needs PATSHOME (the root of ATS2)")
  in
    false
  end else let
    val home = stropt_unsome (opt)
    val () = $FIL.the_prepathlst_push (home)
    val () = $TRENV1.the_trans1_env_initialize ()
    val () = $TRENV2.the_trans2_env_initialize ()
    val () = stderr_off ()
    val ok =
    (
      try (prelude_load (home); true) with
      | ~($ERR.FatalErrorExn()) => false
      | ~($ERR.FatalErrorExn_interr()) => false
    ) : bool
    val () = stderr_on ()
    val () = sema_state_set (if ok then 1 else ~1)
    val () =
      if ~ok then
        prerrln! ("patslint: --semantic: the prelude cannot be loaded")
  in
    ok
  end
end // end of [if]
//
end // end of [sema_setup]

(* ****** ****** *)
fun
filenamelst_restore
  (fil0: $FIL.filename, k: int): void =
  if k > 0 &&
     ~($FIL.eq_filename_filename ($FIL.filename_get_current (), fil0)) then let
    val () = $FIL.the_filenamelst_ppop ()
  in
    filenamelst_restore (fil0, k - 1)
  end // end of [if]
// end of [filenamelst_restore]

//
// the translation to level 2 (the file is the current one); [None_vt]
// if the compiler reports an error. As in patsopt, the file is pushed
// with [ppush] and [trans1_finalize] pops it.
//
fn
sema_trans12
(
  path: string, buf: !textbuf, stadyn: int
) : Option_vt (d2eclist) = let
  val opt = $FIL.filenameopt_make_local (path)
in
//
case+ opt of
| ~Some_vt (fil) => let
    val fil0 = $FIL.filename_get_current ()
    val () = $FIL.the_filenamelst_ppush (fil)
    val () = stderr_off ()
    //
    // the parse records its errors (it raises no exception)
    //
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
    val () = $PAR.the_parerrlst_clear ()
    //
    val () = $TRENV2.the_trans2_env_initialize ()
    val opt1 =
    (
      if nerr > 0 then None_vt () else
      try Some_vt ($TRANS1.d0eclist_tr_errck (d0cs)) with
      | ~($ERR.FatalErrorExn()) => None_vt ()
      | ~($ERR.FatalErrorExn_interr()) => None_vt ()
      | ~($ERR.PATSOPT_FIXITY_EXN()) => None_vt ()
      | ~($ERR.PATSOPT_TRANS1_EXN()) => None_vt ()
      | ~($ERR.PATSOPT_TRANS2_EXN()) => None_vt ()
      | ~($ERR.PATSOPT_FILENONE_EXN(_)) => None_vt ()
      | exn => let
          // any other exception of the compiler: the file is skipped
          // (the exception is not freed)
          val () = $UN.castvwtp0{void}(exn) in None_vt ()
        end // end of [exn]
    ) : Option_vt (d1eclist)
    val res =
    (
      case+ opt1 of
      | ~Some_vt (d1cs) => let
          val () = $TRANS1.trans1_finalize () // the file is popped
        in
          try Some_vt ($TRANS2.d1eclist_tr_errck (d1cs)) with
          | ~($ERR.FatalErrorExn()) => None_vt ()
          | ~($ERR.FatalErrorExn_interr()) => None_vt ()
          | ~($ERR.PATSOPT_FIXITY_EXN()) => None_vt ()
          | ~($ERR.PATSOPT_TRANS1_EXN()) => None_vt ()
          | ~($ERR.PATSOPT_TRANS2_EXN()) => None_vt ()
          | ~($ERR.PATSOPT_FILENONE_EXN(_)) => None_vt ()
          | exn => let
              // any other exception of the compiler: the file is skipped
              // (the exception is not freed)
              val () = $UN.castvwtp0{void}(exn) in None_vt ()
            end // end of [exn]
        end // end of [Some_vt]
      | ~None_vt () => None_vt ()
    ) : Option_vt (d2eclist)
    //
    // an error may leave files (included, staloaded) on the stack of
    // the current files: it is popped down to the file before ours
    //
    val () = filenamelst_restore (fil0, 1000)
    val () = stderr_on ()
  in
    res
  end // end of [Some_vt]
| ~None_vt () => None_vt ()
//
end // end of [sema_trans12]

(* ****** ****** *)

implement
patslint_sema
  (path, buf, stadyn) = let
//
fun rules_on (id: int): bool =
  if id <= RULE_nonexhaustive then
  (
    if the_rule_get_sev (id) >= SEV_info then true else rules_on (id + 1)
  ) else false
//
extern fun
strcmp_at (s: string, i: int, t: string): int = "mac#patslint_strcmp_at"
val n = g0uint2int_size_int (string_length (path))
val ishats = n >= 5 && strcmp_at (path, n - 5, ".hats") = 0
//
in
//
if ~ishats && rules_on (RULE_unused_var) && sema_setup () then let
  extern fun sema_fork (): int = "mac#patslint_sema_fork"
  extern fun child_exit (ok: bool): void = "mac#patslint_sema_child_exit"
  extern fun collect (path: string): bool = "mac#patslint_sema_collect"
in
  if sema_fork () = 0 then let
    //
    // the child: its findings go to the parent
    //
    val opt = sema_trans12 (path, buf, stadyn)
  in
    case+ opt of
    | ~Some_vt (d2cs) => let
        val ctx =
          SCTX
          ( path, 0, 0, 0, 0
          , list_vt_nil (), list_vt_nil (), list_vt_nil ()
          ) (* end of [SCTX] *)
        val () = d2eclist_walk (ctx, buf, d2cs)
        val+~SCTX (_, _, _, _, _, binds, scope, macs) = ctx
        val () = list_vt_free (scope)
        val () = list_vt_free (macs)
        val () = report_unused (path, buf, list_vt_reverse (binds))
      in
        child_exit (true)
      end // end of [Some_vt]
    | ~None_vt () => child_exit (false)
  end else
  (
    if ~collect (path) then
      prerrln!
      ("patslint: --semantic: [", path, "] has errors (see patsopt): skipped")
    // end of [if]
  ) (* end of [if] *)
end // end of [if]
//
end // end of [patslint_sema]

(* ****** ****** *)

(* end of [patslint_sema.dats] *)
