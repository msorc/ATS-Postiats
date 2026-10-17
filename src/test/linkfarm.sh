#!/bin/sh
# usage: linkfarm.sh DIR
# Makes DIR (new, empty or absent) a copy of src made of symbolic links to every file of src and, in DIR/test, to every file of src/test: a mutation
# test replaces the link of one module by a mutated copy and rebuilds in DIR (the C names contain the path of the source, so one program is built from one tree).
set -e
D=$1
S=$(cd "$(dirname "$0")/.." && pwd)
mkdir -p "$D/test"
for f in "$S"/*; do
  [ -d "$f" ] && continue
  ln -sf "$f" "$D/$(basename "$f")"
done
for f in "$S"/test/*; do
  [ -d "$f" ] && continue
  ln -sf "$f" "$D/test/$(basename "$f")"
done
