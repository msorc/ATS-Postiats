(* ATS1: wrappers of the templates and the externs (after the generated dumpers) *)

fun t_svs_nil (): s2varord = $UT.lstord_nil {s2var} ()
fun t_svs_of (v: s2var): s2varord = $UT.lstord_sing (v)
fun t_dvs_nil (): d2varord = $UT.lstord_nil {d2var} ()
fun t_dvs_of (v: d2var): d2varord = $UT.lstord_sing (v)
fun t_p2at_svs (p: p2at): s2varord = p.p2at_svs
fun t_p2at_dvs (p: p2at): d2varord = p.p2at_dvs
fun t_p2at_type (p: p2at): s2expopt = p.p2at_type
//
fun t_dcmap_nil (): d2cstmap (s2exp) = d2cstmap_nil {s2exp} ()
fun t_dcmap_ins (m: &d2cstmap (s2exp), k: d2cst, e: s2exp): bool = d2cstmap_insert {s2exp} (m, k, e)
fun t_dcmap_find (m: d2cstmap (s2exp), k: d2cst): Option_vt (s2exp) = d2cstmap_search {s2exp} (m, k)
//
fun t_dvmap_nil (): d2varmap (s2exp) = d2varmap_nil {s2exp} ()
fun t_dvmap_ins (m: &d2varmap (s2exp), k: d2var, e: s2exp): bool = d2varmap_insert {s2exp} (m, k, e)
fun t_dvmap_find (m: d2varmap (s2exp), k: d2var): Option_vt (s2exp) = d2varmap_search {s2exp} (m, k)
fun t_dvmap_list (m: d2varmap (s2exp)): List0_vt (@(d2var, s2exp)) = d2varmap_listize {s2exp} (m)
//
fun t_dvmapvt_nil (): d2varmap_vt (s2exp) = d2varmap_vt_nil {s2exp} ()
fun t_dvmapvt_free (m: d2varmap_vt (s2exp)): void = d2varmap_vt_free {s2exp} (m)
fun t_dvmapvt_ins (m: &d2varmap_vt (s2exp), k: d2var, e: s2exp): bool = d2varmap_vt_insert {s2exp} (m, k, e)
fun t_dvmapvt_rem (m: &d2varmap_vt (s2exp), k: d2var): bool = d2varmap_vt_remove {s2exp} (m, k)
fun t_dvmapvt_find (m: !d2varmap_vt (s2exp), k: d2var): Option_vt (s2exp) = d2varmap_vt_search {s2exp} (m, k)
fun t_dvmapvt_list (m: !d2varmap_vt (s2exp)): List0_vt (@(d2var, s2exp)) = d2varmap_vt_listize {s2exp} (m)
//
fun t_dvmaplst_nil (): d2varmaplst_vt (s2exp) = d2varmaplst_vt_nil {s2exp} ()
fun t_dvmaplst_free (m: d2varmaplst_vt (s2exp)): void = d2varmaplst_vt_free {s2exp} (m)
fun t_dvmaplst_ins (m: &d2varmaplst_vt (s2exp), k: d2var, e: s2exp): bool = d2varmaplst_vt_insert {s2exp} (m, k, e)
fun t_dvmaplst_rem (m: &d2varmaplst_vt (s2exp), k: d2var): bool = d2varmaplst_vt_remove {s2exp} (m, k)
fun t_dvmaplst_find (m: !d2varmaplst_vt (s2exp), k: d2var): Option_vt (s2exp) = d2varmaplst_vt_search {s2exp} (m, k)
//
fun t_mapgen (d2cs: d2eclist): void = let
  val (s2cs, s2vs, s2Vs, d2cons, d2csts, d2vars) = d2eclist_mapgen_all (d2cs)
in
  dd_ps "mapgen:"; dd_listvt_s2cst (s2cstset_vt_listize_free s2cs);
  dd_ps ";"; dd_listvt_s2var (s2varset_vt_listize_free s2vs);
  dd_ps ";"; dd_listvt_s2Var (s2Varset_vt_listize_free s2Vs);
  dd_ps ";"; dd_listvt_d2con (d2conset_vt_listize_free d2cons);
  dd_ps ";"; dd_listvt_d2cst (d2cstset_vt_listize_free d2csts);
  dd_ps ";"; dd_listvt_d2var (d2varset_vt_listize_free d2vars); dd_nl ()
end
//
fun t_p1ats (n: int): p1atlst = if n <= 0 then list_nil () else list_cons (p1at_any (mkloc (0)), t_p1ats (n-1))
fun t_d1base (k: int): d1exp = d1exp_int (mkloc (k), k)
fun t_d1lam (n: int, body: d1exp): d1exp = d1exp_lam_dyn (mkloc (1), 0, p1at_list (mkloc (2), ~1, t_p1ats (n)), body)
fun t_d1lam1 (body: d1exp): d1exp = d1exp_lam_dyn (mkloc (1), 0, p1at_any (mkloc (2)), body)
fun t_d1met (body: d1exp): d1exp = d1exp_lam_met (mkloc (1), mkloc (2), list_nil (), body)
fun t_d1sta_ana (body: d1exp): d1exp = d1exp_lam_sta_ana (mkloc (1), mkloc (2), S1VARARGone (mkloc (3)), body)
fun t_d1sta_syn (body: d1exp): d1exp = d1exp_lam_sta_syn (mkloc (1), mkloc (2), list_nil (), body)
//
// the tables of the test doubles of trans2_env and trans3_env (implemented by the driver, s2env1.hats)
//
extern fun t_penv_clear (): void = "s2t_penv_clear"
extern fun t_penv_add (id: symbol, itm: s2itm): void = "s2t_penv_add"
extern fun t_bind_clear (): void = "s2t_bind_clear"
extern fun t_bind_add (v: s2var, e: s2exp): void = "s2t_bind_add"
