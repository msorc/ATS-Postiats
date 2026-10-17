#!/bin/sh
# usage: cacmp.sh OUTDIR   runs OUTDIR/ca1 (ATS1) and OUTDIR/ca2 (ATS2) and compares their stdout and stderr (the line of the time stamp is masked); then the cases that
# end the process (CAEXIT=k): the stdout must be identical, both processes must fail (the text of the failure differs: the location of the port's source line, the message
# of the MatchError), and the INTERROR lines of the stderr must be identical.
OUT=$1
L=`cd \`dirname $0\` && pwd`
mask () { sed 's/^\*\* The starting compilation time is: .*$/STARTTIME/'; }
$OUT/ca1 2> $OUT/e1.txt | mask > $OUT/o1.txt; r1=$?
$OUT/ca2 2> $OUT/e2.txt | mask > $OUT/o2.txt; r2=$?
echo "lines: stdout `wc -l < $OUT/o2.txt`, stderr `wc -l < $OUT/e2.txt`"
cmp $OUT/o1.txt $OUT/o2.txt && cmp $OUT/e1.txt $OUT/e2.txt && echo "ca: identical" || exit 1
n=`grep -c '^fun cax_' $L/ca_exit.hats`
i=1; bad=0
while [ $i -le $n ]; do
  CAEXIT=$i $OUT/ca1 > $OUT/xo1.txt 2> $OUT/xe1.txt; s1=$?
  CAEXIT=$i $OUT/ca2 > $OUT/xo2.txt 2> $OUT/xe2.txt; s2=$?
  grep INTERROR $OUT/xe1.txt > $OUT/xi1.txt; grep INTERROR $OUT/xe2.txt > $OUT/xi2.txt
  if [ $s1 != 0 ] && [ $s2 != 0 ] && cmp -s $OUT/xo1.txt $OUT/xo2.txt && cmp -s $OUT/xi1.txt $OUT/xi2.txt; then :; else echo "ca exit case $i differs (status $s1 $s2)"; bad=1; fi
  i=`expr $i + 1`
done
[ $bad = 0 ] && echo "ca: the $n cases that end the process agree"
