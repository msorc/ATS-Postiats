#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
"""
spec_from_sats: a draft of an arenagen spec from the type declarations of an
ATS1 .sats ("'{..}" records, datatypes with "and", List/Option aliases):
    python3 spec_from_sats.py src/X.sats > draft.spec
Review the draft by hand: enum-only datatypes stay datatypes (delete them),
polymorphic/parametric types, types with the same constructor name twice,
and the field types from other modules need a decision (see PORTING.md,
"Arena AST"). The output is ordered by name; the typedef lines come first.
"""
import re,sys
src=open(sys.argv[1]).read()
# strip comments
def strip(s):
    out=[];i=0;n=len(s);depth=0
    while i<n:
        if s.startswith('(*',i): depth+=1;i+=2;continue
        if depth and s.startswith('*)',i): depth-=1;i+=2;continue
        if depth: 
            if s[i]=='\n': out.append('\n')
            i+=1;continue
        if s.startswith('/*',i):
            j=s.index('*/',i);out.append('\n'*s[i:j].count('\n'));i=j+2;continue
        if s.startswith('//',i):
            j=s.find('\n',i); 
            if j<0:j=n
            i=j;continue
        out.append(s[i]);i+=1
    return ''.join(out)
t=strip(src)
def lst(x):
    x=x.strip()
    m=re.match(r'^(List|Option)\s*\(?\s*(.*?)\s*\)?$',x)
    return x
def conv(ty):
    ty=ty.strip()
    ty=re.sub(r'\s+',' ',ty)
    # List T / List (T) / Option
    def repl(m):
        k={'List':'glist','Option':'gopt'}[m.group(1)]
        arg=m.group(2).strip()
        if arg.startswith('(') and arg.endswith(')'): arg=arg[1:-1]
        return '%s(%s)'%(k,arg)
    ty=re.sub(r'\b(List|Option)\s*(\([^()]*\)|\w+)',repl,ty)
    return ty
def split_top(s,sep):
    parts=[];depth=0;buf=''
    for ch in s:
        if ch in '([{': depth+=1
        if ch in ')]}': depth-=1
        if ch==sep and depth==0: parts.append(buf);buf='';continue
        buf+=ch
    parts.append(buf);return parts
# records
recs=[]
for m in re.finditer(r"(?:typedef|and|where)\s+(\w+)\s*(?::\s*\w+)?\s*=\s*'\{(.*?)\}",t,re.S):
    name=m.group(1);fl=[]
    for p in split_top(m.group(2),','):
        p=p.strip()
        if not p: continue
        f,ty=p.split('=',1)
        fl.append((f.strip(),conv(ty)))
    recs.append((m.start(),name,fl))
# datatypes
dts=[]
for m in re.finditer(r"\b(datatype|and)\s+(\w+)\s*(\(\w+:\w+\))?\s*=(.*?)(?=\n\s*(?:and\b|where\b|datatype\b|fun\b|typedef\b|val\b|abstype\b|viewtypedef\b|vtypedef\b|castfn\b|staload\b|#))",t,re.S):
    name=m.group(2);body=m.group(4)
    if '\'{' in body[:3]: continue
    cons=[]
    for c in split_top(body,'|'):
        c=c.strip()
        if not c: continue
        mm=re.match(r'^(\w+)\s*(?:\(\w+\))?\s*(?:of\s*(.*))?$',c,re.S)
        if not mm: print('#?? ',c[:50],file=sys.stderr);continue
        con=mm.group(1);arg=mm.group(2)
        fl=[]
        if arg:
            arg=arg.strip()
            if arg.startswith('(') and arg.endswith(')') and split_top(arg[1:-1],',')!=[arg[1:-1]] or arg=='()':
                inner=arg[1:-1].strip()
                fl=[conv(x) for x in split_top(inner,',')] if inner else []
            elif arg.startswith('(') and arg.endswith(')'):
                fl=[conv(arg[1:-1])]
            else: fl=[conv(arg)]
        cons.append((con,fl))
    dts.append((m.start(),name,cons))
# aliases
als=[]
for m in re.finditer(r"(?:typedef|viewtypedef|vtypedef|and|where)\s+(\w+)\s*(?::\s*(?:type|viewtype))?\s*=\s*((?:List|Option|List_vt|Option_vt|sl0abeled|dl0abeled)\b[^\n]*)",t):
    als.append((m.start(),m.group(1),m.group(2).strip()))

bad={'List','Option','List_vt','Option_vt'}
dts=[d for d in dts if not any(c in bad for c,_ in d[2])]
al={}
for _,n,r in als: al[n]=conv(r)
order=[];seen=set()
def visit(n):
    if n in seen: return
    seen.add(n)
    for w in re.findall(r'\w+',al[n]):
        if w in al: visit(w)
    order.append(n)
for n in al: visit(n)
out=[]
for n in order:
    kw='vtypedef' if n.endswith('_vt') else 'typedef'
    r=re.sub(r'glist\(_vt\) \(?([a-z0-9_]+)\)?$',r'List_vt(\1)',al[n])
    r=re.sub(r'gopt\(_vt\) \(?([a-z0-9_]+)\)?$',r'Option_vt(\1)',r)
    out.append('%s %s = %s'%(kw,n,r))
out.append('')
items=[('r',)+r for r in recs]+[('d',)+d for d in dts]
items.sort(key=lambda x:x[1])
for it in items:
    if it[0]=='r':
        out.append('record %s (%s)'%(it[2],', '.join('%s: %s'%f for f in it[3])))
    else:
        out.append('type %s'%it[2])
        for c,fl in it[3]: out.append('  %s (%s)'%(c,', '.join(fl)))
print('\n'.join(out))
