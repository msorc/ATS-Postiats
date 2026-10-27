(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(* ****** ****** *)
//
// HX-2026-10: the surface printer of the static terms
// (see pats_staexp2_sprint.sats)
//
// The state (the alias table and the names of the current message) is kept in
// C statics (zero = the empty map/list), so that the module needs no dynload
// initialisation: the test drivers that link it without dynloading it work.
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)

staload INTINF = "./pats_intinf.sats"
staload SYM = "./pats_symbol.sats"
staload LAB = "./pats_label.sats"
staload EFF = "./pats_effect.sats"

(* ****** ****** *)

staload "./pats_avlmap.sats"
staload "./pats_staexp2.sats"
staload "./pats_staexp2_util.sats"
staload "./pats_staexp2_sprint.sats"

(* ****** ****** *)

#include "./pats_staexp2.hats"

(* ****** ****** *)

%{^
#include <string.h>
#include <ctype.h>
#include <stdio.h>
/*
** 0: the alias map (avlmap: s2cst -> glist of aliases)
** 1: the tkind aliases (glist)
** 2: the names of the current message (glist, the newest first)
*/
static void *patsopt_sprint_cells[4] = { 0, 0, 0, 0 } ;
ATSinline()
atstype_ptr
patsopt_sprint_cell_get (atstype_int i) { return patsopt_sprint_cells[i] ; }
ATSinline()
atsvoid_t0ype
patsopt_sprint_cell_set
  (atstype_int i, atstype_ptr x) { patsopt_sprint_cells[i] = x ; return ; }
/*
** the name of a variable without the suffix [$n] of its copies
*/
static
int patsopt_sprint_namelen (const char *s)
{
  int n = 0 ;
  if (s[0] == '$') return 0 ;
  while (s[n] && s[n] != '$') n += 1 ;
  return n ;
}
ATSinline()
atstype_bool
patsopt_sprint_name_eq
  (atstype_string s1, atstype_string s2)
{
  int n1 = patsopt_sprint_namelen ((const char*)s1) ;
  int n2 = patsopt_sprint_namelen ((const char*)s2) ;
  if (n1 != n2) return atsbool_false ;
  if (strncmp ((const char*)s1, (const char*)s2, n1) == 0) return atsbool_true ;
  return atsbool_false ;
}
ATSinline()
atsvoid_t0ype
patsopt_sprint_fprint_name
  (atstype_ptr out, atstype_string s)
{
  int n = patsopt_sprint_namelen ((const char*)s) ;
  if (n == 0) fputc ('_', (FILE*)out) ; else fwrite (s, 1, n, (FILE*)out) ;
  return ;
}
ATSinline()
atstype_bool
patsopt_sprint_isop (atstype_string s)
{
  unsigned char c = ((const unsigned char*)s)[0] ;
  if (c == 0) return atsbool_false ;
  if (isalnum (c) || c == '_' || c == '$' || c == '\'') return atsbool_false ;
  return atsbool_true ;
}
%} // end of [%{^]

(* ****** ****** *)

extern
fun cell_get (i: int): ptr = "mac#patsopt_sprint_cell_get"
extern
fun cell_set (i: int, x: ptr): void = "mac#patsopt_sprint_cell_set"
extern
fun name_eq (s1: string, s2: string): bool = "mac#patsopt_sprint_name_eq"
extern
fun fprint_name
  (out: FILEref, s: string): void = "mac#patsopt_sprint_fprint_name"
extern
fun name_isop (s: string): bool = "mac#patsopt_sprint_isop"

(* ****** ****** *)
//
// HX: the names of the variables of the current message
//
typedef vent = @{ knd= int, name= string, id= ptr, idx= int }
//
implement
sprint_reset () = cell_set (2, the_null_ptr)
//
fn varname_index
(
  knd: int, name: string, id: ptr
) : int = let
//
fun loop
(
  xs: glist(ptr), cnt: int, found: &int
) : int =
(
case+ glist_view (xs) of
| ~GLnil () => cnt
| ~GLcons (p, xs) => let
    val e = $UN.ptr0_get<vent> (p)
  in
    if e.knd != knd then loop (xs, cnt, found)
    else if ptr_eq (e.id, id) then (found := e.idx; cnt)
    else if name_eq (e.name, name) then loop (xs, cnt+1, found)
    else loop (xs, cnt, found)
  end // end of [GLcons]
)
//
val xs = $UN.cast{glist(ptr)} (cell_get (2))
var found: int = 0
val cnt = loop (xs, 0, found)
//
in
//
if found > 0 then found else let
  val idx = cnt + 1
  val p = the_garena_alloc (sizeof<vent>)
  val () = $UN.ptr0_set<vent> (p, @{ knd= knd, name= name, id= id, idx= idx })
  val () = cell_set (2, $UN.cast{ptr} (glist_cons<ptr> (p, xs)))
in
  idx
end // end of [if]
//
end // end of [varname_index]

implement
fsprint_varname
  (out, knd, sym, id) = let
  val name = $SYM.symbol_get_name (sym)
  val idx = varname_index (knd, name, id)
  val () = fprint_name (out, name)
in
  if idx >= 2 then (fprint_string (out, "#"); fprint_int (out, idx))
end // end of [fsprint_varname]

implement
sprint_s2vars_seen () = let
//
fun loop
(
  xs: glist(ptr), res: List0_vt(s2var)
) : List0_vt(s2var) =
(
case+ glist_view (xs) of
| ~GLnil () => res
| ~GLcons (p, xs) => let
    val e = $UN.ptr0_get<vent> (p)
  in
    if e.knd = 0
      then loop (xs, list_vt_cons ($UN.cast{s2var} (e.id), res))
      else loop (xs, res)
  end // end of [GLcons]
)
//
in
  loop ($UN.cast{glist(ptr)} (cell_get (2)), list_vt_nil ())
end // end of [sprint_s2vars_seen]

(* ****** ****** *)
//
// HX: the unsolved existential variables are numbered in the message
// (kind 2 of the names: [?1], [?2], ...)
//
fn fsprint_s2Var
  (out: FILEref, s2V: s2Var): void = let
  val idx = varname_index (2, "?", $UN.cast{ptr} (s2V))
in
  fprint_string (out, "?"); fprint_int (out, idx)
end // end of [fsprint_s2Var]

(* ****** ****** *)
//
// HX: the aliases: [lead] are the leading arguments of the head constant,
// [npar] the number of the remaining ones (~1: any number, a renaming)
//
typedef aent = @{ lead= s2explst, sym= symbol, npar= int }
//
typedef tkent = @{ name= string, sym= symbol }
//
fn s2exp_delink
  (s2e: s2exp): s2exp = let
//
fun loop (s2e: s2exp, n: int): s2exp =
  if n > 100 then s2e else
  if s2exp_node_is_S2EVar (s2e.s2exp_node ()) then (
    case+ s2exp_node_view (s2e.s2exp_node ()) of
    | ~S2EVar (s2V) => (
        case+ gopt_view (s2Var_get_link (s2V)) of
        | ~GOsome (s2e1) => loop (s2e1, n+1)
        | ~GOnone () => s2e
      ) // end of [S2EVar]
    | v => (s2exp_node_view_free (v); s2e)
  ) else s2e
//
in
  loop (s2e, 0)
end // end of [s2exp_delink]

(* ****** ****** *)
//
// HX: the resolution of a definition into [h(lead, x1, ..., xn)]:
// the definitions of the constants are followed (no beta-reduction,
// hence no fresh variable, no stamp is taken): see [sprint_alias_add_s2cst]
//
typedef resol = @{ ok= bool, head= ptr, lead= s2explst, npar= int }
//
fn resol_fail (): resol =
  @{ ok= false, head= the_null_ptr, lead= glist_nil (), npar= 0 }
//
// a constant without definition: any number of arguments
fn resol_cst (s2c: s2cst): resol =
  @{ ok= true, head= $UN.cast{ptr} (s2c), lead= glist_nil (), npar= ~1 }
//
fn s2var_is_s2exp
  (s2v: s2var, s2e: s2exp): bool = let
  val s2e = s2exp_delink (s2e)
in
  case+ s2exp_node_view (s2e.s2exp_node ()) of
  | ~S2Evar (s2v1) => ptr_eq ($UN.cast{ptr} (s2v), $UN.cast{ptr} (s2v1))
  | v => (s2exp_node_view_free (v); false)
end // end of [s2var_is_s2exp]

(*
** [xs] ends with the variables [s2vs]; [pre] is the rest
*)
fn s2explst_suffix_svarlst
(
  xs: s2explst, s2vs: s2varlst, pre: &s2explst? >> s2explst
) : bool = let
  val nx = glist_length<s2exp> (xs)
  val nv = glist_length<s2var> (s2vs)
//
fun split
(
  xs: s2explst, k: int, acc: List0_vt(s2exp)
, pre: &s2explst? >> s2explst
) : s2explst =
  if k > 0 then let
    val acc = list_vt_cons (glist_head<s2exp> (xs), acc)
  in
    split (glist_tail<s2exp> (xs), k-1, acc, pre)
  end
  else let
    val acc = list_vt_reverse (acc)
    val () = pre := glist_make_list_vt<s2exp> (acc)
  in
    xs
  end // end of [if]
//
fun test (xs: s2explst, s2vs: s2varlst): bool =
  case+ glist_view (s2vs) of
  | ~GLnil () => true
  | ~GLcons (s2v, s2vs) =>
      if s2var_is_s2exp (s2v, glist_head<s2exp> (xs))
        then test (glist_tail<s2exp> (xs), s2vs) else false
//
in
  if nx >= nv then let
    val suf = split (xs, nx - nv, list_vt_nil (), pre)
  in
    test (suf, s2vs)
  end else (pre := glist_nil (); false)
end // end of [s2explst_suffix_svarlst]

fun resol_s2exp
  (s2e: s2exp, depth: int): resol =
  if depth > 64 then resol_fail () else
  case+ s2exp_node_view (s2e.s2exp_node ()) of
  | ~S2Ecst (s2c) =>
    if s2cst_get_isrec (s2c)
      then resol_cst (s2c)
      else (
        case+ gopt_view (s2cst_get_def (s2c)) of
        | ~GOnone () => resol_cst (s2c)
        | ~GOsome (def) => resol_s2exp (def, depth+1)
      ) (* end of [if] *)
  | ~S2EVar (s2V) => (
      case+ gopt_view (s2Var_get_link (s2V)) of
      | ~GOsome (s2e1) => resol_s2exp (s2e1, depth+1)
      | ~GOnone () => resol_fail ()
    ) // end of [S2EVar]
  | ~S2Eapp (s2f, s2es) => let
      val r = resol_s2exp (s2f, depth+1)
    in
      if ~(r.ok) then r
      else if r.npar < 0 || r.npar = glist_length<s2exp> (s2es)
        then @{
          ok= true, head= r.head
        , lead= glist_append<s2exp> (r.lead, s2es), npar= 0
        } (* end of [then] *)
        else resol_fail ()
    end // end of [S2Eapp]
  | ~S2Elam (s2vs, s2e_body) => let
      val r = resol_s2exp (s2e_body, depth+1)
    in
      if ~(r.ok) then r
      else if r.npar != 0 then resol_fail ()
      else if glist_is_nil (s2vs) then r
      else let
        var pre: s2explst
        val test = s2explst_suffix_svarlst (r.lead, s2vs, pre)
      in
        if test
          then @{
            ok= true, head= r.head, lead= pre, npar= glist_length<s2var> (s2vs)
          } (* end of [then] *)
          else resol_fail ()
        // end of [if]
      end // end of [else]
    end // end of [S2Elam]
  | v => (s2exp_node_view_free (v); resol_fail ())
// end of [resol_s2exp]

(*
** the leading arguments of an alias must be closed (no variable)
*)
fun s2exp_is_closed
  (s2e: s2exp): bool =
  case+ s2exp_node_view (s2e.s2exp_node ()) of
  | ~S2Eint _ => true
  | ~S2Eintinf _ => true
  | ~S2Efloat _ => true
  | ~S2Estring _ => true
  | ~S2Ecst _ => true
  | ~S2Eextype (_, s2ess) => glist_is_nil (s2ess)
  | ~S2Eextkind (_, s2ess) => glist_is_nil (s2ess)
  | ~S2Eapp (s2f, s2es) =>
      if s2exp_is_closed (s2f) then s2explst_is_closed (s2es) else false
  | v => (s2exp_node_view_free (v); false)
// end of [s2exp_is_closed]

and s2explst_is_closed
  (s2es: s2explst): bool =
  case+ glist_view (s2es) of
  | ~GLnil () => true
  | ~GLcons (s2e, s2es) =>
      if s2exp_is_closed (s2e) then s2explst_is_closed (s2es) else false
// end of [s2explst_is_closed]

fn alias_add
(
  h: ptr, lead: s2explst, sym: symbol, npar: int
) : void = let
  val m = $UN.cast{avlmap} (cell_get (0))
  var v: ptr
  val found = avlmap_find (m, h, ptr_cmp, v)
  val xs =
  (
    if found then $UN.cast{glist(ptr)} (v) else glist_nil ()
  ) : glist(ptr)
  val p = the_garena_alloc (sizeof<aent>)
  val () = $UN.ptr0_set<aent> (p, @{ lead= lead, sym= sym, npar= npar })
  val xs = glist_cons<ptr> (p, xs)
  val m = avlmap_insert (m, h, $UN.cast{ptr} (xs), ptr_cmp)
in
  cell_set (0, $UN.cast{ptr} (m))
end // end of [alias_add]

implement
sprint_alias_add_s2cst
  (s2c) = (
//
case+ gopt_view (s2cst_get_def (s2c)) of
| ~GOnone () => ()
| ~GOsome (def) => let
    val r = resol_s2exp (def, 0)
  in
    if r.ok then (
      if ptr_eq (r.head, $UN.cast{ptr} (s2c)) then ()
      else if s2explst_is_closed (r.lead)
        then alias_add (r.head, r.lead, s2cst_get_sym (s2c), r.npar)
      else ()
    ) else ()
  end // end of [GOsome]
//
) (* end of [sprint_alias_add_s2cst] *)

implement
sprint_alias_add_tkind
  (s2c) = (
//
case+ gopt_view (s2cst_get_def (s2c)) of
| ~GOnone () => ()
| ~GOsome (def) => (
    case+ s2exp_node_view (def.s2exp_node ()) of
    | ~S2Eextkind (name, _) => let
        val xs = $UN.cast{glist(ptr)} (cell_get (1))
        val p = the_garena_alloc (sizeof<tkent>)
        val e = @{ name= name, sym= s2cst_get_sym (s2c) } : tkent
        val () = $UN.ptr0_set<tkent> (p, e)
      in
        cell_set (1, $UN.cast{ptr} (glist_cons<ptr> (p, xs)))
      end // end of [S2Eextkind]
    | v => s2exp_node_view_free (v)
  ) // end of [GOsome]
//
) (* end of [sprint_alias_add_tkind] *)

(* ****** ****** *)

fn tkind_find
  (name: string): ptr = let
//
fun loop (xs: glist(ptr)): ptr =
  case+ glist_view (xs) of
  | ~GLnil () => the_null_ptr
  | ~GLcons (p, xs) => let
      val e = $UN.ptr0_get<tkent> (p)
    in
      if e.name = name then p else loop (xs)
    end // end of [GLcons]
//
in
  loop ($UN.cast{glist(ptr)} (cell_get (1)))
end // end of [tkind_find]

(*
** the leading arguments [lead] match the first ones of [s2es]: then
** [rest] is the number of the remaining arguments
*)
fn lead_match
(
  lead: s2explst, s2es: s2explst, rest: &int
) : bool = let
//
fun loop
  (xs: s2explst, ys: s2explst, rest: &int): bool =
  case+ glist_view (xs) of
  | ~GLnil () => (rest := glist_length<s2exp> (ys); true)
  | ~GLcons (x, xs) =>
    if glist_is_nil (ys) then false
    else if s2exp_syneq (x, glist_head<s2exp> (ys))
      then loop (xs, glist_tail<s2exp> (ys), rest) else false
//
in
  loop (lead, s2es, rest)
end // end of [lead_match]

(*
** the alias of [h(s2es)] with the fewest remaining arguments; among
** these, an operator ([+], [>=], ...) is preferred to a name, the first
** operator registered to a later one ([!=] to [<>]), and the latest name
** to an earlier one ([int] to [int0])
*)
fn alias_find
(
  h: s2cst, s2es: s2explst
) : ptr(*aent or null*) = let
//
fun loop
(
  xs: glist(ptr), best: ptr, brest: int, bisop: bool
) : ptr =
(
case+ glist_view (xs) of
| ~GLnil () => best
| ~GLcons (p, xs) => let
    val e = $UN.ptr0_get<aent> (p)
    var rest: int = 0
    val test = lead_match (e.lead, s2es, rest)
    val test = (
      if test then (e.npar < 0 || e.npar = rest) else false
    ) : bool
  in
    if test then let
      val isop = name_isop ($SYM.symbol_get_name (e.sym))
      val better = (
        if ptr_is_null (best) then true
        else if rest < brest then true
        else if rest > brest then false
        else isop (* a name never replaces; an older operator does *)
      ) : bool
    in
      if better then loop (xs, p, rest, isop) else loop (xs, best, brest, bisop)
    end else loop (xs, best, brest, bisop)
  end // end of [GLcons]
)
//
val m = $UN.cast{avlmap} (cell_get (0))
var v: ptr
val found = avlmap_find (m, $UN.cast{ptr} (h), ptr_cmp, v)
//
in
  if found
    then loop ($UN.cast{glist(ptr)} (v), the_null_ptr, 0, false)
    else the_null_ptr
end // end of [alias_find]

(* ****** ****** *)
//
// HX: the operators (the static fixities of prelude/fixity.ats)
//
fn binop_prec
  (name: string): int =
  if name = "**" then 61
  else if name = "*" then 60
  else if name = "/" then 60
  else if name = "%" then 60
  else if name = "mod" then 60
  else if name = "+" then 50
  else if name = "-" then 50
  else if name = "<" then 40
  else if name = "<=" then 40
  else if name = ">" then 40
  else if name = ">=" then 40
  else if name = "=" then 30
  else if name = "==" then 30
  else if name = "!=" then 30
  else if name = "<>" then 30
  else if name = "&&" then 21
  else if name = "||" then 20
  else ~1
// end of [binop_prec]

(* 0: none; 1: left; 2: right *)
fn binop_assoc
  (prec: int): int =
  if prec = 61 then 2
  else if prec = 60 then 1
  else if prec = 50 then 1
  else if prec = 21 then 1
  else if prec = 20 then 1
  else 0
// end of [binop_assoc]

#define PREC_ATOM 100
#define PREC_POSTFIX 69
#define PREC_PREFIX 79
#define PREC_NEG 51
#define PREC_AT 40
#define PREC_EQEQ 30
#define PREC_FUN 10
#define PREC_QUANT 5
#define PREC_LAM 0

fn lparen (out: FILEref, b: bool): void = if b then fprint_string (out, "(")
fn rparen (out: FILEref, b: bool): void = if b then fprint_string (out, ")")

(* ****** ****** *)

fn s2rtbas_name
  (name: string): string =
  if name = "viewt0ype" then "vt@ype"
  else if name = "vt0ype" then "vt@ype"
  else if name = "viewtype" then "vtype"
  else if name = "t0ype" then "t@ype"
  else name
// end of [s2rtbas_name]

fun pr_s2rt
  (out: FILEref, s2t: s2rt, ctx: int): void = let
  val s2t = s2rt_delink (s2t)
in
//
case+ s2rt_viewof (s2t) of
| ~S2RTbas (s2tb) => (
    case+ s2rtbas_view (s2tb) of
    | ~S2RTBASpre (sym) => fprint_string (out, $SYM.symbol_get_name (sym))
    | ~S2RTBASimp (knd, sym) => let
        val () = fprint_string (out, s2rtbas_name ($SYM.symbol_get_name (sym)))
        val pol = test_polkind (knd)
      in
        if pol > 0 then fprint_string (out, "+")
        else if pol < 0 then fprint_string (out, "-")
      end // end of [S2RTBASimp]
    | ~S2RTBASdef (s2td) =>
        fprint_string (out, $SYM.symbol_get_name (s2rtdat_get_sym (s2td)))
  ) (* end of [S2RTbas] *)
| ~S2RTfun (s2ts, s2t) => let
    val paren = ctx > 0
    val () = lparen (out, paren)
    val () =
    (
      if glist_is_sing<s2rt> (s2ts)
        then pr_s2rt (out, glist_head<s2rt> (s2ts), 1)
        else (
          fprint_string (out, "(");
          pr_s2rtlst (out, s2ts); fprint_string (out, ")")
        ) (* end of [else] *)
    ) : void // end of [val]
    val () = fprint_string (out, " -> ")
    val () = pr_s2rt (out, s2t, 0)
  in
    rparen (out, paren)
  end // end of [S2RTfun]
| ~S2RTtup (s2ts) => (
    fprint_string (out, "("); pr_s2rtlst (out, s2ts); fprint_string (out, ")")
  ) // end of [S2RTtup]
| ~S2RTVar _ => fprint_string (out, "?")
| ~S2RTerr () => fprint_string (out, "<error>")
//
end // end of [pr_s2rt]

and pr_s2rtlst
  (out: FILEref, s2ts: s2rtlst): void = let
//
fun loop (s2ts: s2rtlst, i: int): void =
  case+ glist_view (s2ts) of
  | ~GLnil () => ()
  | ~GLcons (s2t, s2ts) => let
      val () = if i > 0 then fprint_string (out, ", ")
      val () = pr_s2rt (out, s2t, 0)
    in
      loop (s2ts, i+1)
    end // end of [GLcons]
//
in
  loop (s2ts, 0)
end // end of [pr_s2rtlst]

implement
fsprint_s2rt (out, s2t) = pr_s2rt (out, s2t, 0)
implement
print_s2rt_s (s2t) = fsprint_s2rt (stdout_ref, s2t)
implement
prerr_s2rt_s (s2t) = fsprint_s2rt (stderr_ref, s2t)

(* ****** ****** *)

implement
fsprint_s2var (out, s2v) =
  fsprint_varname (out, 0, s2var_get_sym (s2v), $UN.cast{ptr} (s2v))
implement
print_s2var_s (s2v) = fsprint_s2var (stdout_ref, s2v)
implement
prerr_s2var_s (s2v) = fsprint_s2var (stderr_ref, s2v)

(* ****** ****** *)

fn fprint_symname
  (out: FILEref, sym: symbol): void =
  fprint_string (out, $SYM.symbol_get_name (sym))

(* ****** ****** *)

fn glist_drop
  (xs: s2explst, n: int): s2explst = let
  fun loop (xs: s2explst, n: int): s2explst =
    if n > 0 then (
      if glist_is_cons (xs) then loop (glist_tail<s2exp> (xs), n-1) else xs
    ) else xs
in
  loop (xs, n)
end // end of [glist_drop]

(* ****** ****** *)

fn fprint_effset
  (out: FILEref, efs: effset, i0: int): void = let
  var i: int = i0
  macdef pr1 (eff, name) =
    if $EFF.effset_ismem (efs, ,(eff)) then (
      if i > 0 then fprint_string (out, ",");
      fprint_string (out, ,(name)); i := i + 1
    ) // end of [if]
  val () = pr1 ($EFF.effect_ntm, "!ntm")
  val () = pr1 ($EFF.effect_exn, "!exn")
  val () = pr1 ($EFF.effect_ref, "!ref")
  val () = pr1 ($EFF.effect_wrt, "!wrt")
in
  // nothing
end // end of [fprint_effset]

(*
** the arrow of a function type: [->], [-<>], [-<cloptr1>], [-<lincloptr1>],
** [-<!exn>]...
*)
fn fprint_arrow
(
  out: FILEref, fc: funclo, lin: int, s2fe: s2eff
) : void = let
  val fcname = (
    case+ fc of
    | FUNCLOfun () => ""
    | FUNCLOcloptr () => "cloptr"
    | FUNCLOclo0 () => "clo"
    | FUNCLOcloref () => "cloref"
  ) : string // end of [val]
  val linname = (if lin > 0 then "lin" else "") : string
  // 0: all; 1: none; 2: some (the set); 3: other
  var efs: effset = $EFF.effset_all
  val effknd = (
    case+ s2eff_view (s2fe) of
    | ~S2EFFset (efs1) =>
        if $EFF.effset_isall (efs1) then 0
        else if $EFF.effset_isnil (efs1) then 1
        else (efs := efs1; 2)
    | ~S2EFFexp _ => 3
    | ~S2EFFadd _ => 3
  ) : int // end of [val]
  val isfun = (fcname = "")
in
  if isfun && lin = 0 && effknd = 0 then fprint_string (out, "->")
  else let
    val () = fprint_string (out, "-<")
    val () = fprint_string (out, linname)
    val () = fprint_string (out, fcname)
    val () =
    (
      if effknd = 0 then (if isfun then () else fprint_string (out, "1"))
      else if effknd = 2
        then fprint_effset (out, efs, (if isfun && lin = 0 then 0 else 1))
      else if effknd = 3
        then fprint_string (out, (if isfun && lin = 0 then "..." else ",..."))
      else ()
    ) : void // end of [val]
  in
    fprint_string (out, ">")
  end // end of [else]
end // end of [fprint_arrow]

(* ****** ****** *)

fun pr_s2exp
  (out: FILEref, s2e0: s2exp, ctx: int): void = let
  macdef prstr (s) = fprint_string (out, ,(s))
in
//
case+ s2exp_node_view (s2e0.s2exp_node ()) of
//
| ~S2Eint (i) =>
    if i >= 0 then fprint_int (out, i) else (prstr "~"; fprint_int (out, ~i))
| ~S2Eintinf (i) => $INTINF.fprint_intinf (out, i)
| ~S2Efloat (rep) => prstr rep
| ~S2Estring (str) => (prstr "\""; prstr str; prstr "\"")
//
| ~S2Ecst (s2c) => fsprint_s2cst (out, s2c)
//
| ~S2Eextype (name, s2ess) => (
    prstr "$extype\""; prstr name; prstr "\""; pr_s2explstlst (out, s2ess)
  ) // end of [S2Eextype]
| ~S2Eextkind (name, s2ess) => let
    val p = tkind_find (name)
  in
    if ptr_isnot_null (p) then let
      val e = $UN.ptr0_get<tkent> (p) in fprint_symname (out, e.sym)
    end else (
      prstr "$extkind\""; prstr name; prstr "\""; pr_s2explstlst (out, s2ess)
    ) // end of [if]
  end // end of [S2Eextkind]
//
| ~S2Evar (s2v) => fsprint_s2var (out, s2v)
| ~S2EVar (s2V) => (
    case+ gopt_view (s2Var_get_link (s2V)) of
    | ~GOsome (s2e) => pr_s2exp (out, s2e, ctx)
    | ~GOnone () => fsprint_s2Var (out, s2V)
  ) // end of [S2EVar]
//
| ~S2Ehole _ => prstr "_"
//
| ~S2Edatcontyp (d2c, s2es) => (
    fprint_symname (out, d2con_get_sym (d2c));
    prstr "("; pr_s2explst (out, s2es); prstr ")"
  ) // end of [S2Edatcontyp]
| ~S2Edatconptr (d2c, s2e_rt, s2es) => (
    fprint_symname (out, d2con_get_sym (d2c));
    prstr "@"; pr_s2exp (out, s2e_rt, PREC_ATOM);
    prstr "("; pr_s2explst (out, s2es); prstr ")"
  ) // end of [S2Edatconptr]
//
| ~S2Eat (s2e1, s2e2) => let
    val paren = ctx > PREC_AT
  in
    lparen (out, paren);
    pr_s2exp (out, s2e1, PREC_AT+1); prstr " @ ";
    pr_s2exp (out, s2e2, PREC_AT+1);
    rparen (out, paren)
  end // end of [S2Eat]
| ~S2Esizeof (s2e) => (prstr "sizeof("; pr_s2exp (out, s2e, 0); prstr ")")
//
| ~S2Eeff (s2fe) => (prstr "<"; pr_s2eff (out, s2fe); prstr ">")
//
| ~S2Eeqeq (s2e1, s2e2) => let
    val paren = ctx > PREC_EQEQ
  in
    lparen (out, paren);
    pr_s2exp (out, s2e1, PREC_EQEQ+1); prstr " == ";
    pr_s2exp (out, s2e2, PREC_EQEQ+1);
    rparen (out, paren)
  end // end of [S2Eeqeq]
//
| ~S2Eproj (s2ae, _(*s2te*), s2ls) => (
    pr_s2exp (out, s2ae, PREC_ATOM); pr_s2lablst (out, s2ls)
  ) // end of [S2Eproj]
//
| ~S2Eapp (s2f, s2es) => let
    val s2f = s2exp_delink (s2f)
  in
    if s2exp_node_is_S2Ecst (s2f.s2exp_node ()) then (
      case+ s2exp_node_view (s2f.s2exp_node ()) of
      | ~S2Ecst (s2c) => let
          val p = alias_find (s2c, s2es)
        in
          if ptr_isnot_null (p) then let
            val e = $UN.ptr0_get<aent> (p)
            val s2es = glist_drop (s2es, glist_length<s2exp> (e.lead))
          in
            pr_app_named (out, e.sym, s2es, ctx)
          end else pr_app_named (out, s2cst_get_sym (s2c), s2es, ctx)
        end // end of [S2Ecst]
      | v => s2exp_node_view_free (v)
    ) else (
      pr_s2exp (out, s2f, PREC_ATOM);
      prstr "("; pr_s2explst (out, s2es); prstr ")"
    ) (* end of [if] *)
  end // end of [S2Eapp]
//
| ~S2Elam (s2vs, s2e_body) => let
    val paren = ctx > PREC_LAM
  in
    lparen (out, paren);
    prstr "lam("; pr_s2varlst (out, s2vs, false); prstr ") => ";
    pr_s2exp (out, s2e_body, PREC_LAM);
    rparen (out, paren)
  end // end of [S2Elam]
//
| ~S2Efun (fc, lin, s2fe, npf, s2es_arg, s2e_res) => let
    val paren = ctx > PREC_FUN
  in
    lparen (out, paren);
    prstr "("; pr_s2explst_npf (out, npf, s2es_arg); prstr ") ";
    fprint_arrow (out, fc, lin, s2fe); prstr " ";
    pr_s2exp (out, s2e_res, PREC_FUN);
    rparen (out, paren)
  end // end of [S2Efun]
//
| ~S2Emetfun (_(*opt*), s2es_met, s2e_body) => let
    val paren = ctx > PREC_QUANT
  in
    lparen (out, paren);
    prstr ".<"; pr_s2explst (out, s2es_met); prstr ">. ";
    pr_s2exp (out, s2e_body, PREC_QUANT);
    rparen (out, paren)
  end // end of [S2Emetfun]
| ~S2Emetdec (s2es1, s2es2) => let
    val paren = ctx > PREC_AT
    val sing = (
      if glist_is_sing<s2exp> (s2es1)
        then glist_is_sing<s2exp> (s2es2) else false
    ) : bool
  in
    lparen (out, paren);
    if sing then (
      pr_s2exp (out, glist_head<s2exp> (s2es1), PREC_AT+1); prstr " < ";
      pr_s2exp (out, glist_head<s2exp> (s2es2), PREC_AT+1)
    ) else (
      prstr "("; pr_s2explst (out, s2es1); prstr ") < (";
      pr_s2explst (out, s2es2); prstr ")"
    );
    rparen (out, paren)
  end // end of [S2Emetdec]
//
| ~S2Etop (knd, s2e) => (
    pr_s2exp (out, s2e, PREC_POSTFIX+1);
    if knd = 0 then prstr "?" else prstr "?!"
  ) // end of [S2Etop]
| ~S2Ewithout (s2e) => (prstr "without("; pr_s2exp (out, s2e, 0); prstr ")")
//
| ~S2Etyarr (s2e_elt, s2es_dim) => (
    prstr "@["; pr_s2exp (out, s2e_elt, 0);
    prstr "]["; pr_s2explst (out, s2es_dim); prstr "]"
  ) // end of [S2Etyarr]
| ~S2Etyrec (knd, npf, ls2es) => pr_tyrec (out, knd, npf, ls2es)
//
//
// HX: an invariant argument (of the instantiation of a template) is
// printed as the argument itself: [!t] would read as a read-only [!t]
//
| ~S2Einvar (s2e) => pr_s2exp (out, s2e, ctx)
//
| ~S2Eexi (s2vs, s2ps, s2e) => let
    val paren = ctx > PREC_QUANT
  in
    lparen (out, paren);
    prstr "["; pr_quant (out, s2vs, s2ps); prstr "] ";
    pr_s2exp (out, s2e, PREC_QUANT);
    rparen (out, paren)
  end // end of [S2Eexi]
| ~S2Euni (s2vs, s2ps, s2e) => let
    val paren = ctx > PREC_QUANT
  in
    lparen (out, paren);
    prstr "{"; pr_quant (out, s2vs, s2ps); prstr "} ";
    pr_s2exp (out, s2e, PREC_QUANT);
    rparen (out, paren)
  end // end of [S2Euni]
//
| ~S2Erefarg (knd, s2e) => (
    if knd = 0 then prstr "!" else prstr "&"; pr_s2exp (out, s2e, PREC_PREFIX+1)
  ) // end of [S2Erefarg]
| ~S2Evararg (s2e) => (pr_s2exp (out, s2e, PREC_POSTFIX+1); prstr "...")
//
| ~S2Ewthtype (s2e, ws2es) => let
    val paren = ctx > PREC_LAM
  in
    lparen (out, paren);
    pr_s2exp (out, s2e, PREC_LAM+1); pr_wths2explst (out, ws2es);
    rparen (out, paren)
  end // end of [S2Ewthtype]
//
| ~S2Eerrexp () => prstr "<error>"
//
end // end of [pr_s2exp]

and pr_app_named
(
  out: FILEref, sym: symbol, s2es: s2explst, ctx: int
) : void = let
  val name = $SYM.symbol_get_name (sym)
  val n = glist_length<s2exp> (s2es)
  val prec = (if n = 2 then binop_prec (name) else ~1) : int
in
  if prec >= 0 then let
    val assoc = binop_assoc (prec)
    val paren = ctx > prec
    val () = lparen (out, paren)
    val ctx1 = (if assoc = 1 then prec else prec+1) : int
    val ctx2 = (if assoc = 2 then prec else prec+1) : int
    val () = pr_s2exp (out, glist_head<s2exp> (s2es), ctx1)
    val () = fprint_string (out, " ")
    val () = fprint_string (out, name)
    val () = fprint_string (out, " ")
    val () = pr_s2exp (out, glist_head<s2exp> (glist_tail<s2exp> (s2es)), ctx2)
  in
    rparen (out, paren)
  end else if n = 1 && name = "~" then let
    val paren = ctx > PREC_NEG
    val () = lparen (out, paren)
    val () = fprint_string (out, "~")
    val () = pr_s2exp (out, glist_head<s2exp> (s2es), PREC_NEG+1)
  in
    rparen (out, paren)
  end else if n = 0 then fprint_string (out, name)
  else (
    fprint_string (out, name);
    fprint_string (out, "("); pr_s2explst (out, s2es); fprint_string (out, ")")
  ) (* end of [if] *)
end // end of [pr_app_named]

and pr_s2explst
  (out: FILEref, s2es: s2explst): void = pr_s2explst_npf (out, 0, s2es)

and pr_s2explst_npf
  (out: FILEref, npf: int, s2es: s2explst): void = let
//
fun loop (s2es: s2explst, i: int): void =
  case+ glist_view (s2es) of
  | ~GLnil () => ()
  | ~GLcons (s2e, s2es) => let
      val () =
        if i > 0 then (
          if i = npf
            then fprint_string (out, " | ") else fprint_string (out, ", ")
        ) // end of [if]
      val () = pr_s2exp (out, s2e, 0)
    in
      loop (s2es, i+1)
    end // end of [GLcons]
//
in
  loop (s2es, 0)
end // end of [pr_s2explst_npf]

and pr_s2explstlst
  (out: FILEref, s2ess: s2explstlst): void =
  case+ glist_view (s2ess) of
  | ~GLnil () => ()
  | ~GLcons (s2es, s2ess) => (
      fprint_string (out, "("); pr_s2explst (out, s2es);
      fprint_string (out, ")"); pr_s2explstlst (out, s2ess)
    ) // end of [GLcons]

and pr_s2varlst
  (out: FILEref, s2vs: s2varlst, srt: bool): void = let
//
fun loop (s2vs: s2varlst, i: int): void =
  case+ glist_view (s2vs) of
  | ~GLnil () => ()
  | ~GLcons (s2v, s2vs) => let
      val () = if i > 0 then fprint_string (out, ", ")
      val () = fsprint_s2var (out, s2v)
      val () =
        if srt then (
          fprint_string (out, ":"); pr_s2rt (out, s2var_get_srt (s2v), 1)
        ) (* end of [if] *)
    in
      loop (s2vs, i+1)
    end // end of [GLcons]
//
in
  loop (s2vs, 0)
end // end of [pr_s2varlst]

and pr_quant
  (out: FILEref, s2vs: s2varlst, s2ps: s2explst): void = let
//
fun loop (s2ps: s2explst, i: int): void =
  case+ glist_view (s2ps) of
  | ~GLnil () => ()
  | ~GLcons (s2p, s2ps) => let
      val () = if i > 0 then fprint_string (out, "; ")
      val () = pr_s2exp (out, s2p, 0)
    in
      loop (s2ps, i+1)
    end // end of [GLcons]
//
val () = pr_s2varlst (out, s2vs, true)
//
in
  if glist_is_cons (s2ps) then (
    if glist_is_cons (s2vs) then fprint_string (out, " | "); loop (s2ps, 0)
  ) // end of [if]
end // end of [pr_quant]

and pr_s2lablst
  (out: FILEref, s2ls: s2lablst): void =
  case+ glist_view (s2ls) of
  | ~GLnil () => ()
  | ~GLcons (s2l, s2ls) => let
      val () = (
        case+ s2lab_view (s2l) of
        | ~S2LABlab (lab) => (
            fprint_string (out, "."); $LAB.fprint_label (out, lab)
          ) (* end of [S2LABlab] *)
        | ~S2LABind (ind) => (
            fprint_string (out, "[");
            pr_s2explst (out, ind); fprint_string (out, "]")
          ) (* end of [S2LABind] *)
      ) : void // end of [val]
    in
      pr_s2lablst (out, s2ls)
    end // end of [GLcons]

and pr_s2eff
  (out: FILEref, s2fe: s2eff): void =
  case+ s2eff_view (s2fe) of
  | ~S2EFFset (efs) =>
      if $EFF.effset_isall (efs) then fprint_string (out, "1")
      else fprint_effset (out, efs, 0)
  | ~S2EFFexp (s2e) => pr_s2exp (out, s2e, 0)
  | ~S2EFFadd (s2fe1, s2fe2) => (
      pr_s2eff (out, s2fe1); fprint_string (out, ","); pr_s2eff (out, s2fe2)
    ) (* end of [S2EFFadd] *)

and pr_tyrec
(
  out: FILEref, knd: tyreckind, npf: int, ls2es: labs2explst
) : void = let
//
fun istup (xs: labs2explst, i: int): bool =
  case+ glist_view (xs) of
  | ~GLnil () => true
  | ~GLcons (x, xs) => (
      case+ $LAB.label_get_int (labs2exp_lab (x)) of
      | ~Some_vt (j) => if i = j then istup (xs, i+1) else false
      | ~None_vt () => false
    ) // end of [GLcons]
//
fun loop (xs: labs2explst, i: int, tup: bool): void =
  case+ glist_view (xs) of
  | ~GLnil () => ()
  | ~GLcons (x, xs) => let
      val () =
        if i > 0 then (
          if i = npf
            then fprint_string (out, " | ") else fprint_string (out, ", ")
        ) // end of [if]
      val () =
        if ~(tup) then (
          $LAB.fprint_label (out, labs2exp_lab (x)); fprint_string (out, "=")
        ) (* end of [if] *)
      val () = pr_s2exp (out, labs2exp_elt (x), 0)
    in
      loop (xs, i+1, tup)
    end // end of [GLcons]
//
val tup = istup (ls2es, 0)
val () =
(
  if tyreckind_is_box (knd) then fprint_string (out, "'")
  else if tyreckind_is_boxlin (knd)
    then fprint_string (out, (if tup then "$tup_vt" else "$rec_vt"))
  else fprint_string (out, "@")
) : void // end of [val]
//
in
  if tup then fprint_string (out, "(") else fprint_string (out, "{");
  loop (ls2es, 0, tup);
  if tup then fprint_string (out, ")") else fprint_string (out, "}")
end // end of [pr_tyrec]

and pr_wths2explst
  (out: FILEref, ws2es: wths2explst): void = let
//
fun loop (xs: wths2explst, i: int): void =
  case+ wths2explst_view (xs) of
  | ~WTHS2EXPLSTnil () => ()
  | ~WTHS2EXPLSTcons_invar (_, x, xs) => let
      val () = fprint_string (out, (if i > 0 then ", " else " >> "))
      val () = pr_s2exp (out, x, PREC_LAM+1)
    in
      loop (xs, i+1)
    end // end of [WTHS2EXPLSTcons_invar]
  | ~WTHS2EXPLSTcons_trans (_, x, xs) => let
      val () = fprint_string (out, (if i > 0 then ", " else " >> "))
      val () = pr_s2exp (out, x, PREC_LAM+1)
    in
      loop (xs, i+1)
    end // end of [WTHS2EXPLSTcons_trans]
  | ~WTHS2EXPLSTcons_none (xs) => loop (xs, i)
//
in
  loop (ws2es, 0)
end // end of [pr_wths2explst]

and fsprint_s2cst_args
  (out: FILEref, s2c: s2cst): void = let
  val p = alias_find (s2c, glist_nil ())
in
  if ptr_isnot_null (p) then let
    val e = $UN.ptr0_get<aent> (p) in fprint_symname (out, e.sym)
  end else fprint_symname (out, s2cst_get_sym (s2c))
end // end of [fsprint_s2cst_args]

implement
fsprint_s2cst (out, s2c) = fsprint_s2cst_args (out, s2c)
implement
print_s2cst_s (s2c) = fsprint_s2cst (stdout_ref, s2c)
implement
prerr_s2cst_s (s2c) = fsprint_s2cst (stderr_ref, s2c)

(* ****** ****** *)

implement
fsprint_s2exp (out, s2e) = pr_s2exp (out, s2e, 0)
implement
fsprint_s2exp_ctx (out, s2e, ctx) = pr_s2exp (out, s2e, ctx)
implement
fsprint_s2eff (out, s2fe) = pr_s2eff (out, s2fe)

implement
s2exp_sprint_nlead
  (s2c, s2es) = let
  val p = alias_find (s2c, s2es)
in
  if ptr_isnot_null (p) then let
    val e = $UN.ptr0_get<aent> (p) in glist_length<s2exp> (e.lead)
  end else 0
end // end of [s2exp_sprint_nlead]

(* ****** ****** *)

local

fn svars_mem
  (xs: glist(s2var), x: s2var): bool = let
  fun loop (xs: glist(s2var)): bool =
    case+ glist_view (xs) of
    | ~GLnil () => false
    | ~GLcons (y, xs) =>
        if ptr_eq ($UN.cast{ptr} (x), $UN.cast{ptr} (y))
          then true else loop (xs)
in
  loop (xs)
end // end of [svars_mem]

fn svars_add
  (xs: glist(s2var), x: s2var): glist(s2var) =
  if svars_mem (xs, x) then xs else glist_cons<s2var> (x, xs)

(*
** the variables of [ys] (newest first) that are not in [bound] are
** added to [acc]
*)
fun svars_merge
(
  acc: glist(s2var), ys: glist(s2var), bound: s2varlst
) : glist(s2var) = let
  val ys = glist_reverse<s2var> (ys)
  fun loop (acc: glist(s2var), ys: glist(s2var)): glist(s2var) =
    case+ glist_view (ys) of
    | ~GLnil () => acc
    | ~GLcons (y, ys) =>
        if svars_mem ($UN.cast{glist(s2var)} (bound), y)
          then loop (acc, ys) else loop (svars_add (acc, y), ys)
in
  loop (acc, ys)
end // end of [svars_merge]

fun aux
  (s2e: s2exp, acc: glist(s2var)): glist(s2var) =
  case+ s2exp_node_view (s2e.s2exp_node ()) of
  | ~S2Evar (s2v) => svars_add (acc, s2v)
  | ~S2EVar (s2V) => (
      case+ gopt_view (s2Var_get_link (s2V)) of
      | ~GOsome (s2e1) => aux (s2e1, acc)
      | ~GOnone () => acc
    ) // end of [S2EVar]
  | ~S2Eextype (_, s2ess) => auxlstlst (s2ess, acc)
  | ~S2Eextkind (_, s2ess) => auxlstlst (s2ess, acc)
  | ~S2Edatcontyp (_, s2es) => auxlst (s2es, acc)
  | ~S2Edatconptr (_, s2e1, s2es) => auxlst (s2es, aux (s2e1, acc))
  | ~S2Eat (s2e1, s2e2) => aux (s2e2, aux (s2e1, acc))
  | ~S2Esizeof (s2e1) => aux (s2e1, acc)
  | ~S2Eeqeq (s2e1, s2e2) => aux (s2e2, aux (s2e1, acc))
  | ~S2Eproj (s2e1, _, _) => aux (s2e1, acc)
  | ~S2Eapp (s2f, s2es) => auxlst (s2es, aux (s2f, acc))
  | ~S2Elam (s2vs, s2e_body) =>
      svars_merge (acc, aux (s2e_body, glist_nil ()), s2vs)
  | ~S2Efun (_, _, _, _, s2es, s2e_res) => aux (s2e_res, auxlst (s2es, acc))
  | ~S2Emetfun (_, s2es, s2e_body) => aux (s2e_body, auxlst (s2es, acc))
  | ~S2Emetdec (s2es1, s2es2) => auxlst (s2es2, auxlst (s2es1, acc))
  | ~S2Etop (_, s2e1) => aux (s2e1, acc)
  | ~S2Ewithout (s2e1) => aux (s2e1, acc)
  | ~S2Etyarr (s2e1, s2es) => auxlst (s2es, aux (s2e1, acc))
  | ~S2Etyrec (_, _, ls2es) => auxlablst (ls2es, acc)
  | ~S2Einvar (s2e1) => aux (s2e1, acc)
  | ~S2Eexi (s2vs, s2ps, s2e_body) =>
      svars_merge (acc, aux (s2e_body, auxlst (s2ps, glist_nil ())), s2vs)
  | ~S2Euni (s2vs, s2ps, s2e_body) =>
      svars_merge (acc, aux (s2e_body, auxlst (s2ps, glist_nil ())), s2vs)
  | ~S2Erefarg (_, s2e1) => aux (s2e1, acc)
  | ~S2Evararg (s2e1) => aux (s2e1, acc)
  | ~S2Ewthtype (s2e1, _) => aux (s2e1, acc)
  | v => (s2exp_node_view_free (v); acc)
// end of [aux]

and auxlst
  (s2es: s2explst, acc: glist(s2var)): glist(s2var) =
  case+ glist_view (s2es) of
  | ~GLnil () => acc
  | ~GLcons (s2e, s2es) => auxlst (s2es, aux (s2e, acc))

and auxlstlst
  (s2ess: s2explstlst, acc: glist(s2var)): glist(s2var) =
  case+ glist_view (s2ess) of
  | ~GLnil () => acc
  | ~GLcons (s2es, s2ess) => auxlstlst (s2ess, auxlst (s2es, acc))

and auxlablst
  (ls2es: labs2explst, acc: glist(s2var)): glist(s2var) =
  case+ glist_view (ls2es) of
  | ~GLnil () => acc
  | ~GLcons (x, xs) => auxlablst (xs, aux (labs2exp_elt (x), acc))

in (* in-of-local *)

implement
s2exp_sprint_svars (s2e, acc) = aux (s2e, acc)

end // end of [local]
implement
print_s2exp_s (s2e) = fsprint_s2exp (stdout_ref, s2e)
implement
prerr_s2exp_s (s2e) = fsprint_s2exp (stderr_ref, s2e)

implement
fsprint_s2explst (out, s2es) = pr_s2explst (out, s2es)
implement
print_s2explst_s (s2es) = fsprint_s2explst (stdout_ref, s2es)
implement
prerr_s2explst_s (s2es) = fsprint_s2explst (stderr_ref, s2es)

(* ****** ****** *)

implement
s2exp_sprint_head
  (s2e, s2c, s2es) = let
  val s2e = s2exp_delink (s2e)
in
  case+ s2exp_node_view (s2e.s2exp_node ()) of
  | ~S2Eapp (s2f, s2es1) => let
      val s2f = s2exp_delink (s2f)
    in
      case+ s2exp_node_view (s2f.s2exp_node ()) of
      | ~S2Ecst (s2c1) => (s2c := s2c1; s2es := s2es1; true)
      | v => (
          s2exp_node_view_free (v);
          s2c := $UN.cast{s2cst} (the_null_ptr); s2es := glist_nil (); false
        ) // end of [_]
    end // end of [S2Eapp]
  | v => (
      s2exp_node_view_free (v);
      s2c := $UN.cast{s2cst} (the_null_ptr); s2es := glist_nil (); false
    ) // end of [_]
end // end of [s2exp_sprint_head]

(* ****** ****** *)

(* end of [pats_staexp2_sprint.dats] *)
