#!/bin/sh
# usage: sh drvfiles.sh [LIST [JOBS]]   (PORTING.md, "Driver and ccomp integration")
# Runs the ATS1-built reference compiler and src/patsopt on every file of LIST (default: all .sats/.dats/.hats of the repository,
# paths relative to the repository root) as `patsopt [OPTS] -s|-d FILE` and compares stdout (the C code), stderr and the exit status.
# Environment: PATSHOME (the repository root, default: ../..), REF (default: src/patsopt of the main tree given by SRC),
# P2 (default: src/patsopt), OPTS (extra options, e.g. --typecheck), FORCEMODE (-s, -d or -dd for every file),
# NOULIMIT=1 (an AddressSanitizer build of patsopt does not work with ulimit -v).
# Normalized: the time stamp of the C code, the file and tag of an uncaught exception (patsopt prints the ATS1 text, with the mangled path of src/
# and its own tag), the location of an aborted assertion / MatchError (the location is that of the source of the compiler; patsopt prints no empty
# line after a failed assertion), the `[file]:` tag of --debug messages.
# Prints one line `STATUS ref-exit p2-exit file key` per file (OK, REFTIMEOUT, STATUS, STDOUT, STDERR) and a summary.
D=$(cd $(dirname $0) && pwd)
cd "${PATSHOME:-$D/../..}" || exit 1
PATSHOME=$(pwd); export PATSHOME
: ${P2:=$PATSHOME/src/patsopt}
export REF P2
if [ -z "$REF" ]; then REF=${ATS1REF:-${SRC:?set REF or ATS1REF}}/patsopt; fi
: ${P2:=$PATSHOME/src/patsopt}
export REF P2
if [ "$1" = "--one" ]; then W=$2; f=$3; else
LIST=${1:-}
W=${TMPDIR:-/tmp}/drvfiles.$$; mkdir -p $W
if [ -z "$LIST" ]; then
  LIST=$W/list; find prelude libats doc contrib utils src -type f \( -name '*.sats' -o -name '*.dats' -o -name '*.hats' \) -not -path 'src/patsopt*' | sort > $LIST
fi
cat $LIST | xargs -P ${2:-8} -n 1 sh $D/drvfiles.sh --one $W | tee $W/result
awk '{print $1}' $W/result | sort | uniq -c
echo "(outputs of the failing files are kept in $W)"; exit 0
fi
case "$f" in *.sats) m=-s;; *) m=-d;; esac; [ -n "$FORCEMODE" ] && m=$FORCEMODE
k=$(echo "$f" | md5sum | cut -c1-12)
[ -z "$NOULIMIT" ] && ulimit -v 16000000
norm() { sed -e 's/^exit(ATS): \[assert\] failed:.*/ASSERTFAIL/' -e 's/^exit(ATS): .*: funarg match failure\.$/FUNARGFAIL/' -e 's/^exit(ATS): .*: match failure\.$/MATCHFAIL/' |
  sed -e '/^ASSERTFAIL$/{n;/^$/d;}' |
  sed -e 's/uncaught exception: .*__\([A-Za-z_0-9]*\)([0-9]*)/uncaught exception: \1/' -e 's/^\*\* The starting compilation time is:.*$/STARTTIME/' \
      -e 's/\[\/[^]]*pats_[a-z0-9_]*\.dats[^]]*\]: /[SRC]: /'; }
timeout 60 $REF $OPTS $m "$f" > $W/$k.o1 2> $W/$k.e1; r1=$?
timeout 60 $P2 $OPTS $m "$f" > $W/$k.o2 2> $W/$k.e2; r2=$?
norm < $W/$k.o1 > $W/$k.o1n; norm < $W/$k.o2 > $W/$k.o2n; norm < $W/$k.e1 > $W/$k.e1n; norm < $W/$k.e2 > $W/$k.e2n
st=OK
if [ $r1 = 124 ]; then st=REFTIMEOUT
elif [ $r1 != $r2 ]; then st=STATUS
elif ! cmp -s $W/$k.o1n $W/$k.o2n; then st=STDOUT
elif ! cmp -s $W/$k.e1n $W/$k.e2n; then st=STDERR
fi
echo "$st $r1 $r2 $f $k"
if [ $st = OK -o $st = REFTIMEOUT ]; then rm -f $W/$k.*; fi
