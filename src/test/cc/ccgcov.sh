#!/bin/sh
# usage: ccgcov.sh OUTDIR    (after cc2.sh OUTDIR) gcov coverage, by ATS line, of the core modules of ccomp by the cases (the process runs once more with CCEXIT=1..N)
OUT=`cd $1 && pwd`
L=`cd \`dirname $0\` && pwd`
W=$OUT/stage2
MODS="pats_ccomp pats_ccomp_print pats_ccomp_tmplab pats_ccomp_tmpvar pats_ccomp_d2env pats_ccomp_funlab pats_ccomp_funent pats_ccomp_util pats_ccomp_instrseq"
cd $W/obj || exit 1
rm -rf ../cov; mkdir ../cov; cd ../cov
CF="-DATS_MEMALLOC_LIBC -D_GNU_SOURCE -include alloca.h -I$W -I$PATSHOME -I$PATSHOME/ccomp/runtime -w"
for m in $MODS; do
  patsopt --gline --output $m.c -d ../$m.dats || exit 1
  gcc -O0 --coverage -g $CF -c -o $m.o $m.c || exit 1
done
OBJS=`ls ../obj/*.o | grep -v "pats_ccomp"`
gcc --coverage -o cc2cov $(for m in $MODS; do echo $m.o; done) $OBJS -lgmp || exit 1
./cc2cov > /dev/null 2>&1
n=${CCEXITS:-0}
i=1
while [ $i -le $n ]; do CCEXIT=$i ./cc2cov > /dev/null 2>&1; i=`expr $i + 1`; done
for m in $MODS; do gcov $m.gcda > /dev/null 2>&1; done
python3 $L/../lp/lpgcov.py $(for m in $MODS; do echo $m.dats.gcov; done)
