# Builds the ATS1 reference driver of the group 4 test (g4dump1: the same objects as g4dump1.sh and the ATS1 objects of the 7 modules of group 4) against the ATS1-built objects of $ATS1REF
# (run `make -C $ATS1REF` first). Environment as for pardump1.sh (ATSHOME, ATSHOMERELOC=ATS-0.2.12, a gcc wrapper accepting K&R C).
SRC=${ATS1REF:-${SRC:?ATS1REF not set: an ATS1 build of the old src/ is needed (see src/README)}}
OBJS=""
for m in error intinf counter utils global basics stamp symbol filename location errmsg label effect fixity_prec fixity_fxty reader lexbuf lexing lexing_error lexing_print lexing_token syntax syntax_print tokbuf parsing parsing_util parsing_error parsing_kwds parsing_base parsing_e0xp parsing_sort parsing_staexp parsing_p0at parsing_dynexp parsing_decl parsing_toplevel staexp1 staexp1_print dynexp1 dynexp1_print staexp2_sort staexp2 stacst2 staexp2_scst staexp2_svar staexp2_svvar staexp2_dcon staexp2_hole staexp2_ctxt staexp2_error staexp2_solve staexp2_print staexp2_pprint staexp2_szexp staexp2_skexp staexp2_util1 staexp2_util2 staexp2_util3 namespace dynexp2 dynexp2_dcst dynexp2_dmac dynexp2_dvar dynexp2_mapgen dynexp2_print dynexp2_util patcst2 trans3_error dynexp3 dynexp3_print trans3_env trans3_env_svar trans3_env_scst trans3_env_termet trans3_env_effect trans3_env_lamlp trans3_env_print trans3_env_pfman trans3_env_dvar trans3_env_lstate trans3_decl trans3_looping trans3_assgn trans3_deref trans3_ptrof trans3_viewat trans3_xchng; do OBJS="$OBJS $SRC/pats_${m}_dats.o"; done
for m in error intinf counter utils global basics stamp symbol filename location errmsg reader lexbuf lexing label fixity effect syntax parsing tokbuf staexp1 dynexp1 staexp2 staexp2_util staexp2_error stacst2 staexp2_solve namespace trans1_env trans2 trans2_env trans3_env dynexp2 dynexp3 dmacro2 trans3 patcst2 jsonize dyncst2 symmap symenv; do [ -f $SRC/pats_${m}_sats.o ] && OBJS="$OBJS $SRC/pats_${m}_sats.o"; done
# the chunks are compiled in parallel, and only when they changed
for f in g4case1_[0-9][0-9].dats; do
  o=`basename $f .dats`_dats.o
  OBJS="$OBJS $o"
  if [ ! -f $o ] || [ $f -nt $o ] || [ d2common1.hats -nt $o ] || [ d2common2.hats -nt $o ] || [ t3compat1_gen.hats -nt $o ] || [ d2compat1_hand.hats -nt $o ] || [ d2compat1_hand3.hats -nt $o ] || [ g4case_pre1.hats -nt $o ] || [ g4hand1.hats -nt $o ] || [ g4state.h -nt $o ] || [ t3hand1.hats -nt $o ] || [ t3hand1_leaf.hats -nt $o ] || [ t3common.hats -nt $o ] || [ g4env1.hats -nt $o ] || [ `echo $f | sed 's/g4case1_/g4cases_/; s/dats$/hats/'` -nt $o ]; then
    atscc -I$SRC -IATS $SRC -D_ATS_NGC -c $f > /dev/null 2>&1 || echo "g4dump1.sh: $f failed" &
  fi
  while [ `jobs -p | wc -l` -ge ${JOBS:-8} ]; do sleep 1; done
done
wait
gcc -c -o g4state.o g4state.c
atscc -I$SRC -IATS $SRC -D_ATS_NGC -o g4dump1 g4dump1.dats g4state.o $OBJS -lats -lgmp
