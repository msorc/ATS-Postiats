#!/bin/sh
# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
#
# Checks the hygiene of the tracked files (no build needed):
#  1. no tracked symbolic link is dangling (a fresh clone must not have
#     broken links);
#  2. no tracked text file contains an absolute home directory of a
#     developer (/home/<name>/).
# Run it from anywhere inside the repository.
#
cd "$(git rev-parse --show-toplevel)" || exit 2
status=0

echo "check: dangling symbolic links"
git ls-files -s | awk '$1 == 120000 { sub(/^[^\t]*\t/, ""); print }' |
while IFS= read -r f; do
  if [ ! -e "$f" ]; then
    echo "  dangling: $f -> $(readlink "$f")"
    echo x > .hygiene_failed.tmp
  fi
done
if [ -f .hygiene_failed.tmp ]; then rm -f .hygiene_failed.tmp; status=1; fi

echo "check: absolute developer paths (/home/...)"
# the pattern is assembled so that this file does not match itself
pat="/home""/[A-Za-z0-9_.-]"
# allow-list (justified):
#  - this script (it names the pattern);
#  - doc/BOOK/ATS2FUNCRASH/LECTURE/01/main.atxt: the text of the lecture shows
#    an example installation path of a student (its md5 is in genall.md5);
#  - src/test/ca/ca_stub.c: a fake file name, a test datum.
hits=$(git ls-files -z | xargs -0 grep -I -l -e "$pat" 2>/dev/null |
       grep -v -e '^share/SCRIPT/check_tree_hygiene\.sh$' \
               -e '^doc/BOOK/ATS2FUNCRASH/LECTURE/01/main\.atxt$' \
               -e '^src/test/ca/ca_stub\.c$' || true)
if [ -n "$hits" ]; then
  echo "$hits" | sed 's/^/  absolute path in: /'
  status=1
fi

if [ $status -eq 0 ]; then echo "tree hygiene: ok"; else echo "tree hygiene: FAILED"; fi
exit $status
