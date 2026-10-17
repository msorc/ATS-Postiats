import os, subprocess, sys, shutil, tempfile, re
# usage: python3 -I drvopt.py TABLE   (TABLE: lines `ENV<TAB>ARG<TAB>ARG...`, ENV is - or K=V;K=V or STDIN=1; see comtable.txt, drvtable.txt)
# Runs REF (the ATS1-built patsopt, or $SRC/patsopt) and src/patsopt as `patsopt ARGS` in a copy of drvcases/ and compares
# stdout, stderr, the exit status and the files that the run wrote (-o). PORTING.md, "Driver and ccomp integration".
table = sys.argv[1]
D=os.path.dirname(os.path.abspath(__file__))
HOME=os.environ.get('PATSHOME', os.path.abspath(os.path.join(D,'..','..')))
REF=os.environ.get('REF') or os.path.join((os.environ.get('ATS1REF') or os.environ['SRC']),'patsopt')
P2=os.environ.get('P2') or os.path.join(HOME,'src','patsopt')
SRC=os.path.join(D,'drvcases')
WORK=os.path.join(os.environ.get('TMPDIR','/tmp'),'drvopt.%d'%os.getpid())
def norm(b):
    t=b.decode('utf-8','replace')
    t=re.sub(r'uncaught exception: .*__([A-Za-z_0-9]*)\(\d+\)', r'uncaught exception: \1', t)
    t=re.sub(r'\*\* The starting compilation time is:.*', 'STARTTIME', t)
    t=re.sub(r'exit\(ATS\): \[assert\] failed:[^\n]*\n\n?','',t)
    t=re.sub(r'exit\(ATS\): [^\n]*match failure\.\n','MATCHFAIL\n',t)
    t=re.sub(r'\[/[^\]\n]*pats_[a-z0-9_]*\.dats[^\]\n]*\]: ','[SRC]: ',t)
    return t
def run(binary, env, args):
    d=WORK; shutil.rmtree(d,ignore_errors=True); os.mkdir(d)
    shutil.copytree(SRC, d, dirs_exist_ok=True)
    e=dict(os.environ); e['PATSHOME']=HOME
    for k in ('USER','PATSRELOCROOT','ATSRELOCROOT'): e.pop(k,None)
    e['USER']='tester'
    if env!='-' and env!='STDIN=1':
        for kv in env.split(';'):
            k,v=kv.split('=',1)
            if v=='': e.pop(k,None)
            else: e[k]=v
    try:
        p=subprocess.run(['patsopt']+args, executable=binary, env=e, capture_output=True, timeout=60, cwd=d, input=(open(os.path.join(SRC,'dyn.dats'),'rb').read() if 'STDIN' in env else b''))
        r=(p.returncode, norm(p.stdout), norm(p.stderr))
    except subprocess.TimeoutExpired:
        r=('TIMEOUT','','')
    files={}
    for f in sorted(x for x in os.listdir(d) if os.path.isfile(os.path.join(d,x))):
        if f not in os.listdir(SRC) or open(os.path.join(d,f),'rb').read()!=open(os.path.join(SRC,f),'rb').read():
            files[f]=norm(open(os.path.join(d,f),'rb').read())
    shutil.rmtree(d)
    return r, files
n=0; nd=0
for line in open(table,encoding='utf-8').read().split('\n'):
    if not line: continue
    f=line.split('\t'); env,args=f[0],f[1:]
    if line=='-': args=[]
    a=run(REF,env,args); b=run(P2,env,args); n+=1
    if a!=b:
        nd+=1; print('DIFFERENT: %r'%line); print('  ref:',a[0][0],a[0][1][-200:],a[0][2][-300:],list(a[1])); print('  p2 :',b[0][0],b[0][1][-200:],b[0][2][-300:],list(b[1]))
shutil.rmtree(WORK,ignore_errors=True)
print('lines',n,'different',nd)
