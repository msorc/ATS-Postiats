(* ATS1: the language layer of the C1 test (see cc1_lang2.hats) *)
(* ****** ****** *)
//
%{^
#include <stdio.h>
#define fflush_stdout() fflush(stdout)
%}
extern fun fflush_stdout (): void = "mac#fflush_stdout"
//
fun mkloc (k: int): location = let
  var p1: $LOC.position
  var p2: $LOC.position
  val () = $LOC.position_init (p1, lint_of_int (k), k+1, k)
  val () = $LOC.position_init (p2, lint_of_int (k+3), k+1, k+3)
  val fil = $FIL.filename_make ("given", "part", "full")
in
  $LOC.location_make_fil_pos_pos (fil, p1, p2)
end
fun mksym (k: int): symbol = $SYM.symbol_make_string (
  case+ k mod 7 of 0 => "a" | 1 => "bb" | 2 => "+" | 3 => "x_y" | 4 => "z" | 5 => "S" | _ => "w1"
)
fun mkfil (k: int): filename = $FIL.filename_make ("g", "p", "f")
fun mkfilenv (k: int): filenv = $UN.cast{filenv} (lint_of_int (k + 1))
fun mkd2var (k: int): d2var = d2var_make (mkloc (k), mksym (k))
fun mkd2cst (k: int): d2cst =
  d2cst_make (mksym (k), mkloc (k), mkfil (0), DCKfun (), list_nil (), list_nil (), s2exp_int (0), DCSTEXTDEFnone (0))
fun LN_s2rtlstlst (): s2rtlstlst = list_nil ()
fun LN_syms2rtlstlst (): List (List (@(symbol, s2rt))) = list_nil ()
fun LN_s2explst (): s2explst = list_nil ()
fun LC_s2explst (x: s2exp, xs: s2explst): s2explst = list_cons (x, xs)
fun ON_s2explstopt (): s2explstopt = None ()
fun mkd2con (k: int): d2con = d2con_make (mkloc (k), mkfil (0), mksym (k),
  s2cst_make_dat (mksym (k), mkloc (k), LN_s2rtlstlst (), s2rt_view, LN_syms2rtlstlst ()), 0, list_nil (), 0,
  (if k mod 2 = 0 then LN_s2explst () else LC_s2explst (s2exp_int (0), LN_s2explst ())), ON_s2explstopt ())
fun mkcaskind (k: int): caskind = (case+ k mod 3 of 0 => CK_case () | 1 => CK_case_pos () | _ => CK_case_neg ())
fun mkpckind (k: int): pckind = (case+ k mod 4 of 0 => PCKcon () | 1 => PCKlincon () | 2 => PCKfree () | _ => PCKunfold ())
fun mkfunkind (k: int): funkind = (case+ k mod 3 of 0 => FK_fn () | 1 => FK_fun () | _ => FK_fnx ())
//
(* ****** ****** *)
//
fun LN_d2envlst (): d2envlst = list_nil ()
fun LC_d2envlst (x: d2env, xs: d2envlst): d2envlst = list_cons (x, xs)
fun LN_d2varlst (): d2varlst = list_nil ()
fun LC_d2varlst (x: d2var, xs: d2varlst): d2varlst = list_cons (x, xs)
fun LN_hifundeclst (): hifundeclst = list_nil ()
fun LC_hifundeclst (x: hifundec, xs: hifundeclst): hifundeclst = list_cons (x, xs)
fun LN_hiimpdeclst (): hiimpdeclst = list_nil ()
fun LC_hiimpdeclst (x: hiimpdec, xs: hiimpdeclst): hiimpdeclst = list_cons (x, xs)
fun LN_s2qualst (): s2qualst = list_nil ()
fun LN_s2varlst (): s2varlst = list_nil ()
fun LN_s2explstlst (): s2explstlst = list_nil ()
fun LN_t2mpmarglst (): t2mpmarglst = list_nil ()
fun LN_funlablst (): funlablst = list_nil ()
fun LC_funlablst (x: funlab, xs: funlablst): funlablst = list_cons (x, xs)
fun LN_tmpvarlst (): tmpvarlst = list_nil ()
fun LN_instrlst (): instrlst = list_nil ()
fun LC_instrlst (x: instr, xs: instrlst): instrlst = list_cons (x, xs)
fun LN_hideclist (): hideclist = list_nil ()
fun LN_primvalist (): primvalist = list_nil ()
fun len_hideclist (xs: hideclist): int = list_length (xs)
fun len_tmpvarlst (xs: tmpvarlst): int = list_length (xs)
fun len_primdeclst (xs: primdeclst): int = list_length (xs)
//
fun ON_d2cstopt (): d2cstopt = None ()
fun OS_d2cstopt (x: d2cst): d2cstopt = Some (x)
fun ON_d2varopt (): d2varopt = None ()
fun OS_d2varopt (x: d2var): d2varopt = Some (x)
fun ON_tmpsubopt (): tmpsubopt = None ()
fun OS_funentopt (x: funent): funentopt = Some (x)
//
fun mk_vbmap_nil (): vbindmap = d2varmap_nil {primval} ()
fun vbmap_ins (m: &vbindmap, d2v: d2var, pmv: primval): void = let
  val _ = d2varmap_insert {primval} (m, d2v, pmv) in () end
//
fun K_tmpsub_nil (): tmpsub = TMPSUBnil ()
fun K_tmpsub_cons (v: s2var, e: s2exp, ts: tmpsub): tmpsub = TMPSUBcons (v, e, ts)
fun K_tmpcstmat_none (): tmpcstmat = TMPCSTMATnone ()
fun K_tmpcstmat_some (imp: hiimpdec, ts: tmpsub, k: int): tmpcstmat = TMPCSTMATsome (imp, ts, k)
fun K_tmpcstmat_some2 (d2c: d2cst, ess: s2explstlst, fl: funlab): tmpcstmat = TMPCSTMATsome2 (d2c, ess, fl)
fun is_tmpcstmat_none (x: tmpcstmat): bool = (case+ x of TMPCSTMATnone () => true | _ => false)
fun K_tmpvarmat_none (): tmpvarmat = TMPVARMATnone ()
fun K_tmpvarmat_some (hfd: hifundec, ts: tmpsub, k: int): tmpvarmat = TMPVARMATsome (hfd, ts, k)
fun K_tmpvarmat_some2 (d2v: d2var, ess: s2explstlst, fl: funlab): tmpvarmat = TMPVARMATsome2 (d2v, ess, fl)
fun is_tmpvarmat_none (x: tmpvarmat): bool = (case+ x of TMPVARMATnone () => true | _ => false)
fun K_hifundec2 (hfd: hifundec, ts: tmpsub): hifundec2 = HIFUNDEC2 (hfd, ts)
fun K_hiimpdec2 (imp: hiimpdec, ts: tmpsub, ess: s2explstlst): hiimpdec2 = HIIMPDEC2 (imp, ts, ess)
//
fun imp_cst (imp: hiimpdec): d2cst = imp.hiimpdec_cst
fun imp2_imp (imp2: hiimpdec2): hiimpdec = (case+ imp2 of HIIMPDEC2 (imp, _, _) => imp)
fun hfd_var (hfd: hifundec): d2var = hfd.hifundec_var
fun hfd2_hfd (hfd2: hifundec2): hifundec = (case+ hfd2 of HIFUNDEC2 (hfd, _) => hfd)
//
fun rd_tmpvarlst (p: Ptr1): tmpvarlst = $UN.ptrget<tmpvarlst> (p)
fun wr_tmpvarlst (p: Ptr1, xs: tmpvarlst): void = $UN.ptrset<tmpvarlst> (p, xs)
fun rd_primdeclst (p: Ptr1): primdeclst = $UN.ptrget<primdeclst> (p)
fun wr_primdeclst (p: Ptr1, xs: primdeclst): void = $UN.ptrset<primdeclst> (p, xs)
fun mk_primdeclst1 (loc: location): primdeclst = list_cons (primdec_none (loc), list_nil ())
//
%{^
extern void *cc1_fenv_cell (void*, int) ;
%}
extern fun cc1_fenv_cell (fenv: filenv, k: int): Ptr1 = "cc1_fenv_cell"
fun K_tmpcstimpmapopt_none (): tmpcstimpmapopt = None ()
fun K_tmpvardecmapopt_none (): tmpvardecmapopt = None ()
fun fenv_set_tcmap (fenv: filenv, xs: hiimpdeclst): void = let
  var m: tmpcstimpmap = d2cstmap_nil {hiimpdeclst} ()
  fun loop (m: &tmpcstimpmap, xs: hiimpdeclst): void =
    case+ xs of
    | list_cons (x, xs) => (tmpcstimpmap_insert (m, x); loop (m, xs))
    | list_nil () => ()
  val () = loop (m, xs)
in
  $UN.ptrset<tmpcstimpmapopt> (cc1_fenv_cell (fenv, 1), Some (m))
end
fun fenv_set_tvmap (fenv: filenv, xs: hifundeclst): void = let
  var m: tmpvardecmap = d2varmap_nil {hifundec} ()
  val () = tmpvardecmap_inserts (m, xs)
in
  $UN.ptrset<tmpvardecmapopt> (cc1_fenv_cell (fenv, 2), Some (m))
end
//
fun dd_hideclist (xs: hideclist): void = let
  fun loop (xs: hideclist, i: int): void =
    case+ xs of
    | list_cons (x, xs) => ((if i > 0 then fprint_string (dd_out, ",")); fprint_hidecl (dd_out, x); loop (xs, i+1))
    | list_nil () => ()
in
  fprint_string (dd_out, "["); loop (xs, 0); fprint_string (dd_out, "]")
end
fun hiimpdeclst_find_match (imps: hiimpdeclst, d2c: d2cst, knd: int): tmpcstmat =
  case+ imps of
  | list_nil () => TMPCSTMATnone ()
  | list_cons (imp, imps) =>
    if eq_d2cst_d2cst (imp.hiimpdec_cst, d2c) then TMPCSTMATsome (imp, TMPSUBnil (), knd+20)
    else hiimpdeclst_find_match (imps, d2c, knd)
fun LC1_s2qualst (): s2qualst = list_cons (s2qua_make (list_nil (), list_nil ()), list_nil ())
//
extern fun cc1_getlev (): int = "cc1_getlev"
extern fun cc1_setlev (k: int): void = "cc1_setlev"
extern fun cc1_getonly (): int = "cc1_getonly"
//
(* ****** ****** *)
//
// the trees of the erased syntax of the scenarios of caseof/looping/trywith/lazyeval, and the readers of the doubles of hidexp_ccomp
//
fun LN_hidexplst (): hidexplst = list_nil ()
fun LC_hidexplst (x: hidexp, xs: hidexplst): hidexplst = list_cons (x, xs)
fun LN_hiclaulst (): hiclaulst = list_nil ()
fun LC_hiclaulst (x: hiclau, xs: hiclaulst): hiclaulst = list_cons (x, xs)
fun LN_hipatlst (): hipatlst = list_nil ()
fun LC_hipatlst (x: hipat, xs: hipatlst): hipatlst = list_cons (x, xs)
fun LN_higmatlst (): higmatlst = list_nil ()
fun LN_ibranchlst (): ibranchlst = list_nil ()
fun LC_ibranchlst (x: ibranch, xs: ibranchlst): ibranchlst = list_cons (x, xs)
fun ON_hidexpopt (): hidexpopt = None ()
fun OS_hidexpopt (x: hidexp): hidexpopt = Some (x)
fun len_hicls (xs: hiclaulst): int = list_length (xs)
fun len_hipatlst (xs: hipatlst): int = list_length (xs)
fun len_primvalist (xs: primvalist): int = list_length (xs)
fun hicls_nth (xs: hiclaulst, i: int): hiclau = let
  val-list_cons (x, xs1) = xs
in
  if i <= 0 then x else hicls_nth (xs1, i-1)
end
fun hicl_body (x: hiclau): hidexp = x.hiclau_body
fun hde_loc (x: hidexp): location = x.hidexp_loc
fun hde_type (x: hidexp): hisexp = x.hidexp_type
fun hde_tag (x: hidexp): int = (
  case+ x.hidexp_node of
  | HDEint _ => 0
  | HDEvar _ => 1
  | HDEcase _ => 2
  | HDEloop _ => 3
  | HDEloopexn _ => 4
  | HDEtrywith _ => 5
  | HDEdelay _ => 6
  | HDEldelay _ => 7
  | HDElazyeval _ => 8
  | _ => 9
)
fun hde_int (x: hidexp): int = let val-HDEint (i) = x.hidexp_node in i end
fun hde_var (x: hidexp): d2var = let val-HDEvar (v) = x.hidexp_node in v end
fun pk_kind (k: patckont): int = (
  case+ k of
  | PTCKNTnone () => 0
  | PTCKNTcaseof_fail _ => 1
  | PTCKNTraise _ => 2
  | _ => 3
)
fun instrseq_add_instrlst (res: !instrseq, xs: instrlst): void =
  case+ xs of
  | list_nil () => ()
  | list_cons (x, xs) => (instrseq_add (res, x); instrseq_add_instrlst (res, xs))
//
extern fun cc1_tbl_set (k: int, p: ptr): void = "cc1_tbl_set"
extern fun cc1_tbl_get (k: int): ptr = "cc1_tbl_get"
fun dbl_dv_set (k: int, d2v: d2var): void = cc1_tbl_set (k, $UN.cast{ptr} (d2v))
fun dbl_dv_get (k: int): d2var = $UN.cast{d2var} (cc1_tbl_get (k))
extern fun cc1_str4 (what: string, a: int, b: int, c: int): string = "cc1_str4"
fun set_dv_hisexp (d2v: d2var, hse: hisexp): void = d2var_set_hisexp (d2v, Some ($UN.cast{dynexp2_hisexp_type} (hse)))
fun mk_tmpvarlst1 (tmp: tmpvar): tmpvarlst = list_cons (tmp, list_nil ())
fun dd_pad (n: int): void = if n > 0 then (fprint_string (dd_out, "  "); dd_pad (n-1))
fun dd_instrlst_deep (xs: instrlst, ind: int): void =
  case+ xs of
  | list_nil () => ()
  | list_cons (x, xs1) => (dd_instr_deep (x, ind); dd_instrlst_deep (xs1, ind))
and dd_ibranchlst_deep (xs: ibranchlst, ind: int): void =
  case+ xs of
  | list_nil () => ()
  | list_cons (x, xs1) => let
      val () = (dd_pad (ind); fprint_string (dd_out, "BRANCH "); $LOC.fprint_location (dd_out, x.ibranch_loc); fprint_newline (dd_out))
    in
      dd_instrlst_deep (x.ibranch_inslst, ind+1); dd_ibranchlst_deep (xs1, ind)
    end
and dd_instr_deep (x: instr, ind: int): void = let
  val () = dd_pad (ind)
  val () = $LOC.fprint_location (dd_out, x.instr_loc)
  val () = fprint_string (dd_out, " ")
in
  case+ x.instr_node of
  | INSloop (t1, t2, t3, i1, pmv, i2, i3, i4) => let
      val () = (fprint_string (dd_out, "LOOP "); fprint_tmplab (dd_out, t1); fprint_string (dd_out, " "); fprint_tmplab (dd_out, t2)
        ; fprint_string (dd_out, " "); fprint_tmplab (dd_out, t3); fprint_string (dd_out, " test="); fprint_primval (dd_out, pmv); fprint_newline (dd_out))
      val () = (dd_pad (ind); fprint_string (dd_out, "init:\n")); val () = dd_instrlst_deep (i1, ind+1)
      val () = (dd_pad (ind); fprint_string (dd_out, "test:\n")); val () = dd_instrlst_deep (i2, ind+1)
      val () = (dd_pad (ind); fprint_string (dd_out, "post:\n")); val () = dd_instrlst_deep (i3, ind+1)
      val () = (dd_pad (ind); fprint_string (dd_out, "body:\n"))
    in
      dd_instrlst_deep (i4, ind+1)
    end
  | INScaseof (ibs) => (fprint_string (dd_out, "CASEOF\n"); dd_ibranchlst_deep (ibs, ind+1))
  | INStrywith (tmp, ins, ibs) => let
      val () = (fprint_string (dd_out, "TRYWITH "); fprint_tmpvar (dd_out, tmp); fprint_newline (dd_out))
      val () = (dd_pad (ind); fprint_string (dd_out, "try:\n")); val () = dd_instrlst_deep (ins, ind+1)
      val () = (dd_pad (ind); fprint_string (dd_out, "with:\n"))
    in
      dd_ibranchlst_deep (ibs, ind+1)
    end
  | INSloopexn (knd, tl) => (fprint_string (dd_out, "LOOPEXN "); fprint_int (dd_out, knd); fprint_string (dd_out, " "); fprint_tmplab (dd_out, tl); fprint_newline (dd_out))
  | INSmove_delay (tmp, lin, hse, pmv) => (fprint_string (dd_out, "MOVE_DELAY "); fprint_tmpvar (dd_out, tmp); fprint_string (dd_out, " "); fprint_int (dd_out, lin)
      ; fprint_string (dd_out, " "); fprint_hisexp (dd_out, hse); fprint_string (dd_out, " "); fprint_primval (dd_out, pmv); fprint_newline (dd_out))
  | INSmove_lazyeval (tmp, lin, hse, pmv) => (fprint_string (dd_out, "MOVE_LAZYEVAL "); fprint_tmpvar (dd_out, tmp); fprint_string (dd_out, " "); fprint_int (dd_out, lin)
      ; fprint_string (dd_out, " "); fprint_hisexp (dd_out, hse); fprint_string (dd_out, " "); fprint_primval (dd_out, pmv); fprint_newline (dd_out))
  | _ => (fprint_instr (dd_out, x); fprint_newline (dd_out))
end
fun dd_funlablst_ents (fls: funlablst): void =
  case+ fls of
  | list_nil () => ()
  | list_cons (fl, fls) => let
      val () = (fprint_funlab (dd_out, fl); fprint_string (dd_out, ": "))
      val () = (case+ funlab_get_funent (fl) of
        | Some (fent) => (fprint_string (dd_out, "funent tmpret="); fprint_tmpvar (dd_out, funent_get_tmpret fent); fprint_newline (dd_out); dd_instrlst_deep (funent_get_instrlst fent, 1))
        | None () => fprint_string (dd_out, "no funent\n"))
    in
      dd_funlablst_ents (fls)
    end
fun LN_hisexplst (): hisexplst = list_nil ()
fun LC_hisexplst (x: hisexp, xs: hisexplst): hisexplst = list_cons (x, xs)
fun mkfunclo (k: int): funclo = (case+ k mod 4 of 0 => FUNCLOfun () | 1 => FUNCLOclo (1) | 2 => FUNCLOclo (0) | _ => FUNCLOclo (~1))
fun K_perv_itm (id: symbol): s2itm = S2ITMcst (list_cons (s2cst_make_dat (id, mkloc (0), LN_s2rtlstlst (), s2rt_type, LN_syms2rtlstlst ()), list_nil ()))
extern fun cc1_getexit (): int = "cc1_getexit"
fun LC_s2explstlst (x: s2explst, xs: s2explstlst): s2explstlst = list_cons (x, xs)
fun imp2_arg (imp2: hiimpdec2): s2explstlst = (case+ imp2 of HIIMPDEC2 (_, _, ess) => ess)
fun fenv_id (x: filenv): int = int_of_lint ($UN.cast{lint} (x))
fun mk_tmpvarlst_n (tmp: tmpvar, n: int): tmpvarlst = if n <= 0 then list_nil () else list_cons (tmp, mk_tmpvarlst_n (tmp, n-1))
fun mk_primdeclst_n (loc: location, n: int): primdeclst = if n <= 0 then list_nil () else list_cons (primdec_none (loc), mk_primdeclst_n (loc, n-1))
