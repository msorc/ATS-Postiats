(* the doubles of the C1 test that are implemented once, by the driver (common subset of ATS1 and ATS2; see cc1_common.hats) *)
(* ****** ****** *)
//
// the double of the level of the variables (trans2_env, [the_d2varlev_get]): cc1_stub.c
//
implement the_d2varlev_get () = cc1_getlev ()

(* ****** ****** *)
//
// the doubles of the matching of the instances of templates (pats_ccomp_template.dats, group C3 of the port):
// they print their arguments and decide from the stamps
//
fun dd_stamp_even_d2cst (d2c: d2cst): bool = ($STMP.stamp_get_int (d2cst_get_stamp d2c) mod 2 = 0)
fun dd_stamp_even_d2var (d2v: d2var): bool = ($STMP.stamp_get_int (d2var_get_stamp d2v) mod 2 = 0)

implement
funlab_tmparg_match (fl0, t2mas) = ans where {
  val ans = ($STMP.stamp_get_int (funlab_get_stamp fl0) mod 3 <> 1)
  val () = (dd_ps "  dbl funlab_tmparg_match "; dd_funlab fl0; dd_ps " -> "; dd_bool ans; dd_nl ())
}

implement
hiimpdec_tmpcst_match (imp, d2c, t2mas, knd) = ans where {
  val ans = (
    if eq_d2cst_d2cst (imp_cst imp, d2c) then K_tmpcstmat_some (imp, K_tmpsub_nil (), knd) else K_tmpcstmat_none ()
  ) : tmpcstmat
  val () = (dd_ps "  dbl hiimpdec_tmpcst_match "; dd_d2cst (imp_cst imp); dd_ps ","; dd_d2cst d2c; dd_ps ","; dd_int knd; dd_ps " -> "; dd_tmpcstmat ans; dd_nl ())
}

implement
hiimpdec2_tmpcst_match (imp2, d2c, t2mas, knd) = ans where {
  val imp = imp2_imp imp2
  val ans = (
    if eq_d2cst_d2cst (imp_cst imp, d2c) then K_tmpcstmat_some (imp, K_tmpsub_nil (), knd+10) else K_tmpcstmat_none ()
  ) : tmpcstmat
  val () = (dd_ps "  dbl hiimpdec2_tmpcst_match "; dd_d2cst (imp_cst imp); dd_ps ","; dd_d2cst d2c; dd_ps ","; dd_int knd; dd_ps " arg="; fprint_s2explstlst (dd_out, imp2_arg imp2); dd_ps " -> "; dd_tmpcstmat ans; dd_nl ())
}

implement
hiimpdeclst_tmpcst_match (imps, d2c, t2mas, knd) = ans where {
  val ans = hiimpdeclst_find_match (imps, d2c, knd)
  val () = (dd_ps "  dbl hiimpdeclst_tmpcst_match "; dd_d2cst d2c; dd_ps ","; dd_int knd; dd_ps " -> "; dd_tmpcstmat ans; dd_nl ())
}

implement
tmpcstmat_tmpcst_match (mat, d2c, t2mas) = ans where {
  val ans = (
    if is_tmpcstmat_none mat then K_tmpcstmat_none ()
    else if dd_stamp_even_d2cst d2c then mat else K_tmpcstmat_none ()
  ) : tmpcstmat
  val () = (dd_ps "  dbl tmpcstmat_tmpcst_match "; dd_d2cst d2c; dd_ps " -> "; dd_tmpcstmat ans; dd_nl ())
}

implement
hifundec_tmpvar_match (hfd, d2v, t2mas) = ans where {
  val ans = (
    if eq_d2var_d2var (hfd_var hfd, d2v) then K_tmpvarmat_some (hfd, K_tmpsub_nil (), 0) else K_tmpvarmat_none ()
  ) : tmpvarmat
  val () = (dd_ps "  dbl hifundec_tmpvar_match "; dd_d2var (hfd_var hfd); dd_ps ","; dd_d2var d2v; dd_ps " -> "; dd_tmpvarmat ans; dd_nl ())
}

implement
hifundec2_tmpvar_match (hfd2, d2v, t2mas) = ans where {
  val hfd = hfd2_hfd hfd2
  val ans = (
    if eq_d2var_d2var (hfd_var hfd, d2v) then K_tmpvarmat_some (hfd, K_tmpsub_nil (), 2) else K_tmpvarmat_none ()
  ) : tmpvarmat
  val () = (dd_ps "  dbl hifundec2_tmpvar_match "; dd_d2var (hfd_var hfd); dd_ps ","; dd_d2var d2v; dd_ps " -> "; dd_tmpvarmat ans; dd_nl ())
}

implement
hifundecopt2tmpvarmat (opt, t2mas) = ans where {
  val ans = (
    case+ opt of
    | ~Some_vt (hfd) => K_tmpvarmat_some (hfd, K_tmpsub_nil (), 1)
    | ~None_vt () => K_tmpvarmat_none ()
  ) : tmpvarmat
  val () = (dd_ps "  dbl hifundecopt2tmpvarmat -> "; dd_tmpvarmat ans; dd_nl ())
}

implement
tmpvarmat_tmpvar_match (mat, d2v, t2mas) = ans where {
  val ans = (
    if is_tmpvarmat_none mat then K_tmpvarmat_none ()
    else if dd_stamp_even_d2var d2v then mat else K_tmpvarmat_none ()
  ) : tmpvarmat
  val () = (dd_ps "  dbl tmpvarmat_tmpvar_match "; dd_d2var d2v; dd_ps " -> "; dd_tmpvarmat ans; dd_nl ())
}


(* ****** ****** *)
//
// the stubs of the functions of trans2_env / trans3_env that the linked static modules (staexp2_solve, stacst2, util2) call
// (the C1 modules do not reach them)
//
implement the_s2expenv_pervasive_find (id) = Some_vt (K_perv_itm (id))
implement s2exp_hnfize_flag_svar (s2e0, s2v, flag) = s2e0
implement s2var_occurcheck_s2exp (s2v0, s2e) = false
implement trans3_env_add_proplst_vt (loc, s2ps) = list_vt_free (s2ps)
implement trans3_env_add_eqeq (loc, e1, e2) = ()
implement trans3_env_hypadd_prop (loc, e) = ()
implement trans3_env_hypadd_bind (loc, v, f) = ()
implement trans3_env_hypadd_eqeq (loc, f1, f2) = ()
implement s2exp_exi_instantiate_all (s2e0, locarg, err) = @(s2e0, list_vt_nil ())
implement s2exp_uni_instantiate_all (s2e0, locarg, err) = @(s2e0, list_vt_nil ())
implement s2hnf_absuni_and_add (loc, s2f) = s2hnf2exp (s2f)
implement s2hnf_opnexi_and_add (loc, s2f) = s2hnf2exp (s2f)
//
implement fprint_tmprimval (out, x) = fprint_string (out, "tmprimval(...)")

(* ****** ****** *)
//
// the doubles of hidexp_ccomp, hidexp_ccompv, hidexp_ccomp_ret, hiclaulst_ccomp, hidexp_ccomp_funlab_arg_body
// (pats_ccomp_dynexp.dats, _claulst.dats, groups C2/C3 of the port): a small compiler of the erased expressions that
// calls the functions under test (caseof, looping, trywith, lazyeval) for the node kinds they implement and records
// the state of the environment in the comments of the instructions
//
fun dbl_comment (env: !ccompenv, res: !instrseq, loc: location, what: string): void = let
  val lev = ccompenv_get_tmplevel (env)
  val rec_ = ccompenv_get_tmprecdepth (env)
  val tlc = $GLOB.the_CCOMPATS_tlcalopt_get ()
  val lvl = the_d2varlev_get ()
  val () = fprint_string (dd_out, "  dbl "); val () = fprint_string (dd_out, what)
  val () = (fprint_string (dd_out, " lev="); fprint_int (dd_out, lev); fprint_string (dd_out, " rec="); fprint_int (dd_out, rec_))
  val () = (fprint_string (dd_out, " tlc="); fprint_int (dd_out, tlc); fprint_string (dd_out, " d2lev="); fprint_int (dd_out, lvl); fprint_newline (dd_out))
  val str = cc1_str4 (what, lev, rec_, tlc)
in
  instrseq_add (res, instr_comment (loc, str))
end

implement
hidexp_ccompv (env, res, hde) = hidexp_ccomp (env, res, hde)

implement
hidexp_ccomp (env, res, hde) = let
  val loc = hde_loc hde
  val hse = hde_type hde
  val tag = hde_tag hde
in
  if tag = 0 then let
    val i = hde_int hde
    val () = dbl_comment (env, res, loc, "int")
    val pmv = primval_int (loc, hse, i)
    val () = if i mod 2 = 1 then ccompenv_add_vbindmapall (env, dbl_dv_get (i mod 8), pmv)
  in
    pmv
  end else if tag = 1 then let
    val d2v = hde_var hde
    val () = dbl_comment (env, res, loc, "var")
    val opt = ccompenv_find_vbindmapall (env, d2v)
  in
    case+ opt of
    | ~Some_vt (pmv) => pmv
    | ~None_vt () => primval_int (loc, hse, ~1)
  end else if tag = 3 then hidexp_ccomp_loop (env, res, hde)
  else if tag = 4 then hidexp_ccomp_loopexn (env, res, hde)
  else if tag >= 2 && tag <= 8 then let
    val tmp = tmpvar_make (loc, hse)
    val () = hidexp_ccomp_ret (env, res, tmp, hde)
  in
    primval_make_tmp (loc, tmp)
  end else primval_empty (loc, hse)
end

implement
hidexp_ccomp_ret (env, res, tmpret, hde) = let
  val loc = hde_loc hde
  val tag = hde_tag hde
in
  if tag = 2 then hidexp_ccomp_ret_case (env, res, tmpret, hde)
  else if tag = 5 then hidexp_ccomp_ret_trywith (env, res, tmpret, hde)
  else if tag = 6 then hidexp_ccomp_ret_delay (env, res, tmpret, hde)
  else if tag = 7 then hidexp_ccomp_ret_ldelay (env, res, tmpret, hde)
  else if tag = 8 then hidexp_ccomp_ret_lazyeval (env, res, tmpret, hde)
  else let
    val pmv = hidexp_ccomp (env, res, hde)
  in
    instrseq_add (res, instr_move_val (loc, tmpret, pmv))
  end
end

fun
dbl_clauses (env: !ccompenv, lvl0: int, npmv: int, fk: int, hicls: hiclaulst, tmpret: tmpvar, i: int, n: int): ibranchlst =
  if i >= n then LN_ibranchlst () else let
    val cl = hicls_nth (hicls, i)
    val body = hicl_body cl
    val loc = hde_loc body
    val res = instrseq_make_nil ()
    val () = dbl_comment (env, res, loc, "clause")
    val () = (fprint_string (dd_out, "  dbl clause "); fprint_int (dd_out, i); fprint_string (dd_out, " lvl0="); fprint_int (dd_out, lvl0)
      ; fprint_string (dd_out, " npmv="); fprint_int (dd_out, npmv); fprint_string (dd_out, " fail="); fprint_int (dd_out, fk); fprint_newline (dd_out))
    val () = hidexp_ccomp_ret (env, res, tmpret, body)
    val ib = ibranch_make (loc, instrseq_get_free res)
    val ibs = dbl_clauses (env, lvl0, npmv, fk, hicls, tmpret, i+1, n)
  in
    LC_ibranchlst (ib, ibs)
  end

implement
hiclaulst_ccomp (env, lvl0, pmvs, hicls, tmpret, fail) =
  dbl_clauses (env, lvl0, len_primvalist pmvs, pk_kind fail, hicls, tmpret, 0, len_hicls hicls)

implement
hidexp_ccomp_funlab_arg_body (env, flab, imparg, tmparg, prolog, loc_fun, hips_arg, hde_body) = let
  val res = instrseq_make_nil ()
  val () = instrseq_add_instrlst (res, prolog)
  val tlc = ccompenv_find_tailcalenv (env, flab)
  val () = (fprint_string (dd_out, "  dbl funlab_arg_body "); dd_funlab flab; fprint_string (dd_out, " nhips="); fprint_int (dd_out, len_hipatlst hips_arg)
    ; fprint_string (dd_out, " tailcal="); fprint_int (dd_out, tlc); fprint_newline (dd_out))
  val () = dbl_comment (env, res, loc_fun, "funbody")
  val tmpret = tmpvar_make_ret (loc_fun, funlab_get_type_res flab)
  val () = hidexp_ccomp_ret (env, res, tmpret, hde_body)
  val inss = instrseq_get_free res
in
  funent_make (loc_fun, flab, imparg, tmparg, ON_tmpsubopt (), tmpret, LN_funlablst (), LN_d2envlst (), mk_vbmap_nil (), inss, LN_tmpvarlst ())
end
