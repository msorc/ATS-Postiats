#
# MS-2026-10: afiber vs Go benchmarks.
#   make bench     -> one-worker suite (afiber vs Go P=1 / P=ncpu)
#   make benchmn   -> M:N suite (afiber workers N vs Go GOMAXPROCS=N, N = 1, 2, 4, 8, 16, ncpu)
#   make bench_ats_single, bench_ats_1n -> extra columns of `make bench` (run.py picks them up)
#
PATSHOME ?= $(abspath ../../..)
export PATSHOME

all: bench_ats bench_go
# -pthread -D_ATS_CCOMP_RUNTIME_TRYWITH_NONE_ is what afiber_workers_start(n>1) needs
bench_ats: bench.dats ; $(PATSHOME)/bin/patscc -pthread -D_ATS_CCOMP_RUNTIME_TRYWITH_NONE_ -D_GNU_SOURCE -DATS_MEMALLOC_LIBC -O2 -o $@ $<
# the 1:N build (no -D_ATS_CCOMP_RUNTIME_TRYWITH_NONE_): the exception head is swapped at each switch
bench_ats_1n: bench.dats ; $(PATSHOME)/bin/patscc -D_GNU_SOURCE -DATS_MEMALLOC_LIBC -O2 -o $@ $<
# the compile-time one-worker mode (-DATSCNTRB_AFIBER_SINGLE, in CATS/afiber.cats): no atomics or locks.
# Where the macro is not defined yet, this builds the normal library.
bench_ats_single: bench.dats ; $(PATSHOME)/bin/patscc -D_GNU_SOURCE -DATS_MEMALLOC_LIBC -O2 -DATSCNTRB_AFIBER_SINGLE -o $@ $<
bench_go: go/bench.go ; cd go && go build -o ../bench_go .
bench: all ; python3 run.py
benchmn: all ; python3 run.py mn
cleanall: ; rm -f bench_ats bench_ats_1n bench_ats_single bench_go bench_dats.c
