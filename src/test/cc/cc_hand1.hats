(* ATS1: the language specific wrappers of the ccomp test, before the generated dumpers (see cc_gen.py, cc_hand2.hats) *)
(* ****** ****** *)
extern fun cc_lev_set (k: int): void = "cc_lev_set"
fun t_lev_set (k: int): void = cc_lev_set (k)
//
fun mkdouble (k: int): double = double_of_int (k) * 0.25
fun dd_double (x: double): void = fprint_double (dd_out, x)
//
extern fun t_tv_set_type (t: tmpvar, h: hisexp): void = "patsopt_tmpvar_set_type"
extern fun t_tv_set_ref (t: tmpvar, k: int): void = "patsopt_tmpvar_set_ref"
extern fun t_tv_set_ret (t: tmpvar, k: int): void = "patsopt_tmpvar_set_ret"
extern fun t_tv_set_topknd (t: tmpvar, k: int): void = "patsopt_tmpvar_set_topknd"
extern fun t_tv_set_origin (t: tmpvar, o: tmpvaropt): void = "patsopt_tmpvar_set_origin"
extern fun t_tv_set_suffix (t: tmpvar, k: int): void = "patsopt_tmpvar_set_suffix"
extern fun t_fe_set_flablst_fin (f: funent, o: funlablstopt): void = "patsopt_funent_set_flablst_fin"
extern fun t_fe_set_d2envlst_fin (f: funent, o: d2envlstopt): void = "patsopt_funent_set_d2envlst_fin"
//
fun t_tvm_nil (): tmpvarmap_vt (tmpvar) = tmpvarmap_vt_nil {tmpvar} ()
fun t_tvm_free (m: tmpvarmap_vt (tmpvar)): void = tmpvarmap_vt_free {tmpvar} (m)
fun t_tvm_search (m: !tmpvarmap_vt (tmpvar), t: tmpvar): Option_vt (tmpvar) = tmpvarmap_vt_search {tmpvar} (m, t)
fun t_tvm_insert (m: &tmpvarmap_vt (tmpvar), t: tmpvar, x: tmpvar): bool = tmpvarmap_vt_insert {tmpvar} (m, t, x)
fun t_tvm_remove (m: &tmpvarmap_vt (tmpvar), t: tmpvar): bool = tmpvarmap_vt_remove {tmpvar} (m, t)
//
fun t_vb0 (): vbindmap = d2varmap_nil {primval} ()
fun t_vb_ins (m: &vbindmap, v: d2var, x: primval): void = let
  val _ = d2varmap_insert (m, v, x)
in
  ()
end
fun t_vb1 (v: d2var, x: primval): vbindmap = let
  var m = t_vb0 ()
  val () = t_vb_ins (m, v, x)
in
  m
end
fun t_vb2 (v1: d2var, x1: primval, v2: d2var, x2: primval): vbindmap = let
  var m = t_vb0 ()
  val () = t_vb_ins (m, v1, x1)
  val () = t_vb_ins (m, v2, x2)
in
  m
end
fun dd_vbindmap (m: vbindmap): void = fprint_vbindmap (dd_out, m)
//
fun dd_funlabopt_shallow (x: funlabopt): void = (
  case+ x of Some (y) => (dd_ps "Some("; fprint_funlab (dd_out, y); dd_ps ")") | None () => dd_ps "None"
)
fun dd_funentopt_shallow (x: funentopt): void = (
  case+ x of Some (y) => (dd_ps "Some("; fprint_funent (dd_out, y); dd_ps ")") | None () => dd_ps "None"
)
fun t_hfd_get_funlabopt (x: hifundec): funlabopt = hifundec_get_funlabopt (x)
//
fun dd_hfunlab (x: hfunlab): void = (dd_ps "hfunlab#"; dd_int ($UN.cast{int} ($UN.cast2lint (x))))
//
fun t_tv_set_tyclo (t: tmpvar, fl: funlab): void = tmpvar_set_tyclo (t, $UN.cast{hfunlab} (fl))
fun t_primdec_extvar (loc: location, name: string, inss: instrlst): primdec = primdec_extvar (loc, name, $UN.cast{ccomp_instrlst_type} (inss))
fun t_primdec_valdecs (loc: location, knd: valkind, hvds: hivaldeclst, inss: instrlst): primdec = primdec_valdecs (loc, knd, hvds, $UN.cast{ccomp_instrlst_type} (inss))
fun t_primdec_valdecs_rec (loc: location, knd: valkind, hvds: hivaldeclst, inss: instrlst): primdec = primdec_valdecs_rec (loc, knd, hvds, $UN.cast{ccomp_instrlst_type} (inss))
fun t_primdec_vardecs (loc: location, hvds: hivardeclst, inss: instrlst): primdec = primdec_vardecs (loc, hvds, $UN.cast{ccomp_instrlst_type} (inss))
fun t_chr (k: int): char = char_of_int (k)
