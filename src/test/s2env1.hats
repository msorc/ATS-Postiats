(* the ATS1 test doubles of the functions of the modules that are not ported yet (pats_trans2_env.dats, pats_trans3_env.dats):
   the same as s2env2.hats (see there), for the ATS1 driver s2dump1.dats. *)
(* ****** ****** *)
//
val the_penv_ids = ref<List (symbol)> (list_nil ())
val the_penv_itms = ref<List (s2itm)> (list_nil ())
val the_bind_vars = ref<List (s2var)> (list_nil ())
val the_bind_exps = ref<List (s2exp)> (list_nil ())
//
implement t_penv_clear () = {
  val () = !the_penv_ids := list_nil ()
  val () = !the_penv_itms := list_nil ()
}
implement t_penv_add (id, itm) = {
  val () = !the_penv_ids := list_cons (id, !the_penv_ids)
  val () = !the_penv_itms := list_cons (itm, !the_penv_itms)
}
implement t_bind_clear () = {
  val () = !the_bind_vars := list_nil ()
  val () = !the_bind_exps := list_nil ()
}
implement t_bind_add (v, e) = {
  val () = !the_bind_vars := list_cons (v, !the_bind_vars)
  val () = !the_bind_exps := list_cons (e, !the_bind_exps)
}
//
fun penv_find (ids: List (symbol), itms: List (s2itm), id: symbol): Option_vt (s2itm) =
  case+ ids of
  | list_nil () => None_vt ()
  | list_cons (id1, ids) => (
    case+ itms of
    | list_nil () => None_vt ()
    | list_cons (itm1, itms) => if $SYM.eq_symbol_symbol (id, id1) then Some_vt (itm1) else penv_find (ids, itms, id)
    )
implement the_s2expenv_pervasive_find (id) =
  penv_find (!the_penv_ids, !the_penv_itms, id)
//
fun bind_find (vs: List (s2var), es: List (s2exp), v: s2var): Option_vt (s2exp) =
  case+ vs of
  | list_nil () => None_vt ()
  | list_cons (v1, vs) => (
    case+ es of
    | list_nil () => None_vt ()
    | list_cons (e1, es) => if eq_s2var_s2var (v, v1) then Some_vt (e1) else bind_find (vs, es, v)
    )
implement s2exp_hnfize_flag_svar (s2e0, s2v, flag) = let
  val ans = bind_find (!the_bind_vars, !the_bind_exps, s2v)
in
  case+ ans of
  | ~None_vt () => s2e0
  | ~Some_vt (s2e) => let val () = flag := flag + 1 in s2exp_hnfize (s2e) end
end
//
implement s2var_occurcheck_s2exp (s2v0, s2e) = let
  fun loop (xs: List_vt (s2var), v: s2var): bool =
    case+ xs of
    | ~list_vt_cons (x, xs) => if eq_s2var_s2var (x, v) then (list_vt_free (xs); true) else loop (xs, v)
    | ~list_vt_nil () => false
  val fvs = s2exp_freevars (s2e)
in
  loop (s2varset_vt_listize_free (fvs), s2v0)
end
fun dd_listvt_s2var_borrow (xs: !List0_vt (s2var)): void = dd_listvt_s2var (list_vt_copy (xs))
fun dd_listvt_s2exp_borrow (xs: !List0_vt (s2exp)): void = dd_listvt_s2exp (list_vt_copy (xs))
//
fun t3_loc (loc: location): void = (dd_ps " "; dd_location loc)
//
extern prfun t3_push_v_make (): trans3_env_push_v
extern prfun t3_push_v_free (pf: trans3_env_push_v): void
implement trans3_env_push () = let
  val () = (dd_ps "T3 push"; dd_nl ())
  prval pf = t3_push_v_make ()
in
  (pf | ())
end
implement trans3_env_pop_and_add_main (pf | loc) = let
  prval () = t3_push_v_free (pf)
in
  (dd_ps "T3 pop_and_add_main"; t3_loc loc; dd_nl ())
end
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
fun t3_inst (knd: int, s2e0: s2exp, locarg: location, err: &int, res: &s2explst_vt): s2exp = let
  var vs: s2varlst
  var ps: s2explst
  var sco: s2exp
  val s2e = s2hnf2exp (s2exp2hnf (s2e0))
  val ans = uns2exp_exiuni (knd, s2e, vs, ps, sco)
in
  if ans then let
    var sub = stasub_make_nil ()
    fun addv (sub: &stasub, locarg: location, vs: s2varlst): void =
      case+ vs of
      | list_nil () => ()
      | list_cons (v, vs) => let
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
  (s2e, list_vt_reverse (res))
end
implement s2exp_uni_instantiate_all (s2e0, locarg, err) = let
  var res: s2explst_vt = list_vt_nil ()
  val s2e = t3_inst (1, s2e0, locarg, err, res)
in
  (s2e, list_vt_reverse (res))
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
