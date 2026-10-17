# t3g3cmp.sh: runs t3g3dump1 (ATS1) and t3g3dump (ATS2) and compares stdout and stderr (the temporary files go to ${TMPDIR:-/tmp})
T=${TMPDIR:-/tmp}
./t3g3dump1 > $T/t3g3dump1.out 2> $T/t3g3dump1.err; r1=$?
./t3g3dump > $T/t3g3dump.out 2> $T/t3g3dump.err; r2=$?
echo "exit codes: ATS1 $r1, ATS2 $r2; lines: stdout `wc -l < $T/t3g3dump.out`, stderr `wc -l < $T/t3g3dump.err`"
cmp $T/t3g3dump1.out $T/t3g3dump.out && cmp $T/t3g3dump1.err $T/t3g3dump.err && [ $r1 = $r2 ] && echo "t3compare: identical"
