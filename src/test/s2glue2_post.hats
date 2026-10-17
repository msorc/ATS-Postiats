(* ATS2: wrappers of the templates and the externs (after the generated dumpers) *)

fun mkuchr (k: int): uchar = $UN.cast{uchar} (65 + k)
fun mkfilenv_k (k: int): filenv = $UN.cast{filenv} (k)
extern fun t_set_isabs (x: s2cst, opt: s2expopt): void = "ext#patsopts2cst_set_isabs"
//
fun t_cmap_nil (): s2cstmap (s2exp) = s2cstmap_nil<s2exp> ()
fun t_cmap_add (m: s2cstmap (s2exp), k: s2cst, e: s2exp): s2cstmap (s2exp) = s2cstmap_add<s2exp> (m, k, e)
fun t_cmap_find (m: s2cstmap (s2exp), k: s2cst): Option_vt (s2exp) = s2cstmap_find<s2exp> (m, k)
//
fun t_ns_f (env: ptr, fenv: filenv): Option_vt (filenv) =
  if $UN.cast{ptr} (fenv) = env then Some_vt (fenv) else None_vt ()
fun t_ns_find (k: int): int = let
  val r = the_namespace_search<filenv> ($UN.cast{ptr} (k), t_ns_f)
in
  case+ r of ~Some_vt (f) => $UN.cast{int} (f) | ~None_vt () => ~1
end
//
fn t_app (x: s2exp, env: !appenv): void = (dd_s2exp x; dd_nl ())
fun t_synapp (xs: s2explst): void = let
  val env = $UN.castvwtp0{appenv} (the_null_ptr)
  val () = synentlst_app<s2exp> (xs, env, t_app)
  val _ = $UN.castvwtp0{ptr} (env)
in
end

fun t_bm_free (m: s2varbindmap): void = let
  val _ = $UN.castvwtp0{ptr} (m)
in
end

fun t_ns_f2 (env: ptr, fenv: filenv): Option_vt (filenv) =
  if ($UN.cast{int} (fenv) mod 3) = $UN.cast{int} (env) then Some_vt (fenv) else None_vt ()
fun t_ns_first (r: int): int = let
  val x = the_namespace_search<filenv> ($UN.cast{ptr} (r), t_ns_f2)
in
  case+ x of ~Some_vt (f) => $UN.cast{int} (f) | ~None_vt () => ~1
end

(* ****** ****** *)
//
// the tables of the test doubles of trans2_env and trans3_env (implemented by the driver, s2env2.hats)
//
extern fun t_penv_clear (): void = "ext#s2t_penv_clear"
extern fun t_penv_add (id: symbol, itm: s2itm): void = "ext#s2t_penv_add"
extern fun t_bind_clear (): void = "ext#s2t_bind_clear"
extern fun t_bind_add (v: s2var, e: s2exp): void = "ext#s2t_bind_add"
//
// the environments of the bound variables of the functions [s2exp_syneq_env] etc. (linear lists)
//
fun t_env_make (vs: s2varlst): s2varlst_vt = let
  fun loop (vs: s2varlst, res: s2varlst_vt): s2varlst_vt =
    case+ glist_view (vs) of
    | ~GLnil () => res
    | ~GLcons (v, vs) => loop (vs, list_vt_cons (v, res))
in
  loop (vs, list_vt_nil ())
end
fun t_var_syneq_env (vs1: s2varlst, vs2: s2varlst, v1: s2var, v2: s2var): bool = let
  val env1 = t_env_make (vs1) and env2 = t_env_make (vs2)
  val r = s2var_syneq_env (env1, env2, v1, v2)
  val () = list_vt_free (env1) and () = list_vt_free (env2)
in
  r
end
fun t_exp_syneq_env (vs1: s2varlst, vs2: s2varlst, e1: s2exp, e2: s2exp): bool = let
  val env1 = t_env_make (vs1) and env2 = t_env_make (vs2)
  val r = s2exp_syneq_env (env1, env2, e1, e2)
  val () = list_vt_free (env1) and () = list_vt_free (env2)
in
  r
end
fun t_hnf_syneq_env (vs1: s2varlst, vs2: s2varlst, e1: s2exp, e2: s2exp): bool = let
  val env1 = t_env_make (vs1) and env2 = t_env_make (vs2)
  val r = s2hnf_syneq_env (env1, env2, s2exp2hnf (e1), s2exp2hnf (e2))
  val () = list_vt_free (env1) and () = list_vt_free (env2)
in
  r
end
fun t_lst_syneq_env (vs1: s2varlst, vs2: s2varlst, es1: s2explst, es2: s2explst): bool = let
  val env1 = t_env_make (vs1) and env2 = t_env_make (vs2)
  val r = s2explst_syneq_env (env1, env2, es1, es2)
  val () = list_vt_free (env1) and () = list_vt_free (env2)
in
  r
end
fun t_lstlst_syneq_env (vs1: s2varlst, vs2: s2varlst, es1: s2explstlst, es2: s2explstlst): bool = let
  val env1 = t_env_make (vs1) and env2 = t_env_make (vs2)
  val r = s2explstlst_syneq_env (env1, env2, es1, es2)
  val () = list_vt_free (env1) and () = list_vt_free (env2)
in
  r
end
