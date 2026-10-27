#!/bin/sh
# The runner of the suite: `sh run.sh [update] [NAME...]`. See README.
# Each case NAME.dats is typechecked with `patsopt --typecheck -d NAME.dats` (the program is
# run from this directory with a relative path), stdout and stderr together, and the output
# plus a last line "exit N" is compared with expected/NAME.out. `legacy` is run with --legacy-errors.
here=$(cd "$(dirname "$0")" && pwd)
cd "$here" || exit 2
PATSOPT=${PATSOPT:-$here/../../patsopt}
PATSHOME=${PATSHOME:-$(cd "$here/../../.." && pwd)}
export PATSHOME
LC_ALL=C
export LC_ALL
unset PATSOPT_LEGACY_ERRORS
mode=check
if [ "$1" = update ]; then mode=update; shift; fi
if [ $# -gt 0 ]; then names="$*"; else names=$(ls *.dats | sed 's/\.dats$//'); fi
mkdir -p expected
total=0
failed=0
for n in $names; do
  total=$((total + 1))
  flags=
  if [ "$n" = legacy ]; then flags=--legacy-errors; fi
  # patsopt prints the absolute path of the file: make it relative
  { "$PATSOPT" --typecheck $flags -d "$n.dats" 2>&1; echo "exit $?"; } | sed "s|$here/||g" > "actual.$n.tmp"
  if [ $mode = update ]; then
    mv "actual.$n.tmp" "expected/$n.out"
  elif cmp -s "actual.$n.tmp" "expected/$n.out"; then
    rm -f "actual.$n.tmp"
  else
    failed=$((failed + 1))
    echo "FAIL $n"
    diff "expected/$n.out" "actual.$n.tmp" | head -20
    rm -f "actual.$n.tmp"
  fi
done
if [ $mode = update ]; then echo "errcases: $total cases updated"; exit 0; fi
echo "errcases: $total cases, $failed failed"
[ $failed -eq 0 ]
