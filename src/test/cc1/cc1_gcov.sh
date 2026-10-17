#!/bin/sh
# usage: cc1_gcov.sh OUTDIR    (after cc1_2.sh OUTDIR) gcov coverage, by ATS line, of the six modules of the C1 group (the doubles of cc1_impl.hats count as the test)
OUT=`cd $1 && pwd`
L=`cd \`dirname $0\` && pwd`
W=$OUT/stage2
MODS="pats_ccomp_ccompenv pats_ccomp_environ pats_ccomp_caseof pats_ccomp_looping pats_ccomp_trywith pats_ccomp_lazyeval"
cd $W/obj || exit 1
rm -rf ../cov; mkdir ../cov; cd ../cov
CF="-DATS_MEMALLOC_LIBC -D_GNU_SOURCE -include alloca.h -I$W -I$PATSHOME -I$PATSHOME/ccomp/runtime -w"
for m in $MODS; do
  patsopt --gline --output $m.c -d ../$m.dats || exit 1
  gcc -O0 --coverage -g $CF -c -o $m.o $m.c || exit 1
done
OBJS=`ls ../obj/*.o | grep -v "pats_ccomp_ccompenv\|pats_ccomp_environ\|pats_ccomp_caseof\|pats_ccomp_looping\|pats_ccomp_trywith\|pats_ccomp_lazyeval"`
gcc --coverage -o cc1cov $(for m in $MODS; do echo $m.o; done) $OBJS -lgmp || exit 1
./cc1cov > /dev/null 2>&1
n=`sed -n 's/^fun cx_count (): int = //p' $L/cc1_exit.hats`
i=1
while [ $i -le $n ]; do CC1EXIT=$i ./cc1cov > /dev/null 2>&1; i=`expr $i + 1`; done
for m in $MODS; do gcov $m.gcda > /dev/null 2>&1; done
python3 $L/../lp/lpgcov.py $(for m in $MODS; do echo $m.dats.gcov; done)
