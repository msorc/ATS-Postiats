#!/bin/sh
# run.sh: libatsopt_test (src/libatsopt_ext.c API) against patsopt: same C output for a few files; needs PATSHOME.
# Used by `make -C src libatsopttest`.
cd "$(dirname "$0")" || exit 1
: ${PATSHOME:?}
T=./libatsopt_test; P2=../../patsopt
W=${TMPDIR:-/tmp}/libatsopt.$$; mkdir -p $W
norm() { sed -e 's/^\*\* The starting compilation time is:.*$/STARTTIME/'; }
nbad=0; n=0
check() { # check ARGS... : library main_opt vs patsopt
  n=$((n+1))
  $T "$@" > $W/o1 2> $W/e1; r1=$?
  $P2 "$@" > $W/o2 2> $W/e2; r2=$?
  norm < $W/o1 > $W/o1n; norm < $W/o2 > $W/o2n
  if ! cmp -s $W/o1n $W/o2n; then echo "DIFFERENT stdout: $*"; nbad=$((nbad+1)); fi
  # the library catches the exceptions and reports them as a status
  grep -v '^\[patsopt\] exited\|^exit(ATS): uncaught exception' $W/e1 > $W/e1n; grep -v '^exit(ATS): uncaught exception' $W/e2 > $W/e2n
  if ! cmp -s $W/e1n $W/e2n; then echo "DIFFERENT stderr: $*"; nbad=$((nbad+1)); fi
  if [ $r2 = 0 ]; then grep -q 'exited normally' $W/e1 || { echo "BAD status (normal expected): $*"; nbad=$((nbad+1)); }
  else grep -q 'exited abnormally' $W/e1 || { echo "BAD status (abnormal expected): $*"; nbad=$((nbad+1)); }; fi
}
P=$PATSHOME
check -d $P/doc/EXAMPLE/INTRO/acker1.dats
check -d $P/doc/EXAMPLE/INTRO/fact1.dats
check -s $P/src/pats_symbol.sats
check -d $P/src/pats_basics.dats
check -d $P/prelude/DATS/list_vt.dats
check --typecheck -d $P/src/pats_label.dats
check -d $P/libats/DATS/qlist.dats
printf 'val x : int = true\n' > $W/bad.dats
check -d $W/bad.dats
check -d $W/missing.dats
check --version
# the comarg API: a string input with prefil/postfil, the captured stdout/stderr
$T -i > $W/oi 2> $W/ei; ri=$?
printf 'implement main0 () = println! ("Hello, world!")\n' > $W/hello.dats
printf '// PRE\nimplement main0 () = println! ("Hello, world!")\n// POST\n' > $W/hello2.dats
# the temporary file name is in the C code: compare the lines without it
$P2 -d $W/hello2.dats | norm | grep -v 'hello2\|string2file' > $W/oi2
norm < $W/oi | grep -v 'hello2\|string2file' > $W/oin
n=$((n+1)); cmp -s $W/oin $W/oi2 || { echo "DIFFERENT: -i (strinp, prefil, postfil)"; nbad=$((nbad+1)); }
$T -r $P/doc/EXAMPLE/INTRO/acker1.dats 2> $W/er | norm > $W/or1
$P2 --dynamic $P/doc/EXAMPLE/INTRO/acker1.dats | norm > $W/or2
n=$((n+1)); cmp -s $W/or1 $W/or2 || { echo "DIFFERENT: -r (patsoptres stdout)"; nbad=$((nbad+1)); }
n=$((n+1)); grep -q '^nerr=0$' $W/er || { echo "BAD: -r nerr"; nbad=$((nbad+1)); }
$T -r $W/bad.dats 2> $W/er2 | norm > /dev/null
n=$((n+1)); grep -q '^nerr=[1-9]' $W/er2 || { echo "BAD: -r nerr of a file with errors"; nbad=$((nbad+1)); }
n=$((n+1)); grep -q 'error' $W/er2 || { echo "BAD: -r captured stderr"; nbad=$((nbad+1)); }
echo "libatsopttest: $n checks, $nbad failures"
rm -rf $W
[ $nbad = 0 ]
