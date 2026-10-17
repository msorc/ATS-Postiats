(* ATS2: the language specific wrappers of the ccomp test, before the generated dumpers (see cc_gen.py) *)
(* ****** ****** *)
%{^
extern int cc_lev_get (void) ;
extern void cc_lev_set (int) ;
%}
extern fun cc_lev_set (k: int): void = "mac#cc_lev_set"
extern fun cc_lev_get (): int = "mac#cc_lev_get"
fun t_lev_set (k: int): void = cc_lev_set (k)
//
fun mkdouble (k: int): double = g0int2float_int_double (k) * 0.25
fun dd_double (x: double): void = fprint_double (dd_out, x)
//
// the setters that ATS1 only has as C functions (declared in pats_ccomp.sats with the same C names here)
//
fun t_tv_set_type (t: tmpvar, h: hisexp): void = tmpvar_set_type (t, h)
fun t_tv_set_ref (t: tmpvar, k: int): void = tmpvar_set_ref (t, k)
fun t_tv_set_ret (t: tmpvar, k: int): void = tmpvar_set_ret (t, k)
fun t_tv_set_topknd (t: tmpvar, k: int): void = tmpvar_set_topknd (t, k)
fun t_tv_set_origin (t: tmpvar, o: tmpvaropt): void = tmpvar_set_origin (t, o)
fun t_tv_set_suffix (t: tmpvar, k: int): void = tmpvar_set_suffix (t, k)
fun t_fe_set_flablst_fin (f: funent, o: funlablstopt): void = funent_set_flablst_fin (f, o)
fun t_fe_set_d2envlst_fin (f: funent, o: d2envlstopt): void = funent_set_d2envlst_fin (f, o)
//
// the maps of the temporary variables (templates here, polymorphic functions in ATS1)
//
fun t_tvm_nil (): tmpvarmap_vt (tmpvar) = tmpvarmap_vt_nil<tmpvar> ()
fun t_tvm_free (m: tmpvarmap_vt (tmpvar)): void = tmpvarmap_vt_free<tmpvar> (m)
fun t_tvm_search (m: !tmpvarmap_vt (tmpvar), t: tmpvar): Option_vt (tmpvar) = tmpvarmap_vt_search<tmpvar> (m, t)
fun t_tvm_insert (m: &tmpvarmap_vt (tmpvar), t: tmpvar, x: tmpvar): bool = tmpvarmap_vt_insert<tmpvar> (m, t, x)
fun t_tvm_remove (m: &tmpvarmap_vt (tmpvar), t: tmpvar): bool = tmpvarmap_vt_remove<tmpvar> (m, t)
//
// the maps of the bindings of variables (vbindmap = d2varmap (primval))
//
fun t_vb0 (): vbindmap = d2varmap_nil<primval> ()
fun t_vb_ins (m: &vbindmap, v: d2var, x: primval): void = let
  val _ = d2varmap_insert<primval> (m, v, x)
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
// shallow dumps (a funlab holds its funent, which holds the funlab)
//
fun dd_funlabopt_shallow (x: funlabopt): void = (
  case+ gopt_view (x) of ~GOsome (y) => (dd_ps "Some("; fprint_funlab (dd_out, y); dd_ps ")") | ~GOnone () => dd_ps "None"
)
fun dd_funentopt_shallow (x: funentopt): void = (
  case+ gopt_view (x) of ~GOsome (y) => (dd_ps "Some("; fprint_funent (dd_out, y); dd_ps ")") | ~GOnone () => dd_ps "None"
)
//
// the places holders of hifundec / hiimpdec as the real types
//
fun t_hfd_get_funlabopt (x: hifundec): funlabopt = hifundec_get_funlabopt (x)
//
// the instrlst and the funlab of the hd test are placeholders: the cc test makes the real ones
//
fun dd_hfunlab (x: hfunlab): void = (dd_ps "hfunlab#"; dd_int ($UN.cast{int} ($UN.cast{lint} (x))))
//
// ATS1 gives the abstract type ccomp_instrlst_type (and the placeholder funlab) to some declarations of pats_ccomp.sats: the wrappers hide it
//
fun t_tv_set_tyclo (t: tmpvar, fl: funlab): void = tmpvar_set_tyclo (t, fl)
fun t_primdec_extvar (loc: location, name: string, inss: instrlst): primdec = primdec_extvar (loc, name, inss)
fun t_primdec_valdecs (loc: location, knd: valkind, hvds: hivaldeclst, inss: instrlst): primdec = primdec_valdecs (loc, knd, hvds, inss)
fun t_primdec_valdecs_rec (loc: location, knd: valkind, hvds: hivaldeclst, inss: instrlst): primdec = primdec_valdecs_rec (loc, knd, hvds, inss)
fun t_primdec_vardecs (loc: location, hvds: hivardeclst, inss: instrlst): primdec = primdec_vardecs (loc, hvds, inss)
fun t_chr (k: int): char = int2char0 (k)
