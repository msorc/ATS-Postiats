# Builds the ATS1 reference driver of the level-1 translation (d1dump1) against the ATS1-built objects of $ATS1REF
# (run `make -C $ATS1REF` first). Environment as for pardump1.sh.
SRC=${ATS1REF:-${SRC:?ATS1REF not set: an ATS1 build of the old src/ is needed (see src/README)}}
OBJS=""
for m in error intinf counter utils global basics stamp symbol filename location errmsg reader lexbuf lexing lexing_error lexing_print lexing_token label effect fixity_prec fixity_fxty syntax syntax_print tokbuf parsing parsing_util parsing_error parsing_kwds parsing_base parsing_e0xp parsing_sort parsing_staexp parsing_p0at parsing_dynexp parsing_decl parsing_toplevel staexp1 staexp1_print dynexp1 dynexp1_print e1xpval e1xpval_error symmap symenv trans1_env trans1_e0xp trans1_error trans1_effect trans1_sort trans1_staexp trans1_p0at trans1_syndef trans1_dynexp trans1_decl filename_reloc; do OBJS="$OBJS $SRC/pats_${m}_dats.o"; done
for m in error intinf counter utils global basics stamp symbol filename location errmsg reader lexbuf lexing label fixity effect syntax parsing tokbuf staexp1 dynexp1 e1xpval symmap symenv trans1_env trans1; do [ -f $SRC/pats_${m}_sats.o ] && OBJS="$OBJS $SRC/pats_${m}_sats.o"; done
atscc -I$SRC -IATS $SRC -D_ATS_NGC -o d1dump1 d1dump1.dats $OBJS -lats -lgmp
