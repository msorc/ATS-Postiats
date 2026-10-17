#!/bin/sh
# usage: ccbcmp.sh OUTDIR   runs OUTDIR/ccb1 (ATS1) and OUTDIR/ccb2 (ATS2) and compares stdout and stderr
OUT=$1
$OUT/ccb1 > $OUT/o1.txt 2> $OUT/e1.txt; r1=$?
$OUT/ccb2 > $OUT/o2.txt 2> $OUT/e2.txt; r2=$?
echo "exit codes: ATS1 $r1, ATS2 $r2; lines: stdout `wc -l < $OUT/o2.txt`, stderr `wc -l < $OUT/e2.txt`"
cmp $OUT/o1.txt $OUT/o2.txt && cmp $OUT/e1.txt $OUT/e2.txt && [ $r1 = $r2 ] && echo "ccb: identical" || exit 1
