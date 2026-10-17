#!/bin/sh
# usage: ccexit.sh BIN   runs BIN (cc1 or cc2) with CCEXIT=1..N (the cases that end the process, cc_exit.hats) and prints, for each, whether it failed, the md5 of its stdout
# and the md5 of the INTERROR lines of its stderr (the other texts of the failure differ between ATS1 and ATS2: the location of the port's source line, the message of a MatchError)
BIN=$1
L=`cd \`dirname $0\` && pwd`
T=${TMPDIR:-/tmp}/ccexit.$$
n=`grep -c '^fun ccx_' $L/cc_exit.hats`
i=1
while [ $i -le $n ]; do
  CCEXIT=$i $BIN > $T.o 2> $T.e; s=$?
  if [ $s != 0 ]; then c=fail; else c=ok; fi
  echo "$i $c `md5sum < $T.o | cut -c1-32` `grep INTERROR $T.e | md5sum | cut -c1-32`"
  i=`expr $i + 1`
done
rm -f $T.o $T.e
