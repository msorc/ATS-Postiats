# Whole-file differential test of pats_depgen, pats_taggen and pats_jsonize (tooldump1 = ATS1 src/ vs tooldump = src/): every .sats/.dats/.hats of
# the repository (symbolic links followed) is parsed as pats_main.dats does for `patsopt -s/-d file` and processed in the modes
#   DEP   (--depgen, absolute path),  DEPR (--depgen, path relative to ROOT: the process runs in ROOT),  DEPI (--depgen with the -IATS directories
#   PATSHOME, PATSHOME/prelude, PATSHOME/src),  TAG (--taggen, absolute),  TAGR (--taggen, relative path),  JSN (the JSON of the complete level-0 tree).
# The outputs (stdout and stderr, files restarted after a fatal error as d1chunk.sh does) must be identical. One API line (the functions of pats_jsonize) is added.
#   make toolfiles             (needs the ATS1 environment of pardump1, see Makefile)
# Environment: ROOT (default ../..), JOBS (default 8), CHUNK (files per process, default 40), TOOLDUMP, TOOLDUMP1 (the binaries), MODES (default "DEP DEPR DEPI TAG TAGR JSN"),
#   FILELIST (a file of lines "KIND<TAB>path" instead of all the files), KEEP=1 (keep the outputs).
ROOT=$(cd ${ROOT:-../..} && pwd)
HERE=$(pwd)
TOOLDUMP=$(cd $(dirname ${TOOLDUMP:-./tooldump}) && pwd)/$(basename ${TOOLDUMP:-./tooldump}); TOOLDUMP1=$(cd $(dirname ${TOOLDUMP1:-./tooldump1}) && pwd)/$(basename ${TOOLDUMP1:-./tooldump1})
W=${TMPDIR:-/tmp}/toolfiles.$$
mkdir -p $W
if [ -n "$FILELIST" ]; then cp $FILELIST $W/all.txt; else
(cd $ROOT && find -L . -type f \( -name '*.sats' -o -name '*.dats' -o -name '*.hats' \) -not -path './.git/*' -not -path './src/test/*_?ats.c' | sort) |
  sed "s|^\./||" > $W/files.txt
awk -v root="$ROOT" -v modes="${MODES:-DEP DEPR DEPI TAG TAGR JSN}" 'BEGIN{n=split(modes, m, " ")}
  {for (i=1;i<=n;i++) { k=m[i]; sd=($0 ~ /\.sats$/)?"sta":"dyn"; rel=0
     if (k=="DEPR") {k="DEP"; rel=1} else if (k=="TAGR") {k="TAG"; rel=1}
     printf "%s%s\t%s\n", k, sd, (rel ? $0 : root "/" $0) }}' $W/files.txt | sort -s -k1,1 > $W/all.txt
# a file name without a dot (the target of --depgen is the name itself) and the API line
printf 'DEPdyn\tsrc/test/toolcases/noext\nTAGdyn\tsrc/test/toolcases/noext\nJSNdyn\tsrc/test/toolcases/noext\nAPI\tx\n' >> $W/all.txt
fi
echo "files: $(wc -l < $W/all.txt)"
split -l ${CHUNK:-40} -d -a 4 $W/all.txt $W/c_
cd $ROOT
ls $W/c_???? | xargs -P ${JOBS:-8} -I{} sh -c "sh $HERE/d1chunk.sh $TOOLDUMP1 {} {}.1; sh $HERE/d1chunk.sh $TOOLDUMP {} {}.2; if cmp -s {}.1.o {}.2.o && cmp -s {}.1.e {}.2.e; then wc -c < {}.2.o > {}.nbytes; grep -a -c '^END ' {}.2.o > {}.nend; grep -a -c '^EXN ' {}.2.o > {}.nexn; rm -f {}.1.o {}.2.o {}.1.e {}.2.e; else echo \"DIFFERENT: {}\"; fi" > $W/diffs.txt
cat $W/diffs.txt
sum() { cat $W/c_????.$1 2>/dev/null | awk '{s+=$1} END{print s+0}'; }
echo "output bytes: $(sum nbytes); runs completed: $(sum nend)"
echo "runs ended by a fatal error (EXN): $(sum nexn)"
if test -s $W/diffs.txt; then echo "toolfiles: DIFFERENCES (kept in $W)"; exit 1; fi
if [ -n "$KEEP" ]; then echo "kept in $W"; else rm -rf $W; fi
echo "toolfiles: identical"
