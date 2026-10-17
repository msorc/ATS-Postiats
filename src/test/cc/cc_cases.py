# the generator of the cases of the ccomp core test (called by cc_gen.py, see there and PORTING.md "ccomp core modules")
#
# A scenario is a function (a block of 'val' statements): it creates cells (s2var, s2cst, d2var, d2cst, d2con, and the cells of ccomp: tmplab, tmpvar, funlab, funent, d2env),
# builds random values of the types of the specs (the wrappers K_x and the typed lists/options of the compat layers, the smart constructors of the sats) and calls the functions of
# the modules, dumping every result completely. The machinery (class Sc, random leaves, hisexp builders) is that of d2_cases.py and hd_cases.py. CCSEED and CCSCALE can be set.
import os, random, re, sys
sys.dont_write_bytecode = True

SEED = int(os.environ.get('CCSEED', '1'))
SCALE = float(os.environ.get('CCSCALE', '3'))

# the printers that the module has for a type: (fprint, print, prerr)
PRINTERS = {'primdec': 'fpp', 'primval': 'fpp', 'primlab': 'fpp', 'instr': 'fpp', 'patck': 'fpp', 'patckont': 'fpp', 'tmpsub': 'f', 'tmpcstmat': 'f', 'tmpvarmat': 'f',
            'primcstsp': 'f', 'tmprimval': 'f', 'hifundec2': 'f', 'hiimpdec2': 'f', 'funlab': 'fpp', 'tmpvar': 'fpp', 'tmplab': 'f', 'd2env': 'f', 'funent': 'fpp'}

def build(G, C, H):
    ScH = H.hd_cases.build(G, C)
    C.TERM.update({
      'primcstsp': ['PMCSTSPmyfil', 'PMCSTSPmyloc', 'PMCSTSPmyfun'],
      'primdec_node': ['PMDnone', 'PMDdatdecs', 'PMDexndecs', 'PMDextvar', 'PMDstaload', 'PMDdynload'],
      'primval_node': ['PMVtmp', 'PMVtmpref', 'PMVarg', 'PMVargref', 'PMVargenv', 'PMVargtmpref', 'PMVcst', 'PMVenv', 'PMVint', 'PMVintrep', 'PMVbool', 'PMVchar',
                       'PMVfloat', 'PMVstring', 'PMVi0nt', 'PMVf0loat', 'PMVcstsp', 'PMVtyrep', 'PMVsizeof', 'PMVtop', 'PMVempty', 'PMVextval', 'PMVfunlab',
                       'PMVcfunlab', 'PMVd2vfunlab', 'PMVerror'],
      'primlab_node': ['PMLlab'],
      'patck': ['PATCKcon', 'PATCKint', 'PATCKbool', 'PATCKchar', 'PATCKfloat', 'PATCKstring', 'PATCKi0nt', 'PATCKf0loat'],
      'tmprimval': ['TPMVnone', 'TPMVsome'],
      'patckont': ['PTCKNTnone', 'PTCKNTtmplab', 'PTCKNTtmplabint', 'PTCKNTcaseof_fail', 'PTCKNTfunarg_fail'],
      'instr_node': ['INSfunlab', 'INStmplab', 'INScomment', 'INSletpop', 'INSloopexn', 'INSmove_list_nil', 'INSpmove_list_nil', 'INSpmove_list_cons',
                     'INSmove_list_phead', 'INSmove_list_ptail', 'INSmove_arrpsz_ptr', 'INSstore_arrpsz_asz', 'INSstore_arrpsz_ptr', 'INSupdate_ptrinc',
                     'INSupdate_ptrdec', 'INStmpdec', 'INSmove_arg_val', 'INSfreecon', 'INSraise'],
      'tmpsub': ['TMPSUBnil'], 'tmpcstmat': ['TMPCSTMATnone'], 'tmpvarmat': ['TMPVARMATnone'],
    })

    class ScC(ScH):
        def leaf(self, t):
            if t == 'double': return 'mkdouble (%d)' % self.R.randint(0, 6)
            if t == 'funlab' and self.pool.get('funlab'):
                return '$UN.cast{hfunlab} (%s)' % self.R.choice(self.pool['funlab'])   # the placeholder of hisexp_tyclo is a real funlab here (its name is printed)
            return ScH.leaf(self, t)
        def pools(self):
            R = self.R
            ScH.pools(self)
            self.do('t_lev_set (%d)' % R.randint(0, 3))
            self.val('funlab_make_type (hisexp_tybox)', 'funlab'); self.val('funlab_make_type (hisexp_typtr)', 'funlab')
            for _ in range(4): self.val('tmpvar_make (%s, %s)' % (self.loc(), self.hse(1)), 'tmpvar')
            for _ in range(2): self.val('tmpvar_make_ref (%s, %s)' % (self.loc(), self.hse(1)), 'tmpvar')
            for _ in range(2): self.val('tmpvar_make_ret (%s, %s)' % (self.loc(), self.hse(1)), 'tmpvar')
            for _ in range(3): self.val('tmplab_make (%s)' % self.loc(), 'tmplab')
            self.flfun = []
            V = self.pool['d2var']; Cs = self.pool['d2cst']
            def fcopt():
                return R.choice(['None_vt ()', 'None_vt ()', 'Some_vt (FUNCLOfun ())', 'Some_vt (FUNCLOclo (1))', 'Some_vt (FUNCLOclo (0))', 'Some_vt (FUNCLOclo (~1))'])
            def hfun():
                return 'hisexp_fun (%s, %s, %s)' % (self.leaf('funclo'), self.hses(1), self.hse(1))
            x = self.val('funlab_make_type (%s)' % hfun(), 'funlab'); self.flfun.append(x)
            x = self.val('funlab_make_type (%s)' % self.hse(1), 'funlab')
            x = self.val('funlab_make_dcst_type (%s, %s, %s)' % (Cs[0], hfun(), fcopt()), 'funlab'); self.flfun.append(x)
            x = self.val('funlab_make_dcst_type (%s, %s, %s)' % (Cs[1], hfun(), 'Some_vt (FUNCLOclo (1))'), 'funlab'); self.flfun.append(x)
            x = self.val('funlab_make_dvar_type (%s, %s, %s)' % (V[0], hfun(), fcopt()), 'funlab'); self.flfun.append(x)
            x = self.val('funlab_make_tmpcst_type (%s, %s, %s, %s)' % (Cs[2], self.gv('t2mpmarglst', 1), hfun(), fcopt()), 'funlab'); self.flfun.append(x)
            st = self.val('$STMP.funlab_stamp_make ()')
            x = self.val('funlab_make ("fl%d", %d, %s, %s, %s, %s, %s, %s)' % (R.randint(0, 9), R.randint(0, 3), hfun(), fcopt(),
                         'ON_d2cstopt ()' if R.random() < 0.5 else 'OS_d2cstopt (%s)' % Cs[R.randrange(3)],
                         'ON_d2varopt ()' if R.random() < 0.5 else 'OS_d2varopt (%s)' % V[R.randrange(3)], self.gv('t2mpmarglst', 1), st), 'funlab'); self.flfun.append(x)
            for i in range(3):
                self.val('d2var_set2_hisexp (%s, OS_hisexpopt (%s))' % (V[i], self.hse(1)))
        def gv(self, t, d):
            R = self.R
            if t in ('tmpvar', 'tmplab', 'funlab'): return R.choice(self.pool[t])
            if t == 'd2env': return 'd2env_make (%s, %s)' % (R.choice(self.pool['d2var']), self.hse(1))
            if t == 'funent': return self.fent()
            if t == 'vbindmap':
                V = self.pool['d2var']; k = R.randrange(3)
                if k == 0: return 't_vb0 ()'
                if k == 1: return 't_vb1 (%s, %s)' % (R.choice(V), self.gv('primval', 1))
                return 't_vb2 (%s, %s, %s, %s)' % (V[0], self.gv('primval', 1), V[1], self.gv('primval', 1))
            # the placeholders of hifundec / hiimpdec hold REAL funlab / instrlst here (the modules read them)
            if t == 'hifunlabopt': return R.choice(['ON_hifunlabopt ()', 'OS_hifunlabopt ($UN.cast{hfunlab} (%s))' % R.choice(self.pool['funlab'])])
            if t == 'hiinstrlstopt': return R.choice(['ON_hiinstrlstopt ()', 'OS_hiinstrlstopt ($UN.cast{hinstrlst} (%s))' % self.gv('instrlst', 1)])
            return ScH.gv(self, t, d)
        def carg(self, t, c, i, at, d):
            R = self.R
            if c == 'PMDstaload': return 'hidecl_staload (%s, %s, mkfil (0), %d, %s, %d)' % (self.loc(), self.gv('symbolopt', 1), R.randrange(2), self.leaf('filenv'), R.randrange(2))
            if c == 'PMDdynload': return 'hidecl_dynload (%s, mkfil (%d))' % (self.loc(), R.randrange(2))
            return ScH.carg(self, t, c, i, at, d)
        def fent(self):
            R = self.R
            return self.val('funent_make2 (%s, %s, %s, %s, %s, %s, %s, %s, %s)' % (self.loc(), R.choice(self.pool['funlab']), self.gv('s2varlst', 1), self.gv('s2explstlst', 1),
                            R.choice(self.pool['tmpvar']), self.gv('funlablst', 1), self.gv('d2envlst', 1), self.gv('vbindmap', 1), self.gv('instrlst', 1)), 'funent')
    return ScC

def printers(sc, t, x, kinds='fpp'):
    p = PRINTERS.get(t)
    if not p: return
    sc.call('fprint_' + t, [x], 'fprint')
    if len(p) > 1 and t not in ('tmplab',):
        sc.call('print_' + t, [x], 'print'); sc.call('prerr_' + t, [x], 'prerr')

def parse_makers(M):
    txt = open(os.path.join(M, 'pats_ccomp.sats')).read()
    txt = re.sub(r'\(\*.*?\*\)', '', txt, flags=re.S)
    txt = re.sub(r'//[^\n]*', '', txt)
    res = []
    for m in re.finditer(r'\bfun\s+(\w+)\s*\(([^()]*)\)\s*:\s*(\w+)', txt):
        name, params, ret = m.group(1), m.group(2), m.group(3)
        if not re.match(r'^(primdec_|primval_|primlab_|instr_|ibranch_)', name): continue
        if ret not in ('primdec', 'primval', 'primlab', 'instr', 'ibranch'): continue
        if name == 'instr_move_fltrec2': continue
        ps = []
        for p in params.split(','):
            p = p.strip()
            if not p: continue
            ty = p.split(':')[1].strip()
            ps.append({'loc_t': 'location'}.get(ty, ty))
        res.append((name, ps, ret))
    seen = set(); out = []
    for r in res:
        if r[0] in seen: continue
        seen.add(r[0]); out.append(r)
    return out

def families(G, C, ScC, M, H, CCORDER):
    F = []
    hdF = H.hd_cases.families(G, C, H.hd_cases.build(G, C), M)
    F.append([x for x in hdF if x[0] == 'setup'][0])
    makers = parse_makers(M)
    # ----------------------------------------------------------------------------------------------------------
    def fam_cell(sc, k):
        R = sc.R
        sc.pools()
        tls = sc.pool['tmplab']; tvs = sc.pool['tmpvar']; fls = sc.pool['funlab']; V = sc.pool['d2var']
        for t in tls:
            sc.dd('tmplab', t); sc.call('fprint_tmplab', [t], 'fprint')
            sc.call('tmplab_get_loc', [t], 'location'); sc.call('tmplab_get_stamp', [t], 'stamp')
        for t in tvs:
            sc.dd('tmpvar', t); printers(sc, 'tmpvar', t)
            sc.call('tmpvar_copy_err', [t], 'tmpvar')
            sc.call('tmpvar_is_void', [t], 'bool')
        for t in tvs[:3]:
            sc.do('tmpvar_inc_tailcal (%s)' % t); sc.do('tmpvar_inc_tailcal (%s)' % t); sc.dd('tmpvar', t)
        for i, t in enumerate(tvs):
            s = R.choice(['t_tv_set_type (%s, %s)' % (t, sc.hse(1)), 't_tv_set_ref (%s, %d)' % (t, R.randrange(3)), 't_tv_set_ret (%s, %d)' % (t, R.randrange(4)),
                          't_tv_set_topknd (%s, %d)' % (t, R.randrange(2)), 't_tv_set_origin (%s, OS_tmpvaropt (%s))' % (t, tvs[(i + 1) % len(tvs)]),
                          't_tv_set_origin (%s, ON_tmpvaropt ())' % t, 't_tv_set_suffix (%s, %d)' % (t, R.randrange(5)),
                          't_tv_set_tyclo (%s, %s)' % (t, R.choice(fls))])
            sc.do(s); sc.dd('tmpvar', t); printers(sc, 'tmpvar', t)
        for t in tvs[:2]:
            for s in ('t_tv_set_type (%s, %s)' % (t, sc.hse(1)), 't_tv_set_ref (%s, 1)' % t, 't_tv_set_ret (%s, 5)' % t, 't_tv_set_topknd (%s, 1)' % t,
                      't_tv_set_origin (%s, OS_tmpvaropt (%s))' % (t, tvs[3]), 't_tv_set_suffix (%s, 3)' % t, 't_tv_set_tyclo (%s, %s)' % (t, fls[0])):
                sc.do(s)
            sc.dd('tmpvar', t); printers(sc, 'tmpvar', t)
            sc.call('tmpvar_get_origin', [t], 'tmpvaropt'); sc.call('fprint_tmpvaropt', [t], 'void') if False else None
            sc.do('(fprint_tmpvaropt (dd_out, tmpvar_get_origin (%s)); dd_nl ())' % t)
        for a in tvs[:4]:
            for b in tvs[:4]:
                sc.call('eq_tmpvar_tmpvar', [a, b], 'bool'); sc.call('compare_tmpvar_tmpvar', [a, b], 'int')
        # the sets
        for rep in range(2):
            xs = [R.choice(tvs) for _ in range(R.randrange(2, 9))]
            sc.do('{ var xs = tmpvarset_vt_nil () %s val () = (dd_listvt_tmpvar (tmpvarset_vt_listize (xs)); dd_nl ()) %s val () = (dd_listvt_tmpvar (tmpvarset_vt_listize_free (xs)); dd_nl ()) }' % (
                  ' '.join('val () = (xs := tmpvarset_vt_add (xs, %s))' % x for x in xs[:len(xs) // 2]),
                  ' '.join('val () = (xs := tmpvarset_vt_add (xs, %s))' % x for x in xs[len(xs) // 2:])))
        sc.do('{ var xs = tmpvarset_vt_nil () val () = (dd_listvt_tmpvar (tmpvarset_vt_listize (xs)); dd_nl ()) val () = tmpvarset_vt_free (xs) }')
        sc.do('{ var xs = tmpvarset_vt_nil () %s val () = tmpvarset_vt_free (xs) }' % ' '.join('val () = (xs := tmpvarset_vt_add (xs, %s))' % x for x in tvs))
        # the maps
        for rep in range(2):
            ops = []
            for _ in range(R.randrange(4, 10)):
                a = R.choice(tvs); b = R.choice(tvs)
                kk = R.randrange(3)
                if kk == 0: ops.append('val () = (dd_bool (t_tvm_insert (m, %s, %s)); dd_nl ())' % (a, b))
                elif kk == 1: ops.append('val () = (dd_optvt_tmpvar (t_tvm_search (m, %s)); dd_nl ())' % a)
                else: ops.append('val () = (dd_bool (t_tvm_remove (m, %s)); dd_nl ())' % a)
            sc.do('{ var m = t_tvm_nil () %s val () = t_tvm_free (m) }' % ' '.join(ops))
        # the d2envs
        for i, v in enumerate(V):
            e = sc.val('d2var2env (%s)' % v, 'd2env'); sc.dd('d2env', e); sc.call('fprint_d2env', [e], 'fprint')
            sc.call('d2env_get_var', [e], 'd2var'); sc.call('d2env_get_type', [e], 'hisexp')
        es = [sc.val('d2env_make (%s, %s)' % (R.choice(V), sc.hse(1)), 'd2env') for _ in range(3)] + sc.pool.get('d2env', [])
        sc.call('fprint_d2envlst', [sc.lst('d2envlst', es)], 'fprint'); sc.call('fprint_d2envlst', [sc.lst('d2envlst', [])], 'fprint')
        sc.call('fprint_d2envlstopt', ['OS_d2envlstopt (%s)' % sc.lst('d2envlst', es[:2])], 'fprint'); sc.call('fprint_d2envlstopt', ['ON_d2envlstopt ()'], 'fprint')
        for rep in range(2):
            xs = [R.choice(es) for _ in range(R.randrange(2, 8))]
            sc.do('{ var xs = d2envset_vt_nil () %s val () = (dd_listvt_d2env (d2envset_vt_listize (xs)); dd_nl ()) val () = (dd_listvt_d2env (d2envset_vt_listize_free (xs)); dd_nl ()) }' % (
                  ' '.join('val () = (xs := d2envset_vt_add (xs, %s))' % x for x in xs)))
        sc.do('{ val xs = d2envlst2set (%s) val () = (dd_listvt_d2env (d2envset_vt_listize_free (xs)); dd_nl ()) }' % sc.lst('d2envlst', es + es[:2]))
        sc.do('{ val xs = d2envlst2set (%s) val () = d2envset_vt_free (xs) }' % sc.lst('d2envlst', es))
        sc.do('{ val xs = d2envset_vt_nil () val () = d2envset_vt_free (xs) }')
        for t in tvs: sc.dd('tmpvar', t)
    F.append(('cell', fam_cell, 2))
    # ----------------------------------------------------------------------------------------------------------
    def fam_funlab(sc, k):
        R = sc.R
        sc.pools()
        fls = sc.pool['funlab']; tvs = sc.pool['tmpvar']
        for f in fls:
            sc.dd('funlab', f); printers(sc, 'funlab', f)
            sc.call('funlab_get_name', [f], 'string'); sc.call('funlab_get_level', [f], 'int'); sc.call('funlab_get_tmpknd', [f], 'int')
            sc.call('funlab_get_d2copt', [f], 'd2cstopt'); sc.call('funlab_get_d2vopt', [f], 'd2varopt')
            sc.call('funlab_get_type', [f], 'hisexp'); sc.call('funlab_get_funclo', [f], 'funclo'); sc.call('funlab_get_ncopy', [f], 'int')
            sc.call('funlab_get_suffix', [f], 'int'); sc.call('funlab_get_tmparg', [f], 't2mpmarglst'); sc.call('funlab_get_stamp', [f], 'stamp')
            sc.do('(dd_funlabopt_shallow (funlab_get_origin (%s)); dd_nl ())' % f)
            sc.do('(dd_funentopt_shallow (funlab_get_funent (%s)); dd_nl ())' % f)
            sc.call('print_hisexp', [sc.val('hisexp_tyclo ($UN.cast{hfunlab} (%s))' % f, 'hisexp')], 'print')
        for f in sc.flfun:
            sc.call('funlab_get_type_arg', [f], 'hisexplst'); sc.call('funlab_get_type_res', [f], 'hisexp')
        for i, f in enumerate(fls):
            sc.do('funlab_set_tmpknd (%s, %d)' % (f, R.randint(-1, 1)))
            sc.do('funlab_set_ncopy (%s, %d)' % (f, R.randrange(5)))
            sc.call('funlab_incget_ncopy', [f], 'int'); sc.call('funlab_incget_ncopy', [f], 'int')
            sc.do('funlab_set_origin (%s, OS_funlabopt (%s))' % (f, fls[(i + 1) % len(fls)]))
            sc.do('funlab_set_suffix (%s, %d)' % (f, R.randrange(7)))
            sc.dd('funlab', f); printers(sc, 'funlab', f)
        for f in fls[:3]:
            sc.do('funlab_set_origin (%s, ON_funlabopt ())' % f)
            sc.call('funlab_get_origin', [f], 'funlabopt') if False else sc.do('(dd_funlabopt_shallow (funlab_get_origin (%s)); dd_nl ())' % f)
        # the function entries attached to the labels
        for i in range(3):
            fe = sc.fent()
            sc.dd('funent', fe)
            sc.do('funlab_set_funent (%s, OS_funentopt (%s))' % (fls[i], fe))
            sc.dd('funlab', fls[i]); sc.call('funlab_get_funent', [fls[i]], 'funentopt')
        # the sets of labels
        for rep in range(3):
            xs = [R.choice(fls) for _ in range(R.randrange(2, 9))]
            sc.do('{ var xs = funlabset_vt_nil () %s %s val () = (dd_listvt_funlab (funlabset_vt_listize (xs)); dd_nl ()) val () = fprint_funlabset_vt (dd_out, xs) val () = dd_nl () val () = (dd_listvt_funlab (funlabset_vt_listize_free (xs)); dd_nl ()) }' % (
                  ' '.join('val () = (xs := funlabset_vt_add (xs, %s))' % x for x in xs[:len(xs) // 2]),
                  ' '.join('val () = (dd_bool (funlabset_vt_ismem (xs, %s)); dd_nl ()) val () = (xs := funlabset_vt_add (xs, %s))' % (R.choice(fls), x) for x in xs[len(xs) // 2:])))
        sc.do('{ var xs = funlabset_vt_nil () val () = (dd_bool (funlabset_vt_ismem (xs, %s)); dd_nl ()) val () = fprint_funlabset_vt (dd_out, xs) val () = dd_nl () val () = funlabset_vt_free (xs) }' % fls[0])
        sc.do('{ val xs = funlablst2set (%s) val () = (dd_listvt_funlab (funlabset_vt_listize_free (xs)); dd_nl ()) }' % sc.lst('funlablst', fls + fls[:3]))
        sc.do('{ val xs = funlablst2set (%s) val () = funlabset_vt_free (xs) }' % sc.lst('funlablst', fls))
        sc.call('fprint_funlablst', [sc.lst('funlablst', fls)], 'fprint'); sc.call('fprint_funlablst', [sc.lst('funlablst', [])], 'fprint')
        sc.call('fprint_funlablstopt', ['OS_funlablstopt (%s)' % sc.lst('funlablst', fls[:3])], 'fprint'); sc.call('fprint_funlablstopt', ['ON_funlablstopt ()'], 'fprint')
        # the labels of the lists of the function types
        for i, f in enumerate(fls): sc.dd('funlab', f)
    F.append(('funlab', fam_funlab, 2))
    # ----------------------------------------------------------------------------------------------------------
    def fam_funent(sc, k):
        R = sc.R
        sc.pools()
        fls = sc.pool['funlab']; tvs = sc.pool['tmpvar']; V = sc.pool['d2var']
        for i in range(3):
            args = (sc.loc(), R.choice(fls), sc.gv('s2varlst', 1), sc.gv('s2explstlst', 1), sc.gv('tmpsubopt', 1), R.choice(tvs), sc.gv('funlablst', 1), sc.gv('d2envlst', 1),
                    sc.gv('vbindmap', 1), sc.gv('instrlst', 1), sc.gv('tmpvarlst', 1))
            fe = sc.val('funent_make (%s)' % ', '.join(args), 'funent')
            fe2 = sc.val('funent_make2 (%s, %s, %s, %s, %s, %s, %s, %s, %s)' % (sc.loc(), R.choice(fls), sc.gv('s2varlst', 1), sc.gv('s2explstlst', 1), R.choice(tvs),
                         sc.gv('funlablst', 1), sc.gv('d2envlst', 1), sc.gv('vbindmap', 1), sc.gv('instrlst', 2)), 'funent')
            for x in (fe, fe2):
                sc.dd('funent', x); printers(sc, 'funent', x)
                sc.call('funent_is_tmplt', [x], 'bool'); sc.call('funent_get_level', [x], 'int')
                sc.call('funent_get_loc', [x], 'location'); sc.do('(fprint_funlab (dd_out, funent_get_lab (%s)); dd_nl ())' % x)
                sc.call('funent_get_imparg', [x], 's2varlst'); sc.call('funent_get_tmparg', [x], 's2explstlst'); sc.call('funent_get_tmpsub', [x], 'tmpsubopt')
                sc.call('funent_get_tmpret', [x], 'tmpvar'); sc.call('funent_get_flablst', [x], 'funlablst'); sc.call('funent_get_flablst_fin', [x], 'funlablstopt')
                sc.call('funent_get_d2envlst', [x], 'd2envlst'); sc.call('funent_get_d2envlst_fin', [x], 'd2envlstopt')
                sc.call('funent_get_tmpvarlst', [x], 'tmpvarlst'); sc.call('funent_get_fnxlablst', [x], 'funlablst')
                sc.do('(dd_vbindmap (funent_get_vbindmap (%s)); dd_nl ())' % x); sc.call('funent_get_instrlst', [x], 'instrlst')
                sc.do('funent_set_tmpsub (%s, %s)' % (x, sc.gv('tmpsubopt', 1)))
                sc.do('t_fe_set_flablst_fin (%s, %s)' % (x, sc.gv('funlablstopt', 1)))
                sc.do('t_fe_set_d2envlst_fin (%s, %s)' % (x, sc.gv('d2envlstopt', 1)))
                sc.do('funent_set_fnxlablst (%s, %s)' % (x, sc.gv('funlablst', 1)))
                sc.dd('funent', x)
                sc.do('funent_set_tmpsub (%s, ON_tmpsubopt ())' % x); sc.do('t_fe_set_flablst_fin (%s, ON_funlablstopt ())' % x); sc.dd('funent', x)
    F.append(('funent', fam_funent, 2))
    # ----------------------------------------------------------------------------------------------------------
    def fam_make(sc, k):
        sc.pools()
        for name, ps, ret in makers:
            for rep in range(2):
                args = [sc.gv(t, 2) for t in ps]
                if name == 'primdec_staload': args[1] = sc.carg('primdec_node', 'PMDstaload', 0, 'hidecl', 2)   # the printer matches HIDstaload / HIDdynload
                if name == 'primdec_dynload': args[1] = sc.carg('primdec_node', 'PMDdynload', 0, 'hidecl', 2)
                x = sc.val('%s (%s)' % ({'primdec_extvar': 't_primdec_extvar', 'primdec_valdecs': 't_primdec_valdecs', 'primdec_valdecs_rec': 't_primdec_valdecs_rec',
                                        'primdec_vardecs': 't_primdec_vardecs'}.get(name, name), ', '.join(args)), ret)
                sc.dd(ret, x)
                if ret in ('primdec', 'primval', 'primlab', 'instr'): printers(sc, ret, x)
                if ret == 'primval':
                    sc.call('primval_is_void', [x], 'bool'); sc.call('primval_is_top', [x], 'bool'); sc.call('primval_is_nshared', [x], 'bool')
                if ret == 'primlab':
                    sc.call('primlab_is_lab', [x], 'bool'); sc.call('primlab_is_ind', [x], 'bool')
        # instr_move_fltrec2: the singleton record is a move, the others a record
        for rep in range(3):
            lh = sc.val('K_labhisexp (%s, ON_stringopt (), %s)' % (sc.leaf('label'), sc.hse(1)))
            hs = sc.val('hisexp_tyrecsin (%s)' % lh, 'hisexp')
            x = sc.val('instr_move_fltrec2 (%s, %s, %s, %s)' % (sc.loc(), sc.gv('tmpvar', 1), sc.lst('labprimvalist', [sc.gv('labprimval', 1)] + [sc.gv('labprimval', 1) for _ in range(rep)]), hs), 'instr')
            sc.dd('instr', x); printers(sc, 'instr', x)
        for rep in range(3):
            hs = sc.val('hisexp_tyrec (%s, %s)' % (sc.tyreckind(), sc.lhs(1)), 'hisexp')
            x = sc.val('instr_move_fltrec2 (%s, %s, %s, %s)' % (sc.loc(), sc.gv('tmpvar', 1), sc.gv('labprimvalist', 1), hs), 'instr')
            sc.dd('instr', x); printers(sc, 'instr', x)
            x = sc.val('instr_move_fltrec2 (%s, %s, %s, %s)' % (sc.loc(), sc.gv('tmpvar', 1), sc.gv('labprimvalist', 1), sc.hse(1)), 'instr')
            sc.dd('instr', x)
    F.append(('make', fam_make, 3))
    # ----------------------------------------------------------------------------------------------------------
    def fam_raw(sc, k):
        """every constructor and record of the spec through K_, dumped and printed"""
        R = sc.R
        sc.pools()
        for t in CCORDER:
            if t in ('tmplab', 'tmpvar', 'd2env', 'funlab', 'funent'): continue
            if t in G.recs:
                for rep in range(2):
                    x = sc.val(sc.record(t, 3), t); sc.dd(t, x); printers(sc, t, x)
            else:
                for c, ts in G.types[t]:
                    for rep in range(2):
                        args = ', '.join(sc.carg(t, c, i, at, 3) for i, at in enumerate(ts))
                        x = sc.val('K_%s (%s)' % (c, args), t); sc.dd(t, x); printers(sc, t, x)
        for k in (1, 10, 127, 65, 97):    # printable and not printable characters
            x = sc.val('K_primval (%s, %s, K_PMVchar (t_chr (%d)))' % (sc.loc(), sc.hse(1), k), 'primval'); sc.dd('primval', x); printers(sc, 'primval', x)
            x = sc.val('K_PATCKchar (t_chr (%d))' % k, 'patck'); sc.dd('patck', x); printers(sc, 'patck', x)
        # the lists and options of the printers
        for t, f in (('primdeclst', 'fprint_primdeclst'), ('primvalist', 'fprint_primvalist'), ('primlablst', 'fprint_primlablst'), ('instrlst', 'fprint_instrlst'),
                     ('labprimvalist', 'fprint_labprimvalist'), ('tmpmovlst', 'fprint_tmpmovlst'), ('hitypelst', None)):
            if not f: continue
            for rep in range(3):
                x = sc.val(sc.gv(t, 2), t); sc.dd(t, x); sc.call(f, [x], 'fprint')
        for rep in range(3):
            sc.call('fprint_tmpcstmat_kind', [sc.gv('tmpcstmat', 2)], 'fprint'); sc.call('fprint_tmpvarmat_kind', [sc.gv('tmpvarmat', 2)], 'fprint')
            sc.call('fprint_vbindmap', [sc.gv('vbindmap', 1)], 'fprint')
    F.append(('raw', fam_raw, 3))
    # ----------------------------------------------------------------------------------------------------------
    def fam_util(sc, k):
        R = sc.R
        sc.pools()
        fls = sc.pool['funlab']; tvs = sc.pool['tmpvar']
        # the predicates, on a primval of every constructor
        hv = sc.val('hisexp_void_t0ype ()', 'hisexp')
        for c, ts in G.types['primval_node']:
            for hs in (hv, sc.hse(1)):
                args = ', '.join(sc.carg('primval_node', c, i, at, 2) for i, at in enumerate(ts))
                x = sc.val('K_primval (%s, %s, K_%s (%s))' % (sc.loc(), hs, c, args), 'primval')
                sc.call('primval_is_void', [x], 'bool'); sc.call('primval_is_top', [x], 'bool'); sc.call('primval_is_nshared', [x], 'bool')
        for x in tvs: sc.call('tmpvar_is_void', [x], 'bool')
        for c, ts in G.types['patckont']:
            x = sc.val('K_%s (%s)' % (c, ', '.join(sc.carg('patckont', c, i, at, 2) for i, at in enumerate(ts)))); sc.call('patckont_is_none', [x], 'bool')
        for x in sc.pool['tmplab'][:0]: pass
        for pml in range(2):
            x = sc.val(sc.record('primlab', 2), 'primlab'); sc.call('primlab_is_lab', [x], 'bool'); sc.call('primlab_is_ind', [x], 'bool')
        for f in fls:
            for fn in ('primval_make_funlab (%s, %s)' % (sc.loc(), f), 'primval_make2_funlab (%s, %s, %s)' % (sc.loc(), sc.hse(1), f),
                       'primval_make_d2vfunlab (%s, %s, %s)' % (sc.loc(), R.choice(sc.pool['d2var']), f)):
                x = sc.val(fn, 'primval'); sc.dd('primval', x)
        # the substitutions of the templates
        for rep in range(3):
            n = R.randrange(4)
            vs = [R.choice(sc.pool['s2var']) for _ in range(n)]
            ts = 'TMPSUBnil'
            e = 'K_TMPSUBnil ()'
            for v in vs: e = 'K_TMPSUBcons (%s, %s, %s)' % (v, sc.gv('s2exp', 1), e)
            ts1 = sc.val(e, 'tmpsub')
            e2 = 'K_TMPSUBnil ()'
            for v in sc.pool['s2var'][:2]: e2 = 'K_TMPSUBcons (%s, %s, %s)' % (v, sc.gv('s2exp', 1), e2)
            ts2 = sc.val(e2, 'tmpsub')
            sc.dd('tmpsub', ts1); sc.call('fprint_tmpsub', [ts1], 'fprint')
            sc.call('fprint_tmpsubopt', ['OS_tmpsubopt (%s)' % ts1], 'fprint'); sc.call('fprint_tmpsubopt', ['ON_tmpsubopt ()'], 'fprint')
            ap = sc.val('tmpsub_append (%s, %s)' % (ts1, ts2), 'tmpsub'); sc.dd('tmpsub', ap)
            for s2e in [sc.gv('s2exp', 2) for _ in range(2)] + ['s2exp_var (%s)' % v for v in sc.pool['s2var']]:
                sc.do('{ val sub = tmpsub2stasub (%s) val s2e = s2exp_subst (sub, %s) val () = (dd_s2exp s2e; dd_nl ()) val () = stasub_free (sub) }' % (ap, s2e))
            sc.do('{ val sub = tmpsub2stasub (%s) val () = (fprint_stasub (dd_out, sub); dd_nl ()) val () = stasub_free (sub) }' % ts1)
        # the sets of the temporary variables of lists of instructions / declarations
        for rep in range(4):
            inss = sc.val(sc.gv('instrlst', 3), 'instrlst'); sc.dd('instrlst', inss)
            sc.do('{ val xs = instrlst_get_tmpvarset (%s) val () = (dd_listvt_tmpvar (tmpvarset_vt_listize_free (xs)); dd_nl ()) }' % inss)
            pmds = sc.val(sc.gv('primdeclst', 3), 'primdeclst')
            sc.do('{ val xs = primdeclst_get_tmpvarset (%s) val () = (dd_listvt_tmpvar (tmpvarset_vt_listize_free (xs)); dd_nl ()) }' % pmds)
        sc.do('{ val xs = instrlst_get_tmpvarset (%s) val () = tmpvarset_vt_free (xs) }' % sc.lst('instrlst', []))
        # every instruction alone (each arm of the traversal), nested in loops, conditionals, cases, try-with and local declarations
        for c, ts in G.types['instr_node']:
            for rep in range(2):
                args = ', '.join(sc.carg('instr_node', c, i, at, 2) for i, at in enumerate(ts))
                x = sc.val('K_instr (%s, K_%s (%s))' % (sc.loc(), c, args), 'instr')
                sc.do('{ val xs = instrlst_get_tmpvarset (%s) val () = (dd_listvt_tmpvar (tmpvarset_vt_listize_free (xs)); dd_nl ()) }' % sc.lst('instrlst', [x]))
        for c, ts in G.types['primdec_node']:
            for rep in range(2):
                args = ', '.join(sc.carg('primdec_node', c, i, at, 2) for i, at in enumerate(ts))
                x = sc.val('K_primdec (%s, K_%s (%s))' % (sc.loc(), c, args), 'primdec')
                sc.do('{ val xs = primdeclst_get_tmpvarset (%s) val () = (dd_listvt_tmpvar (tmpvarset_vt_listize_free (xs)); dd_nl ()) }' % sc.lst('primdeclst', [x]))
        # nested declarations that carry instructions on both sides of a local declaration, an include, a staloadloc
        for rep in range(2):
            tv = sc.pool['tmpvar']
            def ins(i):
                return sc.val('instr_move_val (%s, %s, %s)' % (sc.loc(), tv[i % len(tv)], sc.gv('primval', 1)), 'instr')
            d1 = sc.val('t_primdec_vardecs (%s, %s, %s)' % (sc.loc(), sc.gv('hivardeclst', 1), sc.lst('instrlst', [ins(rep), ins(rep + 1)])), 'primdec')
            d2 = sc.val('t_primdec_valdecs (%s, mkvalkind (%d), %s, %s)' % (sc.loc(), rep, sc.gv('hivaldeclst', 1), sc.lst('instrlst', [ins(rep + 2)])), 'primdec')
            d3 = sc.val('t_primdec_extvar (%s, "ev", %s)' % (sc.loc(), sc.lst('instrlst', [ins(rep + 3)])), 'primdec')
            l1 = sc.val('primdec_local (%s, %s, %s)' % (sc.loc(), sc.lst('primdeclst', [d1]), sc.lst('primdeclst', [d2])), 'primdec')
            l2 = sc.val('primdec_local (%s, %s, %s)' % (sc.loc(), sc.lst('primdeclst', [d3]), sc.lst('primdeclst', [d1, d2])), 'primdec')
            inc = sc.val('primdec_include (%s, %d, %s)' % (sc.loc(), rep, sc.lst('primdeclst', [d2, d3])), 'primdec')
            sl = sc.val('primdec_staloadloc (%s, mkfil (0), mksym (1), %s)' % (sc.loc(), sc.lst('primdeclst', [d3])), 'primdec')
            ls = sc.val('primdec_list (%s, %s)' % (sc.loc(), sc.lst('primdeclst', [d1, d3])), 'primdec')
            for ds in ([l1], [l2], [inc], [sl], [ls], [l1, l2, inc, sl, ls]):
                sc.do('{ val xs = primdeclst_get_tmpvarset (%s) val () = (dd_listvt_tmpvar (tmpvarset_vt_listize_free (xs)); dd_nl ()) }' % sc.lst('primdeclst', ds))
            for x in (l1, l2, inc, sl, ls): sc.dd('primdec', x); printers(sc, 'primdec', x)
    F.append(('util', fam_util, 2))
    # ----------------------------------------------------------------------------------------------------------
    def fam_seq(sc, k):
        R = sc.R
        sc.pools()
        for rep in range(3):
            ops = []
            for _ in range(R.randrange(3, 9)):
                kk = R.randrange(9)
                if kk == 0: ops.append('instrseq_add (res, %s)' % sc.gv('instr', 2))
                elif kk == 1: ops.append('instrseq_add_comment (res, "c%d")' % R.randrange(5))
                elif kk == 2: ops.append('instrseq_add_tmpdec (res, %s, %s)' % (sc.loc(), sc.gv('tmpvar', 1)))
                elif kk == 3: ops.append('instrseq_add_extvar (res, %s, "x%d", %s)' % (sc.loc(), R.randrange(3), sc.gv('primval', 1)))
                elif kk == 4: ops.append('instrseq_add_dcstdef (res, %s, %s, %s)' % (sc.loc(), R.choice(sc.pool['d2cst']), sc.gv('primval', 1)))
                elif kk == 5: ops.append('instrseq_addlst (res, %s)' % sc.gv('instrlst', 2))
                elif kk == 6:
                    xs = 'list_vt_nil ()'
                    for _ in range(R.randrange(3)): xs = 'list_vt_cons (%s, %s)' % (sc.gv('instr', 1), xs)
                    ops.append('instrseq_addlst_vt (res, %s)' % xs)
                elif kk == 7:
                    xs = 'list_vt_nil ()'
                    for _ in range(R.randrange(3)): xs = 'list_vt_cons (%s, %s)' % (sc.gv('primval', 1), xs)
                    ops.append('instrseq_add_freeconlst (res, %s, %s)' % (sc.loc(), xs))
                else: ops.append('instrseq_add (res, %s)' % sc.gv('instr', 1))
            sc.do('{ val res = instrseq_make_nil () %s val xs = instrseq_get_free (res) val () = (dd_instrlst xs; dd_nl ()) val () = (fprint_instrlst (dd_out, xs); dd_nl ()) }' % ' '.join('val () = %s' % o for o in ops))
        sc.do('{ val res = instrseq_make_nil () val xs = instrseq_get_free (res) val () = (dd_instrlst xs; dd_nl ()) }')
    F.append(('seq', fam_seq, 2))
    # ----------------------------------------------------------------------------------------------------------
    def fam_dec(sc, k):
        R = sc.R
        sc.pools()
        fls = sc.pool['funlab']; V = sc.pool['d2var']; Cs = sc.pool['d2cst']
        fds = [sc.val('hifundec_make (%s, %s, %s, %s)' % (sc.loc(), V[i % 3], sc.gv('s2varlst', 1), sc.E(2)), 'hifundec') for i in range(3)]
        ims = [sc.val('hiimpdec_make (%s, %d, %s, %s, %s, %s)' % (sc.loc(), R.randrange(2), Cs[i % 3], sc.gv('s2varlst', 1), sc.gv('s2explstlst', 1), sc.E(2)), 'hiimpdec') for i in range(3)]
        for f in fds:
            sc.call('hifundec_get_funlabopt', [f], 'funlabopt')
            sc.do('hifundec_set_funlabopt (%s, OS_funlabopt (%s))' % (f, R.choice(fls)))
            sc.call('hifundec_get_funlabopt', [f], 'funlabopt'); sc.dd('hifundec', f)
            sc.do('hifundec_set_funlabopt (%s, ON_funlabopt ())' % f); sc.call('hifundec_get_funlabopt', [f], 'funlabopt')
            sc.do('hifundec_set_funlabopt (%s, OS_funlabopt (%s))' % (f, R.choice(fls)))
        for m in ims:
            sc.call('hiimpdec_get_funlabopt', [m], 'funlabopt'); sc.call('hiimpdec_get_instrlstopt', [m], 'instrlstopt')
            sc.do('hiimpdec_set_funlabopt (%s, OS_funlabopt (%s))' % (m, R.choice(fls)))
            sc.do('hiimpdec_set_instrlstopt (%s, OS_instrlstopt (%s))' % (m, sc.gv('instrlst', 2)))
            sc.call('hiimpdec_get_funlabopt', [m], 'funlabopt'); sc.call('hiimpdec_get_instrlstopt', [m], 'instrlstopt'); sc.dd('hiimpdec', m)
            x = sc.val('primdec_impdec (%s, %s)' % (sc.loc(), m), 'primdec'); sc.dd('primdec', x); printers(sc, 'primdec', x)
            sc.do('{ val xs = primdeclst_get_tmpvarset (%s) val () = (dd_listvt_tmpvar (tmpvarset_vt_listize_free (xs)); dd_nl ()) }' % sc.lst('primdeclst', [x]))
            sc.do('hiimpdec_set_instrlstopt (%s, ON_instrlstopt ())' % m); sc.call('hiimpdec_get_instrlstopt', [m], 'instrlstopt')
            sc.do('{ val xs = primdeclst_get_tmpvarset (%s) val () = (dd_listvt_tmpvar (tmpvarset_vt_listize_free (xs)); dd_nl ()) }' % sc.lst('primdeclst', [x]))
        x = sc.val('primdec_fundecs (%s, mkfunkind (%d), %s, %s)' % (sc.loc(), R.randrange(7), sc.gv('s2qualst', 1), sc.lst('hifundeclst', fds)), 'primdec'); sc.dd('primdec', x); printers(sc, 'primdec', x)
        x = sc.val('primdec_impdec (%s, %s)' % (sc.loc(), ims[0]), 'primdec'); sc.dd('primdec', x); printers(sc, 'primdec', x)
    F.append(('dec', fam_dec, 2))
    return F

def exit_cases(ScC, G, R):
    """the functions ccx_k (): each builds the (small) values of its case and runs the operation that ends the process"""
    out = []
    def mk(k, body):
        sc = ScC(G, R, 'ccx_%d' % k)
        sc.pools()
        body(sc)
        out.append(sc.text())
    L = lambda sc: sc.loc()
    def nonfun(sc): return sc.val('funlab_make_type (hisexp_tybox)', 'funlab')
    mk(1, lambda sc: sc.do('(dd_hisexplst (funlab_get_type_arg (%s)); dd_nl ())' % nonfun(sc)))
    mk(2, lambda sc: sc.do('(dd_hisexp (funlab_get_type_res (%s)); dd_nl ())' % nonfun(sc)))
    mk(3, lambda sc: sc.do('(dd_d2env (d2var2env (%s)); dd_nl ())' % sc.new('d2var')))
    mk(4, lambda sc: sc.do('(dd_instr (instr_move_fltrec2 (%s, %s, %s, hisexp_tyrecsin (K_labhisexp (mklab (0), ON_stringopt (), hisexp_tybox)))); dd_nl ())' % (L(sc), sc.gv('tmpvar', 1), sc.lst('labprimvalist', []))))
    mk(5, lambda sc: sc.do('(fprint_primdec (dd_out, primdec_staload (%s, hidecl_none (%s))); dd_nl ())' % (L(sc), L(sc))))
    mk(6, lambda sc: sc.do('(fprint_primdec (dd_out, primdec_dynload (%s, hidecl_none (%s))); dd_nl ())' % (L(sc), L(sc))))
    mk(7, lambda sc: sc.do('(fprint_primdec (dd_out, primdec_staload (%s, hidecl_dynload (%s, mkfil (0)))); dd_nl ())' % (L(sc), L(sc))))
    return out

def main(G, C, H, d, M, T, CCORDER, CCELLS, CC_LISTS, CC_OPTS):
    G.lists.update(CC_LISTS); G.opts.update(CC_OPTS)
    ScC = build(G, C, H)
    F = families(G, C, ScC, M, H, CCORDER)
    R = random.Random(SEED)
    scs = []
    for name, fam, n in F:
        for i in range(max(1, int(round(n * SCALE))) if n > 0 else 1):
            sc = ScC(G, R, 'sc_%s_%d' % (name, i))
            fam(sc, i)
            scs.append(sc)
    chunks = []; cur = []; size = 0
    for sc in scs:
        t = sc.text()
        cur.append((sc.name, t)); size += t.count('\n')
        if size > 1200 or sc.name.startswith('sc_setup'):
            chunks.append(cur); cur = []; size = 0
    if cur: chunks.append(cur)
    bodies = []
    for ch in chunks:
        k = len(bodies)
        body = ''.join(t for n, t in ch)
        body += 'fun tc%d_body (): void = {\n' % k + ''.join('  val () = %s ()\n' % n for n, t in ch) + '}\n'
        bodies.append(body)
    write_chunks(d, C, bodies)
    xs = exit_cases(ScC, G, random.Random(SEED + 1000))
    C.put(os.path.join(d, 'cc_exit.hats'), ''.join(xs) + 'fun cc_exit (k: int): void = (\n' + ''.join('  if k = %d then ccx_%d () else\n' % (i + 1, i + 1) for i in range(len(xs))) + '  ()\n)\n')
    print('cc_cases: %d scenarios, %d chunks, %d lines' % (len(scs), len(bodies), sum(b.count('\n') for b in bodies)))

def write_chunks(d, C, chunks):
    for f in os.listdir(d):
        m = re.match(r'^(?:ccase_|ccase1_|cc_cases_)(\d\d)\.(?:dats|hats)$', f)
        if m and int(m.group(1)) >= len(chunks): os.remove(os.path.join(d, f))
    ch2 = []; ch1 = []
    for k, body in enumerate(chunks):
        cases = 'cc_cases_%02d.hats' % k
        C.put(os.path.join(d, cases), body)
        C.put(os.path.join(d, 'ccase_%02d.dats' % k),
            '(* generated by cc_gen.py: the chunk %d of the cases of the ccomp test (ATS2) *)\n#define ATS_DYNLOADFLAG 0\n#include "cc_pre.hats"\n'
            'extern fun tc%d_all (): void = "ext#cctc_%d"\n#include "%s"\nimplement tc%d_all () = tc%d_body ()\n' % (k, k, k, cases, k, k))
        C.put(os.path.join(d, 'ccase1_%02d.dats' % k),
            '(* generated by cc_gen.py: the chunk %d of the cases of the ccomp test (ATS1) *)\n#include "cc_pre1.hats"\n'
            'extern fun tc%d_all (): void = "cctc_%d"\n#include "%s"\nimplement tc%d_all () = tc%d_body ()\n' % (k, k, k, cases, k, k))
        ch2.append('extern fun tc%d_all (): void = "ext#cctc_%d"\n' % (k, k))
        ch1.append('extern fun tc%d_all (): void = "cctc_%d"\n' % (k, k))
    call = 'fun tc_all (): void = {\n' + ''.join('  val () = tc%d_all ()\n' % k for k in range(len(chunks))) + '}\n'
    C.put(os.path.join(d, 'cc_chunks.hats'), ''.join(ch2) + call)
    C.put(os.path.join(d, 'cc_chunks1.hats'), ''.join(ch1) + call)
