#!/usr/bin/env python3
#
# ATS/Postiats - Unleashing the Potential of Types!
# Copyright (C) 2026 Hongwei Xi, ATS Trustful Software, Inc.
#
# ATS is free software; you can redistribute it and/or modify it under
# the terms of the GNU GENERAL PUBLIC LICENSE (GPL) as published by the
# Free Software Foundation; either version 3, or (at your option) any
# later version.
#
"""
arenagen: generate the arena encoding of algebraic types for ATS2
(no GC: shared nodes are stored in a libats/arena region).

Spec format (one group of possibly mutually recursive types):

  type NAME
    CON1 ()
    CON2 (TYPE, TYPE)
    CON3 (field1: TYPE, field2: TYPE)    # named fields (getters are
                                         # generated for 1-constructor types)

Field types are copied verbatim; region-indexed types must be written
with their region argument, e.g. s2exp(l). Every field is stored in an
8-byte slot (so a field type must be at most 8 bytes in size).

With --global, the global arena (see libats/SATS/arena.sats) is
used: the handle types are not indexed, the functions take no arena
and a single-constructor type T gets [overload .F with T_get_F] for
each named field F (so that x.F works as for a record).

For each type T it emits (sats):
  abstype T_type(l:addr) = ptr ; typedef T(l:addr) = T_type(l)
  datavtype T_view(l:addr) = CON1 of (...) | ...
  fun T_encode / T_view / T_view_free / T_tag / T_CON (allocating shortcuts)
  fun T_is_CON (for types with several constructors)
  fun T_get_FIELD (for single-constructor types with named fields)
and their implementations (dats).
"""
import re, sys

PASS = []   # typedef/vtypedef lines of the spec, copied to the sats
VIEWFN = {} # [viewfn T NAME] in a spec: the function T_view (x) is named NAME (when T_view clashes with a constant)
MUT = set() # names of the fields declared [mut] in a record: they get a setter set_F(x, v)

def split_fields(args):
    fields = []
    args = args.strip()
    if args:
        depth = 0; buf = ''; parts = []
        for ch in args:
            if ch == ',' and depth == 0: parts.append(buf); buf = ''; continue
            if ch == '(': depth += 1
            if ch == ')': depth -= 1
            buf += ch
        parts.append(buf)
        for p in parts:
            p = p.strip()
            fm = re.match(r'^(mut\s+)?(\w+)\s*:\s*(.+)$', p)
            if fm:
                fields.append((fm.group(2), fm.group(3).strip()))
                if fm.group(1): MUT.add(fm.group(2))
            else: fields.append((None, p))
    return fields

def parse(spec):
    types = []
    cur = None
    for raw in spec.split('\n'):
        if re.match(r'^(typedef|vtypedef)\b', raw):
            # a line copied verbatim to the .sats (after the abstypes)
            PASS.append(raw.split('##',1)[0].rstrip()); continue
        line = raw.split('#',1)[0].rstrip()
        if not line.strip(): continue
        m = re.match(r'^viewfn\s+(\w+)\s+(\w+)\s*$', line)
        if m:
            VIEWFN[m.group(1)] = m.group(2); continue
        # record NAME (f1: T1, f2: T2): one constructor, no tag, flat
        m = re.match(r'^record\s+(\w+)\s*\((.*)\)\s*$', line)
        if m:
            types.append({'name': m.group(1), 'record': True,
                          'cons': [{'name': m.group(1), 'fields': split_fields(m.group(2))}]})
            cur = None; continue
        m = re.match(r'^type\s+(\w+)\s*$', line)
        if m:
            cur = {'name': m.group(1), 'cons': [], 'record': False}
            types.append(cur); continue
        m = re.match(r'^\s+(\w+)\s*\((.*)\)\s*$', line)
        if not m or cur is None: raise SystemExit('bad line: %r' % raw)
        cur['cons'].append({'name': m.group(1), 'fields': split_fields(m.group(2))})
    return types

def gen_sats(types, glob=False):
    if glob: return gen_sats_global(types)
    if any(t['record'] for t in types): raise SystemExit('record needs --global')
    out = []
    for t in types:
        T = t['name']
        out.append('abstype\n%s_type(l:addr) = ptr\ntypedef\n%s(l:addr) = %s_type(l)\n' % (T, T, T))
    out.append('//')
    for i, t in enumerate(types):
        T = t['name']
        kw = 'datavtype' if i == 0 else 'and'
        out.append('%s\n%s_view(l:addr) =' % (kw, T))
        for c in t['cons']:
            if c['fields']:
                out.append('  | %s of (%s)' % (c['name'], ', '.join(f[1] for f in c['fields'])))
            else:
                out.append('  | %s of ()' % c['name'])
    out.append('//')
    for t in types:
        T = t['name']
        out.append('''fun
%(T)s_encode{l:addr}(ar: !arena(l), v: %(T)s_view(l)): %(T)s(l)
fun
%(T)s_view{l:addr}(ar: !arena(l), x: %(T)s(l)): %(T)s_view(l)
fun
%(T)s_view_free{l:addr}(v: %(T)s_view(l)): void
fun
%(T)s_tag{l:addr}(ar: !arena(l), x: %(T)s(l)): int''' % {'T': T})
        for c in t['cons']:
            args = ''.join(', a%d: %s' % (k, f[1]) for k, f in enumerate(c['fields']))
            out.append('fun\n%s_%s{l:addr}(ar: !arena(l)%s): %s(l)' % (T, c['name'], args, T))
        if len(t['cons']) > 1:
            for c in t['cons']:
                out.append('fun\n%s_is_%s{l:addr}(ar: !arena(l), x: %s(l)): bool' % (T, c['name'], T))
        if len(t['cons']) == 1:
            for k, f in enumerate(t['cons'][0]['fields']):
                if f[0]:
                    out.append('fun\n%s_get_%s{l:addr}(ar: !arena(l), x: %s(l)): %s' % (T, f[0], T, f[1]))
        out.append('//')
    return '\n'.join(out) + '\n'

def gen_dats(types, glob=False):
    if glob: return gen_dats_global(types)
    if any(t['record'] for t in types): raise SystemExit('record needs --global')
    out = []
    for t in types:
        T = t['name']
        nmax = max([len(c['fields']) for c in t['cons']] + [0])
        nbytes = 8 * (1 + nmax)
        # constructors
        for tag, c in enumerate(t['cons']):
            n = len(c['fields'])
            params = ''.join(', a%d' % k for k in range(n))
            sets = ''.join('val () = arena_store<%s>(ptr_add<byte>(p, %d), a%d)\n' % (f[1], 8*(k+1), k)
                           for k, f in enumerate(c['fields']))
            out.append('''implement
%(T)s_%(C)s
  {l}(ar%(params)s) = let
val p = arena_alloc(ar, i2sz(%(nbytes)d))
val () = arena_store<int>(p, %(tag)d)
%(sets)sin
  $UN.cast{%(T)s(l)}(p)
end // end of [%(T)s_%(C)s]
''' % {'T': T, 'C': c['name'], 'params': params, 'nbytes': nbytes, 'tag': tag, 'sets': sets})
        # make
        branches = []
        for c in t['cons']:
            n = len(c['fields'])
            pats = ', '.join('a%d' % k for k in range(n))
            args = ''.join(', a%d' % k for k in range(n))
            branches.append('| ~%s(%s) => %s_%s(ar%s)' % (c['name'], pats, T, c['name'], args))
        out.append('implement\n%s_encode\n  {l}(ar, v) =\n(\ncase+ v of\n%s\n) (* end of [%s_encode] *)\n' % (T, '\n'.join(branches), T))
        # tag
        out.append('implement\n%s_tag\n  (ar, x) = arena_load<int>($UN.cast{ptr}(x))\n' % T)
        if len(t['cons']) > 1:
            for tag, c in enumerate(t['cons']):
                out.append('implement\n%s_is_%s\n  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = %d)\n' % (T, c['name'], tag))
        # view
        branches = []
        for tag, c in enumerate(t['cons']):
            gets = ', '.join('arena_load<%s>(ptr_add<byte>(p, %d))' % (f[1], 8*(k+1))
                             for k, f in enumerate(c['fields']))
            pat = '_' if tag == len(t['cons'])-1 else str(tag)
            branches.append('| %s => %s(%s)' % (pat, c['name'], gets))
        out.append('''implement
%(T)s_view
  {l}(ar, x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
%(br)s
//
end // end of [%(T)s_view]
''' % {'T': T, 'br': '\n'.join(branches)})
        # view_free
        branches = []
        for c in t['cons']:
            pats = ', '.join('_' for _ in c['fields'])
            branches.append('| ~%s(%s) => ()' % (c['name'], pats))
        out.append('implement\n%s_view_free\n  (v) =\n(\ncase+ v of\n%s\n) (* end of [%s_view_free] *)\n' % (T, '\n'.join(branches), T))
        # getters
        if len(t['cons']) == 1:
            for k, f in enumerate(t['cons'][0]['fields']):
                if f[0]:
                    out.append('implement\n%s_get_%s\n  {l}(ar, x) =\n  arena_load<%s>(ptr_add<byte>($UN.cast{ptr}(x), %d))\n'
                               % (T, f[0], f[1], 8*(k+1)))
        out.append('(* ****** ****** *)\n')
    return '\n'.join(out)

def gen_sats_global(types):
    out = []
    for t in types:
        T = t['name']
        out.append('abstype\n%s_type = ptr\ntypedef\n%s = %s_type\n' % (T, T, T))
    out.extend(PASS)
    out.append('//')
    first = True
    for t in types:
        if t['record']: continue
        T = t['name']
        kw = 'datavtype' if first else 'and'
        first = False
        out.append('%s\n%s_view =' % (kw, T))
        for c in t['cons']:
            if c['fields']:
                out.append('  | %s of (%s)' % (c['name'], ', '.join(f[1] for f in c['fields'])))
            else:
                out.append('  | %s of ()' % c['name'])
    out.append('//')
    for t in types:
        T = t['name']
        if t['record']:
            c = t['cons'][0]
            args = ', '.join('a%d: %s' % (k, f[1]) for k, f in enumerate(c['fields']))
            out.append('fun\n%s_new(%s): %s' % (T, args, T))
            for f in c['fields']:
                out.append('fun\n%s(x: %s): %s' % (f[0], T, f[1]))
                out.append('overload .%s with %s' % (f[0], f[0]))
                if f[0] in MUT: out.append('fun\nset_%s(x: %s, v: %s): void' % (f[0], T, f[1]))
            out.append('//')
            continue
        out.append('''fun
%(T)s_encode(v: %(T)s_view): %(T)s
fun
%(T)s_view(x: %(T)s): %(T)s_view
fun
%(T)s_view_free(v: %(T)s_view): void
fun
%(T)s_tag(x: %(T)s): int''' % {'T': T})
        for c in t['cons']:
            args = ', '.join('a%d: %s' % (k, f[1]) for k, f in enumerate(c['fields']))
            out.append('fun\n%s_%s(%s): %s' % (T, c['name'], args, T))
        if len(t['cons']) > 1:
            for c in t['cons']:
                out.append('fun\n%s_is_%s(x: %s): bool' % (T, c['name'], T))
        if len(t['cons']) == 1:
            for k, f in enumerate(t['cons'][0]['fields']):
                if f[0]:
                    out.append('fun\n%s_get_%s(x: %s): %s' % (T, f[0], T, f[1]))
                    out.append('overload .%s with %s_get_%s' % (f[0], T, f[0]))
        out.append('//')
    return '\n'.join(out) + '\n'

def gen_dats_global(types):
    out = []
    for t in types:
        T = t['name']
        if t['record']:
            c = t['cons'][0]
            n = len(c['fields'])
            params = ', '.join('a%d' % k for k in range(n))
            sets = ''.join('val () = arena_store<%s>(ptr_add<byte>(p, %d), a%d)\n' % (f[1], 8*k, k)
                           for k, f in enumerate(c['fields']))
            out.append('''implement
%(T)s_new
  (%(params)s) = let
val p = the_garena_alloc(i2sz(%(nbytes)d))
%(sets)sin
  $UN.cast{%(T)s}(p)
end // end of [%(T)s_new]
''' % {'T': T, 'params': params, 'nbytes': max(8*n, 8), 'sets': sets})
            for k, f in enumerate(c['fields']):
                out.append('implement\n%s\n  (x) =\n  arena_load<%s>(ptr_add<byte>($UN.cast{ptr}(x), %d))\n'
                           % (f[0], f[1], 8*k))
                if f[0] in MUT:
                    out.append('implement\nset_%s\n  (x, v) =\n  arena_store<%s>(ptr_add<byte>($UN.cast{ptr}(x), %d), v)\n'
                               % (f[0], f[1], 8*k))
            out.append('(* ****** ****** *)\n')
            continue
        nmax = max([len(c['fields']) for c in t['cons']] + [0])
        nbytes = 8 * (1 + nmax)
        for tag, c in enumerate(t['cons']):
            n = len(c['fields'])
            params = ', '.join('a%d' % k for k in range(n))
            sets = ''.join('val () = arena_store<%s>(ptr_add<byte>(p, %d), a%d)\n' % (f[1], 8*(k+1), k)
                           for k, f in enumerate(c['fields']))
            out.append('''implement
%(T)s_%(C)s
  (%(params)s) = let
val p = the_garena_alloc(i2sz(%(nbytes)d))
val () = arena_store<int>(p, %(tag)d)
%(sets)sin
  $UN.cast{%(T)s}(p)
end // end of [%(T)s_%(C)s]
''' % {'T': T, 'C': c['name'], 'params': params, 'nbytes': nbytes, 'tag': tag, 'sets': sets})
        branches = []
        for c in t['cons']:
            n = len(c['fields'])
            pats = ', '.join('a%d' % k for k in range(n))
            branches.append('| ~%s(%s) => %s_%s(%s)' % (c['name'], pats, T, c['name'], pats))
        out.append('implement\n%s_encode\n  (v) =\n(\ncase+ v of\n%s\n) (* end of [%s_encode] *)\n' % (T, '\n'.join(branches), T))
        out.append('implement\n%s_tag\n  (x) = arena_load<int>($UN.cast{ptr}(x))\n' % T)
        if len(t['cons']) > 1:
            for tag, c in enumerate(t['cons']):
                out.append('implement\n%s_is_%s\n  (x) = (arena_load<int>($UN.cast{ptr}(x)) = %d)\n' % (T, c['name'], tag))
        branches = []
        for tag, c in enumerate(t['cons']):
            gets = ', '.join('arena_load<%s>(ptr_add<byte>(p, %d))' % (f[1], 8*(k+1))
                             for k, f in enumerate(c['fields']))
            pat = '_' if tag == len(t['cons'])-1 else str(tag)
            branches.append('| %s => %s(%s)' % (pat, c['name'], gets))
        out.append('''implement
%(T)s_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
%(br)s
//
end // end of [%(T)s_view]
''' % {'T': T, 'br': '\n'.join(branches)})
        branches = []
        for c in t['cons']:
            pats = ', '.join('_' for _ in c['fields'])
            branches.append('| ~%s(%s) => ()' % (c['name'], pats))
        out.append('implement\n%s_view_free\n  (v) =\n(\ncase+ v of\n%s\n) (* end of [%s_view_free] *)\n' % (T, '\n'.join(branches), T))
        if len(t['cons']) == 1:
            for k, f in enumerate(t['cons'][0]['fields']):
                if f[0]:
                    out.append('implement\n%s_get_%s\n  (x) =\n  arena_load<%s>(ptr_add<byte>($UN.cast{ptr}(x), %d))\n'
                               % (T, f[0], f[1], 8*(k+1)))
        out.append('(* ****** ****** *)\n')
    return '\n'.join(out)

DWORD = ('double',)   # field types stored by value (not through a ptr cast) by --compact

def gen_dats_compact(types, stem):
    """--compact (with --global): the same functions as gen_dats_global,
    but each field is a word accessed by two non-template helpers, with
    casts: no template instance (arena_store<T>, ptr_add<byte>) per field,
    which cuts the generated C by a factor of 30 or more."""
    ld = '%s_ld' % stem
    st = '%s_st' % stem
    out = ['''fn %(ld)s (p: ptr, k: int): ptr = $UN.ptr0_get<ptr> (ptr0_add_gint<byte> (p, k))
fn %(st)s (p: ptr, k: int, x: ptr): void = $UN.ptr0_set<ptr> (ptr0_add_gint<byte> (p, k), x)
fn %(stem)s_alloc (n: int): ptr = the_garena_alloc ($UN.cast{size_t} (n))
//
''' % {'ld': ld, 'st': st, 'stem': stem}]
    if any(f[1] in DWORD for t in types for c in t['cons'] for f in c['fields']):
        # a double is not converted to a word by a cast: it is stored as is
        out.append('''fn %(stem)s_ldd (p: ptr, k: int): double = $UN.ptr0_get<double> (ptr0_add_gint<byte> (p, k))
fn %(stem)s_std (p: ptr, k: int, x: double): void = $UN.ptr0_set<double> (ptr0_add_gint<byte> (p, k), x)
//
''' % {'stem': stem})
    def cs(off, k, ft):   # the statement storing the argument ak at the byte offset off
        if ft in DWORD: return 'val () = %s_std (p, %d, a%d)\n' % (stem, off, k)
        return 'val () = %s (p, %d, $UN.cast{ptr} ($UN.cast{lint} (a%d)))\n' % (st, off, k)
    def cl(off, ft, pe='p'):   # the expression loading the field at the byte offset off of pe
        if ft in DWORD: return '%s_ldd (%s, %d)' % (stem, pe, off)
        return '$UN.cast{%s} ($UN.cast{lint} (%s (%s, %d)))' % (ft, ld, pe, off)
    for t in types:
        T = t['name']
        if t['record']:
            c = t['cons'][0]
            n = len(c['fields'])
            params = ', '.join('a%d' % k for k in range(n))
            sets = ''.join(cs(8*k, k, c['fields'][k][1]) for k in range(n))
            out.append('''implement
%(T)s_new
  (%(params)s) = let
val p = %(stem)s_alloc (%(nbytes)d)
%(sets)sin
  $UN.cast{%(T)s} (p)
end // end of [%(T)s_new]
''' % {'T': T, 'params': params, 'nbytes': max(8*n, 8), 'sets': sets, 'stem': stem})
            for k, f in enumerate(c['fields']):
                out.append('implement\n%s\n  (x) = %s\n'
                           % (f[0], cl(8*k, f[1], '$UN.cast{ptr} (x)')))
                if f[0] in MUT:
                    if f[1] in DWORD:
                        out.append('implement\nset_%s\n  (x, v) = %s_std ($UN.cast{ptr} (x), %d, v)\n' % (f[0], stem, 8*k))
                    else:
                        out.append('implement\nset_%s\n  (x, v) = %s ($UN.cast{ptr} (x), %d, $UN.cast{ptr} ($UN.cast{lint} (v)))\n'
                                   % (f[0], st, 8*k))
            out.append('(* ****** ****** *)\n')
            continue
        nmax = max([len(c['fields']) for c in t['cons']] + [0])
        nbytes = 8 * (1 + nmax)
        for tag, c in enumerate(t['cons']):
            n = len(c['fields'])
            params = ', '.join('a%d' % k for k in range(n))
            sets = ''.join(cs(8*(k+1), k, c['fields'][k][1]) for k in range(n))
            out.append('''implement
%(T)s_%(C)s
  (%(params)s) = let
val p = %(stem)s_alloc (%(nbytes)d)
val () = %(st)s (p, 0, $UN.cast{ptr} ($UN.cast{lint} (%(tag)d)))
%(sets)sin
  $UN.cast{%(T)s} (p)
end // end of [%(T)s_%(C)s]
''' % {'T': T, 'C': c['name'], 'params': params, 'nbytes': nbytes, 'tag': tag, 'sets': sets, 'st': st, 'stem': stem})
        branches = []
        for c in t['cons']:
            n = len(c['fields'])
            pats = ', '.join('a%d' % k for k in range(n))
            branches.append('| ~%s(%s) => %s_%s(%s)' % (c['name'], pats, T, c['name'], pats))
        out.append('implement\n%s_encode\n  (v) =\n(\ncase+ v of\n%s\n) (* end of [%s_encode] *)\n' % (T, '\n'.join(branches), T))
        out.append('implement\n%s_tag\n  (x) = $UN.cast{int} ($UN.cast{lint} (%s ($UN.cast{ptr} (x), 0)))\n' % (T, ld))
        if len(t['cons']) > 1:
            for tag, c in enumerate(t['cons']):
                out.append('implement\n%s_is_%s\n  (x) = ($UN.cast{int} ($UN.cast{lint} (%s ($UN.cast{ptr} (x), 0))) = %d)\n' % (T, c['name'], ld, tag))
        branches = []
        for tag, c in enumerate(t['cons']):
            gets = ', '.join(cl(8*(k+1), f[1]) for k, f in enumerate(c['fields']))
            pat = '_' if tag == len(t['cons'])-1 else str(tag)
            branches.append('| %s => %s(%s)' % (pat, c['name'], gets))
        out.append('''implement
%(T)s_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (%(ld)s (p, 0)))
//
in
//
case+ tag of
%(br)s
//
end // end of [%(T)s_view]
''' % {'T': T, 'br': '\n'.join(branches), 'ld': ld})
        branches = []
        for c in t['cons']:
            pats = ', '.join('_' for _ in c['fields'])
            branches.append('| ~%s(%s) => ()' % (c['name'], pats))
        out.append('implement\n%s_view_free\n  (v) =\n(\ncase+ v of\n%s\n) (* end of [%s_view_free] *)\n' % (T, '\n'.join(branches), T))
        if len(t['cons']) == 1:
            for k, f in enumerate(t['cons'][0]['fields']):
                if f[0]:
                    out.append('implement\n%s_get_%s\n  (x) = %s\n'
                               % (T, f[0], cl(8*(k+1), f[1], '$UN.cast{ptr} (x)')))
        out.append('(* ****** ****** *)\n')
    return '\n'.join(out)

if __name__ == '__main__':
    args = sys.argv[1:]
    glob = '--global' in args
    compact = '--compact' in args
    args = [a for a in args if a not in ('--global', '--compact')]
    mode = args[0]   # sats | dats
    spec = open(args[1]).read()
    types = parse(spec)
    if mode == 'dats' and compact:
        import os
        stem = re.sub(r'\W', '_', os.path.splitext(os.path.basename(args[1]))[0])
        out = gen_dats_compact(types, stem)
    else:
        out = gen_sats(types, glob) if mode == 'sats' else gen_dats(types, glob)
    for T, NAME in VIEWFN.items():
        out = out.replace('fun\n%s_view(x: %s)' % (T, T), 'fun\n%s(x: %s)' % (NAME, T))
        out = out.replace('implement\n%s_view\n  (x)' % T, 'implement\n%s\n  (x)' % NAME)
    sys.stdout.write(out)
