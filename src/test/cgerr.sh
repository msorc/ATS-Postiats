# cgerr.sh PROG: the output of the error tests (stdout, exit status, the line INTERROR of stderr): one md5 (cgdump.md5, line 2)
for n in 1 2 3; do
  CG_ERRTEST=$n $1 2> cgerr.tmp; echo "exit $?"
  grep INTERROR cgerr.tmp | sed 's/^[^:]*: *//'
done | md5sum | awk '{print $1}'
rm -f cgerr.tmp
