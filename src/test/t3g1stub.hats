(* ATS2 test doubles of the functions of the OTHER groups of the trans3 port (the ATS1 side of the test links the real ones), see t3g1_gen.py *)
(* ****** ****** *)
//
// Exact on the inputs that the scenarios use: the empty lists, the "rest" case of [d2exp_trdn] (= [d2exp_trup] then [d3exp_trdn], no
// [wthtype]), [D2Esing]/[D2Elist]/[D2Eshowtype]; every other input is a bug of the scenarios: the process stops.
//
(* ****** ****** *)
fun{a:vt0p} stub_stop (name: string): a = let
  val () = (prerr "t3g1stub: "; prerr name; prerr_newline ())
in
  $ERR.abort_interr<a> ()
end
//
implement p2atlst_syn_type (p2ts) =
  if glist_is_nil (p2ts) then glist_nil () else stub_stop<s2explst> ("p2atlst_syn_type")
implement p2atlst_trup_arg (npf, p2ts) =
  if glist_is_nil (p2ts) then glist_nil () else stub_stop<p3atlst> ("p2atlst_trup_arg")
implement d2eclist_tr (d2cs) =
  if glist_is_nil (d2cs) then glist_nil () else stub_stop<d3eclist> ("d2eclist_tr")
//
implement d3exp_fun_restore (fc, d3e_fun) =
  if $UN.cast{int} (fc) = $UN.cast{int} (FUNCLOfun ()) then d3e_fun else stub_stop<d3exp> ("d3exp_fun_restore")
implement d3explst_arg_restore (d3es, s2es, wths2es) = stub_stop<d3explst> ("d3explst_arg_restore")
//
implement d2exp_trdn (d2e0, s2e0) = let
  val s2f0 = s2exp2hnf (s2e0)
  val s2e0 = s2hnf2exp (s2f0)
  val loc0 = d2e0.d2exp_loc ()
in
//
case+ d2exp_node_view (d2e0.d2exp_node ()) of
| ~D2Esing (d2e) => d2exp_trdn (d2e, s2e0)
| ~D2Elist (npf, d2es) => d2exp_trdn (d2exp_tup_flt (loc0, npf, d2es), s2e0)
| ~D2Eshowtype (d2e) => let
    val d3e = d2exp_trdn (d2e, s2e0)
    val () = fshowtype_d3exp_dn (d3e)
  in d3e end
| v => let
    val special = (
      d2exp_node_is_D2Etop (d2e0.d2exp_node ()) || d2exp_node_is_D2Elet (d2e0.d2exp_node ()) || d2exp_node_is_D2Ewhere (d2e0.d2exp_node ())
      || d2exp_node_is_D2Eifhead (d2e0.d2exp_node ()) || d2exp_node_is_D2Esifhead (d2e0.d2exp_node ()) || d2exp_node_is_D2Eifcasehd (d2e0.d2exp_node ())
      || d2exp_node_is_D2Ecasehead (d2e0.d2exp_node ()) || d2exp_node_is_D2Escasehead (d2e0.d2exp_node ()) || d2exp_node_is_D2Etup (d2e0.d2exp_node ())
      || d2exp_node_is_D2Erec (d2e0.d2exp_node ()) || d2exp_node_is_D2Eseq (d2e0.d2exp_node ()) || d2exp_node_is_D2Eraise (d2e0.d2exp_node ())
      || d2exp_node_is_D2Eeffmask (d2e0.d2exp_node ()) || d2exp_node_is_D2Eexist (d2e0.d2exp_node ()) || d2exp_node_is_D2Elam_dyn (d2e0.d2exp_node ())
      || d2exp_node_is_D2Edelay (d2e0.d2exp_node ()) || d2exp_node_is_D2Eldelay (d2e0.d2exp_node ()) || d2exp_node_is_D2Etrywith (d2e0.d2exp_node ())
      || d2exp_node_is_D2Eapplst (d2e0.d2exp_node ()) && (
           case+ d2exp_node_view (d2e0.d2exp_node ()) of
           | ~D2Eapplst (f, _) => d2exp_node_is_D2Emac (f.d2exp_node ())
           | v2 => (d2exp_node_view_free (v2); false))
    )
    val () = d2exp_node_view_free (v)
  in
    if special then stub_stop<d3exp> ("d2exp_trdn: special case") else let
      val d3e0 = d2exp_trup (d2e0)
    in
      if s2exp_is_wthtype (s2e0) then stub_stop<d3exp> ("d2exp_trdn: wthtype") else d3exp_trdn (d3e0, s2e0)
    end
  end
//
end // end of [d2exp_trdn]
//
fun d2explst_trdn_elt_loop (d2es: d2explst, s2e: s2exp, res: List0_vt (d3exp)): d3explst =
  case+ glist_view (d2es) of
  | ~GLnil () => glist_make_list_vt (list_vt_reverse (res))
  | ~GLcons (d2e, d2es) => let val d3e = d2exp_trdn (d2e, s2e) in d2explst_trdn_elt_loop (d2es, s2e, list_vt_cons (d3e, res)) end
implement d2explst_trdn_elt (d2es, s2e) = d2explst_trdn_elt_loop (d2es, s2e, list_vt_nil ())
//
implement s2addr_deref (loc0, s2l, d3ls, s2rt) = let
  val () = s2rt := s2exp_t0ype_err ()
in
  stub_stop<s2exp> ("s2addr_deref")
end
implement d2exp_trup_applst_sym (d2e0, d2s, _arg) = stub_stop<d3exp> ("d2exp_trup_applst_sym")
implement d2exp_trup_applst_tmpsym (d2e0, d2s, t2mas, _arg) = stub_stop<d3exp> ("d2exp_trup_applst_tmpsym")
implement d2exp_trup_applst_seloverld (d2e0, _fun, d2s, _arg) = stub_stop<d3exp> ("d2exp_trup_applst_seloverld")
implement d2exp_trup_selab (loc0, tup, labs) = stub_stop<d3exp> ("d2exp_trup_selab")
implement d2exp_trup_foldat (d2e0) = stub_stop<d3exp> ("d2exp_trup_foldat")
implement d2exp_trup_freeat (d2e0) = stub_stop<d3exp> ("d2exp_trup_freeat")
implement d2exp_trup_ptrof (d2e0) = stub_stop<d3exp> ("d2exp_trup_ptrof")
implement d2exp_trup_deref (loc0, d2s, d2e, d2ls) = stub_stop<d3exp> ("d2exp_trup_deref")
implement d2exp_trup_assgn (d2e0) = stub_stop<d3exp> ("d2exp_trup_assgn")
implement d2exp_trup_xchng (d2e0) = stub_stop<d3exp> ("d2exp_trup_xchng")
implement d2exp_trup_viewat (d2e0) = stub_stop<d3exp> ("d2exp_trup_viewat")
implement d2exp_trup_loop (loc, inv, init, test, post, body) = stub_stop<d3exp> ("d2exp_trup_loop")
implement d2exp_trup_loopexn (loc, knd) = stub_stop<d3exp> ("d2exp_trup_loopexn")
implement d2exp_trdn_ifhead (d2e, s2f) = stub_stop<d3exp> ("d2exp_trdn_ifhead")
implement d2exp_trdn_sifhead (d2e, s2f) = stub_stop<d3exp> ("d2exp_trdn_sifhead")
implement d2exp_trdn_ifcasehd (d2e, s2f) = stub_stop<d3exp> ("d2exp_trdn_ifcasehd")
implement d2exp_trdn_casehead (d2e, s2f) = stub_stop<d3exp> ("d2exp_trdn_casehead")
implement d2exp_trdn_scasehead (d2e, s2f) = stub_stop<d3exp> ("d2exp_trdn_scasehead")
implement c2laulst_trdn (loc0, casknd, invres, c2ls, d3es, s2es_pat, s2e_res) = stub_stop<c3laulst> ("c2laulst_trdn")
