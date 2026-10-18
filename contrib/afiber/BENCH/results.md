rm -f bench_ats bench_go bench_dats.c
/home/msorc/install/devel/lang/ats/ATS-Postiats/bin/patscc -D_GNU_SOURCE -DATS_MEMALLOC_LIBC -O2 -o bench_ats bench.dats
cd go && go build -o ../bench_go .
python3 run.py
| benchmark | ops | afiber ns/op | go P=1 ns/op | go P=32 ns/op | afiber vs go P=1 |
|---|---:|---:|---:|---:|---:|
| spawn | 200000 | 639.0 | 286.6 | 258.8 | 2.23x slower |
| yield | 1000000 | 16.0 | 67.9 | 119.1 | 4.23x faster |
| pingpong | 1000000 | 29.9 | 143.9 | 143.7 | 4.82x faster |
| pipe | 5000000 | 13.6 | 35.3 | 36.6 | 2.60x faster |
| fanin | 5000000 | 13.8 | 35.1 | 50.9 | 2.54x faster |
| chain | 30000 | 10820.6 | 1774.1 | 1400.2 | 6.10x slower |
| sieve | 1500 | 41708.0 | 110701.9 | 26413.2 | 2.65x faster |

| memory (parked fibers) | tasks | afiber KB/task | go P=1 KB/task | go P=32 KB/task |
|---|---:|---:|---:|---:|
| mem | 30000 | 4.16 | 2.71 | 3.20 |
