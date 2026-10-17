#!/usr/bin/env python3
"""
port_ats1: a first mechanical pass of porting an ATS1 .dats (that builds and
matches a record/datatype AST) to the arena encoding of a spec (arenagen.py
--global). Usage:  port_ats1.py X.spec src/X.dats draft.dats

It rewrites, using the constructors/fields of the spec:
  '{ s0exp_loc= l, s0exp_node= S0Eapp (a, b) }  ->  s0exp_new(l, s0exp_node_S0Eapp(a, b))
  CON(args) (expression)    -> T_CON(args);   CON (pattern after | or of) -> ~CON
  case+ x.s0exp_node of     -> case+ s0exp_node_view(x.s0exp_node()) of
  x.field                   -> x.field()
  Some/None/list_cons/list_nil (patterns and expressions) -> gopt/glist
The draft needs a manual pass: wildcard arms on a linear view
([| v => (T_view_free(v); ..)]), bare constructor applications, matches on
tokens, closures, the effect annotations (see PORTING.md, "Arena AST").
"""
import re,sys
# ---- load spec (argv[1])
SPEC=sys.argv[1]
recs={}     # T -> [fields]
field2rec={}
ctors={}    # CON -> (T, nfields)
viewtypes=set()
cur=None
def splitf(a):
    parts=[];d=0;b=''
    for ch in a:
        if ch=='(':d+=1
        if ch==')':d-=1
        if ch==',' and d==0: parts.append(b);b='';continue
        b+=ch
    if b.strip(): parts.append(b)
    return parts
for SPEC1 in SPEC.split(':'):   # several specs may be given, separated by ':' (e.g. trans1: syntax:staexp1:dynexp1)
  cur=None
  for l in open(SPEC1):
    l=l.split('#',1)[0].rstrip()
    m=re.match(r'^record\s+(\w+)\s*\((.*)\)\s*$',l)
    if m:
        fs=[re.sub(r'^mut\s+','',p.split(':')[0].strip()) for p in splitf(m.group(2))]   # [mut f] of a record: the same getter name
        recs[m.group(1)]=fs
        for f in fs: field2rec[f]=m.group(1)
        continue
    m=re.match(r'^type\s+(\w+)\s*$',l)
    if m: cur=m.group(1);viewtypes.add(cur);continue
    m=re.match(r'^\s+(\w+)\s*\((.*)\)\s*$',l)
    if m and cur:
        ctors[m.group(1)]=(cur,len(splitf(m.group(2))))
ctors['D0Cextype2']=('d0ecl_node',3)
enums=['SRPIFKIND\\w+','CSTSP\\w+','MSK\\w+','E0XPACT\\w+']
def comment_mask(s):
    m=[False]*len(s);i=0;n=len(s);depth=0
    while i<n:
        if s.startswith('(*',i): depth+=1;m[i]=m[i+1]=True;i+=2;continue
        if depth and s.startswith('*)',i): depth-=1;m[i]=m[i+1]=True;i+=2;continue
        if depth: m[i]=True;i+=1;continue
        if s.startswith('//',i):
            while i<n and s[i]!='\n': m[i]=True;i+=1
            continue
        if s[i]=='"':
            i+=1
            while i<n and s[i]!='"':
                if s[i]=='\\': i+=1
                i+=1
        i+=1
    return m
def match_close(s,i,open_,close):
    # s[i]==open_ ; return index of matching close, ignoring comments/strings
    d=0;n=len(s);msk=comment_mask(s)
    j=i
    while j<n:
        if msk[j]: j+=1;continue
        c=s[j]
        if c=='"':
            j+=1
            while s[j]!='"':
                if s[j]=='\\': j+=1
                j+=1
        elif c==open_: d+=1
        elif c==close:
            d-=1
            if d==0: return j
        j+=1
    raise Exception('unbalanced')
def strip_comments(s):
    out=[];m=comment_mask(s)
    for i,ch in enumerate(s):
        if not m[i]: out.append(ch)
    return ''.join(out)
def top_split(s,sep=','):
    parts=[];d=0;b='';instr=False
    for ch in s:
        if ch in '([{': d+=1
        if ch in ')]}': d-=1
        if ch==sep and d==0: parts.append(b);b='';continue
        b+=ch
    parts.append(b)
    return parts
def conv_ctor_expr(e,node_default_T=None):
    e=e.strip()
    m=re.match(r'^(\w+)\s*(.*)$',e,re.S)
    if m and m.group(1) in ctors:
        c=m.group(1);rest=m.group(2).strip()
        T=ctors[c][0]
        if rest.startswith('(') and match_close(rest,0,'(',')')==len(rest)-1:
            args=rest[1:-1].strip()
        elif rest=='': args=''
        else: args=rest
        return '%s_%s(%s)'%(T,c,re.sub(r'\s+',' ',args))
    return re.sub(r'\s+',' ',e)
def string_mask(s):
    # the characters of the string literals (a constructor name inside a literal, e.g. in a printer, is text)
    m=[False]*len(s);i=0;n=len(s);msk=comment_mask(s)
    while i<n:
        if msk[i]: i+=1;continue
        if s[i]=='"':
            j=i+1
            while j<n and s[j]!='"':
                if s[j]=='\\': j+=1
                j+=1
            for k in range(i,min(j+1,n)): m[k]=True
            i=j+1
        else: i+=1
    return m
def sub_code(s,pat,fn,flags=0):
    msk=[a or b for a,b in zip(comment_mask(s),string_mask(s))]
    def f(m):
        if msk[m.start()]: return m.group(0)
        return fn(m)
    return re.sub(pat,f,s,flags=flags)
def conv_records(s):
    while True:
        msk=comment_mask(s)
        pos=-1
        for m in re.finditer(r"'\{",s):
            if not msk[m.start()]: pos=m.start();break
        if pos<0: return s
        end=match_close(s,pos+1,'{','}')
        body=strip_comments(s[pos+2:end])
        flds={}
        for p in top_split(body):
            p=p.strip()
            if not p: continue
            k,v=p.split('=',1)
            flds[k.strip()]=v.strip()
        T=field2rec[list(flds)[0]]
        args=[]
        for f in recs[T]:
            v=flds[f]
            if f.endswith('_node') and f==T+'_node': v=conv_ctor_expr(v)
            args.append(re.sub(r'\s+',' ',v))
        s=s[:pos]+'%s_new(%s)'%(T,', '.join(args))+s[end+1:]
def conv_all(s):
    s=conv_records(s)
    # case scrutinee wrapping
    def casef(m):
        scr=m.group(2)
        rest=strip_comments(s_[m.end():m.end()+1500])  # skip comments after [of]
        a=re.match(r'\s*\|?\s*(~?)(\w+)',rest)
        c=a.group(2) if a else ''
        if c in ctors and ctors[c][0] in viewtypes:
            T=ctors[c][0]; return '%s%s_view(%s) of'%(m.group(1),T,scr.strip())
        if c in('Some','None'): return '%sgopt_view(%s) of'%(m.group(1),scr.strip())
        if c in('list_cons','list_nil'): return '%sglist_view(%s) of'%(m.group(1),scr.strip())
        return m.group(0)
    global s_
    s_=s
    s=sub_code(s,r'(case\+?\s+)((?:(?!\bof\b).)+?)\s+of\b',casef,re.S)
    # patterns: constructors after | or of
    def patf(m):
        c=m.group(3)
        if c in ctors: return '%s%s~%s'%(m.group(1),m.group(2),c)
        return m.group(0)
    s=sub_code(s,r'(\||\bof\b)(\s*)(\w+)(?=\s*[\(_ ])',patf)
    # exprs: remaining ctors
    def exf(m):
        c=m.group(1)
        if c in ctors:
            return '%s_%s('%(ctors[c][0],c)
        return m.group(0)
    s=sub_code(s,r'(?<![~\w$])(\w+)\s*\((?!\*)',exf)
    # enums
    for e in enums:
        s=sub_code(s,r'\b(%s)\s*\(\s*\)'%e,lambda m:m.group(1))
    # options and lists
    s=sub_code(s,r'(\||\bof\b)(\s*)Some\s*\(?\s*([\w.]+)\s*\)?\s*=>',lambda m:'%s%s~GOsome(%s) =>'%(m.group(1),m.group(2),m.group(3)))
    s=sub_code(s,r'(\||\bof\b)(\s*)None\s*(\(\s*\)|_)?\s*=>',lambda m:'%s%s~GOnone() =>'%(m.group(1),m.group(2)))
    s=sub_code(s,r'(\||\bof\b)(\s*)list_cons\s*\(([^()]*)\)\s*=>',lambda m:'%s%s~GLcons(%s) =>'%(m.group(1),m.group(2),m.group(3)))
    s=sub_code(s,r'(\||\bof\b)(\s*)list_cons\s*_\s*=>',lambda m:'%s%s~GLcons(_, _) =>'%(m.group(1),m.group(2)))
    s=sub_code(s,r'(\||\bof\b)(\s*)list_nil\s*(\(\s*\)|_)?\s*=>',lambda m:'%s%s~GLnil() =>'%(m.group(1),m.group(2)))
    s=sub_code(s,r'\bNone\s*\(\s*\)',lambda m:'gopt_none()')
    s=sub_code(s,r'\bSome\s*\(',lambda m:'gopt_some(')
    s=sub_code(s,r'\blist_nil\s*\(\s*\)',lambda m:'glist_nil()')
    s=sub_code(s,r'\blist_nil\b(?!\s*\()',lambda m:'glist_nil()')
    s=sub_code(s,r'\blist_cons\s*\(',lambda m:'glist_cons(')
    s=sub_code(s,r'\blist_sing\s*\(',lambda m:'glist_sing(')
    s=s.replace('list_last_opt<','glist_last_opt<')
    zero=[c for c,(t,n) in ctors.items() if n==0]
    s=sub_code(s,r'(?<![~\w$])(%s)\b(?!\s*[\(\w])'%'|'.join(zero),lambda m:'%s_%s()'%(ctors[m.group(1)][0],m.group(1)))
    # fields
    names='|'.join(sorted(list(field2rec)+['token_loc'],key=len,reverse=True))
    s=sub_code(s,r'\.(%s)\b(?!\s*\()'%names,lambda m:'.%s()'%m.group(1))
    return s
if __name__=='__main__':
    src=open(sys.argv[2]).read()
    open(sys.argv[3],'w').write(conv_all(src))
