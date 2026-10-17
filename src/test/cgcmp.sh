# cgcmp.sh: runs cgdump1 (ATS1) and cgdump (ATS2) and compares stdout and stderr (the temporary files go to ${TMPDIR:-/tmp});
# then the error tests (CG_ERRTEST=n: an aborting p2at2cst): the exit codes, stdout and the line of the message INTERROR must be the same
# (the text of the failed assertion is the one of the language: not compared)
T=${TMPDIR:-/tmp}
./cgdump1 > $T/cgdump1.out 2> $T/cgdump1.err; r1=$?
./cgdump > $T/cgdump.out 2> $T/cgdump.err; r2=$?
echo "exit codes: ATS1 $r1, ATS2 $r2; lines: stdout `wc -l < $T/cgdump.out`, stderr `wc -l < $T/cgdump.err`"
cmp $T/cgdump1.out $T/cgdump.out && cmp $T/cgdump1.err $T/cgdump.err && [ $r1 = $r2 ] && echo "cgcompare: identical"
for n in 1 2 3; do
  CG_ERRTEST=$n ./cgdump1 > $T/cgerr1.out 2> $T/cgerr1.err; e1=$?
  CG_ERRTEST=$n ./cgdump > $T/cgerr.out 2> $T/cgerr.err; e2=$?
  a=`grep INTERROR $T/cgerr1.err | sed 's/^[^:]*: *//'`; b=`grep INTERROR $T/cgerr.err | sed 's/^[^:]*: *//'`
  if [ $e1 = $e2 ] && cmp -s $T/cgerr1.out $T/cgerr.out && [ "$a" = "$b" ]; then echo "errtest $n: same (exit $e1)"; else echo "errtest $n: DIFFERENT (exit $e1 $e2)"; fi
done
