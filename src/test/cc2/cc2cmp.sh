#!/bin/sh
# usage: cc2cmp.sh OUTDIR   runs OUTDIR/cc2_1 (ATS1) and OUTDIR/cc2 (ATS2) and compares stdout and stderr; then the cases that end the process (CC2EXIT=k): the stdout must be
# identical, both processes must fail, and the stderr texts that do not mention a source position of the port must be identical. ATS1 runs are limited in memory.
OUT=$1
L=`cd \`dirname $0\` && pwd`
ulimit -v ${CC2MEM:-6000000}
$OUT/cc2_1 > $OUT/o1.txt 2> $OUT/e1.txt; r1=$?
$OUT/cc2 > $OUT/o2.txt 2> $OUT/e2.txt; r2=$?
echo "exit codes: ATS1 $r1, ATS2 $r2; lines: stdout `wc -l < $OUT/o2.txt`, stderr `wc -l < $OUT/e2.txt`"
cmp $OUT/o1.txt $OUT/o2.txt && cmp $OUT/e1.txt $OUT/e2.txt && [ $r1 = $r2 ] && echo "cc2: identical" || exit 1
n=`grep -c '^fun ccx_' $L/cc2_exit.hats`
i=1; bad=0
while [ $i -le $n ]; do
  CC2EXIT=$i $OUT/cc2_1 > $OUT/xo1.txt 2> $OUT/xe1.txt; s1=$?
  CC2EXIT=$i $OUT/cc2 > $OUT/xo2.txt 2> $OUT/xe2.txt; s2=$?
  grep -v 'pats_ccomp_\|assert\|match failure\|exit(ATS)\|FatalErrorExn\|uncaught\|^$' $OUT/xe1.txt > $OUT/xi1.txt; grep -v 'pats_ccomp_\|assert\|match failure\|exit(ATS)\|FatalErrorExn\|uncaught\|^$\|src' $OUT/xe2.txt > $OUT/xi2.txt
  if [ $s1 != 0 ] && [ $s2 != 0 ] && cmp -s $OUT/xo1.txt $OUT/xo2.txt && cmp -s $OUT/xi1.txt $OUT/xi2.txt; then :; else echo "cc2 exit case $i differs (status $s1 $s2)"; bad=1; fi
  i=`expr $i + 1`
done
[ $bad = 0 ] && echo "cc2: the $n cases that end the process agree"
