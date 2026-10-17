(* ATS2: the language layer of the C1 test (constructors, typed lists and options that differ between ATS1 and ATS2; see cc1_lang1.hats, cc1_gen.py) *)
(* ****** ****** *)
//
%{^
#include <stdio.h>
#define fflush_stdout() fflush(stdout)
extern void cc1_tbl_set (int, void*) ;
extern void *cc1_tbl_get (int) ;
extern char *cc1_str4 (const char*, int, int, int) ;
extern int cc1_getlev (void) ;
extern void cc1_setlev (int) ;
extern int cc1_getonly (void) ;
extern int cc1_getexit (void) ;
%}
extern fun fflush_stdout (): void = "mac#fflush_stdout"
//
fun mkloc (k: int): location = let
  var p1: $LOC.position
  var p2: $LOC.position
  val () = $LOC.position_init (p1, $UN.cast{lint} (k), k+1, k)
  val () = $LOC.position_init (p2, $UN.cast{lint} (k+3), k+1, k+3)
  val fil = $FIL.filename_make ("given", "part", "full")
in
  $LOC.location_make_fil_pos_pos (fil, p1, p2)
end
fun mksym (k: int): symbol = $SYM.symbol_make_string (
  case+ k mod 7 of 0 => "a" | 1 => "bb" | 2 => "+" | 3 => "x_y" | 4 => "z" | 5 => "S" | _ => "w1"
)
fun mkfil (k: int): filename = $FIL.filename_make ("g", "p", "f")
fun mkfilenv (k: int): filenv = $UN.cast{filenv} ($UN.cast{lint} (k + 1))
fun mkd2var (k: int): d2var = d2var_make (mkloc (k), mksym (k))
fun mkd2cst (k: int): d2cst =
  d2cst_make (mksym (k), mkloc (k), mkfil (0), DCKfun, glist_nil (), glist_nil (), s2exp_int (0), dcstextdef_DCSTEXTDEFnone (0))
fun LN_s2rtlstlst (): s2rtlstlst = glist_nil ()
fun LN_syms2rtlstlst (): syms2rtlstlst = glist_nil ()
fun LN_s2explst (): s2explst = glist_nil ()
fun LC_s2explst (x: s2exp, xs: s2explst): s2explst = glist_cons<s2exp> (x, xs)
fun ON_s2explstopt (): s2explstopt = gopt_none ()
fun mkd2con (k: int): d2con = d2con_make (mkloc (k), mkfil (0), mksym (k),
  s2cst_make_dat (mksym (k), mkloc (k), LN_s2rtlstlst (), s2rt_view, LN_syms2rtlstlst ()), 0, glist_nil (), 0,
  (if k mod 2 = 0 then LN_s2explst () else LC_s2explst (s2exp_int (0), LN_s2explst ())), ON_s2explstopt ())
fun mkcaskind (k: int): caskind = (case+ k mod 3 of 0 => CK_case | 1 => CK_case_pos | _ => CK_case_neg)
fun mkpckind (k: int): pckind = (case+ k mod 4 of 0 => PCKcon | 1 => PCKlincon | 2 => PCKfree | _ => PCKunfold)
fun mkfunkind (k: int): funkind = (case+ k mod 3 of 0 => FK_fn | 1 => FK_fun | _ => FK_fnx)
//
(* ****** ****** *)
//
fun LN_d2envlst (): d2envlst = glist_nil ()
fun LC_d2envlst (x: d2env, xs: d2envlst): d2envlst = glist_cons<d2env> (x, xs)
fun LN_d2varlst (): d2varlst = glist_nil ()
fun LC_d2varlst (x: d2var, xs: d2varlst): d2varlst = glist_cons<d2var> (x, xs)
fun LN_hifundeclst (): hifundeclst = glist_nil ()
fun LC_hifundeclst (x: hifundec, xs: hifundeclst): hifundeclst = glist_cons<hifundec> (x, xs)
fun LN_hiimpdeclst (): hiimpdeclst = glist_nil ()
fun LC_hiimpdeclst (x: hiimpdec, xs: hiimpdeclst): hiimpdeclst = glist_cons<hiimpdec> (x, xs)
fun LN_s2qualst (): s2qualst = glist_nil ()
fun LN_s2varlst (): s2varlst = glist_nil ()
fun LN_s2explstlst (): s2explstlst = glist_nil ()
fun LN_t2mpmarglst (): t2mpmarglst = glist_nil ()
fun LN_funlablst (): funlablst = glist_nil ()
fun LC_funlablst (x: funlab, xs: funlablst): funlablst = glist_cons<funlab> (x, xs)
fun LN_tmpvarlst (): tmpvarlst = glist_nil ()
fun LN_instrlst (): instrlst = glist_nil ()
fun LC_instrlst (x: instr, xs: instrlst): instrlst = glist_cons<instr> (x, xs)
fun LN_hideclist (): hideclist = glist_nil ()
fun LN_primvalist (): primvalist = glist_nil ()
fun len_hideclist (xs: hideclist): int = glist_length<hidecl> (xs)
fun len_tmpvarlst (xs: tmpvarlst): int = glist_length<tmpvar> (xs)
fun len_primdeclst (xs: primdeclst): int = glist_length<primdec> (xs)
//
fun ON_d2cstopt (): d2cstopt = gopt_none ()
fun OS_d2cstopt (x: d2cst): d2cstopt = gopt_some<d2cst> (x)
fun ON_d2varopt (): d2varopt = gopt_none ()
fun OS_d2varopt (x: d2var): d2varopt = gopt_some<d2var> (x)
fun ON_tmpsubopt (): tmpsubopt = gopt_none ()
fun OS_funentopt (x: funent): funentopt = gopt_some<funent> (x)
//
fun mk_vbmap_nil (): vbindmap = d2varmap_nil<primval> ()
fun vbmap_ins (m: &vbindmap, d2v: d2var, pmv: primval): void = let
  val _ = d2varmap_insert<primval> (m, d2v, pmv) in () end
//
fun K_tmpsub_nil (): tmpsub = tmpsub_TMPSUBnil ()
fun K_tmpsub_cons (v: s2var, e: s2exp, ts: tmpsub): tmpsub = tmpsub_TMPSUBcons (v, e, ts)
fun K_tmpcstmat_none (): tmpcstmat = tmpcstmat_TMPCSTMATnone ()
fun K_tmpcstmat_some (imp: hiimpdec, ts: tmpsub, k: int): tmpcstmat = tmpcstmat_TMPCSTMATsome (imp, ts, k)
fun K_tmpcstmat_some2 (d2c: d2cst, ess: s2explstlst, fl: funlab): tmpcstmat = tmpcstmat_TMPCSTMATsome2 (d2c, ess, fl)
fun is_tmpcstmat_none (x: tmpcstmat): bool = tmpcstmat_is_TMPCSTMATnone (x)
fun K_tmpvarmat_none (): tmpvarmat = tmpvarmat_TMPVARMATnone ()
fun K_tmpvarmat_some (hfd: hifundec, ts: tmpsub, k: int): tmpvarmat = tmpvarmat_TMPVARMATsome (hfd, ts, k)
fun K_tmpvarmat_some2 (d2v: d2var, ess: s2explstlst, fl: funlab): tmpvarmat = tmpvarmat_TMPVARMATsome2 (d2v, ess, fl)
fun is_tmpvarmat_none (x: tmpvarmat): bool = tmpvarmat_is_TMPVARMATnone (x)
fun K_hifundec2 (hfd: hifundec, ts: tmpsub): hifundec2 = hifundec2_new (hfd, ts)
fun K_hiimpdec2 (imp: hiimpdec, ts: tmpsub, ess: s2explstlst): hiimpdec2 = hiimpdec2_new (imp, ts, ess)
//
fun imp_cst (imp: hiimpdec): d2cst = imp.hiimpdec_cst ()
fun imp2_imp (imp2: hiimpdec2): hiimpdec = imp2.hiimpdec2_imp ()
fun hfd_var (hfd: hifundec): d2var = hfd.hifundec_var ()
fun hfd2_hfd (hfd2: hifundec2): hifundec = hfd2.hifundec2_hfd ()
//
fun rd_tmpvarlst (p: Ptr1): tmpvarlst = $UN.ptr0_get<tmpvarlst> (p)
fun wr_tmpvarlst (p: Ptr1, xs: tmpvarlst): void = $UN.ptr0_set<tmpvarlst> (p, xs)
fun rd_primdeclst (p: Ptr1): primdeclst = $UN.ptr0_get<primdeclst> (p)
fun wr_primdeclst (p: Ptr1, xs: primdeclst): void = $UN.ptr0_set<primdeclst> (p, xs)
fun mk_primdeclst1 (loc: location): primdeclst = glist_sing<primdec> (primdec_none (loc))
//
// the doubles of the functions of trans2_env that the C1 modules call (the file environments are the integers k+1)
//
%{^
extern void *cc1_fenv_cell (void*, int) ;
%}
extern fun cc1_fenv_cell (fenv: filenv, k: int): Ptr1 = "mac#cc1_fenv_cell"
fun K_tmpcstimpmapopt_none (): tmpcstimpmapopt = gopt_none ()
fun K_tmpvardecmapopt_none (): tmpvardecmapopt = gopt_none ()
fun fenv_set_tcmap (fenv: filenv, xs: hiimpdeclst): void = let
  var m: tmpcstimpmap = d2cstmap_nil<hiimpdeclst> ()
  fun loop (m: &tmpcstimpmap, xs: hiimpdeclst): void =
    case+ glist_view (xs) of
    | ~GLcons (x, xs) => (tmpcstimpmap_insert (m, x); loop (m, xs))
    | ~GLnil () => ()
  val () = loop (m, xs)
in
  $UN.ptr0_set<tmpcstimpmapopt> (cc1_fenv_cell (fenv, 1), gopt_some<tmpcstimpmap> (m))
end
fun fenv_set_tvmap (fenv: filenv, xs: hifundeclst): void = let
  var m: tmpvardecmap = d2varmap_nil<hifundec> ()
  val () = tmpvardecmap_inserts (m, xs)
in
  $UN.ptr0_set<tmpvardecmapopt> (cc1_fenv_cell (fenv, 2), gopt_some<tmpvardecmap> (m))
end
//
fun dd_hideclist (xs: hideclist): void = let
  fun loop (xs: hideclist, i: int): void =
    case+ glist_view (xs) of
    | ~GLcons (x, xs) => ((if i > 0 then fprint_string (dd_out, ",")); fprint_hidecl (dd_out, x); loop (xs, i+1))
    | ~GLnil () => ()
in
  fprint_string (dd_out, "["); loop (xs, 0); fprint_string (dd_out, "]")
end
fun hiimpdeclst_find_match (imps: hiimpdeclst, d2c: d2cst, knd: int): tmpcstmat =
  case+ glist_view (imps) of
  | ~GLnil () => tmpcstmat_TMPCSTMATnone ()
  | ~GLcons (imp, imps) =>
    if eq_d2cst_d2cst (imp.hiimpdec_cst (), d2c) then tmpcstmat_TMPCSTMATsome (imp, tmpsub_TMPSUBnil (), knd+20)
    else hiimpdeclst_find_match (imps, d2c, knd)
fun LC1_s2qualst (): s2qualst = glist_sing<s2qua> (s2qua_make (glist_nil (), glist_nil ()))
//
extern fun cc1_getlev (): int = "mac#cc1_getlev"
extern fun cc1_setlev (k: int): void = "mac#cc1_setlev"
extern fun cc1_getonly (): int = "mac#cc1_getonly"
//
(* ****** ****** *)
//
// the trees of the erased syntax of the scenarios of caseof/looping/trywith/lazyeval, and the readers of the doubles of hidexp_ccomp
//
fun LN_hidexplst (): hidexplst = glist_nil ()
fun LC_hidexplst (x: hidexp, xs: hidexplst): hidexplst = glist_cons<hidexp> (x, xs)
fun LN_hiclaulst (): hiclaulst = glist_nil ()
fun LC_hiclaulst (x: hiclau, xs: hiclaulst): hiclaulst = glist_cons<hiclau> (x, xs)
fun LN_hipatlst (): hipatlst = glist_nil ()
fun LC_hipatlst (x: hipat, xs: hipatlst): hipatlst = glist_cons<hipat> (x, xs)
fun LN_higmatlst (): higmatlst = glist_nil ()
fun LN_ibranchlst (): ibranchlst = glist_nil ()
fun LC_ibranchlst (x: ibranch, xs: ibranchlst): ibranchlst = glist_cons<ibranch> (x, xs)
fun ON_hidexpopt (): hidexpopt = gopt_none ()
fun OS_hidexpopt (x: hidexp): hidexpopt = gopt_some<hidexp> (x)
fun len_hicls (xs: hiclaulst): int = glist_length<hiclau> (xs)
fun len_hipatlst (xs: hipatlst): int = glist_length<hipat> (xs)
fun len_primvalist (xs: primvalist): int = glist_length<primval> (xs)
fun hicls_nth (xs: hiclaulst, i: int): hiclau = let
  val x = glist_head<hiclau> (xs)
in
  if i <= 0 then x else hicls_nth (glist_tail<hiclau> (xs), i-1)
end
fun hicl_body (x: hiclau): hidexp = x.hiclau_body ()
fun hde_loc (x: hidexp): location = x.hidexp_loc ()
fun hde_type (x: hidexp): hisexp = x.hidexp_type ()
fun hde_tag (x: hidexp): int = let
  val nd = x.hidexp_node ()
in
  if hidexp_node_is_HDEint (nd) then 0
  else if hidexp_node_is_HDEvar (nd) then 1
  else if hidexp_node_is_HDEcase (nd) then 2
  else if hidexp_node_is_HDEloop (nd) then 3
  else if hidexp_node_is_HDEloopexn (nd) then 4
  else if hidexp_node_is_HDEtrywith (nd) then 5
  else if hidexp_node_is_HDEdelay (nd) then 6
  else if hidexp_node_is_HDEldelay (nd) then 7
  else if hidexp_node_is_HDElazyeval (nd) then 8
  else 9
end
fun hde_int (x: hidexp): int = let val-~HDEint (i) = hidexp_node_view (x.hidexp_node ()) in i end
fun hde_var (x: hidexp): d2var = let val-~HDEvar (v) = hidexp_node_view (x.hidexp_node ()) in v end
fun pk_kind (k: patckont): int = (
  if patckont_is_PTCKNTnone (k) then 0
  else if patckont_is_PTCKNTcaseof_fail (k) then 1
  else if patckont_is_PTCKNTraise (k) then 2
  else 3
)
fun instrseq_add_instrlst (res: !instrseq, xs: instrlst): void =
  case+ glist_view (xs) of
  | ~GLnil () => ()
  | ~GLcons (x, xs) => (instrseq_add (res, x); instrseq_add_instrlst (res, xs))
//
extern fun cc1_tbl_set (k: int, p: ptr): void = "mac#cc1_tbl_set"
extern fun cc1_tbl_get (k: int): ptr = "mac#cc1_tbl_get"
fun dbl_dv_set (k: int, d2v: d2var): void = cc1_tbl_set (k, $UN.cast{ptr} (d2v))
fun dbl_dv_get (k: int): d2var = $UN.cast{d2var} (cc1_tbl_get (k))
extern fun cc1_str4 (what: string, a: int, b: int, c: int): string = "mac#cc1_str4"
fun set_dv_hisexp (d2v: d2var, hse: hisexp): void = d2var_set_hisexp (d2v, gopt_some<dynexp2_hisexp_type> ($UN.cast{dynexp2_hisexp_type} (hse)))
fun mk_tmpvarlst1 (tmp: tmpvar): tmpvarlst = glist_sing<tmpvar> (tmp)
fun dd_pad (n: int): void = if n > 0 then (fprint_string (dd_out, "  "); dd_pad (n-1))
fun dd_instrlst_deep (xs: instrlst, ind: int): void =
  case+ glist_view (xs) of
  | ~GLnil () => ()
  | ~GLcons (x, xs1) => (dd_instr_deep (x, ind); dd_instrlst_deep (xs1, ind))
and dd_ibranchlst_deep (xs: ibranchlst, ind: int): void =
  case+ glist_view (xs) of
  | ~GLnil () => ()
  | ~GLcons (x, xs1) => let
      val () = (dd_pad (ind); fprint_string (dd_out, "BRANCH "); $LOC.fprint_location (dd_out, x.ibranch_loc ()); fprint_newline (dd_out))
    in
      dd_instrlst_deep (x.ibranch_inslst (), ind+1); dd_ibranchlst_deep (xs1, ind)
    end
and dd_instr_deep (x: instr, ind: int): void = let
  val () = dd_pad (ind)
  val () = $LOC.fprint_location (dd_out, x.instr_loc ())
  val () = fprint_string (dd_out, " ")
in
  case+ instr_node_view (x.instr_node ()) of
  | ~INSloop (t1, t2, t3, i1, pmv, i2, i3, i4) => let
      val () = (fprint_string (dd_out, "LOOP "); fprint_tmplab (dd_out, t1); fprint_string (dd_out, " "); fprint_tmplab (dd_out, t2)
        ; fprint_string (dd_out, " "); fprint_tmplab (dd_out, t3); fprint_string (dd_out, " test="); fprint_primval (dd_out, pmv); fprint_newline (dd_out))
      val () = (dd_pad (ind); fprint_string (dd_out, "init:\n")); val () = dd_instrlst_deep (i1, ind+1)
      val () = (dd_pad (ind); fprint_string (dd_out, "test:\n")); val () = dd_instrlst_deep (i2, ind+1)
      val () = (dd_pad (ind); fprint_string (dd_out, "post:\n")); val () = dd_instrlst_deep (i3, ind+1)
      val () = (dd_pad (ind); fprint_string (dd_out, "body:\n"))
    in
      dd_instrlst_deep (i4, ind+1)
    end
  | ~INScaseof (ibs) => (fprint_string (dd_out, "CASEOF\n"); dd_ibranchlst_deep (ibs, ind+1))
  | ~INStrywith (tmp, ins, ibs) => let
      val () = (fprint_string (dd_out, "TRYWITH "); fprint_tmpvar (dd_out, tmp); fprint_newline (dd_out))
      val () = (dd_pad (ind); fprint_string (dd_out, "try:\n")); val () = dd_instrlst_deep (ins, ind+1)
      val () = (dd_pad (ind); fprint_string (dd_out, "with:\n"))
    in
      dd_ibranchlst_deep (ibs, ind+1)
    end
  | ~INSloopexn (knd, tl) => (fprint_string (dd_out, "LOOPEXN "); fprint_int (dd_out, knd); fprint_string (dd_out, " "); fprint_tmplab (dd_out, tl); fprint_newline (dd_out))
  | ~INSmove_delay (tmp, lin, hse, pmv) => (fprint_string (dd_out, "MOVE_DELAY "); fprint_tmpvar (dd_out, tmp); fprint_string (dd_out, " "); fprint_int (dd_out, lin)
      ; fprint_string (dd_out, " "); fprint_hisexp (dd_out, hse); fprint_string (dd_out, " "); fprint_primval (dd_out, pmv); fprint_newline (dd_out))
  | ~INSmove_lazyeval (tmp, lin, hse, pmv) => (fprint_string (dd_out, "MOVE_LAZYEVAL "); fprint_tmpvar (dd_out, tmp); fprint_string (dd_out, " "); fprint_int (dd_out, lin)
      ; fprint_string (dd_out, " "); fprint_hisexp (dd_out, hse); fprint_string (dd_out, " "); fprint_primval (dd_out, pmv); fprint_newline (dd_out))
  | v => (instr_node_view_free (v); fprint_instr (dd_out, x); fprint_newline (dd_out))
end
fun dd_funlablst_ents (fls: funlablst): void =
  case+ glist_view (fls) of
  | ~GLnil () => ()
  | ~GLcons (fl, fls) => let
      val () = (fprint_funlab (dd_out, fl); fprint_string (dd_out, ": "))
      val () = (case+ gopt_view (funlab_get_funent (fl)) of
        | ~GOsome (fent) => (fprint_string (dd_out, "funent tmpret="); fprint_tmpvar (dd_out, funent_get_tmpret fent); fprint_newline (dd_out); dd_instrlst_deep (funent_get_instrlst fent, 1))
        | ~GOnone () => fprint_string (dd_out, "no funent\n"))
    in
      dd_funlablst_ents (fls)
    end
fun LN_hisexplst (): hisexplst = glist_nil ()
fun LC_hisexplst (x: hisexp, xs: hisexplst): hisexplst = glist_cons<hisexp> (x, xs)
fun mkfunclo (k: int): funclo = (case+ k mod 4 of 0 => FUNCLOfun () | 1 => FUNCLOclo (1) | 2 => FUNCLOclo (0) | _ => FUNCLOclo (~1))
fun K_perv_itm (id: symbol): s2itm = s2itm_S2ITMcst (glist_sing<s2cst> (s2cst_make_dat (id, mkloc (0), LN_s2rtlstlst (), s2rt_type, LN_syms2rtlstlst ())))
extern fun cc1_getexit (): int = "mac#cc1_getexit"
fun LC_s2explstlst (x: s2explst, xs: s2explstlst): s2explstlst = glist_cons<s2explst> (x, xs)
fun imp2_arg (imp2: hiimpdec2): s2explstlst = imp2.hiimpdec2_arg ()
fun fenv_id (x: filenv): int = $UN.cast{int} ($UN.cast{lint} (x))
fun mk_tmpvarlst_n (tmp: tmpvar, n: int): tmpvarlst = if n <= 0 then glist_nil () else glist_cons<tmpvar> (tmp, mk_tmpvarlst_n (tmp, n-1))
fun mk_primdeclst_n (loc: location, n: int): primdeclst = if n <= 0 then glist_nil () else glist_cons<primdec> (primdec_none (loc), mk_primdeclst_n (loc, n-1))
