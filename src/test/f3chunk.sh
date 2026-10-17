# f3chunk.sh BIN LIST OUTPREFIX: as d1chunk.sh (runs BIN, f3dump or f3dump1, on the lines of LIST, restarting the process after the line where it
# stopped: an exception or an exit of the translation ends the process, see f3dump.dats), and a file on which the process is killed by its alarm
# of 60 s (exit status 142: the hang of ATS1's p2at_trdn_exist, see PORTING.md G3-9) is recorded as the line "TIMEOUT idx" in the output, identically for both
# builds. stdout and stderr go to OUTPREFIX.o, OUTPREFIX.e (concatenated). EXTRA=time translates without dumping.
BIN=$1; LIST=$2; OUT=$3
: > $OUT.o; : > $OUT.e
start=1
while true; do
  $BIN $LIST $start $EXTRA >> $OUT.o 2> $OUT.err.$$
  rc=$?
  cat $OUT.err.$$ >> $OUT.e
  if [ "$(tail -1 $OUT.o)" = FINISHED ]; then rm -f $OUT.err.$$; break; fi
  last=$(grep -a '^BEGIN ' $OUT.err.$$ | tail -1 | awk '{print $2}')
  rm -f $OUT.err.$$
  if [ -z "$last" ] || [ "$last" -lt "$start" ]; then echo "f3chunk: no progress at $start" >> $OUT.e; break; fi
  if [ $rc -eq 142 ]; then echo "TIMEOUT $last" >> $OUT.o; fi
  start=$((last+1))
done
