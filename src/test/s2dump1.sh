# Builds the ATS1 reference driver of the level-2 test (s2dump1) against the ATS1-built objects of $ATS1REF
# (run `make -C $ATS1REF` first). Environment as for pardump1.sh (ATSHOME, ATSHOMERELOC=ATS-0.2.12, a gcc wrapper accepting K&R C).
SRC=${ATS1REF:-${SRC:?ATS1REF not set: an ATS1 build of the old src/ is needed (see src/README)}}
OBJS=""
for m in error intinf counter utils global basics stamp symbol filename location errmsg reader lexbuf lexing lexing_error lexing_print lexing_token label effect fixity_prec fixity_fxty syntax syntax_print tokbuf parsing parsing_util parsing_error parsing_kwds parsing_base parsing_e0xp parsing_sort parsing_staexp parsing_p0at parsing_dynexp parsing_decl parsing_toplevel staexp1 staexp1_print staexp2_sort staexp2 staexp2_scst staexp2_svar staexp2_svvar staexp2_dcon staexp2_hole staexp2_ctxt staexp2_error staexp2_print staexp2_pprint staexp2_szexp staexp2_skexp staexp2_util1 staexp2_util2 staexp2_util3 stacst2 staexp2_solve namespace; do OBJS="$OBJS $SRC/pats_${m}_dats.o"; done
for m in error intinf counter utils global basics stamp symbol filename location errmsg reader lexbuf lexing label fixity effect syntax parsing tokbuf staexp1 staexp2 staexp2_util staexp2_error stacst2 staexp2_solve namespace trans2_env trans3_env dynexp2 dynexp3 patcst2 jsonize dyncst2 symmap symenv dynexp1 trans1_env; do [ -f $SRC/pats_${m}_sats.o ] && OBJS="$OBJS $SRC/pats_${m}_sats.o"; done
# the chunks are compiled in parallel, and only when they changed
for f in s2case1_[0-9][0-9].dats; do
  o=`basename $f .dats`_dats.o
  OBJS="$OBJS $o"
  if [ ! -f $o ] || [ $f -nt $o ] || [ s2common1.hats -nt $o ] || [ s2common2.hats -nt $o ] || [ s2compat1_gen.hats -nt $o ] || [ s2glue1_pre.hats -nt $o ] || [ s2glue1_mid.hats -nt $o ] || [ s2glue1_post.hats -nt $o ] || [ s2case_pre1.hats -nt $o ] || [ `echo $f | sed 's/s2case1_/s2cases_/; s/dats$/hats/'` -nt $o ]; then
    atscc -I$SRC -IATS $SRC -D_ATS_NGC -c $f > /dev/null 2>&1 || echo "s2dump1.sh: $f failed" &
  fi
  while [ `jobs -p | wc -l` -ge ${JOBS:-8} ]; do sleep 1; done
done
wait
atscc -I$SRC -IATS $SRC -D_ATS_NGC -o s2dump1 s2dump1.dats $OBJS -lats -lgmp
