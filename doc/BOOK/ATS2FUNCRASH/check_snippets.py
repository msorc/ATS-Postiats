#!/usr/bin/env python3
# Checks that every code fragment of a chapter (#dats2xhtml, #sats2xhtml,
# #atscode blocks) occurs, modulo white space, in a file of CODE/ (which
# the regression tests build): prose and code cannot drift apart.
# usage: check_snippets.py CHAP_X/main.atxt [CODE-file ...]
import re, sys, glob
def norm(s):
    s = re.sub(r'\(\*.*?\*\)', '', s, flags=re.S)
    s = re.sub(r'//[^\n]*', '', s)
    return re.sub(r'\s+', '', s)
chap = sys.argv[1]
text = open(chap).read()
files = sys.argv[2:] or glob.glob('CODE/*.dats') + glob.glob('CODE/*/*.dats') + glob.glob('CODE/*.sats') + glob.glob('CODE/*/*.sats')
code = norm(''.join(open(f).read() + '\n' for f in files))
import os
home = os.environ.get('PATSHOME', '../../..')
libs = glob.glob(home + '/prelude/*.sats') + glob.glob(home + '/prelude/SATS/*.sats') + glob.glob(home + '/libats/SATS/*.sats') + glob.glob(home + '/libats/*/SATS/*.sats') + glob.glob(home + '/libats/SATS/SHARE/*.hats')
lib = norm(''.join(open(f, errors='replace').read() + '\n' for f in libs))
bad = 0
for m in re.finditer(r"#(?:dats|sats|hats)2xhtml\((['\"])\\?\n?((?:\\.|(?!\1).)*)\1\)", text, re.S):
    frag = re.sub(r'\\(.)', lambda k: k.group(1), m.group(2)).replace('&lt;', '<').replace('&gt;', '>').replace('&amp;', '&')
    parts = [x for x in re.split(r'\n[ \t]*(?://)?[ \t]*\n', frag) if norm(x)]
    ok = True
    for part in parts:
        n = norm(part)
        if n in code or ('extern' + n) in code: continue
        if m.group(0).startswith('#sats') and n in lib: continue
        ok = False
    if ok: continue
    bad += 1
    line = text[:m.start()].count('\n') + 1
    print('%s:%d: fragment not in CODE: %s' % (chap, line, frag.strip().split('\n')[0]))
sys.exit(1 if bad else 0)
