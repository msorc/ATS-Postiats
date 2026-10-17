# Builds the ATS1 reference parser dumper (pardump1) against the ATS1-built objects of $ATS1REF
# (run `make -C $ATS1REF` first). Environment as for lexdump1.sh: ATSHOME (ATS1), ATSHOMERELOC=ATS-0.2.12,
# a gcc wrapper accepting K&R C (see CLAUDE.md / the ats1-bootstrap-build notes).
SRC=${ATS1REF:-${SRC:?ATS1REF not set: an ATS1 build of the old src/ is needed (see src/README)}}
OBJS=""
for m in error intinf counter utils global basics stamp symbol filename location errmsg reader lexbuf lexing lexing_error lexing_print lexing_token label effect fixity_prec fixity_fxty syntax syntax_print tokbuf parsing parsing_util parsing_error parsing_kwds parsing_base parsing_e0xp parsing_sort parsing_staexp parsing_p0at parsing_dynexp parsing_decl parsing_toplevel; do OBJS="$OBJS $SRC/pats_${m}_dats.o"; done
for m in error intinf counter utils global basics stamp symbol filename location errmsg reader lexbuf lexing label fixity effect syntax parsing tokbuf; do [ -f $SRC/pats_${m}_sats.o ] && OBJS="$OBJS $SRC/pats_${m}_sats.o"; done
atscc -I$SRC -IATS $SRC -D_ATS_NGC -o pardump1 pardump1.dats $OBJS -lats -lgmp
