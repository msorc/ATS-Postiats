#!/bin/sh
# usage: cagcov.sh OUTDIR    (after ca2.sh OUTDIR) gcov coverage, by ATS line, of pats_ccomp_emit{,2,3}.dats by the cases (the process runs once more with CAEXIT=1..N:
# the paths that end the process).
OUT=`cd $1 && pwd`
L=`cd \`dirname $0\` && pwd`
W=$OUT/stage2
MODS="pats_ccomp_emit pats_ccomp_emit2 pats_ccomp_emit3"
cd $W/obj || exit 1
rm -rf ../cov; mkdir ../cov; cd ../cov
CF="-DATS_MEMALLOC_LIBC -D_GNU_SOURCE -include alloca.h -I$W -I$PATSHOME -I$PATSHOME/ccomp/runtime -w"
for m in $MODS; do
  patsopt --gline --output $m.c -d ../$m.dats || exit 1
  gcc -O0 --coverage -g $CF -c -o $m.o $m.c || exit 1
done
OBJS=`ls ../obj/*.o | grep -v "pats_ccomp_emit"`
gcc --coverage -o ca2cov $(for m in $MODS; do echo $m.o; done) $OBJS -lgmp || exit 1
./ca2cov > /dev/null 2>&1
n=${CAEXITS:-0}
i=1
while [ $i -le $n ]; do CAEXIT=$i ./ca2cov > /dev/null 2>&1; i=`expr $i + 1`; done
for m in $MODS; do gcov $m.gcda > /dev/null 2>&1; done
python3 $L/../lp/lpgcov.py $(for m in $MODS; do echo $m.dats.gcov; done)
