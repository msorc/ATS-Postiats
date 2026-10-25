# g2build.sh: builds g2dump (the ATS2 driver of the level-3 translation test, group 2) in src/test, or in the link farm G2STAGE (linkfarm.sh: for the mutation test).
# G2OBJ (default obj), G2EXE (default g2dump), G2CF (extra C flags, e.g. "-g -fsanitize=address") make another variant. The objects are in G2STAGE/test/$G2OBJ and are rebuilt when the module or a header of src is newer. Needs PATSHOME/PATH of CLAUDE.md. JOBS: parallel compilations.
P=${PATSHOME:-`pwd`/../..}
W=$P/src
ST=${G2STAGE:-$W}
cd $W/test && python3 g2_gen.py || exit 1
[ "$ST" = "$W" ] || sh $W/test/linkfarm.sh $ST || exit 1
cd $ST/test || exit 1
OBJ=${G2OBJ:-obj}; EXE=${G2EXE:-g2dump}
# the objects of the modules with the default options are the ones that the Makefile shares among the suites (MODOBJ)
MODOBJ=$OBJ; [ "$ST" = "$W" ] && [ "$OBJ" = obj ] && [ -z "$G2CF" ] && MODOBJ=modobj
mkdir -p $OBJ $MODOBJ
CC="patscc -DATS_MEMALLOC_LIBC -D_GNU_SOURCE -include alloca.h -I$ST $G2CF"
MODS="`cat $W/test/g2mods.txt`"
for m in $MODS; do
  o=$MODOBJ/${m}_dats.o
  if [ ! -f $o ] || [ -n "$FORCE" ] || [ $W/$m.dats -nt $o ] || [ -n "`find $W -maxdepth 1 \( -name '*.sats' -o -name '*.hats' \) -newer $o | head -1`" ]; then
    echo "(cd $MODOBJ && $CC -c -o ${m}_dats.o $ST/$m.dats) || echo FAILED $m"
  fi
done | xargs -P ${JOBS:-8} -I{} sh -c "{}"
[ -f $OBJ/pats_error_sats.o ] || { patsopt --output $OBJ/pats_error_sats.c --static $ST/pats_error.sats && $CC -c -o $OBJ/pats_error_sats.o $OBJ/pats_error_sats.c; }
for f in g2case_[0-9][0-9].dats; do
  b=`basename $f .dats`
  o=$OBJ/$b.o
  h=`echo $b | sed 's/g2case_/g2cases_/'`.hats
  if [ ! -f $o ] || [ $f -nt $o ] || [ $h -nt $o ] || [ -n "`find $W/test -maxdepth 1 \( -name '*.hats' -o -name '*.cats' \) -newer $o | head -1`" ] || [ -n "`find $W -maxdepth 1 \( -name '*.sats' -o -name '*.hats' \) -newer $o | head -1`" ]; then
    echo "$CC -I$ST/test -c -o $o $f || echo FAILED $f"
  fi
done | xargs -P ${JOBS:-8} -I{} sh -c "{}"
$CC -I$ST/test -c -o $OBJ/g2dump.o g2dump.dats || exit 1
OBJS=""
for m in $MODS; do OBJS="$OBJS $MODOBJ/${m}_dats.o"; done
$CC -o $EXE $OBJS $OBJ/pats_error_sats.o $OBJ/g2dump.o $OBJ/g2case_[0-9][0-9].o -lgmp
