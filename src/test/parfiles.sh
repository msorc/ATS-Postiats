# Whole-file differential test of the parsers (ATS1 pardump1 vs ATS2 pardump): every .sats/.dats/.hats
# of the repository (symbolic links followed) is parsed with the toplevel parser (.sats: static, others:
# dynamic) and dumped completely (deepdump.hats); the lexer/parser errors are part of the dump.
#   make parfiles            (needs the ATS1 environment of pardump1, see Makefile)
# Environment: ROOT (default ../..), JOBS (default 8), CHUNK (files per process, default 40).
ROOT=$(cd ${ROOT:-../..} && pwd)
W=${TMPDIR:-/tmp}/parfiles.$$
mkdir -p $W
(cd $ROOT && find -L . -type f \( -name '*.sats' -o -name '*.dats' -o -name '*.hats' \) -not -path './.git/*' -not -path './src/test/*_?ats.c' | sort) |
  sed "s|^\./|$ROOT/|" |
  awk '{k=($0 ~ /\.sats$/)?"FILEsta":"FILEdyn"; printf "%s\t%s\n", k, $0}' > $W/all.txt
echo "files: $(wc -l < $W/all.txt)"
split -l ${CHUNK:-40} -d -a 4 $W/all.txt $W/c_
ls $W/c_???? | xargs -P ${JOBS:-8} -I{} sh -c './pardump1 {} > {}.o1 2>&1; ./pardump {} > {}.o2 2>&1; cmp -s {}.o1 {}.o2 || echo "DIFFERENT: {}"' > $W/diffs.txt
cat $W/diffs.txt
echo "output lines: $(cat $W/c_????.o2 | wc -l); files with errors: $(grep -c '^nerr=[1-9]' $W/c_????.o2 | awk -F: '{s+=$2} END{print s}')"
if test -s $W/diffs.txt; then echo "parfiles: DIFFERENCES (kept in $W)"; exit 1; fi
rm -rf $W
echo "parfiles: identical"
