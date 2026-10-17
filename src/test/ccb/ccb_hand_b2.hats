(* ATS2: the language specific part of the ccomp group B test that comes after the generated dumpers (see ccb_gen.py) *)
(* ****** ****** *)

fun ccb_nil_vbindmap (): vbindmap = d2varmap_nil<primval> ()
fun ccb_ins_vbindmap (m: &vbindmap, d2v: d2var, pmv: primval): void = let
  val _ = d2varmap_insert<primval> (m, d2v, pmv)
in
end

(* the funlabs of the scenarios: made by funlab_make (the stamp is a funlab stamp) *)
fun ccb_mkfunlab (k: int, level: int, hse: hisexp): funlab = let
  val stamp = $STMP.funlab_stamp_make ()
  val name = $STMP.tostring_prefix_stamp ("fl", stamp)
in
  funlab_make (name, level, hse, None_vt (), gopt_none (), gopt_none (), glist_nil (), stamp)
end

fun ccb_has_origin (fl: funlab): bool = gopt_is_some (funlab_get_origin fl)
fun ccb_get_origin (fl: funlab): funlab = gopt_unsome<funlab> (funlab_get_origin fl)


fun ccb_hitl2 (a: hitype, b: hitype): hitypelst = glist_cons<hitype> (a, glist_cons<hitype> (b, glist_nil ()))

fun ccb_tyclo (fl: funlab): hisexp = hisexp_tyclo ($UN.cast{hisexp_funlab_type} (fl))

(* ---- helpers of the mock environment (ccb_mock.hats) that differ between the languages *)
fun ccb_pck_is_free (pck: pckind): bool = (case+ pck of PCKfree () => true | _ => false)
fun ccb_tc_isnone (mat: tmpcstmat): bool = tmpcstmat_is_TMPCSTMATnone (mat)
fun ccb_tv_isnone (mat: tmpvarmat): bool = tmpvarmat_is_TMPVARMATnone (mat)
fun ccb_stal_tc (fenv: filenv, d2c0: d2cst, t2mas: t2mpmarglst): tmpcstmat = let
  val opt = filenv_get_tmpcstimpmapopt (fenv)
in
  if gopt_is_some (opt) then let
    val map = gopt_unsome<tmpcstimpmap> (opt)
    val implst = tmpcstimpmap_find (map, d2c0)
  in
    hiimpdeclst_tmpcst_match (implst, d2c0, t2mas, 1(*staload*))
  end else tmpcstmat_TMPCSTMATnone ()
end
fun ccb_stal_tv (fenv: filenv, d2v0: d2var, t2mas: t2mpmarglst): tmpvarmat = let
  val opt = filenv_get_tmpvardecmapopt (fenv)
  val map = gopt_unsome<tmpvardecmap> (opt)
  val hfdopt = tmpvardecmap_find (map, d2v0)
in
  hifundecopt2tmpvarmat (hfdopt, t2mas)
end
fun ccb_d2vs_add (set: d2envset_vt, d2vs: d2varlst): d2envset_vt =
  if glist_is_cons (d2vs) then
    ccb_d2vs_add (d2envset_vt_add (set, d2var2env (glist_head<d2var> (d2vs))), glist_tail<d2var> (d2vs))
  else set
fun ccb_vbmap_has (vbmap: vbindmap, d2v: d2var): bool = let
  val opt = d2varmap_search<primval> (vbmap, d2v)
in
  case+ opt of ~Some_vt _ => true | ~None_vt () => false
end
fun ccb_auxenv (env: !ccompenv, vbmap: vbindmap, d2es: d2envlst): void =
  if glist_is_cons (d2es) then let
    val d2e = glist_head<d2env> (d2es)
    val d2es = glist_tail<d2env> (d2es)
    val () = if ccb_vbmap_has (vbmap, d2env_get_var (d2e)) then () else ccompenv_add_dvarsetenv_env (env, d2e)
  in
    ccb_auxenv (env, vbmap, d2es)
  end else ()
fun ccb_funent_of (fl: funlab): funent = gopt_unsome<funent> (funlab_get_funent fl)
fun ccb_imp_tmparg (imp: hiimpdec): s2explstlst = imp.hiimpdec_tmparg ()
fun ccb_is_nil_s2qualst (xs: s2qualst): bool = glist_is_nil (xs)
fun ccb_add_fundec2s (env: !ccompenv, tsub: tmpsub, hfds: hifundeclst): void =
  if glist_is_cons (hfds) then let
    val () = ccompenv_add_fundec2 (env, K_hifundec2 (glist_head<hifundec> (hfds), tsub))
  in
    ccb_add_fundec2s (env, tsub, glist_tail<hifundec> (hfds))
  end else ()
fun ccb_d2vs_nonempty (d2vs: d2varlst): bool = glist_is_cons (d2vs)

fun ccb_mkfunlab_t2 (level: int, hse: hisexp, t2mas: t2mpmarglst, d2c: d2cst): funlab = let
  val stamp = $STMP.funlab_stamp_make ()
  val name = $STMP.tostring_prefix_stamp ("flt", stamp)
in
  funlab_make (name, level, hse, None_vt (), gopt_some<d2cst> (d2c), gopt_none (), t2mas, stamp)
end
fun ccb_mkfunlab_v (level: int, hse: hisexp, t2mas: t2mpmarglst, d2v: d2var): funlab = let
  val stamp = $STMP.funlab_stamp_make ()
  val name = $STMP.tostring_prefix_stamp ("flv", stamp)
in
  funlab_make (name, level, hse, None_vt (), gopt_none (), gopt_some<d2var> (d2v), t2mas, stamp)
end

(* the funlab and the funent that the mock of hiimpdec_ccomp_if / hifundeclst_ccomp make (a body with two temporaries) *)
fun ccb_mkfun_body (loc: location, fl: funlab, imparg: s2varlst, tmparg: s2explstlst): void = let
  val hse = hisexp_funptr
  val t1 = tmpvar_make (loc, hse)
  val tmpret = tmpvar_make_ret (loc, hse)
  val body = LC_instrlst (instr_move_val (loc, t1, primval_int (loc, hse, 1)),
             LC_instrlst (instr_move_val (loc, tmpret, primval_tmp (loc, hse, t1)), LN_instrlst ()))
  val fent = funent_make (loc, fl, imparg, tmparg, gopt_none (), tmpret, LN_funlablst (), LN_d2envlst (), ccb_nil_vbindmap (), body,
                          LC_tmpvarlst (t1, LC_tmpvarlst (tmpret, LN_tmpvarlst ())))
in
  funlab_set_funent (fl, gopt_some<funent> (fent))
end
fun ccb_imp_mkfun (imp: hiimpdec): void =
  if gopt_is_some (hiimpdec_get_funlabopt imp) then () else let
    val loc = imp.hiimpdec_loc ()
    val fl = ccb_mkfunlab_t2 (0, hisexp_funptr, glist_nil (), imp.hiimpdec_cst ())
    val () = ccb_mkfun_body (loc, fl, imp.hiimpdec_imparg (), imp.hiimpdec_tmparg ())
  in
    hiimpdec_set_funlabopt (imp, gopt_some<funlab> (fl))
  end
fun ccb_hfds_mkfun (hfds: hifundeclst): void =
  if glist_is_cons (hfds) then let
    val hfd = glist_head<hifundec> (hfds)
    val () = if gopt_is_some (hifundec_get_funlabopt hfd) then () else let
      val loc = hfd.hifundec_loc ()
      val fl = ccb_mkfunlab_v (0, hisexp_funptr, glist_nil (), hfd.hifundec_var ())
      val () = ccb_mkfun_body (loc, fl, hfd.hifundec_imparg (), glist_nil ())
    in
      hifundec_set_funlabopt (hfd, gopt_some<funlab> (fl))
    end
  in
    ccb_hfds_mkfun (glist_tail<hifundec> (hfds))
  end else ()

fun ccb_tmpvar_set_ref (t: tmpvar, k: int): void = tmpvar_set_ref (t, k)
fun ccb_tmpvar_set_ret (t: tmpvar, k: int): void = tmpvar_set_ret (t, k)
fun ccb_tmpvar_set_topknd (t: tmpvar, k: int): void = tmpvar_set_topknd (t, k)

fun ccb_pd_extvar (loc: location, nm: string, inss: instrlst): primdec = primdec_extvar (loc, nm, inss)
fun ccb_pd_valdecs (loc: location, knd: valkind, hvds: hivaldeclst, inss: instrlst): primdec = primdec_valdecs (loc, knd, hvds, inss)
fun ccb_pd_vardecs (loc: location, hvds: hivardeclst, inss: instrlst): primdec = primdec_vardecs (loc, hvds, inss)

fun ccb_len_primdeclst (xs: primdeclst): int = $UN.cast{int} (glist_length<primdec> (xs))
fun ccb_fprint_tmpvars (out: FILEref, xs: tmpvarlst): void =
  if glist_is_cons (xs) then (fprint_tmpvar (out, glist_head<tmpvar> (xs)); fprint_string (out, ";"); ccb_fprint_tmpvars (out, glist_tail<tmpvar> (xs))) else ()
fun ccb_ccomp0 (hids: hideclist): primdeclst =
  if glist_is_cons (hids) then let
    val hid = glist_head<hidecl> (hids)
    val loc = hid.hidecl_loc ()
    val hse = hisexp_int_t0ype ()
    val tmp = tmpvar_make (loc, hse)
    val pmd = primdec_extvar (loc, "mockdec", LC_instrlst (instr_move_val (loc, tmp, primval_int (loc, hse, 1)), LN_instrlst ()))
    val rest = ccb_ccomp0 (glist_tail<hidecl> (hids))
  in
    glist_cons<primdec> (pmd, rest)
  end else glist_nil ()

fun ccb_mainextdef (i: int): dcstextdef = dcstextdef_DCSTEXTDEFsome_ext ("mainats_main")

fun ccb_pd_valdecs_rec (loc: location, knd: valkind, hvds: hivaldeclst, inss: instrlst): primdec = primdec_valdecs_rec (loc, knd, hvds, inss)
