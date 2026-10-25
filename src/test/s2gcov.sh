# s2gcov.sh: the line coverage (by ATS line, gcov) of the modules of the slice 2 of the level 2 (util2, util3, stacst2, solve) by the generated cases.
# Needs the objects of `make s2dump` (s2obj/ and modobj/) and PATSHOME/PATH of CLAUDE.md. Usage: sh s2gcov.sh [DIR]   (DIR: scratch directory, default /tmp/s2cov)
D=${1:-/tmp/s2cov}; T=`pwd`; S=$T/..; P=${PATSHOME:-$S/..}
mkdir -p $D && cd $D && rm -f *.gcda *.gcno *.o *.gcov
for m in staexp2_util2 staexp2_util3 stacst2 staexp2_solve; do
  patsopt --gline -DATS_MEMALLOC_LIBC --output pats_${m}_dats.c -d $S/pats_$m.dats || exit 1
  gcc -O0 --coverage -g -w -D_GNU_SOURCE -include alloca.h -DATS_MEMALLOC_LIBC -I$S -I$P -I$P/ccomp/runtime -c pats_${m}_dats.c -o pats_${m}_dats.o || exit 1
done
OBJS=`cd $T; (ls s2obj/*.o; for m in \`make -s echovar VAR=S2MODS\`; do echo modobj/${m}_dats.o; done) | grep -v "util2_dats\|util3_dats\|stacst2_dats\|solve_dats" | sed "s|^|$T/|"`
gcc -g --coverage -o s2dump_cov $OBJS pats_*_dats.o -lgmp -lm || exit 1
(cd $T && $D/s2dump_cov > /dev/null 2> /dev/null)
for m in staexp2_util2 staexp2_util3 stacst2 staexp2_solve; do
  gcov -o . pats_${m}_dats.gcda > /dev/null 2>&1
  python3 - pats_$m.dats.gcov <<'PYEOF'
import sys
ex = hit = 0; miss = []
for l in open(sys.argv[1], errors='replace'):
    p = l.split(':', 2)
    if len(p) < 3: continue
    c = p[0].strip(); n = p[1].strip()
    if c == '-' or n == '0': continue
    ex += 1
    if c.startswith('#####') or c.startswith('====='): miss.append(n)
    else: hit += 1
print('%-28s %5d executable lines, %5d covered (%.1f%%); not covered: %s' % (sys.argv[1], ex, hit, 100.0 * hit / ex, ' '.join(miss)))
PYEOF
done
