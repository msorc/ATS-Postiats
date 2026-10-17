(* the part of the ccomp group B test that is written once for ATS1 and ATS2 (the common subset), after the generated dumpers *)
(* ****** ****** *)

fun dd_optvt_primval (x: Option_vt (primval)): void =
  case+ x of ~Some_vt (e) => (dd_ps "Some_vt("; dd_primval e; dd_ps ")") | ~None_vt () => dd_ps "None_vt()"

fun ccb_sub3 (v0: s2var, e0: s2exp, v1: s2var, e1: s2exp, v2: s2var, e2: s2exp): stasub = let
  var sub = stasub_make_nil ()
  val () = stasub_add (sub, v0, e0)
  val () = stasub_add (sub, v1, e1)
  val () = stasub_add (sub, v2, e2)
in
  sub
end
fun ccb_funlab_subst (sub: stasub, fl: funlab): funlab = let
  val fl2 = funlab_subst (sub, fl)
  val () = stasub_free (sub)
in
  fl2
end
fun ccb_funent_subst (env: !ccompenv, sub: stasub, fl2: funlab, fent: funent, sfx: int): funent = let
  val fe2 = funent_subst (env, sub, fl2, fent, sfx)
  val () = stasub_free (sub)
in
  fe2
end
fun ccb_d2envlst_subst (sub: stasub, d2es: d2envlst): d2envlst_vt = let
  val r = d2envlst_subst (sub, d2es)
  val () = stasub_free (sub)
in
  r
end
fun ccb_t2mas_subst (sub: stasub, t2mas: t2mpmarglst): t2mpmarglst = let
  val r = t2mpmarglst_subst ($LOC.location_dummy, sub, t2mas)
  val () = stasub_free (sub)
in
  r
end
fun dd_d2envlstvt (xs: d2envlst_vt): void = let
  fun loop (xs: d2envlst_vt, i: int): void =
    case+ xs of
    | ~list_vt_cons (x, xs) => ((if i > 0 then dd_ps ","); dd_d2env x; loop (xs, i+1))
    | ~list_vt_nil () => ()
in
  dd_ps "["; loop (xs, 0); dd_ps "]"
end

fun ccb_pd_fundecs (loc: location, knd: funkind, decarg: s2qualst, hfds: hifundeclst): primdec = let
  val () = ccb_hfds_mkfun (hfds)
in
  primdec_fundecs (loc, knd, decarg, hfds)
end
