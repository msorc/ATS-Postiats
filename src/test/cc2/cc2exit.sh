#!/bin/sh
# usage: cc2exit.sh BIN   runs BIN (cc2_1 or cc2) with CC2EXIT=1..N and prints, for each, fail/ok, the md5 of its stdout and of the stderr lines that are not source positions
BIN=$1
L=`cd \`dirname $0\` && pwd`
T=${TMPDIR:-/tmp}/cc2exit.$$
n=`grep -c '^fun ccx_' $L/cc2_exit.hats`
i=1
while [ $i -le $n ]; do
  CC2EXIT=$i $BIN > $T.o 2> $T.e; s=$?
  if [ $s != 0 ]; then c=fail; else c=ok; fi
  echo "$i $c `md5sum < $T.o | cut -c1-32` `grep -v 'pats_ccomp_\|assert\|match failure\|exit(ATS)\|FatalErrorExn\|uncaught\|^$\|src' $T.e | md5sum | cut -c1-32`"
  i=`expr $i + 1`
done
rm -f $T.o $T.e
