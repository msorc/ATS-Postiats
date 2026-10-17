abstype
v1al_type = ptr
typedef
v1al = v1al_type

abstype
e1xp_node_type = ptr
typedef
e1xp_node = e1xp_node_type

abstype
e1xp_type = ptr
typedef
e1xp = e1xp_type

abstype
effcst_type = ptr
typedef
effcst = effcst_type

abstype
s1rt_node_type = ptr
typedef
s1rt_node = s1rt_node_type

abstype
s1rt_type = ptr
typedef
s1rt = s1rt_type

abstype
s1rtpol_type = ptr
typedef
s1rtpol = s1rtpol_type

abstype
d1atsrtcon_type = ptr
typedef
d1atsrtcon = d1atsrtcon_type

abstype
d1atsrtdec_type = ptr
typedef
d1atsrtdec = d1atsrtdec_type

abstype
s1arg_type = ptr
typedef
s1arg = s1arg_type

abstype
s1marg_type = ptr
typedef
s1marg = s1marg_type

abstype
s1var_type = ptr
typedef
s1var = s1var_type

abstype
a1srt_type = ptr
typedef
a1srt = a1srt_type

abstype
a1msrt_type = ptr
typedef
a1msrt = a1msrt_type

abstype
sp1at_node_type = ptr
typedef
sp1at_node = sp1at_node_type

abstype
sp1at_type = ptr
typedef
sp1at = sp1at_type

abstype
s1exp_node_type = ptr
typedef
s1exp_node = s1exp_node_type

abstype
s1rtext_node_type = ptr
typedef
s1rtext_node = s1rtext_node_type

abstype
s1qua_node_type = ptr
typedef
s1qua_node = s1qua_node_type

abstype
wths1explst_type = ptr
typedef
wths1explst = wths1explst_type

abstype
s1exp_type = ptr
typedef
s1exp = s1exp_type

abstype
labs1exp_type = ptr
typedef
labs1exp = labs1exp_type

abstype
s1rtext_type = ptr
typedef
s1rtext = s1rtext_type

abstype
s1qua_type = ptr
typedef
s1qua = s1qua_type

abstype
s1vararg_type = ptr
typedef
s1vararg = s1vararg_type

abstype
s1exparg_node_type = ptr
typedef
s1exparg_node = s1exparg_node_type

abstype
s1exparg_type = ptr
typedef
s1exparg = s1exparg_type

abstype
m1acarg_node_type = ptr
typedef
m1acarg_node = m1acarg_node_type

abstype
m1acarg_type = ptr
typedef
m1acarg = m1acarg_type

abstype
witht1ype_type = ptr
typedef
witht1ype = witht1ype_type

abstype
s1rtdef_type = ptr
typedef
s1rtdef = s1rtdef_type

abstype
s1tacst_type = ptr
typedef
s1tacst = s1tacst_type

abstype
s1tacon_type = ptr
typedef
s1tacon = s1tacon_type

abstype
t1kindef_type = ptr
typedef
t1kindef = t1kindef_type

abstype
s1expdef_type = ptr
typedef
s1expdef = s1expdef_type

abstype
s1aspdec_type = ptr
typedef
s1aspdec = s1aspdec_type

abstype
q1marg_type = ptr
typedef
q1marg = q1marg_type

abstype
i1mparg_type = ptr
typedef
i1mparg = i1mparg_type

abstype
t1mpmarg_type = ptr
typedef
t1mpmarg = t1mpmarg_type

abstype
d1atcon_type = ptr
typedef
d1atcon = d1atcon_type

abstype
d1atdec_type = ptr
typedef
d1atdec = d1atdec_type

abstype
e1xndec_type = ptr
typedef
e1xndec = e1xndec_type

abstype
d1cstdec_type = ptr
typedef
d1cstdec = d1cstdec_type

typedef v1alist = glist(v1al)
typedef e1xplst = glist(e1xp)
typedef effvarlst = glist(effvar)
typedef effcstopt = gopt(effcst)
typedef s1rtlst = glist(s1rt)
typedef s1rtopt = gopt(s1rt)
typedef s1rtlstlst = glist(s1rtlst)
typedef s1rtlstopt = gopt(s1rtlst)
typedef d1atsrtconlst = glist(d1atsrtcon)
typedef d1atsrtdeclst = glist(d1atsrtdec)
typedef s1arglst = glist(s1arg)
typedef s1arglstlst = glist(s1arglst)
typedef s1marglst = glist(s1marg)
typedef s1varlst = glist(s1var)
typedef a1srtlst = glist(a1srt)
typedef a1msrtlst = glist(a1msrt)
typedef s1explst = glist(s1exp)
vtypedef s1explst_vt = List0_vt(s1exp)
typedef s1expopt = gopt(s1exp)
typedef s1explstlst = glist(s1explst)
typedef s1explstopt = gopt(s1explst)
typedef labs1explst = glist(labs1exp)
typedef s1qualst = glist(s1qua)
typedef s1qualstlst = glist(s1qualst)
typedef s1vararglst = glist(s1vararg)
typedef s1exparglst = glist(s1exparg)
typedef s1expargopt = gopt(s1exparg)
typedef m1acarglst = glist(m1acarg)
typedef s1rtdeflst = glist(s1rtdef)
typedef s1tacstlst = glist(s1tacst)
typedef s1taconlst = glist(s1tacon)
typedef s1expdeflst = glist(s1expdef)
typedef s1aspdeclst = glist(s1aspdec)
typedef q1marglst = glist(q1marg)
typedef t1mpmarglst = glist(t1mpmarg)
typedef d1atconlst = glist(d1atcon)
typedef d1atdeclst = glist(d1atdec)
typedef e1xndeclst = glist(e1xndec)
typedef d1cstdeclst = glist(d1cstdec)
//
datavtype
v1al_view =
  | V1ALint of (int)
  | V1ALchar of (char)
  | V1ALstring of (string)
  | V1ALfloat of (double)
  | V1ALerr of ()
and
e1xp_node_view =
  | E1XPide of (symbol)
  | E1XPint of (int)
  | E1XPintrep of (string)
  | E1XPchar of (char)
  | E1XPfloat of (string)
  | E1XPstring of (string)
  | E1XPv1al of (v1al)
  | E1XPnone of ()
  | E1XPundef of ()
  | E1XPapp of (e1xp, location, e1xplst)
  | E1XPfun of (symbolist, e1xp)
  | E1XPif of (e1xp, e1xp, e1xp)
  | E1XPeval of (e1xp)
  | E1XPlist of (e1xplst)
  | E1XPerr of ()
and
effcst_view =
  | EFFCSTall of ()
  | EFFCSTnil of ()
  | EFFCSTset of (effset, effvarlst)
and
s1rt_node_view =
  | S1RTapp of (s1rt, s1rtlst)
  | S1RTlist of (s1rtlst)
  | S1RTqid of (s0rtq, symbol)
  | S1RTtype of (int)
  | S1RTerr of ()
and
sp1at_node_view =
  | SP1Tcstr of (s0taq, symbol, s1arglst)
and
s1exp_node_view =
  | S1Eide of (symbol)
  | S1Esqid of (s0taq, symbol)
  | S1Eint of (int)
  | S1Eintrep of (string)
  | S1Echar of (char)
  | S1Efloat of (string)
  | S1Estring of (string)
  | S1Eextype of (string, s1explstlst)
  | S1Eextkind of (string, s1explstlst)
  | S1Eapp of (s1exp, loc_t, s1explst)
  | S1Elam of (s1marg, s1rtopt, s1exp)
  | S1Eimp of (funclo, int, int, effcstopt)
  | S1Etop of (int, s1exp)
  | S1Elist of (int, s1explst)
  | S1Einvar of (int, s1exp)
  | S1Etrans of (s1exp, s1exp)
  | S1Etyarr of (s1exp, s1explst)
  | S1Etytup of (int, int, s1explst)
  | S1Etyrec of (int, int, labs1explst)
  | S1Etyrec_ext of (string, int, labs1explst)
  | S1Euni of (s1qualst, s1exp)
  | S1Eexi of (int, s1qualst, s1exp)
  | S1Eann of (s1exp, s1rt)
  | S1Ed2ctype of (S1Ed2ctype)
  | S1Eerr of ()
and
s1rtext_node_view =
  | S1TEsrt of (s1rt)
  | S1TEsub of (symbol, s1rtext, s1explst)
and
s1qua_node_view =
  | S1Qprop of (s1exp)
  | S1Qvars of (i0delst, s1rtext)
and
wths1explst_view =
  | WTHS1EXPLSTnil of ()
  | WTHS1EXPLSTcons_some of (int, int, s1exp, wths1explst)
  | WTHS1EXPLSTcons_none of (wths1explst)
and
s1vararg_view =
  | S1VARARGone of (location)
  | S1VARARGall of (location)
  | S1VARARGseq of (location, s1arglst)
and
s1exparg_node_view =
  | S1EXPARGone of ()
  | S1EXPARGall of ()
  | S1EXPARGseq of (s1explst)
and
m1acarg_node_view =
  | M1ACARGdyn of (i0delst)
  | M1ACARGsta of (s1arglst)
and
witht1ype_view =
  | WITHT1YPEsome of (int, s1exp)
  | WITHT1YPEnone of ()
and
i1mparg_view =
  | I1MPARG_sarglst of (s1arglst)
  | I1MPARG_svararglst of (s1vararglst)
//
fun
v1al_encode(v: v1al_view): v1al
fun
v1al_view(x: v1al): v1al_view
fun
v1al_view_free(v: v1al_view): void
fun
v1al_tag(x: v1al): int
fun
v1al_V1ALint(a0: int): v1al
fun
v1al_V1ALchar(a0: char): v1al
fun
v1al_V1ALstring(a0: string): v1al
fun
v1al_V1ALfloat(a0: double): v1al
fun
v1al_V1ALerr(): v1al
fun
v1al_is_V1ALint(x: v1al): bool
fun
v1al_is_V1ALchar(x: v1al): bool
fun
v1al_is_V1ALstring(x: v1al): bool
fun
v1al_is_V1ALfloat(x: v1al): bool
fun
v1al_is_V1ALerr(x: v1al): bool
//
fun
e1xp_node_encode(v: e1xp_node_view): e1xp_node
fun
e1xp_node_view(x: e1xp_node): e1xp_node_view
fun
e1xp_node_view_free(v: e1xp_node_view): void
fun
e1xp_node_tag(x: e1xp_node): int
fun
e1xp_node_E1XPide(a0: symbol): e1xp_node
fun
e1xp_node_E1XPint(a0: int): e1xp_node
fun
e1xp_node_E1XPintrep(a0: string): e1xp_node
fun
e1xp_node_E1XPchar(a0: char): e1xp_node
fun
e1xp_node_E1XPfloat(a0: string): e1xp_node
fun
e1xp_node_E1XPstring(a0: string): e1xp_node
fun
e1xp_node_E1XPv1al(a0: v1al): e1xp_node
fun
e1xp_node_E1XPnone(): e1xp_node
fun
e1xp_node_E1XPundef(): e1xp_node
fun
e1xp_node_E1XPapp(a0: e1xp, a1: location, a2: e1xplst): e1xp_node
fun
e1xp_node_E1XPfun(a0: symbolist, a1: e1xp): e1xp_node
fun
e1xp_node_E1XPif(a0: e1xp, a1: e1xp, a2: e1xp): e1xp_node
fun
e1xp_node_E1XPeval(a0: e1xp): e1xp_node
fun
e1xp_node_E1XPlist(a0: e1xplst): e1xp_node
fun
e1xp_node_E1XPerr(): e1xp_node
fun
e1xp_node_is_E1XPide(x: e1xp_node): bool
fun
e1xp_node_is_E1XPint(x: e1xp_node): bool
fun
e1xp_node_is_E1XPintrep(x: e1xp_node): bool
fun
e1xp_node_is_E1XPchar(x: e1xp_node): bool
fun
e1xp_node_is_E1XPfloat(x: e1xp_node): bool
fun
e1xp_node_is_E1XPstring(x: e1xp_node): bool
fun
e1xp_node_is_E1XPv1al(x: e1xp_node): bool
fun
e1xp_node_is_E1XPnone(x: e1xp_node): bool
fun
e1xp_node_is_E1XPundef(x: e1xp_node): bool
fun
e1xp_node_is_E1XPapp(x: e1xp_node): bool
fun
e1xp_node_is_E1XPfun(x: e1xp_node): bool
fun
e1xp_node_is_E1XPif(x: e1xp_node): bool
fun
e1xp_node_is_E1XPeval(x: e1xp_node): bool
fun
e1xp_node_is_E1XPlist(x: e1xp_node): bool
fun
e1xp_node_is_E1XPerr(x: e1xp_node): bool
//
fun
e1xp_new(a0: location, a1: e1xp_node): e1xp
fun
e1xp_loc(x: e1xp): location
overload .e1xp_loc with e1xp_loc
fun
e1xp_node(x: e1xp): e1xp_node
overload .e1xp_node with e1xp_node
//
fun
effcst_encode(v: effcst_view): effcst
fun
effcst_view(x: effcst): effcst_view
fun
effcst_view_free(v: effcst_view): void
fun
effcst_tag(x: effcst): int
fun
effcst_EFFCSTall(): effcst
fun
effcst_EFFCSTnil(): effcst
fun
effcst_EFFCSTset(a0: effset, a1: effvarlst): effcst
fun
effcst_is_EFFCSTall(x: effcst): bool
fun
effcst_is_EFFCSTnil(x: effcst): bool
fun
effcst_is_EFFCSTset(x: effcst): bool
//
fun
s1rt_node_encode(v: s1rt_node_view): s1rt_node
fun
s1rt_node_view(x: s1rt_node): s1rt_node_view
fun
s1rt_node_view_free(v: s1rt_node_view): void
fun
s1rt_node_tag(x: s1rt_node): int
fun
s1rt_node_S1RTapp(a0: s1rt, a1: s1rtlst): s1rt_node
fun
s1rt_node_S1RTlist(a0: s1rtlst): s1rt_node
fun
s1rt_node_S1RTqid(a0: s0rtq, a1: symbol): s1rt_node
fun
s1rt_node_S1RTtype(a0: int): s1rt_node
fun
s1rt_node_S1RTerr(): s1rt_node
fun
s1rt_node_is_S1RTapp(x: s1rt_node): bool
fun
s1rt_node_is_S1RTlist(x: s1rt_node): bool
fun
s1rt_node_is_S1RTqid(x: s1rt_node): bool
fun
s1rt_node_is_S1RTtype(x: s1rt_node): bool
fun
s1rt_node_is_S1RTerr(x: s1rt_node): bool
//
fun
s1rt_new(a0: location, a1: s1rt_node): s1rt
fun
s1rt_loc(x: s1rt): location
overload .s1rt_loc with s1rt_loc
fun
s1rt_node(x: s1rt): s1rt_node
overload .s1rt_node with s1rt_node
//
fun
s1rtpol_new(a0: location, a1: s1rt, a2: int): s1rtpol
fun
s1rtpol_loc(x: s1rtpol): location
overload .s1rtpol_loc with s1rtpol_loc
fun
s1rtpol_srt(x: s1rtpol): s1rt
overload .s1rtpol_srt with s1rtpol_srt
fun
s1rtpol_pol(x: s1rtpol): int
overload .s1rtpol_pol with s1rtpol_pol
//
fun
d1atsrtcon_new(a0: location, a1: symbol, a2: s1rtlst): d1atsrtcon
fun
d1atsrtcon_loc(x: d1atsrtcon): location
overload .d1atsrtcon_loc with d1atsrtcon_loc
fun
d1atsrtcon_sym(x: d1atsrtcon): symbol
overload .d1atsrtcon_sym with d1atsrtcon_sym
fun
d1atsrtcon_arg(x: d1atsrtcon): s1rtlst
overload .d1atsrtcon_arg with d1atsrtcon_arg
//
fun
d1atsrtdec_new(a0: location, a1: symbol, a2: d1atsrtconlst): d1atsrtdec
fun
d1atsrtdec_loc(x: d1atsrtdec): location
overload .d1atsrtdec_loc with d1atsrtdec_loc
fun
d1atsrtdec_sym(x: d1atsrtdec): symbol
overload .d1atsrtdec_sym with d1atsrtdec_sym
fun
d1atsrtdec_con(x: d1atsrtdec): d1atsrtconlst
overload .d1atsrtdec_con with d1atsrtdec_con
//
fun
s1arg_new(a0: location, a1: symbol, a2: s1rtopt): s1arg
fun
s1arg_loc(x: s1arg): location
overload .s1arg_loc with s1arg_loc
fun
s1arg_sym(x: s1arg): symbol
overload .s1arg_sym with s1arg_sym
fun
s1arg_srt(x: s1arg): s1rtopt
overload .s1arg_srt with s1arg_srt
//
fun
s1marg_new(a0: location, a1: s1arglst): s1marg
fun
s1marg_loc(x: s1marg): location
overload .s1marg_loc with s1marg_loc
fun
s1marg_arg(x: s1marg): s1arglst
overload .s1marg_arg with s1marg_arg
//
fun
s1var_new(a0: location, a1: symbol, a2: s1rt): s1var
fun
s1var_loc(x: s1var): location
overload .s1var_loc with s1var_loc
fun
s1var_sym(x: s1var): symbol
overload .s1var_sym with s1var_sym
fun
s1var_srt(x: s1var): s1rt
overload .s1var_srt with s1var_srt
//
fun
a1srt_new(a0: location, a1: symbolopt, a2: s1rt): a1srt
fun
a1srt_loc(x: a1srt): location
overload .a1srt_loc with a1srt_loc
fun
a1srt_sym(x: a1srt): symbolopt
overload .a1srt_sym with a1srt_sym
fun
a1srt_srt(x: a1srt): s1rt
overload .a1srt_srt with a1srt_srt
//
fun
a1msrt_new(a0: location, a1: a1srtlst): a1msrt
fun
a1msrt_loc(x: a1msrt): location
overload .a1msrt_loc with a1msrt_loc
fun
a1msrt_arg(x: a1msrt): a1srtlst
overload .a1msrt_arg with a1msrt_arg
//
fun
sp1at_node_encode(v: sp1at_node_view): sp1at_node
fun
sp1at_node_view(x: sp1at_node): sp1at_node_view
fun
sp1at_node_view_free(v: sp1at_node_view): void
fun
sp1at_node_tag(x: sp1at_node): int
fun
sp1at_node_SP1Tcstr(a0: s0taq, a1: symbol, a2: s1arglst): sp1at_node
//
fun
sp1at_new(a0: location, a1: sp1at_node): sp1at
fun
sp1at_loc(x: sp1at): location
overload .sp1at_loc with sp1at_loc
fun
sp1at_node(x: sp1at): sp1at_node
overload .sp1at_node with sp1at_node
//
fun
s1exp_node_encode(v: s1exp_node_view): s1exp_node
fun
s1exp_node_view(x: s1exp_node): s1exp_node_view
fun
s1exp_node_view_free(v: s1exp_node_view): void
fun
s1exp_node_tag(x: s1exp_node): int
fun
s1exp_node_S1Eide(a0: symbol): s1exp_node
fun
s1exp_node_S1Esqid(a0: s0taq, a1: symbol): s1exp_node
fun
s1exp_node_S1Eint(a0: int): s1exp_node
fun
s1exp_node_S1Eintrep(a0: string): s1exp_node
fun
s1exp_node_S1Echar(a0: char): s1exp_node
fun
s1exp_node_S1Efloat(a0: string): s1exp_node
fun
s1exp_node_S1Estring(a0: string): s1exp_node
fun
s1exp_node_S1Eextype(a0: string, a1: s1explstlst): s1exp_node
fun
s1exp_node_S1Eextkind(a0: string, a1: s1explstlst): s1exp_node
fun
s1exp_node_S1Eapp(a0: s1exp, a1: loc_t, a2: s1explst): s1exp_node
fun
s1exp_node_S1Elam(a0: s1marg, a1: s1rtopt, a2: s1exp): s1exp_node
fun
s1exp_node_S1Eimp(a0: funclo, a1: int, a2: int, a3: effcstopt): s1exp_node
fun
s1exp_node_S1Etop(a0: int, a1: s1exp): s1exp_node
fun
s1exp_node_S1Elist(a0: int, a1: s1explst): s1exp_node
fun
s1exp_node_S1Einvar(a0: int, a1: s1exp): s1exp_node
fun
s1exp_node_S1Etrans(a0: s1exp, a1: s1exp): s1exp_node
fun
s1exp_node_S1Etyarr(a0: s1exp, a1: s1explst): s1exp_node
fun
s1exp_node_S1Etytup(a0: int, a1: int, a2: s1explst): s1exp_node
fun
s1exp_node_S1Etyrec(a0: int, a1: int, a2: labs1explst): s1exp_node
fun
s1exp_node_S1Etyrec_ext(a0: string, a1: int, a2: labs1explst): s1exp_node
fun
s1exp_node_S1Euni(a0: s1qualst, a1: s1exp): s1exp_node
fun
s1exp_node_S1Eexi(a0: int, a1: s1qualst, a2: s1exp): s1exp_node
fun
s1exp_node_S1Eann(a0: s1exp, a1: s1rt): s1exp_node
fun
s1exp_node_S1Ed2ctype(a0: S1Ed2ctype): s1exp_node
fun
s1exp_node_S1Eerr(): s1exp_node
fun
s1exp_node_is_S1Eide(x: s1exp_node): bool
fun
s1exp_node_is_S1Esqid(x: s1exp_node): bool
fun
s1exp_node_is_S1Eint(x: s1exp_node): bool
fun
s1exp_node_is_S1Eintrep(x: s1exp_node): bool
fun
s1exp_node_is_S1Echar(x: s1exp_node): bool
fun
s1exp_node_is_S1Efloat(x: s1exp_node): bool
fun
s1exp_node_is_S1Estring(x: s1exp_node): bool
fun
s1exp_node_is_S1Eextype(x: s1exp_node): bool
fun
s1exp_node_is_S1Eextkind(x: s1exp_node): bool
fun
s1exp_node_is_S1Eapp(x: s1exp_node): bool
fun
s1exp_node_is_S1Elam(x: s1exp_node): bool
fun
s1exp_node_is_S1Eimp(x: s1exp_node): bool
fun
s1exp_node_is_S1Etop(x: s1exp_node): bool
fun
s1exp_node_is_S1Elist(x: s1exp_node): bool
fun
s1exp_node_is_S1Einvar(x: s1exp_node): bool
fun
s1exp_node_is_S1Etrans(x: s1exp_node): bool
fun
s1exp_node_is_S1Etyarr(x: s1exp_node): bool
fun
s1exp_node_is_S1Etytup(x: s1exp_node): bool
fun
s1exp_node_is_S1Etyrec(x: s1exp_node): bool
fun
s1exp_node_is_S1Etyrec_ext(x: s1exp_node): bool
fun
s1exp_node_is_S1Euni(x: s1exp_node): bool
fun
s1exp_node_is_S1Eexi(x: s1exp_node): bool
fun
s1exp_node_is_S1Eann(x: s1exp_node): bool
fun
s1exp_node_is_S1Ed2ctype(x: s1exp_node): bool
fun
s1exp_node_is_S1Eerr(x: s1exp_node): bool
//
fun
s1rtext_node_encode(v: s1rtext_node_view): s1rtext_node
fun
s1rtext_node_view(x: s1rtext_node): s1rtext_node_view
fun
s1rtext_node_view_free(v: s1rtext_node_view): void
fun
s1rtext_node_tag(x: s1rtext_node): int
fun
s1rtext_node_S1TEsrt(a0: s1rt): s1rtext_node
fun
s1rtext_node_S1TEsub(a0: symbol, a1: s1rtext, a2: s1explst): s1rtext_node
fun
s1rtext_node_is_S1TEsrt(x: s1rtext_node): bool
fun
s1rtext_node_is_S1TEsub(x: s1rtext_node): bool
//
fun
s1qua_node_encode(v: s1qua_node_view): s1qua_node
fun
s1qua_node_view(x: s1qua_node): s1qua_node_view
fun
s1qua_node_view_free(v: s1qua_node_view): void
fun
s1qua_node_tag(x: s1qua_node): int
fun
s1qua_node_S1Qprop(a0: s1exp): s1qua_node
fun
s1qua_node_S1Qvars(a0: i0delst, a1: s1rtext): s1qua_node
fun
s1qua_node_is_S1Qprop(x: s1qua_node): bool
fun
s1qua_node_is_S1Qvars(x: s1qua_node): bool
//
fun
wths1explst_encode(v: wths1explst_view): wths1explst
fun
wths1explst_view(x: wths1explst): wths1explst_view
fun
wths1explst_view_free(v: wths1explst_view): void
fun
wths1explst_tag(x: wths1explst): int
fun
wths1explst_WTHS1EXPLSTnil(): wths1explst
fun
wths1explst_WTHS1EXPLSTcons_some(a0: int, a1: int, a2: s1exp, a3: wths1explst): wths1explst
fun
wths1explst_WTHS1EXPLSTcons_none(a0: wths1explst): wths1explst
fun
wths1explst_is_WTHS1EXPLSTnil(x: wths1explst): bool
fun
wths1explst_is_WTHS1EXPLSTcons_some(x: wths1explst): bool
fun
wths1explst_is_WTHS1EXPLSTcons_none(x: wths1explst): bool
//
fun
s1exp_new(a0: location, a1: s1exp_node): s1exp
fun
s1exp_loc(x: s1exp): location
overload .s1exp_loc with s1exp_loc
fun
s1exp_node(x: s1exp): s1exp_node
overload .s1exp_node with s1exp_node
//
fun
labs1exp_new(a0: l0ab, a1: s0tringopt, a2: s1exp): labs1exp
fun
labs1exp_lab(x: labs1exp): l0ab
overload .labs1exp_lab with labs1exp_lab
fun
labs1exp_nam(x: labs1exp): s0tringopt
overload .labs1exp_nam with labs1exp_nam
fun
labs1exp_elt(x: labs1exp): s1exp
overload .labs1exp_elt with labs1exp_elt
//
fun
s1rtext_new(a0: location, a1: s1rtext_node): s1rtext
fun
s1rtext_loc(x: s1rtext): location
overload .s1rtext_loc with s1rtext_loc
fun
s1rtext_node(x: s1rtext): s1rtext_node
overload .s1rtext_node with s1rtext_node
//
fun
s1qua_new(a0: location, a1: s1qua_node): s1qua
fun
s1qua_loc(x: s1qua): location
overload .s1qua_loc with s1qua_loc
fun
s1qua_node(x: s1qua): s1qua_node
overload .s1qua_node with s1qua_node
//
fun
s1vararg_encode(v: s1vararg_view): s1vararg
fun
s1vararg_view(x: s1vararg): s1vararg_view
fun
s1vararg_view_free(v: s1vararg_view): void
fun
s1vararg_tag(x: s1vararg): int
fun
s1vararg_S1VARARGone(a0: location): s1vararg
fun
s1vararg_S1VARARGall(a0: location): s1vararg
fun
s1vararg_S1VARARGseq(a0: location, a1: s1arglst): s1vararg
fun
s1vararg_is_S1VARARGone(x: s1vararg): bool
fun
s1vararg_is_S1VARARGall(x: s1vararg): bool
fun
s1vararg_is_S1VARARGseq(x: s1vararg): bool
//
fun
s1exparg_node_encode(v: s1exparg_node_view): s1exparg_node
fun
s1exparg_node_view(x: s1exparg_node): s1exparg_node_view
fun
s1exparg_node_view_free(v: s1exparg_node_view): void
fun
s1exparg_node_tag(x: s1exparg_node): int
fun
s1exparg_node_S1EXPARGone(): s1exparg_node
fun
s1exparg_node_S1EXPARGall(): s1exparg_node
fun
s1exparg_node_S1EXPARGseq(a0: s1explst): s1exparg_node
fun
s1exparg_node_is_S1EXPARGone(x: s1exparg_node): bool
fun
s1exparg_node_is_S1EXPARGall(x: s1exparg_node): bool
fun
s1exparg_node_is_S1EXPARGseq(x: s1exparg_node): bool
//
fun
s1exparg_new(a0: location, a1: s1exparg_node): s1exparg
fun
s1exparg_loc(x: s1exparg): location
overload .s1exparg_loc with s1exparg_loc
fun
s1exparg_node(x: s1exparg): s1exparg_node
overload .s1exparg_node with s1exparg_node
//
fun
m1acarg_node_encode(v: m1acarg_node_view): m1acarg_node
fun
m1acarg_node_view(x: m1acarg_node): m1acarg_node_view
fun
m1acarg_node_view_free(v: m1acarg_node_view): void
fun
m1acarg_node_tag(x: m1acarg_node): int
fun
m1acarg_node_M1ACARGdyn(a0: i0delst): m1acarg_node
fun
m1acarg_node_M1ACARGsta(a0: s1arglst): m1acarg_node
fun
m1acarg_node_is_M1ACARGdyn(x: m1acarg_node): bool
fun
m1acarg_node_is_M1ACARGsta(x: m1acarg_node): bool
//
fun
m1acarg_new(a0: location, a1: m1acarg_node): m1acarg
fun
m1acarg_loc(x: m1acarg): location
overload .m1acarg_loc with m1acarg_loc
fun
m1acarg_node(x: m1acarg): m1acarg_node
overload .m1acarg_node with m1acarg_node
//
fun
witht1ype_encode(v: witht1ype_view): witht1ype
fun
witht1ype_view(x: witht1ype): witht1ype_view
fun
witht1ype_view_free(v: witht1ype_view): void
fun
witht1ype_tag(x: witht1ype): int
fun
witht1ype_WITHT1YPEsome(a0: int, a1: s1exp): witht1ype
fun
witht1ype_WITHT1YPEnone(): witht1ype
fun
witht1ype_is_WITHT1YPEsome(x: witht1ype): bool
fun
witht1ype_is_WITHT1YPEnone(x: witht1ype): bool
//
fun
s1rtdef_new(a0: location, a1: symbol, a2: s1rtext): s1rtdef
fun
s1rtdef_loc(x: s1rtdef): location
overload .s1rtdef_loc with s1rtdef_loc
fun
s1rtdef_sym(x: s1rtdef): symbol
overload .s1rtdef_sym with s1rtdef_sym
fun
s1rtdef_def(x: s1rtdef): s1rtext
overload .s1rtdef_def with s1rtdef_def
//
fun
s1tacst_new(a0: loc_t, a1: symbol, a2: filename, a3: a1msrtlst, a4: s1rt, a5: scstextdef): s1tacst
fun
s1tacst_loc(x: s1tacst): loc_t
overload .s1tacst_loc with s1tacst_loc
fun
s1tacst_sym(x: s1tacst): symbol
overload .s1tacst_sym with s1tacst_sym
fun
s1tacst_fil(x: s1tacst): filename
overload .s1tacst_fil with s1tacst_fil
fun
s1tacst_arg(x: s1tacst): a1msrtlst
overload .s1tacst_arg with s1tacst_arg
fun
s1tacst_res(x: s1tacst): s1rt
overload .s1tacst_res with s1tacst_res
fun
s1tacst_extdef(x: s1tacst): scstextdef
overload .s1tacst_extdef with s1tacst_extdef
//
fun
s1tacon_new(a0: loc_t, a1: symbol, a2: filename, a3: a1msrtlst, a4: s1expopt): s1tacon
fun
s1tacon_loc(x: s1tacon): loc_t
overload .s1tacon_loc with s1tacon_loc
fun
s1tacon_sym(x: s1tacon): symbol
overload .s1tacon_sym with s1tacon_sym
fun
s1tacon_fil(x: s1tacon): filename
overload .s1tacon_fil with s1tacon_fil
fun
s1tacon_arg(x: s1tacon): a1msrtlst
overload .s1tacon_arg with s1tacon_arg
fun
s1tacon_def(x: s1tacon): s1expopt
overload .s1tacon_def with s1tacon_def
//
fun
t1kindef_new(a0: location, a1: symbol, a2: location, a3: s1exp): t1kindef
fun
t1kindef_loc(x: t1kindef): location
overload .t1kindef_loc with t1kindef_loc
fun
t1kindef_sym(x: t1kindef): symbol
overload .t1kindef_sym with t1kindef_sym
fun
t1kindef_loc_id(x: t1kindef): location
overload .t1kindef_loc_id with t1kindef_loc_id
fun
t1kindef_def(x: t1kindef): s1exp
overload .t1kindef_def with t1kindef_def
//
fun
s1expdef_new(a0: location, a1: symbol, a2: location, a3: s1marglst, a4: s1rtopt, a5: s1exp): s1expdef
fun
s1expdef_loc(x: s1expdef): location
overload .s1expdef_loc with s1expdef_loc
fun
s1expdef_sym(x: s1expdef): symbol
overload .s1expdef_sym with s1expdef_sym
fun
s1expdef_loc_id(x: s1expdef): location
overload .s1expdef_loc_id with s1expdef_loc_id
fun
s1expdef_arg(x: s1expdef): s1marglst
overload .s1expdef_arg with s1expdef_arg
fun
s1expdef_res(x: s1expdef): s1rtopt
overload .s1expdef_res with s1expdef_res
fun
s1expdef_def(x: s1expdef): s1exp
overload .s1expdef_def with s1expdef_def
//
fun
s1aspdec_new(a0: location, a1: sqi0de, a2: s1marglst, a3: s1rtopt, a4: s1exp): s1aspdec
fun
s1aspdec_loc(x: s1aspdec): location
overload .s1aspdec_loc with s1aspdec_loc
fun
s1aspdec_qid(x: s1aspdec): sqi0de
overload .s1aspdec_qid with s1aspdec_qid
fun
s1aspdec_arg(x: s1aspdec): s1marglst
overload .s1aspdec_arg with s1aspdec_arg
fun
s1aspdec_res(x: s1aspdec): s1rtopt
overload .s1aspdec_res with s1aspdec_res
fun
s1aspdec_def(x: s1aspdec): s1exp
overload .s1aspdec_def with s1aspdec_def
//
fun
q1marg_new(a0: location, a1: s1qualst): q1marg
fun
q1marg_loc(x: q1marg): location
overload .q1marg_loc with q1marg_loc
fun
q1marg_arg(x: q1marg): s1qualst
overload .q1marg_arg with q1marg_arg
//
fun
i1mparg_encode(v: i1mparg_view): i1mparg
fun
i1mparg_view(x: i1mparg): i1mparg_view
fun
i1mparg_view_free(v: i1mparg_view): void
fun
i1mparg_tag(x: i1mparg): int
fun
i1mparg_I1MPARG_sarglst(a0: s1arglst): i1mparg
fun
i1mparg_I1MPARG_svararglst(a0: s1vararglst): i1mparg
fun
i1mparg_is_I1MPARG_sarglst(x: i1mparg): bool
fun
i1mparg_is_I1MPARG_svararglst(x: i1mparg): bool
//
fun
t1mpmarg_new(a0: location, a1: s1explst): t1mpmarg
fun
t1mpmarg_loc(x: t1mpmarg): location
overload .t1mpmarg_loc with t1mpmarg_loc
fun
t1mpmarg_arg(x: t1mpmarg): s1explst
overload .t1mpmarg_arg with t1mpmarg_arg
//
fun
d1atcon_new(a0: location, a1: symbol, a2: q1marglst, a3: int, a4: s1explst, a5: s1explstopt): d1atcon
fun
d1atcon_loc(x: d1atcon): location
overload .d1atcon_loc with d1atcon_loc
fun
d1atcon_sym(x: d1atcon): symbol
overload .d1atcon_sym with d1atcon_sym
fun
d1atcon_qua(x: d1atcon): q1marglst
overload .d1atcon_qua with d1atcon_qua
fun
d1atcon_npf(x: d1atcon): int
overload .d1atcon_npf with d1atcon_npf
fun
d1atcon_arg(x: d1atcon): s1explst
overload .d1atcon_arg with d1atcon_arg
fun
d1atcon_ind(x: d1atcon): s1explstopt
overload .d1atcon_ind with d1atcon_ind
//
fun
d1atdec_new(a0: location, a1: filename, a2: symbol, a3: a1msrtlst, a4: d1atconlst): d1atdec
fun
d1atdec_loc(x: d1atdec): location
overload .d1atdec_loc with d1atdec_loc
fun
d1atdec_fil(x: d1atdec): filename
overload .d1atdec_fil with d1atdec_fil
fun
d1atdec_sym(x: d1atdec): symbol
overload .d1atdec_sym with d1atdec_sym
fun
d1atdec_arg(x: d1atdec): a1msrtlst
overload .d1atdec_arg with d1atdec_arg
fun
d1atdec_con(x: d1atdec): d1atconlst
overload .d1atdec_con with d1atdec_con
//
fun
e1xndec_new(a0: location, a1: filename, a2: symbol, a3: q1marglst, a4: int, a5: s1explst): e1xndec
fun
e1xndec_loc(x: e1xndec): location
overload .e1xndec_loc with e1xndec_loc
fun
e1xndec_fil(x: e1xndec): filename
overload .e1xndec_fil with e1xndec_fil
fun
e1xndec_sym(x: e1xndec): symbol
overload .e1xndec_sym with e1xndec_sym
fun
e1xndec_qua(x: e1xndec): q1marglst
overload .e1xndec_qua with e1xndec_qua
fun
e1xndec_npf(x: e1xndec): int
overload .e1xndec_npf with e1xndec_npf
fun
e1xndec_arg(x: e1xndec): s1explst
overload .e1xndec_arg with e1xndec_arg
//
fun
d1cstdec_new(a0: location, a1: filename, a2: symbol, a3: s1exp, a4: dcstextdef): d1cstdec
fun
d1cstdec_loc(x: d1cstdec): location
overload .d1cstdec_loc with d1cstdec_loc
fun
d1cstdec_fil(x: d1cstdec): filename
overload .d1cstdec_fil with d1cstdec_fil
fun
d1cstdec_sym(x: d1cstdec): symbol
overload .d1cstdec_sym with d1cstdec_sym
fun
d1cstdec_type(x: d1cstdec): s1exp
overload .d1cstdec_type with d1cstdec_type
fun
d1cstdec_extdef(x: d1cstdec): dcstextdef
overload .d1cstdec_extdef with d1cstdec_extdef
//
