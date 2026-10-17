#!/bin/sh
# usage: hscover.sh OUTDIR    (after hsdrv2.sh OUTDIR) gcov coverage, by ATS line, of pats_histaexp{,_print,_funlab}.dats by the cases
OUT=`cd $1 && pwd`
L=`cd \`dirname $0\` && pwd`
W=$OUT/stage2
cd $W/obj || exit 1
rm -rf ../cov; mkdir ../cov; cd ../cov
CF="-DATS_MEMALLOC_LIBC -D_GNU_SOURCE -include alloca.h -I$W -I$PATSHOME -I$PATSHOME/ccomp/runtime -w"
for m in pats_histaexp pats_histaexp_print pats_histaexp_funlab; do
  patsopt --gline --output $m.c -d ../$m.dats || exit 1
  gcc -O0 --coverage $CF -c -o $m.o $m.c || exit 1
done
OBJS=`ls ../obj/*.o | grep -v "pats_histaexp"`
gcc --coverage -o hs2cov pats_histaexp.o pats_histaexp_print.o pats_histaexp_funlab.o $OBJS -lgmp || exit 1
./hs2cov > /dev/null
gcov pats_histaexp.gcda pats_histaexp_print.gcda pats_histaexp_funlab.gcda > /dev/null 2>&1
python3 $L/../lp/lpgcov.py pats_histaexp.dats.gcov pats_histaexp_print.dats.gcov pats_histaexp_funlab.dats.gcov
