#!/usr/bin/env python3
"""hdmutate.py OUTDIR REFERENCE.out [REFERENCE.err] [N...]   Mutation test of the ATS2 ports of pats_hidynexp{,_print,_util} and pats_typerase_*: for each deliberate bug
below the module is mutated, recompiled in the staging directory of hd2.sh (OUTDIR/stage2), relinked, run, and its stdout and stderr compared with the reference (the output of hd1,
the ATS1 build). With numbers: only those mutations."""
import sys, os, shutil, subprocess, tempfile
OUT = os.path.abspath(sys.argv[1]); REF = os.path.abspath(sys.argv[2])
REFERR = os.path.abspath(sys.argv[3]) if len(sys.argv) > 3 and not sys.argv[3].isdigit() else None
SEL = [int(a) for a in sys.argv[3:] if a.isdigit()] if REFERR is None else [int(a) for a in sys.argv[4:] if a.isdigit()]
W = os.path.join(OUT, 'stage2')
H = 'pats_hidynexp.dats'; HP = 'pats_hidynexp_print.dats'; HU = 'pats_hidynexp_util.dats'
TE = 'pats_typerase_error.dats'; TS = 'pats_typerase_staexp.dats'; TD = 'pats_typerase_dynexp.dats'; TC = 'pats_typerase_decl.dats'
M = [
 # ---- pats_hidynexp.dats
 ('hipat_lst: the kind of the constructors', H, 'if lin = 0 then PCKcon() else PCKfree()', 'if lin = 0 then PCKfree() else PCKcon()'),
 ('hipat_lst: the label of the tail', H, 'val l1 = $LAB.label_make_int (1)', 'val l1 = $LAB.label_make_int (2)'),
 ('hipat_lst: the nil constructor', H, 'else hipat_con_any (loc, hse_lst, pck, d2c_nil)', 'else hipat_con_any (loc, hse_lst, pck, d2c_cons)'),
 ('hipat_rec2: the kind that is flat', H, '''val isflt =
  (if knd = 0 then true else false): bool
//
in
//
if
isflt
then (
if glist_is_cons (lhips)''', '''val isflt =
  (if knd = 1 then true else false): bool
//
in
//
if
isflt
then (
if glist_is_cons (lhips)'''),
 ('hipat_rec2: the singleton', H, 'if glist_is_cons (lhips) andalso glist_is_nil (glist_tail<labhipat> (lhips))', 'if glist_is_cons (lhips) andalso glist_is_cons (glist_tail<labhipat> (lhips))'),
 ('hidexp_rec2: the singleton', H, 'if glist_is_cons (lhdes) andalso glist_is_nil (glist_tail<labhidexp> (lhdes))', 'if glist_is_cons (lhdes) andalso glist_is_nil (lhdes)'),
 ('hidexp_app2: castfn test', H, '    $D2E.d2cst_is_castfn (d2c)\n  end else false', '    not($D2E.d2cst_is_castfn (d2c))\n  end else false'),
 ('hidexp_app2: the empty argument', H, 'hidexp_empty (loc, hisexp_void_t0ype())', 'hidexp_empty (loc, hisexp_tybox)'),
 ('labhipatlst_is_unused: wildcard only', H, 'if hipat_node_is_HIPany (hip.hipat_node())', 'if hipat_node_is_HIPvar (hip.hipat_node())'),
 ('hifundec_getref_hideclopt: the offset', H, 'i2sz(32)', 'i2sz(40)'),
 ('hiimpdec_getref_instrlstopt: the offset', H, 'i2sz(56)', 'i2sz(48)'),
 ('hiimpdec_getref_funlabopt: the offset', H, 'hiimpdec_getref_funlabopt (imp) =\n  $UN.cast{Ptr1} (ptr0_add_guint<byte> ($UN.cast{ptr} (imp), i2sz(48)))', 'hiimpdec_getref_funlabopt (imp) =\n  $UN.cast{Ptr1} (ptr0_add_guint<byte> ($UN.cast{ptr} (imp), i2sz(40)))'),
 ('tmpcstimpmap_insert: the list of instances', H, 'glist_cons (imp, imps))', 'glist_cons (imp, glist_nil ()))'),
 ('tmpvardecmap_inserts: the first element', H, '  val () = tmpvardecmap_insert (map, hfd)\nin\n  tmpvardecmap_inserts', '  val () = ()\nin\n  tmpvardecmap_inserts'),
 ('hifundeclst_set_hideclopt: only the first', H, '    auxlst (glist_tail<hifundec> (hfds), opt)', '    auxlst (glist_nil (), opt)'),
 ('hipat_set_asvar: no effect', H, 'hipat_set_asvar (hip, opt) = set_hipat_asvar (hip, opt)', 'hipat_set_asvar (hip, opt) = ()'),
 ('hidexplst_get_type: the order', H, 'then glist_cons (hidexp_get_type (glist_head<hidexp> (hdes)), hidexplst_get_type (glist_tail<hidexp> (hdes)))', 'then glist_append (hidexplst_get_type (glist_tail<hidexp> (hdes)), glist_sing (hidexp_get_type (glist_head<hidexp> (hdes))))'),
 ('hilab_ind: a label', H, 'hilab_ind (loc, ind) = hilab_new (loc, hilab_node_HILind (ind))', 'hilab_ind (loc, ind) = hilab_new (loc, hilab_node_HILind (glist_nil ()))'),
 ('hiimpdec_make: the kind', H, '  (loc, knd, d2c, imparg, tmparg, def, gopt_none (), gopt_none ())', '  (loc, 1-knd, d2c, imparg, tmparg, def, gopt_none (), gopt_none ())'),
 # ---- pats_hidynexp_print.dats
 ('print: the name of HDEif', HP, 'val () = prstr "HDEif("', 'val () = prstr "HDEIf("'),
 ('print: the newline of the list of declarations', HP, '  val () = fprint_newline (out)\nin\n  fprint_hideclist', '  val () = ()\nin\n  fprint_hideclist'),
 ('print: the trywith', HP, 'val () = fprint_string (out, "...")', 'val () = fprint_string (out, "..")'),
 ('print: the loop', HP, 'prstr "HDEloop(...)"', 'prstr "HDEloop()"'),
 ('print: the code of an external declaration', HP, 'val () = fprint_string (out, ", pos=")', 'val () = fprint_string (out, ",pos=")'),
 ('print: the arguments of HDEcase', HP, 'val () = $UT.fprintlst<hiclau> (out, hcls, "\\n", fprint_hiclau)', 'val () = $UT.fprintlst<hiclau> (out, hcls, ";", fprint_hiclau)'),
 ('print: the separator of the expressions', HP, '$UT.fprintlst<hidexp> (out, xs, "; ", fprint_hidexp)', '$UT.fprintlst<hidexp> (out, xs, ", ", fprint_hidexp)'),
 ('print: a variable declaration', HP, 'val () = prstr " : "\n  val () = fprint_hisexp (out, hvd.hivardec_type())', 'val () = prstr " :: "\n  val () = fprint_hisexp (out, hvd.hivardec_type())'),
 ('print: HIPrec', HP, 'val () = (fprint_string (out, "knd= "); fprint_int (out, knd))\n    val () = prstr "; "\n    val () = fprint_labhipatlst', 'val () = (fprint_string (out, "knd= "); fprint_int (out, 1-knd))\n    val () = prstr "; "\n    val () = fprint_labhipatlst'),
 # ---- pats_hidynexp_util.dats
 ('is_wild: refas', HU, '''end else if hipat_node_is_HIPrefas (nd) then let
  val-~HIPrefas (_, hip) = hipat_node_view (nd) in hipat_is_wild (hip)
end else false''', '''end else if hipat_node_is_HIPrefas (nd) then let
  val-~HIPrefas (_, hip) = hipat_node_view (nd) in false
end else false'''),
 ('subtest: a constructor against an unused one', HU, '    if d2c1 = d2c2 then labhipatlst_is_wild (lxs2) else false', '    if d2c1 = d2c2 then true else false'),
 ('subtest: integers', HU, 'val-~HIPint (i2) = hipat_node_view (hipn2) in i1 = i2', 'val-~HIPint (i2) = hipat_node_view (hipn2) in i1 <= i2'),
 ('subtest: strings', HU, 'val-~HIPstring (str2) = hipat_node_view (hipn2) in str1 = str2', 'val-~HIPstring (str2) = hipat_node_view (hipn2) in true'),
 ('subtest: labels of records', HU, '  if l1 = l2 then hipat_subtest (x1, x2) else false', '  if true then hipat_subtest (x1, x2) else false'),
 ('subtest: the lists of different lengths', HU, '''  if glist_is_cons (xs2) then false else true
)
//
end // end of [hipatlst_subtest]''', '''  true
)
//
end // end of [hipatlst_subtest]'''),
 ('is_value: lam', HU, 'else if hidexp_node_is_HDElam (nd) then true', 'else if hidexp_node_is_HDElam (nd) then false'),
 ('is_value: let', HU, '  if hideclist_is_value(hids) then hidexp_is_value(hde) else false', '  if hideclist_is_value(hids) then true else false'),
 ('is_lvalue: selptr', HU, 'else if hidexp_node_is_HDEselptr (nd) then true', 'else if hidexp_node_is_HDEselptr (nd) then false'),
 ('is_lvalue: sequences', HU, '    then auxseq (glist_head<hidexp> (hdes), glist_tail<hidexp> (hdes)) else false', '    then hidexp_is_lvalue (glist_head<hidexp> (hdes)) else false'),
 ('is_empty: foldat', HU, 'else if hidexp_node_is_HDEfoldat (nd) then true', 'else if hidexp_node_is_HDEfoldat (nd) then false'),
 ('seq_simplify: the filter', HU, '    if isemp then xs1 else glist_cons (x, xs1)', '    if isemp then glist_cons (x, xs1) else xs1'),
 ('let_simplify: the variable of the declaration', HU, '            if not(d2v=d2v2)\n              then hidexp_let', '            if (d2v=d2v2)\n              then hidexp_let'),
 ('let_simplify: dropz', HU, '  then glist_cons (x, dropz (xs1)) else glist_nil ()', '  then glist_nil () else glist_nil ()'),
 ('hidecl_is_empty: valdecs_rec', HU, '''end else if hidecl_node_is_HIDvaldecs_rec (nd) then let
  val-~HIDvaldecs_rec (_, xs) = hidecl_node_view (nd) in glist_is_nil (xs)''', '''end else if hidecl_node_is_HIDvaldecs_rec (nd) then let
  val-~HIDvaldecs_rec (_, xs) = hidecl_node_view (nd) in false'''),
 ('hidecl_is_value: fundecs', HU, 'else if hidecl_node_is_HIDfundecs (nd) then true', 'else if hidecl_node_is_HIDfundecs (nd) then false'),
 ('d2cst_get2_funclo: no funclo', HU, '  | ~HSEfun (fc, _, _) => Some_vt (fc)\n  | v => (hisexp_node_view_free (v); None_vt ())\nend else None_vt ()\n//\nend // end of [d2cst_get2_funclo]', '  | ~HSEfun (fc, _, _) => None_vt ()\n  | v => (hisexp_node_view_free (v); None_vt ())\nend else None_vt ()\n//\nend // end of [d2cst_get2_funclo]'),
 ('d2cst_is_fun: a function', HU, 'case+ fc of FUNCLOfun () => true | _ => false\n  ) // end of [HSEfun]', 'case+ fc of FUNCLOfun () => false | _ => false\n  ) // end of [HSEfun]'),
 # ---- pats_typerase_staexp.dats
 ('s2cst_tyer: a constant', TS, '  end else hisexp_cst (s2c) // end of [None]', '  end else hisexp_tybox // end of [None]'),
 ('s2hnf_tyer: a variable', TS, '| ~S2Evar(s2v) => hisexp_tyvar(s2v)', '| ~S2Evar(s2v) => hisexp_tybox'),
 ('s2hnf_tyer: the existential variable', TS, '  s2zexp_tyer(loc0, s2Var_get_szexp(s2V))', '  hisexp_tybox'),
 ('s2hnf_tyer: refarg', TS, 's2exp_tyer_shallow(loc0, s2e) in hisexp_refarg(knd, hse)', 's2exp_tyer_deep(loc0, s2e) in hisexp_refarg(knd, hse)'),
 ('s2exp_tyer_fun: the flag', TS, 'if\nflag > 0\nthen let\n//\nval\nhses_arg =', 'if\nflag > 1\nthen let\n//\nval\nhses_arg ='),
 ('s2exp_tyer_fun: the closure', TS, 'if funclo_get_clokind (fc) = 0 then hisexp_clotyp else hisexp_cloptr', 'if funclo_get_clokind (fc) = 0 then hisexp_cloptr else hisexp_clotyp'),
 ('s2exp_tyer_datcontyp: the sum', TS, '  hisexp_tysum (d2c, lhses)\nend else hisexp_datcontyp', '  hisexp_datcontyp\nend else hisexp_datcontyp'),
 ('s2exp_tyer_tyrec: the flag of boxes', TS, '    if flag > 0 then\n      hisexp_tyrec (knd, lhses) else hisexp_tybox', '    if flag > 0 then\n      hisexp_tybox else hisexp_tyrec (knd, lhses)'),
 ('s2exp_tyer_tyrec: the external records', TS, '  ) // end of [TYRECKINDbox]\nelse if tyreckind_is_TYRECKINDflt_ext (knd) then hisexp_tyrec (knd, lhses)\nelse ( (* TYRECKINDflt0/1 *)\n  if glist_is_cons (lhses) andalso glist_is_nil (glist_tail<labhisexp> (lhses))\n    then hisexp_tyrecsin (glist_head<labhisexp> (lhses))', '  ) // end of [TYRECKINDbox]\nelse if tyreckind_is_TYRECKINDflt_ext (knd) then hisexp_tybox\nelse ( (* TYRECKINDflt0/1 *)\n  if glist_is_cons (lhses) andalso glist_is_nil (glist_tail<labhisexp> (lhses))\n    then hisexp_tyrecsin (glist_head<labhisexp> (lhses))'),
 ('s2exp_tyer_tyrec: the singleton', TS, '  ) // end of [TYRECKINDbox]\nelse if tyreckind_is_TYRECKINDflt_ext (knd) then hisexp_tyrec (knd, lhses)\nelse ( (* TYRECKINDflt0/1 *)\n  if glist_is_cons (lhses) andalso glist_is_nil (glist_tail<labhisexp> (lhses))\n    then hisexp_tyrecsin (glist_head<labhisexp> (lhses))', '  ) // end of [TYRECKINDbox]\nelse if tyreckind_is_TYRECKINDflt_ext (knd) then hisexp_tyrec (knd, lhses)\nelse ( (* TYRECKINDflt0/1 *)\n  if glist_is_cons (lhses) andalso glist_is_nil (glist_tail<labhisexp> (lhses))\n    then hisexp_tyrec (knd, lhses)'),
 ('s2explst_tyer_arglst: tkind', TS, '      if keep then true else s2rt_is_tkind (s2t)', '      if keep then true else false'),
 ('s2explst_tyer: proofs', TS, '    if isprf then\n      s2explst_tyer (loc0, s2es)\n    else let', '    if not(isprf) then\n      s2explst_tyer (loc0, s2es)\n    else let'),
 ('labize: the index after a proof', TS, '      s2explst_npf_tyer_labize_aux (loc0, npf, s2es, i+1)  \n    else let', '      s2explst_npf_tyer_labize_aux (loc0, npf, s2es, i)  \n    else let'),
 ('labs2explst_tyer: the name', TS, '      val lhse = labhisexp_new (l, name, hse)', '      val lhse = labhisexp_new (l, gopt_none (), hse)'),
 ('s2exp_tyer_appcst: no definition', TS, '  hisexp_make_srt (s2t0)\nelse let', '  hisexp_tybox\nelse let'),
 ('s2exp_tyer_app2: the substitution', TS, '  val s2e_body = s2exp_subst (sub, s2e_body)', '  val s2e_body = s2e_body'),
 ('s2zexp_tyer: the pointer size', TS, '| ~S2ZEptr () => hisexp_tybox', '| ~S2ZEptr () => hisexp_undefined'),
 ('s2zexp_tyer: the existential variable', TS, '| ~S2ZEVar (s2V) => hisexp_undefined', '| ~S2ZEVar (s2V) => hisexp_tybox'),
 ('s2zexp_tyer_tyrec: boxes', TS, 'if tyreckind_is_TYRECKINDbox (knd) then hisexp_tybox\nelse if tyreckind_is_TYRECKINDflt_ext (knd) then hisexp_tyrec (knd, lhses)\nelse ( (* TYRECKINDflt0/1 *)\n  if glist_is_cons (lhses) andalso glist_is_nil (glist_tail<labhisexp> (lhses))\n    then hisexp_tyrecsin (glist_head<labhisexp> (lhses))\n    else hisexp_tyrec (knd, lhses) (* non-sing *)\n) // end of [TYRECKINDflt0/1]\n//\nend // end of [s2exp_tyer_tyrec]\n\n(* ****** ****** *)\n\nimplement\nlabs2zexplst_tyer', 'if tyreckind_is_TYRECKINDbox (knd) then hisexp_tyrec (knd, lhses)\nelse if tyreckind_is_TYRECKINDflt_ext (knd) then hisexp_tyrec (knd, lhses)\nelse ( (* TYRECKINDflt0/1 *)\n  if glist_is_cons (lhses) andalso glist_is_nil (glist_tail<labhisexp> (lhses))\n    then hisexp_tyrecsin (glist_head<labhisexp> (lhses))\n    else hisexp_tyrec (knd, lhses) (* non-sing *)\n) // end of [TYRECKINDflt0/1]\n//\nend // end of [s2exp_tyer_tyrec]\n\n(* ****** ****** *)\n\nimplement\nlabs2zexplst_tyer'),
 ('s2zexplst_tyer_arglst: proofs', TS, '    if s2zexp_is_S2ZEprf (s2ze) then\n      s2zexplst_tyer_arglst (loc0, s2zes)', '    if not(s2zexp_is_S2ZEprf (s2ze)) then\n      s2zexplst_tyer_arglst (loc0, s2zes)'),
 ('labs2zexplst_tyer: proofs', TS, '    if s2zexp_is_S2ZEprf (s2ze) then\n        labs2zexplst_tyer (loc0, ls2zes)', '    if not(s2zexp_is_S2ZEprf (s2ze)) then\n        labs2zexplst_tyer (loc0, ls2zes)'),
 ('t2mpmarg_tyer: shallow types', TS, '    val hse =\n      s2exp_tyer_shallow (loc0, s2e)\n    // end of [val]\n  in\n    glist_cons (hse, t2mpmarg_tyer_aux', '    val hse =\n      s2exp_tyer_deep (loc0, s2e)\n    // end of [val]\n  in\n    glist_cons (hse, t2mpmarg_tyer_aux'),
 ('t2mpmarg_mhnfize: the location', TS, '  t2mpmarg_make (loc, s2es)', '  t2mpmarg_make ($LOC.location_dummy, s2es)'),
 # ---- pats_typerase_dynexp.dats
 ('d2var_tyer: the type is recorded', TD, '    val ((*void*)) = d2var_set2_hisexp (d2v, gopt_some (hse))', '    val ((*void*)) = ()'),
 ('d2cst_tyer: the type is recorded', TD, '    val ((*void*)) = d2cst_set2_hisexp (d2c, gopt_some (hse))', '    val ((*void*)) = ()'),
 ('p3at_tyer: the kind of the record', TD, '      if knd > 0\n        then tyreckind_TYRECKINDbox() else tyreckind_TYRECKINDflt0()', '      if knd > 0\n        then tyreckind_TYRECKINDflt0() else tyreckind_TYRECKINDbox()'),
 ('p3at_tyer_con: the unused arguments', TD, 'if test then\n    hipat_con_any(loc0, hse0, pck, d2c)', 'if not(test) then\n    hipat_con_any(loc0, hse0, pck, d2c)'),
 ('p3at_tyer: existential', TD, '    (s2vs, p3t_scoop) => p3at_tyer(p3t_scoop)', '    (s2vs, p3t_scoop) => hipat_any (loc0, hse0, d2var_make_any (loc0))'),
 ('auxerr_if: partial proofs', TD, 'if\nnot(isful)\nthen let', 'if\nisful\nthen let'),
 ('p3atlst_tyer: proofs', TD, '    if isprf\n      then let\n        val () = auxerr_if(p3t) in p3atlst_tyer(p3ts)', '    if not(isprf)\n      then let\n        val () = auxerr_if(p3t) in p3atlst_tyer(p3ts)'),
 ('p3atlst_tyer2: proofs of the values', TD, '      if isprf then true else d3exp_is_prf(d3e)', '      if isprf then true else false'),
 ('d3exp_tyer: a variable counts a use', TD, '| ~D3Evar (d2v) => let\n    val () =\n      d2var_inc_utimes (d2v)', '| ~D3Evar (d2v) => let\n    val () = ()'),
 ('d3exp_tyer: the application type', TD, '    val hse_fun = s2exp_tyer_deep (loc0, s2e_fun)\n    val hde_fun = d3exp_tyer (d3e_fun)', '    val hse_fun = s2exp_tyer_shallow (loc0, s2e_fun)\n    val hde_fun = d3exp_tyer (d3e_fun)'),
 ('d3exp_tyer: boxed lambdas', TD, 'hidexp_lam (loc0, hse_fun, 1(*boxed*), hips_arg, hde_body)', 'hidexp_lam (loc0, hse_fun, 0(*boxed*), hips_arg, hde_body)'),
 ('d3exp_tyer: ifcase', TD, '  if knd > 0\n    then (\n      d3exp_tyer(x0.i3fcl_body ())', '  if knd = 0\n    then (\n      d3exp_tyer(x0.i3fcl_body ())'),
 ('d3exp_tyer: a proof assignment', TD, '    if d3exp_is_prf (d3e_r) then hidexp_empty (loc0, hse0)\n    else let\n    val () = d2var_inc_utimes (d2v_l)', '    if not(d3exp_is_prf (d3e_r)) then hidexp_empty (loc0, hse0)\n    else let\n    val () = d2var_inc_utimes (d2v_l)'),
 ('d3exp_tyer: vcopyenv counts a use', TD, '// HX: hidexp_vcopyenv = hidexp_var\n//\n    val () =\n      d2var_inc_utimes (d2v)', '// HX: hidexp_vcopyenv = hidexp_var\n//\n    val () = ()'),
 ('d3exp_tyer: the type of a tuple', TD, '    val hse_rec =\n       s2exp_tyer_deep (loc0, s2e0)\n    // end of [val]\n    val lhdes =\n      d3explst_npf_tyer_labize (npf, d3es)', '    val hse_rec =\n       s2exp_tyer_shallow (loc0, s2e0)\n    // end of [val]\n    val lhdes =\n      d3explst_npf_tyer_labize (npf, d3es)'),
 ('d3exp_tyer: the first index', TD, 'val i0 = (if npf >= 0 then npf else 0): int', 'val i0 = 0'),
 ('d3exp_tyer_cst: true', TD, '    hidexp_bool (loc0, hse0, true)\nelse if sym =', '    hidexp_bool (loc0, hse0, false)\nelse if sym ='),
 ('d3exp_tyer: array initialization size', TD, '| ~None_vt() => ~1', '| ~None_vt() => 0'),
 ('d3exp_tyer: the let simplifier', TD, '    hidexp_let_simplify (loc0, hse0, hids, hde_scope)', '    hidexp_let (loc0, hse0, hids, hde_scope)'),
 ('d3exp_tyer: the sequence simplifier', TD, '    hidexp_seq_simplify(loc0, hse0, hdes)', '    hidexp_seq (loc0, hse0, hdes)'),
 ('d3exp_tyer: sel_ref', TD, '    hidexp_selptr (loc0, hse0, hde, hse_rt, hils)\n  end // end of [D3Esel_ref]', '    hidexp_selvar (loc0, hse0, d2var_make_any (loc0), hse_rt, hils)\n  end // end of [D3Esel_ref]'),
 ('gm3at_tyer: the pattern', TD, '      then gopt_some (p3at_tyer (gopt_unsome (p3to))) else gopt_none ((*void*))', '      then gopt_none ((*void*)) else gopt_none ((*void*))'),
 ('c3lau_tyer2: the sequentiality', TD, '  hiclau_make (loc, hips, gua, seq, neg, body)\nend // end of [c3lau_tyer2]', '  hiclau_make (loc, hips, gua, neg, seq, body)\nend // end of [c3lau_tyer2]'),
 ('labd3explst_tyer: proofs', TD, '    if d3exp_is_prf (x) then\n      labd3explst_tyer (lxs)', '    if not(d3exp_is_prf (x)) then\n      labd3explst_tyer (lxs)'),
 ('d3explst_tyer: proofs', TD, '    if isprf then\n      d3explst_tyer (d3es)', '    if not(isprf) then\n      d3explst_tyer (d3es)'),
 # ---- pats_typerase_decl.dats / error.dats
 ('d3ecl_tyer_impdec: the kind', TC, '\nif\nknd >= 0\nthen let', '\nif\nknd > 0\nthen let'),
 ('f3undeclst_tyer: proofs are erased', TC, 'if\nisprf\nthen glist_nil ((*void*)) // proofs are erased\nelse let\n  val imparg', 'if\nnot(isprf)\nthen glist_nil ((*void*)) // proofs are erased\nelse let\n  val imparg'),
 ('v3aldeclst_tyer: proofs are erased', TC, 'if isprf then\n  glist_nil ((*void*)) // proofs are erased\nelse v3aldeclst_tyer_map', 'if not(isprf) then\n  glist_nil ((*void*)) // proofs are erased\nelse v3aldeclst_tyer_map'),
 ('d3ecl_tyer_fundecs: the declaration of the functions', TC, 'val () = hifundeclst_set_hideclopt (hfds, gopt_some (hdc0))', 'val () = ()'),
 ('tmpcstimpmap_make_hideclist: only the instances with template arguments', TC, '    if glist_is_cons (tmparg) then tmpcstimpmap_insert (map, imp) else ()', '    if glist_is_nil (tmparg) then tmpcstimpmap_insert (map, imp) else ()'),
 ('tmpvardecmap_make_hideclist: only the templates', TC, '    if glist_is_cons (s2qs) then tmpvardecmap_inserts (map, hfds) else ()', '    if glist_is_nil (s2qs) then tmpvardecmap_inserts (map, hfds) else ()'),
 ('d3ecl_tyer: the loaded flag', TC, '      if (loaded = 0) then let', '      if (loaded = 1) then let'),
 ('d3eclist_tyer: the order', TC, 'val hids = list_vt_reverse<hidecl> (hids)\n//\nin\n  glist_make_list_vt (hids)', 'val hids = hids\n//\nin\n  glist_make_list_vt (hids)'),
 ('d3eclist_tyer: empty declarations are dropped', TC, '    if isemp\n      then loop (d3cs, res)', '    if not(isemp)\n      then loop (d3cs, res)'),
 ('decarg2imparg: the order', TC, '    glist_append<s2var> (s2q.s2qua_svs (), decarg2imparg (s2qs))', '    glist_append<s2var> (decarg2imparg (s2qs), s2q.s2qua_svs ())'),
 ('v3ardec_tyer: the type', TC, 'val hse = s2exp_tyer_shallow (loc, s2e)\n//\nval init = d3expopt_tyer', 'val hse = s2exp_tyer_deep (loc, s2e)\n//\nval init = d3expopt_tyer'),
 ('d3ecl_tyer: a local declaration', TC, '    hidecl_local (loc0, hids_head, hids_body)', '    hidecl_local (loc0, hids_body, hids_head)'),
 ('trans4errlst: the count', TE, 'if nxs > 0\n    then $raise($ERR.PATSOPT_TRANS4_EXN())', 'if nxs > 1\n    then $raise($ERR.PATSOPT_TRANS4_EXN())'),
 ('trans4errlst: the list is emptied', TE, '  val () = $UN.ptr0_set<trans4errlst> (the_trans4errlst, glist_nil ())\nin\n  xs', '  val () = ()\nin\n  xs'),
]
def run(arg):
    i, (name, fn, old, new) = arg
    tmp = tempfile.mkdtemp(prefix='hdmut')
    path = os.path.join(W, fn)
    src = open(path).read()
    try:
        n = src.count(old)
        if n != 1: return (i, name, 'ERROR', 'occurs %d times' % n)
        open(path, 'w').write(src.replace(old, new))
        mod = fn[:-5]
        cc = ['patscc', '-DATS_MEMALLOC_LIBC', '-D_GNU_SOURCE', '-include', 'alloca.h', '-I' + W, '-c', '-o', os.path.join(tmp, mod + '.o'), path]
        r = subprocess.run(cc, capture_output=True, text=True, cwd=tmp)
        open(path, 'w').write(src)
        if r.returncode != 0: return (i, name, 'BUILD-FAILED', (r.stdout + r.stderr)[-300:].replace('\n', ' '))
        objs = [os.path.join(W, 'obj', f) for f in sorted(os.listdir(os.path.join(W, 'obj'))) if f.endswith('.o') and f != mod + '.o']
        exe = os.path.join(tmp, 'hd2m')
        r = subprocess.run(['gcc', '-o', exe, os.path.join(tmp, mod + '.o')] + objs + ['-lgmp'], capture_output=True, text=True)
        if r.returncode != 0: return (i, name, 'LINK-FAILED', r.stderr[-200:].replace('\n', ' '))
        try:
            p = subprocess.run([exe], capture_output=True, timeout=300)
        except subprocess.TimeoutExpired:
            return (i, name, 'DETECTED', 'timeout')
        ref = open(REF, 'rb').read()
        if p.returncode != 0: return (i, name, 'DETECTED', 'exit %d' % p.returncode)
        if p.stdout != ref:
            a, b = p.stdout.split(b'\n'), ref.split(b'\n')
            return (i, name, 'DETECTED', '%d lines differ' % (sum(1 for x, y in zip(a, b) if x != y) + abs(len(a) - len(b))))
        if REFERR and p.stderr != open(REFERR, 'rb').read(): return (i, name, 'DETECTED', 'stderr differs')
        return (i, name, 'SURVIVED', '')
    finally:
        open(path, 'w').write(src)
        shutil.rmtree(tmp, ignore_errors=True)
bad = 0; cnt = 0
for i, name, st, info in map(run, [(i, m) for i, m in enumerate(M) if not SEL or i in SEL]):
    cnt += 1
    print('%-12s %2d %s %s' % (st, i, name, info)); sys.stdout.flush()
    if st != 'DETECTED': bad += 1
print('mutations: %d, not detected: %d' % (cnt, bad))
