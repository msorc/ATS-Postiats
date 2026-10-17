#!/bin/sh
# usage: cccmp.sh OUTDIR   runs OUTDIR/cc1 (ATS1) and OUTDIR/cc2 (ATS2) and compares their stdout and stderr
OUT=$1
$OUT/cc1 > $OUT/o1.txt 2> $OUT/e1.txt; r1=$?
$OUT/cc2 > $OUT/o2.txt 2> $OUT/e2.txt; r2=$?
echo "exit codes: ATS1 $r1, ATS2 $r2; lines: stdout `wc -l < $OUT/o2.txt`, stderr `wc -l < $OUT/e2.txt`"
cmp $OUT/o1.txt $OUT/o2.txt && cmp $OUT/e1.txt $OUT/e2.txt && [ $r1 = $r2 ] && echo "cc: identical" || exit 1
L=`cd \`dirname $0\` && pwd`
sh $L/ccexit.sh $OUT/cc1 > $OUT/x1.txt; sh $L/ccexit.sh $OUT/cc2 > $OUT/x2.txt
cmp $OUT/x1.txt $OUT/x2.txt && echo "cc: the `wc -l < $OUT/x2.txt` cases that end the process agree" || { diff $OUT/x1.txt $OUT/x2.txt; exit 1; }
grep -q ok $OUT/x2.txt && { echo "cc: an exit case did not fail"; exit 1; }
true
