#!/bin/sh
# usage: cc1_exit.sh DRIVER   runs the cases that end the process of one driver (CC1EXIT=1..N) and prints their stdout (md5 file of the ATS1 driver: cc1.md5, line 2)
L=`cd \`dirname $0\` && pwd`
n=`sed -n 's/^fun cx_count (): int = //p' $L/cc1_exit.hats`
i=1
while [ $i -le $n ]; do CC1EXIT=$i $1 2> /dev/null; echo "status $?"; i=`expr $i + 1`; done
