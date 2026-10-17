#!/bin/sh
# usage: hdcmp.sh OUTDIR   runs OUTDIR/hd1 (ATS1) and OUTDIR/hd2 (ATS2) and compares their stdout and stderr; then the cases that end the process (HDEXIT=k):
# the stdout must be identical, both processes must fail (the text of the failure differs: the location of the port's source line, the message of the MatchError),
# and the INTERROR lines of the stderr must be identical.
OUT=$1
L=`cd \`dirname $0\` && pwd`
$OUT/hd1 > $OUT/o1.txt 2> $OUT/e1.txt; r1=$?
$OUT/hd2 > $OUT/o2.txt 2> $OUT/e2.txt; r2=$?
echo "exit codes: ATS1 $r1, ATS2 $r2; lines: stdout `wc -l < $OUT/o2.txt`, stderr `wc -l < $OUT/e2.txt`"
cmp $OUT/o1.txt $OUT/o2.txt && cmp $OUT/e1.txt $OUT/e2.txt && [ $r1 = $r2 ] && echo "hd: identical" || exit 1
n=`grep -c '^fun hdx_' $L/hd_exit.hats`
i=1; bad=0
while [ $i -le $n ]; do
  HDEXIT=$i $OUT/hd1 > $OUT/xo1.txt 2> $OUT/xe1.txt; s1=$?
  HDEXIT=$i $OUT/hd2 > $OUT/xo2.txt 2> $OUT/xe2.txt; s2=$?
  grep INTERROR $OUT/xe1.txt > $OUT/xi1.txt; grep INTERROR $OUT/xe2.txt > $OUT/xi2.txt
  if [ $s1 != 0 ] && [ $s2 != 0 ] && cmp -s $OUT/xo1.txt $OUT/xo2.txt && cmp -s $OUT/xi1.txt $OUT/xi2.txt; then :; else echo "hd exit case $i differs (status $s1 $s2)"; bad=1; fi
  i=`expr $i + 1`
done
[ $bad = 0 ] && echo "hd: the $n cases that end the process agree"
