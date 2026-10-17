#!/usr/bin/env python3
# usage: python3 com_table.py > comtable.txt
# The table of command lines of the differential test of pats_comarg (comtable.sh): one line = ENV<TAB>arg<TAB>arg...
# ENV is "-" or a ;-separated list of VAR=value (VAR= unsets it). Valid, invalid, combined short/long options,
# -DATS/-IATS in all their forms (with the definition in the same or the next argument), -o/-s/-d/-dd waiting for an argument, dashes only, ...
import random, sys
random.seed(20261014)
lines = []
def add(*args, env='-'):
    lines.append('\t'.join([env] + list(args)))

SHORT = ['-o', '-s', '-d', '-dd', '-cc', '-tc', '-dep', '-tag', '-h', '-v']
LONG = ['--help', '--output', '--output-w', '--output-a', '--static', '--dynamic', '--dynamics', '--compile', '--typecheck', '--gline',
        '--debug', '--debug2', '--depgen', '--taggen', '--atsreloc', '--codegen-2', '--jsonize-2', '--tlcalopt-disable',
        '--constraint-export', '--constraint-ignore', '--version']
# no argument at all (the program name only)
add()
# every option alone and followed by a file
for o in SHORT + LONG:
    add(o)
    add(o, 'a.dats')
    add('x.sats', o)
# the options that wait for an argument, with and without it
for o in ['-o', '--output', '--output-w', '--output-a']:
    add(o, 'out.c'); add(o, '-s', 'a.sats'); add('-s', 'a.sats', o, 'o.c', 'b.sats'); add(o, o, 'f')
for o in ['-s', '-d', '-dd', '--static', '--dynamic', '--dynamics']:
    add(o, 'a'); add(o, 'a', 'b', 'c'); add(o, 'a', '-', 'b'); add(o, '-'); add(o, 'a', o, 'b'); add(o, o)
    add(o, 'a', '-o', 'out', 'b'); add(o, '--output', 'out', 'a', 'b'); add(o, '-DATS', 'X=1', 'a'); add(o, '-IATS', '/tmp', 'a')
# -DATS in all its forms
for d in ['FOO', 'FOO=1', 'FOO=1+2', 'FOO=(1+2)*3', 'FOO="str"', 'FOO=\'c\'', 'FOO=1.5', 'FOO=BAR', 'FOO=BAR(1,2)', 'FOO=~1', 'FOO=1,2',
          'A=B=C', 'F00=0x1F', 'X_Y=1', 'a1=-1', 'DEBUG=1', 'N=100', 'FOO = 1', 'FOO=', 'S="a b"', 'VERSION="0.4.2"']:
    add('-DATS' + d)
    add('-DATS', d)
    add('-DATS' + d, 'x.dats')
for d in ['', '=', '1=', '=1', 'A=(', 'A=)', 'A=1+', 'A=\'', 'A="', '(', '-1', '"s"', 'A=B=', '$X=1', 'A.B=1', ' ', 'A B', 'A==1']:
    add('-DATS' + d)
    add('-DATS', d)
add('-DATS')
add('-DATS', '-DATS', 'X=1')
add('-DATSA=1', '-DATSB=2', '-DATSC=3')
add('-DATS', 'A=1', '-DATSB=2', '-DATS', 'C=3', 'x.dats')
add('-DAT', '-DATSX', '-DAT=1', '-DATA=1', '-DAT S=1', '-D', '-DATS=1', '-DATS', '=1')
# -IATS
for d in ['/tmp', 'dir', '.', '..', '/', '/usr/include', 'a/b/c', 'a b', '~/x', '$PATSHOME/prelude', '']:
    add('-IATS' + d)
    add('-IATS', d)
    add('-IATS' + d, 'f.sats')
add('-IATS')
add('-IATS', '-IATS', 'x')
add('-IATS', 'a', '-IATSb', '-IATS', 'c', '-IATS/d')
add('-IAT', '-IATSX', '-IAT=1', '-I', '-IATS=1', '-IATA/x')
add('-IATS', '-s', 'a.sats')
add('-DATS', '-s', 'a.sats')
add('-DATS', '--static', '-IATS', '--dynamic')
# dashes, empty strings, odd arguments
for a in ['-', '--', '---', '----', '-x', '--x', '--x=y', '-x=y', '-xy', '-s=a', '--static=a', '-S', '-D', '-I', '--DATS', '--IATS', '-DATS-', '-IATS-',
          '', ' ', '\t', '-\t', '- ', ' -', '-o-', '-s-', '--output-', '--help=1', '--version2', '-vv', '-hh', '-ss', '-dd2', '-ddd', '-cc1', '-dep1',
          'a-b', 'a--b', '-a-b', '--a-b', '-1', '-0', 'é', '-é', '--é', '@', '-@', '--@', '--=', '-=', '=', '-=-', '\\', '"', "'"]:
    add(a)
    add('-s', a)
    add('-d', a, '-s', 'x')
    add(a, a)
# whole programs
add('-s', 'a.sats', '-d', 'b.dats', 'c.dats')
add('-dd', 'a.dats', 'b.dats', 'c.dats', '-o', 'out.c', 'd.dats', 'e.dats')
add('-IATS', '/tmp', '-DATS', 'X=1', '-d', 'a.dats', '--output', 'o.c', '--typecheck')
add('--static', 'a.sats', '--dynamic', 'b.dats', '--dynamics', 'c.dats', 'd.dats')
add('-cc', '-tc', '-cc', '--typecheck', '--compile', '-d', 'a.dats')
add('--depgen', '--taggen', '-dep', '-tag', '-s', 'a.sats')
add('--gline', '--debug', '--debug2', '--atsreloc', '--codegen-2', '--jsonize-2', '--tlcalopt-disable', '--constraint-export', '--constraint-ignore', '-d', 'a')
add('-h', '-v', '--help', '--version', '-s', 'a.sats')
add('-s', 'a.sats', '-h')
add('-s', 'a.sats', 'b.sats', '-v', 'c.sats')
add('-d', 'a', 'x', '-s', 'y', 'z', '-dd', 'p', 'q', '-d', '-')
add('-s', '-s', 'a', '-s')
add('-o', '-o', '-o')
add('-DATS', 'A=1', '-IATS', 'p', '-DATS', 'A=2', '-IATS', 'q', '-d', 'x')
add('-DATSA=1', '-DATSA=2', '-DATSA=(3)')
add('a', 'b', 'c')
add('-', '-', '-')
add('-s', '-', '-d', '-')
# the environment: PATSRELOCROOT, ATSRELOCROOT, USER
add(env='USER=alice')
add(env='USER=')
add(env='USER=;PATSRELOCROOT=/x/y')
add(env='PATSRELOCROOT=/root/reloc', *['-s', 'a'])
add(env='PATSRELOCROOT=', *['-s', 'a'])
add(env='USER=;PATSRELOCROOT=;ATSRELOCROOT=/atsroot', *['-s', 'a'])
add(env='USER=bébé', *['-s', 'a'])
add(env='USER=a/b', *['-s', 'a'])
add(env='USER=\' ', *['-s', 'a'])
add(env='PATSRELOCROOT=a;ATSRELOCROOT=b', *['-d', 'a'])
# random combinations
pool = SHORT + LONG + ['-', 'a.sats', 'b.dats', 'x', '-DATSX=1', '-DATS', 'Y=2', '-IATS', '/tmp', '-IATS/usr', '-DATSZ', '--', '-z', '--zz', 'out.c', '']
for i in range(220):
    n = random.randint(1, 9)
    add(*[random.choice(pool) for _ in range(n)])
sys.stdout.write('\n'.join(lines) + '\n')
