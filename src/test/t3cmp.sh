# t3cmp.sh: runs t3dump1 (ATS1) and t3dump (ATS2) and compares stdout and stderr (the temporary files go to ${TMPDIR:-/tmp})
T=${TMPDIR:-/tmp}
./t3dump1 > $T/t3dump1.out 2> $T/t3dump1.err; r1=$?
./t3dump > $T/t3dump.out 2> $T/t3dump.err; r2=$?
echo "exit codes: ATS1 $r1, ATS2 $r2; lines: stdout `wc -l < $T/t3dump.out`, stderr `wc -l < $T/t3dump.err`"
cmp $T/t3dump1.out $T/t3dump.out && cmp $T/t3dump1.err $T/t3dump.err && [ $r1 = $r2 ] && echo "t3compare: identical"
