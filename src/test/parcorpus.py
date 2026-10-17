#!/usr/bin/env python3
# Corpus of fragments for pardump/pardump1 (see parcompare.sh): one case per line,
# "KIND<TAB>text". Fragments are cut from real ATS source lines (stadef/sortdef/
# typedef/#define right-hand sides, ':' annotations, {..} / (..) groups, ...)
# plus the same fragments fed to the "wrong" parsers, so that the error paths
# are compared too.
#   usage: parcorpus.py MAXPERFILE FILE... > corpus.txt
import re, sys, random

import os
random.seed(int(os.environ.get("SEED", "1")))
maxper = int(sys.argv[1])
files = sys.argv[2:]

def strip_comment(l):
    i = l.find('//')
    if i >= 0: l = l[:i]
    return l.rstrip()

def groups(l, o, c):
    # balanced single-line groups (outermost) with open/close chars
    res = []; depth = 0; start = -1
    for i, ch in enumerate(l):
        if ch == o:
            if depth == 0: start = i
            depth += 1
        elif ch == c and depth > 0:
            depth -= 1
            if depth == 0: res.append(l[start+1:i])
    return res

SEXP = ['s0exp', 'atms0exp']
cases = set()
NLK = ('TOPsta', 'TOPdyn', 'd0ecl_sta', 'd0ecl_dyn', 'd0eclseq_sta', 'd0eclseq_dyn', 'd0exp', 'p0at')
def add(kind, text):
    text = text.replace('\t', ' ').replace('\r', ' ').strip()
    if not text or len(text) > (1500 if kind in NLK else 300): return
    if any(ord(ch) < 32 and ch != '\x01' for ch in text): return
    if '\x01' in text and kind not in NLK: return
    cases.add((kind, text))

def fragments(l, out):
    m = re.match(r'\s*(?:#define|#\w*define)\s+(\S+?)(\([^)]*\))?\s+(.*)$', l)
    if m:
        out.append(('e0xp', m.group(3))); out.append(('e0xpseq', m.group(3)))
    m = re.match(r'\s*#(?:if|elif|ifdef|ifndef)\b(.*)$', l)
    if m: out.append(('e0xp', m.group(1)))
    m = re.match(r'\s*(?:stadef|typedef|vtypedef|viewdef|propdef|viewtypedef|abstype|absprop|absview|absvtype|abst0ype|absvt0ype|abstflat)\b.*?=\s*(.*)$', l)
    if m:
        out.append(('s0exp', m.group(1)))
        out.append(('s0rtext', m.group(1)))
    m = re.match(r'\s*sortdef\s+\S+\s*=\s*(.*)$', l)
    if m:
        out += [('s0rtext', m.group(1)), ('s0rt', m.group(1))]
    m = re.match(r'\s*(?:datasort|datatype|dataprop|dataview|datavtype|dataviewtype)\b.*?=\s*(.*)$', l)
    if m: out += [('d0atsrtconseq', m.group(1)), ('s0exp', m.group(1))]
    m = re.match(r'\s*\|\s*(\w+)\s+of\s+(.*)$', l)
    if m: out += [('d0atsrtconseq', l.strip()), ('s0rt', m.group(2)), ('ofs0rtopt', 'of ' + m.group(2))]
    m = re.match(r'\s*withtype\s+(.*)$', l)
    if m: out += [('witht0ype', l.strip()), ('s0exp', m.group(1))]
    # annotations
    for m in re.finditer(r':\s*([^,)=;{}\[\]]+)', l):
        t = m.group(1).strip()
        out += [('s0exp', t), ('s0rt', t), ('colons0rtopt', ': ' + t)]
    for m in re.finditer(r':\s*(<[^>]*>)', l):
        out += [('colonwith', ':' + m.group(1)), ('e0fftaglst', m.group(1).strip('<>'))]
    for m in re.finditer(r':<([^>]*)>', l):
        out += [('colonwith', ':<' + m.group(1) + '>'), ('e0fftaglst', m.group(1))]
    for g in groups(l, '{', '}'):
        out += [('s0quaseq', g), ('s0exp', '{' + g + '}'), ('q0margseq', '{' + g + '}'),
                ('labs0exp', g), ('s0rtext', '{' + g + '}'), ('s0qua', g), ('s0exparg', g)]
        for part in re.split(r'[|;]', g):
            out += [('s0qua', part), ('s0rtext', part)]
        if ':' in g:
            a, b = g.split(':', 1)
            out += [('s0rt', b.split('|')[0]), ('s0arg', a.split(',')[0] + ':' + b.split('|')[0]), ('s0marg', '(' + g + ')')]
    for g in groups(l, '(', ')'):
        out += [('s0exp', '(' + g + ')'), ('s0exp', g), ('atms0exp', '(' + g + ')'),
                ('e0xpseq', g), ('e0xp', '(' + g + ')'), ('s0marg', '(' + g + ')'),
                ('a0msrt', '(' + g + ')'), ('s0exp', '@(' + g + ')'), ('s0exp', "$tup(" + g + ")"),
                ('s0exparg', g), ('s0vararg', g), ('tmps0expseq', g), ('s0exp', 'lam (' + g + ') => x')]
        parts = [p for p in re.split(r',', g)]
        if parts: out += [('a0srt', parts[0]), ('s0arg', parts[0])]
    for g in groups(l, '[', ']'):
        out += [('s0exp', '[' + g + ']'), ('s0quaseq', g), ('s0exp', '@[' + g + ']')]
    m = re.search(r'=\s*("[^"]*")', l)
    if m: out += [('extnamopt', '= ' + m.group(1)), ('s0tring', m.group(1))]
    out += [('s0exp', l.strip()), ('s0rt', l.strip()), ('e0xp', l.strip())]
    # tokens-level pieces
    for w in re.findall(r'\S+', l)[:6]:
        out += [('i0de', w), ('si0de', w), ('s0rtid', w), ('i0dext', w), ('i0de_dlr', w), ('p0rec', w),
                ('l0ab', w), ('s0taq', w), ('sqi0de', w), ('s0rtq', w), ('i0nt', w), ('s0tring', w),
                ('labs0exp', w + ' = x'), ('datsdef', w), ('datsdef', w + ' = 1')]
    # a suffix and a prefix of the line (error paths)
    words = l.split()
    if len(words) > 2:
        k = random.randrange(1, len(words))
        out += [('s0exp', ' '.join(words[:k])), ('s0exp', ' '.join(words[k:])), ('e0xp', ' '.join(words[k:]))]
        out += [('s0rt', ' '.join(words[k:])), ('s0quaseq', ' '.join(words[:k]))]

for f in files:
    try:
        lines = open(f, errors='replace').read().split('\n')
    except Exception:
        continue
    out = []
    incomment = False
    for l in lines:
        if '(*' in l and '*)' not in l: incomment = True
        if incomment:
            if '*)' in l: incomment = False
            continue
        l = strip_comment(l)
        if not l.strip() or l.lstrip().startswith(('(*', '%{', '/*')): continue
        fragments(l, out)
    random.shuffle(out)
    seen = 0
    for k, t in out:
        if seen >= maxper: break
        before = len(cases); add(k, t); seen += (len(cases) > before)

# random token sequences (differential fuzzing of the error recovery); FUZZ=count
import os
VOC = ['a', 'b', 'n', 'int', 'type', 'prop', 't@ype', 'list', 'x', '$LIST.t', '$LIST.', '1', '0', "'c'", '"s"', '1.5',
       '(', ')', '{', '}', '[', ']', '@(', "'(", '@{', "'{", '$tup(', '$rec{', '$tup_vt(', '$extype', '$extype_struct', 'of',
       ',', '|', ':', ';', '->', '=>', '=', '<', '>', '>=', '+', '-', '*', '!', '~', '@', '\\', '&', '<>', '><', '-<', '-<>', ':<', ':<>', '#[', '@[',
       'lam', 'op', 'if', 'then', 'else', 'as', '..', '...', '.', '%(', '$d2', 'withtype', '<fun1>', 'fun', 'prf', 'wrt']
FZK = ['s0exp', 's0rt', 'e0xp', 's0quaseq', 's0rtext', 's0qua', 'q0margseq', 'labs0exp', 'e0xpseq', 'atms0exp', 's0marg',
       'a0msrt', 's0vararg', 's0exparg', 'd0atsrtconseq', 'colonwith', 'e0fftaglst', 'p0rec', 'tmps0expseq', 'witht0ype']
for _ in range(int(os.environ.get('FUZZ', '0'))):
    n = random.randint(1, 14)
    t = ' '.join(random.choice(VOC) for _ in range(n))
    if random.random() < 0.3: t = t.replace(' ', '')
    k = random.choice(FZK)
    if 'd2' in t: continue
    cases.add((k, t))

# grammar-directed random fragments (mostly valid, a few mutated); GFUZZ=count
def g_atom():
    return random.choice(['a', 'b', 'int', 'list', 'x', 'n', '1', '0', "'c'", '"s"', '2.5', '$LIST.t', '$A.b', '+', '->', '>=', '!', '@', '~', '<', '>', '\\\\', 'op +', 'op list'])
def g_sort(d=0):
    r = random.random()
    if d > 2 or r < 0.5: return random.choice(['int', 'bool', 'type', 'prop', 't@ype', 'view', 'vtype', '$S.t', 'addr', 'a'])
    if r < 0.7: return g_sort(d+1) + ' ' + g_sort(d+1)
    if r < 0.85: return g_sort(d+1) + ' -> ' + g_sort(d+1)
    return '(' + ', '.join(g_sort(d+1) for _ in range(random.randint(0, 3))) + ')'
def g_args(d):
    return ', '.join(g_sexp(d+1) for _ in range(random.randint(0, 3)))
def g_qua(d):
    r = random.random()
    ids = ', '.join(random.choice(['a', 'b', 'n', 'm', 'l']) for _ in range(random.randint(1, 3)))
    if r < 0.6: return ids + ': ' + g_sort()
    if r < 0.7: return ids + ': {' + random.choice(['a', 'b']) + ': int | ' + g_sexp(d+1) + '}'
    return g_sexp(d+1)
def g_quas(d):
    return random.choice(['', ';', ' | ']).join(g_qua(d) for _ in range(random.randint(1, 3)))
def g_sexp(d=0):
    r = random.random()
    if d > 3 or r < 0.3: return g_atom()
    if r < 0.45: return g_sexp(d+1) + ' ' + g_sexp(d+1)
    if r < 0.55: return '(' + g_args(d) + ')'
    if r < 0.60: return '(' + g_args(d) + ' | ' + g_args(d) + ')'
    if r < 0.65: return random.choice(['@(', "'(", '$tup(', '$tup_vt(']) + g_args(d) + ')'
    if r < 0.70: return random.choice(['@{', "'{", '$rec{', '$rec_vt{']) + ', '.join(random.choice(['x', 'y', '1']) + ' = ' + g_sexp(d+1) for _ in range(random.randint(1, 3))) + '}'
    if r < 0.75: return '{' + g_quas(d) + '} ' + g_sexp(d+1)
    if r < 0.80: return '[' + g_quas(d) + '] ' + g_sexp(d+1)
    if r < 0.84: return 'lam (' + ', '.join(random.choice(['a', 'a: int', 'b: type']) for _ in range(random.randint(1, 2))) + ') => ' + g_sexp(d+1)
    if r < 0.88: return g_sexp(d+1) + ' : ' + g_sort(1)
    if r < 0.91: return '@[' + g_sexp(d+1) + '][' + g_args(d) + ']'
    if r < 0.94: return random.choice(['-<fun1>', '-<>', '-<lin,prf>', '-<!wrt>', '-<cloptr1>']) + ' ' + g_sexp(d+1)
    if r < 0.97: return '$extype "foo" ' + g_sexp(d+1)
    return g_atom() + ' ' + g_sexp(d+1)
def g_e0xp(d=0):
    r = random.random()
    if d > 3 or r < 0.4: return random.choice(['a', 'b', '1', "'c'", '"s"', '2.5', '+', '*'])
    if r < 0.6: return g_e0xp(d+1) + ' ' + g_e0xp(d+1)
    if r < 0.75: return '(' + ', '.join(g_e0xp(d+1) for _ in range(random.randint(0, 3))) + ')'
    if r < 0.85: return '%(' + g_e0xp(d+1) + ')'
    return 'if ' + g_e0xp(d+1) + ' then ' + g_e0xp(d+1) + random.choice(['', ' else ' + g_e0xp(d+1)])
def mutate(t):
    if random.random() < 0.7: return t
    w = t.split(' ')
    i = random.randrange(len(w))
    op = random.random()
    if op < 0.4: del w[i]
    elif op < 0.7: w.insert(i, random.choice(VOC))
    else: w[i] = random.choice(VOC)
    return ' '.join(w)
for _ in range(int(os.environ.get('GFUZZ', '0'))):
    r = random.random()
    if r < 0.35: cases.add(('s0exp', mutate(g_sexp())))
    elif r < 0.45: cases.add(('s0quaseq', mutate(g_quas(0))))
    elif r < 0.55: cases.add(('s0rt', mutate(g_sort())))
    elif r < 0.65: cases.add(('s0rtext', mutate(random.choice(['{a: int | a > 0}', '{a: int | ' + g_sexp(1) + '; ' + g_sexp(1) + '}', g_sort()])) ))
    elif r < 0.75: cases.add(('e0xp', mutate(g_e0xp())))
    elif r < 0.80: cases.add(('e0xpseq', mutate(', '.join(g_e0xp(1) for _ in range(3)))))
    elif r < 0.85: cases.add(('q0margseq', mutate(' '.join('{' + g_quas(1) + '}' for _ in range(random.randint(1, 3))))))
    elif r < 0.90: cases.add(('labs0exp', mutate(random.choice(['x', '1']) + random.choice(['', ' as "y"']) + ' = ' + g_sexp(1))))
    elif r < 0.93: cases.add(('s0marg', mutate('(' + ', '.join(random.choice(['a', 'a: int', 'b: type -> type']) for _ in range(random.randint(0, 3))) + ')')))
    elif r < 0.96: cases.add(('a0msrt', mutate('(' + ', '.join(random.choice(['a', 'a: int', 'b: type -> type', 'int']) for _ in range(random.randint(0, 3))) + ')')))
    elif r < 0.98: cases.add(('d0atsrtconseq', mutate(' | '.join(random.choice(['A', 'B of int', 'C of (int, bool)']) for _ in range(random.randint(1, 3))))))
    else: cases.add(('s0exparg', mutate(g_args(0))))


# ------------------------------------------------------------------ phase 2: p0at, d0exp, d0ecl
def blank_comments(t):
    # blank out comments/strings-safe: (* *) nested, // and /* */; keeps the newlines
    o = []; i = 0; n = len(t); depth = 0
    while i < n:
        c = t[i]
        if depth == 0 and c == '"':
            j = i + 1
            while j < n and t[j] != '"' and t[j] != '\n':
                if t[j] == '\\': j += 1
                j += 1
            o.append(t[i:j+1]); i = j + 1; continue
        if t.startswith('(*', i) and not t.startswith('(*)', i):
            depth += 1; o.append('  '); i += 2; continue
        if depth and t.startswith('*)', i):
            depth -= 1; o.append('  '); i += 2; continue
        if depth:
            o.append('\n' if c == '\n' else ' '); i += 1; continue
        if t.startswith('//', i):
            while i < n and t[i] != '\n': o.append(' '); i += 1
            continue
        if t.startswith('/*', i):
            j = t.find('*/', i)
            j = n if j < 0 else j + 2
            o.append(''.join('\n' if ch == '\n' else ' ' for ch in t[i:j])); i = j; continue
        o.append(c); i += 1
    return ''.join(o)

def statements(t):
    # blank comments, drop %{ .. %} blocks, split at blank lines
    t = blank_comments(t)
    t = re.sub(r'%\{[\^\$#]?.*?%\}', lambda m: re.sub(r'[^\n]', ' ', m.group(0)), t, flags=re.S)
    out = []; cur = []
    for l in t.split('\n'):
        if not l.strip():
            if cur: out.append(cur); cur = []
        else: cur.append(l)
    if cur: out.append(cur)
    return out

def dfragments(l, out):
    s = l.strip()
    out += [('d0exp', s), ('p0at', s), ('d0ecl_dyn', s), ('d0ecl_sta', s), ('c0lauseq', s), ('d0expsemiseq', s)]
    m = re.match(r'\s*(?:val|var|prval|prvar)\b\s*(?:\w+\s*)?(.*?)\s*=\s*(.*)$', l)
    if m: out += [('p0at', m.group(1)), ('d0exp', m.group(2)), ('eqd0expopt', '= ' + m.group(2))]
    m = re.match(r'\s*\|?\s*(.*?)\s*=>\s*(.*)$', l)
    if m: out += [('p0at', m.group(1)), ('d0exp', m.group(2)), ('c0lauseq', '| ' + l.strip().lstrip('|'))]
    m = re.match(r'\s*(?:fun|fn|fnx|prfun|prfn|praxi|castfn)\b\s*(.*?)\s*=\s*(.*)$', l)
    if m: out += [('d0exp', m.group(2))]
    m = re.match(r'\s*(?:implement|primplement|implmnt)\b(.*?)=\s*(.*)$', l)
    if m: out += [('d0exp', m.group(2)), ('tmpqi0de', m.group(1).strip()), ('dqi0de', m.group(1).strip().split(' ')[0])]
    m = re.match(r'\s*(?:datatype|dataviewtype|datavtype|dataprop|dataview)\b.*?=\s*(.*)$', l)
    if m: out += [('d0atconseq', m.group(1)), ('d0atdecseq', l.strip())]
    m = re.match(r'\s*\|\s*(\w+)\b', l)
    if m: out += [('d0atconseq', l.strip()), ('e0xndec', l.strip().lstrip('|')), ('e0xndecseq', l.strip().lstrip('|'))]
    m = re.match(r'\s*exception\s+(.*)$', l)
    if m: out += [('e0xndecseq', m.group(1)), ('e0xndec', m.group(1))]
    m = re.match(r'\s*(?:fun|fn|val|praxi|prfun|castfn|prval)\s+(.*)$', l)
    if m: out += [('d0cstdecseq', m.group(1))]
    m = re.match(r'\s*(?:macdef|macrodef)\s+(.*)$', l)
    if m: out += [('m0acdef', m.group(1))]
    m = re.match(r'\s*datasort\b.*?=\s*(.*)$', l)
    if m: out += [('d0atsrtdecseq', l.strip()), ('d0atsrtdecseq', m.group(1))]
    m = re.match(r'\s*sortdef\s+(.*)$', l)
    if m: out += [('s0rtdefseq', m.group(1))]
    m = re.match(r'\s*stacst\s+(.*)$', l)
    if m: out += [('s0tacstseq', m.group(1))]
    m = re.match(r'\s*(?:stadef|typedef|vtypedef|propdef|viewdef)\s+(.*)$', l)
    if m: out += [('s0expdefseq', m.group(1))]
    m = re.match(r'\s*(?:absvtype|abstype|absprop|absview|abst0ype|absvt0ype)\s+(.*)$', l)
    if m: out += [('s0taconseq', m.group(1))]
    for g in groups(l, '(', ')'):
        out += [('d0exp', '(' + g + ')'), ('p0at', '(' + g + ')'), ('d0exp', g), ('p0at', g), ('f0arg1', '(' + g + ')'),
                ('f0arg2', '(' + g + ')'), ('d0exp', '@(' + g + ')'), ('p0at', '@(' + g + ')'), ("d0exp", "$tup(" + g + ")"),
                ('d0cstarg', '(' + g + ')'), ('a0typ', g.split(',')[0]), ('d0expsemiseq', g), ('d0expsemiseq', g.replace(',', ';')),
                ('d0exp', 'foo(' + g + ')'), ('d0exp', 'foo<int>(' + g + ')'), ('p0at', 'Foo(' + g + ')'), ('d0exp', '$d2ctype(' + g + ')'),
                ('S0Ed2ctype', g), ('d0exp', 'if ' + g + ' then 1 else 2'), ('d0exp', 'case+ ' + g + ' of | x => y')]
    for g in groups(l, '{', '}'):
        out += [('d0exp', '{' + g + '}'), ('f0arg1', '{' + g + '}'), ('f0arg2', '{' + g + '}'), ('p0at', '{' + g + '}'), ('d0exp', 'foo{' + g + '}'),
                ('d0cstarg', '{' + g + '}'), ('d0exp', '@{' + g + '}'), ('labd0exp', g), ('labp0at', g), ('d0exp', 'let ' + g + ' in x end'), ('d0exp', 'x where {' + g + '}')]
    for g in groups(l, '[', ']'):
        out += [('d0exp', '[' + g + ']'), ('p0at', '[' + g + ']'), ('d0exp', 'a[' + g + ']'), ('d0exp', '@[int][' + g + '](x)'), ('d0exp', '$arrpsz{int}(' + g + ')')]
    for w in re.findall(r'\S+', l)[:6]:
        out += [('di0de', w), ('pi0de', w), ('dqi0de', w), ('tmpqi0de', w), ('arrqi0de', w), ('d0ynq', w), ('labd0exp', w + ' = x'),
                ('labp0at', w + ' = x'), ('d0exp', w), ('p0at', w), ('d0exp', w + ' x'), ('p0at', w + ' x'), ('S0Ed2ctype', w), ('d0exp', w + '<int>(x)'),
                ('d0exp', w + '.x'), ('d0exp', w + '[1]'), ('d0exp', '!' + w), ('d0exp', w + '->x')]
    words = l.split()
    if len(words) > 2:
        k = random.randrange(1, len(words))
        out += [('d0exp', ' '.join(words[:k])), ('d0exp', ' '.join(words[k:])), ('p0at', ' '.join(words[k:])), ('d0ecl_dyn', ' '.join(words[k:])), ('d0ecl_sta', ' '.join(words[:k]))]

def stmt_fragments(st, out):
    t = '\x01'.join(l.rstrip() for l in st)
    if len(t) <= 1500:
        out += [('d0ecl_dyn', t), ('d0ecl_sta', t), ('TOPdyn', t), ('TOPsta', t), ('d0eclseq_dyn', t), ('d0eclseq_sta', t), ('d0exp', t)]
        # token mutation (error recovery)
        toks = re.findall(r'"(?:[^"\\]|\\.)*"|[A-Za-z_$#%\'][\w\'$]*|\d+|\S', t.replace('\x01', ' \x01 '))
        toks = [x for x in toks]
        for _ in range(2):
            if len(toks) < 3: break
            w = list(toks); i = random.randrange(len(w)); r = random.random()
            if r < 0.35: del w[i]
            elif r < 0.6: w.insert(i, random.choice(DVOC))
            elif r < 0.8: w[i] = random.choice(DVOC)
            else:
                j = random.randrange(len(w)); w[i], w[j] = w[j], w[i]
            m = ' '.join(w).replace(' \x01 ', '\x01').replace('\x01 ', '\x01').replace(' \x01', '\x01')
            out += [(random.choice(['TOPdyn', 'TOPsta', 'd0ecl_dyn', 'd0ecl_sta', 'd0eclseq_dyn']), m)]

DKINDS = ['d0exp', 'd0exp', 'd0exp', 'p0at', 'p0at', 'labp0at', 'labd0exp', 'f0arg1', 'f0arg2', 'd0ecl_dyn', 'd0ecl_sta', 'd0eclseq_dyn', 'd0eclseq_sta', 'c0lauseq', 'sc0lauseq', 'i0fclseq', 'd0expsemiseq', 'eqd0expopt', 'S0Ed2ctype', 'a0typ', 'd0cstarg', 'e0xndec', 'e0xndecseq', 'd0atconseq', 'd0atdecseq', 'd0cstdecseq', 'm0acdef', 's0expdefseq', 's0aspdec', 's0taconseq', 's0tacstseq', 's0rtdefseq', 'd0atsrtdecseq', 'dqi0de', 'tmpqi0de', 'arrqi0de', 'd0ynq', 'di0de', 'pi0de', 'TOPdyn', 'TOPsta', 'q0marg']
DVOC = ['a', 'b', 'x', 'f', 'xs', 'n', '1', '0', '2.5', "'c'", '"s"', '$LIST.t', '$LIST.', 'int', 'type', '(', ')', '{', '}', '[', ']', '@(', "'(", '@{', "'{",
  '$tup(', '$rec{', '$lst(', '$arrpsz', '$extval', '$extfcall', '$extmcall', ',', ';', '|', ':', '=', '=>', '=<', '=<>', '->', '<', '>', '<>', '!', '~', '@', '&', '.', '..', '...', '#',
  'if', 'then', 'else', 'let', 'in', 'end', 'begin', 'case', 'case+', 'case-', 'of', 'when', 'as', 'where', 'val', 'var', 'fun', 'fn', 'fnx', 'prfun', 'implement', 'lam', 'llam', 'fix', 'with', 'try',
  'while', 'for', 'op', 'rec', 'and', 'local', 'datatype', 'abstype', 'typedef', 'staload', 'dynload', '#include', '#define', '$delay', '$ldelay', '$raise', '$effmask_all', '$showtype',
  'ifcase', 'sif', 'scase', '.<', '>.', '.<>.', '#[', '$d2ctype', 'extern', 'static', 'sortdef', 'stadef', 'macdef', 'symintr', 'infixl', 'overload', 'exception', 'assume', 'withtype', '<!wrt>', ':<>', ':<cloref1>', '%(', '`(', ',(', '$myfilename', '$mylocation', '$myfunction', '$break', '$continue', '$vcopyenv_v', '$tempenver', '$solver_assert']

# grammar-directed random dynamic code (mostly valid, mutated afterwards); DGFUZZ=count
def r_id(): return random.choice(['a', 'b', 'x', 'y', 'f', 'g', 'xs', 'n', 'foo', 'Bar', '$LIST.f', '$A.B.c', '+', '-', '*', '<', '>', '>=', '!', '~'])
def r_lit(): return random.choice(['0', '1', '42', "'c'", '"s"', '2.5', '0x1F', '1u', '1L', "'\\n'"])
def g_pat(d=0):
    r = random.random()
    if d > 3 or r < 0.3: return random.choice(['x', 'y', '_', 'xs', 'Foo', '1', "'c'", '"s"', '$A.Foo', 'op +', 'nil', 'None()'])
    if r < 0.45: return g_pat(d+1) + ' ' + g_pat(d+1)
    if r < 0.55: return random.choice(['Foo', 'cons', 'Some']) + '(' + ', '.join(g_pat(d+1) for _ in range(random.randint(0, 3))) + ')'
    if r < 0.62: return '(' + ', '.join(g_pat(d+1) for _ in range(random.randint(0, 3))) + ')'
    if r < 0.66: return '(' + g_pat(d+1) + ' | ' + g_pat(d+1) + ')'
    if r < 0.70: return random.choice(['@(', "'(", '$tup(', '$tup_vt(']) + ', '.join(g_pat(d+1) for _ in range(random.randint(1, 3))) + ')'
    if r < 0.74: return random.choice(['@{', "'{", '$rec{', '$rec_vt{']) + ', '.join(random.choice(['x', 'y']) + ' = ' + g_pat(d+1) for _ in range(random.randint(1, 3))) + '}'
    if r < 0.77: return '$lst(' + ', '.join(g_pat(d+1) for _ in range(random.randint(0, 3))) + ')'
    if r < 0.80: return '~' + g_pat(d+1)
    if r < 0.83: return '@' + g_pat(d+1)
    if r < 0.87: return g_pat(d+1) + ' as ' + g_pat(d+1)
    if r < 0.92: return g_pat(d+1) + ' : ' + g_sexp(1)
    if r < 0.95: return random.choice(['Foo{n}', 'Foo{n:int}', 'Foo{n}{m}']) + '(' + g_pat(d+1) + ')'
    if r < 0.97: return '[' + random.choice(['n', 'n:int', 'n,m']) + ']' + g_pat(d+1)
    return '(' + g_pat(d+1) + ')'
def g_decl_dyn(d=0):
    r = random.random()
    body = lambda: g_dexp(d+1)
    if r < 0.18: return random.choice(['val ', 'val+ ', 'val- ', 'prval ']) + g_pat(1) + random.choice(['', ' : ' + g_sexp(1)]) + ' = ' + body()
    if r < 0.24: return 'var ' + random.choice(['x', 'x: int', 'x with pf', 'x: int with pf']) + random.choice(['', ' = ' + body()])
    if r < 0.40: return random.choice(['fun ', 'fn ', 'fnx ', 'prfun ', 'fun{a:t@ype} ', 'fun {a:t@ype} ']) + random.choice(['f', 'foo', '+']) + ' (' + ', '.join(random.choice(['x', 'x: int', 'x: !int', '{n:int}', 'x: int n']) for _ in range(random.randint(0, 3))) + ')' + random.choice(['', ': int', ':<> int', ':<cloref1> bool']) + ' = ' + body() + random.choice(['', ' and g (y) = 1', ' withtype int -> int'])
    if r < 0.50: return random.choice(['implement ', 'implement{a} ', 'implement {a} ', 'primplement ']) + random.choice(['f', 'foo<int>', '$A.f', 'f<a,b>']) + ' (' + g_pat(1) + ')' + random.choice(['', ': int']) + ' = ' + body()
    if r < 0.56: return 'datatype ' + random.choice(['t', 't(a:type)', 't (a:t@ype) (n:int)']) + ' = ' + ' | '.join(random.choice(['A', 'B of int', 'C of (int, a)', 'D of (int | a)', '{n:nat} E of (int n)', 'F(int)']) for _ in range(random.randint(1, 3)))
    if r < 0.60: return random.choice(['staload ', 'staload X = ', 'dynload ', '#include ', '#staload ']) + random.choice(['"foo.sats"', '"./bar.dats"', '$X', '{$x}']) 
    if r < 0.64: return random.choice(['local ', 'local\x01']) + g_decl_dyn(d+1) + ' in ' + g_decl_dyn(d+1) + ' end'
    if r < 0.68: return random.choice(['typedef t = int', 'stadef n = 1', 'sortdef s = int', 'abstype t', 'abstype t = ptr', 'extern fun f: int -> int', 'extern val x: int = "mac#x"', 'exception E of int', 'assume t = int', 'infixl 50 +', 'nonfix f', 'symintr f', 'overload + with f', 'overload f with g of 10', '#define N 10', '#if N > 1 then', '#endif', '#else', '#print "x"', '#error "x"', '#assert 1', '%{^ x %}', '%{$ x %}', 'macdef f (x) = ,(x)', 'extern praxi f: int', 'dataprop p = P', 'dataview v = V', 'datavtype vt = VT', 'datasort s = S | T of int', 'stacst c: int', 'abst@ype t', 'absvtype vt', 'withtype t', 'static val x = 1', 'extern castfn f: int -> int', 'prfn f (x: int): int = x', 'implmnt f() = 1', 'reassume t', 'classdec c', 'extype "x" = int', 'extvar "x" = 1', '$extype "x"', 'pragma', 'codegen'])
    if r < 0.72: return random.choice(['val ', 'var ']) + g_pat(1) + ' = ' + body() + ' ' + random.choice(['where {', 'withtype ']) + g_pat(1)
    if r < 0.80: return g_dexp(d+1)
    return random.choice(['val x = 1', 'fun f(): int = 1', 'val () = ()', 'implement main0 () = ()', 'var x: int = 0', 'staload "a.sats"', 'typedef t = int'])
def g_dexp(d=0):
    r = random.random()
    if d > 3 or r < 0.25: return random.choice([r_id(), r_lit(), '()', 'x', 'y', 'f', 'xs', '$MYFILENAME', '$mylocation'.upper() if False else '$myfilename', '$mylocation', '$myfunction', 'nil()', 'None()', '$break', '$continue', '?', '$vararg'])
    if r < 0.40: return g_dexp(d+1) + ' ' + g_dexp(d+1)
    if r < 0.46: return r_id() + '(' + ', '.join(g_dexp(d+1) for _ in range(random.randint(0, 3))) + ')'
    if r < 0.50: return '(' + ', '.join(g_dexp(d+1) for _ in range(random.randint(0, 3))) + ')'
    if r < 0.53: return '(' + g_dexp(d+1) + ' | ' + g_dexp(d+1) + ')'
    if r < 0.56: return random.choice(['@(', "'(", '$tup(', '$tup_vt(']) + ', '.join(g_dexp(d+1) for _ in range(random.randint(1, 3))) + ')'
    if r < 0.59: return random.choice(['@{', "'{", '$rec{', '$rec_vt{']) + ', '.join(random.choice(['x', 'y']) + ' = ' + g_dexp(d+1) for _ in range(random.randint(1, 3))) + '}'
    if r < 0.62: return 'if ' + g_dexp(d+1) + ' then ' + g_dexp(d+1) + random.choice(['', ' else ' + g_dexp(d+1)])
    if r < 0.64: return random.choice(['ifcase', 'ifcase\x01']) + ' | ' + g_dexp(d+1) + ' => ' + g_dexp(d+1) + random.choice(['', ' | _ => ' + g_dexp(d+1)])
    if r < 0.66: return 'sif ' + g_sexp(1) + ' then ' + g_dexp(d+1) + ' else ' + g_dexp(d+1)
    if r < 0.71: return random.choice(['case ', 'case+ ', 'case- ']) + g_dexp(d+1) + ' of ' + ' | '.join(g_pat(1) + random.choice([' => ', ' => ', ' =>> ', ' =/=> ']) + g_dexp(d+1) for _ in range(random.randint(1, 3)))
    if r < 0.72: return random.choice(['scase ', 'scase+ ']) + g_sexp(1) + ' of ' + ' | '.join(random.choice(['Foo(x)', 'Bar()']) + ' => ' + g_dexp(d+1) for _ in range(random.randint(1, 2)))
    if r < 0.75: return 'let ' + ' '.join(g_decl_dyn(d+1) for _ in range(random.randint(0, 3))) + ' in ' + g_dexp(d+1) + random.choice([' end', ' end', ''])
    if r < 0.77: return 'begin ' + g_dexp(d+1) + random.choice(['; ' + g_dexp(d+1), '']) + random.choice([' end', ' end', ''])
    if r < 0.79: return '(' + g_dexp(d+1) + '; ' + g_dexp(d+1) + ')'
    if r < 0.81: return g_dexp(d+1) + ' where { ' + g_decl_dyn(d+1) + ' }'
    if r < 0.84: return random.choice(['lam ', 'llam ', 'lam@ ', 'fix f ', 'fix@ f ']) + '(' + ', '.join(random.choice(['x', 'x: int', 'pf | x']) for _ in range(random.randint(0, 2))) + ')' + random.choice(['', ': int', ' : int', ':<cloref1> int']) + ' => ' + g_dexp(d+1)
    if r < 0.86: return random.choice(['while ', 'while* ']) + g_dexp(d+1) + ' ' + g_dexp(d+1) if False else 'while ' + g_dexp(d+1) + ' ' + g_dexp(d+1)
    if r < 0.88: return 'for ' + g_dexp(d+1) + '; ' + g_dexp(d+1) + '; ' + g_dexp(d+1) + ' ' + g_dexp(d+1)
    if r < 0.90: return 'try ' + g_dexp(d+1) + ' with ' + ' | '.join(g_pat(1) + ' => ' + g_dexp(d+1) for _ in range(random.randint(1, 2)))
    if r < 0.92: return g_dexp(d+1) + random.choice(['.x', '.1', '[1]', '[i, j]', '->x', '.<>.']) 
    if r < 0.94: return random.choice(['!', '~', '&', '@', '$raise ', '$delay ', '$ldelay ', '$effmask_all ', '$effmask_wrt ', '$showtype ', '%', 'fold@ ', 'free@ ', '$vcopyenv_v ', '$vcopyenv_vt ', '$solver_verify ']) + g_dexp(d+1)
    if r < 0.95: return random.choice(['$extval(int, "x")', '$extfcall(int, "f", x, y)', '$extmcall(int, x, "m", y)', '$d2ctype(f)', '$d2ctype(f<int>)', '$arrpsz{int}(1, 2, 3)', '$arrpsz(1,2)', '$lst(1, 2)', '$lst_vt(1, 2)', '$list(1,2)', '$tyrep(int)', '$literal(1)', '$effmask(wrt, x)', '$effmask_ntm(x)', 'x: int', '(x: int)', '@[int][3](1, 2, 3)', '@[int][n]()', '@[int](1)', "'[1,2]", "'(1)", '[1,2]', '{x}', '{n:int}', '<int>', 'f<int>', 'f<int, bool>(x)', 'f{int}(x)', 'f{n}{m}(x)', 'f<>(x)', '#[n] x', '.<n>. x', '`(x)', ',(x)', '%(x)', '%(1 + 2)', 'x.y.z', 'x.1.2', 'op +', 'op f', '$f', '$f(x)', 'xs.[i]', '$vararg'])
    return g_dexp(d+1) + ' ' + random.choice(['+', '-', '*', '/', '<', '>', '=', '==', '<=', '>=', '!=', '&&', '||', ':=', '+=']) + ' ' + g_dexp(d+1)

def mutate_d(t):
    if random.random() < 0.5: return t
    w = t.split(' ')
    for _ in range(random.randint(1, 2)):
        if not w: break
        i = random.randrange(len(w)); op = random.random()
        if op < 0.4: del w[i]
        elif op < 0.7: w.insert(i, random.choice(DVOC))
        else: w[i] = random.choice(DVOC)
    return ' '.join(w)

for f in files:
    try:
        text = open(f, errors='replace').read()
    except Exception:
        continue
    out = []
    code = blank_comments(text)
    for l in code.split('\n'):
        if not l.strip() or l.lstrip().startswith(('%{', '#')) and False: continue
        if not l.strip(): continue
        dfragments(l, out)
    sts = statements(text)
    random.shuffle(sts)
    sout = []
    for st in sts[:60]:
        stmt_fragments(st, sout)
    random.shuffle(out); random.shuffle(sout)
    seen = 0
    for k, t in out:
        if seen >= maxper: break
        before = len(cases); add(k, t); seen += (len(cases) > before)
    seen = 0
    for k, t in sout:
        if seen >= maxper: break
        before = len(cases); add(k, t); seen += (len(cases) > before)

for _ in range(int(os.environ.get('DFUZZ', '0'))):
    n = random.randint(1, 14)
    t = ' '.join(random.choice(DVOC) for _ in range(n))
    if random.random() < 0.3: t = t.replace(' ', '')
    k = random.choice(DKINDS)
    cases.add((k, t))

for _ in range(int(os.environ.get('DGFUZZ', '0'))):
    r = random.random()
    mut = lambda t: mutate_d(t)
    if r < 0.40: cases.add((random.choice(['d0exp', 'd0exp', 'S0Ed2ctype', 'd0expsemiseq', 'eqd0expopt', 'c0lauseq', 'i0fclseq']), mut(g_dexp())))
    elif r < 0.55: cases.add((random.choice(['p0at', 'p0at', 'labp0at', 'f0arg1', 'f0arg2']), mut(g_pat())))
    elif r < 0.85: cases.add((random.choice(['d0ecl_dyn', 'd0ecl_dyn', 'd0ecl_sta', 'd0eclseq_dyn', 'TOPdyn', 'TOPsta', 'd0ecl']), mut(g_decl_dyn())))
    else:
        cases.add((random.choice(['TOPdyn', 'd0eclseq_dyn']), mut('\x01'.join(g_decl_dyn() for _ in range(random.randint(1, 4))))))

# whole-file mutations (error recovery of the toplevel); FMUT=count
FMUT = int(os.environ.get('FMUT', '0'))
if FMUT:
    pool = [f for f in files if os.path.getsize(f) < 12000 and f.endswith(('.dats', '.sats', '.hats'))]
    for _ in range(FMUT):
        f = random.choice(pool)
        try:
            t = open(f, errors='replace').read()
        except Exception:
            continue
        t = t.encode('ascii', 'replace').decode('ascii')
        ls = t.split('\n')
        for _ in range(random.randint(1, 3)):
            if not ls: break
            r = random.random(); i = random.randrange(len(ls))
            if r < 0.3: del ls[i]
            elif r < 0.5: ls[i] = ' '.join(ls[i].split(' ')[:random.randint(0, 6)])
            elif r < 0.7:
                ws = ls[i].split(' ')
                if ws: ws[random.randrange(len(ws))] = random.choice(DVOC)
                ls[i] = ' '.join(ws)
            elif r < 0.85: ls.insert(i, random.choice(DVOC) + ' ' + random.choice(DVOC))
            else:
                j = random.randrange(len(ls)); ls[i], ls[j] = ls[j], ls[i]
        t = '\x01'.join(l.replace('\t', ' ').replace('\r', ' ') for l in ls)
        if any(ord(ch) < 32 and ch != '\x01' for ch in t): continue
        cases.add(('TOPsta' if f.endswith('.sats') else 'TOPdyn', t))

# hand-written error cases and corner cases
HAND = open(__file__.replace('parcorpus.py', 'parcorpus.hand')).read().split('\n') if True else []
for l in HAND:
    if '\t' in l and not l.startswith('#'):
        k, t = l.split('\t', 1); cases.add((k, t))

for k, t in sorted(cases):
    print('%s\t%s' % (k, t))
