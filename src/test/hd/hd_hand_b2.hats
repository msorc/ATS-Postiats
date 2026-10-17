(* ATS2: the language specific wrappers of the erased-tree / typerase test (after the generated dumpers; see hd_gen.py) *)
(* ****** ****** *)
//
// the cells (Ptr1) that the mutable parts of the records are (hifundec_getref_hideclopt, ..) and of the doubles of filenv
//
fun t_pget_hideclopt (p: Ptr1): hideclopt = $UN.ptr0_get<hideclopt> (p)
fun t_pset_hideclopt (p: Ptr1, x: hideclopt): void = $UN.ptr0_set<hideclopt> (p, x)
fun t_pget_hifunlabopt (p: Ptr1): hifunlabopt = $UN.ptr0_get<hifunlabopt> (p)
fun t_pset_hifunlabopt (p: Ptr1, x: hifunlabopt): void = $UN.ptr0_set<hifunlabopt> (p, x)
fun t_pget_hiinstrlstopt (p: Ptr1): hiinstrlstopt = $UN.ptr0_get<hiinstrlstopt> (p)
fun t_pset_hiinstrlstopt (p: Ptr1, x: hiinstrlstopt): void = $UN.ptr0_set<hiinstrlstopt> (p, x)
fun t_pget_d3eclistopt (p: Ptr1): d3eclistopt = $UN.ptr0_get<d3eclistopt> (p)
fun t_pget_tcmapopt (p: Ptr1): tmpcstimpmapopt = $UN.ptr0_get<tmpcstimpmapopt> (p)
fun t_pget_tvmapopt (p: Ptr1): tmpvardecmapopt = $UN.ptr0_get<tmpvardecmapopt> (p)
fun t_pset_tcmapopt (p: Ptr1, x: tmpcstimpmapopt): void = $UN.ptr0_set<tmpcstimpmapopt> (p, x)
fun t_pset_tvmapopt (p: Ptr1, x: tmpvardecmapopt): void = $UN.ptr0_set<tmpvardecmapopt> (p, x)
fun t_fenv_ref_tc (fenv: filenv): Ptr1 = filenv_getref_tmpcstimpmap (fenv)
fun t_fenv_ref_tv (fenv: filenv): Ptr1 = filenv_getref_tmpvardecmap (fenv)
fun t_fenv_set_d3cs (fenv: filenv, d3cs: d3eclist): void =
  $UN.ptr0_set<d3eclistopt> (filenv_getref_d3eclistopt (fenv), gopt_some<d3eclist> (d3cs))
//
// the maps of the instances of the templates
//
fun t_tcmap_nil (): tmpcstimpmap = d2cstmap_nil<hiimpdeclst> ()
fun t_tcmap_find (m: tmpcstimpmap, c: d2cst): hiimpdeclst = tmpcstimpmap_find (m, c)
fun t_tcmap_ins (m: &tmpcstimpmap, x: hiimpdec): void = tmpcstimpmap_insert (m, x)
fun t_tvmap_nil (): tmpvardecmap = d2varmap_nil<hifundec> ()
fun t_tvmap_find (m: tmpvardecmap, v: d2var): Option_vt (hifundec) = tmpvardecmap_find (m, v)
fun t_tvmap_ins (m: &tmpvardecmap, x: hifundec): void = tmpvardecmap_insert (m, x)
fun t_tvmap_inss (m: &tmpvardecmap, xs: hifundeclst): void = tmpvardecmap_inserts (m, xs)
fun t_tcmapopt_some (m: tmpcstimpmap): tmpcstimpmapopt = gopt_some<tmpcstimpmap> (m)
fun t_tvmapopt_some (m: tmpvardecmap): tmpvardecmapopt = gopt_some<tmpvardecmap> (m)
fun t_tcmapopt_get (o: tmpcstimpmapopt): Option_vt (tmpcstimpmap) = (
  case+ gopt_view (o) of ~GOsome (m) => Some_vt (m) | ~GOnone () => None_vt ()
)
fun t_tvmapopt_get (o: tmpvardecmapopt): Option_vt (tmpvardecmap) = (
  case+ gopt_view (o) of ~GOsome (m) => Some_vt (m) | ~GOnone () => None_vt ()
)
fun dd_tcmapopt (o: tmpcstimpmapopt): void = (
  case+ gopt_view (o) of ~GOsome (_) => dd_ps "Some(tcmap)" | ~GOnone () => dd_ps "None"
)
fun dd_tvmapopt (o: tmpvardecmapopt): void = (
  case+ gopt_view (o) of ~GOsome (_) => dd_ps "Some(tvmap)" | ~GOnone () => dd_ps "None"
)
//
// the result of an erasure that may raise PATSOPT_TRANS4_EXN
//
fun t_errck (d3cs: d3eclist): hideclist = let
  val r = (
    try Some_vt (d3eclist_tyer_errck (d3cs)) with | ~$ERR.PATSOPT_TRANS4_EXN () => None_vt ()
  ) : Option_vt (hideclist)
in
  case+ r of ~Some_vt (x) => x | ~None_vt () => (dd_ps "EXN PATSOPT_TRANS4_EXN\n"; glist_nil ())
end
//
fun t_add4_p (p: p3at): void = the_trans4errlst_add (trans4err_T4E_p3at_tyer_isprf (p))
fun t_add4_e (e: d3exp): void = the_trans4errlst_add (trans4err_T4E_d3exp_tyer_isprf (e))
fun t_fin4 (): void = (
  try the_trans4errlst_finalize () with | ~$ERR.PATSOPT_TRANS4_EXN () => dd_ps "EXN PATSOPT_TRANS4_EXN\n"
)
fun t_pcst (name: string): s2cst = let
  val opt = the_s2expenv_pervasive_find ($SYM.symbol_make_string (name))
in
  case+ opt of
  | ~Some_vt (itm) => (
    case+ s2itm_view (itm) of
    | ~S2ITMcst (cs) => glist_head<s2cst> (cs)
    | v => ($ERR.abort<s2cst> ()) where { val () = s2itm_view_free (v) }
    )
  | ~None_vt () => $ERR.abort<s2cst> ()
end
//
// the doubles of the functions of trans2_env / trans3_env that typerase calls (a table of the cells of the files, hd_stub.c)
//
%{^
extern void *hd_fenv_cell (void*, int) ;
%}
extern fun hd_fenv_cell (fenv: filenv, k: int): Ptr1 = "mac#hd_fenv_cell"
//
fun t_hislst_len (xs: hideclist): int = glist_length (xs)
