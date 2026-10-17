(* the test doubles of trans3_env (the recorders) and of the binding table of trans3_env for the codegen2/patcst2 test (copy of the
   second half of s2env2.hats / s2env1.hats; the real pats_staexp2_util2/util3/solve are linked, they call these functions; they print
   a line "T3 .." when called, the lists by their length). The environment functions of trans2_env are the tables of cgenv.cats. *)
(* ****** ****** *)
//
implement s2exp_hnfize_flag_svar (s2e0, s2v, flag) = s2e0
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
fun dd_listvt_s2var_borrow (xs: !List0_vt (s2var)): void = dd_int (list_vt_length xs)
fun dd_listvt_s2exp_borrow (xs: !List0_vt (s2exp)): void = dd_int (list_vt_length xs)
fun dd_s2exp (x: s2exp): void = fprint_s2exp (dd_out, x)
fun dd_listvt_s2exp (xs: List0_vt (s2exp)): void = (dd_int (list_vt_length xs); list_vt_free xs)
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
