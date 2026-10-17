# m2exit.sh: the scenarios that end the process (m2_cases.py, exit_scenarios: M2EXIT=1..5 the patterns that eval1_p2at does not support (exitloc),
# 6 and 7 a macro applied insufficiently (the MatchError of ATS1, assertloc here)). The summary of a run is, for n = 1..7, "failed or not", the stdout
# and the messages of the evaluator (the lines "full: ..." of stderr); the other lines of stderr (the location of exitloc, the exception of the
# runtime) differ between ATS1 and ATS2 by construction.
#   sh m2exit.sh               m2dump1 (ATS1) and m2dump (ATS2) must have the same summary
#   sh m2exit.sh ref F         write the summary of m2dump1 into F
#   sh m2exit.sh exit-only F   write the summary of m2dump into F
#   sh m2exit.sh md5           the md5 of the summary of m2dump against the second line of m2dump.md5 (needs no ATS1)
T=${TMPDIR:-/tmp}
summ () {
  for n in 1 2 3 4 5 6 7; do
    M2EXIT=$n $1 > $T/x.out 2> $T/x.err; if [ $? != 0 ]; then echo "== $n: failed"; else echo "== $n: NOT FAILED"; fi
    cat $T/x.out; grep '^full: ' $T/x.err
  done
}
case "$1" in
  ref) summ ./m2dump1 > $2 ;;
  exit-only) summ ./m2dump > $2 ;;
  md5) a=`summ ./m2dump | md5sum | awk '{print $1}'`; b=`sed -n 2p m2dump.md5 | awk '{print $1}'`
       test "$a" = "$b" && echo "m2exit: output as expected" ;;
  *) summ ./m2dump1 > $T/xs1.txt; summ ./m2dump > $T/xs2.txt
     if cmp -s $T/xs1.txt $T/xs2.txt && ! grep -q "NOT FAILED" $T/xs2.txt; then echo "m2exit: identical ($(wc -l < $T/xs2.txt) lines)"; else echo "m2exit: DIFFERENT"; fi ;;
esac
