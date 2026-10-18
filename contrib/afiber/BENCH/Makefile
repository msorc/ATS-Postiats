#
# MS-2026-10: afiber vs Go benchmarks. make bench -> table on stdout.
#
PATSHOME ?= $(abspath ../../..)
export PATSHOME

all: bench_ats bench_go
bench_ats: bench.dats ; $(PATSHOME)/bin/patscc -D_GNU_SOURCE -DATS_MEMALLOC_LIBC -O2 -o $@ $<
bench_go: go/bench.go ; cd go && go build -o ../$@ .
bench: all ; python3 run.py
cleanall: ; rm -f bench_ats bench_go bench_dats.c
