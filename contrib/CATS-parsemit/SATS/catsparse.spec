# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
#
# HX-2026-10: no GC
# The arena encoding (in the global arena) of the syntax:
#   python3 $PATSHOME/utils/arenagen/arenagen.py sats --global \
#     SATS/catsparse.spec > SATS/catsparse_gen.hats
#   python3 $PATSHOME/utils/arenagen/arenagen.py dats --global \
#     SATS/catsparse.spec > DATS/catsparse_gen.hats
#
type token_node
  T_KWORD (keyword)
  T_IDENT_alp (string)
  T_IDENT_sym (string)
  T_IDENT_srp (string)
  T_CHAR (string)
  T_INT (int, string)
  T_FLOAT (int, string)
  T_STRING (string)
  T_LPAREN ()
  T_RPAREN ()
  T_LBRACKET ()
  T_RBRACKET ()
  T_LBRACE ()
  T_RBRACE ()
  T_LT ()
  T_GT ()
  T_MINUS ()
  T_COLON ()
  T_COMMA ()
  T_SEMICOLON ()
  T_SLASH ()
  T_ENDL ()
  T_SPACES (string)
  T_COMMENT_line (string)
  T_COMMENT_block (string)
  T_EOF ()

type token
  TOKEN (token_loc: loc_t, token_node: token_node)

type lexerr_node
  LEXERR_FEXPONENT_nil ()
  LEXERR_UNSUPPORTED_char (char)

type lexerr
  LEXERR (lexerr_loc: loc_t, lexerr_node: lexerr_node)

type signed
  SIGNED (loc_t, int)

type i0de
  I0DE (i0dex_loc: loc_t, i0dex_sym: symbol)

type s0exp_node
  S0Eide (symbol)
  S0Elist (glist(s0exp))
  S0Eappid (i0de, glist(s0exp))

type s0exp
  S0EXP (s0exp_loc: loc_t, s0exp_node: s0exp_node)

type tyfld_node
  TYFLD (i0de, s0exp)

type tyfld
  TYFLDREC (tyfld_loc: loc_t, tyfld_node: tyfld_node)

type tyrec
  TYREC (tyrec_loc: loc_t, tyrec_node: glist(tyfld))

type d0exp_node
  D0Eide (i0de)
  D0Elist (glist(d0exp))
  D0Eappid (i0de, glist(d0exp))
  D0Eappexp (d0exp, glist(d0exp))
  ATSPMVint (token)
  ATSPMVintrep (token)
  ATSPMVbool (bool)
  ATSPMVfloat (token)
  ATSPMVstring (token)
  ATSPMVi0nt (token)
  ATSPMVf0loat (token)
  ATSPMVempty (int)
  ATSPMVextval (glist(token))
  ATSPMVrefarg0 (d0exp)
  ATSPMVrefarg1 (d0exp)
  ATSPMVfunlab (i0de)
  ATSPMVcfunlab (int, i0de, glist(d0exp))
  ATSPMVcastfn (i0de, s0exp, d0exp)
  ATSCSTSPmyloc (token)
  ATSCKiseqz (d0exp)
  ATSCKisneqz (d0exp)
  ATSCKptriscons (d0exp)
  ATSCKptrisnull (d0exp)
  ATSCKpat_int (d0exp, d0exp)
  ATSCKpat_bool (d0exp, d0exp)
  ATSCKpat_string (d0exp, d0exp)
  ATSCKpat_con0 (d0exp, int)
  ATSCKpat_con1 (d0exp, int)
  ATSSELcon (d0exp, s0exp, i0de)
  ATSSELrecsin (d0exp, s0exp, i0de)
  ATSSELboxrec (d0exp, s0exp, i0de)
  ATSSELfltrec (d0exp, s0exp, i0de)
  ATSextfcall (i0de, glist(d0exp))
  ATSextmcall (d0exp, d0exp, glist(d0exp))
  ATSfunclo_fun (d0exp, s0exp, s0exp)
  ATSfunclo_clo (d0exp, s0exp, s0exp)

type d0exp
  D0EXP (d0exp_loc: loc_t, d0exp_node: d0exp_node)

type f0arg_node
  F0ARGnone (s0exp)
  F0ARGsome (i0de, s0exp)

type f0arg
  F0ARG (f0arg_loc: loc_t, f0arg_node: f0arg_node)

type f0marg
  F0MARG (f0marg_loc: loc_t, f0marg_node: glist(f0arg))

type fkind
  FKIND (fkind_loc: loc_t, fkind_node: fkind_node)

type f0head_node
  F0HEAD (i0de, f0marg, s0exp)

type f0head
  F0HEADREC (f0head_loc: loc_t, f0head_node: f0head_node)

type tmpdec_node
  TMPDECnone (i0de)
  TMPDECsome (i0de, s0exp)

type tmpdec
  TMPDEC (tmpdec_loc: loc_t, tmpdec_node: tmpdec_node)

type instr_node
  ATSif (d0exp, glist(instr), gopt(glist(instr)))
  ATSthen (glist(instr))
  ATSelse (glist(instr))
  ATSifthen (d0exp, glist(instr))
  ATSifnthen (d0exp, glist(instr))
  ATSbranchseq (glist(instr))
  ATScaseofseq (glist(instr))
  ATSfunbodyseq (glist(instr))
  ATSreturn (i0de)
  ATSreturn_void (i0de)
  ATSlinepragma (token, token)
  ATSINSlab (i0de)
  ATSINSgoto (i0de)
  ATSINSflab (i0de)
  ATSINSfgoto (i0de)
  ATSINSfreeclo (d0exp)
  ATSINSfreecon (d0exp)
  ATSINSmove (i0de, d0exp)
  ATSINSmove_void (i0de, d0exp)
  ATSINSmove_nil (i0de)
  ATSINSmove_con0 (i0de, token)
  ATSINSmove_con1 (glist(instr))
  ATSINSmove_con1_new (i0de, s0exp)
  ATSINSstore_con1_tag (i0de, token)
  ATSINSstore_con1_ofs (i0de, s0exp, i0de, d0exp)
  ATSINSmove_boxrec (glist(instr))
  ATSINSmove_boxrec_new (i0de, s0exp)
  ATSINSstore_boxrec_ofs (i0de, s0exp, i0de, d0exp)
  ATSINSmove_fltrec (glist(instr))
  ATSINSstore_fltrec_ofs (i0de, s0exp, i0de, d0exp)
  ATSINSmove_delay (i0de, s0exp, d0exp)
  ATSINSmove_lazyeval (i0de, s0exp, d0exp)
  ATSINSmove_ldelay (i0de, s0exp, d0exp)
  ATSINSmove_llazyeval (i0de, s0exp, d0exp)
  ATStailcalseq (glist(instr))
  ATSINSmove_tlcal (i0de, d0exp)
  ATSINSargmove_tlcal (i0de, i0de)
  ATSINSextvar_assign (d0exp, d0exp)
  ATSINSdyncst_valbind (i0de, d0exp)
  ATSINScaseof_fail (token)
  ATSINSdeadcode_fail (token)
  ATSdynload (int)
  ATSdynloadset (i0de)
  ATSdynloadfcall (i0de)
  ATSdynloadflag_sta (i0de)
  ATSdynloadflag_ext (i0de)
  ATSdynloadflag_init (i0de)
  ATSdynloadflag_minit (i0de)
  ATSdynexn_dec (i0de)
  ATSdynexn_extdec (i0de)
  ATSdynexn_initize (i0de, string)

type instr
  INSTR (instr_loc: loc_t, instr_node: instr_node)

type f0body_node
  F0BODY (glist(tmpdec), glist(instr))

type f0body
  F0BODYREC (f0body_loc: loc_t, f0body_node: f0body_node)

type f0decl_node
  F0DECLnone (f0head)
  F0DECLsome (f0head, f0body)

type f0decl
  F0DECLREC (f0decl_loc: loc_t, f0decl_node: f0decl_node)

type d0ecl_node
  D0Cinclude (token)
  D0Cifdef (i0de, glist(d0ecl))
  D0Cifndef (i0de, glist(d0ecl))
  D0Ctypedef (i0de, tyrec)
  D0Cassume (i0de)
  D0Cdyncst_mac (i0de)
  D0Cdyncst_extfun (i0de, glist(s0exp), s0exp)
  D0Cdyncst_valdec (i0de, s0exp)
  D0Cdyncst_valimp (i0de, s0exp)
  D0Cextcode (glist(token))
  D0Cstatmp (i0de, gopt(s0exp))
  D0Cfundecl (fkind, f0decl)
  D0Cclosurerize (i0de, s0exp, s0exp, s0exp)
  D0Cdynloadflag_init (i0de)
  D0Cdynloadflag_minit (i0de)
  D0Cdynexn_dec (i0de)
  D0Cdynexn_extdec (i0de)
  D0Cdynexn_initize (i0de, token)

type d0ecl
  D0ECLREC (d0ecl_loc: loc_t, d0ecl_node: d0ecl_node)
