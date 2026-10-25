#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
"""
port_parser: first mechanical pass for porting a hand-written ATS1 parser (src/pats_parsing_*.dats)
to the ATS2 parser of src2/ (PORTING.md, section "Parser, phase 2"). Usage:
    port_parser.py src/pats_parsing_X.dats draft.dats
It rewrites
  * [case+ tok.token_node of | T_X (v) => .. | _ when ptest_fun (..) => .. | _ => ..] (also [case+ 0 of],
    [case+ tnode of]) into a chain of [if token_node_is_T_X(tnd) then (..) else ..] with
    [val tnd = tok.token_node()] and [val v = token_ival_get(tok)] (helpers of pats_parsing.hats);
  * [{T}] template arguments into [<T>] and the missing ones ([ptest_fun<T>], [pstar_fun<T>],
    [pif_fun<T>], [synent_null<T>], [tokbuf_set_ntok_null<T>], [list12_free<T>]: T from the parser
    signatures; [XXX_...] remains where it cannot be guessed);
  * Some/None/list_cons/list_nil, Option, List_vt, [(l2l)x], [val+~], [var ent: synent?], [.token_loc];
and replaces [p_d0eclseq_fun] by the template version.
The header (staloads), the [fun] -> [implement] of functions that the .sats declares, string concatenation,
and the remaining type errors are done by hand. The path of pats_parsing.sats below is the one of this repo.
"""
#!/usr/bin/env python3
# first mechanical pass: ATS1 parser source -> ATS2 draft (token cases -> if chains, template args, etc.)
import re, sys

src = open(sys.argv[1]).read()
import os
SATS = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'src2', 'pats_parsing.sats')).read()

def mask_of(s):
    n = len(s); m = [False]*n; i = 0; depth = 0
    while i < n:
        if s.startswith('(*', i) and not s.startswith('(*)', i):
            depth += 1; m[i] = m[i+1] = True; i += 2; continue
        if depth:
            if s.startswith('*)', i):
                depth -= 1; m[i] = m[i+1] = True; i += 2; continue
            m[i] = True; i += 1; continue
        if s.startswith('//', i):
            while i < n and s[i] != '\n': m[i] = True; i += 1
            continue
        if s[i] == '"':
            m[i] = True; i += 1
            while i < n and s[i] != '"':
                if s[i] == '\\': m[i] = True; i += 1
                m[i] = True; i += 1
            if i < n: m[i] = True
            i += 1; continue
        if s[i] == "'":
            if i+2 < n and s[i+2] == "'" and s[i+1] != '\\':
                m[i] = m[i+1] = m[i+2] = True; i += 3; continue
            if i+1 < n and s[i+1] == '\\':
                j = s.find("'", i+2)
                if 0 < j < i+6:
                    for k in range(i, j+1): m[k] = True
                    i = j+1; continue
        i += 1
    return m

# ---- parser type map
ptype = {}
for m in re.finditer(r'fun\s+(p_\w+)\s*:\s*parser\s*\(\s*([\w ]+?)\s*\)', SATS):
    ptype[m.group(1)] = m.group(2)
for m in re.finditer(r'fun\s+(p_\w+)\s*:\s*parser\s*\(\s*(\w+)\s*\)', SATS):
    ptype[m.group(1)] = m.group(2)
for m in re.finditer(r'fun\s+(p_\w+)\s*:\s*parser\s*\(\s*(\w+)\s*\)', src):
    ptype[m.group(1)] = m.group(2)
ptype['p_EOF'] = 'token'
for t in 'AND END THEN ELSE AS OF IN IF SIF CASE SCASE IFCASE REC WITH WHEN FORSTAR WHILESTAR TRY BAR COLON COMMA SEMICOLON LPAREN RPAREN LBRACKET RBRACKET LBRACE RBRACE BANG DOT EQ EQGT GT GTDOT GTLT SRPTHEN SRPENDIF'.split():
    ptype['p_' + t] = 'token'
lst12 = {}
for m in re.finditer(r'viewtypedef\s+(\w+)\s*=\s*list12\s*\(\s*(\w+)\s*\)', src):
    lst12[m.group(1)] = m.group(2)

def add_local_types(s):
    msk = mask_of(s)
    # col-0 definitions: fun/implement/and  NAME ( ... ) : T =
    for m in re.finditer(r'^(?:fun|fn|and|implement|extern\s+fun)\s*\n?\s*(p_\w+|\w+)\b', s, re.M):
        pass

# ---- definition scopes
def defs_of(s):
    msk = mask_of(s)
    out = []
    for m in re.finditer(r'^(fun|fn|and|implement|extern)\b', s, re.M):
        if msk[m.start()]: continue
        out.append(m.start())
    return out

def ret_type_of_def(s, pos):
    # text from pos to the first '=' at depth 0 after the params
    msk = mask_of(s)
    m = re.match(r'(extern\s+)?(fun|fn|and|implement)\s*', s[pos:])
    j = pos + m.end()
    # name
    m2 = re.match(r'(\{[^}]*\}\s*)?(\w+)', s[j:])
    if not m2: return None, None
    name = m2.group(2)
    # find ') : T' pattern at depth 0
    k = j + m2.end(); d = 0; n = len(s)
    last_close = None
    while k < n:
        if msk[k]: k += 1; continue
        c = s[k]
        if c in '([{': d += 1
        elif c in ')]}': d -= 1;
        if d == 0 and c == ')':
            last_close = k
        if d == 0 and c == '=' and s[k+1:k+2] != '>' and s[k-1:k] not in '<>=':
            break
        k += 1
    seg = s[(last_close or j):k]
    m3 = re.search(r':\s*([^=]*?)\s*$', seg, re.S)
    t = None
    if m3 and last_close is not None:
        t = re.sub(r'\s+', ' ', re.sub(r'\(\*.*?\*\)', '', m3.group(1))).strip()
        t = t.split('//')[0].strip()
    return name, t

defs = defs_of(src)
deftypes = {}  # name -> ret type
for p in defs:
    try:
        nm, t = ret_type_of_def(src, p)
    except Exception:
        continue
    if nm and t:
        deftypes[nm] = t
        if nm.startswith('p_') and nm not in ptype and re.match(r'^\w+$', t):
            ptype[nm] = t
# implement p_x without ': T' -> from sats (already in ptype)

def ptype_of(name):
    return ptype.get(name)

def enclosing_ret(pos):
    best = None
    for p in defs:
        if p < pos: best = p
        else: break
    if best is None: return None
    nm, t = ret_type_of_def(src2[0], best)
    if nm in ptype: return ptype[nm]
    return t or deftypes.get(nm)

src2 = [src]

# ---- token-case conversion
KW_STOP = set('then else andalso'.split())
IVAL = set('DLRLST DLRTUP DLRREC ABSTYPE MACDEF TYPEDEF DATATYPE VAR IMPLEMENT LAM FIX DLRVCOPYENV DLRDELAY DLREFFMASK_ARG'.split())
SVAL = set('IDENT_alp IDENT_sym IDENT_arr IDENT_tmp IDENT_dlr STRING'.split())
def helper_of(c):
    if c in IVAL: return 'token_ival_get'
    if c in SVAL: return 'token_sval_get'
    if c == 'FUN': return 'token_fun_get'
    if c == 'VAL': return 'token_val_get'
    raise Exception('payload ' + c)

def find_case_end(s, msk, i):
    n = len(s); stack = []; d = 0
    j = i
    while j < n:
        if msk[j]: j += 1; continue
        c = s[j]
        if c in '([{':
            stack.append(c)
        elif c in ')]}':
            if not stack: return j
            stack.pop()
        elif c.isalpha() or c == '_':
            k = j
            while k < n and (s[k].isalnum() or s[k] in "_'$"): k += 1
            w = s[j:k]
            prev = s[j-1] if j > 0 else ' '
            if prev not in '#$.%':
                if w in ('let', 'begin', 'local'):
                    stack.append('let')
                elif w == 'in':
                    if stack and stack[-1] == 'let': stack[-1] = 'in'
                    elif not stack: return j
                elif w == 'end':
                    if not stack: return j
                    stack.pop()
                elif not stack and w in KW_STOP: return j
                elif not stack and w in ('implement', 'fun', 'fn', 'extern', 'and', 'val', 'var', 'staload', 'dynload', 'overload', 'datatype', 'typedef', 'macdef') and re.match(r'[ \t]*\n', s[:j][-1:] and '') is None and (j == 0 or s[j-1] == '\n'):
                    return j
            j = k; continue
        elif c == ',' and not stack:
            return j
        j += 1
    return n

def split_top(s, msk_off, text, sep):
    # split text at depth-0 sep (single token '|'), returns list of (start,end) pieces
    pass

def split_arms(s, msk, a, b):
    # positions of depth-0 '|' (not '||') between a,b; and '=>' handled later
    parts = []; stack = []; cur = a; j = a
    while j < b:
        if msk[j]: j += 1; continue
        c = s[j]
        if c in '([{': stack.append(c)
        elif c in ')]}': stack.pop()
        elif c.isalpha() or c == '_':
            k = j
            while k < b and (s[k].isalnum() or s[k] in "_'$"): k += 1
            w = s[j:k]
            prev = s[j-1] if j > 0 else ' '
            if prev not in '#$.%':
                if w in ('let', 'begin', 'local'): stack.append('let')
                elif w == 'in':
                    if stack and stack[-1] == 'let': stack[-1] = 'in'
                elif w == 'end': stack.pop()
            j = k; continue
        elif c == '|' and not stack and s[j+1:j+2] != '|' and s[j-1:j] != '|':
            parts.append(s[cur:j]); cur = j + 1
        j += 1
    parts.append(s[cur:b])
    return parts

def strip_cm(t):
    m = mask_of(t)
    return ''.join(ch for ch, mm in zip(t, m) if not mm)

def convert_cases(s):
    # find the last convertible case, convert it, repeat
    while True:
        msk = mask_of(s)
        cands = []
        for m in re.finditer(r'\bcase\+?\s+', s):
            if msk[m.start()]: continue
            # scrutinee up to ' of'
            e = re.compile(r'\bof\b')
            mm = e.search(s, m.end())
            while mm and msk[mm.start()]: mm = e.search(s, mm.end())
            if not mm: continue
            scrut = strip_cm(s[m.end():mm.start()]).strip()
            if re.match(r'^\w+\.token_node$', scrut) or scrut == '0' or scrut in ('tnode', 'tnd'):
                cands.append((m.start(), m.end(), mm.end(), scrut))
        if not cands: return s
        done = False
        for (cs, ce, ae, scrut) in reversed(cands):
            if scrut == '0' or True:
                end = find_case_end(s, msk, ae)
                body = s[ae:end]
                new = convert_one(s, msk, cs, ae, end, scrut)
                if new is None: continue
                s = s[:cs] + new + s[end:]
                done = True
                break
        if not done: return s

skipped = []
def convert_one(s, msk, cs, ae, end, scrut):
    parts = split_arms(s, msk, ae, end)
    arms = []  # (conds, binds, body)
    pend = []
    lead_comments = ''
    for pt in parts:
        pm = mask_of(pt)
        # find depth-0 '=>'
        idx = None; stack = []; j = 0
        while j < len(pt):
            if pm[j]: j += 1; continue
            c = pt[j]
            if c in '([{': stack.append(c)
            elif c in ')]}': stack.pop()
            elif c == '=' and pt[j+1:j+2] == '>' and not stack:
                idx = j; break
            j += 1
        if idx is None:
            if strip_cm(pt).strip() == '' : continue
            pend.append(strip_cm(pt).strip()); continue
        pat = strip_cm(pt[:idx]).strip()
        body = pt[idx+2:]
        pend.append(pat)
        arms.append((pend, body)); pend = []
    if pend:
        return None
    tokvar = None
    m = re.match(r'^(\w+)\.token_node$', scrut)
    if m: tokvar = m.group(1)
    basevar = None
    out = []
    # decide var name
    names = set()
    for pats, body in arms:
        for p in pats:
            mw = re.match(r'^(\w+)\s+when\b', p)
            if mw and not p.startswith('T_') and mw.group(1) != '_': names.add(mw.group(1))
            elif re.match(r'^[a-z]\w*$', p): names.add(p)
    if scrut in ('tnode', 'tnd'): tn = scrut
    elif names: tn = sorted(names)[0]
    else: tn = 'tnd'
    chain = []
    for pats, body in arms:
        conds = []; binds = []; whens = []
        for p in pats:
            when = None
            mw = re.match(r'^(.*?)\s+when\s+(.*)$', p, re.S)
            if mw: p, when = mw.group(1).strip(), mw.group(2).strip()
            if p == '_' or re.match(r'^[a-z]\w*$', p):
                c = None
                if p != '_' and p != tn and p != scrut: binds.append('val %s = %s' % (p, tn))
            else:
                mc = re.match(r'^(T_\w+)\s*(.*)$', p, re.S)
                if not mc: raise Exception('pattern ' + p)
                con = mc.group(1); rest = mc.group(2).strip()
                c = 'token_node_is_%s(%s)' % (con, tn)
                mv = re.match(r'^\(\s*(\w+)\s*\)$|^()(\w+)$', rest)
                if mv and mv.group(1) is None: mv = re.match(r'^(\w+)$', rest)
                if mv and mv.group(1) != '_':
                    if len(pats) > 1: raise Exception('or-pattern with payload')
                    binds.append('val %s = %s(%s)' % (mv.group(1), helper_of(con[2:]), tokvar))
                elif rest not in ('', '_', '()', '(_)') and not mv:
                    raise Exception('pattern rest ' + rest)
            if when is not None:
                c = '(%s) && (%s)' % (c, when) if c else when
            conds.append(c)
        if any(c is None for c in conds) and len(pats) > 1: raise Exception('or default')
        cond = None if (len(conds) == 1 and conds[0] is None) else ' || '.join('(%s)' % c if len(conds) > 1 else c for c in conds)
        chain.append((cond, binds, body))
    # build
    res = []
    for k, (cond, binds, body) in enumerate(chain):
        b = body.strip('\n')
        if strip_cm(b).strip() == '()' and not binds: b = '()';
        if binds:
            b = 'let %s in\n%s\nend' % (' '.join(binds), b)
        if cond is None:
            if k != len(chain) - 1: raise Exception('default not last')
            res.append(b if b == '()' else '(\n%s\n)' % b)
        else:
            res.append('if %s then %s' % (cond, b if b == '()' else '(\n%s\n)' % b))
    if chain[-1][0] is not None:
        res.append('(assertloc(false); %s)' % 'abort_unreach()')
    text = '\nelse '.join(res)
    if scrut.endswith('.token_node'):
        text = 'let val %s = %s.token_node() in\n%s\nend' % (tn, tokvar, text)
    return '(' + text + ')'

src = convert_cases(src)
src2[0] = src

# ---- textual rewrites
def sub_code(s, pat, fn, flags=0):
    msk = mask_of(s)
    def f(m):
        if msk[m.start()]: return m.group(0)
        return fn(m)
    return re.sub(pat, f, s, flags=flags)

s = src
s = sub_code(s, r'\.token_loc\b(?!\s*\()', lambda m: '.token_loc()')
s = sub_code(s, r'\.token_node\b(?!\s*\()', lambda m: '.token_node()')
s = sub_code(s, r'\(l2l\)\s*(\w+)', lambda m: 'l2l(%s)' % m.group(1))
s = sub_code(s, r'\(t2t\)\s*(\w+)', lambda m: 't2t(%s)' % m.group(1))
s = sub_code(s, r'val\+~', lambda m: 'val ~')
s = sub_code(s, r'var ent: synent\?', lambda m: 'var ent: synent = synent_null<synent>()')
s = sub_code(s, r'\bList_vt\s*\(', lambda m: 'List0_vt(')
s = sub_code(s, r'(:\s*)(\w+?)lst_vt\b', lambda m: '%sList0_vt(%s)' % (m.group(1), m.group(2)))
s = sub_code(s, r'\bviewtypedef\b', lambda m: 'vtypedef')
s = sub_code(s, r'list_of_list_vt', lambda m: 'glist_make_list_vt')
s = sub_code(s, r'option_of_option_vt', lambda m: 'gopt_make_option_vt')
TPL = r'pseq2_fun|pseq3_fun|pstar_fun0_\w+|pstar_fun1_\w+|pstar1_fun|pstar_fun|pstar_sep_fun|pstar_COMMA_fun|popt_fun|ptest_fun|pif_fun|plist12_fun|p1list12_fun|ptokentopt_fun|ptokwrap_fun|list12_free|tokbuf_set_ntok_null|synent_null'
s = sub_code(s, r'\b(%s)\s*\{([^{}]*)\}\s*' % TPL, lambda m: '%s<%s>' % (m.group(1), re.sub(r'\s+', '', m.group(2))))
s = sub_code(s, r'\b(list12_free|tokbuf_set_ntok_null|synent_null)\s*(?=\()', lambda m: m.group(0).rstrip())
s = re.sub(r'\bsynent_null\s*\(\s*(\(\*[^*]*\*\))?\s*\)', lambda m: 'synent_null()', s)

# ---- options and lists of the tree (as in utils/arenagen/port_ats1.py)
def casef(m):
    scr = m.group(2)
    rest = s_[m.end():m.end()+400]
    a = re.match(r'(?:\s|//[^\n]*\n|\(\*.*?\*\))*\|?\s*(~?)(\w+)', rest, re.S)
    c = a.group(2) if a else ''
    if c in ('Some', 'None'): return '%sgopt_view(%s) of' % (m.group(1), scr.strip())
    if c in ('list_cons', 'list_nil'): return '%sglist_view(%s) of' % (m.group(1), scr.strip())
    return m.group(0)
s_ = s
s = sub_code(s, r'(case\+?\s+)((?:(?!\bof\b).)+?)\s+of\b', casef, re.S)
s = sub_code(s, r'(\||\bof\b)(\s*)Some\s*\(?\s*([\w.]+)\s*\)?\s*=>', lambda m: '%s%s~GOsome(%s) =>' % (m.group(1), m.group(2), m.group(3)))
s = sub_code(s, r'(\||\bof\b)(\s*)None\s*(\(\s*\)|_)?\s*=>', lambda m: '%s%s~GOnone() =>' % (m.group(1), m.group(2)))
s = sub_code(s, r'(\||\bof\b)(\s*)list_cons\s*\(([^()]*)\)\s*=>', lambda m: '%s%s~GLcons(%s) =>' % (m.group(1), m.group(2), m.group(3)))
s = sub_code(s, r'(\||\bof\b)(\s*)list_cons\s*_\s*=>', lambda m: '%s%s~GLcons(_, _) =>' % (m.group(1), m.group(2)))
s = sub_code(s, r'(\||\bof\b)(\s*)list_nil\s*(\(\s*\)|_)?\s*=>', lambda m: '%s%s~GLnil() =>' % (m.group(1), m.group(2)))
s = sub_code(s, r'\bNone\s*\(\s*\)', lambda m: 'gopt_none()')
s = sub_code(s, r'\bSome\s*\(', lambda m: 'gopt_some(')
s = sub_code(s, r'\blist_nil\s*\(\s*\)', lambda m: 'glist_nil()')
s = sub_code(s, r'\blist_nil\b(?!\s*\()', lambda m: 'glist_nil()')
s = sub_code(s, r'\blist_cons\s*\(', lambda m: 'glist_cons(')
s = sub_code(s, r'\blist_sing\s*\(', lambda m: 'glist_sing(')
s = sub_code(s, r'\bOption\s*\(', lambda m: 'gopt(')
s = sub_code(s, r'\bOption\s+(\w+)', lambda m: 'gopt(%s)' % m.group(1))
src2[0] = s

def argsplit(t):
    parts = []; d = 0; b = ''
    for ch in t:
        if ch in '([{': d += 1
        if ch in ')]}': d -= 1
        if ch == ',' and d == 0: parts.append(b.strip()); b = ''; continue
        b += ch
    parts.append(b.strip()); return parts

def call_args(s, pos):
    # pos at '(' ; return (inner, endpos)
    msk = mask_of(s); d = 0; j = pos
    while j < len(s):
        if not msk[j]:
            if s[j] in '([{': d += 1
            elif s[j] in ')]}':
                d -= 1
                if d == 0: return s[pos+1:j], j
        j += 1
    raise Exception('unbalanced')

# add explicit template args where missing
def add_targs(s):
    out = []; i = 0
    msk = mask_of(s)
    pat = re.compile(r'\b(pseq2_fun|pseq3_fun|pstar_fun0_\w+|pstar_fun1_\w+|pstar1_fun|pstar_fun|pstar_sep_fun|pstar_COMMA_fun|popt_fun|ptest_fun|pif_fun|plist12_fun|p1list12_fun|ptokentopt_fun|ptokwrap_fun|list12_free|tokbuf_set_ntok_null|synent_null)(\s*)\(')
    pos = 0; res = ''
    for m in pat.finditer(s):
        if msk[m.start()] or m.start() < pos: continue
        name = m.group(1)
        lp = m.end() - 1
        inner, rp = call_args(s, lp)
        args = argsplit(inner)
        T = None
        def pt(a):
            a = a.strip()
            return ptype_of(a)
        if name in ('pstar_fun', 'popt_fun', 'plist12_fun') or name.startswith('pstar_fun0_') or name in ('pstar_COMMA_fun',):
            T = pt(args[-1]) if name != 'pstar_sep_fun' else None
        elif name.startswith('pstar_fun1_'):
            T = pt(args[3] if name == 'pstar_fun1_sep' else args[3])
        elif name in ('pstar1_fun',): T = pt(args[3])
        elif name == 'pstar_sep_fun': T = pt(args[3])
        elif name == 'ptest_fun': T = pt(args[1])
        elif name == 'pif_fun': T = pt(args[3])
        elif name == 'ptokentopt_fun': T = pt(args[2])
        elif name == 'p1list12_fun': T = pt(args[3])
        elif name == 'ptokwrap_fun': T = enclosing_ret(m.start())
        elif name == 'tokbuf_set_ntok_null': T = enclosing_ret(m.start())
        elif name == 'synent_null': T = enclosing_ret(m.start())
        elif name == 'pseq2_fun':
            ts = [pt(args[3]), pt(args[4])]
            T = ','.join(ts) if all(ts) else None
        elif name == 'pseq3_fun':
            ts = [pt(args[3]), pt(args[4]), pt(args[5])]
            T = ','.join(ts) if all(ts) else None
        elif name == 'list12_free':
            v = args[0].strip()
            mm = None
            for mm2 in re.finditer(r'val\s+%s\s*=\s*(?:\(\s*)?(?:\n\s*)?(\w+)' % re.escape(v), s[:m.start()]): mm = mm2
            mp = None
            for mp2 in re.finditer(r'\b%s\s*:\s*(\w+)' % re.escape(v), s[:m.start()]): mp = mp2
            if mp and mp.group(1) in lst12: T = lst12[mp.group(1)]
            if mm:
                rt = deftypes.get(mm.group(1))
                if rt in lst12: T = lst12[rt]
        if T is None:
            T = 'XXX_' + name
        res += s[pos:m.start()] + '%s<%s>(' % (name, T)
        pos = lp + 1
    res += s[pos:]
    return res

defs = defs_of(s)
src2[0] = s
s = add_targs(s)

NEWSEQ = """implement
{a}(*tmp*)
p_d0eclseq_fun
  (buf, bt, f) = let
//
fun loop (
  buf: &tokbuf
, err: &int, acc: List0_vt(a)
) : List0_vt(a) = let
  val x = f (buf, 1(*bt*), err)
in
  if err > 0 then list_vt_reverse (acc) // HX: [x] is dropped
  else let
    val semilst = pstar_fun<token>(buf, 1(*bt*), p_SEMICOLON)
    val () = list_vt_free (semilst)
  in
    loop (buf, err, list_vt_cons (x, acc))
  end // end of [else]
end // end of [loop]
//
var err: int = 0
//
in
  loop (buf, err, list_vt_nil ()) (* properly ordered *)
end // end of [p_d0eclseq_fun]"""
i = s.find('implement\np_d0eclseq_fun') if False else -1

mi = re.search(r'implement\s*\np_d0eclseq_fun.*?end // end of \[p_d0eclseq_fun\]', s, re.S)
if mi: s = s[:mi.start()] + NEWSEQ + s[mi.end():]
open(sys.argv[2], 'w').write(s)
