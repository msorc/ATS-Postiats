# d2cmp.sh: runs d2dump1 (ATS1) and d2dump (ATS2) and compares stdout and stderr (the temporary files go to ${TMPDIR:-/tmp})
T=${TMPDIR:-/tmp}
./d2dump1 > $T/d2dump1.out 2> $T/d2dump1.err; r1=$?
./d2dump > $T/d2dump.out 2> $T/d2dump.err; r2=$?
echo "exit codes: ATS1 $r1, ATS2 $r2; lines: stdout `wc -l < $T/d2dump.out`, stderr `wc -l < $T/d2dump.err`"
cmp $T/d2dump1.out $T/d2dump.out && cmp $T/d2dump1.err $T/d2dump.err && [ $r1 = $r2 ] && echo "d2compare: identical"
