# g2cmp.sh: runs g2dump1 (ATS1, here) and g2dump (ATS2, in G2STAGE/test) and compares stdout, stderr and the exit status (the temporary files go to ${TMPDIR:-/tmp})
T=${TMPDIR:-/tmp}; ST=${G2STAGE:-$(cd .. && pwd)}
./g2dump1 > $T/g2dump1.out 2> $T/g2dump1.err; r1=$?
(cd $ST/test && ./g2dump > $T/g2dump.out 2> $T/g2dump.err); r2=$?
echo "exit codes: ATS1 $r1, ATS2 $r2; lines: stdout `wc -l < $T/g2dump.out`, stderr `wc -l < $T/g2dump.err`"
cmp $T/g2dump1.out $T/g2dump.out && cmp $T/g2dump1.err $T/g2dump.err && [ $r1 = $r2 ] && echo "g2compare: identical"
# the process that ends (the last scenario, CG_ERRTEST=1)
CG_ERRTEST=1 ./g2dump1 > $T/g2dump1.xout 2> $T/g2dump1.xerr; r1=$?
(cd $ST/test && CG_ERRTEST=1 ./g2dump > $T/g2dump.xout 2> $T/g2dump.xerr); r2=$?
echo "exit mode: exit codes: ATS1 $r1, ATS2 $r2; lines: stdout `wc -l < $T/g2dump.xout`, stderr `wc -l < $T/g2dump.xerr`"
# the text of the final assertion (assertloc) differs by construction
filt () { sed '/^exit(ATS)/d; /\.dats: [0-9]*(line=/d; /^$/d' $1; }
filt $T/g2dump1.xerr > $T/g2dump1.xerr.f; filt $T/g2dump.xerr > $T/g2dump.xerr.f
cmp $T/g2dump1.xout $T/g2dump.xout && cmp $T/g2dump1.xerr.f $T/g2dump.xerr.f && [ $r1 = $r2 ] && echo "g2compare (exit mode): identical"
