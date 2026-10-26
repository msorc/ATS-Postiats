#!/usr/bin/env python3
#
# suite.py: the md5 suite of libatsynmark and pats2xhtml (utils/libatsynmark/TEST)
#
#   suite.py run    --p2x PATS2XHTML --api TEST03 --test01 TEST01 --test02 TEST02
#   suite.py update --p2x REF_PATS2XHTML --api REF_TEST03 --test01 REF_TEST01 --test02 REF_TEST02
#
# [run] runs every case (make_cases) and compares the md5 of its result (status,
# stdout, stderr without the uncaught-exception line, and the files that it writes; the path of the
# temporary directory is replaced by @W@) with the line of
# expected.md5: it prints the cases that differ and exits with status 1 if there is one.
# The inputs are the files of cases/ and the edge cases that [gen_edge] writes (empty and
# unterminated comments, strings and chars, every kind of number, directives, extern code,
# unicode, CRLF, very long lines, ...), in a temporary directory: the suite runs in any
# directory, in any locale, and needs no ATS1.
#
# [update] writes expected.md5 (a line '-' is a dropped case) from the ATS1 build of the same programs
# (the ATS1 versions of libatsynmark and pats2xhtml; api1.dats and the ATS1 test01/test02 are
# the programs test03/test01/test02 of this directory in ATS1 syntax: see PORTING.md,
# "pats2xhtml and libatsynmark"); a case that the ATS1 program cannot complete
# (a match failure of charlst_declitemize when two declarations are on one line) is dropped.
#
# HX-2026-10
#
# The 96 [api] cases of the inputs with non-ASCII bytes (the string API of
# test03: tok1, psm, lvl1s, html, proc1-3) are recorded from ATS2: the string
# reader of the compiler (src/pats_reader.dats) sign-extended a byte, so that
# ATS1 (and ATS2 before the fix) stopped at the first byte >= 128; the string
# API now gives what the FILE and char-list APIs give.
#
import sys, os, json, subprocess, hashlib, shutil, tempfile, re

HERE = os.path.dirname(os.path.abspath(__file__))

def gen_edge(d):
    os.makedirs(d, exist_ok=True)
    C = {}
    def add(name, data):
        if isinstance(data, str): data = data.encode('utf-8')
        C[name] = data
    add('empty.dats', b'')
    add('nl.dats', b'\n')
    add('spaces.dats', b'   \n\t\n  \n')
    add('nonl.dats', b'val x = 1')
    add('onechar.dats', b'x')
    # comments
    add('cmt_line.dats', '// a line comment\nval x = 1 // trailing\n// last without newline')
    add('cmt_block.dats', '(* block *) val x = (* inner *) 1\n(* multi\nline\n   comment *)\nval y = 2\n')
    add('cmt_nested.dats', '(* a (* b (* c *) b *) a *) val x = 1\n(* (*) *) val y = 2\n(*) not a comment? *)\n')
    add('cmt_unterminated.dats', 'val x = 1\n(* never closed\nval y = 2\n')
    add('cmt_unterminated2.dats', 'val x = 1 (* (* nested open *) val y = 2\n')
    add('cmt_rest.dats', 'val x = 1\n////\nthis is the rest of the file\nval y = (* not parsed *) 2\n')
    add('cmt_rest_mid.dats', 'val x = 1 //// rest\nval y = 2\n')
    add('cmt_c.dats', '/* c comment */ val x = 1\n/* unterminated')
    add('cmt_in_string.dats', 'val s = "(* not a comment *)" val t = "// nor this"\n')
    add('cmt_star.dats', '(**)\n(***)\n(* * *)\n(*)\n*)\n')
    # strings and chars
    add('str_basic.dats', 'val s = "hello" val t = "" val u = "a b"\n')
    add('str_escapes.dats', r'val s = "a\nb\tc\\d\"e\x41f\101g\0h\a\b\f\r\v\'"' + '\n')
    add('str_unterminated.dats', 'val s = "no end\nval t = 1\n')
    add('str_unterminated_eof.dats', 'val s = "no end')
    add('str_cont.dats', 'val s = "line one \\\n  continued" val t = 1\n')
    add('str_long.dats', 'val s = "' + 'x' * 5000 + '"\n')
    add('str_html.dats', 'val s = "<b>&amp; \'quoted\' </b>" // <tag> & stuff\n')
    add('chr_basic.dats', "val c = 'a' val d = '\\n' val e = '\\\\' val f = '\\'' val g = '\\x41' val h = '\\101' val i = ' '\n")
    add('chr_bad.dats', "val c = 'ab' val d = ''' val e = 'x\n")
    add('chr_eof.dats', "val c = '")
    add('chr_brace.dats', "val a = '{' val b = '}' val c = '(' val d = ')' val e = '[' val f = ']' val g = '\\{' val h = '\\}'\n")
    # numbers
    add('num_int.dats', 'val a = 0 val b = 123 val c = 0x1F val d = 0XaB val e = 017 val f = 123L val g = 123u val h = 123UL val i = 0xFFul val j = 0b101\n')
    add('num_int2.dats', 'val a = 1_000 val b = 12abc val c = 0x val d = 08 val e = 99999999999999999999999 val f = ~1 val g = ~0x10\n')
    add('num_float.dats', 'val a = 1.5 val b = 1e10 val c = 1.5e-3 val d = .5 val e = 5. val f = 0x1.8p3 val g = 1.5f val h = 1.5l val i = 1E+9 val j = 1.e2 val k = 0.0\n')
    add('num_float2.dats', 'val a = 1.5.2 val b = 1e val c = 1e+ val d = 1.f val e = 3.14159265358979323846264338327950288\n')
    add('num_dotint.dats', 'val a = x.0 val b = x.1 val c = x.12 val d = 1.2.3\n')
    # directives
    add('dir_define.dats', '#define N 10\n#define F(x) (x + 1)\n#undef N\nval x = N\n')
    add('dir_include.dats', '#include "share/atspre_staload.hats"\n#include "nonexistent_file.hats"\nval x = 1\n')
    add('dir_if.dats', '#if defined(A) && (B > 1)\nval x = 1\n#elif C\nval y = 2\n#else\nval z = 3\n#endif\n#ifdef Q\nval a = 1\n#endif\n#ifndef R\nval b = 2\n#endif\n')
    add('dir_if_unbal.dats', '#if A\nval x = 1\n#else\nval y = 2\n')
    add('dir_misc.dats', '#print "hello"\n#error "boom"\n#assert (1 > 0)\n#then val x = 1\n#staload "x.sats"\n#dynload "y.dats"\n#pragma foo\n#codegen2 (a, b)\n')
    add('dir_hash_bad.dats', '#\n# \n#123\n#foo\n#[x]\n')
    add('dir_stringify.dats', '#define S(x) #x\n#define CAT(x,y) x ## y\nval a = S(abc)\n')
    add('dir_filename.dats', 'val f = $FILENAME val l = $LOCATION val g = #FILENAME val h = #LOCATION\n')
    # external code
    add('ext_block.dats', '%{^\n#include <stdio.h>\nstatic int f(int x) { return x + 1; }\n%}\nval x = 1\n%{$\nint g(void) { return 0; }\n%}\n%{#\nint h;\n%}\n%{\nint k;\n%}\n')
    add('ext_block_unterminated.dats', 'val x = 1\n%{^\nint f(void) { return 0; }\n')
    add('ext_block_nested.dats', '%{^\n%{ inside %} not closed yet\n%}\nval x = 1\n')
    add('ext_block_str.dats', '%{^\nconst char *s = "%}";\n%}\nval y = 2\n')
    add('ext_percent.dats', 'val a = 5 % 3 val b = %(x) val c = %( val d = 1\n')
    add('ext_extern.dats', 'extern fun f (x: int): int = "mac#f"\nextern val v: int = "ext#v"\nextern castfn g (x: int): ptr\n$extern("name", 1)\nval a = $extval(int, "x")\nval b = $extfcall(int, "f", 1, 2)\nval c = $extmcall(int, obj, "m", 1)\ntypedef T = $extype "T"\ntypedef U = $extype_struct "U" of { x= int, y= int }\nvtypedef V = $extkind "atstype_int"\n')
    add('ext_dlr.dats', 'val a = $arrpsz{int}(1, 2, 3) val b = $arrpsz(1) val c = $lst(1, 2) val d = $list{int}(1, 2) val e = $tup(1, 2) val f = $rec{x=1} val g = $delay(1) val h = $ldelay(2) val i = $raise Exn val j = $effmask_all(f()) val k = $showtype x val l = $tempenver(x)\n')
    # unicode / bytes
    add('uni_comment.dats', '(* \u00e9\u00e8 \u4e2d\u6587 \U0001F600 *) val x = 1 // \u00fc\nval y = 2\n')
    add('uni_string.dats', 'val s = "\u00e9\u4e2d\u6587\U0001F600" val t = "\u00fc"\nval u = 3\n')
    add('uni_ident.dats', 'val \u00e9 = 1\nval x = 2\n')
    add('uni_first.dats', '\u00e9 val x = 1\n')
    add('uni_char.dats', "val c = '\u00e9' val d = 1\n")
    add('bytes_high.dats', b'val x = 1 \xff\xfe\x80\x81 val y = 2\n')
    add('bytes_invalid_utf8.dats', b'(* \xc3\x28 \xa0\xa1 *) val x = "\xe2\x28\xa1" val y = 2\n')
    add('bytes_nul_str.dats', b'val s = "a\x00b" val t = 1\n')
    add('bytes_ctrl.dats', b'val x = 1\x01\x02\x03\x07\x08\x0b\x0c\x1b\x7f val y = 2\n')
    add('bytes_all.dats', bytes(range(1, 256)))
    add('bytes_all_cmt.dats', b'(*' + bytes(range(1, 256)) + b'*) val x = 1\n')
    add('bytes_all_str.dats', b'val s = "' + bytes(c for c in range(1, 256) if c not in (0x22, 0x5c, 10, 13)) + b'"\n')
    # whitespace
    add('crlf.dats', 'val x = 1\r\nval y = (* c\r\n*) 2\r\n// line\r\nval z = "s"\r\n')
    add('cr_only.dats', 'val x = 1\rval y = 2\r// c\rval z = 3\r')
    add('tabs_ff.dats', 'val\tx\t=\t1\n\x0cval y = 2\n\x0b\n')
    add('mixed_nl.dats', 'val x = 1\r\nval y = 2\nval z = 3\r\n(* a\n b\r\n c *)\n')
    add('bom.dats', b'\xef\xbb\xbfval x = 1\n')
    # long lines
    add('long_line.dats', 'val x = ' + ' + '.join(['1'] * 20000) + '\n')
    add('long_ident.dats', 'val ' + 'a' * 100000 + ' = 1\n')
    add('long_cmt.dats', '(* ' + 'z' * 200000 + ' *)\nval x = 1\n')
    add('long_nested.dats', '(*' * 3000 + '*)' * 3000 + '\nval x = 1\n')
    add('long_parens.dats', 'val x = ' + '(' * 3000 + '1' + ')' * 3000 + '\n')
    add('long_list.dats', 'val x = @(' + ', '.join(str(i) for i in range(20000)) + ')\n')
    add('many_lines.dats', ''.join('val x%d = %d\n' % (i, i) for i in range(20000)))
    add('deep_expr.dats', 'val x = ' + 'f(' * 1000 + '1' + ')' * 1000 + '\n')
    # declarations
    add('decl_sta.sats', '''stadef f = g
    sortdef nat = {a: int | a >= 0}
    datasort mylist = nil | cons of (int, mylist)
    abstype T
    abstype T2 = ptr
    absvtype V(a: t@ype)
    abstflt F
    absprop P(n: int)
    absview W(l: addr)
    typedef t = int
    typedef t2 (a: t@ype) = List(a)
    vtypedef vt = [n: nat] list_vt(int, n)
    propdef pd = P(1)
    viewdef vd = W(null)
    dataprop DP(int) = DPnil(0) | {n: nat} DPcons(n+1) of DP(n)
    dataview DV(addr) = DVnil(null) | {l: addr} DVcons(l) of DV(l)
    datatype list0(a: t@ype) = nil0 | cons0 of (a, list0(a))
    dataviewtype dvt = A | B of (int)
    datavtype dvt2 = C | D of (int, dvt2)
    stacst foo: (int, int) -> int
    extern fun f {n: nat} (x: int(n)): int(n+1)
    exception MyExn of (int, string)
    assume T = int
    symintr +
    symelim -
    overload + with add_int_int of 10
    overload print with print_int
    infixl + -
    infixr ::
    prefix ~
    postfix !
    nonfix foo
    staload "a.sats"
    staload X = "x.sats"
    staload _ = "y.dats"
    dynload "z.dats"
    #staload "w.sats"
    ''')
    add('decl_dyn.dats', '''fun f (x: int): int = x + 1
    fn g (x: int): int = x
    fnx h (x: int): int = x
    and k (x: int): int = h x
    prfun p {n: nat} (x: int(n)): void = ()
    prfn p2 () : void = ()
    praxi ax () : void
    castfn cf (x: int): ptr
    val x = 1
    val (a, b) = (1, 2)
    val+ y = 3
    val- z = 4
    prval pf = foo
    var v: int = 3
    var w = 4
    implement main0 () = ()
    implement{a} foo<a> (x) = x
    implement (a:t@ype) bar (x) = x
    primplement pm () = ()
    macdef m = 1
    macrodef mm (x) = x
    local
    val a = 1
    in
    val b = a
    end
    extern fun {a:t@ype} ff (x: a): a
    extern praxi pa () : void
    and gg () = 1
    #define X 1
    ''')
    add('expr_all.dats', '''val a = if x then 1 else 2
    val b = if x then 1
    val c = case x of 1 => 2 | _ => 3
    val d = case+ x of 1 => 2 | _ => 3
    val e = case- x of 1 => 2
    val f = let val x = 1 in x end
    val g = x where { val y = 1 }
    val h = lam (x: int): int => x
    val i = llam (x: int) => x
    val j = fix f (x: int): int => f x
    val k = fix@ f (x: int): int => f x
    val l = lam@ (x: int) => x
    val m = (1, 2, 3)
    val n = @(1, 2)
    val o = '(1, 2)
    val p = @{x=1, y=2}
    val q = '{x=1, y=2}
    val r = $tup(1, 2)
    val s = x.y
    val t = x[1]
    val u = x->y
    val v = !p
    val w = &x
    val x1 = @[int][3](1, 2, 3)
    val y1 = @[int](1)
    val z1 = (x: int)
    val a2 = try f() with | ~Exn () => 0
    val b2 = while x do y
    val c2 = for i => 1 to 2 do y
    val d2 = begin 1 end
    val e2 = ()
    val f2 = foo<int>(1)
    val g2 = foo<>(1)
    val h2 = x := 1
    val i2 = x <- 1
    val j2 = x >< y
    val k2 = sif x then 1 else 2
    val l2 = scase x of 1 => 2
    val m2 = ifcase | x => 1 | _ => 2
    val n2 = $effmask_all(x)
    val o2 = fold@ x
    val p2 = free@ x
    val q2 = view@ x
    val r2 = addr@ x
    val s2 = ref@ x
    val t2 = x.y.z
    val u2 = x.0
    val v2 = (x; y; z)
    val w2 = @(x | y)
    val x3 = (x | y)
    val y3 = _
    val z3 = ?
    val a4 = ~1
    val b4 = #[x]
    ''')
    add('pat_all.dats', '''fun f (x: int, (a, b): (int, int), @(c, d): @(int, int), '(e, f): '(int, int), g as h, ~i, @{x=j, y=k}, '{x=l, y=m}, [n:nat] o, !p, (q: int), _) = 1
    fun g (xs: list(int)): int = case xs of | list_nil () => 0 | list_cons (x, xs) => 1 | @list_cons (a, !b) => 2 | ~list_nil () => 3 | _ when x > 0 => 4
    fun h {n:nat} .<n>. (x: int(n)): int = 1
    fun i {n:nat} (x: int(n)): [m:nat | m > n] int(m) = 1
    fun j (pf: foo | x: int): (bar | int) = 1
    fun k (x: int) :<fun,!ref> int = 1
    fun l (x: int) :<> int = 1
    fun m (x: &int >> int, y: !list_vt(int) >> _, z: &(@[int][3]) >> _) : void = ()
    fun n (x: int, y: int) : (int, int) = @(x, y)
    fun o {a:t@ype} (x: a): a = x
    fun p {a:vt@ype} {n:int | n >= 0} (x: a): a = x
    fun q (x: ~int, y: ?int, z: int?, w: int!, v: !int) = 1
    ''')
    add('typ_all.sats', '''typedef a1 = int
    typedef a2 = (int, int)
    typedef a3 = @(int, int)
    typedef a4 = '(int, int)
    typedef a5 = @{x= int, y= int}
    typedef a6 = '{x= int, y= int}
    typedef a7 = int -> int
    typedef a8 = (int) -<cloref1> int
    typedef a9 = (int) -<lin,prf> void
    typedef b1 = [a:type] a
    typedef b2 = {a:type} a
    typedef b3 = [n:nat | n > 0] int(n)
    typedef b4 = lam (x: int) => x
    typedef b5 = @[int][3]
    typedef b6 = @[int]
    typedef b7 = (int | int)
    typedef b8 = &int
    typedef b9 = int?
    typedef c1 = int!
    typedef c2 = ~int
    typedef c3 = $extype "x"
    typedef c4 = list(int)
    typedef c5 = foo(1, 2; 3)
    typedef c6 = a + b * c
    typedef c7 = ?a
    typedef c8 = [a:type | a == b] a
    typedef c9 = (int, int) -> (int)
    ''')
    add('err_misc.dats', 'val = 1\nfun (x) = 2\nval x : = 3\nimplement\nend end end\n) ) )\n} } }\n] ] ]\nval y = (\nval z = [\nval w = {\n')
    add('err_eof.dats', 'fun f (x: int): int =')
    add('err_eof2.dats', 'implement')
    add('err_eof3.dats', 'val x = (1,')
    add('err_keywords.dats', 'val val val fun fun fun in in in then then else else of of and and with with when when\n')
    add('err_tokens.dats', '@ \\ ! | ` : :< $ . .. ... = => =< =<> =/=> => >> = < > >< .< >. .<>. -> -< -<> ~ # ? ,  ; \n')
    add('err_opers.dats', 'val a = 1 +++ 2 val b = 1 ==> 2 val c = <> val d = >=< val e = ^ ** %% && || !! ?? ~~ \n')
    add('kw_all.dats', 'abstype abst0ype absprop absview absvtype absviewtype absvt0ype absviewt0ype and as assume begin break continue case case+ case- classdec datasort datatype dataprop dataview dataviewtype datavtype do dynload else end exception extern fix fix@ fn fnx for for* fun implement implmnt infix infixl infixr lam lam@ llam llam@ let local macdef macrodef nonfix overload of op prfn prfun primplement primplmnt prval prvar praxi propdef rec require scase sif sortdef sta stacst stadef staload staloadnm stavar symelim symintr then try type type+ type- t@ype t@ype+ t@ype- viewdef viewtype viewtype+ viewtype- viewt@ype viewt@ype+ viewt@ype- val val+ val- var when where while while* with withtype withprop withview withviewtype\n')
    add('kw_dlr.dats', '$arrpsz $arrptrsize $delay $ldelay $effmask $effmask_ntm $effmask_exn $effmask_ref $effmask_wrt $effmask_all $extern $extkind $extype $extype_struct $extval $extfcall $extmcall $lst $lst_t $lst_vt $list $list_t $list_vt $rec $rec_t $rec_vt $record $record_t $record_vt $tup $tup_t $tup_vt $tuple $tuple_t $tuple_vt $raise $showtype $vcopyenv_v $vcopyenv_vt $tempenver $solver_assert $solver_verify $myfilename $mylocation $myfunction $foo $bar_baz\n')
    add('kw_misc.dats', 'addr@ fold@ free@ view@ ref@ @( @[ @{ \'( \'[ \'{ #[ ,( %( `( .<>. <> :< ?! @ fun@ lam@ fix@\n')
    add('ident_sym.dats', 'val a = x + y val b = x +* y val c = x <=> y val d = x ::: y val e = ## val f = $+ val g = a_b_1 val h = a\'b val i = a$b val j = _a val k = A1 val l = x? val m = x! val n = x_\n')
    add('ident_arr.dats', 'val a = x[1] val b = x[ ] val c = x[1][2] val d = arr.[i] val e = x.[1]\n')
    add('ident_tmp.dats', 'val a = f<int> val b = f<int,bool> val c = f<> val d = f<a<b>> val e = x < y > z val f = f<1> val g = f<(1, 2)>\n')
    add('ident_qual.dats', 'val a = $M.x val b = M.x val c = $M.N.x val d = $M.f<int> val e = $M. val f = $M.1\n')
    add('lab_all.dats', 'val a = x.name val b = x.0 val c = x.1.2 val d = x. val e = x.. val f = x...\n')
    add('lone_op.dats', '+\n')
    add('only_lparen.dats', '(')
    add('only_quote.dats', "'")
    add('only_dquote.dats', '"')
    add('only_pct.dats', '%')
    add('only_hash.dats', '#')
    add('only_slash.dats', '/')
    add('only_dollar.dats', '$')
    add('only_cmt_open.dats', '(*')
    add('only_ext_open.dats', '%{')
    add('only_ext_open2.dats', '%{^')
    add('only_slash_slash.dats', '//')
    add('only_four_slash.dats', '////')
    add('only_dot.dats', '.')
    add('only_backslash.dats', '\\')
    add('only_tilde.dats', '~')
    add('only_at.dats', '@')
    add('guard_decl.dats', '#if A\nfun f () = 1\n#else\nfun g () = 2\n#endif\nval x = 1\n#ifdef B\n#if C\nval y = 1\n#endif\n#endif\n')
    add('guard_dyn.sats', '#if X\nfun f (): int\n#elif Y\nfun g (): int\n#else\nfun h (): int\n#endif\n')
    add('local_nest.dats', 'local local val a = 1 in val b = a end in val c = b end\n')
    add('sats_as_dats.dats', 'fun f (x: int): int\nfun g (x: int): int\nval v: int\n')
    add('dats_as_sats.sats', 'implement main0 () = println! ("hello")\nval x = 1\n')
    add('hats.hats', '#define A 1\n#ifndef X_HATS\n#define X_HATS\n#endif\nmacdef f (x) = ,(x)\n')
    add('macro_syn.dats', 'macdef f (x) = ,(x) macdef g = `(1 + ,(x)) macdef h (x) = %(x) val a = ,(1) val b = `(f) val c = ,(b)\n')
    add('prfexp.dats', 'val (pf | x) = f() val _ = g(pf | x) fun f (pf: p | x: int): (q | int) = (pf | x) prval pf2 = f(pf) prfun p () = () fun h (x: int, pf: p) = 1 val t = @(pf | x, y | z)\n')
    add('stalab.dats', 'typedef t = @{a= int, b= (int, int)} val x = @{a= 1, b= @(1, 2)} val y = x.a val z = $rec{a= 1} typedef u = $record{a= int}\n')
    add('dynlab.dats', 'val a = @{x= 1, y= 2} val b = @{x= 1, ...} fun f (@{x= a, ...}) = a val c = '+"'"+'{x= 1, y= 2}\n')
    add('tmpid.dats', 'val a = f<int>(1) val b = g<a,b><c>(1) val c = x.foo<int>(1) val d = h<(int)>(1)\n')
    add('exdec.dats', 'exception E1\nexception E2 of int\nexception E3 of (int, int)\nexception {a:type} E4 of (a)\n')
    add('datdec.dats', 'datatype d = A | B of int | C of (int, d) | {a:type} D of (a) | [n:nat] E(n) of (int(n)) | F(1)\nand e = G\nwithtype t = int\ndatavtype dv (a:t@ype) = DV1 | DV2 of (a, dv(a)) withtype dvt = int\n')
    add('absimpl.dats', 'abstype t\nabstype t2 = int\nabsvtype t3 = ptr\nabstflt t4\nabsview v\nassume t = int\nassume t2 = (int, int)\nreassume t\n')
    add('fixities.dats', 'infix 60 +++\ninfixl 50 ---\ninfixr 40 ===\nprefix 70 ~~~\npostfix 80 !!!\ninfix (+) ---\nnonfix +++\nsymintr foo bar\nsymelim foo\noverload foo with bar of 5\noverload + with (add) of 10\noverload .x with y\n')
    add('whitespace_odd.dats', 'val\n\n\nx\n\n=\n\n1\n\n\n\n')
    add('same_line_many.dats', 'val a=1 val b=2 val c=3 val d=4 val e=5 val f=6 val g=7 val h=8 val i=9 val j=10\n')
    add('str_in_dyn.dats', 'val a = "x" val b = "y\\n" val c = "z" + "w" val d = print("hello") val e = $extfcall(void, "puts", "hello")\n')
    add('char_in_dyn.dats', "val a = 'x' val b = '\\0' val c = f('y') val d = (c = 'a')\n")
    add('cdata.dats', 'val x = "abc" val y = $arrpsz{char}(\'a\')\n')
    add('ints_ops.dats', 'val a = 1 + 2 * 3 - 4 / 5 % 6 val b = 1 << 2 >> 3 val c = 1 land 2 lor 3 lxor 4 val d = 1 <= 2 val e = 1 >= 2 val f = 1 != 2 val g = 1 <> 2 val h = ~1 val i = 1 == 2 val j = 1 =/= 2\n')
    add('x_sv_all.dats', 'implement {...} f (x) = x\n')
    add('x_a0msrt.dats', 'datatype d (n: int, m: int) = A of (int) | B(1, 2)\n')
    add('x_e0xp.dats', '#define A 1\n#define B(x) x\n#if (A) #then #endif\n')
    add('x_eff1.dats', 'val a = $effmask {ntm} (f ())\n')
    add('x_eff2.dats', 'val a = $effmask {ntm, exn} f()\n')
    add('x_eff3.dats', 'val a = $effmask {!ntm, !exn} (f ())\n')
    add('x_eff4.dats', 'val a = $effmask {all} (f ())\n')
    add('x_eff5.dats', 'val a = $effmask_ntm (f ())\n')
    add('x_eff6.dats', 'val a = $effmask_all (f ())\n$effmask_ref (g ())\n')
    add('x_guard1.dats', '#if (A) #then\nval x = 1\n#else\nval y = 2\n#endif\n')
    add('x_guard2.dats', '#if A #then val a = 1 #elif B #then val b = 2 #else val c = 3 #endif\n')
    add('x_guard3.dats', '#ifdef A #then\nval a = 1\n#endif\n#ifndef B #then\nval b = 2\n#endif\n')
    add('x_guard4.dats', '#if 1 #then\n#if 2 #then\nval a = 1\n#else\nval b = 2\n#endif\n#endif\nval x = 3\n')
    add('x_guard5.dats', '#if (A) #then\nfun f (): int\n#elifdef B #then\nfun g (): int\n#elifndef C #then\nfun h(): int\n#endif\n')
    add('x_mac1.dats', 'macdef f {a:t@ype} (x: a) = ,(x)\n')
    add('x_mac2.dats', 'macdef f {a} (x) = x\n')
    add('x_mac3.dats', 'macdef f (x) = x\nmacdef g = lam (x) => x\n')
    add('x_mac4.dats', 'macrodef f {a:t@ype} (x) = x\n')
    add('x_perr1.dats', 'val ) = 1\n')
    add('x_perr10.dats', 'implement f (1 2) = 1\n')
    add('x_perr11.dats', "val '( = 1\n")
    add('x_perr12.dats', 'val @( = 1\n')
    add('x_perr13.dats', 'fun f (x, , y) = 1\nval z = 2\n')
    add('x_perr14.dats', 'val x = \n')
    add('x_perr2.dats', 'val (x, ) = 1\n')
    add('x_perr3.dats', 'fun f (, x) = 1\n')
    add('x_perr4.dats', 'val x : = 1\n')
    add('x_perr5.dats', 'val (1 + ) = 2\n')
    add('x_perr6.dats', 'fun f (x:) = 1\n')
    add('x_perr7.dats', 'val () = case x of | ( => 1\n')
    add('x_perr8.dats', 'fun f ({ x) = 1\n')
    add('x_perr9.dats', 'val a = (x |) \n')
    add('x_rec1.dats', 'val @{ a= x | b= y } = r\n')
    add('x_rec2.dats', 'fun f (@{ pf= p | x= y }) = 1\n')
    add('x_rec3.dats', 'val r = @{ pf= p | x= 1 }\n')
    add('x_rec4.dats', 'val r = $rec{ a= 1 | b= 2 }\n')
    add('x_rec5.dats', 'val r = $record{ a= 1 | b= 2 }\n')
    add('x_rec6.dats', "val r = '{ a= 1 | b= 2 }\n")
    add('x_rec7.dats', 'typedef t = @{ a= int | b= int }\n')
    add('x_rec8.dats', "val '{ a= x | b= y } = r\n")
    add('x_srt1.dats', 'sortdef t = int\nstacst c: t\nabstype a(t)\n')
    add('x_sv1.dats', 'implement {...} f<...> (x) = x\n')
    add('x_sv10.dats', 'implement f {...} (x) = x\n')
    add('x_sv11.dats', 'implement f{a}{...}() = 1\n')
    add('x_sv12.dats', 'implement f<a><..>() = 1\n')
    add('x_sv13.dats', 'val x = foo<..>(1)\n')
    add('x_sv14.dats', 'val x = foo{..}(1)\n')
    add('x_sv2.dats', 'implement {a,...} f<a> (x) = x\n')
    add('x_sv3.dats', 'fun f {..} (x: int) = x\n')
    add('x_sv4.dats', 'val x = f{...}(1)\n')
    add('x_sv5.dats', 'implement {..} f (x) = x\n')
    add('x_sv6.dats', 'fun {..} f (x: int) = x\n')
    add('x_sv7.dats', 'fun f {a:t@ype} {...} (x: a) = x\n')
    add('x_sv8.dats', 'val f = lam {..} (x: int) => x\n')
    add('x_sv9.dats', 'extern fun {...} f(): int\n')

    for k, v in C.items():
        open(os.path.join(d, k), 'wb').write(v)
    return sorted(C)

# the names of the symbols that d0eclreplst_find_synop looks for in a file
RX = re.compile(r"\b(?:fun|fn|val|typedef|datatype|datavtype|dataview|stadef|abstype|macdef|overload|exception|stacst|implement|prfun|extern)\s+(?:\{[^}]*\}\s*|\([^)]*\)\s*|<[^>]*>\s*)?(?:fun\s+|val\s+)?([A-Za-z_][A-Za-z0-9_']*)")

def names_of(path):
    s = open(path, 'r', encoding='latin-1').read()
    names = []
    for m in RX.finditer(s):
        if m.group(1) not in names: names.append(m.group(1))
        if len(names) >= 6: break
    return ' '.join(names + ['main0', 'nonexistent_name_xyz'])

def make_cases(work):
    files = sorted(f for f in os.listdir(work) if f.endswith(('.sats', '.dats', '.hats')))
    cs = []
    def add(kind, args, stdin=None, outs=False):
        cs.append({'k': kind, 'a': args, 'i': stdin, 'o': outs})
    for f in files:
        add('p2x', ['-d', f]); add('p2x', ['-s', f])
        add('p2x', ['--embedded', '-d', f]); add('p2x', ['--embedded', '-s', f])
        add('p2x', ['-d'], f); add('p2x', ['--embedded', '-s'], f)
        add('p2x', ['--embedded', '-o', 'out/x.html', '--dynamic', f], None, True)
        for c, sd in [('tok1', '1'), ('tok2', '1'), ('tok3', '1'), ('psm', '1'), ('lvl1s', '0'), ('lvl1s', '1'), ('lvl1c', '1'),
                      ('lvl1f', '0'), ('html', '0'), ('html', '1'), ('putc', '1'), ('proc1', '1'), ('proc2', '0'), ('proc3', '1')]:
            add('api', [c, sd, f])
        for sd in ('0', '1'):
            add('api', ['decl', sd, f, names_of(os.path.join(work, f))])
        add('tok', [], f); add('psm2', ['-d'], f); add('psm2', ['-s'], f)
    add('api', ['setcur', '1', files[0]]); add('api', ['setcur', '1', 'nonexistent_file.dats']); add('api', ['setcur', '0', 'sub/nonexistent_file.dats'])
    # the command line of pats2xhtml
    a, b, c, e = 'cmt_block.dats', 'decl_sta.sats', 'ext_block.dats', 'empty.dats'
    cli = [[], ['-h'], ['--help'], ['-h', '-d', a], ['-d', a, '-h'], ['--embedded'], ['--embedded', '-d'], ['-d'], ['-s'],
      ['-d', a, b, c], ['-s', b, '-d', a], ['-s', b, a, '-d', c, e, '--embedded'], ['--embedded', '-s', b, '-s', b],
      ['-d', a, '-d'], ['-d', a, '-s'], ['-s', '-d'], ['-d', '-s', b], ['-d', '-d', a], ['-d', e], ['-s', e],
      ['-d', 'nofile.dats'], ['-d', a, 'nofile.dats', b], ['--bogus', '-d', a], ['-x', '-d', a, '--embedded'], ['-', '-d', a],
      ['--', '-d', a], ['', '-d', a], ['-d', a, '--embedded', '--embedded'], ['--Embedded', '-d', a],
      ['-DATS', 'X=1', '-d', a], ['-DATSX=1', '-d', a], ['-DATS', 'X="s"', '-d', a], ['-DATS', 'X', '-d', a],
      ['-DATS', 'A=(', '-d', a], ['-DATS'], ['-d', a, '-DATS'], ['-DATSA=1', '-DATSB=2', '-d', a, '--embedded'],
      ['-IATS', '.', '-d', a], ['-IATS.', '-d', a], ['-IATS'], ['-IATS', '-d', a], ['-DAT', '-d', a], ['-IAT', '-d', a],
      ['-o'], ['--output'], ['-d', a, '-o'], ['-o', 'out/o1.html', '-d', a], ['--output', 'out/o1.html', '--embedded', '-d', a],
      ['-o', 'out/o1.html', '-d', a, '-o', 'out/o2.html', '-s', b], ['-d', a, '-o', 'out/o1.html', '-d', b],
      ['-o', 'out/o1.html', '-o', 'out/o2.html', '-d', a], ['-o', 'out/o1.html'], ['-o', 'nodir/o1.html', '-d', a],
      ['-o', 'nodir/o1.html', '-d', a, '-s', b, '--embedded'], ['-o', '/dev/null', '-d', a], ['-o', 'out/e.html', '-d', e],
      ['-o', 'out/e.html', '--embedded', '-d', 'err_misc.dats'], ['-o', 'out/e.html', '-d', 'err_misc.dats'],
      ['-s', 'err_misc.dats'], ['-d', 'err_eof.dats', '--embedded'], ['-d', 'cmt_unterminated.dats'], ['-d', 'str_unterminated.dats'],
      ['--static', a], ['--dynamic', a], ['--static', a, '--embedded'], ['--embedded', '--dynamic', b], ['-d', './' + a], ['-d', 'cases_nodir/' + a]]
    for argv in cli:
        add('p2x', argv, None, True)
    for argv in [['-d'], ['--embedded', '-d'], ['-s'], ['-o', 'out/o3.html', '-d'], ['--embedded']]:
        add('p2x', argv, c, True)
    return cs

def norm_err(b):
    s = b.decode('latin-1')
    s = re.sub(r'exit\(ATS\): uncaught exception: [^\n]*\n?', 'EXN\n', s)
    s = re.sub(r'exit\(ATS\): uncaught exception at run-time:\n[^\n]*\n?', 'EXN\n', s)
    return s

def run_case(case, work, exes):
    kind, args = case['k'], list(case['a'])
    exe = {'p2x': exes['p2x'], 'api': exes['api'], 'tok': exes['test01'], 'psm2': exes['test02']}[kind]
    out = os.path.join(work, 'out')
    shutil.rmtree(out, ignore_errors=True); os.makedirs(out)
    inp = open(os.path.join(work, case['i']), 'rb') if case['i'] else subprocess.DEVNULL
    env = {'PATH': '/usr/bin:/bin', 'LC_ALL': 'C'}
    p = subprocess.run([exe] + args, stdin=inp, stdout=subprocess.PIPE, stderr=subprocess.PIPE, cwd=work, env=env, timeout=120)
    if case['i']: inp.close()
    h = hashlib.md5()
    h.update(('rc=%d\n' % p.returncode).encode()); h.update(p.stdout.replace(work.encode(), b'@W@')); h.update(b'\n--stderr--\n'); h.update(norm_err(p.stderr).replace(work, '@W@').encode('latin-1'))
    for dp, dn, fn in sorted(os.walk(out)):
        for f in sorted(fn):
            h.update(('\n--file %s--\n' % os.path.relpath(os.path.join(dp, f), out)).encode()); h.update(open(os.path.join(dp, f), 'rb').read())
    return h.hexdigest(), p

def prepare(work):
    gen_edge(work)
    for f in sorted(os.listdir(os.path.join(HERE, 'cases'))):
        shutil.copy(os.path.join(HERE, 'cases', f), os.path.join(work, f))

def main():
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument('mode', choices=['run', 'update'])
    for o in ('p2x', 'api', 'test01', 'test02'): ap.add_argument('--' + o, required=True)
    ap.add_argument('--keep', action='store_true')
    a = ap.parse_args()
    exes = {k: os.path.abspath(getattr(a, k)) for k in ('p2x', 'api', 'test01', 'test02')}
    work = os.path.realpath(tempfile.mkdtemp(prefix='p2xsuite.'))
    try:
        prepare(work)
        cases = make_cases(work)
        if a.mode == 'update':
            sums = []
            for c in cases:
                md5, p = run_case(c, work, exes)
                if c['k'] == 'api' and c['a'][0] == 'decl' and b'match failure' in p.stderr:
                    md5 = '-'   # ATS1 aborts (two declarations on one line): not a case
                sums.append(md5)
            open(os.path.join(HERE, 'expected.md5'), 'w').write(''.join(x + '\n' for x in sums))
            print('wrote %d cases (%d dropped)' % (len(sums), sums.count('-'))); return 0
        want = [l.strip() for l in open(os.path.join(HERE, 'expected.md5'))]
        if len(cases) != len(want):
            print('expected.md5 has %d lines and there are %d cases: regenerate it (suite.py update)' % (len(want), len(cases)), file=sys.stderr)
            return 1
        nbad = 0; n = 0
        for c, w in zip(cases, want):
            if w == '-': continue
            n += 1
            md5, p = run_case(c, work, exes)
            if md5 != w:
                nbad += 1
                if nbad <= 20: print('DIFFERENT: %s %s' % (c['k'], ' '.join(c['a'])[:150]), file=sys.stderr)
        print('%d cases, %d different' % (n, nbad))
        return 1 if nbad else 0
    finally:
        if not a.keep: shutil.rmtree(work, ignore_errors=True)

if __name__ == '__main__':
    sys.exit(main())
