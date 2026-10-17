#!/bin/sh
# usage: caexit.sh BIN   runs BIN (ca1 or ca2) with CAEXIT=1..N (the cases that end the process, ca_exit.hats) and prints, for each, whether it failed, the md5 of its stdout
# and the md5 of the INTERROR lines of its stderr
BIN=$1
L=`cd \`dirname $0\` && pwd`
T=${TMPDIR:-/tmp}/caexit.$$
n=`grep -c '^fun cax_' $L/ca_exit.hats`
i=1
while [ $i -le $n ]; do
  CAEXIT=$i $BIN > $T.o 2> $T.e; s=$?
  if [ $s != 0 ]; then c=fail; else c=ok; fi
  echo "$i $c `md5sum < $T.o | cut -c1-32` `grep INTERROR $T.e | md5sum | cut -c1-32`"
  i=`expr $i + 1`
done
rm -f $T.o $T.e
