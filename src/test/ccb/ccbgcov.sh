#!/bin/sh
# usage: ccbgcov.sh OUTDIR    (after ccb2.sh OUTDIR) gcov coverage, by ATS line, of the five modules of group B by the cases
OUT=`cd $1 && pwd`
L=`cd \`dirname $0\` && pwd`
W=$OUT/stage2
MODS="pats_ccomp_hitype pats_ccomp_hipat pats_ccomp_subst pats_ccomp_template pats_ccomp_main"
cd $W/obj || exit 1
rm -rf ../cov; mkdir ../cov; cd ../cov
CF="-DATS_MEMALLOC_LIBC -D_GNU_SOURCE -include alloca.h -I$W -I$PATSHOME -I$PATSHOME/ccomp/runtime -w"
for m in $MODS; do
  patsopt --gline --output $m.c -d ../$m.dats || exit 1
  gcc -O0 --coverage -g $CF -c -o $m.o $m.c || exit 1
done
OBJS=`ls ../obj/*.o | grep -v "pats_ccomp_hitype\|pats_ccomp_hipat\|pats_ccomp_subst\|pats_ccomp_template\|pats_ccomp_main"`
gcc --coverage -o ccb2cov $(for m in $MODS; do echo $m.o; done) $OBJS -lgmp || exit 1
./ccb2cov > /dev/null 2>&1
for m in $MODS; do gcov $m.gcda > /dev/null 2>&1; done
python3 $L/../lp/lpgcov.py $(for m in $MODS; do echo $m.dats.gcov; done)
