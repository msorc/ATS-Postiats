#!/usr/bin/env python3
"""cc1_mutate.py OUTDIR [N...]   Mutation test of the ATS2 ports of pats_ccomp_{ccompenv,environ,caseof,looping,trywith,lazyeval}: for each deliberate bug below the module is mutated,
recompiled in the staging directory of cc1_2.sh (OUTDIR/stage2; CC1_ONLY recompiles just that module), relinked, run, and its stdout (and the exit status) compared with the reference
(OUTDIR/o1.txt, the output of cc1_1, the ATS1 build). With numbers: only those mutations."""
import sys, os, shutil, subprocess
OUT = os.path.abspath(sys.argv[1])
SEL = [int(a) for a in sys.argv[2:] if a.isdigit()]
L = os.path.dirname(os.path.abspath(__file__)); T = os.path.abspath(os.path.join(L, '..', '..'))
W = os.path.join(OUT, 'stage2')
E = 'pats_ccomp_ccompenv.dats'; V = 'pats_ccomp_environ.dats'; C = 'pats_ccomp_caseof.dats'; P = 'pats_ccomp_looping.dats'; Y = 'pats_ccomp_trywith.dats'; Z = 'pats_ccomp_lazyeval.dats'
M = [
 # ---- pats_ccomp_ccompenv.dats: the global lists
 ('the_exndeclst_get: not reversed', E, 'the_exndeclst_get() = let\n  val xs = $UN.cast{hideclist}(cell_get(the_exndeclst))\n  val () = cell_set(the_exndeclst, the_null_ptr)\nin\n  glist_reverse<hidecl>(xs)', 'the_exndeclst_get() = let\n  val xs = $UN.cast{hideclist}(cell_get(the_exndeclst))\n  val () = cell_set(the_exndeclst, the_null_ptr)\nin\n  xs'),
 ('the_saspdeclst_get: not emptied', E, 'val () = cell_set(the_saspdeclst, the_null_ptr)\nin', 'val () = ()\nin'),
 ('the_extcodelst_get: unstable merge', E, 'if extcode_pos(x) - extcode_pos(y) <= 0', 'if extcode_pos(x) - extcode_pos(y) < 0'),
 ('the_extcodelst_get: no sorting', E, '  extcode_sort(xs, glist_length<hidecl>(xs)) // HX: stable-sorting', '  xs'),
 ('the_dyncstlst_add: no test of membership', E, 'if\n~(found)\nthen let\n  val () = let\n    val xs = $UN.cast{d2cstlst}', 'if\ntrue\nthen let\n  val () = let\n    val xs = $UN.cast{d2cstlst}'),
 ('the_dynconlst_get: not reversed', E, '  glist_reverse<d2con>(d2cs)', '  d2cs'),
 ('the_funlablst_get: not reversed', E, '  glist_reverse<funlab>(fls)', '  fls'),
 ('the_funlablst_addlst: only the first', E, '    val () = the_funlablst_add(fl) in addlst(fls1)', '    val () = the_funlablst_add(fl) in addlst(glist_nil())'),
 ('the_staloadlst_get: not reversed', E, '  glist_reverse<hidecl>(xs)\nend // end of [the_staloadlst_get]', '  xs\nend // end of [the_staloadlst_get]'),
 # ---- the printer of the environment
 ('fprint_markenvlst: the separator', E, '''    val () =
    (
      if i > 0 then fprint_string (out, ", ")
    )
    val () =
      fprint_d2var (out, x)''', '''    val () =
    (
      if i > 0 then fprint_string (out, ",")
    )
    val () =
      fprint_d2var (out, x)'''),
 ('fprint_markenvlst: the mark', E, 'fprint_string (out, "||")', 'fprint_string (out, "|")'),
 ('fprint_markenvlst: the staload', E, '    val fname = filenv_get_name (x)\n    val () =\n      $FIL.fprint_filename_full (out, fname)', '    val fname = filenv_get_name (x)\n    val () = fprint_string (out, "")'),
 # ---- counters
 ('dec_tmplevel: by 2', E, 'val ((*void*)) = (p.ccompenv_tmplevel := level - 1)', 'val ((*void*)) = (p.ccompenv_tmplevel := level - 2)'),
 ('inc_tmprecdepth: by 2', E, 'val ((*void*)) = p.ccompenv_tmprecdepth := depth+1', 'val ((*void*)) = p.ccompenv_tmprecdepth := depth+2'),
 ('dec_tmprecdepth: no effect', E, 'val ((*void*)) = p.ccompenv_tmprecdepth := depth-1', 'val ((*void*)) = p.ccompenv_tmprecdepth := depth'),
 # ---- freeconenv
 ('add_freeconenv: into the next frame', E, 'val-\n@list_vt_cons\n  (pmvs, _) = p.ccompenv_freeconenv\n//\nval ((*void*)) =\n  pmvs := list_vt_cons(pmv, pmvs)', 'val-\n@list_vt_cons\n  (pmvs, _) = p.ccompenv_freeconenv\n//\nval ((*void*)) =\n  pmvs := pmvs'),
 ('add_freeconenv_if: nullary test', E, '    if not(isnul)\n      then ccompenv_add_freeconenv(env, pmv)', '    if isnul\n      then ccompenv_add_freeconenv(env, pmv)'),
 ('add_freetupenv_if: the kind', E, '| PCKfree() =>\n  ccompenv_add_freeconenv(env, pmv)', '| PCKcon() =>\n  ccompenv_add_freeconenv(env, pmv)'),
 ('add_freeconenv_if: the kind', E, '| PCKfree() => let\n    val isnul = d2con_is_nullary(d2c)', '| PCKlincon() => let\n    val isnul = d2con_is_nullary(d2c)'),
 # ---- loops
 ('get_loopfini: the cont label', E, 'val tl_fini = x.1', 'val tl_fini = x.2'),
 ('get_loopcont: the init label', E, 'val tl_cont = x.2', 'val tl_cont = x.0'),
 ('inc_loopexnenv: the order of the labels', E, 'val tlll = @(tl1, tl2, tl3)', 'val tlll = @(tl2, tl1, tl3)'),
 # ---- tail calls
 ('auxfind (function group): the first index', E, 'auxfind_lst (s0, fls, 1)', 'auxfind_lst (s0, fls, 0)'),
 ('auxfind_lst: the index of the next', E, 'if iseq then i else auxfind_lst(s0, fls1, i+1)', 'if iseq then i else auxfind_lst(s0, fls1, i+2)'),
 ('auxfind2: the test', E, '        iseq = eq_d2cst_d2cst(d2c0, d2c)\n      in\n        if iseq then Some_vt(fl) else None_vt()', '        iseq = eq_d2cst_d2cst(d2c0, d2c)\n      in\n        if iseq then None_vt() else Some_vt(fl)'),
 ('auxfind3: the first count', E, '    val () = ntl := 1\n  in\n    auxfind3_lst', '    val () = ntl := 0\n  in\n    auxfind3_lst'),
 ('auxfind3_lst: the count', E, 'val () = ntl := ntl + 1 in auxfind3_lst(d2v0, fls1, ntl)', 'val () = ntl := ntl + 2 in auxfind3_lst(d2v0, fls1, ntl)'),
 ('find_tailcalenv_tmpcst: the match', E, '    if ans then Some_vt (fl0) else None_vt ()\n  end // end [Some_vt]\n//\n| ~None_vt((*void*)) => None_vt()\n//\nend // end of [ccompenv_find_tailcalenv_tmpcst]', '    if ans then None_vt () else Some_vt (fl0)\n  end // end [Some_vt]\n//\n| ~None_vt((*void*)) => None_vt()\n//\nend // end of [ccompenv_find_tailcalenv_tmpcst]'),
 ('find_tailcalenv_tmpvar: the match', E, '    if ans then Some_vt (fl0) else None_vt ()\n  end // end [Some_vt]\n//\n| ~None_vt((*void*)) => None_vt()\n//\nend // end of [ccompenv_find_tailcalenv_tmpvar]', '    if ans then Some_vt (fl0) else Some_vt (fl0)\n  end // end [Some_vt]\n//\n| ~None_vt((*void*)) => None_vt()\n//\nend // end of [ccompenv_find_tailcalenv_tmpvar]'),
 # ---- the sets of variables and functions
 ('add_dvarsetenv_var: the level', E, 'val lvl = d2var_get_level (d2v)\n//\nval () =\nif (lvl > 0) then', 'val lvl = d2var_get_level (d2v)\n//\nval () =\nif (lvl >= 0) then'),
 ('add_dvarsetenv_env: the level', E, 'val lvl = d2var_get_level (d2v)\n//\nval () =\nif (lvl > 0) then\n{\nval+ @CCOMPENV (p) = env\n//\nval-@list_vt_cons\n  (d2es, _) = p.ccompenv_dvarsetenv\nval () = d2es := d2envset_vt_add (d2es, d2e)', 'val lvl = d2var_get_level (d2v)\n//\nval () =\nif (lvl > 1) then\n{\nval+ @CCOMPENV (p) = env\n//\nval-@list_vt_cons\n  (d2es, _) = p.ccompenv_dvarsetenv\nval () = d2es := d2envset_vt_add (d2es, d2e)'),
 ('addlst_dvarsetenv_if: the comparison', E, 'if lvl <= flvl0 then ccompenv_add_dvarsetenv_env (env, d2e)', 'if lvl < flvl0 then ccompenv_add_dvarsetenv_env (env, d2e)'),
 ('addlst_flabsetenv_ifmap: the level', E, '    if flvl > flvl0 then let\n      val-~GOsome', '    if flvl >= flvl0 then let\n      val-~GOsome'),
 ('addlst_flabsetenv_ifmap: the test of the map', E, '      | ~Some_vt _ => ()\n      | ~None_vt _ => ccompenv_add_dvarsetenv_env (env, d2e)', '      | ~Some_vt _ => ccompenv_add_dvarsetenv_env (env, d2e)\n      | ~None_vt _ => ()'),
 ('addlst_flabsetenv_ifmap: the result list', E, '      val fls = addlst_if (env, flvl0, vbmap, fls)\n    in\n      list_vt_cons (fl, fls)', '      val fls = addlst_if (env, flvl0, vbmap, fls)\n    in\n      fls'),
 ('add_flabsetenv: no effect', E, 'val () = fls := funlabset_vt_add (fls, fl)', 'val () = fls := fls'),
 ('incwth_dvarsetenv: an empty set', E, 'val d2es = d2envlst2set (d2es)\n//\nval+ @CCOMPENV (p) = env', 'val d2es = d2envset_vt_nil ()\n//\nval+ @CCOMPENV (p) = env'),
 # ---- the maps and the scopes
 ('add_vbindmapenv: no effect', E, 'val _(*replaced*) = d2varmap_insert<primval> (vbm, d2v, pmv)', 'val _(*replaced*) = false'),
 ('find_vbindmapenv: nothing', E, 'val opt = d2varmap_search<primval> (vbm, d2v)\nprval () = fold@ (p.ccompenv_vbindmapenv)', 'val opt = None_vt ()\nprval () = fold@ (p.ccompenv_vbindmapenv)'),
 ('add_vbindmapall: no map', E, 'val _(*replaced*) = d2varmaplst_vt_insert<primval> (p.ccompenv_vbindmapall, d2v, pmv)', 'val _(*replaced*) = false'),
 ('add_vbindmapall: no mark of the variable', E, 'val () = p.ccompenv_markenvlst := MARKENVLSTcons_var (d2v, xs)', 'val () = p.ccompenv_markenvlst := xs'),
 ('auxpop: the variables are not removed', E, 'val _(*removed*) = d2varmaplst_vt_remove<primval> (map, d2v)', 'val _(*removed*) = false'),
 ('auxjoin2: only the top mark', E, '| ~MARKENVLSTmark (xs1) => (xs := xs1; auxpop2 (xs))', '| ~MARKENVLSTmark (xs1) => (xs := xs1)'),
 ('auxpop2: through the declarations', E, '| ~MARKENVLSTcons_impdec (_, xs1) => (xs := xs1; auxpop2(xs))', '| ~MARKENVLSTcons_impdec (_, xs1) => (xs := xs1)'),
 ('add_fundecsloc: no declarations', E, '    | ~Some_vt(tsub) => auxlst (env, tsub, hfds)\n', '    | ~Some_vt(tsub) => auxlst (env, tsub, glist_nil ())\n'),
 ('add_impdecloc: the kind of the entry', E, 'ccompenv_add_impdec2 (env, hiimpdec2_new(imp, tsub, tmparg))', 'ccompenv_add_impdec (env, imp)'),
 ('find_tmpsub: the first one', E, '| MARKENVLSTcons_tmpsub\n    (tsub, xs1) => Some_vt (tsub)', '| MARKENVLSTcons_tmpsub\n    (tsub, xs1) => (case+ loop (xs1) of ~Some_vt (ts2) => Some_vt (ts2) | ~None_vt () => Some_vt (tsub))'),
 # ---- the matching of the instances
 ('tmpcst_match: the continuation', E, 'if tmpcstmat_is_TMPCSTMATnone(opt)\n  then auxlst(xs, d2c0, t2mas) else opt', 'if tmpcstmat_is_TMPCSTMATnone(opt)\n  then opt else auxlst(xs, d2c0, t2mas)'),
 ('tmpcst_match: the kind of the local instance', E, '      (imp, d2c0, t2mas, 0(*local*))', '      (imp, d2c0, t2mas, 1(*local*))'),
 ('tmpcst_match: the kind of the staload', E, 'hiimpdeclst_tmpcst_match (implst, d2c0, t2mas, 1(*staload*))', 'hiimpdeclst_tmpcst_match (implst, d2c0, t2mas, 0(*staload*))'),
 ('tmpcst_match: the pervasive file', E, '    | ~GOnone ((*void*)) => auxlst (xs1, d2c0, t2mas)', '    | ~GOnone ((*void*)) => tmpcstmat_TMPCSTMATnone ()'),
 ('tmpvar_match: the continuation', E, 'if tmpvarmat_is_TMPVARMATnone(opt)\n  then auxlst (xs, d2v0, t2mas) else opt', 'if tmpvarmat_is_TMPVARMATnone(opt)\n  then opt else auxlst (xs, d2v0, t2mas)'),
 ('tmpvar_match: the staload', E, 'val hfdopt = tmpvardecmap_find (map, d2v0)', 'val hfdopt = None_vt ()'),
 # ---- the free variables of the templates
 ('get_tempenver: the order', E, '  list_vt_reverse<d2var>(d2vs)\nend // end of [ccompenv_get_tempenver]', '  d2vs\nend // end of [ccompenv_get_tempenver]'),
 ('add_tempenver: the flag is not set', E, 'val () = theFlag_set()\n//\nval+ @CCOMPENV (p) = env', '//\nval+ @CCOMPENV (p) = env'),
 ('dvarsetenv_add_tempenver: no variables', E, '  auxlst(d2es, d2vs)\nend // end of [ccompenv_dvarsetenv_add_tempenver]', '  (list_vt_free (d2vs); d2es)\nend // end of [ccompenv_dvarsetenv_add_tempenver]'),
 ('the_toplevel_getref: swapped', E, 'the_toplevel_getref_tmpvarlst\n  ((*void*)) = $UN.cast{Ptr1}(the_tmplst)', 'the_toplevel_getref_tmpvarlst\n  ((*void*)) = $UN.cast{Ptr1}(the_pmdlst)'),
 ('ccompenv_make: no toplevel flabset', E, 'val () = ccompenv_inc_flabsetenv(env) // toplevel flabs', 'val () = () // toplevel flabs'),
 # ---- pats_ccomp_environ.dats
 ('auxtrclo (flablst): the level', V, 'if flvl >= flvl0 then let\n      val\n      ismem', 'if flvl > flvl0 then let\n      val\n      ismem'),
 ('funent_eval_flablst: the function itself', V, '    val res = funlabset_vt_add(res, fl0)\n    val res = auxtrclo(flvl, xs0, xss, res)', '    val res = auxtrclo(flvl, xs0, xss, res)'),
 ('funent_eval_flablst: not remembered', V, 'val ((*void*)) = funent_set_flablst_fin(fent, gopt_some<funlablst>(fls))', 'val ((*void*)) = ()'),
 ('funent_eval_d2envlst: not remembered', V, 'val ((*void*)) = funent_set_d2envlst_fin (fent, gopt_some<d2envlst>(d2es))', 'val ((*void*)) = ()'),
 ('aux_funlab_get_d2envlst: the final list', V, '| ~GOsome(d2es) => d2es\n| ~GOnone((*void*)) =>\n    funent_get_d2envlst (fent) (* HX-2013-10-09: error? *)', '| ~GOsome(d2es) => funent_get_d2envlst (fent)\n| ~GOnone((*void*)) =>\n    funent_get_d2envlst (fent) (* HX-2013-10-09: error? *)'),
 ('auxd2es: the set', V, '    val res = d2envset_vt_add (res, d2e)\n  in\n    auxd2es', '    val res = res\n  in\n    auxd2es'),
 ('funlab_is_envful: the test', V, '  glist_is_cons (d2es)\nend // end of [funlab_is_envful]', '  glist_is_nil (d2es)\nend // end of [funlab_is_envful]'),
 ('funlab_get_type_fullarg: the order', V, '    glist_cons<hisexp>(hse, aux (d2es, hses))', '    aux (d2es, glist_cons<hisexp>(hse, hses))'),
 ('funent_varbindmap_initize: the index', V, 'auxenv (map, loc0, i+1, d2es)', 'auxenv (map, loc0, i+2, d2es)'),
 ('funent_varbindmap_initize: the map is not used', V, 'val () = auxmap (map, d2varmap_listize<primval> (vbmap))', 'val () = auxmap (map, list_vt_nil ())'),
 ('funent_varbindmap_initize2: the first function', V, '| ~GLcons (_, fls) => auxlst (fls)', '| ~GLcons (_, fls) => auxlst (glist_nil ())'),
 ('funent_varbindmap_initize2: only the first', V, '    val ((*void*)) =\n    (\n      case+ gopt_view(opt) of\n      | ~GOnone () => ()\n      | ~GOsome (fent) =>\n          funent_varbindmap_initize (fent)\n        // end of [Some]\n    ) : void // end of [val]\n  in\n    auxlst (fls)', '    val ((*void*)) =\n    (\n      case+ gopt_view(opt) of\n      | ~GOnone () => ()\n      | ~GOsome (fent) =>\n          funent_varbindmap_initize (fent)\n        // end of [Some]\n    ) : void // end of [val]\n  in\n    auxlst (glist_nil ())'),
 ('funent_varbindmap_uninitize: not emptied', V, 'val () = vbmap_put (d2varmap_vt_nil<primval> ())\n//\nin', 'val () = vbmap_put (vbmap_take ())\n//\nin'),
 # ---- caseof
 ('case: the failure of case+', C, '| CK_case_pos() => patckont_PTCKNTnone()', '| CK_case_pos() => patckont_PTCKNTcaseof_fail(loc0)'),
 ('case: the failure of case-', C, '| CK_case_neg() => patckont_PTCKNTcaseof_fail(loc0)', '| CK_case_neg() => patckont_PTCKNTnone()'),
 ('case: the level', C, 'val lvl0 = the_d2varlev_get((*void*))', 'val lvl0 = 0'),
 ('case: the order of the evaluation of the arguments', C, '    val pmv = hidexp_ccompv(env, res, hde)\n    val pmvs = hidexplst_ccompv_caseof(env, res, hdes)', '    val pmvs = hidexplst_ccompv_caseof(env, res, hdes)\n    val pmv = hidexp_ccompv(env, res, hde)'),
 ('case: the arguments are not compiled', C, 'val pmvs = hidexplst_ccompv_caseof(env, res, hdes)\n//\nval fail', 'val pmvs = glist_nil ()\n//\nval fail'),
 # ---- looping
 ('loop: the continue label', P, 'if gopt_is_some (post)\n  then tmplab_make (loc0) else tlab_init', 'if gopt_is_none (post)\n  then tmplab_make (loc0) else tlab_init'),
 ('loop: the order of the labels', P, 'val tlab_init = tmplab_make (loc0)\nval tlab_fini = tmplab_make (loc0)', 'val tlab_fini = tmplab_make (loc0)\nval tlab_init = tmplab_make (loc0)'),
 ('loop: the environment of the loop is not left', P, 'val () = ccompenv_dec_loopexnenv (env)', 'val () = ()'),
 ('loop: the post is compiled before the test', P, 'val res_test = instrseq_make_nil ()\nval pmv_test = hidexp_ccomp (env, res_test, test)\nval res_test = instrseq_get_free (res_test)\n//\nval res_post =', 'val res_test = instrseq_make_nil ()\nval pmv_test = primval_empty (loc0, hse0)\nval res_test = instrseq_get_free (res_test)\n//\nval res_post ='),
 ('loop: the init after the labels', P, 'val res_init =\n(\ncase+ gopt_view(init) of', 'val tlab_init = tmplab_make (loc0)\nval res_init =\n(\ncase+ gopt_view(init) of'),
 ('loopexn: the labels', P, 'if knd = 0\n  then ccompenv_get_loopfini (env)\n  else ccompenv_get_loopcont (env)', 'if knd = 0\n  then ccompenv_get_loopcont (env)\n  else ccompenv_get_loopfini (env)'),
 ('loopexn: the kind', P, 'val ins_lpxn = instr_loopexn (loc0, knd, tlab)', 'val ins_lpxn = instr_loopexn (loc0, 1-knd, tlab)'),
 # ---- trywith
 ('trywith: the tail calls are not restored', Y, 'val () = $GLOBAL.the_CCOMPATS_tlcalopt_set(f0)', 'val () = $GLOBAL.the_CCOMPATS_tlcalopt_set(0)'),
 ('trywith: the tail calls are not disabled', Y, 'val () = $GLOBAL.the_CCOMPATS_tlcalopt_set(0)\n//\nval () = hidexp_ccomp_ret(env, res_try, tmpret, hde_try)', 'val () = ()\n//\nval () = hidexp_ccomp_ret(env, res_try, tmpret, hde_try)'),
 ('trywith: the level', Y, 'val lvl0 = the_d2varlev_get()', 'val lvl0 = 5'),
 ('trywith: the exception value', Y, 'env, lvl0, glist_sing(pmv_exn), hicls_with, tmpret, fail', 'env, lvl0, glist_nil(), hicls_with, tmpret, fail'),
 ('trywith: the failure of the clauses', Y, '  patckont_PTCKNTraise(tmpret, pmv_exn)', '  patckont_PTCKNTnone()'),
 ('trywith: the temporary of the exception is created late', Y, 'val tmp_exn = tmpvar_make(loc0, hse_exn)\nval pmv_exn = primval_make_tmp(loc0, tmp_exn)\n//\nval res_try = instrseq_make_nil()', 'val res_try = instrseq_make_nil()\nval tmp_exn = tmpvar_make(loc0, hse_exn)\nval pmv_exn = primval_make_tmp(loc0, tmp_exn)\nval tmp_exn2 = tmpvar_make(loc0, hse_exn)'),
 ('trywith: no scope for the try', Y, 'val\n(pfpush | ()) = ccompenv_push(env)', 'val\n(pfpush | ()) = (let val (pf | ()) = ccompenv_push(env) val () = ccompenv_pop (pf | env) in ccompenv_push(env) end)'),
 # ---- lazyeval
 ('delay: the kind of the template function', Z, 'val tmplev = ccompenv_get_tmplevel (env)\nval () = if tmplev > 0 then funlab_set_tmpknd (flab, 1)\n//\nval fent = let\n  val imparg = glist_nil((*s2vs*))\n  val tmparg = glist_nil((*s2ess*))\n  val ins = instr_funlab (loc0, flab)\n  val prolog = glist_sing (ins)\nin\n//\nhidexp_ccomp_funlab_arg_body\n  (env, flab, imparg, tmparg, prolog, loc0, glist_nil(), hde)', 'val tmplev = ccompenv_get_tmplevel (env)\nval () = if tmplev >= 0 then funlab_set_tmpknd (flab, 1)\n//\nval fent = let\n  val imparg = glist_nil((*s2vs*))\n  val tmparg = glist_nil((*s2ess*))\n  val ins = instr_funlab (loc0, flab)\n  val prolog = glist_sing (ins)\nin\n//\nhidexp_ccomp_funlab_arg_body\n  (env, flab, imparg, tmparg, prolog, loc0, glist_nil(), hde)'),
 ('delay: the linearity', Z, 'instr_move_delay(loc0, tmpret, 0(*lin*), hse_res, pmv0_tk)', 'instr_move_delay(loc0, tmpret, 1(*lin*), hse_res, pmv0_tk)'),
 ('delay: the closure kind', Z, 'hisexp_fun (FUNCLOclo(~1), glist_nil(), hse_res)', 'hisexp_fun (FUNCLOclo(0), glist_nil(), hse_res)'),
 ('delay: no tail call frame', Z, 'val () = ccompenv_inc_tailcalenv (env, flab)\n//\nval tmplev = ccompenv_get_tmplevel (env)\nval () = if tmplev > 0 then funlab_set_tmpknd (flab, 1)\n//\nval fent = let\n  val imparg = glist_nil((*s2vs*))\n  val tmparg = glist_nil((*s2ess*))\n  val ins = instr_funlab (loc0, flab)\n  val prolog = glist_sing (ins)\nin\n//\nhidexp_ccomp_funlab_arg_body\n  (env, flab, imparg, tmparg, prolog, loc0, glist_nil(), hde)', 'val tmplev = ccompenv_get_tmplevel (env)\nval () = if tmplev > 0 then funlab_set_tmpknd (flab, 1)\n//\nval fent = let\n  val imparg = glist_nil((*s2vs*))\n  val tmparg = glist_nil((*s2ess*))\n  val ins = instr_funlab (loc0, flab)\n  val prolog = glist_sing (ins)\nin\n//\nhidexp_ccomp_funlab_arg_body\n  (env, flab, imparg, tmparg, prolog, loc0, glist_nil(), hde)'),
 ('delay: the function is not registered', Z, 'val () = the_funlablst_add (flab)\nval () = ccompenv_add_flabsetenv (env, flab)\n//\nval () = ccompenv_inc_tailcalenv (env, flab)\n//\nval tmplev = ccompenv_get_tmplevel (env)\nval () = if tmplev > 0 then funlab_set_tmpknd (flab, 1)\n//\nval fent = let\n  val imparg = glist_nil((*s2vs*))\n  val tmparg = glist_nil((*s2ess*))\n  val ins = instr_funlab (loc0, flab)\n  val prolog = glist_sing (ins)\nin\n//\nhidexp_ccomp_funlab_arg_body\n  (env, flab, imparg, tmparg, prolog, loc0, glist_nil(), hde)', 'val () = ccompenv_add_flabsetenv (env, flab)\n//\nval () = ccompenv_inc_tailcalenv (env, flab)\n//\nval tmplev = ccompenv_get_tmplevel (env)\nval () = if tmplev > 0 then funlab_set_tmpknd (flab, 1)\n//\nval fent = let\n  val imparg = glist_nil((*s2vs*))\n  val tmparg = glist_nil((*s2ess*))\n  val ins = instr_funlab (loc0, flab)\n  val prolog = glist_sing (ins)\nin\n//\nhidexp_ccomp_funlab_arg_body\n  (env, flab, imparg, tmparg, prolog, loc0, glist_nil(), hde)'),
 ('ldelay: the closure kind', Z, 'hisexp_fun (FUNCLOclo(1), hses_arg, hse_res)', 'hisexp_fun (FUNCLOclo(0), hses_arg, hse_res)'),
 ('ldelay: the branches of the test', Z, 'val hde12_body = hidexp_if (loc0, hse_res, hde_flag, hde1, hde2)', 'val hde12_body = hidexp_if (loc0, hse_res, hde_flag, hde2, hde1)'),
 ('ldelay: the linearity', Z, 'instr_move_delay(loc0, tmpret, 1(*lin*), hse_res, pmv0_tk)', 'instr_move_delay(loc0, tmpret, 0(*lin*), hse_res, pmv0_tk)'),
 ('ldelay: the argument', Z, 'val hip_arg = hipat_var (loc0, hse_arg, d2v_flag)\nval hips_arg = glist_cons<hipat>(hip_arg, glist_nil())', 'val hip_arg = hipat_var (loc0, hse_arg, d2v_flag)\nval hips_arg = glist_nil()'),
 ('ldelay: the evaluation of the second branch', Z, 'val hde2 = hidexp_ignore (hde2.hidexp_loc(), hse_res, hde2)', 'val hde2 = hde2'),
 ('lazyeval: the linearity', Z, 'instr_move_lazyeval (loc0, tmpret, lin, hse0, pmv_lazy)', 'instr_move_lazyeval (loc0, tmpret, 1-lin, hse0, pmv_lazy)'),
 ('lazyeval: the type', Z, 'instr_move_lazyeval (loc0, tmpret, lin, hse0, pmv_lazy)', 'instr_move_lazyeval (loc0, tmpret, lin, hde_lazy.hidexp_type(), pmv_lazy)'),
]

def run(cmd, env=None, timeout=900):
    e = dict(os.environ); e.update(env or {})
    return subprocess.run(cmd, shell=True, env=e, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=timeout)

def main():
    MD = os.path.join(OUT, 'mut'); os.makedirs(MD, exist_ok=True)
    ref = open(os.path.join(OUT, 'o1.txt'), 'rb').read()
    refc = 0
    bad = []; n_ok = 0
    for k, (desc, f, old, new) in enumerate(M, 1):
        if SEL and k not in SEL: continue
        src = open(os.path.join(T, f)).read()
        if src.count(old) < 1:
            print('%3d  PATTERN NOT FOUND: %s' % (k, desc)); bad.append((k, desc, 'pattern')); continue
        mut = src.replace(old, new, 1)
        shutil.copy(os.path.join(T, f), os.path.join(MD, f + '.orig')) if False else None
        for g in ('pats_ccomp_ccompenv.dats', 'pats_ccomp_environ.dats', 'pats_ccomp_caseof.dats', 'pats_ccomp_looping.dats', 'pats_ccomp_trywith.dats', 'pats_ccomp_lazyeval.dats'):
            shutil.copy(os.path.join(T, g), os.path.join(MD, g))
        open(os.path.join(MD, f), 'w').write(mut)
        r = run('sh %s/cc1_2.sh %s' % (L, OUT), {'REUSE': '1', 'CC1_SRC': MD, 'CC1_ONLY': f[:-5]})
        if r.returncode != 0:
            print('%3d  does not compile: %s' % (k, desc)); bad.append((k, desc, 'compile'))
            continue
        try:
            r = run('%s/cc1_2' % OUT, timeout=300)
        except subprocess.TimeoutExpired:
            print('%3d  detected (timeout): %s' % (k, desc)); n_ok += 1; continue
        if r.returncode != refc or r.stdout != ref or r.stderr != b'':
            n_ok += 1; print('%3d  detected: %s' % (k, desc))
        else:
            print('%3d  NOT DETECTED: %s' % (k, desc)); bad.append((k, desc, 'undetected'))
    # restore the build of the real modules
    run('sh %s/cc1_2.sh %s' % (L, OUT), {'REUSE': '1', 'CC1_ONLY': 'pats_ccomp_ccompenv pats_ccomp_environ pats_ccomp_caseof pats_ccomp_looping pats_ccomp_trywith pats_ccomp_lazyeval'})
    print('mutations: %d detected of %d' % (n_ok, len([1 for k in range(1, len(M)+1) if not SEL or k in SEL])))
    for b in bad: print('  problem:', b)

main()
