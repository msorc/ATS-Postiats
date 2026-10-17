# toolcases.sh BIN: runs BIN (tooldump or tooldump1) on the hand-written cases of toolcases/ (depgen, depgen with -IATS, taggen, jsonize, in the directory
# of the repository, with relative paths) and prints the md5sum of the output (stdout and stderr, the repository directory made anonymous).
# toolcases.md5 is the md5sum of the output of the ATS1 build (tooldump1): `make tooltest` checks the ATS2 build without ATS1.
HERE=$(pwd)
ROOT=$(cd ${ROOT:-../..} && pwd)
BIN=$(cd $(dirname $1) && pwd)/$(basename $1)
W=${TMPDIR:-/tmp}/toolcases.$$
mkdir -p $W
(cd $ROOT && find src/test/toolcases -type f | sort) | while read f; do
  case $f in *.sats) sd=sta;; *) sd=dyn;; esac
  for k in DEP DEPI TAG JSN; do printf '%s%s\t%s\n' $k $sd $f; done
done > $W/list.txt
printf 'API\tx\n' >> $W/list.txt
(cd $ROOT && sh $HERE/d1chunk.sh $BIN $W/list.txt $W/out)
cat $W/out.o $W/out.e | sed "s|$ROOT|ROOT|g" | md5sum | awk '{print $1}'
rm -rf $W
