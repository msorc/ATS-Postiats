(* ATS1: the language specific wrappers of the emit test (see ca_hand2.hats) *)
(* ****** ****** *)
%{^
extern ats_char_type ca_chr (ats_int_type) ;
extern ats_ptr_type ca_str (ats_int_type) ;
extern ats_double_type ca_dbl (ats_int_type) ;
extern ats_int_type ca_getexit (void) ;
%}
extern fun H_chr (i: int): char = "ca_chr"
extern fun H_str (k: int): string = "ca_str"
extern fun H_dbl (k: int): double = "ca_dbl"
extern fun H_getexit (): int = "ca_getexit"
//
// the C functions of pats_ccomp_tmpvar.dats / pats_ccomp_funent.dats that the ATS2 sats declares with their C names
extern fun tmpvar_set_type (tmp: tmpvar, hse: hisexp): void = "patsopt_tmpvar_set_type"
extern fun tmpvar_set_ref (tmp: tmpvar, knd: int): void = "patsopt_tmpvar_set_ref"
extern fun tmpvar_set_ret (tmp: tmpvar, ret: int): void = "patsopt_tmpvar_set_ret"
extern fun tmpvar_set_topknd (tmp: tmpvar, knd: int): void = "patsopt_tmpvar_set_topknd"
extern fun tmpvar_set_origin (tmp: tmpvar, opt: tmpvaropt): void = "patsopt_tmpvar_set_origin"
extern fun tmpvar_set_suffix (tmp: tmpvar, sfx: int): void = "patsopt_tmpvar_set_suffix"
extern fun funent_set_flablst_fin (fent: funent, opt: Option (funlablst)): void = "patsopt_funent_set_flablst_fin"
extern fun funent_set_d2envlst_fin (fent: funent, opt: Option (d2envlst)): void = "patsopt_funent_set_d2envlst_fin"
//
fun H_vbmap0 (): vbindmap = d2varmap_nil {primval} ()
fun H_vbmap1 (d2v: d2var, pmv: primval): vbindmap = let
  var m: vbindmap = d2varmap_nil {primval} ()
  val _ = d2varmap_insert {primval} (m, d2v, pmv)
in m end
fun H_vbmap2 (d2v1: d2var, pmv1: primval, d2v2: d2var, pmv2: primval): vbindmap = let
  var m: vbindmap = d2varmap_nil {primval} ()
  val _ = d2varmap_insert {primval} (m, d2v1, pmv1)
  val _ = d2varmap_insert {primval} (m, d2v2, pmv2)
in m end
//
fun H_filenv (fil: filename, d2cs: d2eclist): filenv = $UN.cast{filenv} (ref<d2eclist> (d2cs))
//
fun H_hse_tyclo (flab: funlab): hisexp = hisexp_tyclo ($UN.cast{hisexp_funlab_type} (flab))
