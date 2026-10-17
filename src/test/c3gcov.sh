# c3gcov.sh: the line coverage (by ATS line, gcov) of the modules of the constraint solver and of the level-2 jsonize (pats_constraint3*, pats_jsonize_synent2) by the
# drivers c3dump (gmp, on the data files c3data_*.txt: DATA) and j2dump (the generated cases). Needs the objects of `make c3dump j2dump` (c3obj/) and PATSHOME/PATH of
# CLAUDE.md. Usage: sh c3gcov.sh [DIR]   (DIR: scratch directory, default /tmp/c3cov)
D=${1:-/tmp/c3cov}; T=`pwd`; S=$T/..; P=${PATSHOME:-$S/..}
MODS="pats_constraint3 pats_constraint3_print pats_constraint3_icnstr pats_constraint3_simplify pats_constraint3_solve pats_constraint3_init pats_constraint3_mapgen pats_constraint3_jsonize pats_jsonize_synent2"
DATA=${DATA:-"$T/c3data_gmp.txt"}
mkdir -p $D && cd $D && rm -f *.gcda *.gcno *.o *.gcov
for m in $MODS; do
  patsopt --gline -DATS_MEMALLOC_LIBC --output ${m}_dats.c -d $S/$m.dats || exit 1
  gcc -O0 --coverage -g -w -D_GNU_SOURCE -include alloca.h -DATS_MEMALLOC_LIBC -I$S -I$P -I$P/ccomp/runtime -c ${m}_dats.c -o ${m}_dats.o || exit 1
done
# the driver is instrumented too: it instantiates the templates of pats_constraint3_icnstr.dats (s3exp2icnstr, ..) for the direct tests
(cd $T && patsopt --gline -DATS_MEMALLOC_LIBC --output $D/c3dump_dats.c -d c3dump.dats) || exit 1
gcc -O0 --coverage -g -w -D_GNU_SOURCE -include alloca.h -DATS_MEMALLOC_LIBC -I$S -I$T -I$P -I$P/ccomp/runtime -c c3dump_dats.c -o c3dump_cov.o || exit 1
# the lists of the modules of the two drivers (the Makefile gives them; the instrumented modules replace the ones of c3obj/)
C3MODS=${C3MODS:?}; J2MODS=${J2MODS:?}
objs() { for m in $1; do case " $MODS " in *" $m "*) ;; *) echo $T/c3obj/${m}_dats.o;; esac; done; }
gcc -g --coverage -o c3dump_cov `objs "$C3MODS"` pats_*_dats.o c3dump_cov.o $T/c3obj/pats_error_sats.o $T/c3obj/c3drv.o -lgmp -lm || exit 1
gcc -g --coverage -o j2dump_cov `objs "$J2MODS"` pats_jsonize_synent2_dats.o $T/c3obj/pats_error_sats.o $T/c3obj/j2dump.o $T/c3obj/j2case_*.o -lgmp -lm || exit 1
for f in $DATA; do ./c3dump_cov $f > /dev/null 2> /dev/null; done
./j2dump_cov > /dev/null 2> /dev/null
# gcov of each unit apart; the counts of a source line are merged (executed in any unit)
for u in $MODS; do
  mkdir -p g_$u; (cd g_$u && rm -f *.gcov && gcov -o .. ../${u}_dats.gcda > /dev/null 2>&1)
done
mkdir -p g_c3dump; (cd g_c3dump && rm -f *.gcov && gcov -o .. ../c3dump_cov.gcda > /dev/null 2>&1)
python3 - $MODS <<'PYEOF'
import sys, glob, os
want = ['%s.dats' % m for m in sys.argv[1:]] + ['pats_constraint3_appenv.hats', 'pats_constraint3.hats']
tot = totc = 0
for f in want:
    cov = {}   # line -> executed in some unit
    for g in glob.glob('g_*/%s.gcov' % f):
        for l in open(g, errors='replace'):
            p = l.split(':', 2)
            if len(p) < 3: continue
            c = p[0].strip(); n = p[1].strip()
            if c == '-' or n == '0' or not n.isdigit(): continue
            n = int(n)
            hit = not (c.startswith('#####') or c.startswith('====='))
            cov[n] = cov.get(n, False) or hit
    if not cov: continue
    miss = sorted(n for n, h in cov.items() if not h)
    ex = len(cov); hit = ex - len(miss); tot += ex; totc += hit
    print('%-42s %5d executable lines, %5d covered (%.1f%%); not covered: %s' % (f, ex, hit, 100.0 * hit / max(ex, 1), ' '.join(map(str, miss))))
print('total: %d of %d executable lines (%.1f%%)' % (totc, tot, 100.0 * totc / max(tot, 1)))
PYEOF
