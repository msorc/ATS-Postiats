#!/bin/sh
#
# genall.sh: regenerates the files that the .atxt templates of the repository
# stand for, with the new toolchain only (atsdoc, patscc, libatsdoc, no ATS1),
# and compares them with what is expected.
#
#   sh genall.sh [-j N] prelude        regenerates the prelude CODEGEN directories
#                                      (what `make -f codegen/Makefile_atslib` does) in
#                                      a scratch copy and compares every tracked generated
#                                      file with the tracked one (git is not needed)
#   sh genall.sh [-j N] all            all the templates of genall.md5
#   sh genall.sh [-j N] PREFIX...      the templates of genall.md5 whose path starts with
#                                      one of the prefixes (e.g. doc/DISTRIB prelude/SATS)
#   sh genall.sh list                  the templates of genall.md5
#   sh genall.sh clean                 removes the untracked generated programs (*_atxt.*)
#                                      that the runs leave in the directories of the templates
#
# genall.md5: `md5sum  kind  path`, the md5 sum of the text that the template
# generates once the time stamps ("Mon Jan  1 00:00:00 2024") are replaced by
# <TIMESTAMP>. kind is `plain` (atsdoc --outcode X_atxt.dats -i X.atxt > X_atxt.txt;
# patscc ... X_atxt.dats -latsdoc; ./X_atxt.exe) or `dg` (the DOCUGEN documents: the
# program is share/DOCUGEN/htmlgendecl.atxt with the data that atsdoc extracts from the
# document, see the Makefile of the DOCUGEN directories). 402 of the 415 templates are
# there: the md5 sums are those of the text that the ATS1 atsdoc/atscc produce (the 6 chapters of the
# libcairo TUTORIAL and doc/EXAMPLE/EFFECTIVATS/PwTP-bool-vs-prop excepted: ATS1 could not run them
# either, so their sums are those of the new output, see src/PORTING.md; the 21
# Makefile.atxt of the DOCUGEN, CODEGEN and DISTRIB directories excepted: their text
# now names patscc, see src/PORTING.md "atsdoc corpus adaptation"; doc/DISTRIB/ATEXT/
# atslib_libats.atxt excepted too: it packs the afiber files added in 2026-10).
#
# The runs happen in the directories of the templates: the programs they leave (*_atxt.*) are
# ignored by git (`sh genall.sh clean`), but a few tracked, generated programs (the *_atxt.dats of
# contrib/atscntrb/atscntrb-hx-libgmp/SATS/DOCUGEN, ...) are rewritten: restore them with git.
#
# The locale is C, PATSHOME is the canonical root of this repository (the C names of
# the dynload functions contain it: libatsdoc.a and libatsynmark.a must have been built
# with that root). Needs bin/atsdoc, bin/patscc, ccomp/atslib/lib/{libatsdoc.a,
# libatslib.a, libatsopt.a, libatsynmark.a}: `make -f Makefile_devl all bin_atsdoc
# bin_pats2xhtml` and `make -C utils/libatsynmark install`.
#

LC_ALL=C; export LC_ALL
HERE=`dirname "$0"`
PATSHOME=`cd "$HERE/../../.." && pwd -P`; export PATSHOME
PATH="$PATSHOME/bin:$PATH"; export PATH
LIBDIR="$PATSHOME/ccomp/atslib/lib"
LIST="$PATSHOME/utils/atsdoc/TEST/genall.md5"
SELF="$PATSHOME/utils/atsdoc/TEST/genall.sh"

TS_RE='(Sun|Mon|Tue|Wed|Thu|Fri|Sat) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [ 0-9]{1,2} [0-9:]{8} [0-9]{4}'
norm() { sed -E "s/$TS_RE/<TIMESTAMP>/g"; }

SYNLIBS="-I$PATSHOME/src $LIBDIR/libatsynmark.a -latsdoc -latslib $PATSHOME/src/libatsopt.a -lgmp"

# one template of the kind plain: prints the normalised text
run_plain() {
  f=$1; d=`dirname "$f"`; b=`basename "$f" .atxt`
  cd "$PATSHOME/$d" || exit 1
  src="$b.atxt"
  # the chapters of a TUTORIAL include "./ATEXT/..." and are run from the directory above (its Makefile)
  case "$d" in */TUTORIAL/ATEXT) cd .. || exit 1; src="ATEXT/$b.atxt";; esac
  libs="-latsdoc -latslib"
  if grep -qE 'pats2xhtml|libatsynmark|mytextfun|htmlgendecl' "$src"; then libs="$SYNLIBS"; fi
  atsdoc --outcode "${b}_atxt.dats" -i "$src" > "${b}_atxt.txt" 2>/dev/null || exit 1
  patscc -DATS_MEMALLOC_LIBC -o "${b}_atxt.exe" "${b}_atxt.dats" $libs >/dev/null 2>&1 || exit 1
  "./${b}_atxt.exe" 2>/dev/null | norm
}

# one DOCUGEN directory: prints "md5 path" for each document of the list
run_dg() {
  d=$1
  cd "$PATSHOME/$d" || exit 1
  sd="$PATSHOME/share/DOCUGEN"
  tmp=`mktemp -d`
  for m in declatext htmlgendecl; do
    patscc -DATS_MEMALLOC_LIBC -I"$PATSHOME/src" -IATS "$sd" -c "$sd/$m.dats" -o "$tmp/${m}_dats.o" >/dev/null 2>&1 || { echo "FAIL $d (share/DOCUGEN/$m.dats)"; return; }
  done
  if ! atsdoc --outcode htmlgendecl_atxt.dats -i "$sd/htmlgendecl.atxt" > htmlgendecl_atxt.txt 2>/dev/null; then echo "FAIL $d (htmlgendecl.atxt)"; return; fi
  grep "  dg  $d/" "$LIST" | while read sum kind f; do
    b=`basename "$f" .atxt`
    got=missing
    if cat "$b.atxt" | atsdoc --prefix __datatok --outcode htmlgendecl_data_atxt.dats > "${b}_atxt.txt" 2>/dev/null &&
       patscc -DATS_MEMALLOC_LIBC -I"$PATSHOME/src" -IATS "$sd" -o "${b}_atxt.exe" htmlgendecl_atxt.dats \
         "$tmp/declatext_dats.o" "$tmp/htmlgendecl_dats.o" $SYNLIBS >/dev/null 2>&1; then
      got=`"./${b}_atxt.exe" 2>/dev/null | norm | md5sum | cut -d' ' -f1`
    fi
    if [ "$got" = "$sum" ]; then echo "ok $f"; else echo "FAIL $f"; fi
  done
  rm -rf "$tmp"
}

# the prelude CODEGEN directories: regenerated in a scratch copy, compared with the tracked files
do_prelude() {
  tmp=`mktemp -d`
  st=0
  for d in prelude/SATS/CODEGEN prelude/DATS/CODEGEN prelude/DATS/SHARE/CODEGEN prelude/CATS/CODEGEN; do
    mkdir -p "$tmp/$d"
    cp -RL "$PATSHOME/$d/." "$tmp/$d/"
    # the scratch copy has the tracked files; the generated ones are overwritten
    (cd "$tmp/$d" && make -f Makefile.gen >/dev/null 2>&1 && make -f Makefile all >/dev/null 2>&1) ||
      { echo "FAIL $d: the make failed"; st=1; continue; }
    for f in "$PATSHOME/$d"/*.sats "$PATSHOME/$d"/*.dats "$PATSHOME/$d"/*.cats "$PATSHOME/$d"/Makefile; do
      [ -f "$f" ] || continue
      b=`basename "$f"`
      case "$b" in *_atxt.dats) continue;; esac
      [ "$b" = Makefile ] || [ -f "$PATSHOME/$d/${b%.*}.atxt" ] || continue
      norm < "$f" > "$tmp/a.norm"; norm < "$tmp/$d/$b" > "$tmp/b.norm"
      if cmp -s "$tmp/a.norm" "$tmp/b.norm"; then echo "ok $d/$b"; else echo "FAIL $d/$b"; st=1; fi
    done
  done
  rm -rf "$tmp"
  return $st
}

jobs=1
if [ "$1" = "-j" ]; then jobs=$2; shift 2; fi

case "$1" in
  --one-plain) run_plain "$2"; exit;;
  --one-dg) run_dg "$2"; exit;;
  --check-plain)
    sum=$2; f=$3
    got=`sh "$SELF" --one-plain "$f" | md5sum | cut -d' ' -f1`
    if [ "$got" = "$sum" ]; then echo "ok $f"; else echo "FAIL $f"; fi
    exit;;
  list) awk '{print $3}' "$LIST"; exit;;
  clean)
    cd "$PATSHOME" && git ls-files -o -i --exclude-standard -z |
      grep -z -E '_atxt\.(dats|txt|exe)$|_atxt_dats\.c$|_atxt_dats\.o$' | xargs -0 rm -f
    exit;;
  prelude)
    out=`mktemp`; do_prelude > "$out"; st=$?
    cat "$out"; echo "genall prelude: `grep -c '^ok' "$out"` ok, `grep -c '^FAIL' "$out"` failed"
    rm -f "$out"; exit $st;;
  "") echo "usage: sh genall.sh [-j N] prelude | all | list | clean | PREFIX..."; exit 2;;
esac

# the templates to run
sel=`mktemp`
if [ "$1" = all ]; then cp "$LIST" "$sel"; else
  : > "$sel"
  for p in "$@"; do grep -E "  [a-z]+  $p" "$LIST" >> "$sel"; done
fi
res=`mktemp`
# plain templates, in parallel
grep '  plain  ' "$sel" | while read sum kind f; do echo "$sum $f"; done |
  xargs -P "$jobs" -L 1 sh -c 'sh "$0" --check-plain "$1" "$2"' "$SELF" > "$res"
# DOCUGEN directories (the documents of a directory share generated file names: one job per directory)
grep '  dg  ' "$sel" | awk '{print $3}' | sed 's|/[^/]*$||' | sort -u |
  xargs -P "$jobs" -L 1 sh -c 'sh "$0" --one-dg "$1"' "$SELF" >> "$res"
sort "$res" | uniq
nf=`grep -c '^FAIL' "$res"`; no=`grep -c '^ok' "$res"`
echo "genall: $no ok, $nf failed"
rm -f "$sel" "$res"
[ "$nf" = 0 ]
