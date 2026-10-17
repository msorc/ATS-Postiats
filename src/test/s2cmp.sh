# s2cmp.sh: runs s2dump1 (ATS1) and s2dump (ATS2) and compares stdout and stderr (the temporary files go to ${TMPDIR:-/tmp})
T=${TMPDIR:-/tmp}
./s2dump1 > $T/s2dump1.out 2> $T/s2dump1.err; r1=$?
./s2dump > $T/s2dump.out 2> $T/s2dump.err; r2=$?
echo "exit codes: ATS1 $r1, ATS2 $r2; lines: stdout `wc -l < $T/s2dump.out`, stderr `wc -l < $T/s2dump.err`"
cmp $T/s2dump1.out $T/s2dump.out && cmp $T/s2dump1.err $T/s2dump.err && [ $r1 = $r2 ] && echo "s2compare: identical"
