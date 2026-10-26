#!/usr/bin/env python3
#
# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: GPL-3.0-or-later
#
# suite.py: the tests of patslint (utils/atslint/TEST)
#
#   suite.py run    --patslint PATSLINT --diff PATSLINT_DIFF [NAME ...]
#   suite.py update --patslint PATSLINT --diff PATSLINT_DIFF [NAME ...]
#
# Each case (CASES below) writes its input files into an empty temporary
# directory, runs patslint (or patslint-diff in a git repository made there)
# with the given arguments in that directory, and records the exit status,
# stdout, stderr and, for --fix, the files after the run (each line with
# its bytes escaped, so that the expected files have no tabs, CRs or
# trailing white space). [run] compares the record with expected/NAME.out
# and prints the cases that differ (with a diff); [update] rewrites
# expected/NAME.out: review the change before committing it.
#
# The inputs are in this file, as bytes, so that no tool can change their
# white space; the temporary directory has no .patslint above it unless a
# case writes one.
#
import sys, os, subprocess, tempfile, difflib, argparse

HERE = os.path.dirname(os.path.abspath(__file__))
EXPECTED = os.path.join(HERE, 'expected')

#
# a case: (name, files, argv, options)
#   files: {path: bytes or str}
#   argv: the arguments of patslint (the program is prepended); [DIFF] as
#         the first element runs patslint-diff instead
#   options: show=[paths] (files printed after the run),
#            git=True (the files are committed first, then [after] is written),
#            env={NAME: value or None} (the environment of the run),
#            escape=True (the bytes of stdout are escaped as in the files)
#
CASES = []

def case(name, files, argv, **opts):
    CASES.append((name, files, argv, opts))

#
# the rules, one bad and one good input each
#
case('tab_bad', {'a.dats': 'val\tx = 1\n// a\ttab in a comment\n\tval y = 2\n'}, ['a.dats'])
case('tab_ok', {'a.dats': 'val s = "a\ttab in a string"\nval c = \'\t\'\n'}, ['a.dats'])
case('tab_extcode', {'a.dats': '%{\nint\tf(void) { return 0; }\n%}\n'}, ['a.dats'])

case('trailing_ws_bad', {'a.dats': 'val x = 1 \nval y = 2\t\n(* comment  \n*)\n// \n'}, ['a.dats'])
case('trailing_ws_ok', {'a.dats': 'val x = 1\nval s = "a string   \ngoes on"\n'}, ['a.dats'])

case('line_length_bad', {'a.dats':
    'val x = ' + ' + '.join(['1'] * 40) + '\n' +
    '// ' + 'word ' * 20 + '\n'}, ['a.dats'])
case('line_length_ok', {'a.dats':
    '// https://example.org/' + 'x' * 100 + '\n' +
    'val s =\n"' + 'y' * 100 + '"\n' +
    'val x = 1 // short\n' +
    '// ' + '\u00e9' * 77 + '\n'}, ['a.dats'])
case('line_length_maxcol', {'a.dats': 'val x = 123456789 + 123456789\n'}, ['--max-col=20', 'a.dats'])
case('line_length_tab', {'a.dats': 'val x =\t\t\t\t\t\t\t\t\t1 + 1\n'}, ['--disable=tab', 'a.dats'])

case('crlf_bad', {'a.dats': b'val x = 1\r\nval y = 2\r\nval z = 3\n'}, ['a.dats'])
case('final_newline_bad', {'a.dats': 'val x = 1\nval y = 2'}, ['a.dats'])
case('blank_eof_bad', {'a.dats': 'val x = 1\n\n  \n\n'}, ['a.dats'])
case('blank_eof_ok', {'a.dats': 'val x = 1\n\nval y = 2\n'}, ['a.dats'])

case('indent_off', {'a.dats': 'fun f () =\n   1\n'}, ['a.dats'])
case('indent_bad', {'a.dats':
    'fun f () =\n   1\n(*\n   a comment\n*)\n%{\n   int x;\n%}\nval s = "a\n   b"\n'},
    ['--enable=indent', 'a.dats'])
case('indent_width', {'a.dats': 'fun f () =\n  1\nfun g () =\n    2\n'},
    ['--enable=indent', '--indent-width=4', 'a.dats'])

case('non_ascii_off', {'a.dats': 'val \u00e9 = 1\n'}, ['a.dats'])
case('non_ascii_bad', {'a.dats':
    'val x = 1 // \u00e9t\u00e9\nval s = "\u4f60\u597d"\nval y = 1 \u00d7 2\n'},
    ['--enable=non-ascii', 'a.dats'])

case('lex_error_comment', {'a.dats': 'val x = 1\n(* not (* closed *)\nval y = 2\n'}, ['a.dats'])
case('lex_error_string', {'a.dats': 'val x = 1\nval s = "not closed\nval y = 2\n'}, ['a.dats'])
case('lex_error_char', {'a.dats': "val c = 'ab'\n"}, ['a.dats'])
case('lex_error_extcode', {'a.dats': 'val x = 1\n%{\nint x;\n'}, ['a.dats'])

#
# edge cases
#
case('empty', {'a.dats': b''}, ['a.dats'])
case('only_newline', {'a.dats': b'\n'}, ['a.dats'])
case('no_newline_one_char', {'a.dats': b'x'}, ['--disable=parse-error', 'a.dats'])
case('nul_byte', {'a.dats': b'val x = 1\x00\nval y = 2 \n'}, ['a.dats'])
case('utf8_columns', {'a.dats': '// \u00e9\u00e9\u00e9\tx\nval s = "\u4f60\u597d" \n'}, ['a.dats'])
case('latin1_bytes', {'a.dats': b'// caf\xe9\nval x = 1 \n'}, ['a.dats'])
case('long_line', {'a.dats': 'val x = ' + ' + '.join(['1'] * 3000) + '\n'}, ['a.dats'])
case('rest_comment', {'a.dats': 'val x = 1\n////\nanything \t here\n'}, ['a.dats'])
case('sats_hats', {'a.sats': 'fun f (): int \n', 'b.hats': '\tval x = 1\n'}, ['a.sats', 'b.hats'])

#
# the rules on the tokens
#
case('footer', {'a.dats': 'val x = 1\n(* end of [b.dats] *)\n',
                'b.dats': 'val y = 1\n(* end of [b.dats] *)\n',
                'c.dats': '// end of [a list]\n'},
    ['a.dats', 'b.dats', 'c.dats'])
case('separator', {'a.dats':
    '(* ****** ****** *)\nval x = 1\n(* ***** ***** *)\n(****** ******)\n(* a *)\n(**)\n'},
    ['--enable=separator', 'a.dats'])
case('comma_space', {'a.dats':
    'val x = f(a,b)\nval y = f(a, b)\nval z = @(a,b,c)\nval w = f(a,\n  b)\nval s = "a,b"\n'},
    ['--enable=comma-space', 'a.dats'])
case('trailing_semicolon', {'a.dats':
    'val () = (f (); g ();)\nval () = (f (); g ())\nval x = let val () = f (); in 1 end\n'
    'val () = { val () = f (); }\nval () = (f (); // comment\n)\n'},
    ['--enable=trailing-semicolon', 'a.dats'])

#
# the rules on the syntax tree
#
case('parse_error', {'a.dats': 'val x = 1\nval = 2\nval y = 3\n'}, ['a.dats'])
case('parse_error_after_lex', {'a.dats': 'val x = 1\nval s = "open\n'}, ['a.dats'])
case('parse_hats_static', {'a.hats':
    'fun f (x: int): int\nabstype t = ptr\n', 'b.hats': 'val x = f (1)\n',
    'c.hats': 'val = 1\n'}, ['a.hats', 'b.hats', 'c.hats'])
case('staload_dup', {'a.dats':
    'staload "x.sats"\nstaload X = "x.sats"\nstaload "x.sats"\n'
    'staload X = "x.sats"\nval y = $X.f\n'
    'val z = let staload "x.sats" in 1 end\n'}, ['a.dats'])
case('staload_unused', {'a.dats':
    'staload A = "a.sats"\nstaload B = "b.sats"\nstaload _ = "c.dats"\n'
    'staload "d.sats"\nval x = $A.f\nval s = "$B"\n',
    'h.hats': 'staload C = "c.sats"\n'}, ['a.dats', 'h.hats'])
case('let_empty', {'a.dats': 'val x = let in 1 end\nval y = let val z = 1 in z end\n'},
    ['--enable=let-empty', 'a.dats'])
case('case_rules', {'a.dats':
    'val a = case x of 0 => 1 | _ => 2\nval b = case+ x of _ => 1\n'
    'val c = case- x of 0 => 1 | _ => 2\n'},
    ['--enable=case-single,case-unchecked', 'a.dats'])
case('end_comment', {'a.dats':
    'fun f (): int = let\nin\n  1\nend // end of [g]\n'
    'fun g (): int = let\nin\n  2\nend // end of [g]\n'
    'implement h () = let\nin\n  3\nend // end of [let]\n'
    'implement k () = let\nin\n  4\nend // end of [f]\n'}, ['a.dats'])
case('fnx_template', {'a.dats':
    'fnx{a:t@ype} f (x: a): a = x\nfnx g (x: int): int = x\nfun{a:t@ype} h (x: a): a = x\n'},
    ['a.dats'])
case('if_const', {'a.dats':
    'val x = if true then 1 else 2\nval y = if b then 1 else 2\nval z = (if false then ())\n'},
    ['a.dats'])
case('naming', {'a.sats':
    'datavtype list_vt = nil_vt | cons_vt of (int, list_vt)\n'
    'datavtype mylist = mynil | mycons of (int, mylist)\n'
    'vtypedef buf_vt = ptr\nvtypedef buf = ptr\nabsvtype obj = ptr\nabsvtype obj_vtype = ptr\n'
    'dataview arr_v (l:addr) = arr_nil (l)\ndataview arr (l:addr) = arr_nil2 (l)\n'
    'typedef t = int\ndatatype d = D\n'}, ['--enable=naming', 'a.sats'])

#
# --semantic (the rules after the binding of the names: PATSHOME is the
# root of this repository)
#
SEMA_A = """\
#include "share/atspre_staload.hats"

datatype color = Red | Green | Blue

fun f (x: int, y: int): int = let
  val unused = x + 1
  val used = x * 2
  fun helper (z: int): int = z
  fun g (z: int): int = z + used
  val x = g (y)
in
  x
end

fun h (c: color): int =
  case c of
  | Red () => 1
  | Green () => 2

fun h2 (c: color): int =
  case+ c of
  | Red () => 1
  | Green () => 2
  | Blue () => 3

fun h3 (c: color): int =
  case- c of Red () => 1

fun k (c: color): int = let
  val Red () = c
in
  0
end

fun loop (n: int, acc: int): int =
  if n > 0 then loop (n - 1, acc + n) else acc

fun firstof (a: int, b: int): int = a

fun ignored (_a: int): int = 0

implement main0 () = {
  val n = f (1, 2)
  val _skip = 3
  macdef pr (s) = print (,(s))
  val m = 4
  val () = pr (m)
  var v: int = 0
  val () = v := 1
  val opt = Some_vt (1)
  val () = (case+ opt of ~Some_vt (z) => () | ~None_vt () => ())
}
"""
case('sema_default', {'a.dats': SEMA_A}, ['--semantic', 'a.dats'])
case('sema_all', {'a.dats': SEMA_A},
    ['--semantic', '--enable=unused-arg,shadow', 'a.dats'])
case('sema_off', {'a.dats': SEMA_A}, ['a.dats'])
case('sema_local', {'a.dats':
    'local\n  val hidden = 1\n  val shown = 2\nin\n  val x = shown\nend\n'
    'val top = 3\nfun top_fun (): int = 4\n'}, ['--semantic', 'a.dats'])
case('sema_where', {'a.dats':
    'fun f (): int = y where {\n  val y = 1\n  val z = 2\n}\n'}, ['--semantic', 'a.dats'])
case('sema_errors', {'a.dats': 'val x = nosuchname\nval y = let val z = 1 in 2 end\n'},
    ['--semantic', 'a.dats'])
case('sema_sats_hats', {
    'a.sats': 'fun f (x: int): int\ndatatype t = A | B\n',
    'b.hats': 'val x = let val y = 1 in 2 end\n'},
    ['--semantic', 'a.sats', 'b.hats'])
case('sema_include', {
    'a.dats': '#include "b.hats"\nval x = let val y = 1 in 2 end\n',
    'b.hats': 'val p = let val q = 1 in 2 end\n'},
    ['--semantic', 'a.dats'])
case('sema_no_patshome', {'a.dats': 'val x = 1\n'}, ['--semantic', 'a.dats'],
    env={'PATSHOME': None})

#
# the comments that disable rules
#
case('disable_line', {'a.dats':
    'val x = 1\t// lint: disable=tab\n'
    '// lint: disable=trailing-ws,tab\n'
    'val\ty = 2 \n'
    'val\tz = 3 \n'}, ['a.dats'])
case('disable_block', {'a.dats':
    '(* lint: disable=trailing-ws *)\nval y = 2 \n(*\n  lint: disable=tab\n*)\nval\tz = 3\n'}, ['a.dats'])
case('disable_file', {'a.dats':
    'val\tx = 1 \n(* lint: disable-file=tab *)\nval\ty = 2 \n'}, ['a.dats'])
case('disable_all', {'a.dats': '// lint: disable=all\nval\tx = 1 \nval\ty = 2 \n'}, ['a.dats'])
case('disable_in_string', {'a.dats': 'val s = "lint: disable=tab"\nval\tx = 1\n'}, ['a.dats'])

#
# the options
#
case('opt_help', {}, ['--help'])
case('opt_list_rules', {}, ['--list-rules'])
case('opt_no_file', {}, [])
case('opt_unknown', {'a.dats': 'val x = 1\n'}, ['--frobnicate', 'a.dats'])
case('opt_unknown_rule', {'a.dats': 'val x = 1\n'}, ['--enable=tabs,indent', 'a.dats'])
case('opt_bad_number', {'a.dats': 'val x = 1\n'}, ['--max-col=zero', '--indent-width=-2', 'a.dats'])
case('opt_no_such_file', {}, ['nonexistent.dats'])
case('opt_disable', {'a.dats': 'val\tx = 1 \n'}, ['--disable=tab,trailing-ws', 'a.dats'])
case('opt_severity', {'a.dats': 'val\tx = 1 \n'},
    ['--severity=tab:error', '--severity=trailing-ws:info', 'a.dats'])
case('opt_severity_bad', {'a.dats': 'val x = 1\n'},
    ['--severity=tab', '--severity=tab:loud', '--severity=nope:error', 'a.dats'])
case('opt_fail_on_error', {'a.dats': 'val\tx = 1\n'}, ['--fail-on=error', 'a.dats'])
case('opt_fail_on_info', {'a.dats': 'fun f () =\n   1\n'},
    ['--enable=indent', '--fail-on=info', 'a.dats'])
case('opt_lines', {'a.dats': 'val\ta = 1\nval\tb = 2\nval\tc = 3\nval\td = 4\nval\te = 5\n'},
    ['--lines=2,4-5', 'a.dats', '--all-lines', 'a.dats'])
case('opt_lines_bad', {'a.dats': 'val x = 1\n'}, ['--lines=3-1', '--lines=x', 'a.dats'])
case('opt_json', {'a "q".dats': 'val\tx = 1\n(* not closed\n'}, ['--format=json', 'a "q".dats'])
case('opt_source', {'a.dats':
    b'val x = 1 \n\tval\ty = "\xc3\xa9t\xc3\xa9"\t// x\nval z = f(a,b)\r\n(* open\n'},
    ['--source', '--enable=comma-space', 'a.dats', '--no-source', 'a.dats'], escape=True)
case('opt_source_json', {'a.dats': 'val\tx = 1\n'}, ['--source', '--format=json', 'a.dats'])
case('opt_order', {'a.dats': 'val\tx = 1\n', 'b.dats': 'val\ty = 1\n'},
    ['a.dats', '--disable=tab', 'b.dats'])

#
# the configuration file
#
case('config_basic', {
    '.patslint': '# a comment\nmax-col = 20\ntab = off\nindent = on\nindent-width = 4\ntrailing-ws = error\n',
    'a.dats': 'val\tx = 123456789 + 123456789 \nfun f () =\n   1\n'}, ['a.dats'])
case('config_nearest', {
    '.patslint': 'tab = off\n',
    'sub/.patslint': 'trailing-ws = off\n',
    'a.dats': 'val\tx = 1 \n', 'sub/b.dats': 'val\ty = 1 \n'}, ['a.dats', 'sub/b.dats'])
case('config_exclude', {
    '.patslint': 'exclude = gen/*\nexclude = *_gen.hats\n',
    'a.dats': 'val\tx = 1\n', 'gen/b.dats': 'val\ty = 1\n',
    'sub/c_gen.hats': 'val\tz = 1\n'}, ['a.dats', 'gen/b.dats', 'sub/c_gen.hats'])
case('config_cmdline_wins', {
    '.patslint': 'tab = off\nmax-col = 10\n',
    'a.dats': 'val\tx = 1 + 2 + 3\n'}, ['--enable=tab', '--max-col=100', 'a.dats'])
case('config_errors', {
    '.patslint': 'max-col 80\nmax-col = 0\nnope = on\ntab = loud\n',
    'a.dats': 'val\tx = 1\n', 'b.dats': 'val\ty = 1\n'}, ['a.dats', 'b.dats'])

#
# --fix
#
case('fix_all', {'a.dats':
    b'\tval x = 1 \r\n  \tval s = "a\tb  \nc"\r\nval\ty = 2\t\n\n \n'},
    ['--fix', 'a.dats'], show=['a.dats'])
case('fix_final_newline', {'a.dats': b'val x = 1\nval y = 2'}, ['--fix', 'a.dats'], show=['a.dats'])
case('fix_nothing', {'a.dats': b'val x = 1\n'}, ['--fix', 'a.dats'], show=['a.dats'])
case('fix_disabled', {'a.dats': b'val x = 1 \nval y = 2 // lint: disable=trailing-ws \n'},
    ['--fix', '--disable=final-newline', 'a.dats'], show=['a.dats'])
case('fix_lines', {'a.dats': b'val x = 1 \nval y = 2 \nval z = 3 \n'},
    ['--fix', '--lines=2', 'a.dats'], show=['a.dats'])

#
# patslint-diff (the changed lines of a git repository)
#
case('diff_changed_lines', {
    'x.dats': 'val a = 1 \nval b = 2\nval c = 3\n',
    'y z.sats': 'val q = 1\n',
    'notats.txt': 'text \n'},
    ['DIFF', 'HEAD'], git=True, after={
    'x.dats': 'val a = 1 \nval b = 2  \nval c = 3\nval\td = 4\n',
    'y z.sats': 'val q = 1\nval\tr = 2\n',
    'new.dats': 'val n = 1 \n',
    'notats.txt': 'more text \n'})
case('diff_options', {'x.dats': 'val a = 1\n'},
    ['DIFF', 'HEAD', '--disable=tab', '--format=json'], git=True, after={
    'x.dats': 'val a = 1\nval\tb = 2 \n'})
case('diff_clean', {'x.dats': 'val a = 1 \n'}, ['DIFF', 'HEAD'], git=True, after={})

#
# the running of a case
#

def write_files(d, files):
    for path, data in files.items():
        if isinstance(data, str):
            data = data.encode('utf-8')
        full = os.path.join(d, path)
        os.makedirs(os.path.dirname(full), exist_ok=True)
        with open(full, 'wb') as f:
            f.write(data)

def escape_line(line):
    out = []
    for b in line:
        c = chr(b)
        if c == '\\':
            out.append('\\\\')
        elif 32 <= b < 127:
            out.append(c)
        elif c == '\t':
            out.append('\\t')
        elif c == '\r':
            out.append('\\r')
        else:
            out.append('\\x%02x' % b)
    return ''.join(out)

def show_bytes(data):
    lines = data.split(b'\n')
    res = []
    for i, line in enumerate(lines):
        last = i == len(lines) - 1
        if last and line == b'':
            break
        res.append('| ' + escape_line(line) + ('' if last else '$'))
    if not data.endswith(b'\n'):
        res.append('(no newline at the end)')
    return res

def git(d, *args):
    env = dict(os.environ, GIT_AUTHOR_NAME='t', GIT_AUTHOR_EMAIL='t@t',
               GIT_COMMITTER_NAME='t', GIT_COMMITTER_EMAIL='t@t',
               GIT_CONFIG_NOSYSTEM='1', HOME=d)
    subprocess.run(['git'] + list(args), cwd=d, env=env, check=True,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def run_case(c, patslint, pdiff):
    name, files, argv, opts = c
    with tempfile.TemporaryDirectory(prefix='patslint-') as d:
        write_files(d, files)
        env = dict(os.environ, LC_ALL='C')
        for k, v in opts.get('env', {}).items():
            if v is None:
                env.pop(k, None)
            else:
                env[k] = v
        if opts.get('git'):
            git(d, 'init', '-q')
            git(d, 'add', '-A')
            git(d, 'commit', '-q', '-m', 'init')
            write_files(d, opts.get('after', {}))
            git(d, 'add', '-A')
        if argv and argv[0] == 'DIFF':
            cmd = [pdiff] + argv[1:]
            env['PATSLINT'] = patslint
            env['HOME'] = d
            env['GIT_CONFIG_NOSYSTEM'] = '1'
            shown = 'patslint-diff ' + ' '.join(argv[1:])
        else:
            cmd = [patslint] + argv
            shown = 'patslint ' + ' '.join(argv)
        p = subprocess.run(cmd, cwd=d, env=env, stdout=subprocess.PIPE,
                           stderr=subprocess.PIPE)
        out = ['$ ' + shown.rstrip()]
        if opts.get('escape'):
            for line in p.stdout.split(b'\n')[:-1]:
                # the spaces at the end are escaped too (no tool strips them)
                core = line.rstrip(b' ')
                out.append(escape_line(core) + '\\x20' * (len(line) - len(core)))
        else:
            for line in p.stdout.decode('utf-8', 'replace').splitlines():
                out.append(line.replace(d, '@TMP@'))
        for line in p.stderr.decode('utf-8', 'replace').splitlines():
            out.append(('stderr: ' + line.replace(d, '@TMP@')).rstrip())
        out.append('exit: %d' % p.returncode)
        for path in opts.get('show', []):
            out.append('--- ' + path)
            with open(os.path.join(d, path), 'rb') as f:
                out.extend(show_bytes(f.read()))
            if os.path.exists(os.path.join(d, path + '.patslint-fix')):
                out.append('(the file ' + path + '.patslint-fix is left)')
        return '\n'.join(out) + '\n'

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('mode', choices=['run', 'update'])
    ap.add_argument('--patslint', required=True)
    ap.add_argument('--diff', required=True)
    ap.add_argument('names', nargs='*')
    a = ap.parse_args()
    patslint = os.path.abspath(a.patslint)
    pdiff = os.path.abspath(a.diff)
    names = set(a.names)
    seen = set()
    nfail = 0
    nrun = 0
    for c in CASES:
        name = c[0]
        assert name not in seen, name
        seen.add(name)
        if names and name not in names:
            continue
        nrun += 1
        got = run_case(c, patslint, pdiff)
        path = os.path.join(EXPECTED, name + '.out')
        if a.mode == 'update':
            os.makedirs(EXPECTED, exist_ok=True)
            with open(path, 'w') as f:
                f.write(got)
            continue
        try:
            with open(path) as f:
                exp = f.read()
        except FileNotFoundError:
            exp = ''
        if got != exp:
            nfail += 1
            print('FAIL: ' + name)
            sys.stdout.writelines(difflib.unified_diff(
                exp.splitlines(True), got.splitlines(True),
                'expected/' + name + '.out', 'got'))
    if a.mode == 'update':
        print('patslint suite: wrote %d expected outputs' % nrun)
        return 0
    print('patslint suite: %d cases, %d failed' % (nrun, nfail))
    return 1 if nfail else 0

if __name__ == '__main__':
    sys.exit(main())
