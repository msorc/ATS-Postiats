(* the cases of the C1 test that end the process (CC1EXIT=k, see cc1_exit.sh): a MatchError of ATS1 (a [val-] that fails); the ATS2 port ends the same way (assertloc).
   Common subset of ATS1 and ATS2 (included by the drivers after the doubles of cc1_impl.hats). *)
(* ****** ****** *)

fun cx_dv (k: int): d2var = let
  val v = mkd2var (k)
  val () = d2var_set_level (v, 1)
  val () = set_dv_hisexp (v, mkhse (0))
in
  v
end
fun cx_fl (k: int, lvl: int): funlab =
  funlab_make ("cx", lvl, mkhfun (k), None_vt (), ON_d2cstopt (), ON_d2varopt (), LN_t2mpmarglst (), $STMP.funlab_stamp_make ())
fun cx_fent (fl: funlab, fls: funlablst, d2es: d2envlst): funent =
  funent_make (mkloc (1), fl, LN_s2varlst (), LN_s2explstlst (), ON_tmpsubopt (), tmpvar_make (mkloc (2), mkhse (0)), fls, d2es, mk_vbmap_nil (), LN_instrlst (), LN_tmpvarlst ())

fun cx_run (k: int): void = let
  val env = ccompenv_make ()
  val pv = primval_int (mkloc (1), mkhse (0), 1)
  val dv = cx_dv (1)
  val de = d2env_make (dv, mkhse (0))
  val fl = cx_fl (1, 3)
  val tl = tmplab_make (mkloc (3))
  val () = dd_ps "exit case "; val () = dd_int k; val () = dd_nl ()
  val () = (
    case+ k of
    | 1 => op_freeconenv_getdec (env)
    | 2 => op_freeconenv_add (env, pv)
    | 3 => op_loopfini (env)
    | 4 => op_loopcont (env)
    | 5 => op_loopexn_dec (env)
    | 6 => op_tailcal_dec (env)
    | 7 => op_tailcal_find (env, fl)
    | 8 => op_tailcal_find_cst (env, mkd2cst (1))
    | 9 => op_tailcal_find_var (env, dv)
    | 10 => op_tailcal_find_tmpcst (env, mkd2cst (1))
    | 11 => op_tailcal_find_tmpvar (env, dv)
    | 12 => (op_dvarset_getdec (env); op_dvarset_getdec (env))
    | 13 => (op_dvarset_getdec (env); op_dvarset_add_var (env, dv))
    | 14 => (op_dvarset_getdec (env); op_dvarset_add_env (env, de))
    | 15 => (op_flabset_getdec (env); op_flabset_getdec (env))
    | 16 => (op_flabset_getdec (env); op_flabset_add (env, fl))
    | 17 => (op_vbindmapenv_getdec (env); op_vbindmapenv_getdec (env))
    | 18 => (op_vbindmapenv_getdec (env); op_vbindmapenv_add (env, dv, pv))
    | 19 => (op_vbindmapenv_getdec (env); op_vbindmapenv_find (env, dv))
    | 20 => op_flabset_addlst_ifmap (env, 0, mk_vbmap_nil (), list_vt_cons (fl, list_vt_nil ()))
    | 21 => let   // the transitive closure meets a function without entry
        val fl2 = cx_fl (2, 3)
        val fent = cx_fent (fl, LC_funlablst (fl2, LN_funlablst ()), LN_d2envlst ())
      in
        op_eval_flablst (fent)
      end
    | 22 => let
        val fl2 = cx_fl (2, 1)   // a parent function: the closure does not look into it, but the environments do
        val fent = cx_fent (fl, LC_funlablst (fl2, LN_funlablst ()), LN_d2envlst ())
      in
        op_eval_d2envlst (fent)
      end
    | 23 => let   // tmpvar_match with a file environment that has no map of the functions
        val () = op_add_staload (env, mkfilenv (60))
      in
        op_tmpvar_match (env, dv)
      end
    | 24 => op_comp (env, hidexp_loopexn (mkloc (4), mkhse (0), 1))
    | 25 => let
        val fent = cx_fent (fl, LN_funlablst (), LN_d2envlst ())
        val () = funlab_set_funent (fl, OS_funentopt (fent))
        val fl2 = cx_fl (2, 3)
      in
        op_flabset_addlst_ifmap (env, 0, mk_vbmap_nil (), list_vt_cons (fl2, list_vt_nil ()))
      end
    | _ => ()
  ) : void
  val () = ccompenv_free (env)
in
  ()
end
fun cx_count (): int = 25
