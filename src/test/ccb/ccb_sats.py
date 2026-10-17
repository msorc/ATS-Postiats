# parse the function declarations of pats_ccomp.sats: name -> (params [(name, type)], return type)
import re, sys, os

def strip_comments(t):
    out = []; i = 0; n = len(t); depth = 0
    while i < n:
        if t.startswith('(*', i): depth += 1; i += 2; continue
        if depth and t.startswith('*)', i): depth -= 1; i += 2; continue
        if depth: i += 1; continue
        if t.startswith('//', i):
            while i < n and t[i] != '\n': i += 1
            continue
        out.append(t[i]); i += 1
    return ''.join(out)

def parse(path):
    t = strip_comments(open(path).read())
    res = {}
    for m in re.finditer(r'^(?:fun|and)\s*(?:\{[^}]*\})?\s*(?:\{[^}]*\})?\s*(\w+)\s*', t, re.M):
        name = m.group(1); i = m.end()
        if i >= len(t) or t[i] != '(': continue
        dep = 0; j = i
        while True:
            if t[j] == '(': dep += 1
            elif t[j] == ')':
                dep -= 1
                if dep == 0: break
            j += 1
        params = t[i + 1:j]
        rest = t[j + 1:]
        mm = re.match(r'\s*:\s*(?:<[^>]*>\s*)?', rest)
        if not mm: continue
        rest = rest[mm.end():]
        # the return type: up to the end of the line (or the "= ..." of an external name)
        r = re.split(r'\n\s*\n|\n(?=fun|and|overload|absvtype|abstype|typedef|vtypedef|datatype|staload|\()', rest, 1)[0]
        r = r.split('=')[0].strip() if '= "' in r else r.strip()
        ps = []; dep = 0; cur = ''
        for ch in params:
            if ch in '({[': dep += 1
            if ch in ')}]': dep -= 1
            if ch == ',' and dep == 0: ps.append(cur.strip()); cur = ''; continue
            cur += ch
        if cur.strip(): ps.append(cur.strip())
        pl = []
        for p in ps:
            p = re.sub(r'\s+', ' ', p)
            if ':' in p:
                pn, pt = p.split(':', 1); pl.append((pn.strip(), pt.strip()))
            else: pl.append(('_', p))
        res[name] = (pl, re.sub(r'\s+', ' ', r))
    return res

if __name__ == '__main__':
    d = parse(sys.argv[1])
    print(len(d))
    for n in sys.argv[2:]: print(n, d.get(n))
