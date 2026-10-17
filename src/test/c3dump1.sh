# Builds the ATS1 reference driver of the constraint-solver test (c3dump1) against the ATS1-built objects of $SRC (run `make -C $ATS1REF`
# first). Environment as for t3dump1.sh (ATSHOME, ATSHOMERELOC=ATS-0.2.12, a gcc wrapper accepting K&R C). C3KND=int builds the variant with the integers
# of the solver of kind [intknd] (the solver, the myint module and intinf are compiled from the ATS1 sources with -DATS C3NSTRINTKND=intknd).
SRC=${ATS1REF:-${SRC:?ATS1REF not set: an ATS1 build of the old src/ is needed (see src/README)}}
OUT=${OUT:-c3dump1}
OBJS=""
for m in error intinf counter utils global basics stamp symbol filename location errmsg label effect fixity_prec fixity_fxty reader lexbuf lexing lexing_error lexing_print lexing_token syntax syntax_print tokbuf parsing parsing_util parsing_error parsing_kwds parsing_base parsing_e0xp parsing_sort parsing_staexp parsing_p0at parsing_dynexp parsing_decl parsing_toplevel staexp1 staexp1_print dynexp1 dynexp1_print staexp2_sort staexp2 stacst2 staexp2_scst staexp2_svar staexp2_svvar staexp2_dcon staexp2_hole staexp2_ctxt staexp2_error staexp2_solve staexp2_print staexp2_pprint staexp2_szexp staexp2_skexp staexp2_util1 staexp2_util2 staexp2_util3 namespace dynexp2 dynexp2_dcst dynexp2_dmac dynexp2_dvar dynexp2_mapgen dynexp2_print dynexp2_util patcst2 trans3_error dynexp3 dynexp3_print trans3_env trans3_env_svar trans3_env_scst trans3_env_termet trans3_env_effect trans3_env_lamlp trans3_env_print trans3_env_pfman trans3_env_dvar trans3_env_lstate jsonize jsonize_synent2 lintprgm lintprgm_print lintprgm_solve constraint3 constraint3_print constraint3_icnstr constraint3_simplify constraint3_solve constraint3_init constraint3_mapgen constraint3_jsonize; do OBJS="$OBJS $SRC/pats_${m}_dats.o"; done
for m in error intinf counter utils global basics stamp symbol filename location errmsg reader lexbuf lexing label fixity effect syntax parsing tokbuf staexp1 dynexp1 staexp2 staexp2_util staexp2_error stacst2 staexp2_solve namespace trans1_env trans2 trans2_env trans3_env dynexp2 dynexp3 dmacro2 trans3 patcst2 jsonize jsonize_synent2 lintprgm constraint3 dyncst2 symmap symenv; do [ -f $SRC/pats_${m}_sats.o ] && OBJS="$OBJS $SRC/pats_${m}_sats.o"; done
if [ "$C3KND" = int ]; then
  # the integer kind of the solver and of intinf from the ATS1 sources
  W=${W:-c3obj1_int}; mkdir -p $W
  for m in intinf lintprgm_myint constraint3_solve; do
    OBJS=`echo $OBJS | sed "s| $SRC/pats_${m}_dats.o| $W/pats_${m}_dats.o|"`
    atscc -I$SRC -IATS $SRC -D_ATS_NGC -DATS C3NSTRINTKND=intknd -c -o $W/pats_${m}_dats.o $SRC/pats_${m}.dats > $W/$m.log 2>&1 || { echo "c3dump1.sh: $m failed"; head -20 $W/$m.log; exit 1; }
  done
  KFL="-DATS C3NSTRINTKND=intknd"
fi
atscc -I$SRC -IATS $SRC -D_ATS_NGC $KFL -c -o c3drv1.o c3drv.c -I. 2>/dev/null || gcc -c -o c3drv1.o c3drv.c -I.
atscc -I$SRC -IATS $SRC -D_ATS_NGC $KFL -o $OUT c3dump1.dats c3drv1.o $OBJS -lats -lgmp
