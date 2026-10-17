# Builds the ATS1 reference driver of the level-3 translation test, group 2 (g2dump1) against the ATS1-built objects of $ATS1REF
# (run `make -C $ATS1REF` first; SRC= the main tree's src). Environment as for pardump1.sh (ATSHOME, ATSHOMERELOC=ATS-0.2.12, a gcc wrapper accepting K&R C).
# The objects of the four modules under test are the ATS1 ones (pats_trans3_{dynexp_dn,appsym,caseof,patcon}_dats.o); the functions of the other groups
# of src/pats_trans3.sats are implemented by the test doubles of g2env.tmpl.
SRC=${ATS1REF:-${SRC:?ATS1REF not set: an ATS1 build of the old src/ is needed (see src/README)}}
OBJS=""
for m in error intinf counter utils global basics stamp symbol filename location errmsg label effect fixity_prec fixity_fxty reader lexbuf lexing lexing_error lexing_print lexing_token syntax syntax_print tokbuf parsing parsing_util parsing_error parsing_kwds parsing_base parsing_e0xp parsing_sort parsing_staexp parsing_p0at parsing_dynexp parsing_decl parsing_toplevel staexp1 staexp1_print dynexp1 dynexp1_print staexp2_sort staexp2 stacst2 staexp2_scst staexp2_svar staexp2_svvar staexp2_dcon staexp2_hole staexp2_ctxt staexp2_error staexp2_solve staexp2_print staexp2_pprint staexp2_szexp staexp2_skexp staexp2_util1 staexp2_util2 staexp2_util3 namespace dynexp2 dynexp2_dcst dynexp2_dmac dynexp2_dvar dynexp2_mapgen dynexp2_print dynexp2_util patcst2 trans3_error dynexp3 dynexp3_print trans3_env trans3_env_svar trans3_env_scst trans3_env_termet trans3_env_effect trans3_env_lamlp trans3_env_print trans3_env_pfman trans3_env_dvar trans3_env_lstate dmacro2 dmacro2_eval0 dmacro2_eval1 dmacro2_print trans3_dynexp_dn trans3_appsym trans3_caseof trans3_patcon; do OBJS="$OBJS $SRC/pats_${m}_dats.o"; done
for m in error intinf counter utils global basics stamp symbol filename location errmsg reader lexbuf lexing label fixity effect syntax parsing tokbuf staexp1 dynexp1 staexp2 staexp2_util staexp2_error stacst2 staexp2_solve namespace trans1_env trans2 trans2_env trans3_env dynexp2 dynexp3 dmacro2 trans3 patcst2 jsonize dyncst2 symmap symenv; do [ -f $SRC/pats_${m}_sats.o ] && OBJS="$OBJS $SRC/pats_${m}_sats.o"; done
# the chunks are compiled in parallel, and only when they changed
for f in g2case1_[0-9][0-9].dats; do
  o=`basename $f .dats`_dats.o
  OBJS="$OBJS $o"
  if [ ! -f $o ] || [ $f -nt $o ] || [ d2common1.hats -nt $o ] || [ d2common2.hats -nt $o ] || [ t3compat1_gen.hats -nt $o ] || [ d2compat1_hand.hats -nt $o ] || [ d2compat1_hand3.hats -nt $o ] || [ t3case_pre1.hats -nt $o ] || [ g2case_pre1.hats -nt $o ] || [ g2common.hats -nt $o ] || [ cgcommon.hats -nt $o ] || [ cgcompat1_gen.hats -nt $o ] || [ t3hand1.hats -nt $o ] || [ t3hand1_leaf.hats -nt $o ] || [ t3common.hats -nt $o ] || [ `echo $f | sed 's/g2case1_/g2cases_/; s/dats$/hats/'` -nt $o ]; then
    atscc -I$SRC -IATS $SRC -D_ATS_NGC -c $f > /dev/null 2>&1 || echo "g2dump1.sh: $f failed" &
  fi
  while [ `jobs -p | wc -l` -ge ${JOBS:-8} ]; do sleep 1; done
done
wait
atscc -I$SRC -IATS $SRC -D_ATS_NGC -o g2dump1 g2dump1.dats $OBJS -lats -lgmp
