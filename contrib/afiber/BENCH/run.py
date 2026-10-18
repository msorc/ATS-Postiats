#!/usr/bin/env python3
# MS-2026-10: run bench_ats and bench_go, median of REPS runs.
#   python3 run.py        one-worker suite: afiber vs Go GOMAXPROCS=1 and default
#                         (env BEFORE=/path/to/old/binary adds a "before M:N" column;
#                          bench_ats_1n, built by `make bench_ats_1n`, adds the 1:N-build column)
#   python3 run.py mn     M:N suite: afiber workers N vs Go GOMAXPROCS=N
import os, statistics, subprocess, sys
here = os.path.dirname(os.path.abspath(__file__))
MN = len(sys.argv) > 1 and sys.argv[1] == "mn"
REPS = int(os.environ.get("REPS", "5" if MN else "7"))
NCPU = os.cpu_count()
NS = sorted(set(n for n in (1, 2, 4, 8, NCPU) if n <= NCPU))
def run_mn(cmd, env, name, n, w):
    out = subprocess.run(cmd + [name, str(n)] + ([str(w)] if cmd[0] == "./bench_ats" else []),
                         cwd=here, env={**os.environ, **env}, capture_output=True, text=True,
                         check=True, timeout=300).stdout.split()
    return int(out[1]), int(out[2])
if MN:
    MB = [("mn_pingpong", 1600000, "16 pairs ping-pong (cap 1), per message"),
          ("mn_pipeline", 2000000, "source -> 8 stages -> sink (cap 128), per item"),
          ("mn_cpu", 512000000, "64 fibers x LCG loop, yield per 1000, per step"),
          ("mn_spawn", 200000, "spawn+join in batches of 1000, per fiber"),
          ("mn_mutex", 2000000, "32 fibers, counter under a mutex, per lock+unlock")]
    res = {}
    for name, n, _ in MB:
        for impl in ("afiber", "go"):
            for w in NS:
                cmd, env = (["./bench_ats"], {}) if impl == "afiber" else (["./bench_go"], {"GOMAXPROCS": str(w)})
                r = [run_mn(cmd, env, name, n, w) for _ in range(REPS)]
                res[name, impl, w] = (r[0][0], statistics.median(x[1] for x in r))
                print(name, impl, w, res[name, impl, w][1] / r[0][0], file=sys.stderr)
    print("ns per op, median of %d runs (afiber: N workers; go: GOMAXPROCS=N)\n" % REPS)
    print("| benchmark | impl | " + " | ".join("N=%d" % w for w in NS) + " |")
    print("|---|---|" + "---:|" * len(NS))
    for name, n, desc in MB:
        for impl in ("afiber", "go"):
            print("| %s | %s | " % (name, impl) + " | ".join("%.1f" % (res[name, impl, w][1] / res[name, impl, w][0]) for w in NS) + " |")
    print("\nspeedup of wall time vs the same implementation at N=1 (above 1 = faster)\n")
    print("| benchmark | impl | " + " | ".join("N=%d" % w for w in NS) + " |")
    print("|---|---|" + "---:|" * len(NS))
    for name, n, desc in MB:
        for impl in ("afiber", "go"):
            print("| %s | %s | " % (name, impl) + " | ".join("%.2f" % (res[name, impl, 1][1] / res[name, impl, w][1]) for w in NS) + " |")
    print("\nafiber time / go time at the same N (above 1 = afiber slower)\n")
    print("| benchmark | " + " | ".join("N=%d" % w for w in NS) + " |")
    print("|---|" + "---:|" * len(NS))
    for name, n, desc in MB:
        print("| %s | " % name + " | ".join("%.2f" % (res[name, "afiber", w][1] / res[name, "go", w][1]) for w in NS) + " |")
    sys.exit(0)
B = [("spawn", 200000), ("yield", 500000), ("pingpong", 500000), ("pipe", 5000000),
     ("fanin", 5000000), ("chain", 30000), ("sieve", 1500), ("mem", 30000)]
CFG = [("afiber", ["./bench_ats"], {})]
if os.path.exists(os.path.join(here, "bench_ats_1n")):
    CFG.append(("afiber 1:N build", ["./bench_ats_1n"], {}))
if os.environ.get("BEFORE"):
    CFG.append(("afiber before M:N", [os.environ["BEFORE"]], {}))
CFG += [
        ("go P=1", ["./bench_go"], {"GOMAXPROCS": "1"}),
        ("go P=%d" % os.cpu_count(), ["./bench_go"], {})]
GO1 = [c[0] for c in CFG].index("go P=1")
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
        max(row[0]/row[GO1], row[GO1]/row[0]), "slower" if row[0] > row[GO1] else "faster"))
print()
print("| memory (parked fibers) | tasks | " + " | ".join(c[0] + " KB/task" for c in CFG) + " |")
print("|---|---:|" + "---:|" * len(CFG))
print("| mem | %d | " % res["mem", CFG[0][0]][0] + " | ".join("%.2f" % res["mem", c[0]][2] for c in CFG) + " |")
