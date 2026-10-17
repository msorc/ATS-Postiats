# Builds the ATS1 reference driver of the codegen2/patcst2 test (cgdump1) against the ATS1-built objects of $ATS1REF
# (run `make -C $ATS1REF` first). Environment as for d2dump1.sh (ATSHOME, ATSHOMERELOC=ATS-0.2.12, a gcc wrapper accepting K&R C).
SRC=${ATS1REF:-${SRC:?ATS1REF not set: an ATS1 build of the old src/ is needed (see src/README)}}
OBJS=""
for m in error intinf counter utils global basics stamp symbol filename location errmsg reader lexbuf lexing lexing_error lexing_print lexing_token label effect fixity_prec fixity_fxty syntax syntax_print tokbuf parsing parsing_util parsing_error parsing_kwds parsing_base parsing_e0xp parsing_sort parsing_staexp parsing_p0at parsing_dynexp parsing_decl parsing_toplevel staexp1 staexp1_print dynexp1 dynexp1_print staexp2_sort staexp2 staexp2_scst staexp2_svar staexp2_svvar staexp2_dcon staexp2_hole staexp2_ctxt staexp2_error staexp2_print staexp2_pprint staexp2_szexp staexp2_skexp staexp2_util1 staexp2_util2 staexp2_util3 staexp2_solve namespace dynexp2 dynexp2_dcst dynexp2_dmac dynexp2_dvar dynexp2_mapgen dynexp2_print dynexp2_util stacst2 patcst2 codegen2 codegen2_util codegen2_datype codegen2_fprint codegen2_absrec; do OBJS="$OBJS $SRC/pats_${m}_dats.o"; done
for m in error intinf counter utils global basics stamp symbol filename location errmsg reader lexbuf lexing label fixity effect syntax parsing tokbuf staexp1 dynexp1 staexp2 staexp2_util staexp2_error staexp2_solve namespace jsonize trans3_env dynexp3 dyncst2 dynexp2 symmap symenv trans2_env stacst2 patcst2 codegen2; do [ -f $SRC/pats_${m}_sats.o ] && OBJS="$OBJS $SRC/pats_${m}_sats.o"; done
# the chunks are compiled in parallel, and only when they changed
DEPS="cgcommon.hats cgcompat1_hand.hats cgcase_pre1.hats cgenv.cats d2common1.hats d2common2.hats d2compat1_gen.hats d2compat1_hand.hats d2compat1_hand3.hats d2case_pre1.hats"
for f in cgcase1_[0-9][0-9].dats; do
  o=`basename $f .dats`_dats.o
  OBJS="$OBJS $o"
  stale=0
  [ ! -f $o ] && stale=1
  [ $f -nt $o ] && stale=1
  [ `echo $f | sed 's/cgcase1_/cgcases_/; s/dats$/hats/'` -nt $o ] && stale=1
  for d in $DEPS; do [ $d -nt $o ] && stale=1; done
  if [ $stale = 1 ]; then
    atscc -I$SRC -IATS $SRC -D_ATS_NGC -c $f > /dev/null 2>&1 || echo "cgdump1.sh: $f failed" &
  fi
  while [ `jobs -p | wc -l` -ge ${JOBS:-8} ]; do sleep 1; done
done
wait
atscc -I$SRC -IATS $SRC -D_ATS_NGC -o cgdump1 cgdump1.dats $OBJS -lats -lgmp
