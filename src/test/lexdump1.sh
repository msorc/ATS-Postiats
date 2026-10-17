# Builds the ATS1 reference token dumper (lexdump1) against the ATS1-built objects of $ATS1REF
# (run `make -C $ATS1REF` first). Environment: ATSHOME (ATS1), ATSHOMERELOC=ATS-0.2.12,
# a gcc wrapper accepting K&R C (see CLAUDE.md / the ats1-bootstrap-build notes).
SRC=${ATS1REF:-${SRC:?ATS1REF not set: an ATS1 build of the old src/ is needed (see src/README)}}
OBJS=""
for m in error intinf counter utils global basics stamp symbol filename location reader lexbuf lexing lexing_error lexing_print lexing_token; do OBJS="$OBJS $SRC/pats_${m}_dats.o"; done
for m in error intinf counter utils global basics stamp symbol filename location reader lexbuf lexing; do [ -f $SRC/pats_${m}_sats.o ] && OBJS="$OBJS $SRC/pats_${m}_sats.o"; done
atscc -I$SRC -IATS $SRC -D_ATS_NGC -o lexdump1 lexdump1.dats $OBJS -lats -lgmp
