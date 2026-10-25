(* ****** ****** *)
//
// Author: Hongwei Xi
// Authoremail: gmhwxiATgmailDOTcom
// Start Time: May, 2011
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_dynexp2.dats, see PORTING.md, "Level 2 dynamic (dynexp2)")
// The only .dats that includes [pats_dynexp2_gen_dats.hats]
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)
//
staload
LOC = "./pats_location.sats"
//
macdef
location_combine = $LOC.location_combine
//
(* ****** ****** *)

staload UT = "./pats_utils.sats"
staload _(*anon*) = "./pats_utils.dats"

(* ****** ****** *)

staload "./pats_basics.sats"
staload "./pats_syntax.sats"
staload "./pats_staexp1.sats"
staload "./pats_avlmap.sats"
staload "./pats_staexp2.sats"
staload "./pats_dynexp2.sats"

(* ****** ****** *)

#include "./pats_basics.hats"

(* ****** ****** *)

#include "./pats_dynexp2_gen_dats.hats"

(* ****** ****** *)
//
#define l2l glist_make_list_vt
//
(* ****** ****** *)

implement
d2sym_make (
  loc, q, id, d2pis
) = d2sym_new(loc, q, id, d2pis) // end of [d2sym_make]

(* ****** ****** *)
//
// HX: dynamic patterns
//
(* ****** ****** *)

fun cmp_s2vsym (x: s2var, y: s2var): int = compare_s2vsym_s2vsym (x, y)
fun cmp_d2vsym (x: d2var, y: d2var): int = compare_d2vsym_d2vsym (x, y)

(* ****** ****** *)

fn p2at_svs_nil (): s2varord = $UT.lstord_nil<s2var> ()
fn p2at_dvs_nil (): d2varord = $UT.lstord_nil<d2var> ()

fun p2at_svs_add_svar
(
  svs: s2varord, s2v: s2var
) : s2varord = $UT.lstord_insert<s2var> (svs, s2v, cmp_s2vsym)
// end of [p2at_svs_add_svar]

fun p2at_svs_add_svarlst
(
  svs: s2varord, s2vs: s2varlst
) : s2varord =
  case+ glist_view (s2vs) of
  | ~GLcons (s2v, s2vs) => p2at_svs_add_svarlst (p2at_svs_add_svar (svs, s2v), s2vs)
  | ~GLnil () => svs
// end of [p2at_svs_add_svarlst]

implement
p2atlst_svs_union (p2ts) = let
  fun aux (svs: s2varord, p2ts: p2atlst): s2varord =
    case+ glist_view (p2ts) of
    | ~GLcons (p2t, p2ts) =>
        aux ($UT.lstord_union<s2var> (svs, p2t.p2at_svs(), cmp_s2vsym), p2ts)
    | ~GLnil () => svs
in
  aux (p2at_svs_nil (), p2ts)
end // end of [p2atlst_svs_union]

implement
p2atlst_dvs_union (p2ts) = let
  fun aux (dvs: d2varord, p2ts: p2atlst): d2varord =
    case+ glist_view (p2ts) of
    | ~GLcons (p2t, p2ts) =>
        aux ($UT.lstord_union<d2var> (dvs, p2t.p2at_dvs(), cmp_d2vsym), p2ts)
    | ~GLnil () => dvs
in
  aux (p2at_dvs_nil (), p2ts)
end // end of [p2atlst_dvs_union]

(* ****** ****** *)

implement
eq_pckind_pckind
  (x1, x2) = (
  case+ (x1, x2) of
  | (PCKcon (), PCKcon ()) => true
  | (PCKlincon (), PCKlincon ()) => true
  | (PCKfree (), PCKfree ()) => true
  | (PCKunfold (), PCKunfold ()) => true
  | (_, _) => false
) // end of [eq_pckind_pckind]

(* ****** ****** *)

implement
p2at_make_node
(
  loc, svs, dvs, node
) = p2at_new(loc, svs, dvs, gopt_none(), node) // end of [p2at_make_node]

implement
p2at_any (loc) =
  p2at_make_node (loc, p2at_svs_nil (), p2at_dvs_nil (), p2at_node_P2Tany())
// end of [p2at_any]

implement
p2at_var
  (loc, d2v) = let
  val dvs = $UT.lstord_sing<d2var> (d2v) in
  p2at_make_node (loc, p2at_svs_nil (), dvs, p2at_node_P2Tvar(d2v))
end // end of [p2at_var]

(* ****** ****** *)

implement
p2at_int (loc, i) =
  p2at_make_node (loc, p2at_svs_nil (), p2at_dvs_nil (), p2at_node_P2Tint(i))
// end of [p2at_int]

implement
p2at_intrep (loc, rep) =
  p2at_make_node (loc, p2at_svs_nil (), p2at_dvs_nil (), p2at_node_P2Tintrep(rep))
// end of [p2at_int]

implement
p2at_bool (loc, b) =
  p2at_make_node (loc, p2at_svs_nil (), p2at_dvs_nil (), p2at_node_P2Tbool(b))
// end of [p2at_bool]

implement
p2at_char (loc, c) =
  p2at_make_node (loc, p2at_svs_nil (), p2at_dvs_nil (), p2at_node_P2Tchar(c))
// end of [p2at_char]

implement
p2at_float (loc, rep) =
  p2at_make_node (loc, p2at_svs_nil (), p2at_dvs_nil (), p2at_node_P2Tfloat(rep))
// end of [p2at_float]

implement
p2at_string (loc, str) =
  p2at_make_node (loc, p2at_svs_nil (), p2at_dvs_nil (), p2at_node_P2Tstring(str))
// end of [p2at_string]

(* ****** ****** *)

implement
p2at_i0nt (loc, x) =
  p2at_make_node (loc, p2at_svs_nil (), p2at_dvs_nil (), p2at_node_P2Ti0nt(x))
// end of [p2at_i0nt]

implement
p2at_f0loat (loc, x) =
  p2at_make_node (loc, p2at_svs_nil (), p2at_dvs_nil (), p2at_node_P2Tf0loat(x))
// end of [p2at_f0loat]

(* ****** ****** *)

implement
p2at_empty (loc) =
  p2at_make_node (loc, p2at_svs_nil (), p2at_dvs_nil (), p2at_node_P2Tempty())
// end of [p2at_empty]

(* ****** ****** *)

implement
p2at_con (
  loc, pck // '~' and '@'
, d2c, s2qs, s2f, npf, darg
) = let
  val svs = p2atlst_svs_union (darg)
  val svs = let
    fun f (
      res: s2varord, xs: s2qualst
    ) : s2varord =
      case+ glist_view (xs) of
      | ~GLcons (x, xs) => f (p2at_svs_add_svarlst (res, x.s2qua_svs()), xs)
      | ~GLnil () => res
    // end of [f]
  in
    f (svs, s2qs)
  end // end of [val]
  val dvs = p2atlst_dvs_union (darg)
  val node = p2at_node_P2Tcon(pck, d2c, s2qs, s2f, npf, darg)
in
  p2at_make_node (loc, svs, dvs, node)
end // end of [p2at_con]

(* ****** ****** *)

implement
p2at_list
  (loc, npf, p2ts) = let
  val svs = p2atlst_svs_union (p2ts)
  val dvs = p2atlst_dvs_union (p2ts)
in
  p2at_make_node (loc, svs, dvs, p2at_node_P2Tlist(npf, p2ts))
end // end of [p2at_list]

(* ****** ****** *)

implement
p2at_rec
  (loc, knd, npf, lp2ts) = let
  val p2ts = aux (lp2ts) where {
    fun aux (
      xs: labp2atlst
    ) : p2atlst = case+ glist_view(xs) of
      | ~GLcons(x, xs) => (case+ labp2at_view(x) of
        | ~LABP2ATnorm (l0, p2t) => glist_cons (p2t, aux xs)
        | ~LABP2ATomit (loc) => aux (xs)
        ) // end of [list_cons]
      | ~GLnil() => glist_nil ()
    // end of [aux]
  } // end of [val]
  val svs = p2atlst_svs_union (p2ts)
  val dvs = p2atlst_dvs_union (p2ts)
in
  p2at_make_node (loc, svs, dvs, p2at_node_P2Trec(knd, npf, lp2ts))
end // end of [p2at_lp2ts]

(* ****** ****** *)

implement
p2at_lst (loc, lin, p2ts) = let
  val svs = p2atlst_svs_union (p2ts)
  val dvs = p2atlst_dvs_union (p2ts)
in
  p2at_make_node (loc, svs, dvs, p2at_node_P2Tlst(lin, p2ts))
end // end of [p2at_lst]

(* ****** ****** *)

implement
p2at_refas (loc, d2v, p2t) = let
  val svs = p2t.p2at_svs()
  val dvs = $UT.lstord_insert<d2var>
    (p2t.p2at_dvs(), d2v, cmp_d2vsym)
  // end of [val]
in
  p2at_make_node (loc, svs, dvs, p2at_node_P2Trefas(d2v, p2t))
end // end of [p2at_refas]

(* ****** ****** *)

implement
p2at_exist
  (loc, s2vs, p2t) = let
  val svs =
    p2at_svs_add_svarlst (p2t.p2at_svs(), s2vs)
  // end of [val]
  val dvs = p2t.p2at_dvs()
in
  p2at_make_node (loc, svs, dvs, p2at_node_P2Texist(s2vs, p2t))
end // end of [p2at_exist]

(* ****** ****** *)

implement
p2at_ann
(
  loc, p2t, s2e
) = p2at_make_node (
  loc, p2t.p2at_svs(), p2t.p2at_dvs(), p2at_node_P2Tann(p2t, s2e)
) // end of [p2at_ann]

(* ****** ****** *)

implement
p2at_vbox (loc, d2v) = let
  val dvs = $UT.lstord_sing<d2var> (d2v) in
  p2at_make_node (loc, p2at_svs_nil (), dvs, p2at_node_P2Tvbox(d2v))
end // end of [p2at_vbox]

(* ****** ****** *)

implement
p2at_errpat (loc) =
  p2at_make_node (loc, p2at_svs_nil (), p2at_dvs_nil (), p2at_node_P2Terrpat())
// end of [p2at_errpat]

(* ****** ****** *)
//
// HX: dynamic expressions
//
(* ****** ****** *)

implement
d2exp_make_node
  (loc, node) = d2exp_new(loc, node) // end of [d2exp_make_node]

(* ****** ****** *)

implement
d2exp_cst(loc, d2c) =
d2exp_make_node(loc, d2exp_node_D2Ecst(d2c))

implement
d2exp_var(loc, d2v) =
d2exp_make_node(loc, d2exp_node_D2Evar(d2v))

(* ****** ****** *)

implement
d2exp_int (loc, i) = d2exp_make_node (loc, d2exp_node_D2Eint(i))
implement
d2exp_intrep (loc, rep) = d2exp_make_node (loc, d2exp_node_D2Eintrep(rep))
implement
d2exp_bool (loc, b) = d2exp_make_node (loc, d2exp_node_D2Ebool(b))
implement
d2exp_char (loc, c) = d2exp_make_node (loc, d2exp_node_D2Echar(c))
implement
d2exp_float (loc, rep) = d2exp_make_node (loc, d2exp_node_D2Efloat(rep))
implement
d2exp_string (loc, s) = d2exp_make_node (loc, d2exp_node_D2Estring(s))

implement
d2exp_i0nt (loc, x) = d2exp_make_node (loc, d2exp_node_D2Ei0nt(x))
implement
d2exp_c0har (loc, x) = d2exp_make_node (loc, d2exp_node_D2Ec0har(x))
implement
d2exp_f0loat (loc, x) = d2exp_make_node (loc, d2exp_node_D2Ef0loat(x))
implement
d2exp_s0tring (loc, x) = d2exp_make_node (loc, d2exp_node_D2Es0tring(x))

(* ****** ****** *)

implement
d2exp_top (loc) =
  d2exp_make_node (loc, d2exp_node_D2Etop())
implement
d2exp_top2 (loc, s2e) =
  d2exp_make_node (loc, d2exp_node_D2Etop2(s2e))
//
implement
d2exp_empty (loc) =
  d2exp_make_node (loc, d2exp_node_D2Eempty())
//
(* ****** ****** *)

implement
d2exp_cstsp
  (loc, csp) =
  d2exp_make_node(loc, d2exp_node_D2Ecstsp(csp))
// end of [d2exp_cstsp]

(* ****** ****** *)

implement
d2exp_tyrep
  (loc, s2e) =
  d2exp_make_node(loc, d2exp_node_D2Etyrep(s2e))
// end of [d2exp_tyrep]

(* ****** ****** *)

implement
d2exp_literal
  (loc, d2e) =
  d2exp_make_node(loc, d2exp_node_D2Eliteral(d2e))
// end of [d2exp_literal]

(* ****** ****** *)

implement
d2exp_extval
  (loc, s2e, name) =
  d2exp_make_node (loc, d2exp_node_D2Eextval(s2e, name))
// end of [d2exp_extval]

implement
d2exp_extfcall
  (loc, s2e, _fun, _arg) =
  d2exp_make_node (loc, d2exp_node_D2Eextfcall(s2e, _fun, _arg))
// end of [d2exp_extfcall]

implement
d2exp_extmcall
  (loc, s2e, _obj, _mtd, _arg) =
  d2exp_make_node (loc, d2exp_node_D2Eextmcall(s2e, _obj, _mtd, _arg))
// end of [d2exp_extmcall]

(* ****** ****** *)

implement
d2exp_con
  (loc, d2c, locfun, sarg, npf, locarg, darg) =
  d2exp_make_node (loc, d2exp_node_D2Econ(d2c, locfun, sarg, npf, locarg, darg))
// end of [d2exp_con]

implement
d2exp_sym (loc, d2s) = d2exp_make_node (loc, d2exp_node_D2Esym(d2s))

(* ****** ****** *)

implement
d2exp_foldat
  (loc, s2as, d2e) = d2exp_make_node (loc, d2exp_node_D2Efoldat(s2as, d2e))
// end of [d2exp_foldat]
implement
d2exp_freeat
  (loc, s2as, d2e) = d2exp_make_node (loc, d2exp_node_D2Efreeat(s2as, d2e))
// end of [d2exp_freeat]

(* ****** ****** *)

implement
d2exp_tmpid (loc, d2e_id, t2mas) =
  d2exp_make_node (loc, d2exp_node_D2Etmpid(d2e_id, t2mas))
// end of [d2exp_tmpid]

(* ****** ****** *)

implement
d2exp_let (loc, d2cs, body) =
  d2exp_make_node (loc, d2exp_node_D2Elet(d2cs, body))
// end of [d2exp_let]

implement
d2exp_where (loc, body, d2cs) =
  d2exp_make_node (loc, d2exp_node_D2Ewhere(body, d2cs))
// end of [d2exp_where]

(* ****** ****** *)

implement
d2exp_applst (
  loc, d2e_fun, d2as_arg
) = d2exp_make_node (loc, d2exp_node_D2Eapplst(d2e_fun, d2as_arg))

implement
d2exp_app_sta (
  loc0, d2e_fun, locarg, s2as
) = let
(*
  val () = (
    print "d2exp_app_sta: d2e_fun = "; print_d2exp d2e_fun; print_newline ()
  ) // end of [val]
*)
in
//
case+ glist_view(s2as) of
| ~GLcons(_, _) => let
    val d2a =
      d2exparg_D2EXPARGsta(locarg, s2as)
    // end of [val]
    val node = (
      case+ d2exp_node_view(d2e_fun.d2exp_node()) of
      | ~D2Eapplst (d2e_fun, d2as) => let
          val d2as = glist_append<d2exparg> (d2as, glist_sing(d2a))
        in
          d2exp_node_D2Eapplst(d2e_fun, d2as)
        end
      | v => (d2exp_node_view_free (v); d2exp_node_D2Eapplst(d2e_fun, glist_sing(d2a)))
    ) : d2exp_node // end of [val]
  in
    d2exp_make_node (loc0, node)
  end // end of [list_cons]
| ~GLnil() => d2e_fun
//
end (* end of [d2exp_app_sta] *)

implement
d2exp_app_dyn (
  loc0, d2e_fun, npf, locarg, darg
) = let
(*
  val () = (
    print "d2exp_app_fun: d2e_fun = "; print_d2exp d2e_fun; print_newline ()
  ) // end of [val]
*)
  val d2a =
    d2exparg_D2EXPARGdyn(npf, locarg, darg)
  // end of [val]
  val node = (
    case+ d2exp_node_view(d2e_fun.d2exp_node()) of
    | ~D2Eapplst (d2e_fun, d2as) => let
        val d2as = glist_append<d2exparg> (d2as, glist_sing(d2a))
      in
        d2exp_node_D2Eapplst(d2e_fun, d2as)
      end
    | v => (d2exp_node_view_free (v); d2exp_node_D2Eapplst(d2e_fun, glist_sing(d2a)))
  ) : d2exp_node // end of [val]
in
  d2exp_make_node (loc0, node)
end // end of [d2exp_app_dyn]

implement
d2exp_app_sta_dyn (
  loc_dyn, loc_sta
, d2e_fun, sarg, locarg, npf, darg
) = let
  val d2e_sta =
    d2exp_app_sta (loc_sta, d2e_fun, loc_sta, sarg)
  // end of [val]
in
  if npf >= ~1 then // [npf] takes ~2 as a fake value
    d2exp_app_dyn (loc_dyn, d2e_sta, npf, locarg, darg)
  else d2e_sta // end of [if]
end // end of [d2exp_app_sta_dyn]

(* ****** ****** *)

implement
d2exp_ifhead (
  loc, r2es, _cond, _then, _else
) = d2exp_make_node (
  loc, d2exp_node_D2Eifhead(r2es, _cond, _then, _else)
) // end of [d2exp_ifhead]

implement
d2exp_sifhead (
  loc, r2es, _cond, _then, _else
) = d2exp_make_node (
  loc, d2exp_node_D2Esifhead(r2es, _cond, _then, _else)
) // end of [d2exp_sifhead]

(* ****** ****** *)

local

fun
i2fcl_is_else
  (ifcl: i2fcl): bool = let
//
val test = ifcl.i2fcl_test()
//
in
//
d2exp_node_is_D2Etop(test.d2exp_node())
//
end // end of [i2fcl_is_else]

fun
i2fclist_is_else
  (ifcls: i2fclist): bool = let
//
fun
loop
(
  x: i2fcl, xs: i2fclist
) : bool =
  case+ glist_view(xs) of
  | ~GLnil() => i2fcl_is_else(x)
  | ~GLcons(x, xs) => loop(x, xs)
//
in
//
case+ glist_view(ifcls) of
| ~GLnil() => true
| ~GLcons(x, xs) => loop(x, xs)
//
end // end of [i2fclist_is_else]

in (* in-of-local *)

implement
d2exp_ifcasehd
(
  loc, r2es, ifcls
) = let
//
val opt =
  i2fclist_is_else(ifcls)
//
val knd = (if opt then 1 else 0): int
//
(*
val () =
println!
  ("d2exp_ifcasehd: knd = ", knd)
*)
//
in
//
d2exp_make_node
  (loc, d2exp_node_D2Eifcasehd(knd, r2es, ifcls))
//
end // end of [d2exp_ifcasehd]

end // end of [local]

(* ****** ****** *)
//
implement
d2exp_casehead
(
  loc, knd, inv, d2es, c2ls
) = d2exp_make_node
(
  loc
, d2exp_node_D2Ecasehead(knd, inv, d2es, c2ls)
) // end of [d2exp_casehead]
//
implement
d2exp_scasehead
  (loc, inv, s2f, sc2ls) =
(
d2exp_make_node
  (loc, d2exp_node_D2Escasehead(inv, s2f, sc2ls))
)
//
(* ****** ****** *)
//
implement
d2exp_sing(loc, d2e) =
  d2exp_make_node (loc, d2exp_node_D2Esing(d2e))
//
implement
d2exp_list(loc, npf, d2es) =
  d2exp_make_node(loc, d2exp_node_D2Elist(npf, d2es))
//
(* ****** ****** *)

implement
d2exp_lst
  (loc, lin, elt, d2es) =
  d2exp_make_node(loc, d2exp_node_D2Elst(lin, elt, d2es))
// end of [d2exp_lst]

(* ****** ****** *)
//
implement
d2exp_tup
(
  loc, knd, npf, d2es
) =
(
d2exp_make_node
  (loc, d2exp_node_D2Etup(knd, npf, d2es))
)
//
implement
d2exp_tup_flt
  (loc, npf, d2es) =
(
d2exp_tup
  (loc, TYTUPKIND_flt(*knd*), npf, d2es)
)
//
(* ****** ****** *)
//
implement
d2exp_rec
(
  loc, knd, npf, ld2es
) =
(
  d2exp_make_node(loc, d2exp_node_D2Erec(knd, npf, ld2es))
)
//
(* ****** ****** *)

implement
d2exp_seq(loc, d2es) =
  d2exp_make_node(loc, d2exp_node_D2Eseq(d2es))
// end of [d2exp_seq]

implement
d2exp_seq2(loc, d2es) =
(
case+ glist_view(d2es) of
| ~GLnil() =>
  d2exp_empty(loc)
| ~GLcons(d2e, d2es1) =>
  (
    case+ glist_view(d2es1) of
    | ~GLnil() => d2e
    | ~GLcons(_, _) => d2exp_seq(loc, d2es)
  ) // end of [list_cons]
) (* end of [d2exp_seq2] *)

(* ****** ****** *)

implement
d2exp_deref
  (loc, d2s, lval) =
  d2exp_make_node(loc, d2exp_node_D2Ederef(d2s, lval))
// end of [d2exp_assgn]

implement
d2exp_assgn (
  loc, _left, _right
) = d2exp_make_node(loc, d2exp_node_D2Eassgn(_left, _right))
// end of [d2exp_assgn]

implement
d2exp_xchng (
  loc, _left, _right
) = d2exp_make_node(loc, d2exp_node_D2Exchng(_left, _right))
// end of [d2exp_xchng]

(* ****** ****** *)
//
implement
d2exp_arrsub
(
  loc, d2s, arr, locind, ind
) =
(
d2exp_make_node
  (loc, d2exp_node_D2Earrsub(d2s, arr, locind, ind))
)
//
implement
d2exp_arrpsz
(
  loc, s2eopt_elt, d2es_ini
) =
(
d2exp_make_node
  (loc, d2exp_node_D2Earrpsz(s2eopt_elt, d2es_ini))
)
//
implement
d2exp_arrinit (
  loc, s2e_elt, asz, init
) =
(
d2exp_make_node
  (loc, d2exp_node_D2Earrinit(s2e_elt, asz, init))
)
//
(* ****** ****** *)
//
implement
d2exp_ptrof(loc, d2e) =
  d2exp_make_node (loc, d2exp_node_D2Eptrof(d2e))
//
implement
d2exp_viewat(loc, d2e) =
  d2exp_make_node (loc, d2exp_node_D2Eviewat(d2e))
//
(* ****** ****** *)

implement
d2exp_selab
  (loc, d2e, d2ls) =
  d2exp_make_node(loc, d2exp_node_D2Eselab(d2e, d2ls))
// end of [d2exp_selab]

implement
d2exp_sel_dot
  (loc, d2e, d2ls) = d2exp_selab (loc, d2e, d2ls)
// end of [d2exp_sel_dot]

implement
d2exp_sel_ptr
  (loc, d2s, d2e, d2l) = let
  val loc2 = d2e.d2exp_loc()
  val d2e_deref = d2exp_deref(loc2, d2s, d2e)
in
  d2exp_selab(loc, d2e_deref, glist_sing(d2l))
end // end of [d2exp_sel_ptr]

(* ****** ****** *)
//
implement
d2exp_raise
  (loc, d2e) =
  d2exp_make_node(loc, d2exp_node_D2Eraise(d2e))
//
implement
d2exp_effmask
  (loc, s2fe, d2e) =
  d2exp_make_node(loc, d2exp_node_D2Eeffmask(s2fe, d2e))
// end of [d2exp_effmask]
//
(* ****** ****** *)
//
implement
d2exp_vararg
  (loc, d2es) =
  d2exp_make_node(loc, d2exp_node_D2Evararg(d2es))
//
(* ****** ****** *)

implement
d2exp_vcopyenv
  (loc, knd, d2e) =
  d2exp_make_node(loc, d2exp_node_D2Evcopyenv(knd, d2e))
// end of [d2exp_vcopyenv]

(* ****** ****** *)
//
implement
d2exp_showtype
  (loc, d2e) =
  d2exp_make_node(loc, d2exp_node_D2Eshowtype(d2e))
//
(* ****** ****** *)
//
implement
d2exp_tempenver
  (loc, d2vs) =
  d2exp_make_node(loc, d2exp_node_D2Etempenver(d2vs))
//
(* ****** ****** *)

implement
d2exp_exist
  (loc, s2a, d2e) =
  d2exp_make_node(loc, d2exp_node_D2Eexist(s2a, d2e))
// end of [d2exp_exist]

(* ****** ****** *)
//
implement
d2exp_lam_dyn
(
  loc, knd, npf, arg, body
) = d2exp_make_node
    (loc, d2exp_node_D2Elam_dyn(knd, npf, arg, body))
//
implement
d2exp_laminit_dyn
(
  loc, knd, npf, arg, body
) = d2exp_make_node
    (loc, d2exp_node_D2Elaminit_dyn(knd, npf, arg, body))
//
implement
d2exp_lam_sta
  (loc, s2vs, s2ps, body) =
  d2exp_make_node(loc, d2exp_node_D2Elam_sta(s2vs, s2ps, body))
// end of [d2exp_lam_sta]
//
implement
d2exp_lam_met
  (loc, ref, met, body) =
  d2exp_make_node(loc, d2exp_node_D2Elam_met(ref, met, body))
// end of [d2exp_lam_met]
//
implement
d2exp_lam_met_new
  (loc, met, body) = let
//
val
ref = d2varlstref_new(glist_nil())
//
in
  d2exp_lam_met(loc, ref, met, body)
end // end of [d2exp_lam_met_new]
//
implement
d2exp_fix (
  loc, knd, d2v_fun, d2e_body
) = d2exp_make_node
    (loc, d2exp_node_D2Efix(knd, d2v_fun, d2e_body))
//
(* ****** ****** *)

implement
d2exp_delay
  (loc, d2e) =
  d2exp_make_node (loc, d2exp_node_D2Edelay(d2e))
// end of [d2exp_delay]

implement
d2exp_ldelay
  (loc, _eval, _free) =
  d2exp_make_node(loc, d2exp_node_D2Eldelay(_eval, _free))
// end of [d2exp_ldelay]

implement
d2exp_ldelay_none
  (loc, d2e) = d2exp_ldelay(loc, d2e, gopt_none((*void*)))
// end of [d2exp_ldelay_none]

(* ****** ****** *)

implement
d2exp_for
(
  loc, i2nv, init, test, post, body
) =
  d2exp_make_node (loc, d2exp_node_D2Efor(i2nv, init, test, post, body))
// end of [d2exp_for]

implement
d2exp_while
(
  loc, i2nv, test, body
) =
  d2exp_make_node (loc, d2exp_node_D2Ewhile(i2nv, test, body))
// end of [d2exp_while]

implement
d2exp_loopexn
  (loc, knd) = d2exp_make_node (loc, d2exp_node_D2Eloopexn(knd))
// end of [d2exp_loopexn]

(* ****** ****** *)

implement
d2exp_trywith (
  loc, r2es, d2e, c2ls
) = d2exp_make_node (loc, d2exp_node_D2Etrywith(r2es, d2e, c2ls))

(* ****** ****** *)

implement
d2exp_ann_type
  (loc, d2e, s2e) =
  d2exp_make_node (loc, d2exp_node_D2Eann_type(d2e, s2e))
// end of [d2exp_ann_type]

implement
d2exp_ann_seff
  (loc, d2e, s2fe) =
  d2exp_make_node (loc, d2exp_node_D2Eann_seff(d2e, s2fe))
// end of [d2exp_ann_seff]

implement
d2exp_ann_funclo
  (loc, d2e, fc) =
  d2exp_make_node (loc, d2exp_node_D2Eann_funclo(d2e, fc))
// end of [d2exp_ann_funclo]

(* ****** ****** *)

implement
d2exp_mac
  (loc, d2m) =
  d2exp_make_node (loc, d2exp_node_D2Emac(d2m))
// end of [d2exp_mac]

implement
d2exp_macsyn
  (loc, knd, d2e) =
  d2exp_make_node (loc, d2exp_node_D2Emacsyn(knd, d2e))
// end of [d2exp_macsyn]

implement
d2exp_macfun
  (loc, name, d2es) =
  d2exp_make_node (loc, d2exp_node_D2Emacfun(name, d2es))
// end of [d2exp_macfun]

(* ****** ****** *)
//
implement
d2exp_solassert
  (loc, d2e_prf) =
  d2exp_make_node(loc, d2exp_node_D2Esolassert(d2e_prf))
implement
d2exp_solverify
  (loc, s2e_prop) =
  d2exp_make_node(loc, d2exp_node_D2Esolverify(s2e_prop))
//
(* ****** ****** *)
//
implement
d2exp_errexp(loc) =
  d2exp_make_node (loc, d2exp_node_D2Eerrexp((*void*)))
//
(* ****** ****** *)

implement
labd2exp_make (l, d2e) = labd2exp_new(l, d2e)

(* ****** ****** *)

implement
d2lab_lab
(
  loc, lab, opt
) = d2lab_new(loc, d2lab_node_D2LABlab(lab), opt) // end of [d2lab_lab]

implement
d2lab_ind
  (loc, ind) = d2lab_new(loc, d2lab_node_D2LABind(ind), gopt_none((*void*))) // end of [d2lab_ind]

(* ****** ****** *)

implement
i2nvarg_make
  (d2v, s2e) =
i2nvarg_new(d2v, s2e) (* end of [i2nvarg_make] *)

(* ****** ****** *)

implement
i2nvarg_get_var
  (arg) = let
  val d2v = arg.i2nvarg_var()
  val opt = d2var_get_view (d2v)
in
  case+ gopt_view(opt) of
  | ~GOsome(d2vw) => d2vw | ~GOnone() => d2v
end // end of [i2nvarg_get_var]

implement
i2nvarg_get_type
  (arg) = let
//
val opt = arg.i2nvarg_type()
//
in
//
case+ gopt_view(opt) of
| ~GOnone() => gopt_none()
| ~GOsome(s2e) => let
    val d2v = arg.i2nvarg_var()
    val ismut = d2var_is_mutabl (d2v)
  in
    if ismut
      then let
        val s2l =
          gopt_unsome<s2exp> (d2var_get_addr(d2v))
        // end of [val]
      in
        gopt_some(s2exp_at (s2e, s2l))
      end // end of [then]
      else opt // end of [else]
    // end of [if]
  end // end of [Some]
//
end // end of [i2nvarg_get_type]

(* ****** ****** *)

implement
i2nvresstate_nil =
  i2nvresstate_make (
  glist_nil((*svs*)), glist_nil((*gua*)), glist_nil((*arg*))
) // end of [i2nvresstate_nil]

implement
i2nvresstate_make
  (s2vs, s2ps, arg) =
i2nvresstate_new(s2vs, s2ps, arg, gopt_none()) // end of [i2nvresstate_make]

implement
i2nvresstate_make_met
 (svs, gua, arg, met) =
i2nvresstate_new(svs, gua, arg, met) // end of [i2nvresstate_make]

(* ****** ****** *)

implement
loopi2nv_make (
  loc, svs, gua, met, arg, res
) = loopi2nv_new(loc, svs, gua, arg, met, res) // end of [loopi2nv_make]

(* ****** ****** *)

implement
i2fcl_make
  (loc, test, body) = i2fcl_new(loc, test, body) (* end of [i2fcl_make] *)

(* ****** ****** *)

implement
gm2at_make
  (loc, d2e, p2topt) = gm2at_new(loc, d2e, p2topt) // end of [gm2at_make]

implement
c2lau_make (
  loc, p2t, gua, seq, neg, d2e
) = c2lau_new(loc, p2t, gua, seq, neg, d2e) // end of [c2lau_make]

implement
sc2lau_make (loc, sp2t, d2e) = sc2lau_new(loc, sp2t, d2e) // end of [sc2lau_make]

(* ****** ****** *)
//
// HX: various declarations
//
(* ****** ****** *)

implement
i2mpdec_make (
  loc, locid
, d2c, s2vs, s2ess, s2pss, def
) = i2mpdec_new(loc, locid, d2c, s2vs, s2ess, s2pss, def) // end of [i2mpdec_make]

(* ****** ****** *)

implement
f2undec_make (
  loc, d2v, def, ann
) = f2undec_new(loc, d2v, def, ann) // end of [f2undec_make]

(* ****** ****** *)

implement
v2aldec_make (
  loc, p2t, def, ann
) = v2aldec_new(loc, p2t, def, ann) // end of [v2aldec_make]

(* ****** ****** *)

implement
v2ardec_make
(
  loc, knd
, s2v, d2v, pfat, s2eopt, init, d2vopt
) = v2ardec_new(loc, knd, s2v, d2v, pfat, s2eopt, init, d2vopt) // end of [v2ardec_make]

implement
prv2ardec_make (
  loc, d2v, s2eopt, init
) = prv2ardec_new(loc, d2v, s2eopt, init) // end of [prv2ardec_make]

(* ****** ****** *)
//
extern
fun
d2ecl_make_node
(
  loc: location, node: d2ecl_node
) : d2ecl // end-of-function
implement
d2ecl_make_node
  (loc, node) = d2ecl_new(loc, node)
//
(* ****** ****** *)
//
implement
d2ecl_none(loc) =
  d2ecl_make_node (loc, d2ecl_node_D2Cnone())
//
implement
d2ecl_list(loc, xs) =
  d2ecl_make_node (loc, d2ecl_node_D2Clist(xs))
//
(* ****** ****** *)

implement
d2ecl_symintr
  (loc, ids) =
  d2ecl_make_node (loc, d2ecl_node_D2Csymintr(ids))
// end of [d2ecl_symintr]
implement
d2ecl_symelim
  (loc, ids) =
  d2ecl_make_node (loc, d2ecl_node_D2Csymelim(ids))
// end of [d2ecl_symelim]

(* ****** ****** *)

implement
d2ecl_overload
(
  loc, id, pval, def
) = d2ecl_make_node(loc, d2ecl_node_D2Coverload(id, pval, def))
// end of [d2ecl_overload]

(* ****** ****** *)
//
implement
d2ecl_pragma
  (loc, e1xps) =
  d2ecl_make_node(loc, d2ecl_node_D2Cpragma(e1xps))
//
implement
d2ecl_codegen
  (loc, knd, xs) =
  d2ecl_make_node(loc, d2ecl_node_D2Ccodegen(knd, xs))
//
(* ****** ****** *)
//
implement
d2ecl_stacsts
  (loc, s2cs) =
  d2ecl_make_node (loc, d2ecl_node_D2Cstacsts(s2cs))
implement
d2ecl_stacons
  (loc, knd, s2cs) =
  d2ecl_make_node (loc, d2ecl_node_D2Cstacons(knd, s2cs))
//
(* ****** ****** *)

(*
implement
d2ecl_stavars
  (loc, xs) = d2ecl_make_node (loc, D2Cstavars (xs))
// end of [d2ecl_stavars]
*)

(* ****** ****** *)
//
implement
d2ecl_saspdec
  (loc, d0) = d2ecl_make_node(loc, d2ecl_node_D2Csaspdec(d0))
//
implement
d2ecl_reassume
  (loc, s2c) = d2ecl_make_node(loc, d2ecl_node_D2Creassume(s2c))
//
(* ****** ****** *)
//
implement
d2ecl_extype (loc, name, def) =
  d2ecl_make_node (loc, d2ecl_node_D2Cextype(name, def))
implement
d2ecl_extvar (loc, name, def) =
  d2ecl_make_node (loc, d2ecl_node_D2Cextvar(name, def))
implement
d2ecl_extcode (loc, knd, pos, code) =
  d2ecl_make_node (loc, d2ecl_node_D2Cextcode(knd, pos, code))
//
(* ****** ****** *)
//
implement
d2ecl_exndecs (loc, d2cs) =
 d2ecl_make_node (loc, d2ecl_node_D2Cexndecs(d2cs))
//
implement
d2ecl_datdecs (loc, knd, s2cs) =
  d2ecl_make_node (loc, d2ecl_node_D2Cdatdecs(knd, s2cs))
//
(* ****** ****** *)
//
implement
d2ecl_dcstdecs
  (loc, knd, dck, d2cs) =
  d2ecl_make_node (loc, d2ecl_node_D2Cdcstdecs(knd, dck, d2cs))
//
(* ****** ****** *)
//
implement
d2ecl_fundecs (loc, knd, decarg, f2ds) =
  d2ecl_make_node (loc, d2ecl_node_D2Cfundecs(knd, decarg, f2ds))
//
(* ****** ****** *)

implement
d2ecl_valdecs (loc, knd, v2ds) =
  d2ecl_make_node (loc, d2ecl_node_D2Cvaldecs(knd, v2ds))

implement
d2ecl_valdecs_rec (loc, knd, v2ds) =
  d2ecl_make_node (loc, d2ecl_node_D2Cvaldecs_rec(knd, v2ds))

(* ****** ****** *)

implement
d2ecl_vardecs (loc, v2ds) =
  d2ecl_make_node (loc, d2ecl_node_D2Cvardecs(v2ds))

implement
d2ecl_prvardecs (loc, v2ds) =
  d2ecl_make_node (loc, d2ecl_node_D2Cprvardecs(v2ds))

(* ****** ****** *)

implement
d2ecl_impdec (loc, knd, d2c) =
  d2ecl_make_node (loc, d2ecl_node_D2Cimpdec(knd, d2c))

(* ****** ****** *)

implement
d2ecl_include (loc, knd, d2cs) =
  d2ecl_make_node (loc, d2ecl_node_D2Cinclude(knd, d2cs))

(* ****** ****** *)

implement
d2ecl_staload (
  loc, idopt, cfil, flag, fenv, loaded
) = d2ecl_make_node
  (loc, d2ecl_node_D2Cstaload(idopt, cfil, flag, fenv, loaded))
// endof [d2ecl_staload]

implement
d2ecl_staloadloc (
  loc, pfil, nspace, fenv
) = d2ecl_make_node (loc, d2ecl_node_D2Cstaloadloc(pfil, nspace, fenv))

(* ****** ****** *)

implement
d2ecl_dynload (loc, fil) = d2ecl_make_node (loc, d2ecl_node_D2Cdynload(fil))

(* ****** ****** *)

implement d2ecl_local
  (loc, head, body) = d2ecl_make_node (loc, d2ecl_node_D2Clocal(head, body))
// end of [d2ecl_local]

(* ****** ****** *)

implement d2ecl_errdec (loc) = d2ecl_make_node (loc, d2ecl_node_D2Cerrdec())

(* ****** ****** *)

implement
p2at_set_type (p2t, opt) = set_p2at_type (p2t, opt)
// the field [p2at_type] is a [mut] field of the record (ATS1: C function patsopt_p2at_set_type)

(* ****** ****** *)

(* end of [pats_dynexp2.dats] *)
