(* ATS2 test double of the part of pats_trans3_env.dats that the level-2 translation calls ($d2ctype of pats_trans2_dynexp.dats):
   a port of s2exp_tmp_instantiate_tmpmarglst and the functions it needs (the errors of the trans3 error list are only printed:
   the list is not looked at by the level-2 test; [trans3_env_add_sVar] records the variable for the solver). Included by t2dump.dats. *)

fun
t2_stasub_instantiate_some
(
  sub: &stasub >> _
, locarg: location, s2vs: s2varlst, s2es: s2explst
, err: &int
) : void = let
//
fun
auxerr1
(
  locarg: location, serr: int
) : void = let
  val () = prerr_error3_loc (locarg)
  val () = filprerr_ifdebug "stasub_s2varlst_instantiate_some"
  val () = prerr ": static arity mismatch"
  val () = if serr > 0 then prerr ": more arguments are expected."
  val () = if serr < 0 then prerr ": fewer arguments are expected."
  val () = prerr_newline ((*void*))
in
end // end of [auxerr1]
fun
auxerr2
(
  locarg: location, s2t1: s2rt, s2t2: s2rt
) : void = let
  val () = prerr_error3_loc (locarg)
  val () = filprerr_ifdebug "stasub_s2varlst_instantiate_some"
  val () = prerr ": mismatch of sorts:\n"
  val () = prerrln! ("the needed sort is [", s2t1, "];")
  val () = prerrln! ("the actual sort is [", s2t2, "].")
in
end // end of [auxerr2]
//
in
//
case+ glist_view (s2vs) of
| ~GLcons (s2v, s2vs) => (
  case+ glist_view (s2es) of
  | ~GLcons (s2e, s2es) => let
      val s2t1 = s2var_get_srt (s2v)
      val s2t2 = s2e.s2exp_srt ()
      val ismat = s2rt_ltmat1 (s2t2, s2t1)
    in
      if ismat then let
        val () = stasub_add (sub, s2v, s2e)
      in
        t2_stasub_instantiate_some (sub, locarg, s2vs, s2es, err)
      end else let
        val () = err := err + 1
        val () = auxerr2 (locarg, s2t1, s2t2)
        val () = stasub_add (sub, s2v, s2exp_errexp(s2t1))
      in
        t2_stasub_instantiate_some (sub, locarg, s2vs, s2es, err)
      end (* end of [if] *)
    end // end of [list_cons]
  | ~GLnil () => let
      val () = err := err + 1
      val () = auxerr1 (locarg, 1) // HX: more arguments expected
    in
      // nothing
    end // end of [list_nil]
  ) // end of [list_cons]
| ~GLnil () => (
  case+ glist_view (s2es) of
  | ~GLcons (_, _) => let
      val () = err := err + 1
      val () = auxerr1 (locarg, ~1) // HX: fewer arguments expected
    in
      // nothing
    end // end of [list_cons]
  | ~GLnil () => ()
  ) // end of [list_nil]
end // end of [t2_stasub_instantiate_some]

fun
t2_stasub_instcollect
(
  sub: &stasub >> _
, locarg: location, s2vs: s2varlst, res: s2explst_vt
) : s2explst_vt =
  case+ glist_view (s2vs) of
  | ~GLcons (s2v, s2vs) => let
      val s2V = s2Var_make_var (locarg, s2v)
      val s2e = s2exp_Var (s2V)
      val () = stasub_add (sub, s2v, s2e)
      val res = list_vt_cons (s2e, res)
    in
      t2_stasub_instcollect (sub, locarg, s2vs, res)
    end // end of [list_cons]
  | ~GLnil () => list_vt_reverse (res)

fn
t2_tmp_instantiate_rest
  (s2e_tmp: s2exp, locarg: location, s2qs: s2qualst, nerr: &int): @(s2exp, t2mpmarglst) = let
//
fun loop (
  locarg: location
, sub: &stasub >> _
, s2qs: s2qualst
, t2mas: List0_vt (t2mpmarg)
, nerr: &int // HX: unused
) : List0_vt (t2mpmarg) =
  case+ glist_view (s2qs) of
  | ~GLnil () => list_vt_reverse (t2mas)
  | ~GLcons (s2q, s2qs) => let
      val s2vs = s2q.s2qua_svs ()
      val () = assertloc (glist_is_nil (s2q.s2qua_sps ()))
      val s2es = t2_stasub_instcollect (sub, locarg, s2vs, list_vt_nil ())
      val t2ma = t2mpmarg_make (locarg, glist_make_list_vt (s2es))
      val t2mas = list_vt_cons (t2ma, t2mas)
    in
      loop (locarg, sub, s2qs, t2mas, nerr)
    end // end of [list_cons]
//
var sub: stasub = stasub_make_nil ()
val t2mas = loop (locarg, sub, s2qs, list_vt_nil (), nerr)
val s2e_res = s2exp_subst (sub, s2e_tmp)
val ((*freed*)) = stasub_free (sub)
//
in
  @(s2e_res, glist_make_list_vt (t2mas))
end // end of [t2_tmp_instantiate_rest]

implement
s2exp_tmp_instantiate_tmpmarglst_stub
  (s2e_tmp, locarg, s2qs, t2mas, nerr) = let
//
fun
auxerr
(
  locarg: location
) : void = let
  val () =
  prerr_error3_loc (locarg)
  val () =
  filprerr_ifdebug "s2exp_tmp_instantiate_tmpmarglst"
  val () =
  prerrln! ": the template instantiation is overly done."
in
end (* end of [auxerr] *)
//
var locarg: location = locarg
//
fun
auxsome
(
  sub: &stasub >> _
, locarg: &location
, s2qs: s2qualst
, t2mas: t2mpmarglst
, nerr: &int
) : s2qualst =
  case+ glist_view (s2qs) of
  | ~GLnil () => (
    case+ glist_view (t2mas) of
    | ~GLnil () => glist_nil ()
    | ~GLcons (t2ma, t2mas) => let
        val () = nerr := nerr + 1
        val () = locarg := t2ma.t2mpmarg_loc ()
        val () = auxerr (locarg)
      in
        auxsome (sub, locarg, s2qs, t2mas, nerr)
      end // end of [list_cons]
    ) (* end of [list_nil] *)
  | ~GLcons (s2q, s2qs1) => (
    case+ glist_view (t2mas) of
    | ~GLnil () => glist_cons (s2q, s2qs1)
    | ~GLcons (t2ma, t2mas) => let
        val s2vs = s2q.s2qua_svs ()
        val () = assertloc (glist_is_nil (s2q.s2qua_sps ()))
        val s2es = t2ma.t2mpmarg_arg ()
        val () = locarg := t2ma.t2mpmarg_loc ()
        val () = t2_stasub_instantiate_some (sub, locarg, s2vs, s2es, nerr)
      in
        auxsome (sub, locarg, s2qs1, t2mas, nerr)
      end // end of [list_cons]
    ) (* end of [list_cons] *)
//
var sub: stasub = stasub_make_nil ()
val s2qs = auxsome (sub, locarg, s2qs, t2mas, nerr)
val s2e_res = s2exp_subst (sub, s2e_tmp)
val ((*freed*)) = stasub_free (sub)
//
in
//
if glist_is_nil (s2qs) then @(s2e_res, t2mas)
else let
    val locarg = $LOC.location_rightmost (locarg)
    val @(s2e2_res, t2mas2) =
      t2_tmp_instantiate_rest (s2e_res, locarg, s2qs, nerr)
  in
    @(s2e2_res, glist_append<t2mpmarg> (t2mas, t2mas2))
  end // end of [list_cons]
//
end // end of [s2exp_tmp_instantiate_tmpmarglst]
