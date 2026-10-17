# Whole-file differential test of the level-2 translation (d1dump1 = ATS1 src/ vs d1dump = src/): every .sats/.dats/.hats of the
# repository (symbolic links followed) is parsed and translated as pats_main.dats does for `patsopt -s/-d file`, and the
# resulting d1eclist is dumped completely (deepdump.hats, deepdump_t1.hats); the errors (stderr) and the dumps must be identical.
#   make t2files             (needs the ATS1 environment of pardump1, see Makefile)
# Environment: ROOT (default ../..), JOBS (default 8), CHUNK (files per process, default 40), T2DUMP, T2DUMP1 (the binaries),
#   MODES (default "FILE RAW REL": FILE = d0eclist_tr_errck as pats_main does, RAW = d0eclist_tr, so that the trees are dumped also when there are errors, REL = FILE with the option --atsreloc),
#   FILELIST (a file of lines "KIND<TAB>path" instead of all the files), KEEP=1 (keep the outputs).
ROOT=$(cd ${ROOT:-../..} && pwd)
T2DUMP=${T2DUMP:-./t2dump}; T2DUMP1=${T2DUMP1:-./t2dump1}
W=${TMPDIR:-/tmp}/t2files.$$
mkdir -p $W
if [ -n "$FILELIST" ]; then cp $FILELIST $W/all.txt; else
(cd $ROOT && find -L . -type f \( -name '*.sats' -o -name '*.dats' -o -name '*.hats' \) -not -path './.git/*' -not -path './src/test/*_?ats.c' | sort) |
  sed "s|^\./|$ROOT/|" |
  awk -v modes="${MODES:-FILE RAW}" 'BEGIN{n=split(modes, m, " ")} {for (i=1;i<=n;i++) {k=m[i] (($0 ~ /\.sats$/)?"sta":"dyn"); printf "%s\t%s\n", k, $0}}' | sort -s -k1,1 > $W/all.txt
fi
echo "files: $(wc -l < $W/all.txt)"
split -l ${CHUNK:-40} -d -a 4 $W/all.txt $W/c_
ls $W/c_???? | xargs -P ${JOBS:-8} -I{} sh -c "sh ./d1chunk.sh $T2DUMP1 {} {}.1; sh ./d1chunk.sh $T2DUMP {} {}.2; if cmp -s {}.1.o {}.2.o && cmp -s {}.1.e {}.2.e; then wc -c < {}.2.o > {}.nbytes; grep -a -c '^END ' {}.2.o > {}.nend; grep -a -c '^EXN ' {}.2.o > {}.nexn; grep -a -v '^BEGIN' {}.2.e | wc -l > {}.nerr; rm -f {}.1.o {}.2.o {}.1.e {}.2.e; else echo \"DIFFERENT: {}\"; fi" > $W/diffs.txt
cat $W/diffs.txt
sum() { cat $W/c_????.$1 2>/dev/null | awk '{s+=$1} END{print s+0}'; }
echo "dump bytes: $(sum nbytes); files: $(sum nend)"
echo "files with fatal errors (EXN): $(sum nexn)"
echo "stderr lines: $(sum nerr)"
if test -s $W/diffs.txt; then echo "t2files: DIFFERENCES (kept in $W)"; exit 1; fi
if [ -n "$KEEP" ]; then echo "kept in $W"; else rm -rf $W; fi
echo "t2files: identical"
