# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
#
# HX-2026-10: no GC
#   python3 $PATSHOME/utils/arenagen/arenagen.py sats \
#     SATS/patsolve_smt2_solving.spec > SATS/patsolve_smt2_solving_gen.hats
#   python3 $PATSHOME/utils/arenagen/arenagen.py dats \
#     SATS/patsolve_smt2_solving.spec > DATS/SOLVING/patsolve_smt2_solving_gen.hats
#
type form
  FORMint (int)
  FORMbool (bool)
  FORMintrep (astring(l))
  FORMs2var (s2var(l))
  FORMs2cst (s2cst(l))
  FORMs2exp (s2exp(l))
  FORMnot (form(l))
  FORMconj (form(l), form(l))
  FORMdisj (form(l), form(l))
  FORMimpl (form(l), form(l))
