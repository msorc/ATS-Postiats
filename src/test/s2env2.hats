(* the ATS2 test doubles of the functions of the modules that are not ported yet (pats_trans2_env.dats, pats_trans3_env.dats):
   see PORTING.md, "Level 2, slice 2". The ATS1 driver has the same code (s2env1.hats). Included by s2dump.dats.
   * [the_s2expenv_pervasive_find]: a table (the last [t_penv_add] first) of the pervasive static constants of the cases.
   * [s2exp_hnfize_flag_svar]: a table of bindings of static variables ([t_bind_add]), as the_s2varbindmap of trans3_env.
   * the recorders [trans3_env_*]: print their arguments, as lines "T3 ..." of the output.
   * [s2var_occurcheck_s2exp]: through [s2exp_freevars]. *)
(* ****** ****** *)
//
var the_penv_ids: glist (symbol) = glist_nil ()
var the_penv_itms: glist (s2itm) = glist_nil ()
var the_bind_vars: glist (s2var) = glist_nil ()
var the_bind_exps: glist (s2exp) = glist_nil ()
val the_penv_ids_r = ref_make_viewptr{glist (symbol)} (view@ the_penv_ids | addr@ the_penv_ids)
val the_penv_itms_r = ref_make_viewptr{glist (s2itm)} (view@ the_penv_itms | addr@ the_penv_itms)
val the_bind_vars_r = ref_make_viewptr{glist (s2var)} (view@ the_bind_vars | addr@ the_bind_vars)
val the_bind_exps_r = ref_make_viewptr{glist (s2exp)} (view@ the_bind_exps | addr@ the_bind_exps)
//
implement t_penv_clear () = {
  val () = ref_set_elt (the_penv_ids_r, glist_nil ())
  val () = ref_set_elt (the_penv_itms_r, glist_nil ())
}
implement t_penv_add (id, itm) = {
  val () = ref_set_elt (the_penv_ids_r, glist_cons<symbol> (id, ref_get_elt (the_penv_ids_r)))
  val () = ref_set_elt (the_penv_itms_r, glist_cons<s2itm> (itm, ref_get_elt (the_penv_itms_r)))
}
implement t_bind_clear () = {
  val () = ref_set_elt (the_bind_vars_r, glist_nil ())
  val () = ref_set_elt (the_bind_exps_r, glist_nil ())
}
implement t_bind_add (v, e) = {
  val () = ref_set_elt (the_bind_vars_r, glist_cons<s2var> (v, ref_get_elt (the_bind_vars_r)))
  val () = ref_set_elt (the_bind_exps_r, glist_cons<s2exp> (e, ref_get_elt (the_bind_exps_r)))
}
//
fun penv_find (ids: glist (symbol), itms: glist (s2itm), id: symbol): Option_vt (s2itm) =
  case+ glist_view (ids) of
  | ~GLnil () => None_vt ()
  | ~GLcons (id1, ids) => (
    case+ glist_view (itms) of
    | ~GLnil () => None_vt ()
    | ~GLcons (itm1, itms) => if $SYM.eq_symbol_symbol (id, id1) then Some_vt (itm1) else penv_find (ids, itms, id)
    )
implement the_s2expenv_pervasive_find (id) =
  penv_find (ref_get_elt (the_penv_ids_r), ref_get_elt (the_penv_itms_r), id)
//
fun bind_find (vs: glist (s2var), es: glist (s2exp), v: s2var): Option_vt (s2exp) =
  case+ glist_view (vs) of
  | ~GLnil () => None_vt ()
  | ~GLcons (v1, vs) => (
    case+ glist_view (es) of
    | ~GLnil () => None_vt ()
    | ~GLcons (e1, es) => if eq_s2var_s2var (v, v1) then Some_vt (e1) else bind_find (vs, es, v)
    )
implement s2exp_hnfize_flag_svar (s2e0, s2v, flag) = let
  val ans = bind_find (ref_get_elt (the_bind_vars_r), ref_get_elt (the_bind_exps_r), s2v)
in
  case+ ans of
  | ~None_vt () => s2e0
  | ~Some_vt (s2e) => let val () = flag := flag + 1 in s2exp_hnfize (s2e) end
end
//
implement s2var_occurcheck_s2exp (s2v0, s2e) = let
  fun loop (xs: List0_vt (s2var), v: s2var): bool =
    case+ xs of
    | ~list_vt_cons (x, xs) => if eq_s2var_s2var (x, v) then (list_vt_free (xs); true) else loop (xs, v)
    | ~list_vt_nil () => false
  val fvs = s2exp_freevars (s2e)
in
  loop (s2varset_vt_listize_free (fvs), s2v0)
end
fun dd_listvt_s2var_borrow (xs: !List0_vt (s2var)): void = dd_listvt_s2var (list_vt_copy<s2var> (xs))
fun dd_listvt_s2exp_borrow (xs: !List0_vt (s2exp)): void = dd_listvt_s2exp (list_vt_copy<s2exp> (xs))
//
fun t3_loc (loc: location): void = (dd_ps " "; dd_location loc)
implement trans3_env_push () = (dd_ps "T3 push"; dd_nl ())
implement trans3_env_pop_and_add_main (loc) = (dd_ps "T3 pop_and_add_main"; t3_loc loc; dd_nl ())
implement trans3_env_add_proplst_vt (loc, s2ps) = let
  val () = (dd_ps "T3 add_proplst_vt"; t3_loc loc; dd_ps " "; dd_listvt_s2exp (s2ps))
in
  dd_nl ()
end
implement trans3_env_add_eqeq (loc, e1, e2) = (dd_ps "T3 add_eqeq"; t3_loc loc; dd_ps " "; dd_s2exp e1; dd_ps " "; dd_s2exp e2; dd_nl ())
implement trans3_env_hypadd_prop (loc, e) = (dd_ps "T3 hypadd_prop"; t3_loc loc; dd_ps " "; dd_s2exp e; dd_nl ())
implement trans3_env_hypadd_bind (loc, v, f) = (dd_ps "T3 hypadd_bind"; t3_loc loc; dd_ps " "; dd_s2var v; dd_ps " "; dd_s2exp (s2hnf2exp f); dd_nl ())
implement trans3_env_hypadd_eqeq (loc, f1, f2) = (dd_ps "T3 hypadd_eqeq"; t3_loc loc; dd_ps " "; dd_s2exp (s2hnf2exp f1); dd_ps " "; dd_s2exp (s2hnf2exp f2); dd_nl ())
//
// the instantiation of the universal/existential quantifiers: a fresh existential variable for each bound variable
//
fun t3_inst (knd: int, s2e0: s2exp, locarg: location, err: &int, res: &s2explst_vt >> _): s2exp = let
  var vs: s2varlst? and ps: s2explst? and sco: s2exp?
  val s2e = s2hnf2exp (s2exp2hnf (s2e0))
  val ans = uns2exp_exiuni (knd, s2e, vs, ps, sco)
in
  if ans then let
    var sub = stasub_make_nil ()
    fun addv (sub: &stasub >> _, locarg: location, vs: s2varlst): void =
      case+ glist_view (vs) of
      | ~GLnil () => ()
      | ~GLcons (v, vs) => let
          val () = stasub_add (sub, v, s2exp_Var (s2Var_make_var (locarg, v)))
        in
          addv (sub, locarg, vs)
        end
    val () = addv (sub, locarg, vs)
    val ps1 = s2explst_subst_vt (sub, ps)
    val () = res := list_vt_reverse_append (ps1, res)
    val sco1 = s2exp_subst (sub, sco)
    val () = stasub_free (sub)
  in
    t3_inst (knd, sco1, locarg, err, res)
  end else s2e
end
implement s2exp_exi_instantiate_all (s2e0, locarg, err) = let
  var res: s2explst_vt = list_vt_nil ()
  val s2e = t3_inst (0, s2e0, locarg, err, res)
in
  @(s2e, list_vt_reverse (res))
end
implement s2exp_uni_instantiate_all (s2e0, locarg, err) = let
  var res: s2explst_vt = list_vt_nil ()
  val s2e = t3_inst (1, s2e0, locarg, err, res)
in
  @(s2e, list_vt_reverse (res))
end
implement s2hnf_absuni_and_add (loc, s2f) = let
  val @(s2e, s2vs, s2ps) = s2exp_absuni (s2hnf2exp s2f)
  val () = (dd_ps "T3 add_svarlst "; dd_listvt_s2var_borrow (s2vs); dd_nl ())
  val () = list_vt_free (s2vs)
  val () = (dd_ps "T3 hypadd_proplst_vt"; t3_loc loc; dd_ps " "; dd_listvt_s2exp_borrow (s2ps); dd_nl ())
  val () = list_vt_free (s2ps)
in
  s2e
end
implement s2hnf_opnexi_and_add (loc, s2f) = let
  val @(s2e, s2vs, s2ps) = s2exp_opnexi (s2hnf2exp s2f)
  val () = (dd_ps "T3 add_svarlst "; dd_listvt_s2var_borrow (s2vs); dd_nl ())
  val () = list_vt_free (s2vs)
  val () = (dd_ps "T3 hypadd_proplst_vt"; t3_loc loc; dd_ps " "; dd_listvt_s2exp_borrow (s2ps); dd_nl ())
  val () = list_vt_free (s2ps)
in
  s2e
end
