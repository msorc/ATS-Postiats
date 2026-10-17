#!/usr/bin/env python3
# usage: python3 tree1_gen.py   (rewrites deepdump_l1.hats deepdump1_l1.hats treecases.hats treecases1.hats)
#
# Test of the level-1 trees (pats_staexp1, pats_dynexp1) and of their printers against the ATS1 build of
# src/ (there is no trans1 in src yet that could build level-1 trees). From the specs
# ../pats_staexp1.spec, ../pats_dynexp1.spec (and ../pats_syntax.spec for the level-0 types they use) it generates
#  * deepdump_l1.hats / deepdump1_l1.hats: a complete dumper dd_T of every record/datatype of the two specs (every
#    field), in ATS2 and in ATS1 (as deepdump_gen.py does for the level-0 tree);
#  * treecases.hats / treecases1.hats: for every constructor of every datatype ("node") of the specs a tree that is
#    built with it (record around it, the other fields get samples) and dumped with dd_T and the fprint_T of
#    the printers; and for every function [f (args): R] declared in the ATS1 sats files (the smart constructors:
#    s1exp_list, p1at_list, d1exp_list, ..., the conversions e1xp_make_s1exp, s1exp_make_e1xp, ...) calls with sample
#    arguments (lists of 0, 1 and 2 elements, options, and every constructor of the node type of the argument for the
#    conversions) whose result is dumped. testfun1.hats is the same for the hand-written cases.
# treedump.dats / treedump1.dats (the drivers) include them. The ATS1 and ATS2 outputs must be identical.
import re, os, sys

d = os.path.dirname(os.path.abspath(__file__))
SPECS = ['pats_syntax.spec', 'pats_staexp1.spec', 'pats_dynexp1.spec']
L1SPECS = ['pats_staexp1.spec', 'pats_dynexp1.spec']

def splitf(a):
    parts = []; dep = 0; b = ''
    for ch in a:
        if ch == '(': dep += 1
        if ch == ')': dep -= 1
        if ch == ',' and dep == 0: parts.append(b.strip()); b = ''; continue
        b += ch
    if b.strip(): parts.append(b.strip())
    return parts

lists = {'symbolist': 'symbol'}; opts = {'symbolopt': 'symbol'}
recs = {}; types = {}; order = {}   # order[spec] = [names]
specof = {}
for sp in SPECS:
    cur = None; order[sp] = []
    for l in open(os.path.join(d, '..', sp)).read().split('\n'):
        l = l.split('#', 1)[0].rstrip()
        if not l: continue
        m = re.match(r'^typedef\s+(\w+)\s*=\s*glist\((\w+)\)\s*$', l)
        if m: lists[m.group(1)] = m.group(2); continue
        m = re.match(r'^typedef\s+(\w+)\s*=\s*gopt\((\w+)\)\s*$', l)
        if m: opts[m.group(1)] = m.group(2); continue
        if l.startswith('typedef') or l.startswith('vtypedef'): continue
        m = re.match(r'^record\s+(\w+)\s*\((.*)\)\s*$', l)
        if m:
            recs[m.group(1)] = [tuple(x.strip() for x in p.split(':')) for p in splitf(m.group(2))]
            order[sp].append(m.group(1)); specof[m.group(1)] = sp; cur = None; continue
        m = re.match(r'^type\s+(\w+)\s*$', l)
        if m: cur = m.group(1); types[cur] = []; order[sp].append(cur); specof[cur] = sp; continue
        m = re.match(r'^\s+(\w+)\s*\((.*)\)\s*$', l)
        if m and cur:
            types[cur].append((m.group(1), [p.strip() for p in splitf(m.group(2))])); continue
        raise Exception('spec line: ' + l)

# the leaf types: their sample (ATS1, ATS2) and dumper
LEAF = {}
def leaf(names, s1, s2, dd):
    for n in names.split(): LEAF[n] = (s1, s2, dd)
leaf('location loc_t', 'mkloc (%(k)d)', 'mkloc (%(k)d)', '$LOC.fprint_location (dd_out, x)')
leaf('symbol', 'mksym (%(k)d)', 'mksym (%(k)d)', '$SYM.fprint_symbol (dd_out, x)')
leaf('label', 'mklab (%(k)d)', 'mklab (%(k)d)', '$LAB.fprint_label (dd_out, x)')
leaf('filename', 'mkfil (%(k)d)', 'mkfil (%(k)d)', '$FIL.fprint_filename_full (dd_out, x)')
leaf('token', 'mktok_int (%(k)d)', 'mktok_int (%(k)d)', 'fprint_token (dd_out, x)')
leaf('i0nt', 'mktok_int (%(k)d)', 'mktok_int (%(k)d)', 'fprint_token (dd_out, x)')
leaf('c0har', 'mktok_chr (%(k)d)', 'mktok_chr (%(k)d)', 'fprint_token (dd_out, x)')
leaf('f0loat', 'mktok_flt (%(k)d)', 'mktok_flt (%(k)d)', 'fprint_token (dd_out, x)')
leaf('s0tring', 'mktok_str (%(k)d)', 'mktok_str (%(k)d)', 'fprint_token (dd_out, x)')
leaf('int', '%(k)d', '%(k)d', 'fprint_int (dd_out, x)')
leaf('bool', '%(b)s', '%(b)s', 'fprint_bool (dd_out, x)')
leaf('char', "mkchr (%(k)d)", "mkchr (%(k)d)", 'fprint_char (dd_out, x)')
leaf('double', '%(k)d.25', '%(k)d.25', 'fprint_double (dd_out, x)')
leaf('string', '"s%(k)d"', '"s%(k)d"', '(dd_ps "\\""; fprint_string (dd_out, x); dd_ps "\\"")')
leaf('S0Ed2ctype S1Ed2ctype', 'mkd2ctype ()', 'mkd2ctype ()', 'dd_ps "d2ctype(...)"')
leaf('Stropt', 'mkstropt (%(k)d)', 'mkstropt (%(k)d)', '$UT.fprint_stropt (dd_out, x)')
leaf('effect', 'mkeffect (%(k)d)', 'mkeffect (%(k)d)', '$EFF.fprint_effect (dd_out, x)')
leaf('effset', 'mkeffset (%(k)d)', 'mkeffset (%(k)d)', '$EFF.fprint_effset (dd_out, x)')
ENUMS = {   # enum type -> constructors
  'funkind': ['FK_fn', 'FK_fnx', 'FK_fun', 'FK_prfn', 'FK_prfun', 'FK_praxi', 'FK_castfn'],
  'valkind': ['VK_val', 'VK_val_pos', 'VK_val_neg', 'VK_prval'],
  'caskind': ['CK_case', 'CK_case_pos', 'CK_case_neg'],
  'dcstkind': ['DCKfun', 'DCKval', 'DCKpraxi', 'DCKprfun', 'DCKprval', 'DCKcastfn'],
  'macsynkind': ['MSKencode', 'MSKdecode', 'MSKxstage'],
  'cstsp': ['CSTSPmyfil', 'CSTSPmyloc', 'CSTSPmyfun'],
  'srpifkind': ['SRPIFKINDif', 'SRPIFKINDifdef', 'SRPIFKINDifndef'],
  'e0xpactkind': ['E0XPACTerror', 'E0XPACTprerr', 'E0XPACTprint', 'E0XPACTassert'],
  'assoc': ['ASSOCnon', 'ASSOClft', 'ASSOCrgt'],
}
for e, cs in ENUMS.items():
    LEAF[e] = ('ENUM', e, None)
LEAF['funclo'] = ('FUNCLO', 'funclo', None)
DD_FPRINT = {'funkind': 'fprint_funkind', 'valkind': 'fprint_valkind', 'caskind': 'fprint_caskind', 'dcstkind': 'fprint_dcstkind',
             'macsynkind': 'fprint_macsynkind', 'cstsp': 'fprint_cstsp', 'e0xpactkind': 'fprint_e0xpactkind', 'funclo': 'fprint_funclo'}

ALIAS = {'effvar': 'i0de'}
def known(t):
    return t in ALIAS or t in recs or t in types or t in lists or t in opts or t in LEAF

# 'labs0exp' ... are one-constructor datatypes in ATS1
SPECIAL1 = {'labs0exp': 'SL0ABELED', 'labd0exp': 'DL0ABELED', 'datsdef': 'DATSDEF', 'labs1exp': 'SL0ABELED', 'labd1exp': 'DL0ABELED'}

for r, fs in recs.items():
    for f, t in fs: assert known(t), (r, f, t)
for n, cs in types.items():
    for c, ts in cs:
        for t in ts: assert known(t), (n, c, t)

# ------------------------------------------------------------------------------------ dumpers
def dd_prelude(lang):
    fn = 'fun' if lang == 1 else 'fn'
    o = []
    o.append('(* generated by tree1_gen.py: complete dumper of the level-1 trees (%s) *)' % ('ATS1' if lang == 1 else 'ATS2'))
    leafdd = ['location', 'symbol', 'label', 'filename', 'token', 'int', 'bool', 'char', 'double', 'string', 'S1Ed2ctype', 'Stropt', 'effset',
              'funkind', 'valkind', 'caskind', 'dcstkind', 'macsynkind', 'cstsp', 'funclo']
    for n in ['loc_t']:
        o.append('%s dd_%s (x: %s): void = $LOC.fprint_location (dd_out, x)' % (fn, n, n))
    for n in leafdd:
        if n in ('location', 'symbol', 'label', 'filename', 'token', 'int', 'bool', 'string', 'funkind', 'valkind', 'macsynkind', 'cstsp'):
            if n in ('location', 'symbol', 'label', 'filename', 'token', 'int', 'bool', 'string', 'funkind', 'valkind', 'macsynkind', 'cstsp') and n in ('symbol', 'label', 'filename', 'location', 'token', 'int', 'bool', 'string', 'funkind', 'valkind', 'macsynkind', 'cstsp'):
                pass
    # (the level-0 dumpers of deepdump(1).hats already define: location symbol label token filename int bool string funkind valkind
    #  srpifkind cstsp e0xpactkind macsynkind assoc S0Ed2ctype i0nt c0har f0loat s0tring)
    o.append('%s dd_effvar (x: i0de): void = dd_i0de (x)' % fn)
    o.append('%s dd_char (x: char): void = fprint_char (dd_out, x)' % fn)
    o.append('%s dd_double (x: double): void = fprint_double (dd_out, x)' % fn)
    o.append('%s dd_S1Ed2ctype (x: S1Ed2ctype): void = dd_ps "S1Ed2ctype(...)"' % fn)
    o.append('%s dd_Stropt (x: Stropt): void = $UT.fprint_stropt (dd_out, x)' % fn)
    o.append('%s dd_effect (x: effect): void = $EFF.fprint_effect (dd_out, x)' % fn)
    o.append('%s dd_effset (x: effset): void = $EFF.fprint_effset (dd_out, x)' % fn)
    o.append('%s dd_caskind (x: caskind): void = fprint_caskind (dd_out, x)' % fn)
    o.append('%s dd_dcstkind (x: dcstkind): void = fprint_dcstkind (dd_out, x)' % fn)
    o.append('%s dd_funclo (x: funclo): void = fprint_funclo (dd_out, x)' % fn)
    return '\n'.join(o) + '\n'

def dd_group(lang):
    o = []
    first = [True]
    def kw():
        k = 'fun' if first[0] else 'and'
        first[0] = False
        return k
    names = []
    for sp in L1SPECS: names += order[sp]
    l1lists = {a: e for a, e in lists.items() if a not in ('symbolist',) and not a in LEVEL0LISTS}
    l1opts = {a: e for a, e in opts.items() if a not in ('symbolopt',) and not a in LEVEL0OPTS}
    for n in names:
        if n in recs:
            fs = recs[n]
            body = ['dd_ps "%s{"' % n]
            for i, (f, t) in enumerate(fs):
                body.append('dd_ps "%s%s="' % (',' if i else '', f))
                if lang == 1 and n in SPECIAL1:
                    body.append('dd_%s f%d' % (t, i))
                elif lang == 1:
                    body.append('dd_%s x.%s' % (t, f))
                else:
                    body.append('dd_%s (x.%s())' % (t, f))
            body.append('dd_ps "}"')
            if lang == 1 and n in SPECIAL1:
                o.append('%s dd_%s (x: %s): void = case+ x of %s (%s) => (%s)\n' % (kw(), n, n, SPECIAL1[n], ', '.join('f%d' % i for i in range(len(fs))), '; '.join(body)))
            else:
                o.append('%s dd_%s (x: %s): void = (%s)\n' % (kw(), n, n, '; '.join(body)))
        else:
            arms = []
            for c, ts in types[n]:
                vs = ['a%d' % i for i in range(len(ts))]
                cc = c
                if lang == 1 and c.endswith('2') and c in ('D0Cextype2', 'D1Cextype2'): cc = c[:-1]
                if lang == 1:
                    pat = '%s (%s)' % (cc, ', '.join(vs)) if vs else '%s ()' % cc
                else:
                    pat = '~%s (%s)' % (c, ', '.join(vs)) if vs else '~%s ()' % c
                parts = ['dd_ps "%s("' % c]
                for i, (v, t) in enumerate(zip(vs, ts)):
                    if i: parts.append('dd_ps ","')
                    parts.append('dd_%s %s' % (t, v) if lang == 1 else 'dd_%s (%s)' % (t, v))
                parts.append('dd_ps ")"')
                arms.append('  | %s => (%s)' % (pat, '; '.join(parts)))
            if lang == 1:
                o.append('%s dd_%s (x: %s): void = case+ x of\n%s\n' % (kw(), n, n, '\n'.join(arms)))
            else:
                o.append('%s dd_%s (x: %s): void = case+ %s_view (x) of\n%s\n' % (kw(), n, n, n, '\n'.join(arms)))
    for a, e in l1lists.items():
        o.append('%s dd_%s (xs: %s): void = (dd_ps "["; dd_%s_aux (xs, 0); dd_ps "]")\n' % (kw(), a, a, a))
        if lang == 1:
            o.append('and dd_%s_aux (xs: %s, i: int): void = case+ xs of\n  | list_cons (x, xs1) => ((if i > 0 then dd_ps ","); dd_%s x; dd_%s_aux (xs1, i+1))\n  | list_nil () => ()\n' % (a, a, e, a))
        else:
            o.append('and dd_%s_aux (xs: %s, i: int): void = case+ glist_view (xs) of\n  | ~GLcons (x, xs1) => ((if i > 0 then dd_ps ","); dd_%s (x); dd_%s_aux (xs1, i+1))\n  | ~GLnil () => ()\n' % (a, a, e, a))
    for a, e in l1opts.items():
        if lang == 1:
            o.append('%s dd_%s (x: %s): void = case+ x of\n  | Some y => (dd_ps "some("; dd_%s y; dd_ps ")")\n  | None () => dd_ps "-"\n' % (kw(), a, a, e))
        else:
            o.append('%s dd_%s (x: %s): void = case+ gopt_view (x) of\n  | ~GOsome (y) => (dd_ps "some("; dd_%s (y); dd_ps ")")\n  | ~GOnone () => dd_ps "-"\n' % (kw(), a, a, e))
    return '\n'.join(o)

# the lists and options of the level-0 spec (their dumpers are in deepdump(1).hats)
LEVEL0LISTS = set(); LEVEL0OPTS = set()
for l in open(os.path.join(d, '..', 'pats_syntax.spec')).read().split('\n'):
    m = re.match(r'^typedef\s+(\w+)\s*=\s*glist\((\w+)\)\s*$', l)
    if m: LEVEL0LISTS.add(m.group(1))
    m = re.match(r'^typedef\s+(\w+)\s*=\s*gopt\((\w+)\)\s*$', l)
    if m: LEVEL0OPTS.add(m.group(1))

# ------------------------------------------------------------------------------------ samples
# cost of the smallest tree of each type (fixpoint), to pick a terminating constructor for the recursive types
INF = 10**9
cost = {}
def tcost(t):
    t = ALIAS.get(t, t)
    if t in LEAF or t in lists or t in opts: return 1
    return cost.get(t, INF)
for _ in range(60):
    for r, fs in recs.items():
        cost[r] = 1 + sum(tcost(t) for f, t in fs) if all(tcost(t) < INF for f, t in fs) else INF
    for n, cs in types.items():
        best = INF
        for c, ts in cs:
            v = 1 + sum(tcost(t) for t in ts)
            best = min(best, v)
        cost[n] = best
minctor = {}
for n, cs in types.items():
    best = None; bv = INF
    for c, ts in cs:
        v = 1 + sum(tcost(t) for t in ts)
        if v < bv: bv = v; best = c
    minctor[n] = best

class S:
    def __init__(self, lang): self.lang = lang; self.k = 0; self.lmode = 1; self.omode = 0; self.depth = 0
    def nk(self):
        self.k += 1; return self.k
    def leaf(self, t):
        a, b, _ = LEAF[t]
        k = self.nk()
        if a == 'ENUM':
            cs = ENUMS[t]; c = cs[k % len(cs)]
            return '%s ()' % c if self.lang == 1 else c
        if a == 'FUNCLO':
            return rnd_funclo(k, self.lang)
        s = a if self.lang == 1 else b
        return s % {'k': k, 'b': 'true' if k % 2 else 'false'}
    def lst(self, a, e):
        n = self.lmode
        xs = [self.val(e) for _ in range(n)]
        if self.lang == 1:
            r = 'list_nil ()'
            for x in reversed(xs): r = 'list_cons (%s, %s)' % (x, r)
            return r
        r = 'glist_nil ()'
        for x in reversed(xs): r = 'glist_cons (%s, %s)' % (x, r)
        return r
    def opt(self, a, e):
        if self.omode: return ('Some (%s)' if self.lang == 1 else 'gopt_some (%s)') % self.val(e)
        return 'None ()' if self.lang == 1 else 'gopt_none ()'
    def val(self, t, forcector=None):
        t = ALIAS.get(t, t)
        if t in LEAF: return self.leaf(t)
        if t in lists: return self.lst(t, lists[t])
        if t in opts: return self.opt(t, opts[t])
        if t in recs: return self.rec(t, forcector)
        return self.node(t, forcector)
    def rec(self, r, forced=None):
        fs = recs[r]
        args = []
        for f, t in fs:
            if t in types:
                args.append(self.node(t, forced if forced and forced[0] == t else None))
            else:
                args.append(self.val(t))
        if self.lang == 1:
            if r in SPECIAL1: return '%s (%s)' % (SPECIAL1[r], ', '.join(args))
            return "'{%s}" % ', '.join('%s= %s' % (f, a) for (f, t), a in zip(fs, args))
        return '%s_new (%s)' % (r, ', '.join(args))
    def node(self, t, forced=None):
        if forced and forced[0] == t: c = forced[1]
        else: c = minctor[t]
        ts = dict(types[t])[c]
        args = [self.val(x) for x in ts]
        return self.ctor(t, c, args)
    def ctor(self, t, c, args):
        if self.lang == 1:
            cc = c[:-1] if c in ('D0Cextype2', 'D1Cextype2') else c
            return '%s (%s)' % (cc, ', '.join(args))
        return '%s_%s (%s)' % (t, c, ', '.join(args))

def rnd_funclo(k, lang):
    cs = ['FUNCLOfun ()' if lang == 1 else 'FUNCLOfun', 'FUNCLOclo (1)', 'FUNCLOclo (0)', 'FUNCLOclo (~1)']
    return cs[k % 4]

# ------------------------------------------------------------------------------------ the functions of the sats files
def strip_comments(s):
    out = []; i = 0; n = len(s); depth = 0
    while i < n:
        if s.startswith('(*', i): depth += 1; i += 2; continue
        if depth and s.startswith('*)', i): depth -= 1; i += 2; continue
        if depth:
            if s[i] == '\n': out.append('\n')
            i += 1; continue
        if s.startswith('//', i):
            j = s.find('\n', i)
            if j < 0: j = n
            i = j; continue
        out.append(s[i]); i += 1
    return ''.join(out)

FUNS = []   # (name, [(pname, ptype)], rtype)
def read_funs(path):
    t = strip_comments(open(path).read())
    for m in re.finditer(r'(?m)^(?:fun|and)\s+(\w+)\s*\(', t):
        name = m.group(1)
        i = m.end() - 1
        dep = 0; j = i
        while True:
            if t[j] == '(': dep += 1
            if t[j] == ')':
                dep -= 1
                if dep == 0: break
            j += 1
        params = t[i+1:j]
        rest = t[j+1:j+200]
        mm = re.match(r'\s*:\s*([\w\']+)', rest)
        if not mm: continue
        rt = mm.group(1)
        ps = []
        ok = True
        for p in splitf(params):
            pm = re.match(r'^(\w+)\s*(?:\([^)]*\))?\s*:\s*(.+)$', p)
            if not pm: ok = False; break
            pt = pm.group(2).strip()
            pt = re.sub(r'\s*//.*$', '', pt)
            ps.append((pm.group(1), pt))
        if ok: FUNS.append((name, ps, rt))
for f in ('pats_staexp1.sats', 'pats_dynexp1.sats'):
    read_funs(os.path.join(d, '..', '..', 'src', f))

PTYPES = dict((k, k) for k in list(recs) + list(types) + list(lists) + list(opts) + list(LEAF))
PTYPES['s1explst_vt'] = 'LISTVT'
def fprinter(t):
    """the name of the printer fprint_T of the type t (declared in the sats files) or None"""
    return 'fprint_' + t if ('fprint_' + t) in PRINTERS else None
# declared in the sats files of ATS1 and never implemented (also not in src)
UNIMPL = set(['fprint_d1atcon', 'fprint_d1atdec', 'fprint_s1var', 's1var_make', 'sp1at_arg'])
PRINTERS = set()
for f in ('pats_staexp1.sats', 'pats_dynexp1.sats'):
    for m in re.finditer(r'fun\s+(fprint_\w+)', strip_comments(open(os.path.join(d, '..', '..', 'src', f)).read())):
        if m.group(1) not in UNIMPL: PRINTERS.add(m.group(1))

# the functions whose result is not a tree are dumped by the shown type
def gen_cases(lang):
    cases = []   # (title, code lines)
    Sx = S
    def mk_print(t, e, title):
        if t in recs or t in types or t in lists or t in opts:
            pr = fprinter(t)
            body = 'val x = %s\n  val () = (dd_%s x; dd_ps "\\n")\n' % (e, t) if lang == 1 else 'val x = %s\n  val () = (dd_%s (x); dd_ps "\\n")\n' % (e, t)
            if pr: body += '  val () = (%s (dd_out, x); dd_ps "\\n")\n' % pr
        elif t == 'bool':
            body = 'val x = %s\n  val () = (fprint_bool (dd_out, x); dd_ps "\\n")\n' % e
        elif t == 'void':
            body = 'val () = %s\n' % e
        else:
            body = 'val x = %s\n  val () = (dd_%s x; dd_ps "\\n")\n' % (e, t)
        return body
    # ---- 1. every constructor of every node type
    for sp in L1SPECS:
        for n in order[sp]:
            if n in recs:
                # a record without a node field: one sample
                has_node = any(t in types for f, t in recs[n])
                if has_node: continue
                for lm, om in ((0, 0), (1, 1), (2, 0)):
                    s = Sx(lang); s.lmode = lm; s.omode = om
                    cases.append(('record %s lists=%d' % (n, lm), mk_print(n, s.val(n), n)))
        for n in order[sp]:
            if n not in types: continue
            owner = None
            for r, fs in recs.items():
                if any(t == n for f, t in fs): owner = r; break
            for c, ts in types[n]:
                for lm, om in ((0, 0), (1, 1), (2, 0), (2, 1)):
                    s = Sx(lang); s.lmode = lm; s.omode = om
                    if owner: e = s.rec(owner, (n, c)); t = owner
                    else: e = s.node(n, (n, c)); t = n
                    cases.append(('%s.%s lists=%d opts=%d' % (n, c, lm, om), mk_print(t, e, c)))
    # ---- 2. the functions of the sats files
    skip = re.compile(r'^(fprint_|print_|prerr_|.*_view$)')
    DEEP = re.compile(r'(make_e1xp|make_s1exp|make_p1at|make_d1exp|make_v1al|d1exp_sing|d1exp_is_metric|ann_funclo_opt|s1rt_is_arrow|wths1explst_|effcst_contain|^s1exp_list$|^p1at_list$|^d1exp_list$|^s1rt_list$)')
    nskipped = []
    for name, ps, rt in FUNS:
        if skip.match(name) or name in UNIMPL: continue
        if name in ('e1xp_make', 's1exp_make', 'p1at_make', 'd1exp_make'): pass
        ok = all(pt in PTYPES for pn, pt in ps) and (rt in PTYPES or rt in ('bool', 'void'))
        if not ok: nskipped.append((name, ps, rt)); continue
        # the arguments: for a deep function, every constructor of the node type of the first record argument
        variants = [None]
        if DEEP.search(name) and ps:
            t0 = ps[0 if ps[0][1] not in ('location', 'loc_t') else (1 if len(ps) > 1 else 0)][1]
            if t0 in recs:
                for f, tt in recs[t0]:
                    if tt in types: variants = [(tt, c) for c, _ in types[tt]]
            elif t0 in types:
                variants = [(t0, c) for c, _ in types[t0]]
        for var in variants:
            for lm, om in ((0, 0), (1, 1), (2, 0)):
                s = Sx(lang); s.lmode = lm; s.omode = om
                args = []
                used = False
                for pn, pt in ps:
                    if pt == 's1explst_vt':
                        xs = [s.val('s1exp') for _ in range(lm)]
                        r = 'list_vt_nil ()'
                        for x in reversed(xs): r = 'list_vt_cons (%s, %s)' % (x, r)
                        args.append(r)
                    elif var and not used and (pt in recs and any(tt == var[0] for f, tt in recs[pt])):
                        args.append(s.rec(pt, var)); used = True
                    elif var and not used and pt == var[0]:
                        args.append(s.node(pt, var)); used = True
                    else:
                        args.append(s.val(pt))
                call = '%s (%s)' % (name, ', '.join(args)) if args else '%s ()' % name
                title = '%s%s lists=%d opts=%d' % (name, (' ' + var[1]) if var else '', lm, om)
                cases.append((title, mk_print(rt, call, name)))
                if not var and not any(pt in lists or pt in opts or pt == 's1explst_vt' for pn, pt in ps): break
    return cases, nskipped

def emit(lang):
    cases, nskipped = gen_cases(lang)
    o = ['(* generated by tree1_gen.py (%s) *)' % ('ATS1' if lang == 1 else 'ATS2')]
    fn = 'fun'
    for i, (title, body) in enumerate(cases):
        o.append('%s tcase_%d (): void = let\n  val () = (dd_ps "case %d: %s"; dd_ps "\\n")\n  %s  val () = dd_flush ()\nin end\n' % (fn, i, i, title, body))
    o.append('%s tcase_all (): void = (%s)' % (fn, '; '.join('tcase_%d ()' % i for i in range(len(cases)))))
    return '\n'.join(o) + '\n', len(cases), nskipped

if __name__ == '__main__':
    for lang in (1, 2):
        sfx = '1' if lang == 1 else ''
        open(os.path.join(d, 'deepdump%s_l1.hats' % sfx), 'w').write(dd_prelude(lang) + '\n' + dd_group(lang))
        # deepdump%s_t1.hats (the whole-file test of the level-1 translation, d1dump(1).dats): the same dumpers, but the d1eclist of
        # a D1Cstaload is shared (the translation of a staloaded file is cached) and is dumped only the first time: the driver
        # defines dd_staload_seen (fil)
        grp = dd_group(lang)
        if lang == 1:
            old1 = 'dd_int a2; dd_ps ","; dd_d1eclist a3; dd_ps ")")'
            new1 = 'dd_int a2; dd_ps ","; dd_staload_d1eclist (a1, a3); dd_ps ")")'
        else:
            old1 = 'dd_int (a2); dd_ps ","; dd_d1eclist (a3); dd_ps ")")'
            new1 = 'dd_int (a2); dd_ps ","; dd_staload_d1eclist (a1, a3); dd_ps ")")'
        assert grp.count(old1) == 1
        grp = grp.replace(old1, new1)
        grp += '\nand dd_staload_d1eclist (fil: filename, xs: d1eclist): void =\n  if dd_staload_seen (fil) then dd_ps "<staloaded>" else dd_d1eclist (%s)\n' % ('xs')
        open(os.path.join(d, 'deepdump%s_t1.hats' % sfx), 'w').write(dd_prelude(lang) + '\n' + grp)
        txt, n, nskipped = emit(lang)
        open(os.path.join(d, 'treecases%s.hats' % sfx), 'w').write(txt)
        sys.stderr.write('lang %d: %d cases, %d functions skipped (%s)\n' % (lang, n, len(nskipped), ', '.join(x[0] for x in nskipped)))
