# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
# arenagen specification for pats_ccomp_claulst.dats: the private types of the pattern matrices (matoken, patcomp, patckontref), --compact
# python3 ../utils/arenagen/arenagen.py --global sats pats_ccomp_claulst.spec > pats_ccomp_claulst_gen.hats
# python3 ../utils/arenagen/arenagen.py --global --compact dats pats_ccomp_claulst.spec > pats_ccomp_claulst_gen_dats.hats
#
# ATS1: [datatype matoken], [datatype patcomp] and [typedef patckontref = ref (patckont)] of pats_ccomp_claulst.dats. The lists are [glist]s
# (the clauses of a matrix share their tails), the reference is a one-field record whose field is [mut] (a cell of the arena that
# [patcomplst_jumpfill_*] overwrite). See PORTING.md, "ccomp group C2".
typedef matokenlst = glist(matoken)
typedef patcomplst = glist(patcomp)
typedef patcomplstlst = glist(patcomplst)
record patckontref (mut patckontref_val: patckont)
type matoken
  MTKpat (hipat, tmprimval)
  MTKlabpat (label, hipat, tmprimval)
  MTKrparen ()
type patcomp
  PTCMPany (d2var)
  PTCMPvar (d2var, tmprimval)
  PTCMPasvar (d2var, tmprimval)
  PTCMPlablparen (label)
  PTCMPpatlparen (patck, tmprimval, tmplab, pckindopt, patckontref)
  PTCMPreclparen (tmprimval, tmplab)
  PTCMPrparen ()
  PTCMPpatneg (patck, tmprimval)
  PTCMPtmplabend (tmplab)
  PTCMPtmplabgua (tmplab, patckontref)
