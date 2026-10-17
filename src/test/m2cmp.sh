# m2cmp.sh: runs m2dump1 (ATS1) and m2dump (ATS2) and compares stdout and stderr (the temporary files go to ${TMPDIR:-/tmp})
T=${TMPDIR:-/tmp}
./m2dump1 > $T/m2dump1.out 2> $T/m2dump1.err; r1=$?
./m2dump > $T/m2dump.out 2> $T/m2dump.err; r2=$?
echo "exit codes: ATS1 $r1, ATS2 $r2; lines: stdout `wc -l < $T/m2dump.out`, stderr `wc -l < $T/m2dump.err`"
cmp $T/m2dump1.out $T/m2dump.out && cmp $T/m2dump1.err $T/m2dump.err && [ $r1 = $r2 ] && echo "m2compare: identical"
