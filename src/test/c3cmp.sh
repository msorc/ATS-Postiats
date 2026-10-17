# c3cmp.sh: runs c3dump / c3dump1 (gmp: c3data_gmp.txt) and c3dump_int / c3dump1_int (intknd: c3data_int.txt) and compares stdout, stderr and the exit status
# (the temporary files go to ${TMPDIR:-/tmp})
T=${TMPDIR:-/tmp}
for k in gmp int; do
  if [ $k = gmp ]; then a=./c3dump; b=./c3dump1; else a=./c3dump_int; b=./c3dump1_int; fi
  $b c3data_$k.txt > $T/c3_1_$k.out 2> $T/c3_1_$k.err; r1=$?
  $a c3data_$k.txt > $T/c3_2_$k.out 2> $T/c3_2_$k.err; r2=$?
  echo "$k: exit codes: ATS1 $r1, ATS2 $r2; lines: stdout `wc -l < $T/c3_2_$k.out`, stderr `wc -l < $T/c3_2_$k.err`; problems `wc -l < c3data_$k.txt`"
  cmp $T/c3_1_$k.out $T/c3_2_$k.out && cmp $T/c3_1_$k.err $T/c3_2_$k.err && [ $r1 = $r2 ] && echo "c3compare ($k): identical"
done
