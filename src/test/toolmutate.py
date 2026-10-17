#!/usr/bin/env python3
# usage: python3 toolmutate.py   (needs the ATS1 environment: tooldump1, comdump1 built; make tooldump comdump)
#
# Mutation test of the tools tests: each mutation is a deliberate bug put in a ported module (the file is restored afterwards), tooldump and comdump
# are rebuilt and compared with the ATS1 references (com_run.py on comtable.txt, toolfiles.sh on a sample of the repository files + the API line):
# every mutation must be detected (a difference).
import sys, os, subprocess, shutil, random
d = os.path.dirname(os.path.abspath(__file__)); M = os.path.join(d, '..')
MUT = [
 ('pats_comarg.dats', 'the count of the dashes of an argument', "then @(i, str) else loop (ptr0_succ<char> (p), i+1)", "then @(i, str) else loop (ptr0_succ<char> (p), i+2)"),
 ('pats_comarg.dats', 'is_DATS_flag compares 4 characters', 'if strncmp (flag, "-DATS", i2sz(5)) = 0 then true', 'if strncmp (flag, "-DATS", i2sz(4)) = 0 then true'),
 ('pats_comarg.dats', 'DATS_extract skips one character too many', 'ptr0_add_guint<char>($UN.cast{ptr}(s), i2sz(5))', 'ptr0_add_guint<char>($UN.cast{ptr}(s), i2sz(6))'),
 ('pats_comarg.dats', 'comarglst_parse takes the first argument for all', 'val x = comarg_parse (argv[i-1])', 'val x = comarg_parse (argv[0])'),
 ('pats_comarg.dats', 'process_IATS_dir forgets the IATS list', 'val () = $GLOB.the_IATS_dirlst_ppush(dir)', 'val () = ()'),
 ('pats_comarg.dats', 'the default PATSRELOCROOT', '"/tmp/.PATSRELOCROOT-"', '"/tmp/.PATSRELOCROOT_"'),
 ('pats_comarg.dats', 'the warning text', '"] is ignored."', '"] is ignored"'),
 ('pats_depgen.dats', 'local: the body is not visited', 'val () = depgen_d0eclist (d0cs_body, res)', 'val () = ()'),
 ('pats_depgen.dats', 'the target of a file name', "if i = k then '_' else c", "if i = k then '-' else c"),
 ('pats_depgen.dats', 'the -IATS directories are not searched', 'loop($GLOB.the_IATS_dirlst_get(), given)', 'None_vt()'),
 ('pats_depgen.dats', 'the separator of the entities', "if i > 0 then fprint_char (out, ' ')", "if i > 1 then fprint_char (out, ' ')"),
 ('pats_depgen.dats', 'the elif/else branches of a guarded declaration are not visited', 'val () = depgen_guad0ecl_node(x2, res)', 'val () = ()'),
 ('pats_depgen.dats', 'the order of the dependencies', 'list_vt_reverse(res) where', 'res where'),
 ('pats_taggen.dats', 'the line number', 'location_beg_nrow(loc)+1', 'location_beg_nrow(loc)+0'),
 ('pats_taggen.dats', 'the head of a local is visited twice (the bug of ATS1 is fixed)', 'val () = taggen_d0eclist (d0cs_head, res)\n  } (* end of [D0Clocal] *)', 'val () = taggen_d0eclist (d0cs_body, res)\n  } (* end of [D0Clocal] *)'),
 ('pats_taggen.dats', 'an annotated pattern is not visited', '| ~P0Tann (p0t, _) => tagentlst_add_p0at (res, p0t)', '| ~P0Tann (p0t, _) => ()'),
 ('pats_taggen.dats', 'the character count', 'location_beg_ntot(loc)+1L', 'location_beg_ntot(loc)+2L'),
 ('pats_taggen.dats', 'the order of the entities', 'list_vt_reverse (res)\nend // end of [taggen_proc]', 'res\nend // end of [taggen_proc]'),
 ('pats_jsonize.dats', 'the escape of a tab', '| \'\\t\' => fprint_string (out, "\\\\t")', '| \'\\t\' => fprint_string (out, "\\\\r")'),
 ('pats_jsonize.dats', 'the hexadecimal digits are lower case', "int2char0(char2int0('A') + (d - 10))", "int2char0(char2int0('a') + (d - 10))"),
 ('pats_jsonize.dats', 'the order of the fields of labval3', 'lv(l1, x1, lv(l2, x2, glist_sing(labjsonval_new(l3, x3))))', 'lv(l2, x2, lv(l1, x1, glist_sing(labjsonval_new(l3, x3))))'),
 ('pats_jsonize.dats', 'the separator of a list', 'then fprint_string (out, ", ")\n      // end of [if]\n    val () = fprint_jsonval (out, x)', 'then fprint_string (out, ",")\n      // end of [if]\n    val () = fprint_jsonval (out, x)'),
 ('pats_jsonize.dats', 'the kind of a closure', 'aux1 ("FUNCLOclo", jsonval_int (funclo_get_clokind (fc)))', 'aux1 ("FUNCLOclo", jsonval_int (1))'),
 ('pats_jsonize.dats', 'the label of an integer label', 'jsonval_labval1 ("LABint", jsv)', 'jsonval_labval1 ("LABInt", jsv)'),
 ('pats_jsonize.dats', 'the order of the elements of a list', '| ~GLnil () => list_vt_reverse (res)\n  | ~GLcons (x, xs1) => let\n      val y = f (x) in jsonize_list_loop', '| ~GLnil () => res\n  | ~GLcons (x, xs1) => let\n      val y = f (x) in jsonize_list_loop'),
 ('pats_jsonize.dats', 'a bool', '| ~JSONbool (b) => fprint_bool (out, b)', '| ~JSONbool (b) => fprint_bool (out, ~b)'),
 ('pats_jsonize.dats', 'the symbol option', '| ~GOsome(x) => jsonval_some(jsonize_symbol(x))', '| ~GOsome(x) => jsonize_symbol(x)'),
]
def sh(cmd, **kw):
    return subprocess.run(cmd, shell=True, cwd=d, capture_output=True, text=True, **kw)
def sample():
    # a sample of the repository files for the whole-file test
    root = os.path.abspath(os.path.join(d, '..', '..'))
    files = []
    for dp, dn, fn in os.walk(root):
        if '/.git' in dp or '/test/' in dp + '/': continue
        for f in fn:
            if f.endswith(('.sats', '.dats', '.hats')): files.append(os.path.join(dp, f))
    random.seed(7); random.shuffle(files)
    tc = os.path.join(d, 'toolcases')
    files = files[:200] + [os.path.join(tc, f) for f in os.listdir(tc) if f.endswith(('.sats', '.dats', '.hats'))] + [os.path.join(root, 'src', f) for f in ('pats_comarg.dats', 'pats_taggen.dats', 'pats_depgen.dats', 'pats_jsonize.dats', 'pats_syntax.sats', 'pats_trans1_dynexp.dats')]
    with open('/tmp/selfhost-scratch-tools/mut_files.txt', 'w') as o:
        for f in files:
            sd = 'sta' if f.endswith('.sats') else 'dyn'
            for k in ('DEP', 'DEPI', 'TAG', 'JSN'): o.write('%s%s\t%s\n' % (k, sd, f))
        o.write('API\tx\n')
def detect():
    r = sh('make -j8 -s tooldump comdump 2>&1 | grep -i "error" | head -3')
    if r.stdout.strip(): return 'BUILD FAIL: ' + r.stdout.strip()[:200]
    r = sh('python3 com_run.py comtable.txt ./comdump1 ./comdump | tail -1')
    if 'identical' not in r.stdout: return 'comtable'
    r = sh('FILELIST=/tmp/selfhost-scratch-tools/mut_files.txt TMPDIR=/tmp/selfhost-scratch-tools/w sh toolfiles.sh | tail -1')
    if 'identical' not in r.stdout: return 'toolfiles'
    return None
sample()
nbad = 0
for f, what, old, new in MUT:
    path = os.path.join(M, f)
    src = open(path).read()
    if src.count(old) != 1:
        print('MUTATION NOT APPLICABLE (%d matches): %s: %s' % (src.count(old), f, what)); nbad += 1; continue
    shutil.copy(path, '/tmp/selfhost-scratch-tools/mut_backup_' + f)
    try:
        open(path, 'w').write(src.replace(old, new))
        res = detect()
    finally:
        open(path, 'w').write(src)
    print('%-18s %-70s %s' % (f, what, ('detected by ' + res) if res and not res.startswith('BUILD') else (res or 'NOT DETECTED')))
    if res is None or res.startswith('BUILD'): nbad += 1
r = sh('make -j8 -s tooldump comdump 2>&1 | grep -i error | head')
print('mutations: %d, not detected or failed: %d' % (len(MUT), nbad))
sys.exit(1 if nbad else 0)
