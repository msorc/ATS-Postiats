# t3g1gcov.sh: the line coverage (by ATS line, gcov) of the three modules of group 1 by the generated cases.
# Run in the build directory DIR/test (after `make -f t3g1.mk t3g1dump`). Usage: sh t3g1gcov.sh [SCRATCH]   (default /tmp/t3g1cov)
D=${1:-/tmp/t3g1cov}; T=`pwd`; S=$T/..; P=${PATSHOME:-$S/..}
MODS="pats_trans3_syncst pats_trans3_util pats_trans3_dynexp_up"
mkdir -p $D && cd $D && rm -f *.gcda *.gcno *.o *.gcov
for m in $MODS; do
  patsopt --gline -DATS_MEMALLOC_LIBC --output ${m}_dats.c -d $S/$m.dats || exit 1
  gcc -O0 --coverage -g -w -D_GNU_SOURCE -include alloca.h -DATS_MEMALLOC_LIBC -I$S -I$P -I$P/ccomp/runtime -c ${m}_dats.c -o ${m}_dats.o || exit 1
done
SKIP=`for m in $MODS; do printf "%s_dats\\\\|" $m; done`
OBJS=`cd $T; (ls t3g1obj/*.o; for m in \`make -s -f t3g1.mk echovar VAR=T3G1MODS\`; do echo modobj/${m}_dats.o; done) | grep -v "${SKIP}NONE" | sed "s|^|$T/|"`
gcc -g --coverage -o t3g1dump_cov $OBJS ${D}/pats_*_dats.o -lgmp -lm || exit 1
(cd $T && $D/t3g1dump_cov > /dev/null 2> /dev/null)
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
