# d1chunk.sh BIN LIST OUTPREFIX: runs BIN (d1dump or d1dump1) on the lines of LIST, restarting the process after the line where it
# stopped (an exception or an exit of the translation ends the process, see d1dump.dats); stdout and stderr go to
# OUTPREFIX.o, OUTPREFIX.e (concatenated). EXTRA=time translates without dumping.
BIN=$1; LIST=$2; OUT=$3
: > $OUT.o; : > $OUT.e
start=1
while true; do
  $BIN $LIST $start $EXTRA >> $OUT.o 2> $OUT.err.$$
  cat $OUT.err.$$ >> $OUT.e
  if grep -q '^FINISHED' $OUT.o 2>/dev/null && [ "$(tail -1 $OUT.o)" = FINISHED ]; then rm -f $OUT.err.$$; break; fi
  last=$(grep -a '^BEGIN ' $OUT.err.$$ | tail -1 | awk '{print $2}')
  rm -f $OUT.err.$$
  if [ -z "$last" ] || [ "$last" -lt "$start" ]; then echo "d1chunk: no progress at $start" >> $OUT.e; break; fi
  start=$((last+1))
done
