(* ATS1: the language specific wrappers of the erased-tree / typerase test (after the generated dumpers; see hd_gen.py) *)
(* ****** ****** *)
fun t_pget_hideclopt (p: Ptr1): hideclopt = $UN.ptrget<hideclopt> (p)
fun t_pset_hideclopt (p: Ptr1, x: hideclopt): void = $UN.ptrset<hideclopt> (p, x)
fun t_pget_hifunlabopt (p: Ptr1): hifunlabopt = $UN.ptrget<hifunlabopt> (p)
fun t_pset_hifunlabopt (p: Ptr1, x: hifunlabopt): void = $UN.ptrset<hifunlabopt> (p, x)
fun t_pget_hiinstrlstopt (p: Ptr1): hiinstrlstopt = $UN.ptrget<hiinstrlstopt> (p)
fun t_pset_hiinstrlstopt (p: Ptr1, x: hiinstrlstopt): void = $UN.ptrset<hiinstrlstopt> (p, x)
fun t_pget_d3eclistopt (p: Ptr1): d3eclistopt = $UN.ptrget<d3eclistopt> (p)
fun t_pget_tcmapopt (p: Ptr1): tmpcstimpmapopt = $UN.ptrget<tmpcstimpmapopt> (p)
fun t_pget_tvmapopt (p: Ptr1): tmpvardecmapopt = $UN.ptrget<tmpvardecmapopt> (p)
fun t_pset_tcmapopt (p: Ptr1, x: tmpcstimpmapopt): void = $UN.ptrset<tmpcstimpmapopt> (p, x)
fun t_pset_tvmapopt (p: Ptr1, x: tmpvardecmapopt): void = $UN.ptrset<tmpvardecmapopt> (p, x)
fun t_fenv_ref_tc (fenv: filenv): Ptr1 = $TRENV2.filenv_getref_tmpcstimpmap (fenv)
fun t_fenv_ref_tv (fenv: filenv): Ptr1 = $TRENV2.filenv_getref_tmpvardecmap (fenv)
fun t_fenv_set_d3cs (fenv: filenv, d3cs: d3eclist): void =
  $UN.ptrset<d3eclistopt> ($TRENV2.filenv_getref_d3eclistopt (fenv), Some (d3cs))
//
fun t_tcmap_nil (): tmpcstimpmap = d2cstmap_nil {hiimpdeclst} ()
fun t_tcmap_find (m: tmpcstimpmap, c: d2cst): hiimpdeclst = tmpcstimpmap_find (m, c)
fun t_tcmap_ins (m: &tmpcstimpmap, x: hiimpdec): void = tmpcstimpmap_insert (m, x)
fun t_tvmap_nil (): tmpvardecmap = d2varmap_nil {hifundec} ()
fun t_tvmap_find (m: tmpvardecmap, v: d2var): Option_vt (hifundec) = tmpvardecmap_find (m, v)
fun t_tvmap_ins (m: &tmpvardecmap, x: hifundec): void = tmpvardecmap_insert (m, x)
fun t_tvmap_inss (m: &tmpvardecmap, xs: hifundeclst): void = tmpvardecmap_inserts (m, xs)
fun t_tcmapopt_some (m: tmpcstimpmap): tmpcstimpmapopt = Some (m)
fun t_tvmapopt_some (m: tmpvardecmap): tmpvardecmapopt = Some (m)
fun t_tcmapopt_get (o: tmpcstimpmapopt): Option_vt (tmpcstimpmap) = (
  case+ o of Some (m) => Some_vt (m) | None () => None_vt ()
)
fun t_tvmapopt_get (o: tmpvardecmapopt): Option_vt (tmpvardecmap) = (
  case+ o of Some (m) => Some_vt (m) | None () => None_vt ()
)
fun dd_tcmapopt (o: tmpcstimpmapopt): void = (
  case+ o of Some (_) => dd_ps "Some(tcmap)" | None () => dd_ps "None"
)
fun dd_tvmapopt (o: tmpvardecmapopt): void = (
  case+ o of Some (_) => dd_ps "Some(tvmap)" | None () => dd_ps "None"
)
//
fun t_errck (d3cs: d3eclist): hideclist = let
  val r = (
    try Some (d3eclist_tyer_errck (d3cs)) with | ~($ERR.PATSOPT_TRANS4_EXN ()) => None ()
  ) : Option (hideclist)
in
  case+ r of Some (x) => x | None () => (dd_ps "EXN PATSOPT_TRANS4_EXN\n"; list_nil ())
end
//
//
fun t_add4_p (p: p3at): void = the_trans4errlst_add (T4E_p3at_tyer_isprf (p))
fun t_add4_e (e: d3exp): void = the_trans4errlst_add (T4E_d3exp_tyer_isprf (e))
fun t_fin4 (): void = (
  try the_trans4errlst_finalize () with | ~($ERR.PATSOPT_TRANS4_EXN ()) => dd_ps "EXN PATSOPT_TRANS4_EXN\n"
)
fun t_pcst (name: string): s2cst = let
  val opt = $TRENV2.the_s2expenv_pervasive_find ($SYM.symbol_make_string (name))
in
  case+ opt of
  | ~Some_vt (itm) => (
    case+ itm of
    | S2ITMcst (cs) => (case+ cs of list_cons (c, _) => c | list_nil () => $ERR.abort ())
    | _ => $ERR.abort ()
    )
  | ~None_vt () => $ERR.abort ()
end
extern fun hd_fenv_cell (fenv: filenv, k: int): Ptr1 = "hd_fenv_cell"
fun t_hislst_len (xs: hideclist): int = list_length (xs)
