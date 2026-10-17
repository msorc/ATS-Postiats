#!/usr/bin/env python3
# usage: python3 e1xcorpus.py [SEED [N]]   >  corpus.txt
#
# The corpus of the differential test of the e1xp evaluator (e1xdump / e1xdump1): lines "TOPdyn<TAB>text"
# (\x01 is a newline in the text) of the directives #define/#undef/#if/#ifdef/#ifndef/#elif/#else/#print.
# Part 1 is written by hand (every branch of pats_e1xpval.dats), part 2 is random: N programs
# (default 3000) made of defines (constants, functions, shadowing, undef) and uses (#print, #if) over a
# grammar of expressions (the operators of the evaluator, mismatched types, unbound names,
# arities, deep recursion, ...). The operators are infix (the driver resolves them, see e1xdump.dats).
import random, sys

HAND = r'''
#define A 1\1#print A
#define A 1 + 2 * 3\1#print A\1#print (A - 1)
#define A 10 - 4 - 3\1#print A
#define A ~3\1#print A\1#print (~A)
#define A 7 / 2\1#print A\1#print (A * 2)
#define A 1.5\1#define B 2.25\1#print (A + B)\1#print (A - B)\1#print (A * B)\1#print (A / B)\1#print (~A)
#define A 1.5\1#print (A < 2.5)\1#print (A <= 1.5)\1#print (A > 2.5)\1#print (A >= 1.5)
#define A 1\1#define B 2\1#print (A < B)\1#print (A <= B)\1#print (A > B)\1#print (A >= B)\1#print (A == B)\1#print (A != B)\1#print (A <> B)\1#print (A = B)
#define S "abc"\1#define T "abd"\1#print (S + T)\1#print (S < T)\1#print (S <= T)\1#print (S > T)\1#print (S >= T)\1#print (S == T)\1#print (S != T)
#define S ""\1#define T "x"\1#print (S && T)\1#print (T && T)\1#print (S || T)\1#print (S || S)\1#print (T || S)
#define A 0\1#define B 5\1#print (A && B)\1#print (B && B)\1#print (A || B)\1#print (A || A)\1#print (B || A)
#print (1 + "a")\1#print ("a" - "b")\1#print (1.5 + 1)\1#print (1 < 1.5)\1#print ('a' + 'b')\1#print (1.5 == 1.5)
#print ('a' == 'a')\1#print ('a' < 'b')\1#print (~"a")\1#print (~'a')\1#print ("a" * "b")\1#print ("a" / 2)
#print (1 << 2)\1#print (1 >> 2)\1#print (<< (1, 2))
#print (+ (1, 2))\1#print (+ (1))\1#print (+ (1, 2, 3))\1#print (+ ())\1#print (~ (1, 2))\1#print (defined (1, 2))
#print (defined (X))\1#define X 1\1#print (defined (X))\1#print (undefined (X))\1#undef X\1#print (defined (X))\1#print (undefined (X))\1#print (X)
#print (defined (1))\1#print (undefined (1))\1#print (defined ("a"))\1#print (defined (f(1)))
#define X\1#print X\1#print (defined (X))\1#define Y ()\1#print Y\1#define Z (1, 2)\1#print Z\1#print (Z + 1)
#define f(x) x + 1\1#print (f(3))\1#print (f(f(2)))\1#print (f(1, 2))\1#print (f())\1#print (f)
#define f(x, y) x - y\1#print (f(10, 3))\1#print (f(10))\1#print (f(3, 10, 5))\1#define g(x) f(x, x)\1#print (g(5))
#define fact(n) if n <= 1 then 1 else n * fact(n - 1)\1#print (fact(5))\1#print (fact(10))\1#print (fact(0))
#define loop(n) loop(n)\1#print (loop(1))
#define loop(n) 1 + loop(n)\1#print (loop(1))
#define a b\1#define b a\1#print a
#define X Y\1#print X\1#define Y 3\1#print X
#define X 1\1#define Y X + 1\1#define X 10\1#print Y
#if 1 #then\1#print "one"\1#endif
#if 0 #then\1#print "one"\1#else\1#print "two"\1#endif
#if 0 #then\1#print "one"\1#elif 1 #then\1#print "two"\1#else\1#print "three"\1#endif
#if 0 #then\1#print "one"\1#elif 0 #then\1#print "two"\1#else\1#print "three"\1#endif
#if 0 #then\1#print "one"\1#elif 0 #then\1#print "two"\1#endif
#ifdef X #then\1#print "X"\1#else\1#print "noX"\1#endif\1#define X 1\1#ifdef X #then\1#print "X"\1#else\1#print "noX"\1#endif
#ifndef X #then\1#print "noX"\1#else\1#print "X"\1#endif\1#define X 1\1#ifndef X #then\1#print "noX"\1#else\1#print "X"\1#endif
#ifdef (1 + 1) #then\1#print "x"\1#endif
#ifndef 1 #then\1#print "x"\1#endif
#if undefinedvar #then\1#print "x"\1#endif
#if (1 + "a") #then\1#print "x"\1#else\1#print "y"\1#endif
#if "a" #then\1#print "x"\1#endif\1#if "" #then\1#print "x"\1#else\1#print "y"\1#endif\1#if 0.0 #then\1#print "x"\1#else\1#print "y"\1#endif\1#if 0.5 #then\1#print "x"\1#else\1#print "y"\1#endif
#if '\0' #then\1#print "x"\1#else\1#print "y"\1#endif\1#if 'a' #then\1#print "x"\1#else\1#print "y"\1#endif
#if 1 #then\1#if 0 #then\1#print "a"\1#else\1#print "b"\1#endif\1#else\1#print "c"\1#endif
#define N 3\1#if N > 2 && N < 5 #then\1#print "in"\1#else\1#print "out"\1#endif\1#if N == 3 || X #then\1#print "or"\1#endif
#define N 3\1#if N > 2 && undefinedvar #then\1#print "in"\1#endif
#define N 3\1#if defined(N) && N > 2 #then\1#print "in"\1#endif
#define N 3\1#print %(N + 1)\1#define M %(N + 1)\1#define N 10\1#print M\1#print N
#define M %(1 + "a")\1#print M
#define M %(undefinedvar)\1#print M
#print (if 1 then 2 else 3)\1#print (if 0 then 2 else 3)\1#print (if 0 then 2)\1#print (if "a" then 2 else 3)\1#print (if (1 + "a") then 2 else 3)
#define C if 1 then 2 else 3\1#print C
#define A (1)\1#print A\1#define A ((1))\1#print A\1#define A (1, (2))\1#print A
#print ()\1#print (1)
#print 1(2)\1#print "a"(2)\1#print (f)(1)\1#print (1)(2)
#define f(x) (x)\1#print (f(3))\1#print f(3)\1#print f 3
#define f(x) g(x)\1#print (f(3))\1#define g(y) y * 2\1#print (f(3))
#define f(x, g) g(x)\1#define h(y) y + 1\1#print (f(3, h))
#define f(x) x\1#define x 5\1#print (f(1))\1#print (f(x))
#define pi 3.14159\1#define r 2.0\1#print (pi * r * r)\1#print (pi < 4.0)
#define big 2147483647\1#print (big + 1)\1#print (big * 2)\1#print (~big - 1)
#define big 4294967296\1#print big\1#define h 0xFF\1#print h\1#print (h + 1)\1#define o 0777\1#print o
#define s "a\\nb"\1#print s\1#print (s + s)
#define c 'x'\1#print c\1#define c '\\n'\1#print c
#define f(x) x\1#undef f\1#print (f(1))
#undef nothing\1#print nothing
#define A 1\1#define B 2\1#define C 3\1#define D (A + B) * C\1#print D\1#print (D - A - B - C)
#define a 1 b 2\1#print a
#define a b c\1#print a
#define t(x) if x then 1 else 0\1#print (t(1))\1#print (t(0))\1#print (t(""))\1#print (t("a"))\1#print (t(1 + "a"))
#define ge(a, b) a >= b\1#print (ge(1, 2))\1#print (ge("b", "a"))\1#print (ge(1.5, 1.4))
#define max(a, b) if a > b then a else b\1#print (max(3, 4))\1#print (max(4, 3))\1#print (max("a", "b"))
#define fib(n) if n < 2 then n else fib(n - 1) + fib(n - 2)\1#print (fib(10))
#define ack(m, n) if m == 0 then n + 1 else if n == 0 then ack(m - 1, 1) else ack(m - 1, ack(m, n - 1))\1#print (ack(2, 2))
#define compose(f, g, x) f(g(x))\1#define inc(x) x + 1\1#define dbl(x) x * 2\1#print (compose(inc, dbl, 5))
#define e %(1)\1#print e\1#define e2 %(e + 1)\1#print e2\1#print %(e2 + e2)
#define e %(f(1))\1#define f(x) x\1#print e
#error "stop"
#assert 1
#assert 0
#print "a"\1#prerr "b"\1#print 1\1#prerr 2
#define x_ 1\1#define _x 2\1#print (x_ + _x)\1#define x' 3\1#print x'
#define ATS_VERSION 5\1#if ATS_VERSION >= 5 #then\1#print "new"\1#else\1#print "old"\1#endif
#define A 1\1#define B (1 + 1)\1#define C (B + B)\1#define D (C + C)\1#define E (D + D)\1#define F (E + E)\1#print F
#define f1(x) x\1#define f2(x) f1(f1(x))\1#define f3(x) f2(f2(x))\1#define f4(x) f3(f3(x))\1#define f5(x) f4(f4(x))\1#print (f5(1))
#define d0 1\1#define d1 d0\1#define d2 d1\1#define d3 d2\1#define d4 d3\1#define d5 d4\1#define d6 d5\1#define d7 d6\1#define d8 d7\1#define d9 d8\1#print d9
'''

def chain(n):
    # a chain of n definitions: deep resolution (up to and beyond the maximal level 99)
    lines = ['#define c0 1']
    for i in range(1, n): lines.append('#define c%d c%d + 0' % (i, i-1))
    lines.append('#print c%d' % (n-1))
    return '\x01'.join(lines)

def gen(seed, n):
    rnd = random.Random(seed)
    names = ['a', 'b', 'c', 'd', 'e', 'p', 'q', 'x', 'y', 'N', 'M']
    fnames = ['f', 'g', 'h', 'k']
    binops = ['+', '-', '*', '+', '-', '*', '<', '<=', '>', '>=', '==', '!=', '<>', '=', '&&', '||', '<<', '>>']
    def lit():
        r = rnd.random()
        if r < 0.55: return str(rnd.choice([0, 1, 2, 3, 5, 7, 10, 100, 255, 1000]))
        if r < 0.65: return rnd.choice(['0x10', '0xFF', '017', '1L', '2U', '12345678'])
        if r < 0.75: return rnd.choice(['1.5', '2.25', '0.0', '3.0', '10.5'])
        if r < 0.9: return rnd.choice(['"a"', '"b"', '"abc"', '""', '"x y"'])
        return rnd.choice(["'a'", "'b'", "'\\0'", "'\\n'"])
    # the calls and the references of a definition go to the symbols of a fixed (acyclic) order, so that the
    # evaluation of the random programs is not exponential (the maximal depth of the evaluator is 99)
    def expr(d, params, cs, fs):
        def ex(d): return expr(d, params, cs, fs)
        r = rnd.random()
        if d <= 0 or r < 0.25: return lit()
        if r < 0.40:
            pool = list(params or []) + list(cs) + (['zz', 'undef1'] if rnd.random() < 0.2 else [])
            return rnd.choice(pool) if pool else lit()
        if r < 0.70: return '(%s %s %s)' % (ex(d-1), rnd.choice(binops), ex(d-1))
        if r < 0.76: return '(~%s)' % ex(d-1)
        if r < 0.82:
            if not fs: return lit()
            return '(%s(%s))' % (rnd.choice(fs), ', '.join(ex(d-1) for _ in range(rnd.choice([0, 1, 1, 2, 2, 3]))))
        if r < 0.87: return '(if %s then %s else %s)' % (ex(d-1), ex(d-1), ex(d-1))
        if r < 0.89: return '(if %s then %s)' % (ex(d-1), ex(d-1))
        if r < 0.93: return '(%s(%s))' % (rnd.choice(['defined', 'undefined']), rnd.choice(list(cs) + list(fs) + [lit(), '(a + 1)']))
        if r < 0.96: return '%%(%s)' % ex(d-1)
        if r < 0.98: return '(%s, %s)' % (ex(d-1), ex(d-1))
        return '(%s)' % ex(d-1)
    def stmt():
        r = rnd.random()
        if r < 0.38:
            i = rnd.randrange(len(names))
            return '#define %s %s' % (names[i], expr(rnd.choice([1, 2, 3]), None, names[i+1:], fnames))
        if r < 0.58:
            ps = rnd.sample(['x', 'y', 'z'], rnd.choice([0, 1, 1, 2, 2, 3]))
            j = rnd.randrange(len(fnames))
            return '#define %s(%s) %s' % (fnames[j], ', '.join(ps), expr(rnd.choice([1, 2, 3]), ps, [], fnames[j+1:]))
        if r < 0.63: return '#undef %s' % rnd.choice(names + fnames)
        E = lambda d: expr(d, None, names, fnames)
        if r < 0.80: return '#print %s' % E(rnd.choice([1, 2, 3, 4]))
        c = E(rnd.choice([1, 2]))
        k = rnd.choice(['#if', '#if', '#ifdef', '#ifndef'])
        if k != '#if': c = rnd.choice(names + [c])
        t = '#print %s' % E(1)
        e = '#print %s' % E(1)
        f = rnd.random()
        if f < 0.3: return '%s %s #then\x01%s\x01#endif' % (k, c, t)
        if f < 0.65: return '%s %s #then\x01%s\x01#else\x01%s\x01#endif' % (k, c, t, e)
        return '%s %s #then\x01%s\x01#elif %s #then\x01%s\x01#else\x01%s\x01#endif' % (k, c, t, E(1), e, t)
    out = []
    for i in range(n):
        out.append('TOPdyn\t' + '\x01'.join(stmt() for _ in range(rnd.choice([2, 3, 4, 6, 8]))))
    return out


def gen2(seed, n):
    # well-typed programs: most evaluations succeed (ints, floats, strings, conditions, calls with the right arity)
    rnd = random.Random(seed)
    def ilit(): return str(rnd.choice([0, 1, 2, 3, 4, 5, 7, 10, 100, 255, 1000, 65536]))
    def flit(): return rnd.choice(['0.5', '1.5', '2.25', '10.0', '3.75'])
    def slit(): return rnd.choice(['"a"', '"b"', '"abc"', '"x y"', '"zz"'])
    def inum(d, env):
        r = rnd.random()
        if d <= 0 or r < 0.2:
            return rnd.choice(env['i']) if env['i'] and rnd.random() < 0.6 else ilit()
        if r < 0.55: return '(%s %s %s)' % (inum(d-1, env), rnd.choice(['+', '-', '*', '+', '-']), inum(d-1, env))
        if r < 0.62: return '(%s / %s)' % (inum(d-1, env), rnd.choice(['2', '3', '7']))
        if r < 0.67: return '(~%s)' % inum(d-1, env)
        if r < 0.72: return '(%s %s %s)' % (inum(d-1, env), rnd.choice(['<', '<=', '>', '>=', '==', '!=', '<>', '=']), inum(d-1, env))
        if r < 0.76: return '(%s %s %s)' % (fnum(d-1, env), rnd.choice(['<', '<=', '>', '>=']), fnum(d-1, env))
        if r < 0.80: return '(%s %s %s)' % (snum(d-1, env), rnd.choice(['<', '<=', '>', '>=', '==', '!=']), snum(d-1, env))
        if r < 0.85: return '(%s %s %s)' % (inum(d-1, env), rnd.choice(['&&', '||']), inum(d-1, env))
        if r < 0.88: return '(%s %s %s)' % (snum(d-1, env), rnd.choice(['&&', '||']), snum(d-1, env))
        if r < 0.92: return '(if %s then %s else %s)' % (inum(d-1, env), inum(d-1, env), inum(d-1, env))
        if r < 0.95 and env['f']:
            f, k = rnd.choice(env['f'])
            return '(%s(%s))' % (f, ', '.join(inum(d-1, env) for _ in range(k)))
        if r < 0.97: return '%%(%s)' % inum(d-1, env)
        if r < 0.985 and env['i']: return '(%s(%s))' % (rnd.choice(['defined', 'undefined']), rnd.choice(env['i']))
        return ilit()
    def fnum(d, env):
        r = rnd.random()
        if d <= 0 or r < 0.3:
            return rnd.choice(env['d']) if env['d'] and rnd.random() < 0.6 else flit()
        if r < 0.8: return '(%s %s %s)' % (fnum(d-1, env), rnd.choice(['+', '-', '*', '/']), fnum(d-1, env))
        if r < 0.9: return '(~%s)' % fnum(d-1, env)
        return '(if %s then %s else %s)' % (inum(d-1, env), fnum(d-1, env), fnum(d-1, env))
    def snum(d, env):
        r = rnd.random()
        if d <= 0 or r < 0.4:
            return rnd.choice(env['s']) if env['s'] and rnd.random() < 0.6 else slit()
        if r < 0.85: return '(%s + %s)' % (snum(d-1, env), snum(d-1, env))
        return '(if %s then %s else %s)' % (inum(d-1, env), snum(d-1, env), snum(d-1, env))
    out = []
    for i in range(n):
        env = {'i': [], 'd': [], 's': [], 'f': []}
        st = []
        for j in range(rnd.choice([3, 4, 5, 6])):
            r = rnd.random()
            if r < 0.45:
                nm = 'i%d' % len(env['i']); st.append('#define %s %s' % (nm, inum(2, env))); env['i'].append(nm)
            elif r < 0.6:
                nm = 'd%d' % len(env['d']); st.append('#define %s %s' % (nm, fnum(2, env))); env['d'].append(nm)
            elif r < 0.75:
                nm = 's%d' % len(env['s']); st.append('#define %s %s' % (nm, snum(2, env))); env['s'].append(nm)
            else:
                k = rnd.choice([1, 2, 3]); ps = ['x', 'y', 'z'][:k]
                nm = 'fn%d' % len(env['f'])
                env2 = {'i': ps + env['i'], 'd': env['d'], 's': env['s'], 'f': list(env['f'])}
                st.append('#define %s(%s) %s' % (nm, ', '.join(ps), inum(3, env2))); env['f'].append((nm, k))
        for j in range(rnd.choice([3, 4, 6])):
            r = rnd.random()
            if r < 0.4: st.append('#print %s' % inum(rnd.choice([1, 2, 3]), env))
            elif r < 0.5: st.append('#print %s' % fnum(2, env))
            elif r < 0.6: st.append('#print %s' % snum(2, env))
            elif r < 0.9:
                st.append('#if %s #then\x01#print %s\x01#else\x01#print %s\x01#endif' % (inum(2, env), inum(1, env), snum(1, env)))
            else:
                nm = rnd.choice(['i0', 'i1', 'd0', 's0', 'fn0', 'zz'])
                st.append('#%s %s #then\x01#print %s\x01#endif' % (rnd.choice(['ifdef', 'ifndef']), nm, inum(1, env)))
        out.append('TOPdyn\t' + '\x01'.join(st))
    return out

def main():
    seed = int(sys.argv[1]) if len(sys.argv) > 1 else 1
    n = int(sys.argv[2]) if len(sys.argv) > 2 else 3000
    for l in HAND.strip().split('\n'):
        print('TOPdyn\t' + l.replace('\\1', '\x01'))
    for k in ((10,) if n == 0 else (10, 50, 97, 98, 99, 100, 101, 150)):
        print('TOPdyn\t' + chain(k))
    for l in gen(seed, n): print(l)
    for l in gen2(seed, n): print(l)

main()
