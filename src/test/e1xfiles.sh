# Whole-file differential test of the evaluator (e1xdump1 vs e1xdump): every .sats/.dats/.hats of the
# repository (symbolic links followed) is parsed with the toplevel parser and its directives (#define,
# #undef, #if..., #print) are played, the output (the translation of each definition, its value, its
# normal form, the conditions, the errors) must be identical.
#   make e1xfiles            (needs the ATS1 environment of pardump1, see Makefile)
# Environment: ROOT (default ../..), JOBS (default 8), CHUNK (files per process, default 40).
ROOT=$(cd ${ROOT:-../..} && pwd)
W=${TMPDIR:-/tmp}/e1xfiles.$$
mkdir -p $W
(cd $ROOT && find -L . -type f \( -name '*.sats' -o -name '*.dats' -o -name '*.hats' \) -not -path './.git/*' -not -path './src/test/*_?ats.c' | sort) |
  sed "s|^\./|$ROOT/|" |
  awk '{k=($0 ~ /\.sats$/)?"FILEsta":"FILEdyn"; printf "%s\t%s\n", k, $0}' > $W/all.txt
echo "files: $(wc -l < $W/all.txt)"
split -l ${CHUNK:-40} -d -a 4 $W/all.txt $W/c_
ls $W/c_???? | xargs -P ${JOBS:-8} -I{} sh -c 'timeout 120 ./e1xdump1 {} > {}.o1 2>&1; timeout 120 ./e1xdump {} > {}.o2 2>&1; cmp -s {}.o1 {}.o2 || echo "DIFFERENT: {}"' > $W/diffs.txt
cat $W/diffs.txt
echo "output lines: $(cat $W/c_????.o2 | wc -l); directives: $(cat $W/c_????.o2 | grep -a -c '^DEF \|^COND \|^ACT \|^UNDEF ')"
if test -s $W/diffs.txt; then echo "e1xfiles: DIFFERENCES (kept in $W)"; exit 1; fi
rm -rf $W
echo "e1xfiles: identical"
