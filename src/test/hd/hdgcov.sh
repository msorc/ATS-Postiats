#!/bin/sh
# usage: hdgcov.sh OUTDIR    (after hd2.sh OUTDIR) gcov coverage, by ATS line, of pats_hidynexp{,_print,_util}.dats and pats_typerase_{error,staexp,dynexp,decl}.dats
# by the cases (the process runs once more with HDEXIT=1..N: the paths that end the process).
OUT=`cd $1 && pwd`
L=`cd \`dirname $0\` && pwd`
W=$OUT/stage2
MODS="pats_hidynexp pats_hidynexp_print pats_hidynexp_util pats_typerase_error pats_typerase_staexp pats_typerase_dynexp pats_typerase_decl"
cd $W/obj || exit 1
rm -rf ../cov; mkdir ../cov; cd ../cov
CF="-DATS_MEMALLOC_LIBC -D_GNU_SOURCE -include alloca.h -I$W -I$PATSHOME -I$PATSHOME/ccomp/runtime -w"
for m in $MODS; do
  patsopt --gline --output $m.c -d ../$m.dats || exit 1
  gcc -O0 --coverage -g $CF -c -o $m.o $m.c || exit 1
done
OBJS=`ls ../obj/*.o | grep -v "pats_hidynexp\|pats_typerase"`
gcc --coverage -o hd2cov $(for m in $MODS; do echo $m.o; done) $OBJS -lgmp || exit 1
./hd2cov > /dev/null 2>&1
n=${HDEXITS:-0}
i=1
while [ $i -le $n ]; do HDEXIT=$i ./hd2cov > /dev/null 2>&1; i=`expr $i + 1`; done
for m in $MODS; do gcov $m.gcda > /dev/null 2>&1; done
python3 $L/../lp/lpgcov.py $(for m in $MODS; do echo $m.dats.gcov; done)
