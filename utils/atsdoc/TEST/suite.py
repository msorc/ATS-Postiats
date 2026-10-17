#!/usr/bin/env python3
#
# suite.py: the md5 suite of atsdoc and libatsdoc (utils/atsdoc/TEST)
#
#   suite.py run    --atsdoc ATSDOC --drv DRV
#   suite.py update --atsdoc REF_ATSDOC --drv REF_DRV
#
# [run] runs every case (make_cases) and compares the md5 of its result (exit status,
# stdout, stderr, and the files that it writes) with the line of expected.md5: it prints
# the cases that differ and exits with status 1 if there is one. The cases are
#   - atsdoc on the files of cases/ (a sample of the .atxt files of the repository, as
#     they were when the suite was made) and on the edge cases that [gen_edge] writes
#     (empty file, '#' at the end, escapes, unclosed argument lists and strings, funres,
#     CRLF, NUL and non-ASCII bytes, very long lines, ...), by name (-i), by stdin and with the
#     text on stdout; the command lines (every option, bad files, bad outputs...);
#     mutations of these files (seeded generator: the same ones everywhere);
#   - the API of libatsdoc through DRV (drv.dats): scripts of commands that build atexts,
#     put them in theAtextMap and print them (fprint_atext, fprint_strsub, fprint_filsub,
#     atext_filepath, tostring_strsub...).
# Everything runs in a temporary directory with the locale C, the files are given by
# relative names, and the paths of the temporary directory and of the programs are
# replaced by @W@ and @BIN@: the suite runs in any directory, in any locale, and needs no ATS1.
#
# [update] writes expected.md5 from the ATS1 programs (atsdoc and drv1.dats linked with the ATS1
# libatsdoc.a; see PORTING.md, "atsdoc and libatsdoc"); not needed by the suite.
#
# HX-2026-10
#
import sys, os, subprocess, hashlib, shutil, tempfile

HERE = os.path.dirname(os.path.abspath(__file__))

# ---------------------------------------------------------------- the inputs

def gen_edge():
    C = {}
    def add(name, data):
        if isinstance(data, str): data = data.encode('latin-1')
        C[name] = data
    add('empty.atxt', '')
    add('sharp.atxt', '#')
    add('sharpeof.atxt', 'abc #')
    add('slasheof.atxt', 'abc \\')
    add('esc.atxt', 'a \\# b \\\\ c ## d \\% e \\x f \\\nnext #g(1)\n')
    add('unclosed1.atxt', '#f(1, 2')
    add('unclosed2.atxt', '#f(')
    add('unclosed3.atxt', '#f{')
    add('unclosed4.atxt', '#f(1 2)\n')
    add('unclosed5.atxt', '#f("abc')
    add('unclosed6.atxt', "#f('abc")
    add('unclosed7.atxt', '#f(#g(1)')
    add('unclosed8.atxt', '#f(#g(')
    add('nest.atxt', '#f(#g(1), #h{a}, "x#k(2)y#m(3)z", \'q#n(4)\') tail\n')
    add('funres.atxt', '#f[res](1) #f[](1) #f[res(1) #f[1x](1) #f[a\'b](2) #f[x]\n#g[y]{a} #h[')
    add('crlf.atxt', 'a\r\n#f(1,\r\n 2)\r\n%{\r\nval x = 1\r\n%}\r\nz\r\n')
    add('huge.atxt', 'x' * 1000000 + '#f(1)' + 'y' * 1000000 + '\n')
    add('hugearg.atxt', '#f("' + 'a' * 500000 + '")\n')
    add('bigext.atxt', '%{\n' + ('val x = 1 (* aaaaaaaaaaaaaaa *)\n' * 20000) + '%}\n')
    add('percent1.atxt', 'a %{ not at col 1\n %{\n%\n%x\n%}\n')
    add('percent2.atxt', '%{\nabc\n')
    add('percent3.atxt', '%{\nabc\n%}')
    add('percent4.atxt', '%{\nabc\n %}\n%}x\n')
    add('percent5.atxt', '%{\n%\n%x\n%}\n%')
    add('percent6.atxt', 'text %')
    add('percent7.atxt', '%{%}\n%{\n%}')
    add('ident.atxt', "#f'(1) #f_1(2) #_x(3) #9x(4) #Foo'bar'(5) #f2'")
    add('nums.atxt', '#f(123abc) #f(-1) #f(1.5) #f(007, 0x10) #f(1,2,3)\n')
    add('strs.atxt', '#f("\\\\") #f("\\#") #f("\\"") #f(\'\\\'\') #f("a\\nb") #f("\\") #f(\'"\') #f("\'")\n')
    add('commas.atxt', '#f(a,) #f(,a) #f(a b) #f(a,,b) #f( a , b ) #f(a;b) #f(()) #f({}) #f(a)(b)\n')
    add('ws.atxt', '#f(\ta,\x0bb,\x0cc,\r\nd)\n#g\n(1)\n#h {a}\n')
    add('bin.atxt', bytes(range(256)) + b'#f(1)' + bytes(range(256)))
    add('nul1.atxt', b'x%{\nabc\x00')
    add('nul2.atxt', b'%{\n\x00abc\n')
    add('nul3.atxt', b'#f("abc\x00')
    add('nul4.atxt', b'#f("\x00")')
    add('nul5.atxt', b'#f(\x00')
    add('nul6.atxt', b'#f[a\x00](1)')
    add('nul7.atxt', b"#f('a\x00b')\n")
    add('nul8.atxt', b'\x00#f(1)\x00\n%{\nok\n%}\x00')
    add('nul9.atxt', b'abc\x00def #f(1)\n%{\nxx\x00yy\n%}\n')
    add('utf8.atxt', 'h\u00e9llo #f("\u00e9\u00e8") \u4e2d\u6587\n'.encode('utf-8'))
    add('many.atxt', '#f(1 2)\n' * 250)
    add('many100.atxt', '#f(1 2)\n' * 100)
    add('many101.atxt', '#f(1 2)\n' * 101)
    add('dupres.atxt', '#f[a](1) #g[a](2) #h(3) #k(4)\n')
    add('bare.atxt', '#f #g\n#h x #k{} #m()\n')
    add('hashes.atxt', '# # ## ### #( #{ #1 #-f #f- #f$ $#f\n')
    add('slashnl.atxt', 'a\\\nb\\\n\\\n#f(1)\\\n')
    add('braces.atxt', '#f{a{b}c} #g{a(b)c} #h(a{b}) #k({a})\n')
    add('lines.atxt', 'l1\nl2 #f(1)\n\n\nl5 %{\n%{\nm\n%}\n#g("x\ny")\n')
    add('manyfuncs.atxt', ''.join('#f%d(%d, "s%d", x%d)\n' % (i, i, i, i) for i in range(20000)))
    add('prefix.atxt', '#f(1) #g[zz](2) #h(3)\n')
    add('subdir/inner.atxt', '#f(1) #f(\n')
    return C

class Rng:  # a generator that does not depend on the version of python
    def __init__(self, seed): self.x = seed & 0xffffffff
    def next(self):
        self.x = (self.x * 1103515245 + 12345) & 0x7fffffff
        return self.x >> 8
    def below(self, n): return self.next() % n
    def pick(self, xs): return xs[self.below(len(xs))]

ALPHA = ['#', '#', 'f', 'g', '(', ')', ',', '"', "'", '\\', '\\', '%', '%{\n', '%}\n', '{', '}', '\n', 'x', '1', '12', ' ', '[', ']',
         '$', '#f(', '#g{', '"a#h(', "e'", '_', '\t', '\r', '\xe9', '\x00']

def gen_fuzz(corpus, n):
    rng = Rng(20261017)
    out = {}
    for i in range(n):
        if i % 2 == 0:
            d = ''.join(rng.pick(ALPHA) for _ in range(rng.below(120))).encode('latin-1')
        else:
            base = rng.pick(corpus)
            if len(base) > 3000:
                s = rng.below(len(base) - 2000); base = base[s:s + 100 + rng.below(1900)]
            d = bytearray(base)
            for _ in range(1 + rng.below(4)):
                if not d: break
                k = rng.below(4); j = rng.below(len(d))
                if k == 0: del d[j:j + 1 + rng.below(20)]
                elif k == 1: d[j] = rng.below(256)
                elif k == 2: d[j:j] = rng.pick(ALPHA).encode('latin-1')
                else: d = d[:j]
            d = bytes(d)
        out['fuzz%04d.atxt' % i] = d
    return out

RTFILES = {'f1.txt': b'file one #a$ and \\#b$ #zz$\n', 'empty.txt': b'', 'big.txt': b'abc #a$ def \\ x\\#y #b$\n' * 20000,
           'bin.txt': bytes(range(1, 256)) + b'#a$', 'nonl.txt': b'#', 'tail.txt': b'abc\\',
           'dollar.txt': b'#a$#a$#$ #1$ #_x$ #a$$ #$a$ #a #$\n'}

RTFIXED = [
 'str a hello\nstr b world\ntxt2 c a b\nprint c\n',
 'str a A\nstr b B\nstr s ,\ncat c a b a\nprint c\ncatsep d s a b a\nprint d\ncatsep1 e s a\nprint e\ncat0 z\nprint z\n',
 'str a A\nstr b B\nstr s ,\ncatv c a b a\nprint c\ncatsepv d s a b a\nprint d\n',
 'sub a x#b$y\nstr b BB\nprint a\nstr b CC\nprint a\n',
 'app2 a foo bar baz\napp3 b 1 2 3 4\nprint a\nprint b\nnl n\nprint n\ntxt3 t a n b\nprint t\n',
 'ptr a heap\nptr0 b\nstrcstptr c x#a$\nstrsubptr d y#a$z\nprint a\nprint b\nprint c\nprint d\n',
 'file a f1.txt\nprint a\nfile b nonexistent.txt\nprint b\nfile c empty.txt\nprint c\nfile d big.txt\nsearch d\n',
 'filsub f1.txt\nfilsub empty.txt\nfilsub dollar.txt\nfilsub tail.txt\nfilsub nonl.txt\n',
 'str a A\nfilsub f1.txt\nstr zz Z\nfilsub f1.txt\nfilsub bin.txt\n',
 'filsub nonexistent.txt\nstr a late\n',
 'strsub \\#a$ \\\\#a$ #a$ #$ ## #\nstrsub abc\\\nstrsub #\nstrsub \\\nstrsub x#abc\nstrsub x#abc$y\n',
 'tostr abc #a$ \\#\ntostr \ntostr #x$#y$\n',
 'str a first\nstr a second\nsearch a\ntxt2 b a a\nprint b\n',
 'str a 1\nstr b #a$\nsub c #b$ #a$\nprint c\n',
 'str a \xe9\xff\xe9\nsub b #a$ \xe9 \xff \xe9\nprint a\nprint b\nstrsub a\xe9b\xffc\ntostr a\xe9b\xffc\n',
]
RTNAMES = ['a', 'b', 'c', 'd', 'x', 'y1', '_z', "q'r"]

def rt_script(rng):
    out = []
    files = sorted(k for k in RTFILES if k != 'big.txt')
    for _ in range(1 + rng.below(12)):
        k = rng.below(13)
        n = rng.pick(RTNAMES); m = rng.pick(RTNAMES); l = rng.pick(RTNAMES)
        txt = ''.join(rng.pick(['a', '#', '$', '\\\\', '\\\\n', ' ', 'x', '#' + rng.pick(RTNAMES) + '$', '\xe9', '1', '_', "'"]) for _ in range(rng.below(9)))
        if k == 0: out.append('str %s %s' % (n, txt))
        elif k == 1: out.append('sub %s %s' % (rng.pick(['s1', 's2']), txt))
        elif k == 2: out.append('app2 %s %s %s' % (n, rng.pick(['p', 'q']), txt))
        elif k == 3: out.append('txt2 %s %s %s' % (n, m, l) if n not in (m, l) else 'nil %s' % n)
        elif k == 4: out.append('print %s' % n)
        elif k == 5: out.append('search %s' % n)
        elif k == 6: out.append('strsub %s' % txt)
        elif k == 7: out.append('filsub ' + rng.pick(files))
        elif k == 8: out.append('file %s %s' % (n, rng.pick(files + ['nope'])))
        elif k == 9: out.append('catsep %s %s %s %s %s' % (n, m, l, m, l) if n not in (m, l) else 'nl %s' % n)
        elif k == 10: out.append('nl %s' % n)
        elif k == 11: out.append('tostr %s' % txt)
        else: out.append('app3 %s a %s %s' % (n, rng.pick(['b', '']), txt))
    return '\n'.join(out) + '\n'

CMDS = [
 ('noargs_empty', [], b''), ('noargs_text', [], b'a #f(1)\n'),
 ('help1', ['-h'], None), ('help2', ['--help'], None), ('help3', ['--help', '-i', 'esc.atxt'], None),
 ('help4', ['-i', 'esc.atxt', '--help'], None), ('help5', ['-h', '-h'], None), ('help_stdin', ['-h'], b'x #f(1)'),
 ('nofile', ['-i', 'nonexistent.atxt'], None), ('nofile2', ['-i', 'esc.atxt', 'nonexistent.atxt', 'nest.atxt'], None),
 ('multi', ['-i', 'esc.atxt', 'nest.atxt', 'funres.atxt'], None),
 ('multi_oc', ['--outcode', 'o.dats', '-i', 'esc.atxt', 'nest.atxt'], None),
 ('badout', ['--outcode', '/nonexistent/x.dats', '-i', 'nest.atxt'], None),
 ('badout2', ['-oc', '/nonexistent/x.dats', '-i', 'nest.atxt'], None),
 ('baddata', ['--outdata', '/nonexistent/x.txt', '-i', 'nest.atxt'], None),
 ('baddata2', ['-od', '/nonexistent/x.txt', '-i', 'nest.atxt'], None),
 ('outdata', ['--outdata', 'o.txt', '--outcode', 'o.dats', '-i', 'nest.atxt'], None),
 ('outdata2', ['-od', 'o.txt', '-oc', 'o.dats', '-i', 'nest.atxt'], None),
 ('outcode_twice', ['-oc', 'a.dats', '-oc', 'b.dats', '-i', 'nest.atxt'], None),
 ('outcode_noarg', ['--outcode'], b'x'), ('outcode_noarg2', ['-oc'], b'x #f(1)'),
 ('outdata_noarg', ['-i', 'nest.atxt', '--outdata'], None),
 ('input_noarg', ['-i'], b'x #f(1)'), ('input_noarg2', ['--input'], b'x #f(1)'),
 ('input_opt', ['-i', '-x'], None), ('input_opt2', ['-i', 'esc.atxt', '-x', 'nest.atxt'], None),
 ('input_opt3', ['-i', 'esc.atxt', '--bad', 'nest.atxt'], None), ('input_opt4', ['-i', 'esc.atxt', '---bad', 'nest.atxt'], None),
 ('input_opt5', ['-i', 'esc.atxt', '-i', 'nest.atxt', '-i'], b'z'),
 ('input_long', ['--input', 'esc.atxt', '--outcode', 'l.dats', 'nest.atxt'], None),
 ('prefix', ['--prefix', 'XX', '-i', 'prefix.atxt'], None), ('prefix2', ['--prefix', '', '-i', 'prefix.atxt'], None),
 ('prefix3', ['--prefix'], b'#f(1)'),
 ('prefix4', ['-i', 'prefix.atxt', '--prefix', 'Q_', '-i', 'prefix.atxt'], None),
 ('warn1', ['-foo'], b'#f(1)'), ('warn2', ['--foo'], b''), ('warn3', ['bare'], b''), ('warn4', ['---x'], b''),
 ('warn5', ['-'], b''), ('warn6', ['--'], b''), ('warn7', ['-v'], b''), ('warn8', ['--version'], b''),
 ('warn9', ['-i', 'esc.atxt', '-foo'], None), ('warn10', [''], b''), ('warn11', ['-i', ''], None),
 ('warn12', ['--outcode', '--outdata', 'x'], b'q'),
 ('abs', ['-i', '@W@/esc.atxt'], None), ('rel_dot', ['-i', './esc.atxt'], None), ('rel_sub', ['-i', 'subdir/inner.atxt'], None),
 ('rel_up', ['-i', 'subdir/../esc.atxt'], None), ('rel_up2', ['-i', 'subdir/../subdir/./inner.atxt'], None),
 ('dir', ['-i', 'subdir'], None), ('dot', ['-i', '.'], None), ('dev_null', ['-i', '/dev/null'], None),
 ('oc_devnull', ['--outcode', '/dev/null', '-i', 'nest.atxt'], None),
 ('oc_devfull', ['--outcode', '/dev/full', '-i', 'nest.atxt'], None),
 ('od_devfull', ['--outdata', '/dev/full', '-i', 'nest.atxt'], None),
 ('oc_dir', ['--outcode', 'subdir', '-i', 'nest.atxt'], None),
 ('oc_after_input', ['-i', 'esc.atxt', '-oc', 'o2.dats'], b'stdin #f(1)'),
 ('od_after_input', ['-i', 'esc.atxt', '-od', 'o2.txt'], b'stdin #f(1)'),
 ('longoc_after_input', ['-i', 'esc.atxt', '--outcode', 'o2.dats'], b'stdin #f(1)'),
 ('longod_after_input', ['-i', 'esc.atxt', '--outdata', 'o2.txt'], b'stdin #f(1)'),
 ('input_after_input', ['-i', 'esc.atxt', '-i'], b'stdin #f(2)'),
 ('longinput_after_input', ['--input', 'esc.atxt', '--input'], b'stdin #f(2)'),
 ('help_then_input', ['-h', '-i', 'esc.atxt'], None),
 ('prefix_after_input', ['-i', 'esc.atxt', '--prefix', 'Z'], b'stdin #f(3)'),
 ('same_file', ['--outcode', 'same.out', '--outdata', 'same.out', '-i', 'nest.atxt'], None),
]

def make_cases():
    edge = gen_edge()
    corp = {}
    cdir = os.path.join(HERE, 'cases')
    for f in sorted(os.listdir(cdir)):
        corp[f] = open(os.path.join(cdir, f), 'rb').read()
    fuzz = gen_fuzz(list(corp.values()), 600)
    allfiles = dict(edge); allfiles.update(corp); allfiles.update(fuzz)
    cases = []   # (name, kind, args, stdin)
    for n in sorted(edge):
        if n.startswith('subdir/'): continue
        cases.append(('file_' + n, 'atsdoc', ['--outcode', 'out.dats', '-i', n], None))
        cases.append(('stdin_' + n, 'atsdoc', ['--outcode', 'out.dats'], edge[n]))
        cases.append(('stdout_' + n, 'atsdoc', ['-i', n], None))
    for n in sorted(corp):
        cases.append(('file_' + n, 'atsdoc', ['--outcode', 'out.dats', '-i', n], None))
        cases.append(('stdout_' + n, 'atsdoc', ['-i', n], None))
    for n in sorted(fuzz):
        cases.append(('file_' + n, 'atsdoc', ['--outcode', 'out.dats', '-i', n], None))
        if int(n[4:8]) % 3 == 0:
            cases.append(('stdin_' + n, 'atsdoc', ['--outcode', 'out.dats'], fuzz[n]))
    for name, args, inp in CMDS:
        cases.append(('cmd_' + name, 'atsdoc', args, inp))
    rng = Rng(5)
    scripts = list(RTFIXED) + [rt_script(rng) for _ in range(1500)]
    for i, s in enumerate(scripts):
        cases.append(('api%04d' % i, 'drv', [], s.encode('latin-1')))
    return allfiles, cases

# ---------------------------------------------------------------- running

def run_case(binp, case, allfiles):
    name, kind, args, inp = case
    d = tempfile.mkdtemp(prefix='atsdoc')
    try:
        if kind == 'atsdoc':
            files = allfiles
        else:
            files = RTFILES
        for n, dat in files.items():
            p = os.path.join(d, n); os.makedirs(os.path.dirname(p), exist_ok=True)
            with open(p, 'wb') as f: f.write(dat)
        a = [x.replace('@W@', d) for x in args]
        env = dict(os.environ, LC_ALL='C')
        try:
            r = subprocess.run([binp] + a, cwd=d, input=inp if inp is not None else b'', capture_output=True, env=env, timeout=120)
            rc, so, se = r.returncode, r.stdout, r.stderr
        except subprocess.TimeoutExpired:
            rc, so, se = 'timeout', b'', b''
        written = {}
        for root, _, fs in os.walk(d):
            for f in fs:
                p = os.path.join(root, f); rel = os.path.relpath(p, d)
                dat = open(p, 'rb').read()
                if rel in files and files[rel] == dat: continue
                written[rel] = dat
        norm = lambda b: b.replace(d.encode(), b'@W@').replace(binp.encode(), b'@BIN@').replace(os.path.abspath(binp).encode(), b'@BIN@')
        h = hashlib.md5()
        h.update(repr(rc).encode()); h.update(b'\0'); h.update(norm(so)); h.update(b'\0'); h.update(norm(se))
        for rel in sorted(written):
            h.update(b'\0' + rel.encode() + b'\0'); h.update(norm(written[rel]))
        return h.hexdigest()
    finally:
        shutil.rmtree(d)

def work(a):
    binp, case, allfiles = a
    return case[0], run_case(binp, case, allfiles)

def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else 'run'
    opts = dict(zip(sys.argv[2::2], sys.argv[3::2]))
    atsdoc = os.path.abspath(opts['--atsdoc']); drv = os.path.abspath(opts['--drv'])
    allfiles, cases = make_cases()
    from multiprocessing import Pool
    jobs = [((atsdoc if c[1] == 'atsdoc' else drv), c, allfiles) for c in cases]
    with Pool(min(16, os.cpu_count() or 1)) as p:
        res = p.map(work, jobs, chunksize=8)
    exp = os.path.join(HERE, 'expected.md5')
    if mode == 'update':
        with open(exp, 'w') as f:
            for n, h in res: f.write('%s %s\n' % (n, h))
        print('wrote %d cases to %s' % (len(res), exp)); return 0
    want = {}
    for line in open(exp):
        n, h = line.split(); want[n] = h
    bad = [n for n, h in res if want.get(n) != h]
    extra = [n for n in want if n not in dict(res)]
    for n in bad[:50]: print('FAIL', n)
    if len(bad) > 50: print('... and %d more' % (len(bad) - 50))
    for n in extra: print('MISSING', n)
    print('%d cases, %d failed' % (len(res), len(bad) + len(extra)))
    return 1 if (bad or extra) else 0

if __name__ == '__main__':
    sys.exit(main())
