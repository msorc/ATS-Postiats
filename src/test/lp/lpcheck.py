#!/usr/bin/env python3
"""lpcheck.py OUTPUT: check the answers of the driver against the labels of the problems:
a problem labelled sat must never be refuted (answer -1), one labelled unsat must be refuted by the
solver with and without hint.  Prints the numbers (also of the answers of the problems without a label)."""
import sys, re, collections
cnt = collections.Counter()
bad = 0
cur = None
for line in open(sys.argv[1], errors='replace'):
    m = re.match(r'P (\S+) (\S+) N=(\d+)', line)
    if m:
        cur = m.group(2); cnt['problems'] += 1; cnt['label ' + cur] += 1; continue
    m = re.match(r'solve( \(no hint\)| \(negated\))?: (-?\d+)', line)
    if m and cur:
        which = m.group(1) or ''
        ans = int(m.group(2))
        cnt['answers%s %d' % (which, ans)] += 1
        if which == ' (negated)': continue
        if cur == 'sat' and ans == -1:
            print('UNSOUND: %s answered -1' % cur); bad += 1
        if cur == 'unsat' and ans != -1:
            print('INCOMPLETE: unsat problem answered %d%s' % (ans, which)); bad += 1
    if line.startswith('I '): cnt['arith'] += 1
for k in sorted(cnt): print(k, cnt[k])
print('label violations:', bad)
sys.exit(1 if bad else 0)
