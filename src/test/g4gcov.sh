# g4gcov.sh: the line coverage (by ATS line, gcov) of the 7 modules of group 4 by the generated cases of the group 4 test.
# Needs the objects of `make g4dump` (g4obj/) and PATSHOME/PATH of CLAUDE.md. Usage: sh g4gcov.sh [DIR]   (DIR: scratch directory, default /tmp/g4cov)
D=${1:-/tmp/g4cov}; T=`pwd`; S=$T/..; P=${PATSHOME:-$T/../..}
MODS="pats_trans3_decl pats_trans3_looping pats_trans3_assgn pats_trans3_deref pats_trans3_ptrof pats_trans3_viewat pats_trans3_xchng"
mkdir -p $D && cd $D && rm -f *.gcda *.gcno *.o *.gcov
for m in $MODS; do
  patsopt --gline -DATS_MEMALLOC_LIBC --output ${m}_dats.c -d $S/$m.dats || exit 1
  gcc -O0 --coverage -g -w -D_GNU_SOURCE -include alloca.h -DATS_MEMALLOC_LIBC -I$S -I$P -I$P/ccomp/runtime -c ${m}_dats.c -o ${m}_dats.o || exit 1
done
SKIP=`for m in $MODS; do printf "%s_dats\\\\|" $m; done`
OBJS=`cd $T; ls g4obj/*.o | grep -v "${SKIP}NONE" | sed "s|^|$T/|"`
gcc -g --coverage -o g4dump_cov $OBJS pats_*_dats.o -lgmp -lm || exit 1
(cd $T && $D/g4dump_cov > /dev/null 2> /dev/null)
for m in $MODS; do
  gcov -o . ${m}_dats.gcda > /dev/null 2>&1
  python3 - $m.dats.gcov <<'PYEOF'
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
print('%-34s %5d executable lines, %5d covered (%.1f%%); not covered: %s' % (sys.argv[1], ex, hit, 100.0 * hit / ex, ' '.join(miss)))
PYEOF
done
