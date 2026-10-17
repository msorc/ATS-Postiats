abstype
token_node_type = ptr
typedef
token_node = token_node_type

abstype
token_type = ptr
typedef
token = token_type

abstype
lexerr_node_type = ptr
typedef
lexerr_node = lexerr_node_type

abstype
lexerr_type = ptr
typedef
lexerr = lexerr_type

abstype
signed_type = ptr
typedef
signed = signed_type

abstype
i0de_type = ptr
typedef
i0de = i0de_type

abstype
s0exp_node_type = ptr
typedef
s0exp_node = s0exp_node_type

abstype
s0exp_type = ptr
typedef
s0exp = s0exp_type

abstype
tyfld_node_type = ptr
typedef
tyfld_node = tyfld_node_type

abstype
tyfld_type = ptr
typedef
tyfld = tyfld_type

abstype
tyrec_type = ptr
typedef
tyrec = tyrec_type

abstype
d0exp_node_type = ptr
typedef
d0exp_node = d0exp_node_type

abstype
d0exp_type = ptr
typedef
d0exp = d0exp_type

abstype
f0arg_node_type = ptr
typedef
f0arg_node = f0arg_node_type

abstype
f0arg_type = ptr
typedef
f0arg = f0arg_type

abstype
f0marg_type = ptr
typedef
f0marg = f0marg_type

abstype
fkind_type = ptr
typedef
fkind = fkind_type

abstype
f0head_node_type = ptr
typedef
f0head_node = f0head_node_type

abstype
f0head_type = ptr
typedef
f0head = f0head_type

abstype
tmpdec_node_type = ptr
typedef
tmpdec_node = tmpdec_node_type

abstype
tmpdec_type = ptr
typedef
tmpdec = tmpdec_type

abstype
instr_node_type = ptr
typedef
instr_node = instr_node_type

abstype
instr_type = ptr
typedef
instr = instr_type

abstype
f0body_node_type = ptr
typedef
f0body_node = f0body_node_type

abstype
f0body_type = ptr
typedef
f0body = f0body_type

abstype
f0decl_node_type = ptr
typedef
f0decl_node = f0decl_node_type

abstype
f0decl_type = ptr
typedef
f0decl = f0decl_type

abstype
d0ecl_node_type = ptr
typedef
d0ecl_node = d0ecl_node_type

abstype
d0ecl_type = ptr
typedef
d0ecl = d0ecl_type

//
datavtype
token_node_view =
  | T_KWORD of (keyword)
  | T_IDENT_alp of (string)
  | T_IDENT_sym of (string)
  | T_IDENT_srp of (string)
  | T_CHAR of (string)
  | T_INT of (int, string)
  | T_FLOAT of (int, string)
  | T_STRING of (string)
  | T_LPAREN of ()
  | T_RPAREN of ()
  | T_LBRACKET of ()
  | T_RBRACKET of ()
  | T_LBRACE of ()
  | T_RBRACE of ()
  | T_LT of ()
  | T_GT of ()
  | T_MINUS of ()
  | T_COLON of ()
  | T_COMMA of ()
  | T_SEMICOLON of ()
  | T_SLASH of ()
  | T_ENDL of ()
  | T_SPACES of (string)
  | T_COMMENT_line of (string)
  | T_COMMENT_block of (string)
  | T_EOF of ()
and
token_view =
  | TOKEN of (loc_t, token_node)
and
lexerr_node_view =
  | LEXERR_FEXPONENT_nil of ()
  | LEXERR_UNSUPPORTED_char of (char)
and
lexerr_view =
  | LEXERR of (loc_t, lexerr_node)
and
signed_view =
  | SIGNED of (loc_t, int)
and
i0de_view =
  | I0DE of (loc_t, symbol)
and
s0exp_node_view =
  | S0Eide of (symbol)
  | S0Elist of (glist(s0exp))
  | S0Eappid of (i0de, glist(s0exp))
and
s0exp_view =
  | S0EXP of (loc_t, s0exp_node)
and
tyfld_node_view =
  | TYFLD of (i0de, s0exp)
and
tyfld_view =
  | TYFLDREC of (loc_t, tyfld_node)
and
tyrec_view =
  | TYREC of (loc_t, glist(tyfld))
and
d0exp_node_view =
  | D0Eide of (i0de)
  | D0Elist of (glist(d0exp))
  | D0Eappid of (i0de, glist(d0exp))
  | D0Eappexp of (d0exp, glist(d0exp))
  | ATSPMVint of (token)
  | ATSPMVintrep of (token)
  | ATSPMVbool of (bool)
  | ATSPMVfloat of (token)
  | ATSPMVstring of (token)
  | ATSPMVi0nt of (token)
  | ATSPMVf0loat of (token)
  | ATSPMVempty of (int)
  | ATSPMVextval of (glist(token))
  | ATSPMVrefarg0 of (d0exp)
  | ATSPMVrefarg1 of (d0exp)
  | ATSPMVfunlab of (i0de)
  | ATSPMVcfunlab of (int, i0de, glist(d0exp))
  | ATSPMVcastfn of (i0de, s0exp, d0exp)
  | ATSCSTSPmyloc of (token)
  | ATSCKiseqz of (d0exp)
  | ATSCKisneqz of (d0exp)
  | ATSCKptriscons of (d0exp)
  | ATSCKptrisnull of (d0exp)
  | ATSCKpat_int of (d0exp, d0exp)
  | ATSCKpat_bool of (d0exp, d0exp)
  | ATSCKpat_string of (d0exp, d0exp)
  | ATSCKpat_con0 of (d0exp, int)
  | ATSCKpat_con1 of (d0exp, int)
  | ATSSELcon of (d0exp, s0exp, i0de)
  | ATSSELrecsin of (d0exp, s0exp, i0de)
  | ATSSELboxrec of (d0exp, s0exp, i0de)
  | ATSSELfltrec of (d0exp, s0exp, i0de)
  | ATSextfcall of (i0de, glist(d0exp))
  | ATSextmcall of (d0exp, d0exp, glist(d0exp))
  | ATSfunclo_fun of (d0exp, s0exp, s0exp)
  | ATSfunclo_clo of (d0exp, s0exp, s0exp)
and
d0exp_view =
  | D0EXP of (loc_t, d0exp_node)
and
f0arg_node_view =
  | F0ARGnone of (s0exp)
  | F0ARGsome of (i0de, s0exp)
and
f0arg_view =
  | F0ARG of (loc_t, f0arg_node)
and
f0marg_view =
  | F0MARG of (loc_t, glist(f0arg))
and
fkind_view =
  | FKIND of (loc_t, fkind_node)
and
f0head_node_view =
  | F0HEAD of (i0de, f0marg, s0exp)
and
f0head_view =
  | F0HEADREC of (loc_t, f0head_node)
and
tmpdec_node_view =
  | TMPDECnone of (i0de)
  | TMPDECsome of (i0de, s0exp)
and
tmpdec_view =
  | TMPDEC of (loc_t, tmpdec_node)
and
instr_node_view =
  | ATSif of (d0exp, glist(instr), gopt(glist(instr)))
  | ATSthen of (glist(instr))
  | ATSelse of (glist(instr))
  | ATSifthen of (d0exp, glist(instr))
  | ATSifnthen of (d0exp, glist(instr))
  | ATSbranchseq of (glist(instr))
  | ATScaseofseq of (glist(instr))
  | ATSfunbodyseq of (glist(instr))
  | ATSreturn of (i0de)
  | ATSreturn_void of (i0de)
  | ATSlinepragma of (token, token)
  | ATSINSlab of (i0de)
  | ATSINSgoto of (i0de)
  | ATSINSflab of (i0de)
  | ATSINSfgoto of (i0de)
  | ATSINSfreeclo of (d0exp)
  | ATSINSfreecon of (d0exp)
  | ATSINSmove of (i0de, d0exp)
  | ATSINSmove_void of (i0de, d0exp)
  | ATSINSmove_nil of (i0de)
  | ATSINSmove_con0 of (i0de, token)
  | ATSINSmove_con1 of (glist(instr))
  | ATSINSmove_con1_new of (i0de, s0exp)
  | ATSINSstore_con1_tag of (i0de, token)
  | ATSINSstore_con1_ofs of (i0de, s0exp, i0de, d0exp)
  | ATSINSmove_boxrec of (glist(instr))
  | ATSINSmove_boxrec_new of (i0de, s0exp)
  | ATSINSstore_boxrec_ofs of (i0de, s0exp, i0de, d0exp)
  | ATSINSmove_fltrec of (glist(instr))
  | ATSINSstore_fltrec_ofs of (i0de, s0exp, i0de, d0exp)
  | ATSINSmove_delay of (i0de, s0exp, d0exp)
  | ATSINSmove_lazyeval of (i0de, s0exp, d0exp)
  | ATSINSmove_ldelay of (i0de, s0exp, d0exp)
  | ATSINSmove_llazyeval of (i0de, s0exp, d0exp)
  | ATStailcalseq of (glist(instr))
  | ATSINSmove_tlcal of (i0de, d0exp)
  | ATSINSargmove_tlcal of (i0de, i0de)
  | ATSINSextvar_assign of (d0exp, d0exp)
  | ATSINSdyncst_valbind of (i0de, d0exp)
  | ATSINScaseof_fail of (token)
  | ATSINSdeadcode_fail of (token)
  | ATSdynload of (int)
  | ATSdynloadset of (i0de)
  | ATSdynloadfcall of (i0de)
  | ATSdynloadflag_sta of (i0de)
  | ATSdynloadflag_ext of (i0de)
  | ATSdynloadflag_init of (i0de)
  | ATSdynloadflag_minit of (i0de)
  | ATSdynexn_dec of (i0de)
  | ATSdynexn_extdec of (i0de)
  | ATSdynexn_initize of (i0de, string)
and
instr_view =
  | INSTR of (loc_t, instr_node)
and
f0body_node_view =
  | F0BODY of (glist(tmpdec), glist(instr))
and
f0body_view =
  | F0BODYREC of (loc_t, f0body_node)
and
f0decl_node_view =
  | F0DECLnone of (f0head)
  | F0DECLsome of (f0head, f0body)
and
f0decl_view =
  | F0DECLREC of (loc_t, f0decl_node)
and
d0ecl_node_view =
  | D0Cinclude of (token)
  | D0Cifdef of (i0de, glist(d0ecl))
  | D0Cifndef of (i0de, glist(d0ecl))
  | D0Ctypedef of (i0de, tyrec)
  | D0Cassume of (i0de)
  | D0Cdyncst_mac of (i0de)
  | D0Cdyncst_extfun of (i0de, glist(s0exp), s0exp)
  | D0Cdyncst_valdec of (i0de, s0exp)
  | D0Cdyncst_valimp of (i0de, s0exp)
  | D0Cextcode of (glist(token))
  | D0Cstatmp of (i0de, gopt(s0exp))
  | D0Cfundecl of (fkind, f0decl)
  | D0Cclosurerize of (i0de, s0exp, s0exp, s0exp)
  | D0Cdynloadflag_init of (i0de)
  | D0Cdynloadflag_minit of (i0de)
  | D0Cdynexn_dec of (i0de)
  | D0Cdynexn_extdec of (i0de)
  | D0Cdynexn_initize of (i0de, token)
and
d0ecl_view =
  | D0ECLREC of (loc_t, d0ecl_node)
//
fun
token_node_encode(v: token_node_view): token_node
fun
token_node_view(x: token_node): token_node_view
fun
token_node_view_free(v: token_node_view): void
fun
token_node_tag(x: token_node): int
fun
token_node_T_KWORD(a0: keyword): token_node
fun
token_node_T_IDENT_alp(a0: string): token_node
fun
token_node_T_IDENT_sym(a0: string): token_node
fun
token_node_T_IDENT_srp(a0: string): token_node
fun
token_node_T_CHAR(a0: string): token_node
fun
token_node_T_INT(a0: int, a1: string): token_node
fun
token_node_T_FLOAT(a0: int, a1: string): token_node
fun
token_node_T_STRING(a0: string): token_node
fun
token_node_T_LPAREN(): token_node
fun
token_node_T_RPAREN(): token_node
fun
token_node_T_LBRACKET(): token_node
fun
token_node_T_RBRACKET(): token_node
fun
token_node_T_LBRACE(): token_node
fun
token_node_T_RBRACE(): token_node
fun
token_node_T_LT(): token_node
fun
token_node_T_GT(): token_node
fun
token_node_T_MINUS(): token_node
fun
token_node_T_COLON(): token_node
fun
token_node_T_COMMA(): token_node
fun
token_node_T_SEMICOLON(): token_node
fun
token_node_T_SLASH(): token_node
fun
token_node_T_ENDL(): token_node
fun
token_node_T_SPACES(a0: string): token_node
fun
token_node_T_COMMENT_line(a0: string): token_node
fun
token_node_T_COMMENT_block(a0: string): token_node
fun
token_node_T_EOF(): token_node
fun
token_node_is_T_KWORD(x: token_node): bool
fun
token_node_is_T_IDENT_alp(x: token_node): bool
fun
token_node_is_T_IDENT_sym(x: token_node): bool
fun
token_node_is_T_IDENT_srp(x: token_node): bool
fun
token_node_is_T_CHAR(x: token_node): bool
fun
token_node_is_T_INT(x: token_node): bool
fun
token_node_is_T_FLOAT(x: token_node): bool
fun
token_node_is_T_STRING(x: token_node): bool
fun
token_node_is_T_LPAREN(x: token_node): bool
fun
token_node_is_T_RPAREN(x: token_node): bool
fun
token_node_is_T_LBRACKET(x: token_node): bool
fun
token_node_is_T_RBRACKET(x: token_node): bool
fun
token_node_is_T_LBRACE(x: token_node): bool
fun
token_node_is_T_RBRACE(x: token_node): bool
fun
token_node_is_T_LT(x: token_node): bool
fun
token_node_is_T_GT(x: token_node): bool
fun
token_node_is_T_MINUS(x: token_node): bool
fun
token_node_is_T_COLON(x: token_node): bool
fun
token_node_is_T_COMMA(x: token_node): bool
fun
token_node_is_T_SEMICOLON(x: token_node): bool
fun
token_node_is_T_SLASH(x: token_node): bool
fun
token_node_is_T_ENDL(x: token_node): bool
fun
token_node_is_T_SPACES(x: token_node): bool
fun
token_node_is_T_COMMENT_line(x: token_node): bool
fun
token_node_is_T_COMMENT_block(x: token_node): bool
fun
token_node_is_T_EOF(x: token_node): bool
//
fun
token_encode(v: token_view): token
fun
token_view(x: token): token_view
fun
token_view_free(v: token_view): void
fun
token_tag(x: token): int
fun
token_TOKEN(a0: loc_t, a1: token_node): token
fun
token_get_token_loc(x: token): loc_t
overload .token_loc with token_get_token_loc
fun
token_get_token_node(x: token): token_node
overload .token_node with token_get_token_node
//
fun
lexerr_node_encode(v: lexerr_node_view): lexerr_node
fun
lexerr_node_view(x: lexerr_node): lexerr_node_view
fun
lexerr_node_view_free(v: lexerr_node_view): void
fun
lexerr_node_tag(x: lexerr_node): int
fun
lexerr_node_LEXERR_FEXPONENT_nil(): lexerr_node
fun
lexerr_node_LEXERR_UNSUPPORTED_char(a0: char): lexerr_node
fun
lexerr_node_is_LEXERR_FEXPONENT_nil(x: lexerr_node): bool
fun
lexerr_node_is_LEXERR_UNSUPPORTED_char(x: lexerr_node): bool
//
fun
lexerr_encode(v: lexerr_view): lexerr
fun
lexerr_view(x: lexerr): lexerr_view
fun
lexerr_view_free(v: lexerr_view): void
fun
lexerr_tag(x: lexerr): int
fun
lexerr_LEXERR(a0: loc_t, a1: lexerr_node): lexerr
fun
lexerr_get_lexerr_loc(x: lexerr): loc_t
overload .lexerr_loc with lexerr_get_lexerr_loc
fun
lexerr_get_lexerr_node(x: lexerr): lexerr_node
overload .lexerr_node with lexerr_get_lexerr_node
//
fun
signed_encode(v: signed_view): signed
fun
signed_view(x: signed): signed_view
fun
signed_view_free(v: signed_view): void
fun
signed_tag(x: signed): int
fun
signed_SIGNED(a0: loc_t, a1: int): signed
//
fun
i0de_encode(v: i0de_view): i0de
fun
i0de_view(x: i0de): i0de_view
fun
i0de_view_free(v: i0de_view): void
fun
i0de_tag(x: i0de): int
fun
i0de_I0DE(a0: loc_t, a1: symbol): i0de
fun
i0de_get_i0dex_loc(x: i0de): loc_t
overload .i0dex_loc with i0de_get_i0dex_loc
fun
i0de_get_i0dex_sym(x: i0de): symbol
overload .i0dex_sym with i0de_get_i0dex_sym
//
fun
s0exp_node_encode(v: s0exp_node_view): s0exp_node
fun
s0exp_node_view(x: s0exp_node): s0exp_node_view
fun
s0exp_node_view_free(v: s0exp_node_view): void
fun
s0exp_node_tag(x: s0exp_node): int
fun
s0exp_node_S0Eide(a0: symbol): s0exp_node
fun
s0exp_node_S0Elist(a0: glist(s0exp)): s0exp_node
fun
s0exp_node_S0Eappid(a0: i0de, a1: glist(s0exp)): s0exp_node
fun
s0exp_node_is_S0Eide(x: s0exp_node): bool
fun
s0exp_node_is_S0Elist(x: s0exp_node): bool
fun
s0exp_node_is_S0Eappid(x: s0exp_node): bool
//
fun
s0exp_encode(v: s0exp_view): s0exp
fun
s0exp_view(x: s0exp): s0exp_view
fun
s0exp_view_free(v: s0exp_view): void
fun
s0exp_tag(x: s0exp): int
fun
s0exp_S0EXP(a0: loc_t, a1: s0exp_node): s0exp
fun
s0exp_get_s0exp_loc(x: s0exp): loc_t
overload .s0exp_loc with s0exp_get_s0exp_loc
fun
s0exp_get_s0exp_node(x: s0exp): s0exp_node
overload .s0exp_node with s0exp_get_s0exp_node
//
fun
tyfld_node_encode(v: tyfld_node_view): tyfld_node
fun
tyfld_node_view(x: tyfld_node): tyfld_node_view
fun
tyfld_node_view_free(v: tyfld_node_view): void
fun
tyfld_node_tag(x: tyfld_node): int
fun
tyfld_node_TYFLD(a0: i0de, a1: s0exp): tyfld_node
//
fun
tyfld_encode(v: tyfld_view): tyfld
fun
tyfld_view(x: tyfld): tyfld_view
fun
tyfld_view_free(v: tyfld_view): void
fun
tyfld_tag(x: tyfld): int
fun
tyfld_TYFLDREC(a0: loc_t, a1: tyfld_node): tyfld
fun
tyfld_get_tyfld_loc(x: tyfld): loc_t
overload .tyfld_loc with tyfld_get_tyfld_loc
fun
tyfld_get_tyfld_node(x: tyfld): tyfld_node
overload .tyfld_node with tyfld_get_tyfld_node
//
fun
tyrec_encode(v: tyrec_view): tyrec
fun
tyrec_view(x: tyrec): tyrec_view
fun
tyrec_view_free(v: tyrec_view): void
fun
tyrec_tag(x: tyrec): int
fun
tyrec_TYREC(a0: loc_t, a1: glist(tyfld)): tyrec
fun
tyrec_get_tyrec_loc(x: tyrec): loc_t
overload .tyrec_loc with tyrec_get_tyrec_loc
fun
tyrec_get_tyrec_node(x: tyrec): glist(tyfld)
overload .tyrec_node with tyrec_get_tyrec_node
//
fun
d0exp_node_encode(v: d0exp_node_view): d0exp_node
fun
d0exp_node_view(x: d0exp_node): d0exp_node_view
fun
d0exp_node_view_free(v: d0exp_node_view): void
fun
d0exp_node_tag(x: d0exp_node): int
fun
d0exp_node_D0Eide(a0: i0de): d0exp_node
fun
d0exp_node_D0Elist(a0: glist(d0exp)): d0exp_node
fun
d0exp_node_D0Eappid(a0: i0de, a1: glist(d0exp)): d0exp_node
fun
d0exp_node_D0Eappexp(a0: d0exp, a1: glist(d0exp)): d0exp_node
fun
d0exp_node_ATSPMVint(a0: token): d0exp_node
fun
d0exp_node_ATSPMVintrep(a0: token): d0exp_node
fun
d0exp_node_ATSPMVbool(a0: bool): d0exp_node
fun
d0exp_node_ATSPMVfloat(a0: token): d0exp_node
fun
d0exp_node_ATSPMVstring(a0: token): d0exp_node
fun
d0exp_node_ATSPMVi0nt(a0: token): d0exp_node
fun
d0exp_node_ATSPMVf0loat(a0: token): d0exp_node
fun
d0exp_node_ATSPMVempty(a0: int): d0exp_node
fun
d0exp_node_ATSPMVextval(a0: glist(token)): d0exp_node
fun
d0exp_node_ATSPMVrefarg0(a0: d0exp): d0exp_node
fun
d0exp_node_ATSPMVrefarg1(a0: d0exp): d0exp_node
fun
d0exp_node_ATSPMVfunlab(a0: i0de): d0exp_node
fun
d0exp_node_ATSPMVcfunlab(a0: int, a1: i0de, a2: glist(d0exp)): d0exp_node
fun
d0exp_node_ATSPMVcastfn(a0: i0de, a1: s0exp, a2: d0exp): d0exp_node
fun
d0exp_node_ATSCSTSPmyloc(a0: token): d0exp_node
fun
d0exp_node_ATSCKiseqz(a0: d0exp): d0exp_node
fun
d0exp_node_ATSCKisneqz(a0: d0exp): d0exp_node
fun
d0exp_node_ATSCKptriscons(a0: d0exp): d0exp_node
fun
d0exp_node_ATSCKptrisnull(a0: d0exp): d0exp_node
fun
d0exp_node_ATSCKpat_int(a0: d0exp, a1: d0exp): d0exp_node
fun
d0exp_node_ATSCKpat_bool(a0: d0exp, a1: d0exp): d0exp_node
fun
d0exp_node_ATSCKpat_string(a0: d0exp, a1: d0exp): d0exp_node
fun
d0exp_node_ATSCKpat_con0(a0: d0exp, a1: int): d0exp_node
fun
d0exp_node_ATSCKpat_con1(a0: d0exp, a1: int): d0exp_node
fun
d0exp_node_ATSSELcon(a0: d0exp, a1: s0exp, a2: i0de): d0exp_node
fun
d0exp_node_ATSSELrecsin(a0: d0exp, a1: s0exp, a2: i0de): d0exp_node
fun
d0exp_node_ATSSELboxrec(a0: d0exp, a1: s0exp, a2: i0de): d0exp_node
fun
d0exp_node_ATSSELfltrec(a0: d0exp, a1: s0exp, a2: i0de): d0exp_node
fun
d0exp_node_ATSextfcall(a0: i0de, a1: glist(d0exp)): d0exp_node
fun
d0exp_node_ATSextmcall(a0: d0exp, a1: d0exp, a2: glist(d0exp)): d0exp_node
fun
d0exp_node_ATSfunclo_fun(a0: d0exp, a1: s0exp, a2: s0exp): d0exp_node
fun
d0exp_node_ATSfunclo_clo(a0: d0exp, a1: s0exp, a2: s0exp): d0exp_node
fun
d0exp_node_is_D0Eide(x: d0exp_node): bool
fun
d0exp_node_is_D0Elist(x: d0exp_node): bool
fun
d0exp_node_is_D0Eappid(x: d0exp_node): bool
fun
d0exp_node_is_D0Eappexp(x: d0exp_node): bool
fun
d0exp_node_is_ATSPMVint(x: d0exp_node): bool
fun
d0exp_node_is_ATSPMVintrep(x: d0exp_node): bool
fun
d0exp_node_is_ATSPMVbool(x: d0exp_node): bool
fun
d0exp_node_is_ATSPMVfloat(x: d0exp_node): bool
fun
d0exp_node_is_ATSPMVstring(x: d0exp_node): bool
fun
d0exp_node_is_ATSPMVi0nt(x: d0exp_node): bool
fun
d0exp_node_is_ATSPMVf0loat(x: d0exp_node): bool
fun
d0exp_node_is_ATSPMVempty(x: d0exp_node): bool
fun
d0exp_node_is_ATSPMVextval(x: d0exp_node): bool
fun
d0exp_node_is_ATSPMVrefarg0(x: d0exp_node): bool
fun
d0exp_node_is_ATSPMVrefarg1(x: d0exp_node): bool
fun
d0exp_node_is_ATSPMVfunlab(x: d0exp_node): bool
fun
d0exp_node_is_ATSPMVcfunlab(x: d0exp_node): bool
fun
d0exp_node_is_ATSPMVcastfn(x: d0exp_node): bool
fun
d0exp_node_is_ATSCSTSPmyloc(x: d0exp_node): bool
fun
d0exp_node_is_ATSCKiseqz(x: d0exp_node): bool
fun
d0exp_node_is_ATSCKisneqz(x: d0exp_node): bool
fun
d0exp_node_is_ATSCKptriscons(x: d0exp_node): bool
fun
d0exp_node_is_ATSCKptrisnull(x: d0exp_node): bool
fun
d0exp_node_is_ATSCKpat_int(x: d0exp_node): bool
fun
d0exp_node_is_ATSCKpat_bool(x: d0exp_node): bool
fun
d0exp_node_is_ATSCKpat_string(x: d0exp_node): bool
fun
d0exp_node_is_ATSCKpat_con0(x: d0exp_node): bool
fun
d0exp_node_is_ATSCKpat_con1(x: d0exp_node): bool
fun
d0exp_node_is_ATSSELcon(x: d0exp_node): bool
fun
d0exp_node_is_ATSSELrecsin(x: d0exp_node): bool
fun
d0exp_node_is_ATSSELboxrec(x: d0exp_node): bool
fun
d0exp_node_is_ATSSELfltrec(x: d0exp_node): bool
fun
d0exp_node_is_ATSextfcall(x: d0exp_node): bool
fun
d0exp_node_is_ATSextmcall(x: d0exp_node): bool
fun
d0exp_node_is_ATSfunclo_fun(x: d0exp_node): bool
fun
d0exp_node_is_ATSfunclo_clo(x: d0exp_node): bool
//
fun
d0exp_encode(v: d0exp_view): d0exp
fun
d0exp_view(x: d0exp): d0exp_view
fun
d0exp_view_free(v: d0exp_view): void
fun
d0exp_tag(x: d0exp): int
fun
d0exp_D0EXP(a0: loc_t, a1: d0exp_node): d0exp
fun
d0exp_get_d0exp_loc(x: d0exp): loc_t
overload .d0exp_loc with d0exp_get_d0exp_loc
fun
d0exp_get_d0exp_node(x: d0exp): d0exp_node
overload .d0exp_node with d0exp_get_d0exp_node
//
fun
f0arg_node_encode(v: f0arg_node_view): f0arg_node
fun
f0arg_node_view(x: f0arg_node): f0arg_node_view
fun
f0arg_node_view_free(v: f0arg_node_view): void
fun
f0arg_node_tag(x: f0arg_node): int
fun
f0arg_node_F0ARGnone(a0: s0exp): f0arg_node
fun
f0arg_node_F0ARGsome(a0: i0de, a1: s0exp): f0arg_node
fun
f0arg_node_is_F0ARGnone(x: f0arg_node): bool
fun
f0arg_node_is_F0ARGsome(x: f0arg_node): bool
//
fun
f0arg_encode(v: f0arg_view): f0arg
fun
f0arg_view(x: f0arg): f0arg_view
fun
f0arg_view_free(v: f0arg_view): void
fun
f0arg_tag(x: f0arg): int
fun
f0arg_F0ARG(a0: loc_t, a1: f0arg_node): f0arg
fun
f0arg_get_f0arg_loc(x: f0arg): loc_t
overload .f0arg_loc with f0arg_get_f0arg_loc
fun
f0arg_get_f0arg_node(x: f0arg): f0arg_node
overload .f0arg_node with f0arg_get_f0arg_node
//
fun
f0marg_encode(v: f0marg_view): f0marg
fun
f0marg_view(x: f0marg): f0marg_view
fun
f0marg_view_free(v: f0marg_view): void
fun
f0marg_tag(x: f0marg): int
fun
f0marg_F0MARG(a0: loc_t, a1: glist(f0arg)): f0marg
fun
f0marg_get_f0marg_loc(x: f0marg): loc_t
overload .f0marg_loc with f0marg_get_f0marg_loc
fun
f0marg_get_f0marg_node(x: f0marg): glist(f0arg)
overload .f0marg_node with f0marg_get_f0marg_node
//
fun
fkind_encode(v: fkind_view): fkind
fun
fkind_view(x: fkind): fkind_view
fun
fkind_view_free(v: fkind_view): void
fun
fkind_tag(x: fkind): int
fun
fkind_FKIND(a0: loc_t, a1: fkind_node): fkind
fun
fkind_get_fkind_loc(x: fkind): loc_t
overload .fkind_loc with fkind_get_fkind_loc
fun
fkind_get_fkind_node(x: fkind): fkind_node
overload .fkind_node with fkind_get_fkind_node
//
fun
f0head_node_encode(v: f0head_node_view): f0head_node
fun
f0head_node_view(x: f0head_node): f0head_node_view
fun
f0head_node_view_free(v: f0head_node_view): void
fun
f0head_node_tag(x: f0head_node): int
fun
f0head_node_F0HEAD(a0: i0de, a1: f0marg, a2: s0exp): f0head_node
//
fun
f0head_encode(v: f0head_view): f0head
fun
f0head_view(x: f0head): f0head_view
fun
f0head_view_free(v: f0head_view): void
fun
f0head_tag(x: f0head): int
fun
f0head_F0HEADREC(a0: loc_t, a1: f0head_node): f0head
fun
f0head_get_f0head_loc(x: f0head): loc_t
overload .f0head_loc with f0head_get_f0head_loc
fun
f0head_get_f0head_node(x: f0head): f0head_node
overload .f0head_node with f0head_get_f0head_node
//
fun
tmpdec_node_encode(v: tmpdec_node_view): tmpdec_node
fun
tmpdec_node_view(x: tmpdec_node): tmpdec_node_view
fun
tmpdec_node_view_free(v: tmpdec_node_view): void
fun
tmpdec_node_tag(x: tmpdec_node): int
fun
tmpdec_node_TMPDECnone(a0: i0de): tmpdec_node
fun
tmpdec_node_TMPDECsome(a0: i0de, a1: s0exp): tmpdec_node
fun
tmpdec_node_is_TMPDECnone(x: tmpdec_node): bool
fun
tmpdec_node_is_TMPDECsome(x: tmpdec_node): bool
//
fun
tmpdec_encode(v: tmpdec_view): tmpdec
fun
tmpdec_view(x: tmpdec): tmpdec_view
fun
tmpdec_view_free(v: tmpdec_view): void
fun
tmpdec_tag(x: tmpdec): int
fun
tmpdec_TMPDEC(a0: loc_t, a1: tmpdec_node): tmpdec
fun
tmpdec_get_tmpdec_loc(x: tmpdec): loc_t
overload .tmpdec_loc with tmpdec_get_tmpdec_loc
fun
tmpdec_get_tmpdec_node(x: tmpdec): tmpdec_node
overload .tmpdec_node with tmpdec_get_tmpdec_node
//
fun
instr_node_encode(v: instr_node_view): instr_node
fun
instr_node_view(x: instr_node): instr_node_view
fun
instr_node_view_free(v: instr_node_view): void
fun
instr_node_tag(x: instr_node): int
fun
instr_node_ATSif(a0: d0exp, a1: glist(instr), a2: gopt(glist(instr))): instr_node
fun
instr_node_ATSthen(a0: glist(instr)): instr_node
fun
instr_node_ATSelse(a0: glist(instr)): instr_node
fun
instr_node_ATSifthen(a0: d0exp, a1: glist(instr)): instr_node
fun
instr_node_ATSifnthen(a0: d0exp, a1: glist(instr)): instr_node
fun
instr_node_ATSbranchseq(a0: glist(instr)): instr_node
fun
instr_node_ATScaseofseq(a0: glist(instr)): instr_node
fun
instr_node_ATSfunbodyseq(a0: glist(instr)): instr_node
fun
instr_node_ATSreturn(a0: i0de): instr_node
fun
instr_node_ATSreturn_void(a0: i0de): instr_node
fun
instr_node_ATSlinepragma(a0: token, a1: token): instr_node
fun
instr_node_ATSINSlab(a0: i0de): instr_node
fun
instr_node_ATSINSgoto(a0: i0de): instr_node
fun
instr_node_ATSINSflab(a0: i0de): instr_node
fun
instr_node_ATSINSfgoto(a0: i0de): instr_node
fun
instr_node_ATSINSfreeclo(a0: d0exp): instr_node
fun
instr_node_ATSINSfreecon(a0: d0exp): instr_node
fun
instr_node_ATSINSmove(a0: i0de, a1: d0exp): instr_node
fun
instr_node_ATSINSmove_void(a0: i0de, a1: d0exp): instr_node
fun
instr_node_ATSINSmove_nil(a0: i0de): instr_node
fun
instr_node_ATSINSmove_con0(a0: i0de, a1: token): instr_node
fun
instr_node_ATSINSmove_con1(a0: glist(instr)): instr_node
fun
instr_node_ATSINSmove_con1_new(a0: i0de, a1: s0exp): instr_node
fun
instr_node_ATSINSstore_con1_tag(a0: i0de, a1: token): instr_node
fun
instr_node_ATSINSstore_con1_ofs(a0: i0de, a1: s0exp, a2: i0de, a3: d0exp): instr_node
fun
instr_node_ATSINSmove_boxrec(a0: glist(instr)): instr_node
fun
instr_node_ATSINSmove_boxrec_new(a0: i0de, a1: s0exp): instr_node
fun
instr_node_ATSINSstore_boxrec_ofs(a0: i0de, a1: s0exp, a2: i0de, a3: d0exp): instr_node
fun
instr_node_ATSINSmove_fltrec(a0: glist(instr)): instr_node
fun
instr_node_ATSINSstore_fltrec_ofs(a0: i0de, a1: s0exp, a2: i0de, a3: d0exp): instr_node
fun
instr_node_ATSINSmove_delay(a0: i0de, a1: s0exp, a2: d0exp): instr_node
fun
instr_node_ATSINSmove_lazyeval(a0: i0de, a1: s0exp, a2: d0exp): instr_node
fun
instr_node_ATSINSmove_ldelay(a0: i0de, a1: s0exp, a2: d0exp): instr_node
fun
instr_node_ATSINSmove_llazyeval(a0: i0de, a1: s0exp, a2: d0exp): instr_node
fun
instr_node_ATStailcalseq(a0: glist(instr)): instr_node
fun
instr_node_ATSINSmove_tlcal(a0: i0de, a1: d0exp): instr_node
fun
instr_node_ATSINSargmove_tlcal(a0: i0de, a1: i0de): instr_node
fun
instr_node_ATSINSextvar_assign(a0: d0exp, a1: d0exp): instr_node
fun
instr_node_ATSINSdyncst_valbind(a0: i0de, a1: d0exp): instr_node
fun
instr_node_ATSINScaseof_fail(a0: token): instr_node
fun
instr_node_ATSINSdeadcode_fail(a0: token): instr_node
fun
instr_node_ATSdynload(a0: int): instr_node
fun
instr_node_ATSdynloadset(a0: i0de): instr_node
fun
instr_node_ATSdynloadfcall(a0: i0de): instr_node
fun
instr_node_ATSdynloadflag_sta(a0: i0de): instr_node
fun
instr_node_ATSdynloadflag_ext(a0: i0de): instr_node
fun
instr_node_ATSdynloadflag_init(a0: i0de): instr_node
fun
instr_node_ATSdynloadflag_minit(a0: i0de): instr_node
fun
instr_node_ATSdynexn_dec(a0: i0de): instr_node
fun
instr_node_ATSdynexn_extdec(a0: i0de): instr_node
fun
instr_node_ATSdynexn_initize(a0: i0de, a1: string): instr_node
fun
instr_node_is_ATSif(x: instr_node): bool
fun
instr_node_is_ATSthen(x: instr_node): bool
fun
instr_node_is_ATSelse(x: instr_node): bool
fun
instr_node_is_ATSifthen(x: instr_node): bool
fun
instr_node_is_ATSifnthen(x: instr_node): bool
fun
instr_node_is_ATSbranchseq(x: instr_node): bool
fun
instr_node_is_ATScaseofseq(x: instr_node): bool
fun
instr_node_is_ATSfunbodyseq(x: instr_node): bool
fun
instr_node_is_ATSreturn(x: instr_node): bool
fun
instr_node_is_ATSreturn_void(x: instr_node): bool
fun
instr_node_is_ATSlinepragma(x: instr_node): bool
fun
instr_node_is_ATSINSlab(x: instr_node): bool
fun
instr_node_is_ATSINSgoto(x: instr_node): bool
fun
instr_node_is_ATSINSflab(x: instr_node): bool
fun
instr_node_is_ATSINSfgoto(x: instr_node): bool
fun
instr_node_is_ATSINSfreeclo(x: instr_node): bool
fun
instr_node_is_ATSINSfreecon(x: instr_node): bool
fun
instr_node_is_ATSINSmove(x: instr_node): bool
fun
instr_node_is_ATSINSmove_void(x: instr_node): bool
fun
instr_node_is_ATSINSmove_nil(x: instr_node): bool
fun
instr_node_is_ATSINSmove_con0(x: instr_node): bool
fun
instr_node_is_ATSINSmove_con1(x: instr_node): bool
fun
instr_node_is_ATSINSmove_con1_new(x: instr_node): bool
fun
instr_node_is_ATSINSstore_con1_tag(x: instr_node): bool
fun
instr_node_is_ATSINSstore_con1_ofs(x: instr_node): bool
fun
instr_node_is_ATSINSmove_boxrec(x: instr_node): bool
fun
instr_node_is_ATSINSmove_boxrec_new(x: instr_node): bool
fun
instr_node_is_ATSINSstore_boxrec_ofs(x: instr_node): bool
fun
instr_node_is_ATSINSmove_fltrec(x: instr_node): bool
fun
instr_node_is_ATSINSstore_fltrec_ofs(x: instr_node): bool
fun
instr_node_is_ATSINSmove_delay(x: instr_node): bool
fun
instr_node_is_ATSINSmove_lazyeval(x: instr_node): bool
fun
instr_node_is_ATSINSmove_ldelay(x: instr_node): bool
fun
instr_node_is_ATSINSmove_llazyeval(x: instr_node): bool
fun
instr_node_is_ATStailcalseq(x: instr_node): bool
fun
instr_node_is_ATSINSmove_tlcal(x: instr_node): bool
fun
instr_node_is_ATSINSargmove_tlcal(x: instr_node): bool
fun
instr_node_is_ATSINSextvar_assign(x: instr_node): bool
fun
instr_node_is_ATSINSdyncst_valbind(x: instr_node): bool
fun
instr_node_is_ATSINScaseof_fail(x: instr_node): bool
fun
instr_node_is_ATSINSdeadcode_fail(x: instr_node): bool
fun
instr_node_is_ATSdynload(x: instr_node): bool
fun
instr_node_is_ATSdynloadset(x: instr_node): bool
fun
instr_node_is_ATSdynloadfcall(x: instr_node): bool
fun
instr_node_is_ATSdynloadflag_sta(x: instr_node): bool
fun
instr_node_is_ATSdynloadflag_ext(x: instr_node): bool
fun
instr_node_is_ATSdynloadflag_init(x: instr_node): bool
fun
instr_node_is_ATSdynloadflag_minit(x: instr_node): bool
fun
instr_node_is_ATSdynexn_dec(x: instr_node): bool
fun
instr_node_is_ATSdynexn_extdec(x: instr_node): bool
fun
instr_node_is_ATSdynexn_initize(x: instr_node): bool
//
fun
instr_encode(v: instr_view): instr
fun
instr_view(x: instr): instr_view
fun
instr_view_free(v: instr_view): void
fun
instr_tag(x: instr): int
fun
instr_INSTR(a0: loc_t, a1: instr_node): instr
fun
instr_get_instr_loc(x: instr): loc_t
overload .instr_loc with instr_get_instr_loc
fun
instr_get_instr_node(x: instr): instr_node
overload .instr_node with instr_get_instr_node
//
fun
f0body_node_encode(v: f0body_node_view): f0body_node
fun
f0body_node_view(x: f0body_node): f0body_node_view
fun
f0body_node_view_free(v: f0body_node_view): void
fun
f0body_node_tag(x: f0body_node): int
fun
f0body_node_F0BODY(a0: glist(tmpdec), a1: glist(instr)): f0body_node
//
fun
f0body_encode(v: f0body_view): f0body
fun
f0body_view(x: f0body): f0body_view
fun
f0body_view_free(v: f0body_view): void
fun
f0body_tag(x: f0body): int
fun
f0body_F0BODYREC(a0: loc_t, a1: f0body_node): f0body
fun
f0body_get_f0body_loc(x: f0body): loc_t
overload .f0body_loc with f0body_get_f0body_loc
fun
f0body_get_f0body_node(x: f0body): f0body_node
overload .f0body_node with f0body_get_f0body_node
//
fun
f0decl_node_encode(v: f0decl_node_view): f0decl_node
fun
f0decl_node_view(x: f0decl_node): f0decl_node_view
fun
f0decl_node_view_free(v: f0decl_node_view): void
fun
f0decl_node_tag(x: f0decl_node): int
fun
f0decl_node_F0DECLnone(a0: f0head): f0decl_node
fun
f0decl_node_F0DECLsome(a0: f0head, a1: f0body): f0decl_node
fun
f0decl_node_is_F0DECLnone(x: f0decl_node): bool
fun
f0decl_node_is_F0DECLsome(x: f0decl_node): bool
//
fun
f0decl_encode(v: f0decl_view): f0decl
fun
f0decl_view(x: f0decl): f0decl_view
fun
f0decl_view_free(v: f0decl_view): void
fun
f0decl_tag(x: f0decl): int
fun
f0decl_F0DECLREC(a0: loc_t, a1: f0decl_node): f0decl
fun
f0decl_get_f0decl_loc(x: f0decl): loc_t
overload .f0decl_loc with f0decl_get_f0decl_loc
fun
f0decl_get_f0decl_node(x: f0decl): f0decl_node
overload .f0decl_node with f0decl_get_f0decl_node
//
fun
d0ecl_node_encode(v: d0ecl_node_view): d0ecl_node
fun
d0ecl_node_view(x: d0ecl_node): d0ecl_node_view
fun
d0ecl_node_view_free(v: d0ecl_node_view): void
fun
d0ecl_node_tag(x: d0ecl_node): int
fun
d0ecl_node_D0Cinclude(a0: token): d0ecl_node
fun
d0ecl_node_D0Cifdef(a0: i0de, a1: glist(d0ecl)): d0ecl_node
fun
d0ecl_node_D0Cifndef(a0: i0de, a1: glist(d0ecl)): d0ecl_node
fun
d0ecl_node_D0Ctypedef(a0: i0de, a1: tyrec): d0ecl_node
fun
d0ecl_node_D0Cassume(a0: i0de): d0ecl_node
fun
d0ecl_node_D0Cdyncst_mac(a0: i0de): d0ecl_node
fun
d0ecl_node_D0Cdyncst_extfun(a0: i0de, a1: glist(s0exp), a2: s0exp): d0ecl_node
fun
d0ecl_node_D0Cdyncst_valdec(a0: i0de, a1: s0exp): d0ecl_node
fun
d0ecl_node_D0Cdyncst_valimp(a0: i0de, a1: s0exp): d0ecl_node
fun
d0ecl_node_D0Cextcode(a0: glist(token)): d0ecl_node
fun
d0ecl_node_D0Cstatmp(a0: i0de, a1: gopt(s0exp)): d0ecl_node
fun
d0ecl_node_D0Cfundecl(a0: fkind, a1: f0decl): d0ecl_node
fun
d0ecl_node_D0Cclosurerize(a0: i0de, a1: s0exp, a2: s0exp, a3: s0exp): d0ecl_node
fun
d0ecl_node_D0Cdynloadflag_init(a0: i0de): d0ecl_node
fun
d0ecl_node_D0Cdynloadflag_minit(a0: i0de): d0ecl_node
fun
d0ecl_node_D0Cdynexn_dec(a0: i0de): d0ecl_node
fun
d0ecl_node_D0Cdynexn_extdec(a0: i0de): d0ecl_node
fun
d0ecl_node_D0Cdynexn_initize(a0: i0de, a1: token): d0ecl_node
fun
d0ecl_node_is_D0Cinclude(x: d0ecl_node): bool
fun
d0ecl_node_is_D0Cifdef(x: d0ecl_node): bool
fun
d0ecl_node_is_D0Cifndef(x: d0ecl_node): bool
fun
d0ecl_node_is_D0Ctypedef(x: d0ecl_node): bool
fun
d0ecl_node_is_D0Cassume(x: d0ecl_node): bool
fun
d0ecl_node_is_D0Cdyncst_mac(x: d0ecl_node): bool
fun
d0ecl_node_is_D0Cdyncst_extfun(x: d0ecl_node): bool
fun
d0ecl_node_is_D0Cdyncst_valdec(x: d0ecl_node): bool
fun
d0ecl_node_is_D0Cdyncst_valimp(x: d0ecl_node): bool
fun
d0ecl_node_is_D0Cextcode(x: d0ecl_node): bool
fun
d0ecl_node_is_D0Cstatmp(x: d0ecl_node): bool
fun
d0ecl_node_is_D0Cfundecl(x: d0ecl_node): bool
fun
d0ecl_node_is_D0Cclosurerize(x: d0ecl_node): bool
fun
d0ecl_node_is_D0Cdynloadflag_init(x: d0ecl_node): bool
fun
d0ecl_node_is_D0Cdynloadflag_minit(x: d0ecl_node): bool
fun
d0ecl_node_is_D0Cdynexn_dec(x: d0ecl_node): bool
fun
d0ecl_node_is_D0Cdynexn_extdec(x: d0ecl_node): bool
fun
d0ecl_node_is_D0Cdynexn_initize(x: d0ecl_node): bool
//
fun
d0ecl_encode(v: d0ecl_view): d0ecl
fun
d0ecl_view(x: d0ecl): d0ecl_view
fun
d0ecl_view_free(v: d0ecl_view): void
fun
d0ecl_tag(x: d0ecl): int
fun
d0ecl_D0ECLREC(a0: loc_t, a1: d0ecl_node): d0ecl
fun
d0ecl_get_d0ecl_loc(x: d0ecl): loc_t
overload .d0ecl_loc with d0ecl_get_d0ecl_loc
fun
d0ecl_get_d0ecl_node(x: d0ecl): d0ecl_node
overload .d0ecl_node with d0ecl_get_d0ecl_node
//
