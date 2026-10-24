#!/bin/sh
# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
#
# `make install PREFIX=/usr DESTDIR=<tmp>/destdir` of a built tree (run from the
# root of the repository after `make`), a hello world with the staged tree, and
# `make uninstall`, which must leave nothing in DESTDIR.
#
#   destdir_install.sh <tmp-dir>
#
set -eu
tmp=$1
stage=$tmp/destdir
rm -rf "$stage"
mkdir -p "$stage"
make install PREFIX=/usr DESTDIR="$stage"
test -x "$stage/usr/bin/patscc"
test -x "$stage/usr/bin/patsopt"
#
# the wrappers of a staged tree name PREFIX (/usr), not DESTDIR: PATSHOME is
# given to them, as a packager's test would do
#
home=$(echo "$stage"/usr/lib/ats2-postiats-*)
test -d "$home"
printf 'implement main0 () = println! ("Hello, world!")\n' > "$tmp/hello-destdir.dats"
(cd "$tmp" && env PATSHOME="$home" PATH="$stage/usr/bin:$PATH" patscc -o hello-destdir hello-destdir.dats &&
  ./hello-destdir | grep -x 'Hello, world!')
make uninstall PREFIX=/usr DESTDIR="$stage"
# the empty directory $PREFIX itself may remain; no file, link or directory with content
left=$(find "$stage" -mindepth 1 ! -type d | head -20; find "$stage" -mindepth 1 -type d -empty | grep -v "^$stage/usr$" | head -20)
if [ -n "$left" ]; then
  echo "make uninstall leaves files:"
  echo "$left"
  exit 1
fi
echo "destdir_install: ok (install and uninstall)"
