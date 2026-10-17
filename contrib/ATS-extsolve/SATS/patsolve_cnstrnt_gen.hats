abstype
label_type(l:addr) = ptr
typedef
label(l:addr) = label_type(l)

abstype
s2rt_type(l:addr) = ptr
typedef
s2rt(l:addr) = s2rt_type(l)

abstype
tyreckind_type(l:addr) = ptr
typedef
tyreckind(l:addr) = tyreckind_type(l)

abstype
s2exp_type(l:addr) = ptr
typedef
s2exp(l:addr) = s2exp_type(l)

abstype
s2exp_node_type(l:addr) = ptr
typedef
s2exp_node(l:addr) = s2exp_node_type(l)

abstype
labs2exp_type(l:addr) = ptr
typedef
labs2exp(l:addr) = labs2exp_type(l)

abstype
c3nstrkind_type(l:addr) = ptr
typedef
c3nstrkind(l:addr) = c3nstrkind_type(l)

abstype
s3itm_type(l:addr) = ptr
typedef
s3itm(l:addr) = s3itm_type(l)

abstype
h3ypo_type(l:addr) = ptr
typedef
h3ypo(l:addr) = h3ypo_type(l)

abstype
h3ypo_node_type(l:addr) = ptr
typedef
h3ypo_node(l:addr) = h3ypo_node_type(l)

abstype
c3nstr_type(l:addr) = ptr
typedef
c3nstr(l:addr) = c3nstr_type(l)

abstype
c3nstr_node_type(l:addr) = ptr
typedef
c3nstr_node(l:addr) = c3nstr_node_type(l)

abstype
c3nstropt_type(l:addr) = ptr
typedef
c3nstropt(l:addr) = c3nstropt_type(l)

//
datavtype
label_view(l:addr) =
  | LABint of (int)
  | LABsym of (symbol(l))
and
s2rt_view(l:addr) =
  | S2RTint of ()
  | S2RTaddr of ()
  | S2RTbool of ()
  | S2RTreal of ()
  | S2RTfloat of ()
  | S2RTstring of ()
  | S2RTcls of ()
  | S2RTeff of ()
  | S2RTtup of ()
  | S2RTtype of ()
  | S2RTvtype of ()
  | S2RTt0ype of ()
  | S2RTvt0ype of ()
  | S2RTprop of ()
  | S2RTview of ()
  | S2RTtkind of ()
  | S2RTfun of (alist(l, s2rt(l)), s2rt(l))
  | S2RTnamed of (symbol(l))
  | S2RTerror of ()
and
tyreckind_view(l:addr) =
  | TYRECKINDbox of ()
  | TYRECKINDbox_lin of ()
  | TYRECKINDflt0 of ()
  | TYRECKINDflt1 of (stamp)
  | TYRECKINDflt_ext of (astring(l))
and
s2exp_view(l:addr) =
  | S2EXP of (s2rt(l), s2exp_node(l))
and
s2exp_node_view(l:addr) =
  | S2Eint of (int)
  | S2Eintinf of (astring(l))
  | S2Ecst of (s2cst(l))
  | S2Evar of (s2var(l))
  | S2EVar of (s2Var(l))
  | S2Eeqeq of (s2exp(l), s2exp(l))
  | S2Esizeof of (s2exp(l))
  | S2Eapp of (s2exp(l), alist(l, s2exp(l)))
  | S2Emetdec of (alist(l, s2exp(l)), alist(l, s2exp(l)))
  | S2Etop of (int, s2exp(l))
  | S2Einvar of (s2exp(l))
  | S2Efun of (int, alist(l, s2exp(l)), s2exp(l))
  | S2Euni of (alist(l, s2var(l)), alist(l, s2exp(l)), s2exp(l))
  | S2Eexi of (alist(l, s2var(l)), alist(l, s2exp(l)), s2exp(l))
  | S2Etyrec of (tyreckind(l), int, alist(l, labs2exp(l)))
  | S2Eextype of (symbol(l))
  | S2Eextkind of (symbol(l))
  | S2Eerror of ()
and
labs2exp_view(l:addr) =
  | SLABELED of (label(l), s2exp(l))
and
c3nstrkind_view(l:addr) =
  | C3TKmain of ()
  | C3TKtermet_isnat of ()
  | C3TKtermet_isdec of ()
  | C3TKsolver of (int)
  | C3TKignored of ()
and
s3itm_view(l:addr) =
  | S3ITMsvar of (s2var(l))
  | S3ITMsVar of (s2Var(l))
  | S3ITMhypo of (h3ypo(l))
  | S3ITMcnstr of (c3nstr(l))
  | S3ITMcnstr_ref of (astring(l), c3nstropt(l))
  | S3ITMdisj of (alist(l, alist(l, s3itm(l))))
  | S3ITMsolassert of (s2exp(l))
and
h3ypo_view(l:addr) =
  | H3YPO of (astring(l), h3ypo_node(l))
and
h3ypo_node_view(l:addr) =
  | H3YPOprop of (s2exp(l))
  | H3YPObind of (s2var(l), s2exp(l))
  | H3YPOeqeq of (s2exp(l), s2exp(l))
and
c3nstr_view(l:addr) =
  | C3NSTR of (astring(l), c3nstrkind(l), c3nstr_node(l))
and
c3nstr_node_view(l:addr) =
  | C3NSTRprop of (s2exp(l))
  | C3NSTRitmlst of (alist(l, s3itm(l)))
  | C3NSTRsolverify of (s2exp(l))
and
c3nstropt_view(l:addr) =
  | C3NSTRnone of ()
  | C3NSTRsome of (c3nstr(l))
//
fun
label_encode{l:addr}(ar: !arena(l), v: label_view(l)): label(l)
fun
label_view{l:addr}(ar: !arena(l), x: label(l)): label_view(l)
fun
label_view_free{l:addr}(v: label_view(l)): void
fun
label_tag{l:addr}(ar: !arena(l), x: label(l)): int
fun
label_LABint{l:addr}(ar: !arena(l), a0: int): label(l)
fun
label_LABsym{l:addr}(ar: !arena(l), a0: symbol(l)): label(l)
fun
label_is_LABint{l:addr}(ar: !arena(l), x: label(l)): bool
fun
label_is_LABsym{l:addr}(ar: !arena(l), x: label(l)): bool
//
fun
s2rt_encode{l:addr}(ar: !arena(l), v: s2rt_view(l)): s2rt(l)
fun
s2rt_view{l:addr}(ar: !arena(l), x: s2rt(l)): s2rt_view(l)
fun
s2rt_view_free{l:addr}(v: s2rt_view(l)): void
fun
s2rt_tag{l:addr}(ar: !arena(l), x: s2rt(l)): int
fun
s2rt_S2RTint{l:addr}(ar: !arena(l)): s2rt(l)
fun
s2rt_S2RTaddr{l:addr}(ar: !arena(l)): s2rt(l)
fun
s2rt_S2RTbool{l:addr}(ar: !arena(l)): s2rt(l)
fun
s2rt_S2RTreal{l:addr}(ar: !arena(l)): s2rt(l)
fun
s2rt_S2RTfloat{l:addr}(ar: !arena(l)): s2rt(l)
fun
s2rt_S2RTstring{l:addr}(ar: !arena(l)): s2rt(l)
fun
s2rt_S2RTcls{l:addr}(ar: !arena(l)): s2rt(l)
fun
s2rt_S2RTeff{l:addr}(ar: !arena(l)): s2rt(l)
fun
s2rt_S2RTtup{l:addr}(ar: !arena(l)): s2rt(l)
fun
s2rt_S2RTtype{l:addr}(ar: !arena(l)): s2rt(l)
fun
s2rt_S2RTvtype{l:addr}(ar: !arena(l)): s2rt(l)
fun
s2rt_S2RTt0ype{l:addr}(ar: !arena(l)): s2rt(l)
fun
s2rt_S2RTvt0ype{l:addr}(ar: !arena(l)): s2rt(l)
fun
s2rt_S2RTprop{l:addr}(ar: !arena(l)): s2rt(l)
fun
s2rt_S2RTview{l:addr}(ar: !arena(l)): s2rt(l)
fun
s2rt_S2RTtkind{l:addr}(ar: !arena(l)): s2rt(l)
fun
s2rt_S2RTfun{l:addr}(ar: !arena(l), a0: alist(l, s2rt(l)), a1: s2rt(l)): s2rt(l)
fun
s2rt_S2RTnamed{l:addr}(ar: !arena(l), a0: symbol(l)): s2rt(l)
fun
s2rt_S2RTerror{l:addr}(ar: !arena(l)): s2rt(l)
fun
s2rt_is_S2RTint{l:addr}(ar: !arena(l), x: s2rt(l)): bool
fun
s2rt_is_S2RTaddr{l:addr}(ar: !arena(l), x: s2rt(l)): bool
fun
s2rt_is_S2RTbool{l:addr}(ar: !arena(l), x: s2rt(l)): bool
fun
s2rt_is_S2RTreal{l:addr}(ar: !arena(l), x: s2rt(l)): bool
fun
s2rt_is_S2RTfloat{l:addr}(ar: !arena(l), x: s2rt(l)): bool
fun
s2rt_is_S2RTstring{l:addr}(ar: !arena(l), x: s2rt(l)): bool
fun
s2rt_is_S2RTcls{l:addr}(ar: !arena(l), x: s2rt(l)): bool
fun
s2rt_is_S2RTeff{l:addr}(ar: !arena(l), x: s2rt(l)): bool
fun
s2rt_is_S2RTtup{l:addr}(ar: !arena(l), x: s2rt(l)): bool
fun
s2rt_is_S2RTtype{l:addr}(ar: !arena(l), x: s2rt(l)): bool
fun
s2rt_is_S2RTvtype{l:addr}(ar: !arena(l), x: s2rt(l)): bool
fun
s2rt_is_S2RTt0ype{l:addr}(ar: !arena(l), x: s2rt(l)): bool
fun
s2rt_is_S2RTvt0ype{l:addr}(ar: !arena(l), x: s2rt(l)): bool
fun
s2rt_is_S2RTprop{l:addr}(ar: !arena(l), x: s2rt(l)): bool
fun
s2rt_is_S2RTview{l:addr}(ar: !arena(l), x: s2rt(l)): bool
fun
s2rt_is_S2RTtkind{l:addr}(ar: !arena(l), x: s2rt(l)): bool
fun
s2rt_is_S2RTfun{l:addr}(ar: !arena(l), x: s2rt(l)): bool
fun
s2rt_is_S2RTnamed{l:addr}(ar: !arena(l), x: s2rt(l)): bool
fun
s2rt_is_S2RTerror{l:addr}(ar: !arena(l), x: s2rt(l)): bool
//
fun
tyreckind_encode{l:addr}(ar: !arena(l), v: tyreckind_view(l)): tyreckind(l)
fun
tyreckind_view{l:addr}(ar: !arena(l), x: tyreckind(l)): tyreckind_view(l)
fun
tyreckind_view_free{l:addr}(v: tyreckind_view(l)): void
fun
tyreckind_tag{l:addr}(ar: !arena(l), x: tyreckind(l)): int
fun
tyreckind_TYRECKINDbox{l:addr}(ar: !arena(l)): tyreckind(l)
fun
tyreckind_TYRECKINDbox_lin{l:addr}(ar: !arena(l)): tyreckind(l)
fun
tyreckind_TYRECKINDflt0{l:addr}(ar: !arena(l)): tyreckind(l)
fun
tyreckind_TYRECKINDflt1{l:addr}(ar: !arena(l), a0: stamp): tyreckind(l)
fun
tyreckind_TYRECKINDflt_ext{l:addr}(ar: !arena(l), a0: astring(l)): tyreckind(l)
fun
tyreckind_is_TYRECKINDbox{l:addr}(ar: !arena(l), x: tyreckind(l)): bool
fun
tyreckind_is_TYRECKINDbox_lin{l:addr}(ar: !arena(l), x: tyreckind(l)): bool
fun
tyreckind_is_TYRECKINDflt0{l:addr}(ar: !arena(l), x: tyreckind(l)): bool
fun
tyreckind_is_TYRECKINDflt1{l:addr}(ar: !arena(l), x: tyreckind(l)): bool
fun
tyreckind_is_TYRECKINDflt_ext{l:addr}(ar: !arena(l), x: tyreckind(l)): bool
//
fun
s2exp_encode{l:addr}(ar: !arena(l), v: s2exp_view(l)): s2exp(l)
fun
s2exp_view{l:addr}(ar: !arena(l), x: s2exp(l)): s2exp_view(l)
fun
s2exp_view_free{l:addr}(v: s2exp_view(l)): void
fun
s2exp_tag{l:addr}(ar: !arena(l), x: s2exp(l)): int
fun
s2exp_S2EXP{l:addr}(ar: !arena(l), a0: s2rt(l), a1: s2exp_node(l)): s2exp(l)
fun
s2exp_get_srt{l:addr}(ar: !arena(l), x: s2exp(l)): s2rt(l)
fun
s2exp_get_node{l:addr}(ar: !arena(l), x: s2exp(l)): s2exp_node(l)
//
fun
s2exp_node_encode{l:addr}(ar: !arena(l), v: s2exp_node_view(l)): s2exp_node(l)
fun
s2exp_node_view{l:addr}(ar: !arena(l), x: s2exp_node(l)): s2exp_node_view(l)
fun
s2exp_node_view_free{l:addr}(v: s2exp_node_view(l)): void
fun
s2exp_node_tag{l:addr}(ar: !arena(l), x: s2exp_node(l)): int
fun
s2exp_node_S2Eint{l:addr}(ar: !arena(l), a0: int): s2exp_node(l)
fun
s2exp_node_S2Eintinf{l:addr}(ar: !arena(l), a0: astring(l)): s2exp_node(l)
fun
s2exp_node_S2Ecst{l:addr}(ar: !arena(l), a0: s2cst(l)): s2exp_node(l)
fun
s2exp_node_S2Evar{l:addr}(ar: !arena(l), a0: s2var(l)): s2exp_node(l)
fun
s2exp_node_S2EVar{l:addr}(ar: !arena(l), a0: s2Var(l)): s2exp_node(l)
fun
s2exp_node_S2Eeqeq{l:addr}(ar: !arena(l), a0: s2exp(l), a1: s2exp(l)): s2exp_node(l)
fun
s2exp_node_S2Esizeof{l:addr}(ar: !arena(l), a0: s2exp(l)): s2exp_node(l)
fun
s2exp_node_S2Eapp{l:addr}(ar: !arena(l), a0: s2exp(l), a1: alist(l, s2exp(l))): s2exp_node(l)
fun
s2exp_node_S2Emetdec{l:addr}(ar: !arena(l), a0: alist(l, s2exp(l)), a1: alist(l, s2exp(l))): s2exp_node(l)
fun
s2exp_node_S2Etop{l:addr}(ar: !arena(l), a0: int, a1: s2exp(l)): s2exp_node(l)
fun
s2exp_node_S2Einvar{l:addr}(ar: !arena(l), a0: s2exp(l)): s2exp_node(l)
fun
s2exp_node_S2Efun{l:addr}(ar: !arena(l), a0: int, a1: alist(l, s2exp(l)), a2: s2exp(l)): s2exp_node(l)
fun
s2exp_node_S2Euni{l:addr}(ar: !arena(l), a0: alist(l, s2var(l)), a1: alist(l, s2exp(l)), a2: s2exp(l)): s2exp_node(l)
fun
s2exp_node_S2Eexi{l:addr}(ar: !arena(l), a0: alist(l, s2var(l)), a1: alist(l, s2exp(l)), a2: s2exp(l)): s2exp_node(l)
fun
s2exp_node_S2Etyrec{l:addr}(ar: !arena(l), a0: tyreckind(l), a1: int, a2: alist(l, labs2exp(l))): s2exp_node(l)
fun
s2exp_node_S2Eextype{l:addr}(ar: !arena(l), a0: symbol(l)): s2exp_node(l)
fun
s2exp_node_S2Eextkind{l:addr}(ar: !arena(l), a0: symbol(l)): s2exp_node(l)
fun
s2exp_node_S2Eerror{l:addr}(ar: !arena(l)): s2exp_node(l)
fun
s2exp_node_is_S2Eint{l:addr}(ar: !arena(l), x: s2exp_node(l)): bool
fun
s2exp_node_is_S2Eintinf{l:addr}(ar: !arena(l), x: s2exp_node(l)): bool
fun
s2exp_node_is_S2Ecst{l:addr}(ar: !arena(l), x: s2exp_node(l)): bool
fun
s2exp_node_is_S2Evar{l:addr}(ar: !arena(l), x: s2exp_node(l)): bool
fun
s2exp_node_is_S2EVar{l:addr}(ar: !arena(l), x: s2exp_node(l)): bool
fun
s2exp_node_is_S2Eeqeq{l:addr}(ar: !arena(l), x: s2exp_node(l)): bool
fun
s2exp_node_is_S2Esizeof{l:addr}(ar: !arena(l), x: s2exp_node(l)): bool
fun
s2exp_node_is_S2Eapp{l:addr}(ar: !arena(l), x: s2exp_node(l)): bool
fun
s2exp_node_is_S2Emetdec{l:addr}(ar: !arena(l), x: s2exp_node(l)): bool
fun
s2exp_node_is_S2Etop{l:addr}(ar: !arena(l), x: s2exp_node(l)): bool
fun
s2exp_node_is_S2Einvar{l:addr}(ar: !arena(l), x: s2exp_node(l)): bool
fun
s2exp_node_is_S2Efun{l:addr}(ar: !arena(l), x: s2exp_node(l)): bool
fun
s2exp_node_is_S2Euni{l:addr}(ar: !arena(l), x: s2exp_node(l)): bool
fun
s2exp_node_is_S2Eexi{l:addr}(ar: !arena(l), x: s2exp_node(l)): bool
fun
s2exp_node_is_S2Etyrec{l:addr}(ar: !arena(l), x: s2exp_node(l)): bool
fun
s2exp_node_is_S2Eextype{l:addr}(ar: !arena(l), x: s2exp_node(l)): bool
fun
s2exp_node_is_S2Eextkind{l:addr}(ar: !arena(l), x: s2exp_node(l)): bool
fun
s2exp_node_is_S2Eerror{l:addr}(ar: !arena(l), x: s2exp_node(l)): bool
//
fun
labs2exp_encode{l:addr}(ar: !arena(l), v: labs2exp_view(l)): labs2exp(l)
fun
labs2exp_view{l:addr}(ar: !arena(l), x: labs2exp(l)): labs2exp_view(l)
fun
labs2exp_view_free{l:addr}(v: labs2exp_view(l)): void
fun
labs2exp_tag{l:addr}(ar: !arena(l), x: labs2exp(l)): int
fun
labs2exp_SLABELED{l:addr}(ar: !arena(l), a0: label(l), a1: s2exp(l)): labs2exp(l)
fun
labs2exp_get_lab{l:addr}(ar: !arena(l), x: labs2exp(l)): label(l)
fun
labs2exp_get_exp{l:addr}(ar: !arena(l), x: labs2exp(l)): s2exp(l)
//
fun
c3nstrkind_encode{l:addr}(ar: !arena(l), v: c3nstrkind_view(l)): c3nstrkind(l)
fun
c3nstrkind_view{l:addr}(ar: !arena(l), x: c3nstrkind(l)): c3nstrkind_view(l)
fun
c3nstrkind_view_free{l:addr}(v: c3nstrkind_view(l)): void
fun
c3nstrkind_tag{l:addr}(ar: !arena(l), x: c3nstrkind(l)): int
fun
c3nstrkind_C3TKmain{l:addr}(ar: !arena(l)): c3nstrkind(l)
fun
c3nstrkind_C3TKtermet_isnat{l:addr}(ar: !arena(l)): c3nstrkind(l)
fun
c3nstrkind_C3TKtermet_isdec{l:addr}(ar: !arena(l)): c3nstrkind(l)
fun
c3nstrkind_C3TKsolver{l:addr}(ar: !arena(l), a0: int): c3nstrkind(l)
fun
c3nstrkind_C3TKignored{l:addr}(ar: !arena(l)): c3nstrkind(l)
fun
c3nstrkind_is_C3TKmain{l:addr}(ar: !arena(l), x: c3nstrkind(l)): bool
fun
c3nstrkind_is_C3TKtermet_isnat{l:addr}(ar: !arena(l), x: c3nstrkind(l)): bool
fun
c3nstrkind_is_C3TKtermet_isdec{l:addr}(ar: !arena(l), x: c3nstrkind(l)): bool
fun
c3nstrkind_is_C3TKsolver{l:addr}(ar: !arena(l), x: c3nstrkind(l)): bool
fun
c3nstrkind_is_C3TKignored{l:addr}(ar: !arena(l), x: c3nstrkind(l)): bool
//
fun
s3itm_encode{l:addr}(ar: !arena(l), v: s3itm_view(l)): s3itm(l)
fun
s3itm_view{l:addr}(ar: !arena(l), x: s3itm(l)): s3itm_view(l)
fun
s3itm_view_free{l:addr}(v: s3itm_view(l)): void
fun
s3itm_tag{l:addr}(ar: !arena(l), x: s3itm(l)): int
fun
s3itm_S3ITMsvar{l:addr}(ar: !arena(l), a0: s2var(l)): s3itm(l)
fun
s3itm_S3ITMsVar{l:addr}(ar: !arena(l), a0: s2Var(l)): s3itm(l)
fun
s3itm_S3ITMhypo{l:addr}(ar: !arena(l), a0: h3ypo(l)): s3itm(l)
fun
s3itm_S3ITMcnstr{l:addr}(ar: !arena(l), a0: c3nstr(l)): s3itm(l)
fun
s3itm_S3ITMcnstr_ref{l:addr}(ar: !arena(l), a0: astring(l), a1: c3nstropt(l)): s3itm(l)
fun
s3itm_S3ITMdisj{l:addr}(ar: !arena(l), a0: alist(l, alist(l, s3itm(l)))): s3itm(l)
fun
s3itm_S3ITMsolassert{l:addr}(ar: !arena(l), a0: s2exp(l)): s3itm(l)
fun
s3itm_is_S3ITMsvar{l:addr}(ar: !arena(l), x: s3itm(l)): bool
fun
s3itm_is_S3ITMsVar{l:addr}(ar: !arena(l), x: s3itm(l)): bool
fun
s3itm_is_S3ITMhypo{l:addr}(ar: !arena(l), x: s3itm(l)): bool
fun
s3itm_is_S3ITMcnstr{l:addr}(ar: !arena(l), x: s3itm(l)): bool
fun
s3itm_is_S3ITMcnstr_ref{l:addr}(ar: !arena(l), x: s3itm(l)): bool
fun
s3itm_is_S3ITMdisj{l:addr}(ar: !arena(l), x: s3itm(l)): bool
fun
s3itm_is_S3ITMsolassert{l:addr}(ar: !arena(l), x: s3itm(l)): bool
//
fun
h3ypo_encode{l:addr}(ar: !arena(l), v: h3ypo_view(l)): h3ypo(l)
fun
h3ypo_view{l:addr}(ar: !arena(l), x: h3ypo(l)): h3ypo_view(l)
fun
h3ypo_view_free{l:addr}(v: h3ypo_view(l)): void
fun
h3ypo_tag{l:addr}(ar: !arena(l), x: h3ypo(l)): int
fun
h3ypo_H3YPO{l:addr}(ar: !arena(l), a0: astring(l), a1: h3ypo_node(l)): h3ypo(l)
fun
h3ypo_get_loc{l:addr}(ar: !arena(l), x: h3ypo(l)): astring(l)
fun
h3ypo_get_node{l:addr}(ar: !arena(l), x: h3ypo(l)): h3ypo_node(l)
//
fun
h3ypo_node_encode{l:addr}(ar: !arena(l), v: h3ypo_node_view(l)): h3ypo_node(l)
fun
h3ypo_node_view{l:addr}(ar: !arena(l), x: h3ypo_node(l)): h3ypo_node_view(l)
fun
h3ypo_node_view_free{l:addr}(v: h3ypo_node_view(l)): void
fun
h3ypo_node_tag{l:addr}(ar: !arena(l), x: h3ypo_node(l)): int
fun
h3ypo_node_H3YPOprop{l:addr}(ar: !arena(l), a0: s2exp(l)): h3ypo_node(l)
fun
h3ypo_node_H3YPObind{l:addr}(ar: !arena(l), a0: s2var(l), a1: s2exp(l)): h3ypo_node(l)
fun
h3ypo_node_H3YPOeqeq{l:addr}(ar: !arena(l), a0: s2exp(l), a1: s2exp(l)): h3ypo_node(l)
fun
h3ypo_node_is_H3YPOprop{l:addr}(ar: !arena(l), x: h3ypo_node(l)): bool
fun
h3ypo_node_is_H3YPObind{l:addr}(ar: !arena(l), x: h3ypo_node(l)): bool
fun
h3ypo_node_is_H3YPOeqeq{l:addr}(ar: !arena(l), x: h3ypo_node(l)): bool
//
fun
c3nstr_encode{l:addr}(ar: !arena(l), v: c3nstr_view(l)): c3nstr(l)
fun
c3nstr_view{l:addr}(ar: !arena(l), x: c3nstr(l)): c3nstr_view(l)
fun
c3nstr_view_free{l:addr}(v: c3nstr_view(l)): void
fun
c3nstr_tag{l:addr}(ar: !arena(l), x: c3nstr(l)): int
fun
c3nstr_C3NSTR{l:addr}(ar: !arena(l), a0: astring(l), a1: c3nstrkind(l), a2: c3nstr_node(l)): c3nstr(l)
fun
c3nstr_get_loc{l:addr}(ar: !arena(l), x: c3nstr(l)): astring(l)
fun
c3nstr_get_kind{l:addr}(ar: !arena(l), x: c3nstr(l)): c3nstrkind(l)
fun
c3nstr_get_node{l:addr}(ar: !arena(l), x: c3nstr(l)): c3nstr_node(l)
//
fun
c3nstr_node_encode{l:addr}(ar: !arena(l), v: c3nstr_node_view(l)): c3nstr_node(l)
fun
c3nstr_node_view{l:addr}(ar: !arena(l), x: c3nstr_node(l)): c3nstr_node_view(l)
fun
c3nstr_node_view_free{l:addr}(v: c3nstr_node_view(l)): void
fun
c3nstr_node_tag{l:addr}(ar: !arena(l), x: c3nstr_node(l)): int
fun
c3nstr_node_C3NSTRprop{l:addr}(ar: !arena(l), a0: s2exp(l)): c3nstr_node(l)
fun
c3nstr_node_C3NSTRitmlst{l:addr}(ar: !arena(l), a0: alist(l, s3itm(l))): c3nstr_node(l)
fun
c3nstr_node_C3NSTRsolverify{l:addr}(ar: !arena(l), a0: s2exp(l)): c3nstr_node(l)
fun
c3nstr_node_is_C3NSTRprop{l:addr}(ar: !arena(l), x: c3nstr_node(l)): bool
fun
c3nstr_node_is_C3NSTRitmlst{l:addr}(ar: !arena(l), x: c3nstr_node(l)): bool
fun
c3nstr_node_is_C3NSTRsolverify{l:addr}(ar: !arena(l), x: c3nstr_node(l)): bool
//
fun
c3nstropt_encode{l:addr}(ar: !arena(l), v: c3nstropt_view(l)): c3nstropt(l)
fun
c3nstropt_view{l:addr}(ar: !arena(l), x: c3nstropt(l)): c3nstropt_view(l)
fun
c3nstropt_view_free{l:addr}(v: c3nstropt_view(l)): void
fun
c3nstropt_tag{l:addr}(ar: !arena(l), x: c3nstropt(l)): int
fun
c3nstropt_C3NSTRnone{l:addr}(ar: !arena(l)): c3nstropt(l)
fun
c3nstropt_C3NSTRsome{l:addr}(ar: !arena(l), a0: c3nstr(l)): c3nstropt(l)
fun
c3nstropt_is_C3NSTRnone{l:addr}(ar: !arena(l), x: c3nstropt(l)): bool
fun
c3nstropt_is_C3NSTRsome{l:addr}(ar: !arena(l), x: c3nstropt(l)): bool
//
