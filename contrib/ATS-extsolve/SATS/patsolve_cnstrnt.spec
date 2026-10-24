# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
#
# HX-2026-10: no GC
# The arena encoding of the constraint syntax:
#   python3 $PATSHOME/utils/arenagen/arenagen.py sats \
#     SATS/patsolve_cnstrnt.spec > SATS/patsolve_cnstrnt_gen.hats
#   python3 $PATSHOME/utils/arenagen/arenagen.py dats \
#     SATS/patsolve_cnstrnt.spec > DATS/CNSTRNT/patsolve_cnstrnt_gen.hats
#
type label
  LABint (int)
  LABsym (symbol(l))

type s2rt
  S2RTint ()
  S2RTaddr ()
  S2RTbool ()
  S2RTreal ()
  S2RTfloat ()
  S2RTstring ()
  S2RTcls ()
  S2RTeff ()
  S2RTtup ()
  S2RTtype ()
  S2RTvtype ()
  S2RTt0ype ()
  S2RTvt0ype ()
  S2RTprop ()
  S2RTview ()
  S2RTtkind ()
  S2RTfun (alist(l, s2rt(l)), s2rt(l))
  S2RTnamed (symbol(l))
  S2RTerror ()

type tyreckind
  TYRECKINDbox ()
  TYRECKINDbox_lin ()
  TYRECKINDflt0 ()
  TYRECKINDflt1 (stamp)
  TYRECKINDflt_ext (astring(l))

type s2exp
  S2EXP (srt: s2rt(l), node: s2exp_node(l))

type s2exp_node
  S2Eint (int)
  S2Eintinf (astring(l))
  S2Ecst (s2cst(l))
  S2Evar (s2var(l))
  S2EVar (s2Var(l))
  S2Eeqeq (s2exp(l), s2exp(l))
  S2Esizeof (s2exp(l))
  S2Eapp (s2exp(l), alist(l, s2exp(l)))
  S2Emetdec (alist(l, s2exp(l)), alist(l, s2exp(l)))
  S2Etop (int, s2exp(l))
  S2Einvar (s2exp(l))
  S2Efun (int, alist(l, s2exp(l)), s2exp(l))
  S2Euni (alist(l, s2var(l)), alist(l, s2exp(l)), s2exp(l))
  S2Eexi (alist(l, s2var(l)), alist(l, s2exp(l)), s2exp(l))
  S2Etyrec (tyreckind(l), int, alist(l, labs2exp(l)))
  S2Eextype (symbol(l))
  S2Eextkind (symbol(l))
  S2Eerror ()

type labs2exp
  SLABELED (lab: label(l), exp: s2exp(l))

type c3nstrkind
  C3TKmain ()
  C3TKtermet_isnat ()
  C3TKtermet_isdec ()
  C3TKsolver (int)
  C3TKignored ()

type s3itm
  S3ITMsvar (s2var(l))
  S3ITMsVar (s2Var(l))
  S3ITMhypo (h3ypo(l))
  S3ITMcnstr (c3nstr(l))
  S3ITMcnstr_ref (astring(l), c3nstropt(l))
  S3ITMdisj (alist(l, alist(l, s3itm(l))))
  S3ITMsolassert (s2exp(l))

type h3ypo
  H3YPO (loc: astring(l), node: h3ypo_node(l))

type h3ypo_node
  H3YPOprop (s2exp(l))
  H3YPObind (s2var(l), s2exp(l))
  H3YPOeqeq (s2exp(l), s2exp(l))

type c3nstr
  C3NSTR (loc: astring(l), kind: c3nstrkind(l), node: c3nstr_node(l))

type c3nstr_node
  C3NSTRprop (s2exp(l))
  C3NSTRitmlst (alist(l, s3itm(l)))
  C3NSTRsolverify (s2exp(l))

type c3nstropt
  C3NSTRnone ()
  C3NSTRsome (c3nstr(l))
