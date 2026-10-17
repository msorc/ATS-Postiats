#!/bin/sh
# usage: cc1_cmp.sh OUTDIR   runs OUTDIR/cc1_1 (ATS1) and OUTDIR/cc1_2 (ATS2) and compares their stdout, stderr and exit status; then the cases that end the process (CC1EXIT=k):
# the stdout must be identical and both processes must fail (the text of the failure differs: the location of the failing line, the message of the MatchError)
OUT=$1
L=`cd \`dirname $0\` && pwd`
$OUT/cc1_1 > $OUT/o1.txt 2> $OUT/e1.txt; r1=$?
$OUT/cc1_2 > $OUT/o2.txt 2> $OUT/e2.txt; r2=$?
echo "exit codes: ATS1 $r1, ATS2 $r2; lines: stdout `wc -l < $OUT/o2.txt`, stderr `wc -l < $OUT/e2.txt`"
cmp $OUT/o1.txt $OUT/o2.txt && cmp $OUT/e1.txt $OUT/e2.txt && [ $r1 = $r2 ] && echo "cc1: identical" || exit 1
n=`sed -n 's/^fun cx_count (): int = //p' $L/cc1_exit.hats`
i=1; bad=0
while [ $i -le $n ]; do
  CC1EXIT=$i $OUT/cc1_1 > $OUT/xo1.txt 2> $OUT/xe1.txt; s1=$?
  CC1EXIT=$i $OUT/cc1_2 > $OUT/xo2.txt 2> $OUT/xe2.txt; s2=$?
  if [ $s1 != 0 ] && [ $s2 != 0 ] && cmp -s $OUT/xo1.txt $OUT/xo2.txt; then :; else echo "cc1 exit case $i differs (status $s1 $s2)"; bad=1; fi
  i=`expr $i + 1`
done
[ $bad = 0 ] && echo "cc1: the $n cases that end the process agree"
