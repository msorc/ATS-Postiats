#!/bin/sh
# usage: cc2gcov.sh OUTDIR    (after cc2_2.sh OUTDIR) gcov coverage, by ATS line, of pats_ccomp_{dynexp,decl,claulst}.dats by the scenarios and by the cases that end the process
OUT=`cd $1 && pwd`
L=`cd \`dirname $0\` && pwd`
W=$OUT/stage2
MODS="pats_ccomp_dynexp pats_ccomp_decl pats_ccomp_claulst"
cd $W/obj || exit 1
rm -rf ../cov; mkdir ../cov; cd ../cov
CF="-DATS_MEMALLOC_LIBC -D_GNU_SOURCE -include alloca.h -I$W -I$PATSHOME -I$PATSHOME/ccomp/runtime -w"
for m in $MODS; do
  patsopt --gline --output $m.c -d ../$m.dats || exit 1
  gcc -O0 --coverage -g $CF -c -o $m.o $m.c || exit 1
done
OBJS=`ls ../obj/*.o | grep -v "pats_ccomp_dynexp\|pats_ccomp_decl\|pats_ccomp_claulst"`
gcc --coverage -o cc2cov $(for m in $MODS; do echo $m.o; done) $OBJS -lgmp || exit 1
./cc2cov > /dev/null 2>&1
n=`grep -c '^fun ccx_' $L/cc2_exit.hats`
i=1
while [ $i -le $n ]; do CC2EXIT=$i ./cc2cov > /dev/null 2>&1; i=`expr $i + 1`; done
for m in $MODS; do gcov $m.gcda > /dev/null 2>&1; done
python3 $L/../lp/lpgcov.py $(for m in $MODS; do echo $m.dats.gcov; done)
