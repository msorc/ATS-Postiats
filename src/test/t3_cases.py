# the generator of the cases of the level-3 test (called by t3_gen.py, see there and PORTING.md "Level 3 trees (dynexp3)", "Type-checking environment (trans3_env)")
#
# A scenario is a function (a block of 'val' statements): it creates cells (s2var, s2Var, s2cst, d2var, d2con), builds random values of the types of the
# specs (the wrappers K_x and the typed lists/options of the compat layers) and calls the functions of the modules, dumping every result completely.
# The machinery (the class Sc, the random values) is that of d2_cases.py. T3SEED and T3SCALE can be set in the environment.
import os, random, re, sys
sys.dont_write_bytecode = True

SEED = int(os.environ.get('T3SEED', '1'))
SCALE = float(os.environ.get('T3SCALE', '3'))

def build(G, C):
    C.TERM.update({
      'p3at_node': ['P3Tany', 'P3Tvar', 'P3Tint', 'P3Tintrep', 'P3Tbool', 'P3Tchar', 'P3Tfloat', 'P3Tstring', 'P3Ti0nt', 'P3Tf0loat', 'P3Tempty', 'P3Tvbox', 'P3Terrpat'],
      'd3exp_node': ['D3Ecst', 'D3Evar', 'D3Eint', 'D3Eintrep', 'D3Ebool', 'D3Echar', 'D3Efloat', 'D3Estring', 'D3Ei0nt', 'D3Ef0loat', 'D3Ecstsp', 'D3Etyrep',
                     'D3Etop', 'D3Eempty', 'D3Eextval', 'D3Eptrofvar', 'D3Evcopyenv', 'D3Etempenver', 'D3Eloopexn', 'D3Esolverify', 'D3Eerrexp'],
      'd3ecl_node': ['D3Cnone', 'D3Cdynload', 'D3Cextcode', 'D3Cexndecs', 'D3Cdatdecs', 'D3Cdcstdecs', 'D3Creassume', 'D3Cstaload', 'D3Cstaloadloc', 'D3Clist', 'D3Cinclude', 'D3Clocal'],
      'd3lab_node': ['D3LABlab'],
      'c3nstrkind': ['C3TKmain', 'C3TKtermet_isnat', 'C3TKtermet_isdec', 'C3TKlstate', 'C3TKloop', 'C3TKsolverify', 'C3TKlstate_var', 'C3TKsome_fin'],
      's3itm': ['S3ITMsvar', 'S3ITMsVar', 'S3ITMsolassert'],
      'c3nstr_node': ['C3NSTRprop', 'C3NSTRsolverify'],
      'h3ypo_node': ['H3YPOprop', 'H3YPObind', 'H3YPOeqeq'],
      'lamlp': ['LAMLPloop0'],
    })

    class Sc3(C.Sc):
        def leaf(self, t):
            if t == 'p2atcstlst': return 'mkp2atcstlst (%d)' % self.R.randint(0, 9)
            return C.Sc.leaf(self, t)
        def pools(self):
            for _ in range(4): self.new('s2var')
            for _ in range(2): self.new('s2Var')
            for _ in range(3): self.new('s2cst')
            for _ in range(3): self.new('d2var')
            for _ in range(2): self.new('d2con')
        def loc(self): return self.leaf('location')

    return Sc3

# ---------------------------------------------------------------------------------------------------------------------
# the smart constructors of pats_dynexp3.sats, parsed from the sats
def parse_makers(d):
    txt = open(os.path.join(d, '..', 'pats_dynexp3.sats')).read()
    txt = re.sub(r'\(\*.*?\*\)', '', txt, flags=re.S)
    txt = re.sub(r'//[^\n]*', '', txt)
    res = []
    for m in re.finditer(r'\bfun\s+(\w+)\s*\(([^()]*)\)\s*:\s*(\w+)', txt):
        name, params, ret = m.group(1), m.group(2), m.group(3)
        if not re.match(r'^(p3at_|d3exp_|d3ecl_|d3lab_|i3fcl_|gm3at_|c3lau_|sc3lau_|i3mpdec_|f3undec_|v3aldec_|v3ardec_|prv3ardec_)', name): continue
        if 'make_node' in name: continue
        if ret not in ('p3at','d3exp','d3ecl','d3lab','i3fcl','gm3at','c3lau','sc3lau','i3mpdec','f3undec','v3aldec','v3ardec','prv3ardec'): continue
        ps = []
        for p in params.split(','):
            p = p.strip()
            if not p: continue
            ty = p.split(':')[1].strip()
            ty = {'loc_t': 'location', '$SYN.cstsp': 'cstsp'}.get(ty, ty)
            ps.append(ty)
        if not ps: continue
        res.append((name, ps, ret))
    return res

WNAMES = ['trans3_env_push', 'trans3_env_pop', 'trans3_env_pop_and_add', 'trans3_env_pop_and_add_main', 'the_s2varbindmap_push', 'the_s2varbindmap_pop', 'the_s2cstbindlst_push', 'the_s2cstbindlst_pop', 'the_s2cstbindlst_pop_and_unbind', 'termetenv_push', 'termetenv_push_dvarlst', 'termetenv_pop', 'the_effenv_push', 'the_effenv_push_lam', 'the_effenv_push_set', 'the_effenv_push_effmask', 'the_effenv_pop', 'the_d2varenv_push_lam', 'the_d2varenv_push_let', 'the_d2varenv_push_try', 'the_d2varenv_pop', 'the_lamlpenv_push_lam', 'the_lamlpenv_push_loop0', 'the_lamlpenv_push_loop1', 'the_lamlpenv_pop', 'the_pfmanenv_push_let', 'the_pfmanenv_push_lam', 'the_pfmanenv_push_try', 'the_pfmanenv_pop', 'the_effenv_push_set_if', 'the_effenv_pop_if']
WRE = re.compile(r'(?<![\w])(' + '|'.join(sorted(WNAMES, key=lambda n: -len(n))) + r')(?=\s*\()')
def wrap_text(t):
    return WRE.sub(lambda m: 't_' + m.group(1), t)

def families(G, C, Sc3, d3order, d):
    F = []
    import s2_cases
    S2 = sys.modules["s2_cases2"]
    # ----------------------------------------------------------------------------------------------------------
    def fam_setup(sc, k):
        """the pervasive static constants (the first use of a [the_xxx] fixes the constant), the sup relations of [the_trans3_env_initialize]"""
        perv = []
        for i, (name, args, res) in enumerate(S2.PERV):
            c = S2.perv_cst(sc, name, args, res, i)
            perv.append((name, c))
            sc.do('t_penv_add (mksymname ("%s"), K_S2ITMcst (LC_s2cstlst (%s, LN_s2cstlst ())))' % (name, c))
        sc.do('stacst2_initialize ()')
        sc.do('the_trans3_env_initialize ()')
        for n1, n2 in [('bool_bool_t0ype', 'bool_t0ype'), ('char_int_t0ype', 'char_t0ype'), ('schar_int_t0ype', 'schar_t0ype'), ('uchar_int_t0ype', 'uchar_t0ype'),
                       ('g1int_int_t0ype', 'g0int_t0ype'), ('g1uint_int_t0ype', 'g0uint_t0ype'), ('ptr_addr_type', 'ptr_type'), ('string_int_type', 'string_type'), ('bool_t0ype', 'ptr_type')]:
            cs1 = [c for (nm, c) in perv if nm == n1]; cs2 = [c for (nm, c) in perv if nm == n2]
            sc.say('-- sup ' + n1)
            sc.dd('s2cstlst', 's2cst_get_sup (%s)' % cs1[0])
            sc.dd('s2cstlst', 's2cst_get_sup (%s)' % cs2[0])
        for n in ('bool_t0ype', 'bool_bool_t0ype', 'char_int_t0ype', 'g1int_int_t0ype', 'ptr_addr_type', 'string_int_type'):
            pass
    F.append(('setup', fam_setup, 0))
    # ----------------------------------------------------------------------------------------------------------
    makers = parse_makers(d)
    def maker_calls(sc, depth, reps):
        out = []
        for name, ps, ret in makers:
            for rep in range(reps):
                args = []
                for t in ps:
                    if t == 'int' and name.startswith('d3exp_arrpsz'): args.append('3')
                    else: args.append(sc.gv(t, depth))
                x = sc.val('%s (%s)' % (name, ', '.join(args)), ret)
                out.append((name, ret, x))
        return out
    def fam_tree(sc, k):
        R = sc.R
        sc.pools()
        for name, ret, x in maker_calls(sc, 2, 1):
            sc.dd(ret, x)
            if ret in ('p3at', 'd3exp', 'd3ecl'):
                sc.call('fprint_' + ret, [x], 'fprint'); sc.call('print_' + ret, [x], 'print'); sc.call('prerr_' + ret, [x], 'prerr')
        # every constructor of the nodes through the records, every record
        for n in d3order:
            if n in G.recs:
                for _ in range(2):
                    x = sc.val(sc.record(n, 2), n); sc.dd(n, x)
            else:
                for c, ts in G.types[n]:
                    for _ in range(2):
                        x = sc.val(sc.datatype_con(n, c, 2), n); sc.dd(n, x)
        for t in ('p3atlst', 'd3explst', 'd3eclist', 'labp3atlst', 'labd3explst', 'd3lablst', 'i3fclist', 'gm3atlst', 'c3laulst', 'sc3laulst', 'f3undeclst', 'v3aldeclst', 'v3ardeclst', 'prv3ardeclst'):
            sc.dd(t, sc.gv(t, 2))
        for t in ('p3atopt', 'd3expopt', 'd3eclistopt'):
            sc.dd(t, sc.gv(t, 2)); sc.dd(t, 'ON_%s ()' % t)
        pats = sc.pool.get('p3at', []); exps = sc.pool.get('d3exp', []); decs = sc.pool.get('d3ecl', [])
        for p in pats:
            sc.call('p3at_get_type', [p], 's2exp'); sc.call('p3at_get_dvaropt', [p], 'd2varopt'); sc.call('p3at_get_type_left', [p], 's2expopt')
            for f in ('is_prf', 'is_full', 'is_lincon', 'is_unfold'): sc.call('p3at_' + f, [p], 'bool')
            sc.do('p3at_set_type (%s, %s)' % (p, sc.gv('s2exp', 1)))
            sc.do('p3at_set_dvaropt (%s, %s)' % (p, sc.gv('d2varopt', 1)))
            sc.do('p3at_set_type_left (%s, %s)' % (p, sc.gv('s2expopt', 1)))
            sc.dd('p3at', p)
            for f in ('is_prf', 'is_full'): sc.call('p3at_' + f, [p], 'bool')
        for e in exps:
            sc.call('d3exp_get_type', [e], 's2exp'); sc.call('d3exp_is_prf', [e], 'bool'); sc.call('d3exp_isnot_prf', [e], 'bool')
            sc.do('d3exp_set_type (%s, %s)' % (e, sc.gv('s2exp', 1)))
            sc.dd('d3exp', e)
        ls = [x for n, r, x in [] ]
        for e in exps[:6]:
            sc.do('d3lab_set_overld_app (%s, %s)' % (sc.val('d3lab_lab (%s, %s, ON_d2symopt ())' % (sc.loc(), sc.leaf('label')), 'd3lab'), sc.gv('d3expopt', 1)))
        for lab in sc.pool.get('d3lab', []): sc.dd('d3lab', lab)
        for n in range(4):
            l = sc.lst('d3explst', R.sample(exps, min(len(exps), R.randint(0, 4))))
            sc.call('d3explst_get_type', [l], 's2explst'); sc.call('d3explst_get_labtype', [l], 'labs2explst')
            sc.call('fprint_d3explst', [l], 'fprint')
        sc.call('fprint_p3atlst', [sc.lst('p3atlst', pats[:4])], 'fprint')
        sc.call('fprint_p3atlst', [sc.lst('p3atlst', [])], 'fprint')
        sc.dd('p3at', 'p3at_make_node (%s, %s, %s)' % (sc.loc(), sc.gv('s2exp', 1), sc.datatype_con('p3at_node', 'P3Tany', 1)))
        sc.dd('d3ecl', 'd3ecl_make_node (%s, %s)' % (sc.loc(), sc.datatype_con('d3ecl_node', 'D3Cnone', 1)))
        # d3exp_con: arguments that are tops make a [datcontyp]
        for _ in range(4):
            args = [sc.val('d3exp_top (%s, %s)' % (sc.loc(), sc.gv('s2exp', 1)), 'd3exp'), sc.gv('d3exp', 1)]
            R.shuffle(args)
            e = sc.val('d3exp_con (%s, %s, %s, 1, %s)' % (sc.loc(), sc.gv('s2exp', 1), sc.handle('d2con'), sc.lst('d3explst', args)), 'd3exp')
            sc.dd('d3exp', e)
        for _ in range(3):
            e = sc.val('d3exp_con (%s, %s, %s, 0, %s)' % (sc.loc(), sc.gv('s2exp', 1), sc.handle('d2con'), sc.lst('d3explst', [])), 'd3exp')
            sc.dd('d3exp', e)
        for nd in ('S2Euni', 'S2Emetfun', 'S2Eint', 'S2Eapp'):
            t = sc.val('K_s2exp (s2rt_t0ype, %s)' % sc.datatype_con('s2exp_node', nd, 1), 's2exp') if nd in ('S2Euni', 'S2Emetfun') else sc.gv('s2exp', 1)
            e = sc.val('d3exp_app_unista (%s, %s, d3exp_var (%s, %s, %s))' % (sc.loc(), sc.gv('s2exp', 1), sc.loc(), t, sc.handle('d2var')), 'd3exp')
            sc.dd('d3exp', e)
    F.append(('tree', fam_tree, 2))
    # ----------------------------------------------------------------------------------------------------------
    def fam_rec(sc, k):
        """the complete dumpers of the types of the env spec"""
        sc.pools()
        for n in d3order:
            pass
    # ----------------------------------------------------------------------------------------------------------
    def fam_cnstr(sc, k):
        R = sc.R
        sc.pools()
        loc = sc.loc
        cs = []
        cs.append(sc.val('c3nstr_prop (%s, %s)' % (loc(), sc.gv('s2exp', 1)), 'c3nstr'))
        for _ in range(3):
            cs.append(sc.val('c3nstr_itmlst (%s, %s, %s)' % (loc(), sc.gv('c3nstrkind', 1), sc.gv('s3itmlst', 2)), 'c3nstr'))
        cs.append(sc.val('c3nstr_termet_isnat (%s, %s)' % (loc(), sc.gv('s2exp', 1)), 'c3nstr'))
        cs.append(sc.val('c3nstr_termet_isdec (%s, %s, %s)' % (loc(), sc.gv('s2explst', 1), sc.gv('s2explst', 1)), 'c3nstr'))
        cs.append(sc.val('c3nstr_solverify (%s, %s)' % (loc(), sc.gv('s2exp', 1)), 'c3nstr'))
        for i in range(3):
            cs.append(sc.val('c3nstr_case_exhaustiveness (%s, mkcaskind (%d), p2tcs)' % (loc(), i), 'c3nstr') if False else sc.val('t_c3exh (%s, mkcaskind (%d), %d)' % (loc(), i, i), 'c3nstr'))
        for c in cs:
            sc.dd('c3nstr', c)
            sc.call('fprint_c3nstr', [c], 'fprint'); sc.call('print_c3nstr', [c], 'print'); sc.call('prerr_c3nstr', [c], 'prerr')
        for n, ts in G.types['c3nstrkind'][0:0]: pass
        for c, ts in G.types['c3nstrkind']:
            kk = sc.val(sc.datatype_con('c3nstrkind', c, 1), 'c3nstrkind'); sc.dd('c3nstrkind', kk); sc.call('fprint_c3nstrkind', [kk], 'fprint')
        hs = [sc.val('h3ypo_prop (%s, %s)' % (loc(), sc.gv('s2exp', 1)), 'h3ypo'),
              sc.val('h3ypo_bind (%s, %s, s2exp2hnf (%s))' % (loc(), sc.handle('s2var'), sc.gv('s2exp', 1)), 'h3ypo'),
              sc.val('h3ypo_eqeq (%s, s2exp2hnf (%s), s2exp2hnf (%s))' % (loc(), sc.gv('s2exp', 1), sc.gv('s2exp', 1)), 'h3ypo')]
        for h in hs:
            sc.dd('h3ypo', h); sc.call('fprint_h3ypo', [h], 'fprint'); sc.call('print_h3ypo', [h], 'print'); sc.call('prerr_h3ypo', [h], 'prerr')
        for _ in range(8):
            x = sc.val(sc.datatype_con('s3itm', R.choice([c for c, ts in G.types['s3itm']]), 2), 's3itm')
            sc.dd('s3itm', x); sc.call('fprint_s3itm', [x], 'fprint')
        r = sc.val('c3nstroptref_make_none (%s)' % loc(), 'c3nstroptref'); sc.dd('c3nstroptref', r)
        sc.call('fprint_s3itm', [sc.val('K_S3ITMcnstr_ref (%s)' % r, 's3itm')], 'fprint')
        sc.call('fprint_s3itmlst', [sc.gv('s3itmlst', 2)], 'fprint')
        sc.call('fprint_s3itmlstlst', [sc.gv('s3itmlstlst', 2)], 'fprint')
        for n in ('c3nstropt', 'lstbefitmlst', 'lamlplst'):
            sc.dd(n, sc.gv(n, 2))
        for n in ('lstbefitm', 'lamlp'):
            pass
        for c, ts in G.types['lamlp']:
            x = sc.val(sc.datatype_con('lamlp', c, 1), 'lamlp'); sc.dd('lamlp', x)
        x = sc.val(sc.record('lstbefitm', 1), 'lstbefitm'); sc.dd('lstbefitm', x)
        for d2v in sc.pool['d2var'][:2]:
            lb = sc.val('lstbefitm_make (%s, %d)' % (d2v, R.choice([0, 1, 2])), 'lstbefitm'); sc.dd('lstbefitm', lb)
            sc.call('fprint_lstbefitm', [lb], 'fprint')
        sc.call('fprint_lstbefitmlst', [sc.gv('lstbefitmlst', 2)], 'fprint')
    F.append(('cnstr', fam_cnstr, 2))

    # ----------------------------------------------------------------------------------------------------------
    # helpers for the environment scenarios
    def srt(sc): return sc.R.choice(C.PRESORTS)
    def S(sc, t, d=1): return sc.gv(t, d)
    def quant(sc, kind, depth=1, body=None):
        """a quantified static expression: kind 'S2Euni' / 'S2Eexi' (the bound variables are fresh cells of the scenario)"""
        R = sc.R
        e = body if body else S(sc, 's2exp')
        for _ in range(depth):
            vs = [sc.val('s2var_make_srt (%s)' % srt(sc), 's2var') for _ in range(R.choice([1, 2, 2]))]
            e = sc.val('K_s2exp (%s, K_%s (%s, %s, %s))' % (R.choice(['s2rt_type', 's2rt_t0ype', 's2rt_prop']), kind, sc.lst('s2varlst', vs), S(sc, 's2explst'), e), 's2exp')
        return e
    def dumpenv(sc, label):
        sc.say(label)
        sc.do('(fprint_the_s3itmlst (dd_out); dd_nl ())')
        sc.do('(fprint_the_s3itmlstlst (dd_out); dd_nl ())')
    def popdump(sc):
        sc.do('(dd_listvt_s3itm (trans3_env_pop ()); dd_nl ())')
    def metfun(sc, d2v=None, nmet=1):
        R = sc.R
        mets = sc.lst('s2explst', [sc.val('K_s2exp (s2rt_int, K_S2Eint (%d))' % R.randint(0, 5), 's2exp') for _ in range(nmet)])
        stamp = 'OS_stampopt (d2var_get_stamp (%s))' % d2v if d2v else 'ON_stampopt ()'
        return sc.val('K_s2exp (s2rt_type, K_S2Emetfun (%s, %s, %s))' % (stamp, mets, S(sc, 's2exp')), 's2exp')
    def funty(sc, res):
        R = sc.R
        return sc.val('K_s2exp (s2rt_type, K_S2Efun (mkfunclo (%d), %d, K_S2EFFset (mkeffset (%d)), %d, %s, %s))' % (
            R.randint(0, 3), R.choice([0, 1]), R.randint(0, 4), R.choice([0, 1]), S(sc, 's2explst'), res), 's2exp')
    # ----------------------------------------------------------------------------------------------------------
    def fam_inst(sc, k):
        R = sc.R
        sc.pools()
        loc = sc.loc
        for rep in range(6):
            sc.do('trans3_env_push ()')
            e = quant(sc, 'S2Euni', R.choice([1, 2]), quant(sc, 'S2Eexi', 1) if R.random() < 0.5 else None)
            e2 = quant(sc, 'S2Eexi', R.choice([1, 2]), quant(sc, 'S2Euni', 1) if R.random() < 0.5 else None)
            for knd in (0, 1, 3, 4):
                sc.do('t_inst (%d, %s, %s)' % (knd, R.choice([e, e2]), loc()))
            # the metrics: the stamp is the one of a d2var that is in the termet environment
            d2v = sc.handle('d2var')
            sc.do('termetenv_push_dvarlst (%s, %s)' % (sc.lst('d2varlst', [d2v]), sc.lst('s2explst', [sc.val('K_s2exp (s2rt_int, K_S2Eint (%d))' % R.randint(0, 3), 's2exp')])))
            mf = quant(sc, 'S2Euni', 1, metfun(sc, d2v, R.choice([1, 2])))
            sc.do('t_inst (2, %s, %s)' % (mf, loc()))
            mf2 = quant(sc, 'S2Euni', 1, metfun(sc, None))
            sc.do('t_inst (2, %s, %s)' % (mf2, loc()))
            sc.do('t_inst (2, %s, %s)' % (e, loc()))
            sc.do('termetenv_pop ()')
            for _ in range(3):
                sc.do('t_inst_sexparg (%s, %s)' % (R.choice([e2, S(sc, 's2exp'), quant(sc, 'S2Eexi', 1)]), S(sc, 's2exparg')))
            for _ in range(3):
                sc.do('t_inst_sexparglst (%s, %s)' % (R.choice([e, quant(sc, 'S2Euni', 2)]), S(sc, 's2exparglst')))
            qs = sc.lst('s2qualst', ['K_s2qua (%s, LN_s2explst ())' % sc.lst('s2varlst', [sc.handle('s2var', 0.3) for _ in range(R.randint(0, 2))]) for _ in range(R.randint(0, 3))])
            ms = sc.lst('t2mpmarglst', ['K_t2mpmarg (%s, %s)' % (loc(), sc.lst('s2explst', [S(sc, 's2exp') for _ in range(R.randint(0, 3))])) for _ in range(R.randint(0, 3))])
            sc.do('t_tmp_rest (%s, %s, %s)' % (S(sc, 's2exp'), loc(), qs))
            sc.do('t_tmp_tmparg (%s, %s, %s, %s)' % (S(sc, 's2exp'), loc(), qs, ms))
            sc.do('t_stasub (%s, %s)' % (loc(), sc.lst('s2varlst', [sc.handle('s2var', 0.3) for _ in range(R.randint(0, 3))])))
            sc.dd('s2exp', 's2exp_Var_make_srt (%s, %s)' % (loc(), srt(sc)))
            sc.dd('s2exp', 's2exp_Var_make_var (%s, %s)' % (loc(), sc.handle('s2var')))
            sc.do('(fprint_the_s3itmlst (dd_out); dd_nl ())')
            popdump(sc)
            sc.do('t3chk ()')
    F.append(('inst', fam_inst, 3))
    # ----------------------------------------------------------------------------------------------------------
    def fam_scope(sc, k):
        """the scopes: push/pop, the items, the hypotheses, the bindings of the static variables, the constraints"""
        R = sc.R
        sc.pools()
        loc = sc.loc
        vs = sc.pool['s2var']; Vs = sc.pool['s2Var']
        depth = 0
        def op_add():
            c = R.randint(0, 17)
            if c == 0: sc.do('trans3_env_add_svar (%s)' % R.choice(vs))
            elif c == 1: sc.do('trans3_env_add_svarlst (%s)' % sc.lst('s2varlst', R.sample(vs, R.randint(0, 3))))
            elif c == 2: sc.do('trans3_env_add_squa (%s)' % S(sc, 's2qua'))
            elif c == 3: sc.do('trans3_env_add_squalst (%s)' % S(sc, 's2qualst'))
            elif c == 4: sc.do('trans3_env_add_sp2at (%s)' % S(sc, 'sp2at'))
            elif c == 5: sc.do('trans3_env_add_sVar (%s)' % R.choice(Vs))
            elif c == 6: sc.do('trans3_env_add_sVarlst (%s)' % sc.lst('s2Varlst', Vs))
            elif c == 7: sc.do('trans3_env_add_cnstr (c3nstr_prop (%s, %s))' % (loc(), S(sc, 's2exp')))
            elif c == 8: sc.do('trans3_env_add_cnstr (c3nstr_termet_isnat (%s, %s))' % (loc(), S(sc, 's2exp')))
            elif c == 9: sc.do('trans3_env_add_cnstr_ref (c3nstroptref_make_none (%s))' % loc())
            elif c == 10: sc.do('trans3_env_add_prop (%s, %s)' % (loc(), S(sc, 's2exp')))
            elif c == 11: sc.do('trans3_env_add_proplst (%s, %s)' % (loc(), S(sc, 's2explst')))
            elif c == 12: sc.do('trans3_env_add_proplst_vt (%s, vt_s2explst (%s))' % (loc(), S(sc, 's2explst')))
            elif c == 13: sc.do('trans3_env_add_eqeq (%s, %s, %s)' % (loc(), S(sc, 's2exp'), S(sc, 's2exp')))
            elif c == 14: sc.do('trans3_env_solver_assert (%s, %s)' % (loc(), S(sc, 's2exp')))
            elif c == 15: sc.do('trans3_env_solver_verify (%s, %s)' % (loc(), S(sc, 's2exp')))
            elif c == 16: sc.do('trans3_env_add_cnstr (t_c3exh (%s, mkcaskind (%d), %d))' % (loc(), R.randint(0, 2), R.randint(0, 9)))
            else: sc.do('trans3_env_add_cnstr (c3nstr_solverify (%s, %s))' % (loc(), S(sc, 's2exp')))
        def op_hyp():
            c = R.randint(0, 9)
            if c == 0: sc.do('trans3_env_hypadd_prop (%s, %s)' % (loc(), S(sc, 's2exp')))
            elif c == 1: sc.do('trans3_env_hypadd_proplst (%s, %s)' % (loc(), S(sc, 's2explst')))
            elif c == 2: sc.do('trans3_env_hypadd_proplst_vt (%s, vt_s2explst (%s))' % (loc(), S(sc, 's2explst')))
            elif c == 3: sc.do('trans3_env_hypadd_propopt (%s, %s)' % (loc(), S(sc, 's2expopt')))
            elif c == 4: sc.do('trans3_env_hypadd_propopt_neg (%s, %s)' % (loc(), S(sc, 's2expopt')))
            elif c == 5: sc.do('trans3_env_hypadd_bind (%s, %s, s2exp2hnf (%s))' % (loc(), R.choice(vs), S(sc, 's2exp')))
            elif c == 6: sc.do('trans3_env_hypadd_eqeq (%s, s2exp2hnf (%s), s2exp2hnf (%s))' % (loc(), S(sc, 's2exp'), S(sc, 's2exp')))
            elif c == 7:
                v = R.choice(vs)
                sc.do('the_s2varbindmap_insert (%s, s2exp2hnf (%s))' % (R.choice(vs), S(sc, 's2exp')))
                sc.dd('s2exp', 's2exp_hnfize (K_s2exp (s2rt_t0ype, K_S2Evar (%s)))' % v)
                sc.dd('s2exp', 's2exp_hnfize (K_s2exp (s2rt_t0ype, K_S2Eapp (s2exp_cst (%s), %s)))' % (sc.handle('s2cst'), sc.lst('s2explst', [sc.val('K_s2exp (s2rt_t0ype, K_S2Evar (%s))' % R.choice(vs), 's2exp')])))
            elif c == 8:
                sc.call('the_s2varbindmap_search', [R.choice(vs)], 'optvt_s2exp') if False else sc.do('(dd_optvt_s2exp (the_s2varbindmap_search (%s)); dd_nl ())' % R.choice(vs))
            else:
                e = S(sc, 's2exp')
                sc.dd('bool', 's2var_occurcheck_s2exp (%s, %s)' % (R.choice(vs), e))
                sc.dd('bool', 's2var_occurcheck_s2exp (%s, K_s2exp (s2rt_t0ype, K_S2Eapp (s2exp_cst (%s), %s)))' % (R.choice(vs), sc.handle('s2cst'), sc.lst('s2explst', [sc.val('K_s2exp (s2rt_t0ype, K_S2Evar (%s))' % R.choice(vs), 's2exp')])))
        for step in range(R.randint(14, 24)):
            r = R.random()
            if r < 0.18 or depth == 0:
                sc.do('trans3_env_push ()'); depth += 1
            elif r < 0.36 and depth > 0:
                c = R.randint(0, 2)
                if c == 0: popdump(sc)
                elif c == 1: sc.do('trans3_env_pop_and_add_main (%s)' % loc())
                else: sc.do('trans3_env_pop_and_add (%s, %s)' % (loc(), S(sc, 'c3nstrkind')))
                depth -= 1
            elif r < 0.62: op_add()
            else: op_hyp()
            if step % 5 == 4:
                dumpenv(sc, '-- env')
        while depth > 0:
            popdump(sc); depth -= 1
        sc.do('trans3_env_push ()')
        op_add(); op_add(); op_hyp()
        sc.do('(fprint_the_s2varbindmap (dd_out); dd_nl ())')
        sc.do('the_s2varbindmap_freetop ()')
        sc.do('(fprint_the_s2varbindmap (dd_out); dd_nl ())')
        sc.do('trans3_env_pop_and_add_main (%s)' % loc())
        sc.dd('c3nstr', 'the_trans3_finget_constraint ()')
        sc.do('t3chk ()')
    F.append(('scope', fam_scope, 4))
    # ----------------------------------------------------------------------------------------------------------
    def pat_pair(sc, i, d2c, dcs):
        """a pattern constraint and a type that fits it (or not)"""
        R = sc.R
        v = sc.handle('s2var')
        ind = 'K_s2exp (s2rt_int, K_S2Evar (%s))' % v
        kind = R.choice(['int', 'intc', 'bool', 'char', 'charc', 'rec', 'con', 'con2', 'other', 'any', 'float'])
        if kind == 'int': return 'mkp2atcst0 (2)', 's2exp_int_index_t0ype (%s)' % ind
        if kind == 'intc': return 'mkp2atcst0 (6)', 's2exp_int_index_t0ype (%s)' % ind
        if kind == 'bool': return 'mkp2atcst0 (3)', 's2exp_bool_index_t0ype (%s)' % ind
        if kind == 'char': return 'mkp2atcst0 (4)', 's2exp_char_index_t0ype (%s)' % ind
        if kind == 'charc': return 'mkp2atcst0 (7)', 's2exp_char_index_t0ype (%s)' % ind
        if kind == 'float': return 'mkp2atcst0 (8)', S(sc, 's2exp')
        if kind == 'any': return 'mkp2atcst0 (0)', S(sc, 's2exp')
        if kind == 'rec':
            fields = sc.lst('labs2explst', ['K_labs2exp (mklab (%d), ON_stringopt (), s2exp_int_index_t0ype (%s))' % (2 * j, ind) for j in R.sample(range(3), R.randint(1, 3))])
            return 'mkp2atcst0 (9)', 'K_s2exp (s2rt_t0ype, K_S2Etyrec (K_TYRECKINDbox (), 0, %s))' % fields
        if kind == 'con':
            c1 = R.choice(dcs)
            return 'mkp2atcst_con (%s, %d)' % (d2c, R.randint(0, 4)), 'K_s2exp (s2rt_t0ype, K_S2Edatcontyp (%s, LN_s2explst ()))' % c1
        if kind == 'con2':
            return 'mkp2atcst_con (%s, %d)' % (d2c, R.randint(0, 4)), 'K_s2exp (s2rt_t0ype, K_S2Eapp (s2exp_cst (%s), %s))' % (sc.handle('s2cst'), sc.lst('s2explst', [S(sc, 's2exp')]))
        return 'mkp2atcst0 (%d)' % R.randint(0, 9), S(sc, 's2exp')
    def fam_pat(sc, k):
        R = sc.R
        sc.pools()
        loc = sc.loc
        # constructors with a function type: a constant with a function sort
        dcs = []
        for j in range(3):
            c = S2.perv_cst(sc, 'fc%d_%d' % (k, j), ['t0ype'] * (j + 1), 't0ype', j)
            dcs.append(sc.val('d2con_make (%s, mkfil (0), mksym (%d), %s, 0, LN_s2qualst (), 0, %s, ON_s2explstopt ())' % (
                loc(), j, c, sc.lst('s2explst', [S(sc, 's2exp') for _ in range(j + 1)])), 'd2con'))
        sc.do('trans3_env_push ()')
        for rep in range(14):
            p, e = pat_pair(sc, rep, R.choice(dcs), dcs)
            sc.do('trans3_env_hypadd_patcst (%s, %s, %s)' % (loc(), p, e))
            if rep % 3 == 2:
                dumpenv(sc, '-- patcst')
        for rep in range(6):
            n1 = R.randint(0, 4); n2 = R.randint(0, 4)
            es = sc.lst('s2explst', [pat_pair(sc, 0, dcs[0], dcs)[1] for _ in range(n2)])
            sc.do('trans3_env_hypadd_patcstlst (%s, vt_p2atcstlst (%s), %s)' % (loc(), sc.lst('p2atcstlst', [pat_pair(sc, 0, dcs[0], dcs)[0] for _ in range(n1)]) if False else 'mkp2atcstlst (%d)' % R.randint(0, 9), es))
            sc.do('t3chk ()')
        for rep in range(5):
            sc.do('trans3_env_hypadd_labpatcstlst (%s, mk_lp2tcs_n (%d), %s)' % (loc(), R.randint(0, 4), sc.lst('labs2explst', [
                'K_labs2exp (mklab (%d), ON_stringopt (), s2exp_int_index_t0ype (K_s2exp (s2rt_int, K_S2Evar (%s))))' % (2 * j, sc.handle('s2var')) for j in R.sample(range(5), R.randint(0, 5))])))
        for rep in range(3):
            es = sc.lst('s2explst', [pat_pair(sc, 0, dcs[0], dcs)[1] for _ in range(R.randint(0, 3))])
            sc.do('trans3_env_hypadd_patcstlstlst (%s, mk_p2tcss_vt (%d), %s)' % (loc(), R.randint(0, 6), es))
            sc.do('t3chk ()')
        for rep in range(3):
            es = sc.lst('s2explst', [pat_pair(sc, 0, dcs[0], dcs)[1] for _ in range(R.randint(0, 3))])
            sc.do('trans3_env_add_patcstlstlst_false (%s, mkcaskind (%d), mk_p2tcss_vt (%d), %s)' % (loc(), R.randint(0, 2), R.randint(0, 6), es))
            sc.do('t3chk ()')
        dumpenv(sc, '-- end')
        popdump(sc)
    F.append(('pat', fam_pat, 3))
    # ----------------------------------------------------------------------------------------------------------
    def fam_termet(sc, k):
        R = sc.R
        sc.pools()
        loc = sc.loc
        sc.do('trans3_env_push ()')
        ds = sc.pool['d2var']
        for rep in range(5):
            d1 = R.choice(ds); d2 = R.choice(ds)
            mets = sc.lst('s2explst', [sc.val('K_s2exp (%s, K_S2Eint (%d))' % (R.choice(['s2rt_int', 's2rt_int', 's2rt_bool']), R.randint(0, 3)), 's2exp') for _ in range(R.randint(0, 3))])
            sc.do('termetenv_push_dvarlst (%s, %s)' % (sc.lst('d2varlst', [d1, d2][:R.randint(0, 2)]), mets))
            sc.do('s2explst_check_termet (%s, %s)' % (loc(), mets))
            sc.do('(dd_optvt_s2explst (termetenv_get_termet (d2var_get_stamp (%s))); dd_nl ())' % d1)
            sc.do('(dd_optvt_s2explst (termetenv_get_termet (d2var_get_stamp (%s))); dd_nl ())' % d2)
            sc.do('s2exp_termet_instantiate (%s, d2var_get_stamp (%s), %s)' % (loc(), R.choice(ds), mets))
            if R.random() < 0.5:
                sc.do('termetenv_pop ()')
            e = quant(sc, 'S2Euni', 1, metfun(sc, R.choice(ds), 1)) if R.random() < 0.5 else funty(sc, metfun(sc, R.choice(ds), 2))
            e = e if R.random() < 0.7 else quant(sc, 'S2Euni', 1, funty(sc, metfun(sc, R.choice(ds), 1)))
            sc.do('(dd_optvt_metfun (s2exp_metfun_load (%s, %s)); dd_nl ())' % (e, R.choice(ds)))
            sc.do('(dd_optvt_metfun (s2exp_metfun_load (%s, %s)); dd_nl ())' % (S(sc, 's2exp'), R.choice(ds)))
        dumpenv(sc, '-- termet')
        popdump(sc)
        # the static constants that are bound
        sc.do('the_s2cstbindlst_push ()')
        cs = sc.pool['s2cst']
        for rep in range(8):
            c = R.choice(cs)
            if R.random() < 0.3: sc.do('s2cst_set_isasp (%s, OS_s2expopt (%s))' % (c, S(sc, 's2exp')))
            op = R.randint(0, 4)
            if op == 0: sc.do('the_s2cstbindlst_add (%s)' % c)
            elif op == 1: sc.do('the_s2cstbindlst_addlst (vt_s2cstlst (%s))' % sc.lst('s2cstlst', R.sample(cs, R.randint(0, 3))))
            elif op == 2: sc.do('the_s2cstbindlst_bind_and_add (%s, %s, s2exp2hnf (%s))' % (loc(), c, S(sc, 's2exp')))
            elif op == 3:
                sc.do('the_s2cstbindlst_push ()')
                sc.do('the_s2cstbindlst_bind_and_add (%s, %s, s2exp2hnf (%s))' % (loc(), R.choice(cs), S(sc, 's2exp')))
                sc.do('(dd_listvt_s2cst (the_s2cstbindlst_pop ()); dd_nl ())')
            else:
                sc.do('the_s2cstbindlst_push ()')
                sc.do('the_s2cstbindlst_bind_and_add (%s, %s, s2exp2hnf (%s))' % (loc(), R.choice(cs), S(sc, 's2exp')))
                sc.do('the_s2cstbindlst_pop_and_unbind ()')
            for c1 in cs:
                sc.dd('s2expopt', 's2cst_get_def (%s)' % c1); sc.dd('s2expopt', 's2cst_get_isasp (%s)' % c1)
        sc.do('(dd_listvt_s2cst (the_s2cstbindlst_pop ()); dd_nl ())')
        sc.do('(dd_listvt_s2cst (the_s2cstbindlst_pop ()); dd_nl ())')
        sc.do('t3chk ()')
    F.append(('termet', fam_termet, 2))
    # ----------------------------------------------------------------------------------------------------------
    def fam_effect(sc, k):
        R = sc.R
        sc.pools()
        loc = sc.loc
        depth = 0
        def check():
            c = R.randint(0, 11)
            if c == 0: sc.dd('int', 'the_effenv_check_set (%s, mkeffset (%d))' % (loc(), R.randint(0, 4)))
            elif c == 1: sc.dd('int', 'the_effenv_check_eff (%s, mkeffect (%d))' % (loc(), R.randint(0, 3)))
            elif c == 2: sc.dd('int', 'the_effenv_check_exn (%s)' % loc())
            elif c == 3: sc.dd('int', 'the_effenv_check_ntm (%s)' % loc())
            elif c == 4: sc.dd('int', 'the_effenv_check_ref (%s)' % loc())
            elif c == 5: sc.dd('int', 'the_effenv_check_wrt (%s)' % loc())
            elif c == 6: sc.dd('int', 'the_effenv_caskind_check_exn (%s, mkcaskind (%d))' % (loc(), R.randint(0, 2)))
            elif c == 7: sc.dd('int', 'the_effenv_check_sexp (%s, %s)' % (loc(), S(sc, 's2exp')))
            elif c == 8: sc.dd('int', 'the_effenv_check_s2eff (%s, %s)' % (loc(), S(sc, 's2eff')))
            elif c == 9: sc.dd('int', 'the_effenv_check_s2eff (%s, K_S2EFFadd (K_S2EFFset (mkeffset (%d)), K_S2EFFset (mkeffset (%d))))' % (loc(), R.randint(0, 4), R.randint(0, 4)))
            elif c == 10: sc.dd('int', 'the_effenv_check_s2eff (%s, K_S2EFFexp (%s))' % (loc(), quant(sc, 'S2Euni', 0) if False else S(sc, 's2exp')))
            else: sc.dd('int', 'the_effenv_check_sexp (%s, K_s2exp (s2rt_t0ype, K_S2Eeff (K_S2EFFset (mkeffset (%d)))))' % (loc(), R.randint(0, 4)))
        sc.do('trans3_env_push ()')
        flags = []
        for step in range(R.randint(30, 50)):
            r = R.random()
            if r < 0.14 or depth == 0:
                c = R.randint(0, 5)
                if c == 0: sc.do('the_effenv_push ()')
                elif c == 1: sc.do('the_effenv_push_lam (%s)' % S(sc, 's2eff'))
                elif c == 2: sc.do('the_effenv_push_set (mkeffset (%d))' % R.randint(0, 4))
                elif c == 3: sc.do('the_effenv_push_effmask (K_S2EFFset (mkeffset (%d)))' % R.randint(0, 4))
                elif c == 4: sc.do('the_effenv_push_effmask (%s)' % S(sc, 's2eff'))
                else:
                    t = R.choice(['true', 'false']); flags.append(t)
                    sc.do('the_effenv_push_set_if (%s, mkeffset (%d))' % (t, R.randint(0, 4)))
                    depth += 1
                    # the pop of this push is [pop_if] with the same test
                    sc.do('the_effenv_pop_if (%s)' % t)
                    depth -= 1
                    continue
                depth += 1
            elif r < 0.30 and depth > 0:
                sc.do('the_effenv_pop ()'); depth -= 1
            elif r < 0.38:
                sc.do('the_effenv_add_eff (mkeffect (%d))' % R.randint(0, 3))
            else:
                check()
        while depth > 0:
            sc.do('the_effenv_pop ()'); depth -= 1
        check()
        popdump(sc)
        sc.do('t3chk ()')
    F.append(('effect', fam_effect, 3))

    # ----------------------------------------------------------------------------------------------------------
    def setup_dvars(sc, n=5):
        """d2vars with a linear value, a type and a finalization kind"""
        R = sc.R
        vs = [sc.new('d2var') for _ in range(n)]
        for v in vs:
            sc.do('d2var_set_linval (%s, %d)' % (v, R.choice([-1, 0, 1, 1, 2])))
            r = R.random()
            if r < 0.7: sc.do('d2var_set_type (%s, OS_s2expopt (%s))' % (v, S(sc, 's2exp')))
            else: sc.do('d2var_set_type (%s, ON_s2expopt ())' % v)
            sc.do('d2var_set_finknd (%s, %s)' % (v, R.choice([
                'K_D2VFINnone ()', 'K_D2VFINsome (%s)' % S(sc, 's2exp'), 'K_D2VFINsome_lvar (%s)' % S(sc, 's2exp'),
                'K_D2VFINsome_vbox (%s)' % S(sc, 's2exp'), 'K_D2VFINdone (K_D2VFINnone ())', 'K_D2VFINdone (K_D2VFINsome (%s))' % S(sc, 's2exp')])))
            if R.random() < 0.3: sc.do('d2var_set_addr (%s, %s)' % (v, S(sc, 's2expopt')))
        return vs
    def fam_dvar(sc, k):
        R = sc.R
        sc.pools()
        loc = sc.loc
        vs = setup_dvars(sc)
        nl = sc.val('d2var_make (%s, mksym (1))' % loc(), 'd2var')
        sc.do('d2var_set_type (%s, OS_s2expopt (K_s2exp (s2rt_t0ype, K_S2Eint (0))))' % nl)
        sc.do('d2var_set_linval (%s, 1)' % nl)
        sc.do('trans3_env_push ()')
        depth = 0
        def enter():
            c = R.randint(0, 3)
            if c == 0: sc.do('the_d2varenv_push_let ()')
            elif c == 1: sc.do('the_d2varenv_push_lam (1)')
            elif c == 2: sc.do('the_d2varenv_push_lam (0)')
            else: sc.do('the_d2varenv_push_try ()')
        def add():
            c = R.randint(0, 5)
            if c == 0: sc.do('the_d2varenv_add_dvar (%s)' % R.choice(vs))
            elif c == 1: sc.do('the_d2varenv_add_dvarlst (%s)' % sc.lst('d2varlst', R.sample(vs, R.randint(0, 3))))
            elif c == 2: sc.do('the_d2varenv_add_dvaropt (%s)' % S(sc, 'd2varopt'))
            elif c == 3: sc.do('the_d2varenv_add_dvaropt (OS_d2varopt (%s))' % R.choice(vs))
            elif c == 4: sc.do('the_d2varenv_add_p3at (%s)' % S(sc, 'p3at', 2))
            else: sc.do('the_d2varenv_add_p3atlst (%s)' % S(sc, 'p3atlst', 2))
        for step in range(R.randint(12, 20)):
            r = R.random()
            if r < 0.25 or depth == 0:
                enter(); depth += 1
            elif r < 0.4 and depth > 0:
                sc.do('the_d2varenv_pop ()'); depth -= 1
            elif r < 0.7: add()
            elif r < 0.8: sc.dd('bool', 'the_d2varenv_d2var_is_llamlocal (%s)' % R.choice(vs))
            elif r < 0.88:
                sc.do('(dd_listvt_d2var (the_d2varenv_get_top ()); dd_nl ())')
            elif r < 0.94:
                sc.do('(dd_listvt_d2var (the_d2varenv_get_llamd2vs ()); dd_nl ())')
            else:
                sc.dd('lstbefitmlst', 'the_d2varenv_save_lstbefitmlst ()')
        # save, change, restore
        for rep in range(2):
            for v in vs: add_ = sc.do('the_d2varenv_add_dvar (%s)' % v)
            lb = sc.val('the_d2varenv_save_lstbefitmlst ()', 'lstbefitmlst')
            sc.dd('lstbefitmlst', lb); sc.call('fprint_lstbefitmlst', [lb], 'fprint')
            for v in vs:
                sc.do('d2var_set_type (%s, %s)' % (v, S(sc, 's2expopt')))
                sc.do('d2var_set_linval (%s, %d)' % (v, R.choice([-1, 0, 1])))
            sc.do('lstbefitmlst_restore_type (%s)' % lb)
            for v in vs: sc.do('chk_d2var (%s)' % v)
            for v in vs: sc.do('d2var_set_type (%s, ON_s2expopt ())' % v)
            sc.do('lstbefitmlst_restore_linval_type (%s)' % lb)
            for v in vs: sc.do('chk_d2var (%s)' % v)
        # the finalization checks (they solve, add constraints, report the errors)
        for v in vs: sc.do('the_d2varenv_add_dvar (%s)' % v)
        sc.do('the_d2varenv_check (%s)' % loc())
        for v in vs: sc.do('chk_d2var (%s)' % v)
        sc.do('the_d2varenv_push_lam (1)')
        sc.do('the_d2varenv_add_dvar (%s)' % nl)
        sc.do('the_d2varenv_add_dvar (%s)' % R.choice(vs))
        sc.dd('bool', 'the_d2varenv_d2var_is_llamlocal (%s)' % nl)
        sc.do('the_d2varenv_push_lam (1)')
        sc.dd('bool', 'the_d2varenv_d2var_is_llamlocal (%s)' % nl)
        sc.do('(dd_listvt_d2var (the_d2varenv_get_llamd2vs ()); dd_nl ())')
        sc.do('the_d2varenv_pop ()')
        sc.do('(dd_listvt_d2var (the_d2varenv_get_llamd2vs ()); dd_nl ())')
        sc.do('the_d2varenv_pop ()')
        # the check of a llam: only variables that are not linear are left
        sc.do('the_d2varenv_push_let ()')
        sc.do('the_d2varenv_add_dvar (%s)' % nl)
        sc.do('the_d2varenv_push_lam (1)')
        sc.dd('bool', 'the_d2varenv_d2var_is_llamlocal (%s)' % nl)
        sc.do('the_d2varenv_check_llam (%s)' % loc())
        sc.do('chk_d2var (%s)' % nl)
        sc.do('the_d2varenv_pop ()')
        sc.do('the_d2varenv_pop ()')
        while depth > 0:
            sc.do('the_d2varenv_pop ()'); depth -= 1
        dumpenv(sc, '-- dvar')
        popdump(sc)
        sc.do('t3chk ()')
    F.append(('dvar', fam_dvar, 3))
    # ----------------------------------------------------------------------------------------------------------
    def fam_mut(sc, k):
        R = sc.R
        sc.pools()
        loc = sc.loc
        vs = setup_dvars(sc, 4)
        sc.do('trans3_env_push ()')
        for v in vs:
            if R.random() < 0.8:
                sc.dd('d2var', 'd2var_mutablize (%s, %s, %s, %s)' % (loc(), v, S(sc, 's2exp'), R.choice(['ON_d2varopt ()', 'OS_d2varopt (%s)' % R.choice(vs)])))
                sc.do('chk_d2var (%s)' % v)
                sc.do('chk_d2var (%s)' % ('d2var_get_view_some (%s)' % v) if False else 'chk_d2var (%s)' % v)
            else:
                sc.dd('d2var', 'd2var_mutablize_none (%s, %s, %s)' % (loc(), v, S(sc, 's2exp')))
        sc.do('d2var_opnset_and_add (%s, %s)' % (loc(), vs[0]))
        sc.do('d2var_opnset_and_add (%s, %s)' % (loc(), vs[1]))
        sc.do('chk_d2var (%s)' % vs[0]); sc.do('chk_d2var (%s)' % vs[1])
        dumpenv(sc, '-- mut')
        popdump(sc)
        sc.do('t3chk ()')
    F.append(('mut', fam_mut, 2))
    # ----------------------------------------------------------------------------------------------------------
    def fam_state(sc, k):
        """the linear state of the merge of the branches (lstaftc3nstr) and the update of the variables of a loop"""
        R = sc.R
        sc.pools()
        loc = sc.loc
        vs = setup_dvars(sc, 4)
        for v in vs: sc.do('d2var_set_linval (%s, %d)' % (v, R.choice([0, 1])))
        sc.do('trans3_env_push ()')
        for rep in range(4):
            svs_l = R.sample(sc.pool['s2var'], R.randint(1, 2))
            def tyv(): return 'K_s2exp (s2rt_t0ype, K_S2Evar (%s))' % R.choice(svs_l)
            for v in vs:
                if R.random() < 0.7: sc.do('d2var_set_mastype (%s, OS_s2expopt (%s))' % (v, R.choice([tyv(), 's2exp_int (3)'])))
            sc.do('the_d2varenv_push_let ()')
            for v in vs: sc.do('the_d2varenv_add_dvar (%s)' % v)
            lb = sc.val('the_d2varenv_save_lstbefitmlst ()', 'lstbefitmlst')
            n = R.randint(1, 3)
            body = ['val ls = lstaftc3nstr_initize (%s)' % lb]
            ctrs = []
            for j in range(n):
                c = sc.val('c3nstroptref_make_none (%s)' % loc(), 'c3nstroptref'); ctrs.append(c)
                for v in vs:
                    r = R.random()
                    if r < 0.5: body.append('val () = d2var_set_type (%s, OS_s2expopt (%s))' % (v, R.choice(['s2exp_int (1)', 's2exp_int (1)', 's2exp_int (%d)' % R.randint(0, 3), tyv()])))
                    elif r < 0.7: body.append('val () = d2var_set_type (%s, ON_s2expopt ())' % v)
                    elif r < 0.8: body.append('val () = d2var_set_finknd (%s, K_D2VFINdone (K_D2VFINnone ()))' % v)
                body.append('val () = lstaftc3nstr_update (ls, %s)' % c)
            body.append('val () = (fprint_lstaftc3nstr (dd_out, ls); dd_nl ())')
            svs = sc.lst('s2varlst', svs_l)
            args = sc.lst('i2nvarglst', ['i2nvarg_make (%s, %s)' % (v, R.choice(['ON_s2expopt ()', 'OS_s2expopt (s2exp_int (2))', 'OS_s2expopt (%s)' % tyv()])) for v in R.sample(vs, R.randint(0, 2))])
            inv = sc.val('i2nvresstate_make (%s, %s, %s)' % (svs, S(sc, 's2explst'), args), 'i2nvresstate') if False else sc.val('K_i2nvresstate (%s, %s, %s, ON_s2explstopt ())' % (svs, S(sc, 's2explst'), args), 'i2nvresstate')
            body.append('val () = lstaftc3nstr_process (ls, %s)' % inv)
            body.append('val () = lstaftc3nstr_finalize (ls)')
            sc.do('{ %s }' % ' '.join(body))
            for c in ctrs: sc.dd('c3nstroptref', c)
            for v in vs: sc.do('chk_d2var (%s)' % v)
            sc.do('i2nvresstate_update (%s, %s)' % (loc(), inv))
            sc.do('i2nvarglst_update (%s, %s)' % (loc(), args))
            for v in vs: sc.do('chk_d2var (%s)' % v)
            sc.do('the_d2varenv_pop ()')
            dumpenv(sc, '-- state')
        popdump(sc)
        sc.do('t3chk ()')
    F.append(('state', fam_state, 3))
    # ----------------------------------------------------------------------------------------------------------
    def fam_pf(sc, k):
        R = sc.R
        sc.pools()
        loc = sc.loc
        vs = setup_dvars(sc, 4)
        sv = sc.pool['s2var']
        def p3var(v): return 'p3at_var (%s, %s, %s)' % (loc(), S(sc, 's2exp'), v)
        # lamlpenv
        sc.say('-- lamlp')
        sc.do('(dd_optvt_lamlp (the_lamlpenv_top ()); dd_nl ())')
        sc.do('(dd_optvt_p3atlst (the_lamlpenv_get_funarg ()); dd_nl ())')
        npush = 0
        for rep in range(8):
            c = R.randint(0, 4)
            if c == 3 and npush == 0: c = 1
            npush += (-1 if c == 3 else 1)
            if c == 0: sc.do('the_lamlpenv_push_lam (%s)' % sc.lst('p3atlst', [p3var(R.choice(vs)) for _ in range(R.randint(0, 3))]))
            elif c == 1: sc.do('the_lamlpenv_push_loop0 ()')
            elif c == 2: sc.do('the_lamlpenv_push_loop1 (%s, %s, %s)' % (S(sc, 'loopi2nv'), S(sc, 'lstbefitmlst'), S(sc, 'd2expopt')))
            elif c == 3: sc.do('the_lamlpenv_pop ()')
            else: sc.do('the_lamlpenv_push_lam (%s)' % S(sc, 'p3atlst'))
            sc.do('(dd_optvt_lamlp (the_lamlpenv_top ()); dd_nl ())')
            sc.do('(dd_optvt_p3atlst (the_lamlpenv_get_funarg ()); dd_nl ())')
        for rep in range(npush): sc.do('the_lamlpenv_pop ()')
        sc.do('(dd_optvt_lamlp (the_lamlpenv_top ()); dd_nl ())')
        # the proof manager
        sc.say('-- pfman')
        addrs = [sc.val('K_s2exp (s2rt_addr, K_S2Evar (%s))' % v, 's2exp') for v in sv]
        def attype(a, inner=None):
            e = inner if inner else S(sc, 's2exp')
            return 'K_s2exp (s2rt_view, K_S2Eat (%s, %s))' % (e, a)
        for v in vs:
            sc.do('d2var_set_linval (%s, %d)' % (v, R.choice([0, 1, -1])))
            a = R.choice(addrs)
            r = R.random()
            if r < 0.4: t = attype(a)
            elif r < 0.7: t = 'K_s2exp (s2rt_view, K_S2Etyrec (K_TYRECKINDbox (), 0, %s))' % sc.lst('labs2explst', ['K_labs2exp (mklab (0), ON_stringopt (), %s)' % S(sc, 's2exp'), 'K_labs2exp (mklab (2), ON_stringopt (), %s)' % attype(a)])
            elif r < 0.85: t = attype(R.choice(addrs), attype(a))
            else: t = S(sc, 's2exp')
            sc.do('d2var_set_type (%s, OS_s2expopt (%s))' % (v, t))
        for rep in range(4):
            sc.do('the_pfmanenv_push_let ()')
            sc.do('the_pfmanenv_add_dvar (%s)' % R.choice(vs))
            sc.do('the_pfmanenv_add_dvarlst (%s)' % sc.lst('d2varlst', R.sample(vs, R.randint(0, 3))))
            sc.do('the_pfmanenv_add_dvaropt (OS_d2varopt (%s))' % R.choice(vs))
            sc.do('the_pfmanenv_add_p3at (%s)' % S(sc, 'p3at', 2))
            sc.do('the_pfmanenv_add_p3atlst (%s)' % S(sc, 'p3atlst', 2))
            sc.do('the_pfmanenv_add_p3at (%s)' % p3var(R.choice(vs)))
            c = R.randint(0, 2)
            if c == 0: sc.do('the_pfmanenv_push_lam (0)')
            elif c == 1: sc.do('the_pfmanenv_push_lam (1)')
            else: sc.do('the_pfmanenv_push_try ()')
            sc.do('the_pfmanenv_add_dvar (%s)' % R.choice(vs))
            sc.do('(fprint_the_pfmanenv (dd_out); dd_nl ())')
            for a in addrs:
                sc.do('(dd_optvt_pfobj (pfobj_search_atview (%s)); dd_nl ())' % a)
            sc.do('the_pfmanenv_pop ()')
            sc.do('(fprint_the_pfmanenv (dd_out); dd_nl ())')
            for a in addrs[:2]:
                sc.do('(dd_optvt_pfobj (pfobj_search_atview (%s)); dd_nl ())' % a)
            sc.do('the_pfmanenv_pop ()')
        for rep in range(3): sc.do('the_pfmanenv_pop ()')
        sc.do('(fprint_the_pfmanenv (dd_out); dd_nl ())')
        # the arguments of a function and the types with [withtype]
        sc.say('-- wthtype')
        sc.do('trans3_env_push ()')
        f1 = R.choice(vs); f2 = R.choice(vs); f3 = R.choice(vs)
        sc.do('the_lamlpenv_push_lam (%s)' % sc.lst('p3atlst', [p3var(f1), p3var(f2), p3var(f3)]))
        wths = 'K_WTHS2EXPLSTcons_invar (%d, %s, K_WTHS2EXPLSTcons_trans (%d, %s, K_WTHS2EXPLSTcons_none (K_WTHS2EXPLSTnil ())))' % (R.choice([0, 1]), S(sc, 's2exp'), R.choice([0, 1]), S(sc, 's2exp'))
        for v in (f1, f2, f3):
            sc.do('d2var_set_view (%s, OS_d2varopt (%s))' % (v, R.choice(vs)))
            sc.do('d2var_set_addr (%s, OS_s2expopt (%s))' % (v, R.choice(addrs)))
        body = sc.val('K_s2exp (s2rt_t0ype, K_S2Ewthtype (%s, %s))' % (S(sc, 's2exp'), wths), 's2exp')
        sc.do('(dd_s2exp (s2exp_wthtype_instantiate (%s, %s)); dd_nl ())' % (loc(), body))
        for v in (f1, f2, f3): sc.do('chk_d2var (%s)' % v)
        sc.do('funarg_d2vfin_check (%s)' % loc())
        for v in (f1, f2, f3): sc.do('chk_d2var (%s)' % v)
        sc.do('the_lamlpenv_pop ()')
        popdump(sc)
        sc.do('t3chk ()')
    F.append(('pf', fam_pf, 3))
    # ----------------------------------------------------------------------------------------------------------
    def fam_open(sc, k):
        R = sc.R
        sc.pools()
        loc = sc.loc
        sc.do('trans3_env_push ()')
        for rep in range(8):
            e = quant(sc, R.choice(['S2Euni', 'S2Eexi']), R.choice([1, 2]), quant(sc, R.choice(['S2Euni', 'S2Eexi']), 1) if R.random() < 0.5 else None)
            for f in ('s2hnf_absuni_and_add', 's2hnf_opnexi_and_add', 's2hnf_opn1exi_and_add'):
                sc.dd('s2exp', '%s (%s, s2exp2hnf (%s))' % (f, loc(), R.choice([e, S(sc, 's2exp')])))
            d3e = sc.val('d3exp_var (%s, %s, %s)' % (loc(), R.choice([e, quant(sc, 'S2Eexi', 1)]), sc.handle('d2var')), 'd3exp')
            sc.do('d3exp_open_and_add (%s)' % d3e); sc.dd('d3exp', d3e)
            d3e2 = sc.val('d3exp_var (%s, %s, %s)' % (loc(), quant(sc, 'S2Eexi', 2), sc.handle('d2var')), 'd3exp')
            sc.do('d3explst_open_and_add (%s)' % sc.lst('d3explst', [d3e2, d3e]))
            sc.dd('d3exp', d3e2)
            wths = 'K_WTHS2EXPLSTcons_invar (1, %s, K_WTHS2EXPLSTcons_trans (0, %s, K_WTHS2EXPLSTnil ()))' % (S(sc, 's2exp'), S(sc, 's2exp'))
            wt = sc.val('K_s2exp (s2rt_t0ype, K_S2Ewthtype (%s, %s))' % (S(sc, 's2exp'), wths), 's2exp')
            sc.do('t_unwth (%s, %s)' % (loc(), R.choice([wt, quant(sc, 'S2Eexi', 1, wt), S(sc, 's2exp')])))
            res = quant(sc, 'S2Eexi', 1, wt) if R.random() < 0.6 else wt
            args = sc.lst('s2explst', ['K_s2exp (s2rt_t0ype, K_S2Erefarg (%d, %s))' % (R.choice([0, 1]), quant(sc, 'S2Eexi', 1)) for _ in range(R.randint(1, 3))])
            sc.dd('s2explst', 's2fun_opninv_and_add (%s, %s, %s)' % (loc(), args, R.choice([res, S(sc, 's2exp')])))
            sc.do('t3chk ()')
        dumpenv(sc, '-- open')
        popdump(sc)
    F.append(('open', fam_open, 3))

    # ----------------------------------------------------------------------------------------------------------
    def fam_corner(sc, k):
        """the corners that the random scenarios reach rarely"""
        R = sc.R
        sc.pools()
        loc = sc.loc
        vs = sc.pool['s2var']
        sc.do('trans3_env_push ()')
        # static arguments in sequence: right and wrong numbers of arguments
        for rep in range(8):
            e = quant(sc, 'S2Eexi', 1)
            n = R.randint(0, 3)
            seq = 'K_s2exparg (%s, K_S2EXPARGseq (%s))' % (loc(), sc.lst('s2explst', [S(sc, 's2exp') for _ in range(n)]))
            sc.do('t_inst_sexparg (%s, %s)' % (e, seq))
            sc.do('t_inst_sexparg (%s, K_s2exparg (%s, K_S2EXPARGone ()))' % (e, loc()))
            sc.do('t_inst_sexparg (%s, K_s2exparg (%s, K_S2EXPARGall ()))' % (e, loc()))
            sc.do('t_inst_sexparg (%s, %s)' % (S(sc, 's2exp'), seq))
            u = quant(sc, 'S2Euni', R.choice([1, 2]))
            args = sc.lst('s2exparglst', [seq, 'K_s2exparg (%s, K_S2EXPARGone ())' % loc(), 'K_s2exparg (%s, K_S2EXPARGall ())' % loc(),
                                         'K_s2exparg (%s, K_S2EXPARGseq (%s))' % (loc(), sc.lst('s2explst', [S(sc, 's2exp') for _ in range(R.randint(0, 2))]))][:R.randint(1, 4)])
            sc.do('t_inst_sexparglst (%s, %s)' % (u, args))
            sc.do('t_inst_sexparglst (%s, %s)' % (S(sc, 's2exp'), args))
        # the occurrence of a variable: every form of expression, and through the bindings
        v0 = vs[0]; v1 = vs[1]; v2 = vs[2]
        def sv(v): return 'K_s2exp (s2rt_t0ype, K_S2Evar (%s))' % v
        c0 = sc.handle('s2cst')
        forms = [
            'K_S2Eapp (s2exp_cst (%s), %s)' % (c0, sc.lst('s2explst', [sv(v0)])),
            'K_S2Eapp (%s, LN_s2explst ())' % sv(v0),
            'K_S2Eextype ("t", %s)' % sc.lst('s2explstlst', [sc.lst('s2explst', [sv(v0)])]),
            'K_S2Eextkind ("t", %s)' % sc.lst('s2explstlst', [sc.lst('s2explst', []), sc.lst('s2explst', [sv(v0)])]),
            'K_S2Esizeof (%s)' % sv(v0),
            'K_S2Eeqeq (%s, %s)' % (sv(v1), sv(v0)),
            'K_S2Eeqeq (%s, %s)' % (sv(v0), sv(v1)),
            'K_S2Einvar (%s)' % sv(v0),
            'K_S2Erefarg (1, %s)' % sv(v0),
            'K_S2Elam (%s, %s)' % (sc.lst('s2varlst', [v2]), sv(v0)),
            'K_S2Efun (mkfunclo (0), 0, K_S2EFFset (mkeffset (0)), 0, %s, %s)' % (sc.lst('s2explst', [sv(v0)]), sv(v1)),
            'K_S2Efun (mkfunclo (0), 0, K_S2EFFset (mkeffset (0)), 0, %s, %s)' % (sc.lst('s2explst', [sv(v1)]), sv(v0)),
            'K_S2Eint (3)', 'K_S2Evar (%s)' % v0, 'K_S2Evar (%s)' % v1,
        ]
        for f in forms:
            e = sc.val('K_s2exp (s2rt_t0ype, %s)' % f, 's2exp')
            sc.dd('bool', 's2var_occurcheck_s2exp (%s, %s)' % (v0, e))
        sc.do('trans3_env_hypadd_bind (%s, %s, s2exp2hnf (%s))' % (loc(), v1, sc.val('K_s2exp (s2rt_t0ype, K_S2Eapp (s2exp_cst (%s), %s))' % (c0, sc.lst('s2explst', [sv(v0)])), 's2exp')))
        sc.do('trans3_env_hypadd_bind (%s, %s, s2exp2hnf (%s))' % (loc(), v2, sv(v1)))
        for f in forms:
            e = sc.val('K_s2exp (s2rt_t0ype, %s)' % f, 's2exp')
            sc.dd('bool', 's2var_occurcheck_s2exp (%s, %s)' % (v0, e))
            sc.dd('bool', 's2var_occurcheck_s2exp (%s, %s)' % (v2, e))
        sc.dd('s2exp', 's2exp_hnfize (%s)' % sv(v2))
        sc.do('(fprint_the_s2varbindmap (dd_out); dd_nl ())')
        popdump(sc)
        # the same label twice in the type of a record: the first one is used (the sort is stable)
        for rep in range(3):
            fl = sc.lst('labs2explst', ['K_labs2exp (mklab (0), ON_stringopt (), s2exp_int_index_t0ype (%s))' % sv(v0), 'K_labs2exp (mklab (2), ON_stringopt (), s2exp_int_index_t0ype (%s))' % sv(v1),
                                        'K_labs2exp (mklab (0), ON_stringopt (), s2exp_int_index_t0ype (%s))' % sv(v2), 'K_labs2exp (mklab (2), ON_stringopt (), s2exp_int_index_t0ype (%s))' % sv(v0)])
            sc.do('trans3_env_push ()')
            sc.do('trans3_env_hypadd_labpatcstlst (%s, mk_lp2tcs_n (%d), %s)' % (loc(), rep + 1, fl))
            dumpenv(sc, '-- labs')
            popdump(sc)
        # a constructor with quantifiers
        c = S2.perv_cst(sc, 'qc%d' % k, ['t0ype'], 't0ype', 3)
        qs = sc.lst('s2qualst', ['K_s2qua (%s, %s)' % (sc.lst('s2varlst', [vs[3]]), sc.lst('s2explst', [S(sc, 's2exp')])), 'K_s2qua (%s, LN_s2explst ())' % sc.lst('s2varlst', [vs[2]])])
        dc = sc.val('d2con_make (%s, mkfil (0), mksym (4), %s, 0, %s, 0, %s, ON_s2explstopt ())' % (loc(), c, qs, sc.lst('s2explst', [S(sc, 's2exp')])), 'd2con')
        sc.do('trans3_env_push ()')
        sc.do('trans3_env_hypadd_patcst (%s, mkp2atcst_con (%s, 3), %s)' % (loc(), dc, S(sc, 's2exp')))
        sc.do('trans3_env_hypadd_patcst (%s, mkp2atcst_con (%s, 2), K_s2exp (s2rt_t0ype, K_S2Edatcontyp (%s, LN_s2explst ())))' % (loc(), dc, dc))
        dumpenv(sc, '-- con')
        popdump(sc)
        # every shape of pattern in the variable environments
        ds = setup_dvars(sc, 3)
        P = [p for p in G.types['p3at_node']]
        for c0_, ts in P:
            p3 = sc.val('K_p3at (%s, %s, %s, ON_d2varopt (), ON_s2expopt ())' % (loc(), sc.datatype_con('p3at_node', c0_, 2), S(sc, 's2exp')), 'p3at')
            sc.do('the_d2varenv_add_p3at (%s)' % p3)
            sc.do('the_pfmanenv_add_p3at (%s)' % p3)
        sc.do('the_d2varenv_push_let ()')
        sc.do('the_d2varenv_add_p3at (p3at_refas (%s, %s, %s, p3at_var (%s, %s, %s)))' % (loc(), S(sc, 's2exp'), ds[0], loc(), S(sc, 's2exp'), ds[1]))
        sc.do('(dd_listvt_d2var (the_d2varenv_get_top ()); dd_nl ())')
        sc.do('the_d2varenv_pop ()')
        # funarg: [refas] and the patterns that are not variables
        sc.do('trans3_env_push ()')
        pats = sc.lst('p3atlst', ['p3at_refas (%s, %s, %s, p3at_var (%s, %s, %s))' % (loc(), S(sc, 's2exp'), ds[0], loc(), S(sc, 's2exp'), ds[1]),
                                  'p3at_int (%s, %s, 3)' % (loc(), S(sc, 's2exp')), 'p3at_var (%s, %s, %s)' % (loc(), S(sc, 's2exp'), ds[2])])
        sc.do('the_lamlpenv_push_lam (%s)' % pats)
        sc.do('funarg_d2vfin_check (%s)' % loc())
        for d in ds: sc.do('chk_d2var (%s)' % d)
        wt = sc.val('K_s2exp (s2rt_t0ype, K_S2Eint (1))', 's2exp')
        sc.dd('s2exp', 's2exp_wthtype_instantiate (%s, %s)' % (loc(), wt))
        sc.do('the_lamlpenv_pop ()')
        popdump(sc)
        # variables without type and mutable variables in the proof manager
        w = sc.val('d2var_make (%s, mksym (2))' % loc(), 'd2var')
        sc.do('d2var_set_linval (%s, 1)' % w)
        sc.do('the_pfmanenv_push_let ()')
        sc.do('the_pfmanenv_add_dvar (%s)' % w)
        m = sc.val('d2var_make (%s, mksym (3))' % loc(), 'd2var')
        sc.do('d2var_set_linval (%s, 1)' % m)
        sc.do('d2var_set_type (%s, OS_s2expopt (%s))' % (m, S(sc, 's2exp')))
        mv = sc.val('d2var_ptr_viewat_make (%s, ON_d2varopt ())' % m, 'd2var')
        sc.do('d2var_set_view (%s, OS_d2varopt (%s))' % (m, mv))
        sc.do('d2var_set_type (%s, OS_s2expopt (K_s2exp (s2rt_view, K_S2Eat (%s, %s))))' % (mv, S(sc, 's2exp'), sc.val('K_s2exp (s2rt_addr, K_S2Evar (%s))' % vs[0], 's2exp')))
        sc.do('the_pfmanenv_add_dvar (%s)' % m)
        sc.do('(fprint_the_pfmanenv (dd_out); dd_nl ())')
        sc.do('(dd_optvt_pfobj (pfobj_search_atview (K_s2exp (s2rt_addr, K_S2Evar (%s)))); dd_nl ())' % vs[0])
        sc.do('(dd_optvt_pfobj (pfobj_search_atview (K_s2exp (s2rt_addr, K_S2Evar (%s)))); dd_nl ())' % vs[1])
        sc.do('the_pfmanenv_pop ()')
        # variables without type, extra pops
        sc.do('trans3_env_push ()')
        sc.do('d2var_opnset_and_add (%s, %s)' % (loc(), w))
        sc.do('chk_d2var (%s)' % w)
        sc.do('termetenv_pop ()')
        sc.do('termetenv_pop ()')
        sc.do('the_s2cstbindlst_pop_and_unbind ()')
        sc.do('(dd_listvt_s2cst (the_s2cstbindlst_pop ()); dd_nl ())')
        sc.do('the_s2varbindmap_pop ()')
        sc.do('the_s2varbindmap_pop ()')
        sc.do('the_d2varenv_pop ()')
        sc.do('(dd_listvt_d2var (the_d2varenv_get_llamd2vs ()); dd_nl ())')
        sc.do('(dd_listvt_d2var (the_d2varenv_get_top ()); dd_nl ())')
        sc.do('the_effenv_pop ()')
        sc.do('the_pfmanenv_pop ()')
        sc.do('(dd_optvt_lamlp (the_lamlpenv_top ()); dd_nl ())')
        # a link of an existential variable in the items
        V = sc.pool['s2Var'][0]
        sc.do('s2Var_set_link (%s, OS_s2expopt (%s))' % (V, S(sc, 's2exp')))
        sc.do('trans3_env_add_sVar (%s)' % V)
        sc.do('trans3_env_add_sVarlst (%s)' % sc.lst('s2Varlst', sc.pool['s2Var']))
        popdump(sc)
        sc.do('trans3_env_push ()')
        sc.do('trans3_env_add_sVar (%s)' % V)
        dumpenv(sc, '-- link')
        sc.do('(fprint_the_s3itmlst (dd_out); dd_nl ())')
        popdump(sc)
        sc.do('t3chk ()')
    F.append(('corner', fam_corner, 2))
    return F

# ---------------------------------------------------------------------------------------------------------------------
def write_chunks(d, C, chunks):
    put = C.put
    for f in os.listdir(d):
        m = re.match(r'^(?:t3case_|t3case1_|t3cases_)(\d\d)\.(?:dats|hats)$', f)
        if m and int(m.group(1)) >= len(chunks): os.remove(os.path.join(d, f))
    ch2 = []; ch1 = []
    for k, body in enumerate(chunks):
        cases = 't3cases_%02d.hats' % k
        put(os.path.join(d, cases), body)
        put(os.path.join(d, 't3case_%02d.dats' % k),
            '(* generated by t3_gen.py: the chunk %d of the cases of the level-3 test (ATS2) *)\n#define ATS_DYNLOADFLAG 0\n#include "t3case_pre.hats"\n'
            'extern fun t3tc%d_all (): void = "ext#t3tc_%d"\n#include "%s"\nimplement t3tc%d_all () = tc%d_body ()\n' % (k, k, k, cases, k, k))
        put(os.path.join(d, 't3case1_%02d.dats' % k),
            '(* generated by t3_gen.py: the chunk %d of the cases of the level-3 test (ATS1) *)\n#include "t3case_pre1.hats"\n'
            'extern fun t3tc%d_all (): void = "t3tc_%d"\n#include "%s"\nimplement t3tc%d_all () = tc%d_body ()\n' % (k, k, k, cases, k, k))
        ch2.append('extern fun t3tc%d_all (): void = "ext#t3tc_%d"\n' % (k, k))
        ch1.append('extern fun t3tc%d_all (): void = "t3tc_%d"\n' % (k, k))
    call = 'fun t3tc_all (): void = {\n' + ''.join('  val () = t3tc%d_all ()\n' % k for k in range(len(chunks))) + '}\n'
    put(os.path.join(d, 't3chunks.hats'), ''.join(ch2) + call)
    put(os.path.join(d, 't3chunks1.hats'), ''.join(ch1) + call)

def main(G, C, d3order):
    d = G.d
    Sc3 = build(G, C)
    F = families(G, C, Sc3, d3order, d)
    R = random.Random(SEED)
    scs = []
    for name, fam, n in F:
        for i in range(max(1, int(round(n * SCALE))) if n > 0 else 1):
            sc = Sc3(G, R, 'sc_%s_%d' % (name, i))
            fam(sc, i)
            scs.append(sc)
    chunks = []; cur = []; size = 0
    for sc in scs:
        t = wrap_text(sc.text())
        cur.append((sc.name, t)); size += t.count('\n')
        if size > 1500 or sc.name.startswith('sc_setup'):
            chunks.append(cur); cur = []; size = 0
    if cur: chunks.append(cur)
    bodies = []
    for ch in chunks:
        k = len(bodies)
        body = ''.join(t for n, t in ch)
        body += 'fun tc%d_body (): void = {\n' % k + ''.join('  val () = %s ()\n' % n for n, t in ch) + '}\n'
        bodies.append(body)
    write_chunks(d, C, bodies)
    print('t3_cases: %d scenarios, %d chunks, %d lines' % (len(scs), len(bodies), sum(b.count('\n') for b in bodies)))
