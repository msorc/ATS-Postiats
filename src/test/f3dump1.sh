# Builds the ATS1 reference driver of the level-2 translation (f3dump1) against the ATS1-built objects of $ATS1REF: all of them but pats_main
# (run `make -C $ATS1REF` first). Environment as for d1dump1.sh (ATSHOME, ATSHOMERELOC=ATS-0.2.12, a gcc wrapper accepting K&R C).
SRC=${ATS1REF:-${SRC:?ATS1REF not set: an ATS1 build of the old src/ is needed (see src/README)}}
OBJS=""
for o in $SRC/pats_*_dats.o; do case $o in */pats_main*_dats.o) ;; *) OBJS="$OBJS $o";; esac; done
for o in $SRC/pats_*_sats.o; do OBJS="$OBJS $o"; done
atscc -I$SRC -IATS $SRC -D_ATS_NGC -o f3dump1 f3dump1.dats $OBJS -lats -lgmp
