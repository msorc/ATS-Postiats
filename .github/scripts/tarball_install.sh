#!/bin/sh
# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
#
# The release tarball built by `make dist` (doc/DISTRIB/ATS2-Postiats-<version>.tgz,
# run from the root of the repository) is unpacked in an empty directory,
# configured, built and installed under <tmp>, and a hello world is compiled
# with the installed tree: only <tmp>/inst-<variant>/bin is added to the PATH
# and PATSHOME is not set.
#
#   tarball_install.sh <tmp-dir> with-gmp|without-gmp
#
set -eu
tmp=$1
variant=$2
root=$(pwd)
version=$(cat VERSION)
tgz=$root/doc/DISTRIB/ATS2-Postiats-$version.tgz
test -f "$tgz"
case $variant in
  with-gmp) cfg= ;;
  without-gmp) cfg=--without-gmp ;;
  *) echo "usage: $0 <tmp-dir> with-gmp|without-gmp" >&2; exit 2 ;;
esac
work=$tmp/unpack-$variant
inst=$tmp/inst-$variant
rm -rf "$work" "$inst"
mkdir -p "$work"
tar -xzf "$tgz" -C "$work"
cd "$work"/*
test -f configure
./configure --prefix="$inst" $cfg
make -j4
make install
#
# the installed tree alone
#
cd "$tmp"
printf 'implement main0 () = println! ("Hello, world!")\n' > "hello-$variant.dats"
env -u PATSHOME PATH="$inst/bin:$PATH" patscc -o "hello-$variant" "hello-$variant.dats"
"./hello-$variant" | grep -x 'Hello, world!'
# which patscc was used
env -u PATSHOME PATH="$inst/bin:$PATH" sh -c 'command -v patscc' | grep -x "$inst/bin/patscc"
echo "tarball_install ($variant): ok"
