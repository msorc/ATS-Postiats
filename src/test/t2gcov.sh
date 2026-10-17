# t2gcov.sh: the line coverage (by ATS line, gcov) of the modules of the level 2 translation by the files of LIST (default: t2list.txt, the hand-written cases).
# Needs the objects of `make t2dump` (t2obj/) and PATSHOME/PATH of CLAUDE.md. Usage: sh t2gcov.sh [LIST [DIR]]   (DIR: scratch directory, default /tmp/t2cov)
LIST=${1:-t2list.txt}; D=${2:-/tmp/t2cov}; T=`pwd`; S=$T/..; P=${PATSHOME:-$S/..}
MODS="pats_trans2_env pats_trans2_error pats_trans2_sort pats_trans2_staexp pats_trans2_p1at pats_trans2_dynexp pats_trans2_impdec pats_trans2_decl pats_dyncst2"
mkdir -p $D && cd $D && rm -f *.gcda *.gcno *.o *.gcov
for m in $MODS; do
  patsopt --gline -DATS_MEMALLOC_LIBC --output ${m}_dats.c -d $S/$m.dats || exit 1
  gcc -O0 --coverage -g -w -D_GNU_SOURCE -include alloca.h -DATS_MEMALLOC_LIBC -I$S -I$P -I$P/ccomp/runtime -c ${m}_dats.c -o ${m}_dats.o || exit 1
done
OBJS=`cd $T; ls t2obj/*.o | grep -v "pats_trans2_[a-z0-9]*_dats.o\|pats_dyncst2_dats.o" | sed "s|^|$T/|"`
gcc -g --coverage -o t2dump_cov $OBJS pats_*_dats.o -lgmp -lm || exit 1
(cd $T && sh d1chunk.sh $D/t2dump_cov $LIST $D/cov > /dev/null 2>&1)
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
print('%-28s %5d executable lines, %5d covered (%.1f%%); not covered: %s' % (sys.argv[1], ex, hit, 100.0 * hit / ex, ' '.join(miss)))
PYEOF
done
