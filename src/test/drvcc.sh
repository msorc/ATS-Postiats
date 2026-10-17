#!/bin/sh
# usage: REF=... P2=... sh drvcc.sh /absolute/FILE.dats: compiles FILE with patscc (PATSOPT=REF, then PATSOPT=P2), runs both programs
# (stdin /dev/null, 10 s) and compares stdout, stderr, exit status. Prints OK, REFFAIL (the reference does not build it), P2FAIL or DIFF.
D=$(cd $(dirname $0) && pwd)
: ${PATSHOME:=$D/../..}; export PATSHOME; PATH=$PATSHOME/bin:$PATH
: ${REF:=${ATS1REF:-${SRC:?set REF or ATS1REF}}/patsopt}
: ${P2:=$PATSHOME/src/patsopt}
f=$1; k=`echo $f | md5sum | cut -c1-10`; D=${TMPDIR:-/tmp}/drvcc/$k; mkdir -p $D; ulimit -v 16000000
d=`dirname $f`; b=`basename $f .dats`
cd $d || exit 1
FL="-DATS_MEMALLOC_LIBC -I$PATSHOME -I$PATSHOME/src/../ccomp/runtime"
PATSOPT=$REF timeout 120 patscc $FL -o $D/ref.exe $b.dats -latslib -lm -lgmp > $D/ref.log 2>&1; r1=$?
PATSOPT=$P2 timeout 120 patscc $FL -o $D/p2.exe $b.dats -latslib -lm -lgmp > $D/p2.log 2>&1; r2=$?
if [ $r1 != 0 ]; then echo "REFFAIL $f"; exit 0; fi
if [ $r2 != 0 ]; then echo "P2FAIL $f"; exit 0; fi
timeout 10 $D/ref.exe < /dev/null > $D/ref.out 2>$D/ref.err; s1=$?
timeout 10 $D/p2.exe < /dev/null > $D/p2.out 2>$D/p2.err; s2=$?
if [ $s1 = $s2 ] && cmp -s $D/ref.out $D/p2.out && cmp -s $D/ref.err $D/p2.err; then echo "OK $s1 $f"; rm -rf $D; else echo "DIFF $s1 $s2 $f $D"; fi
