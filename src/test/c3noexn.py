#!/usr/bin/env python3
# usage: python3 c3noexn.py c3dump DATA OUT   writes OUT: the problems of DATA that do not end in an exception (c3dump prints "# N" before the problem N and "EXN .." when the solver aborts):
# an exception leaves the linear structures that are alive unfreed (ATS1 as well), so the leak check of c3asan is run on the others.
import subprocess, sys
exe, data, out = sys.argv[1:4]
o = subprocess.run([exe, data], capture_output=True).stdout.decode(errors='replace').split('\n')
bad = set(); cur = None
for l in o:
    if l.startswith('# ') and l[2:].isdigit(): cur = int(l[2:])
    elif l.startswith('EXN ') and cur is not None: bad.add(cur)
n = 0; w = open(out, 'w')
for i, l in enumerate(open(data), 1):
    if i not in bad: w.write(l); n += 1
w.close()
print('c3noexn: %d of the problems have an exception, %d are kept' % (len(bad), n))
