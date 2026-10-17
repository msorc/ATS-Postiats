#!/usr/bin/env python3
# usage: python3 com_run.py TABLE REF TEST   (make comtable)
# Runs every command line of TABLE (see com_table.py) with the ATS1 driver REF (comdump1) and the ATS2 driver TEST (comdump) as
# `patsopt ARGS...` and compares stdout, stderr and the exit status. Prints a summary; exit status 1 if there is a difference.
import os, subprocess, sys
table, ref, test = sys.argv[1:4]
# REF = - : only TEST is run, the md5sum of its outputs is printed (comtable.md5 is the md5sum of the output of the ATS1 driver)
import hashlib
md5 = hashlib.md5()
def run(binary, env, args):
    e = dict(os.environ)
    for k in ('USER', 'PATSRELOCROOT', 'ATSRELOCROOT'): e.pop(k, None)
    e['USER'] = 'tester'
    if env != '-':
        for kv in env.split(';'):
            k, v = kv.split('=', 1)
            if v == '': e.pop(k, None)
            else: e[k] = v
    p = subprocess.run(['patsopt'] + args, executable=os.path.abspath(binary), env=e, capture_output=True, timeout=60)
    return p.returncode, p.stdout, p.stderr
n = 0; ndiff = 0; nonzero = 0; nwarn = 0; nabort = 0; nout = 0
for line in open(table, encoding='utf-8').read().split('\n'):
    if not line: continue
    f = line.split('\t')
    env, args = f[0], f[1:]
    if line == '-': args = []
    if ref == '-':
        b = run(test, env, args); md5.update(repr(b).encode()); n += 1
        continue
    a = run(ref, env, args)
    b = run(test, env, args)
    n += 1
    if a[0] != 0: nonzero += 1
    if b'warning(ATS)' in a[2]: nwarn += 1
    if b'EXN' in a[1]: nabort += 1
    nout += a[1].count(b'\n')
    if a != b:
        ndiff += 1
        print('DIFFERENT: %r' % line)
        print('  ref :', a[0], a[1][-300:], a[2][-300:])
        print('  test:', b[0], b[1][-300:], b[2][-300:])
if ref == '-':
    print(md5.hexdigest()); sys.exit(0)
print('comtable: %d command lines, %d with exit status != 0, %d with warnings, %d aborted (EXN), %d output lines: %s' %
      (n, nonzero, nwarn, nabort, nout, 'identical' if ndiff == 0 else '%d DIFFERENT' % ndiff))
sys.exit(1 if ndiff else 0)
