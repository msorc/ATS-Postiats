#!/usr/bin/env bash

######
#
# For making a distribution package
#
######
#
set -e
#
autoheader configure.ac
#
aclocal
#
# NO messing with [automake]
# automake --add-missing --foreign || true
#
autoconf
#
###### end of [autogen.sh] ######
