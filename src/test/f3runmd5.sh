# f3runmd5.sh BIN CHUNKFILE OUTDIR: runs f3chunk.sh BIN on CHUNKFILE and keeps only the md5 of the stdout and of the normalized stderr (OUTDIR/<chunk>.md5):
# the dumps are GBs (f3mutate.py, f3files). The temporary outputs are in $TMPDIR (default /tmp) and removed at once.
BIN=$1; C=$2; OUT=$3
n=$(basename $C)
t=${TMPDIR:-/tmp}/f3run.$$.$n
mkdir -p $OUT
sh ./f3chunk.sh $BIN $C $t
a=$(md5sum < $t.o | cut -d' ' -f1)
b=$(sh ./f3norm.sh $t.e | md5sum | cut -d' ' -f1)
echo "$a $b" > $OUT/$n.md5
rm -f $t.o $t.e
