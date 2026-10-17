# the generator of the cases of the codegen2/patcst2 test (called by cg_gen.py, see there and PORTING.md, "Codegen2" and "Pattern coverage (patcst2)")
#
# A scenario is a function (a block of 'val' statements) written in the common subset of ATS1 and ATS2: it builds the environment (the
# datatypes, the abstract records, the d2csts; cgenv.cats), the #codegen2 declarations or the patterns with the wrappers of the level-2 test
# (d2compat_gen.hats) and calls the functions of the modules under test, printing the results. CGSEED (the seed of the random generator)
# and CGSCALE (the number of scenarios) can be set in the environment.
import os, random, re, sys
sys.dont_write_bytecode = True
import d2_cases
from d2_cases import Sc, PRESORTS, put

SEED = int(os.environ.get('CGSEED', '1'))
SCALE = float(os.environ.get('CGSCALE', '4'))

# --------------------------------------------------------------------------------------------------------------------
DT_NAMES = ['tree', 'list_t', 'expr', 'tok', 'a', 'mylist', 'bin_op', 'node_t', 'exp0', 'x_y', 'S', 'w1', 'e', 'stream_vt', 'option_vt', 'T']
CON_NAMES = ['Nil', 'Cons', 'Leaf', 'Node', 'Var', 'App', 'Lam', 'Int', 'Str', 'Bin', 'Un', 'Cst', 'A', 'B', 'C', 'Zero', 'Succ', 'x1', 'c_2',
             'TNIL', 'LTE', 'Z', 'S', 'Plus', 'Minus']
TYPE_SORTS = ['s2rt_type', 's2rt_t0ype', 's2rt_vtype', 's2rt_vt0ype']
VAR_SORTS = ['s2rt_t0ype', 's2rt_vt0ype', 's2rt_type', 's2rt_vtype', 's2rt_int', 's2rt_prop', 's2rt_view', 's2rt_addr', 's2rt_bool']

def S(name):
    return '($SYM.symbol_make_string "%s")' % name
def LOC(sc):
    return 'mkloc (%d)' % sc.R.randint(0, 40)
def e1_ide(sc, n): return 'e1xp_ide (%s, %s)' % (LOC(sc), S(n))
def e1_str(sc, n): return 'e1xp_string (%s, "%s")' % (LOC(sc), n)
def e1_int(sc, i): return 'e1xp_int (%s, %d)' % (LOC(sc), i)
def e1_list(sc, es): return sc.lst('e1xplst', es)
def e1_kw(sc, n):
    """the keyword of a #codegen2: an identifier or a string"""
    return e1_ide(sc, n) if sc.R.random() < 0.7 else e1_str(sc, n)

def codegen_decl(sc, knd, es):
    return sc.val('d2ecl_codegen (%s, %d, %s)' % (LOC(sc), knd, e1_list(sc, es)), 'd2ecl')

def mk_cst(sc, name, srt='s2rt_type', iscon=True, isabs=False, definition=None, islst=None):
    isabs_e = 'OS_s2expoptopt (ON_s2expopt ())' if isabs else 'ON_s2expoptopt ()'
    def_e = 'OS_s2expopt (%s)' % definition if definition else 'ON_s2expopt ()'
    lst_e = 'OS_d2conpairopt (%s)' % islst if islst else 'ON_d2conpairopt ()'
    return sc.val('s2cst_make (%s, %s, mkfil (0), %s, %s, %s, false, ON_s2expopt (), %s, LN_syms2rtlstlst (), %s)' % (
        S(name), LOC(sc), srt, isabs_e, 'true' if iscon else 'false', lst_e, def_e), 's2cst')

def rand_cons(R, nmax=5, tags='seq'):
    n = R.choice([0, 1, 2, 2, 3, 3, 4, nmax])
    names = R.sample(CON_NAMES, n)
    cons = []
    for i, nm in enumerate(names):
        nargs = R.choice([0, 0, 1, 2, 3, 4])
        npf = R.choice([0, 0, 0, 1, 2]) if nargs > 0 else 0
        tag = i if tags == 'seq' else R.choice([i, i, -1, 5, 100])
        cons.append((nm, nargs, npf, tag))
    return cons

def mk_dat(sc, name, cons, **kw):
    """a datatype (the s2cst, its d2cons with their tags; the environment is the business of the caller)"""
    R = sc.R
    c = mk_cst(sc, name, **kw)
    ds = []
    for (cn, nargs, npf, tag) in cons:
        args = [R.choice(['s2exp_int (%d)' % R.randint(0, 5), 's2exp_cst (%s)' % c]) for _ in range(nargs)]
        qua = 'LN_s2qualst ()'
        if R.random() < 0.3:
            v = sc.val('s2var_make_id_srt (%s, %s)' % (S('v%d' % R.randint(0, 3)), R.choice(VAR_SORTS)), 's2var')
            qua = sc.lst('s2qualst', ['K_s2qua (%s, %s)' % (sc.lst('s2varlst', [v]), 'LN_s2explst ()')])
        d = sc.val('d2con_make (%s, mkfil (0), %s, %s, %d, %s, %d, %s, ON_s2explstopt ())' % (
            LOC(sc), S(cn), c, R.choice([0, 0, 1]), qua, npf, sc.lst('s2explst', args)), 'd2con')
        sc.do('d2con_set_tag (%s, %d)' % (d, tag))
        ds.append(d)
    sc.do('s2cst_set_dconlst (%s, OS_d2conlstopt (%s))' % (c, sc.lst('d2conlst', ds)))
    return c, ds

def mk_decarg(sc):
    """a random s2qualst for the d2cst of a template (the sorts decide what is written: t0p, vt0p or nothing)"""
    R = sc.R
    quas = []
    for _ in range(R.choice([0, 0, 1, 1, 2, 3])):
        vs = [sc.val('s2var_make_id_srt (%s, %s)' % (S(R.choice(['a', 'b', 'x', 'n', 'l', 'vt'])), R.choice(VAR_SORTS)), 's2var') for _ in range(R.choice([1, 1, 2, 3]))]
        quas.append('K_s2qua (%s, LN_s2explst ())' % sc.lst('s2varlst', vs))
    return sc.lst('s2qualst', quas)

def mk_d2cst(sc, name, decarg=None):
    if decarg is None: decarg = mk_decarg(sc)
    return sc.val('d2cst_make (%s, %s, mkfil (0), mkdcstkind (0), %s, %s, s2exp_int (0), mkdcstextdef (0))' % (
        S(name), LOC(sc), decarg, sc.lst('intlst', ['1'])), 'd2cst')

def add_cst(sc, c): sc.do('cg_add_s2cst (%s)' % c)
def add_dcst(sc, c): sc.do('cg_add_d2cst (%s)' % c)

# --------------------------------------------------------------------------------------------------------------------
# the codegen2 families
EXTRAS = ['none', 'ide', 'str', 'int', 'ide2']

def extra_args(sc, kind):
    R = sc.R
    if kind == 'none': return []
    if kind == 'ide': return [e1_ide(sc, R.choice(['myf', 'f_', 'print_x']))]
    if kind == 'str': return [e1_str(sc, R.choice(['strf', 'g_', '']))]
    if kind == 'int': return [e1_int(sc, R.randint(0, 9))]
    return [e1_ide(sc, 'f1'), e1_ide(sc, 'f2')]

def run_codegen(sc, kw, rest, direct=None):
    """process the declaration #codegen2(kw, rest..) and (if direct) call the generator directly"""
    R = sc.R
    d2c = codegen_decl(sc, R.choice([0, 1, 2, 2]), [kw] + rest)
    sc.do('codegen2_process (dd_out, %s)' % d2c)
    if direct:
        d2c2 = codegen_decl(sc, 1, [kw] + rest)
        sc.do('codegen2_%s (dd_out, %s, %s)' % (direct, d2c2, e1_list(sc, rest)))

def fam_dat(sc, k):
    """#codegen2(datcon, ...) and #codegen2(datcontag, ...)"""
    R = sc.R
    sc.do('cg_env_clear ()')
    names = R.sample(DT_NAMES, R.choice([1, 2, 3]))
    for nm in names:
        c, ds = mk_dat(sc, nm, rand_cons(R, tags=R.choice(['seq', 'odd'])))
        add_cst(sc, c)
    c, ds = mk_dat(sc, 'notdat', rand_cons(R), iscon=False); add_cst(sc, c)
    c, ds = mk_dat(sc, 'absdt', rand_cons(R), isabs=True); add_cst(sc, c)
    c, ds = mk_dat(sc, 'emptydt', []); add_cst(sc, c)
    sv = sc.val('s2var_make_id_srt (%s, s2rt_type)' % S('svar'), 's2var')
    sc.do('cg_add_s2itm_var ("svar", %s)' % sv)
    sc.do('cg_add_s2itm_nil ("nocst")')
    c1, _ = mk_dat(sc, 'dup', rand_cons(R, 3)); c2, _ = mk_dat(sc, 'dup', rand_cons(R, 2))
    sc.do('cg_add_s2cst2 ("dup", %s, %s)' % (c1, c2))
    for kind in ('datcon', 'datcontag'):
        for nm in names + ['notdat', 'absdt', 'emptydt', 'missing', 'svar', 'nocst', 'dup']:
            for ex in R.sample(EXTRAS, 3):
                run_codegen(sc, e1_kw(sc, kind), [e1_ide(sc, nm) if R.random() < 0.85 else e1_str(sc, nm)] + extra_args(sc, ex), kind)
        # the errors: nothing, a number, something that is not a name
        run_codegen(sc, e1_kw(sc, kind), [], kind)
        run_codegen(sc, e1_kw(sc, kind), [e1_int(sc, 3)], kind)
        run_codegen(sc, e1_kw(sc, kind), [e1_str(sc, names[0])], kind)
    sc.say('-- end')

def fam_fprint(sc, k):
    """#codegen2(fprint, [datatype], <fprint_name>)"""
    R = sc.R
    sc.do('cg_env_clear ()')
    names = R.sample(DT_NAMES, R.choice([1, 2, 3]))
    for nm in names:
        c, ds = mk_dat(sc, nm, rand_cons(R, 6))
        add_cst(sc, c)
        if R.random() < 0.85:
            f = mk_d2cst(sc, 'fprint_%s_' % nm)
            add_dcst(sc, f)
    c, ds = mk_dat(sc, 'notdat', rand_cons(R), iscon=False); add_cst(sc, c)
    c, ds = mk_dat(sc, 'plain', rand_cons(R, 4)); add_cst(sc, c)   # no fprint_plain_
    myf = mk_d2cst(sc, 'myprint'); add_dcst(sc, myf)
    myf2 = mk_d2cst(sc, 'myprint2', 'LN_s2qualst ()'); add_dcst(sc, myf2)
    dv = sc.val('d2var_make (%s, %s)' % (LOC(sc), S('dvar')), 'd2var')
    sc.do('cg_add_d2itm_var ("dvar", %s)' % dv)
    sc.do('cg_add_d2itm_var ("fprint_plain_", %s)' % dv)   # not a d2cst: no fprint-function for plain
    for nm in names + ['plain', 'notdat', 'missing']:
        for tail in ([], [e1_ide(sc, 'myprint')], [e1_ide(sc, 'myprint2')], [e1_ide(sc, 'dvar')], [e1_ide(sc, 'nothere')], [e1_str(sc, 'myprint')],
                     [e1_int(sc, 2)], [e1_ide(sc, 'myprint'), e1_ide(sc, 'more')]):
            if R.random() < 0.55:
                run_codegen(sc, e1_kw(sc, 'fprint'), [e1_ide(sc, nm)] + tail, 'fprint')
    run_codegen(sc, e1_kw(sc, 'fprint'), [], 'fprint')
    run_codegen(sc, e1_kw(sc, 'fprint'), [e1_int(sc, 1)], 'fprint')
    sc.say('-- end')

# ---- the abstract records
def mk_sort_fun(sc, nargs, res):
    return 'K_S2RTfun (%s, %s)' % (sc.lst('s2rtlst', ['s2rt_t0ype'] * nargs), res)

def gen_elt(sc, d, tvars, csts):
    """a type: a constant, a variable, an application, a record or a tuple, or an expression that is printed by fprint_s2exp"""
    R = sc.R
    r = R.random()
    srt = R.choice(['s2rt_type', 's2rt_t0ype', 's2rt_vtype', 's2rt_vt0ype', 's2rt_prop', 's2rt_view'])
    if d <= 0 or r < 0.22:
        c = R.random()
        if c < 0.4: return 's2exp_cst (%s)' % R.choice(csts)
        if c < 0.75 and tvars: return 's2exp_var (%s)' % R.choice(tvars)
        return 'K_s2exp (%s, K_S2Eint (%d))' % (srt, R.randint(0, 9))
    if r < 0.5:
        n = R.choice([1, 1, 2, 3])
        head = 's2exp_cst (%s)' % R.choice(csts) if (R.random() < 0.85 or not tvars) else 's2exp_var (%s)' % R.choice(tvars)
        return 'K_s2exp (%s, K_S2Eapp (%s, %s))' % (srt, head, sc.lst('s2explst', [gen_elt(sc, d - 1, tvars, csts) for _ in range(n)]))
    if r < 0.82:
        knd = R.choice(['K_TYRECKINDbox ()', 'K_TYRECKINDbox_lin ()', 'K_TYRECKINDflt0 ()', 'K_TYRECKINDflt1 (%s)' % sc.val('mkstamp (0)'),
                        'K_TYRECKINDflt_ext ("ext")'])
        n = R.choice([0, 1, 2, 3])
        form = R.choice(['tup', 'rec', 'mix'])
        fl = []
        for i in range(n):
            if form == 'tup' or (form == 'mix' and i % 2 == 0): lab = '$LAB.label_make_int (%d)' % i
            else: lab = '$LAB.label_make_string ("f%d")' % i
            fl.append('K_labs2exp (%s, ON_stringopt (), %s)' % (lab, gen_elt(sc, d - 1, tvars, csts)))
        return 'K_s2exp (%s, K_S2Etyrec (%s, %d, %s))' % (srt, knd, R.choice([0, 0, 1]), sc.lst('labs2explst', fl))
    c = R.choice(['at', 'top', 'without', 'float', 'string', 'invar', 'err', 'refarg'])
    e1 = gen_elt(sc, d - 1, tvars, csts)
    if c == 'at': return 'K_s2exp (%s, K_S2Eat (%s, %s))' % (srt, e1, gen_elt(sc, d - 1, tvars, csts))
    if c == 'top': return 'K_s2exp (%s, K_S2Etop (%d, %s))' % (srt, R.choice([0, 1]), e1)
    if c == 'without': return 'K_s2exp (%s, K_S2Ewithout (%s))' % (srt, e1)
    if c == 'float': return 'K_s2exp (%s, K_S2Efloat ("1.5"))' % srt
    if c == 'string': return 'K_s2exp (%s, K_S2Estring ("str"))' % srt
    if c == 'invar': return 'K_s2exp (%s, K_S2Einvar (%s))' % (srt, e1)
    if c == 'refarg': return 'K_s2exp (%s, K_S2Erefarg (%d, %s))' % (srt, R.choice([0, 1]), e1)
    return 'K_s2exp (%s, K_S2Eerrexp ())' % srt

def mk_recdef(sc, tvars, csts, getset_csts, nfld, lam_levels=1, kind=None):
    """the definition of a record type constructor: lam{..}(.. record ..); the fields are get/set/getset/exch/getref or unknown forms"""
    R = sc.R
    fl = []
    for i in range(nfld):
        lab = '$LAB.label_make_string ("fld%d")' % i if R.random() < 0.6 else '$LAB.label_make_int (%d)' % i
        k = R.choice(['get', 'set', 'getset', 'exch', 'getref', 'foo', 'noargs', 'varhead', 'plain', 'get', 'getset'])
        elt = gen_elt(sc, 2, tvars, csts)
        gs = getset_csts
        if k in ('get', 'set', 'getset', 'exch', 'getref'):
            e = 'K_s2exp (s2rt_type, K_S2Eapp (s2exp_cst (%s), %s))' % (gs[k], sc.lst('s2explst', [elt] + ([gen_elt(sc, 1, tvars, csts)] if R.random() < 0.3 else [])))
        elif k == 'foo':
            e = 'K_s2exp (s2rt_type, K_S2Eapp (s2exp_cst (%s), %s))' % (gs['foo'], sc.lst('s2explst', [elt]))
        elif k == 'noargs':
            e = 'K_s2exp (s2rt_type, K_S2Eapp (s2exp_cst (%s), LN_s2explst ()))' % gs['get']
        elif k == 'varhead':
            e = 'K_s2exp (s2rt_type, K_S2Eapp (s2exp_var (%s), %s))' % (tvars[0], sc.lst('s2explst', [elt]))
        else:
            e = elt
        fl.append('K_labs2exp (%s, ON_stringopt (), %s)' % (lab, e))
    knd = kind or R.choice(['K_TYRECKINDbox ()', 'K_TYRECKINDflt0 ()', 'K_TYRECKINDbox_lin ()'])
    rec = 'K_s2exp (s2rt_type, K_S2Etyrec (%s, 0, %s))' % (knd, sc.lst('labs2explst', fl))
    body = sc.val(rec, 's2exp')
    for lvl in range(lam_levels):
        vs = tvars if lvl == 0 else [sc.val('s2var_make_id_srt (%s, %s)' % (S('w%d' % lvl), R.choice(VAR_SORTS)), 's2var')]
        body = sc.val('K_s2exp (s2rt_type, K_S2Elam (%s, %s))' % (sc.lst('s2varlst', vs), body), 's2exp')
    return body

def fam_absrec(sc, k):
    """#codegen2(absrec, [typedef], <name>)"""
    R = sc.R
    sc.do('cg_env_clear ()')
    gs = {}
    for n in ('get', 'set', 'getset', 'exch', 'getref', 'foo'):
        c = mk_cst(sc, n, iscon=False); gs[n] = c
    tcs = [mk_cst(sc, n, iscon=False) for n in ('int', 'string', 'bool')]
    ntv = R.choice([0, 1, 1, 2, 3])
    tvars = [sc.val('s2var_make_id_srt (%s, %s)' % (S(n), R.choice(VAR_SORTS)), 's2var') for n in ['a', 'b', 'vt', 'n'][:ntv]]
    if not tvars: tvars = [sc.val('s2var_make_id_srt (%s, s2rt_t0ype)' % S('a0'), 's2var')]
    csts = tcs + [gs['foo']]
    names = []
    for i in range(R.choice([1, 2, 3])):
        nm = R.choice(['rec', 'point', 'my_t', 'X', 'cell_t'])
        if nm in names: continue
        names.append(nm)
        d = mk_recdef(sc, tvars, csts, gs, R.choice([0, 1, 2, 3, 4]), R.choice([1, 1, 2]))
        srt = mk_sort_fun(sc, R.choice([1, 2]), R.choice(TYPE_SORTS)) if R.random() < 0.85 else R.choice(TYPE_SORTS)
        c = mk_cst(sc, nm, srt=srt, iscon=False, definition=d)
        add_cst(sc, c)
        csts.append(c)
    # not a record: a lambda over something else, a non-lambda, a nullary tydef
    d = sc.val('K_s2exp (s2rt_type, K_S2Elam (%s, s2exp_int (1)))' % sc.lst('s2varlst', tvars), 's2exp')
    c = mk_cst(sc, 'notrec', srt=mk_sort_fun(sc, 1, 's2rt_type'), iscon=False, definition=d); add_cst(sc, c); names.append('notrec')
    c = mk_cst(sc, 'notrec2', srt='s2rt_type', iscon=False, definition='s2exp_int (2)'); add_cst(sc, c); names.append('notrec2')
    c = mk_cst(sc, 'abst', srt=mk_sort_fun(sc, 1, 's2rt_type'), iscon=False); add_cst(sc, c); names.append('abst')   # no definition: not a tydef
    c, ds = mk_dat(sc, 'dt', rand_cons(R, 3)); add_cst(sc, c); names.append('dt')
    for nm in names + ['missing']:
        for tail in ([], [e1_ide(sc, 'tnm_')], [e1_str(sc, 'strtnm')], [e1_int(sc, 5)], [e1_ide(sc, 'tnm_'), e1_ide(sc, 'x')]):
            if R.random() < 0.6:
                run_codegen(sc, e1_kw(sc, 'absrec'), [e1_ide(sc, nm)] + tail, 'absrec')
    run_codegen(sc, e1_kw(sc, 'absrec'), [], 'absrec')
    sc.say('-- end')

# ---- the pieces
def rand_sorts(sc, d):
    R = sc.R
    r = R.random()
    if d <= 0 or r < 0.4:
        c = R.random()
        if c < 0.6: return R.choice(PRESORTS + ['s2rt_vt0ype', 's2rt_vtype', 's2rt_int', 's2rt_bool', 's2rt_eff', 's2rt_real'])
        if c < 0.75: return 'K_S2RTbas (K_S2RTBASpre (%s))' % S(R.choice(['mypre', 'type']))
        if c < 0.85: return 'K_S2RTbas (K_S2RTBASimp (%d, %s))' % (R.choice([0, 1]), S('myimp'))
        if c < 0.93: return 'K_S2RTbas (K_S2RTBASdef (%s))' % sc.val('s2rtdat_make (%s)' % S('mydat'), 's2rtdat')
        if c < 0.96: return 'K_S2RTerr ()'
        if c < 0.98: return 'K_S2RTVar (%s)' % sc.val('s2rtVar_make (%s)' % LOC(sc), 's2rtVar')
        return 'K_S2RTtup (%s)' % sc.lst('s2rtlst', [rand_sorts(sc, 0), rand_sorts(sc, 0)])
    n = R.choice([0, 1, 2, 3])
    return 'K_S2RTfun (%s, %s)' % (sc.lst('s2rtlst', [rand_sorts(sc, d - 1) for _ in range(n)]), rand_sorts(sc, d - 1))

def fam_emit(sc, k):
    """codegen2_emit_*: sorts, expressions, the declarations of the templates"""
    R = sc.R
    sc.do('cg_env_clear ()')
    for i in range(10):
        s = rand_sorts(sc, 3)
        sc.do('(codegen2_emit_s2rt (dd_out, %s); dd_nl ())' % s)
    tvars = [sc.val('s2var_make_id_srt (%s, %s)' % (S(n), R.choice(VAR_SORTS)), 's2var') for n in ['a', 'b', 'c']]
    csts = [mk_cst(sc, n, iscon=False) for n in ('int', 'list', 'g')]
    for c in csts:
        sc.do('(codegen2_emit_s2cst (dd_out, %s); dd_nl ())' % c)
    for v in tvars:
        sc.do('(codegen2_emit_s2var (dd_out, %s); dd_nl ())' % v)
    for i in range(14):
        e = gen_elt(sc, R.choice([1, 2, 3]), tvars, csts)
        sc.do('(codegen2_emit_s2exp (dd_out, %s); dd_nl ())' % e)
    for i in range(5):
        f = mk_d2cst(sc, 'f%d' % i)
        sc.do('(codegen2_emit_tmpcstapp (dd_out, %s); dd_nl ())' % f)
        sc.do('(codegen2_emit_tmpcstimp (dd_out, %s); dd_nl ())' % f)
        sc.do('(codegen2_emit_tmpcstdec (dd_out, %s); dd_nl ())' % f)
    sc.say('-- end')

def fam_misc(sc, k):
    """the tests of the names, the lookups of the environment, d2eclist_codegen_out"""
    R = sc.R
    sc.do('cg_env_clear ()')
    for nm in ['datcon', 'datcontag', 'fprint', 'absrec', 'other', '']:
        for e in (e1_ide(sc, nm), e1_str(sc, nm), e1_int(sc, 3)):
            t = sc.val(e)
            for f in ('datcon_test_e1xp', 'datcontag_test_e1xp', 'fprint_test_e1xp', 'absrec_test_e1xp'):
                sc.do('(dd_bool (%s (%s)); dd_ps " ")' % (f, t))
            sc.do('dd_nl ()')
    # the lookups
    dt, _ = mk_dat(sc, 'dtype', rand_cons(R, 3)); add_cst(sc, dt)
    td = mk_cst(sc, 'tdef', srt=mk_sort_fun(sc, 1, 's2rt_type'), iscon=False, definition='s2exp_int (1)'); add_cst(sc, td)
    nt = mk_cst(sc, 'plain', iscon=False); add_cst(sc, nt)
    sc.do('cg_add_s2itm_nil ("nocst")')
    sc.do('cg_add_s2itm_var ("svar", %s)' % sc.val('s2var_make_srt (s2rt_type)', 's2var'))
    f = mk_d2cst(sc, 'dfun'); add_dcst(sc, f)
    sc.do('cg_add_d2itm_var ("dvar", %s)' % sc.val('d2var_make (%s, %s)' % (LOC(sc), S('dvar')), 'd2var'))
    for nm in ['dtype', 'tdef', 'plain', 'nocst', 'svar', 'dfun', 'dvar', 'missing']:
        for e in (e1_ide(sc, nm), e1_str(sc, nm), e1_int(sc, 0)):
            t = sc.val(e)
            sc.do('(dd_optvt_s2cst (codegen2_get_s2cst (%s)); dd_nl ())' % t)
            sc.do('(dd_optvt_s2cst (codegen2_get_tydef (%s)); dd_nl ())' % t)
            sc.do('(dd_optvt_s2cst (codegen2_get_datype (%s)); dd_nl ())' % t)
            sc.do('(dd_optvt_d2cst (codegen2_get_d2cst (%s)); dd_nl ())' % t)
    # d2eclist_codegen_out: the declarations of the list, of local .. in .. end, the ones that are skipped
    ds = []
    for knd in (0, 1, 2, 3, 4):
        ds.append(codegen_decl(sc, knd, [e1_ide(sc, 'datcon'), e1_ide(sc, 'dtype')]))
    ds.append(sc.val('d2ecl_none (%s)' % LOC(sc), 'd2ecl'))
    inner = sc.val('d2ecl_list (%s, %s)' % (LOC(sc), sc.lst('d2eclist', [ds[1], ds[0]])), 'd2ecl')
    loc = sc.val('d2ecl_local (%s, %s, %s)' % (LOC(sc), sc.lst('d2eclist', [ds[2], ds[3]]), sc.lst('d2eclist', [ds[4], inner, ds[0]])), 'd2ecl')
    top = sc.lst('d2eclist', [ds[5], ds[0], inner, loc, ds[3], codegen_decl(sc, 2, []), codegen_decl(sc, 0, [e1_int(sc, 1)])])
    sc.do('d2eclist_codegen_out (dd_out, %s)' % top)
    sc.do('d2eclist_codegen_out (dd_out, %s)' % sc.lst('d2eclist', []))
    sc.say('-- end')

# --------------------------------------------------------------------------------------------------------------------
FAMILIES = [
    ('dat', fam_dat, 8),
    ('fprint', fam_fprint, 8),
    ('absrec', fam_absrec, 12),
    ('emit', fam_emit, 3),
    ('misc', fam_misc, 2),
]

def build(G):
    """all the scenarios"""
    R = random.Random(SEED)
    scs = []
    fams = list(FAMILIES)
    try:
        import cg_pat
        fams += cg_pat.FAMILIES
    except ImportError:
        pass
    for name, fam, n in fams:
        for i in range(max(1, int(round(n * SCALE)))):
            sc = Sc(G, R, 'sc_%s_%d' % (name, i))
            fam(sc, i)
            scs.append(sc)
    return scs

def write_chunks(G, scs, d):
    chunks = []; cur = []; size = 0
    for sc in scs:
        t = sc.text()
        cur.append((sc.name, t)); size += t.count('\n')
        if size > 2500:
            chunks.append(cur); cur = []; size = 0
    if cur: chunks.append(cur)
    for f in os.listdir(d):   # remove the files of an older generation (more chunks)
        m = re.match(r'^(?:cgcase_|cgcase1_|cgcases_)(\d\d)\.(?:dats|hats)$', f)
        if m and int(m.group(1)) >= len(chunks): os.remove(os.path.join(d, f))
    ch2 = []; ch1 = []
    for k, ch in enumerate(chunks):
        body = ''.join(t for n, t in ch)
        body += 'fun tc%d_body (): void = {\n' % k + ''.join('  val () = %s ()\n' % n for n, t in ch) + '}\n'
        cases = 'cgcases_%02d.hats' % k
        put(os.path.join(d, cases), body)
        put(os.path.join(d, 'cgcase_%02d.dats' % k),
            '(* generated by cg_gen.py: the chunk %d of the cases of the codegen2/patcst2 test (ATS2) *)\n#define ATS_DYNLOADFLAG 0\n#include "cgcase_pre.hats"\n'
            'extern fun tc%d_all (): void = "ext#cgtc_%d"\n#include "%s"\nimplement tc%d_all () = tc%d_body ()\n' % (k, k, k, cases, k, k))
        put(os.path.join(d, 'cgcase1_%02d.dats' % k),
            '(* generated by cg_gen.py: the chunk %d of the cases of the codegen2/patcst2 test (ATS1) *)\n#include "cgcase_pre1.hats"\n'
            'extern fun tc%d_all (): void = "cgtc_%d"\n#include "%s"\nimplement tc%d_all () = tc%d_body ()\n' % (k, k, k, cases, k, k))
        ch2.append('extern fun tc%d_all (): void = "ext#cgtc_%d"\n' % (k, k))
        ch1.append('extern fun tc%d_all (): void = "cgtc_%d"\n' % (k, k))
    call = 'fun tc_all0 (): void = {\n  val () = cg_init_universe ()\n' + ''.join('  val () = tc%d_all ()\n' % k for k in range(len(chunks))) + '}\n'
    call += 'fun tc_all (): void = let val n = cg_getenv_int () in if n > 0 then (cg_init_universe (); cg_errtest (n)) else tc_all0 () end\n'
    put(os.path.join(d, 'cgchunks.hats'), ''.join(ch2) + call)
    put(os.path.join(d, 'cgchunks1.hats'), ''.join(ch1) + call)
    return len(chunks)

def main(G, d):
    scs = build(G)
    n = write_chunks(G, scs, d)
    print('cg_cases: %d scenarios, %d chunks, %d lines' % (len(scs), n, sum(sc.text().count('\n') for sc in scs)))
