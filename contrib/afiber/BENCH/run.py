#!/usr/bin/env python3
# MS-2026-10: run bench_ats and bench_go (GOMAXPROCS=1 and default), median of REPS runs.
import os, statistics, subprocess, sys
REPS = int(os.environ.get("REPS", "7"))
here = os.path.dirname(os.path.abspath(__file__))
B = [("spawn", 200000), ("yield", 500000), ("pingpong", 500000), ("pipe", 5000000),
     ("fanin", 5000000), ("chain", 30000), ("sieve", 1500), ("mem", 30000)]
CFG = [("afiber", ["./bench_ats"], {}),
       ("go P=1", ["./bench_go"], {"GOMAXPROCS": "1"}),
       ("go P=%d" % os.cpu_count(), ["./bench_go"], {})]
def run(cmd, env, name, n):
    out = subprocess.run(cmd + [name, str(n)], cwd=here, env={**os.environ, **env},
                         capture_output=True, text=True, check=True).stdout.split()
    return int(out[1]), int(out[2]), (float(out[4]) if len(out) > 4 else None)
res = {}
for name, n in B:
    for cname, cmd, env in CFG:
        r = [run(cmd, env, name, n) for _ in range(REPS)]
        ops = r[0][0]
        ns = statistics.median(x[1] for x in r)
        res[name, cname] = (ops, ns, r[0][2] if name != "mem" else statistics.median(x[2] for x in r), min(x[1] for x in r))
        print(name, cname, ops, ns, file=sys.stderr)
print("| benchmark | ops | " + " | ".join(c[0] + " ns/op" for c in CFG) + " | afiber vs go P=1 |")
print("|---|---:|" + "---:|" * (len(CFG) + 1))
for name, n in B:
    if name == "mem": continue
    ops = res[name, CFG[0][0]][0]
    row = [res[name, c[0]][1] / ops for c in CFG]
    print("| %s | %d | " % (name, ops) + " | ".join("%.1f" % v for v in row) + " | %.2fx %s |" % (
        max(row[0]/row[1], row[1]/row[0]), "slower" if row[0] > row[1] else "faster"))
print()
print("| memory (parked fibers) | tasks | " + " | ".join(c[0] + " KB/task" for c in CFG) + " |")
print("|---|---:|" + "---:|" * len(CFG))
print("| mem | %d | " % res["mem", CFG[0][0]][0] + " | ".join("%.2f" % res["mem", c[0]][2] for c in CFG) + " |")
