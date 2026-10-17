# t3cmp.sh: runs j2dump1 (ATS1) and j2dump (ATS2) and compares stdout and stderr (the temporary files go to ${TMPDIR:-/tmp})
T=${TMPDIR:-/tmp}
./j2dump1 > $T/j2dump1.out 2> $T/j2dump1.err; r1=$?
./j2dump > $T/j2dump.out 2> $T/j2dump.err; r2=$?
echo "exit codes: ATS1 $r1, ATS2 $r2; lines: stdout `wc -l < $T/j2dump.out`, stderr `wc -l < $T/j2dump.err`"
cmp $T/j2dump1.out $T/j2dump.out && cmp $T/j2dump1.err $T/j2dump.err && [ $r1 = $r2 ] && echo "j2compare: identical"
