abstype
tmplab_type = ptr
typedef
tmplab = tmplab_type

abstype
tmpvar_type = ptr
typedef
tmpvar = tmpvar_type

abstype
d2env_type = ptr
typedef
d2env = d2env_type

abstype
funlab_type = ptr
typedef
funlab = funlab_type

abstype
funent_type = ptr
typedef
funent = funent_type

abstype
tmpsub_type = ptr
typedef
tmpsub = tmpsub_type

abstype
tmpcstmat_type = ptr
typedef
tmpcstmat = tmpcstmat_type

abstype
tmpvarmat_type = ptr
typedef
tmpvarmat = tmpvarmat_type

abstype
hifundec2_type = ptr
typedef
hifundec2 = hifundec2_type

abstype
hiimpdec2_type = ptr
typedef
hiimpdec2 = hiimpdec2_type

abstype
primcstsp_type = ptr
typedef
primcstsp = primcstsp_type

abstype
primdec_node_type = ptr
typedef
primdec_node = primdec_node_type

abstype
primval_node_type = ptr
typedef
primval_node = primval_node_type

abstype
primlab_node_type = ptr
typedef
primlab_node = primlab_node_type

abstype
labprimval_type = ptr
typedef
labprimval = labprimval_type

abstype
primdec_type = ptr
typedef
primdec = primdec_type

abstype
primval_type = ptr
typedef
primval = primval_type

abstype
primlab_type = ptr
typedef
primlab = primlab_type

abstype
patck_type = ptr
typedef
patck = patck_type

abstype
tmprimval_type = ptr
typedef
tmprimval = tmprimval_type

abstype
tmpmov_type = ptr
typedef
tmpmov = tmpmov_type

abstype
patckont_type = ptr
typedef
patckont = patckont_type

abstype
instr_node_type = ptr
typedef
instr_node = instr_node_type

abstype
instr_type = ptr
typedef
instr = instr_type

abstype
ibranch_type = ptr
typedef
ibranch = ibranch_type

typedef vbindmap = d2varmap(primval)
typedef tmplabopt = gopt(tmplab)
typedef tmpvarlst = glist(tmpvar)
typedef tmpvaropt = gopt(tmpvar)
vtypedef tmpvarlst_vt = List0_vt(tmpvar)
vtypedef tmpvaropt_vt = Option_vt(tmpvar)
typedef d2envlst = glist(d2env)
typedef d2envlstopt = gopt(d2envlst)
vtypedef d2envlst_vt = List0_vt(d2env)
typedef funlablst = glist(funlab)
typedef funlabopt = gopt(funlab)
typedef funlablstopt = gopt(funlablst)
vtypedef funlablst_vt = List0_vt(funlab)
vtypedef funlabopt_vt = Option_vt(funlab)
typedef funentlst = glist(funent)
typedef funentopt = gopt(funent)
vtypedef funentopt_vt = Option_vt(funent)
typedef tmpsubopt = gopt(tmpsub)
vtypedef tmpsubopt_vt = Option_vt(tmpsub)
typedef primdeclst = glist(primdec)
vtypedef primdeclst_vt = List0_vt(primdec)
typedef primvalist = glist(primval)
typedef primvalopt = gopt(primval)
vtypedef primvalist_vt = List0_vt(primval)
typedef labprimvalist = glist(labprimval)
vtypedef labprimvalist_vt = List0_vt(labprimval)
typedef primlablst = glist(primlab)
typedef tmpmovlst = glist(tmpmov)
vtypedef tmpmovlst_vt = List0_vt(tmpmov)
typedef instrlst = glist(instr)
vtypedef instrlst_vt = List0_vt(instr)
typedef instrlstopt = gopt(instrlst)
typedef ibranchlst = glist(ibranch)
//
datavtype
tmpsub_view =
  | TMPSUBcons of (s2var, s2exp, tmpsub)
  | TMPSUBnil of ()
and
tmpcstmat_view =
  | TMPCSTMATnone of ()
  | TMPCSTMATsome of (hiimpdec, tmpsub, int)
  | TMPCSTMATsome2 of (d2cst, s2explstlst, funlab)
and
tmpvarmat_view =
  | TMPVARMATnone of ()
  | TMPVARMATsome of (hifundec, tmpsub, int)
  | TMPVARMATsome2 of (d2var, s2explstlst, funlab)
and
primcstsp_view =
  | PMCSTSPmyfil of (filename)
  | PMCSTSPmyloc of (location)
  | PMCSTSPmyfun of (funlab)
and
primdec_node_view =
  | PMDnone of ()
  | PMDlist of (primdeclst)
  | PMDsaspdec of (s2aspdec)
  | PMDextvar of (string, instrlst)
  | PMDdatdecs of (s2cstlst)
  | PMDexndecs of (d2conlst)
  | PMDfundecs of (funkind, s2qualst, hifundeclst)
  | PMDvaldecs of (valkind, hivaldeclst, instrlst)
  | PMDvaldecs_rec of (valkind, hivaldeclst, instrlst)
  | PMDvardecs of (hivardeclst, instrlst)
  | PMDimpdec of (hiimpdec)
  | PMDinclude of (int, primdeclst)
  | PMDstaload of (hidecl)
  | PMDstaloadloc of (filename, symbol, primdeclst)
  | PMDdynload of (hidecl)
  | PMDlocal of (primdeclst, primdeclst)
and
primval_node_view =
  | PMVtmp of (tmpvar)
  | PMVtmpref of (tmpvar)
  | PMVarg of (int)
  | PMVargref of (int)
  | PMVargenv of (int)
  | PMVargtmpref of (int)
  | PMVcst of (d2cst)
  | PMVenv of (d2var)
  | PMVint of (int)
  | PMVintrep of (string)
  | PMVbool of (bool)
  | PMVchar of (char)
  | PMVfloat of (double)
  | PMVstring of (string)
  | PMVi0nt of (i0nt)
  | PMVf0loat of (f0loat)
  | PMVcstsp of (primcstsp)
  | PMVtyrep of (hisexp)
  | PMVsizeof of (hisexp)
  | PMVtop of ()
  | PMVempty of ()
  | PMVextval of (string)
  | PMVcastfn of (d2cst, primval)
  | PMVselcon of (primval, hisexp, label)
  | PMVselect of (primval, hisexp, primlab)
  | PMVselect2 of (primval, hisexp, primlablst)
  | PMVselptr of (primval, hisexp, primlablst)
  | PMVptrof of (primval)
  | PMVptrofsel of (primval, hisexp, primlablst)
  | PMVvararg of (primvalist)
  | PMVrefarg of (int, int, primval)
  | PMVfunlab of (funlab)
  | PMVcfunlab of (int, funlab)
  | PMVd2vfunlab of (d2var, funlab)
  | PMVlamfix of (d2varopt, primval)
  | PMVtmpltcst of (d2cst, t2mpmarglst)
  | PMVtmpltvar of (d2var, t2mpmarglst)
  | PMVtmpltcstmat of (d2cst, t2mpmarglst, tmpcstmat)
  | PMVtmpltvarmat of (d2var, t2mpmarglst, tmpvarmat)
  | PMVerror of ()
and
primlab_node_view =
  | PMLlab of (label)
  | PMLind of (primvalist)
and
patck_view =
  | PATCKcon of (d2con)
  | PATCKint of (int)
  | PATCKbool of (bool)
  | PATCKchar of (char)
  | PATCKfloat of (double)
  | PATCKstring of (string)
  | PATCKi0nt of (i0nt)
  | PATCKf0loat of (f0loat)
and
tmprimval_view =
  | TPMVnone of (primval)
  | TPMVsome of (tmpvar, primval)
and
patckont_view =
  | PTCKNTnone of ()
  | PTCKNTtmplab of (tmplab)
  | PTCKNTtmplabint of (tmplab, int)
  | PTCKNTtmplabmov of (tmplab, tmpmovlst)
  | PTCKNTcaseof_fail of (location)
  | PTCKNTfunarg_fail of (location, funlab)
  | PTCKNTraise of (tmpvar, primval)
and
instr_node_view =
  | INSfunlab of (funlab)
  | INStmplab of (tmplab)
  | INScomment of (string)
  | INSmove_val of (tmpvar, primval)
  | INSpmove_val of (tmpvar, primval)
  | INSmove_arg_val of (int, primval)
  | INSfcall of (tmpvar, primval, hisexp, primvalist)
  | INSfcall2 of (tmpvar, funlab, int, hisexp, primvalist)
  | INSextfcall of (tmpvar, string, primvalist)
  | INSextmcall of (tmpvar, primval, string, primvalist)
  | INScond of (primval, instrlst, instrlst)
  | INSfreecon of (primval)
  | INSloop of (tmplab, tmplab, tmplab, instrlst, primval, instrlst, instrlst, instrlst)
  | INSloopexn of (int, tmplab)
  | INScaseof of (ibranchlst)
  | INSletpop of ()
  | INSletpush of (primdeclst)
  | INSmove_con of (tmpvar, d2con, hisexp, labprimvalist)
  | INSmove_ref of (tmpvar, primval)
  | INSmove_boxrec of (tmpvar, labprimvalist, hisexp)
  | INSmove_fltrec of (tmpvar, labprimvalist, hisexp)
  | INSpatck of (primval, patck, patckont)
  | INSmove_ptrofsel of (tmpvar, primval, hisexp, primlablst)
  | INSstore_ptrofs of (primval, hisexp, primlablst, primval)
  | INSxstore_ptrofs of (tmpvar, primval, hisexp, primlablst, primval)
  | INSraise of (tmpvar, primval)
  | INSmove_delay of (tmpvar, int, hisexp, primval)
  | INSmove_lazyeval of (tmpvar, int, hisexp, primval)
  | INStrywith of (tmpvar, instrlst, ibranchlst)
  | INSmove_list_nil of (tmpvar)
  | INSpmove_list_nil of (tmpvar)
  | INSpmove_list_cons of (tmpvar, hisexp)
  | INSmove_list_phead of (tmpvar, tmpvar, hisexp)
  | INSmove_list_ptail of (tmpvar, tmpvar, hisexp)
  | INSmove_arrpsz_ptr of (tmpvar, tmpvar)
  | INSstore_arrpsz_asz of (tmpvar, int)
  | INSstore_arrpsz_ptr of (tmpvar, hisexp, int)
  | INSupdate_ptrinc of (tmpvar, hisexp)
  | INSupdate_ptrdec of (tmpvar, hisexp)
  | INSclosure_initize of (tmpvar, d2varopt, funlab)
  | INStmpdec of (tmpvar)
  | INSextvar of (string, primval)
  | INSdcstdef of (d2cst, primval)
  | INStempenver of (d2varlst)
//
fun
tmplab_new(a0: location, a1: stamp): tmplab
fun
tmplab_loc(x: tmplab): location
overload .tmplab_loc with tmplab_loc
fun
tmplab_stamp(x: tmplab): stamp
overload .tmplab_stamp with tmplab_stamp
//
fun
tmpvar_new(a0: location, a1: hisexp, a2: int, a3: int, a4: int, a5: tmpvaropt, a6: int, a7: stamp): tmpvar
fun
tmpvar_loc(x: tmpvar): location
overload .tmpvar_loc with tmpvar_loc
fun
tmpvar_type(x: tmpvar): hisexp
overload .tmpvar_type with tmpvar_type
fun
set_tmpvar_type(x: tmpvar, v: hisexp): void
fun
tmpvar_ref(x: tmpvar): int
overload .tmpvar_ref with tmpvar_ref
fun
set_tmpvar_ref(x: tmpvar, v: int): void
fun
tmpvar_ret(x: tmpvar): int
overload .tmpvar_ret with tmpvar_ret
fun
set_tmpvar_ret(x: tmpvar, v: int): void
fun
tmpvar_topknd(x: tmpvar): int
overload .tmpvar_topknd with tmpvar_topknd
fun
set_tmpvar_topknd(x: tmpvar, v: int): void
fun
tmpvar_origin(x: tmpvar): tmpvaropt
overload .tmpvar_origin with tmpvar_origin
fun
set_tmpvar_origin(x: tmpvar, v: tmpvaropt): void
fun
tmpvar_suffix(x: tmpvar): int
overload .tmpvar_suffix with tmpvar_suffix
fun
set_tmpvar_suffix(x: tmpvar, v: int): void
fun
tmpvar_stamp(x: tmpvar): stamp
overload .tmpvar_stamp with tmpvar_stamp
//
fun
d2env_new(a0: d2var, a1: hisexp): d2env
fun
d2env_var(x: d2env): d2var
overload .d2env_var with d2env_var
fun
d2env_type(x: d2env): hisexp
overload .d2env_type with d2env_type
//
fun
funlab_new(a0: string, a1: int, a2: funclo, a3: hisexp, a4: int, a5: d2cstopt, a6: d2varopt, a7: int, a8: funlabopt, a9: int, a10: t2mpmarglst, a11: funentopt, a12: stamp): funlab
fun
funlab_name(x: funlab): string
overload .funlab_name with funlab_name
fun
funlab_level(x: funlab): int
overload .funlab_level with funlab_level
fun
funlab_funclo(x: funlab): funclo
overload .funlab_funclo with funlab_funclo
fun
funlab_type(x: funlab): hisexp
overload .funlab_type with funlab_type
fun
funlab_tmpknd(x: funlab): int
overload .funlab_tmpknd with funlab_tmpknd
fun
set_funlab_tmpknd(x: funlab, v: int): void
fun
funlab_d2copt(x: funlab): d2cstopt
overload .funlab_d2copt with funlab_d2copt
fun
funlab_d2vopt(x: funlab): d2varopt
overload .funlab_d2vopt with funlab_d2vopt
fun
funlab_ncopy(x: funlab): int
overload .funlab_ncopy with funlab_ncopy
fun
set_funlab_ncopy(x: funlab, v: int): void
fun
funlab_origin(x: funlab): funlabopt
overload .funlab_origin with funlab_origin
fun
set_funlab_origin(x: funlab, v: funlabopt): void
fun
funlab_suffix(x: funlab): int
overload .funlab_suffix with funlab_suffix
fun
set_funlab_suffix(x: funlab, v: int): void
fun
funlab_tmparg(x: funlab): t2mpmarglst
overload .funlab_tmparg with funlab_tmparg
fun
funlab_funent(x: funlab): funentopt
overload .funlab_funent with funlab_funent
fun
set_funlab_funent(x: funlab, v: funentopt): void
fun
funlab_stamp(x: funlab): stamp
overload .funlab_stamp with funlab_stamp
//
fun
funent_new(a0: location, a1: funlab, a2: s2varlst, a3: s2explstlst, a4: tmpsubopt, a5: tmpvar, a6: funlablst, a7: funlablstopt, a8: d2envlst, a9: d2envlstopt, a10: vbindmap, a11: instrlst, a12: tmpvarlst, a13: funlablst): funent
fun
funent_loc(x: funent): location
overload .funent_loc with funent_loc
fun
funent_lab(x: funent): funlab
overload .funent_lab with funent_lab
fun
funent_imparg(x: funent): s2varlst
overload .funent_imparg with funent_imparg
fun
funent_tmparg(x: funent): s2explstlst
overload .funent_tmparg with funent_tmparg
fun
funent_tmpsub(x: funent): tmpsubopt
overload .funent_tmpsub with funent_tmpsub
fun
set_funent_tmpsub(x: funent, v: tmpsubopt): void
fun
funent_tmpret(x: funent): tmpvar
overload .funent_tmpret with funent_tmpret
fun
funent_flablst(x: funent): funlablst
overload .funent_flablst with funent_flablst
fun
funent_flablst_fin(x: funent): funlablstopt
overload .funent_flablst_fin with funent_flablst_fin
fun
set_funent_flablst_fin(x: funent, v: funlablstopt): void
fun
funent_d2envlst(x: funent): d2envlst
overload .funent_d2envlst with funent_d2envlst
fun
funent_d2envlst_fin(x: funent): d2envlstopt
overload .funent_d2envlst_fin with funent_d2envlst_fin
fun
set_funent_d2envlst_fin(x: funent, v: d2envlstopt): void
fun
funent_vbindmap(x: funent): vbindmap
overload .funent_vbindmap with funent_vbindmap
fun
funent_instrlst(x: funent): instrlst
overload .funent_instrlst with funent_instrlst
fun
funent_tmpvarlst(x: funent): tmpvarlst
overload .funent_tmpvarlst with funent_tmpvarlst
fun
funent_fnxlablst(x: funent): funlablst
overload .funent_fnxlablst with funent_fnxlablst
fun
set_funent_fnxlablst(x: funent, v: funlablst): void
//
fun
tmpsub_encode(v: tmpsub_view): tmpsub
fun
tmpsub_view(x: tmpsub): tmpsub_view
fun
tmpsub_view_free(v: tmpsub_view): void
fun
tmpsub_tag(x: tmpsub): int
fun
tmpsub_TMPSUBcons(a0: s2var, a1: s2exp, a2: tmpsub): tmpsub
fun
tmpsub_TMPSUBnil(): tmpsub
fun
tmpsub_is_TMPSUBcons(x: tmpsub): bool
fun
tmpsub_is_TMPSUBnil(x: tmpsub): bool
//
fun
tmpcstmat_encode(v: tmpcstmat_view): tmpcstmat
fun
tmpcstmat_view(x: tmpcstmat): tmpcstmat_view
fun
tmpcstmat_view_free(v: tmpcstmat_view): void
fun
tmpcstmat_tag(x: tmpcstmat): int
fun
tmpcstmat_TMPCSTMATnone(): tmpcstmat
fun
tmpcstmat_TMPCSTMATsome(a0: hiimpdec, a1: tmpsub, a2: int): tmpcstmat
fun
tmpcstmat_TMPCSTMATsome2(a0: d2cst, a1: s2explstlst, a2: funlab): tmpcstmat
fun
tmpcstmat_is_TMPCSTMATnone(x: tmpcstmat): bool
fun
tmpcstmat_is_TMPCSTMATsome(x: tmpcstmat): bool
fun
tmpcstmat_is_TMPCSTMATsome2(x: tmpcstmat): bool
//
fun
tmpvarmat_encode(v: tmpvarmat_view): tmpvarmat
fun
tmpvarmat_view(x: tmpvarmat): tmpvarmat_view
fun
tmpvarmat_view_free(v: tmpvarmat_view): void
fun
tmpvarmat_tag(x: tmpvarmat): int
fun
tmpvarmat_TMPVARMATnone(): tmpvarmat
fun
tmpvarmat_TMPVARMATsome(a0: hifundec, a1: tmpsub, a2: int): tmpvarmat
fun
tmpvarmat_TMPVARMATsome2(a0: d2var, a1: s2explstlst, a2: funlab): tmpvarmat
fun
tmpvarmat_is_TMPVARMATnone(x: tmpvarmat): bool
fun
tmpvarmat_is_TMPVARMATsome(x: tmpvarmat): bool
fun
tmpvarmat_is_TMPVARMATsome2(x: tmpvarmat): bool
//
fun
hifundec2_new(a0: hifundec, a1: tmpsub): hifundec2
fun
hifundec2_hfd(x: hifundec2): hifundec
overload .hifundec2_hfd with hifundec2_hfd
fun
hifundec2_sub(x: hifundec2): tmpsub
overload .hifundec2_sub with hifundec2_sub
//
fun
hiimpdec2_new(a0: hiimpdec, a1: tmpsub, a2: s2explstlst): hiimpdec2
fun
hiimpdec2_imp(x: hiimpdec2): hiimpdec
overload .hiimpdec2_imp with hiimpdec2_imp
fun
hiimpdec2_sub(x: hiimpdec2): tmpsub
overload .hiimpdec2_sub with hiimpdec2_sub
fun
hiimpdec2_arg(x: hiimpdec2): s2explstlst
overload .hiimpdec2_arg with hiimpdec2_arg
//
fun
primcstsp_encode(v: primcstsp_view): primcstsp
fun
primcstsp_view(x: primcstsp): primcstsp_view
fun
primcstsp_view_free(v: primcstsp_view): void
fun
primcstsp_tag(x: primcstsp): int
fun
primcstsp_PMCSTSPmyfil(a0: filename): primcstsp
fun
primcstsp_PMCSTSPmyloc(a0: location): primcstsp
fun
primcstsp_PMCSTSPmyfun(a0: funlab): primcstsp
fun
primcstsp_is_PMCSTSPmyfil(x: primcstsp): bool
fun
primcstsp_is_PMCSTSPmyloc(x: primcstsp): bool
fun
primcstsp_is_PMCSTSPmyfun(x: primcstsp): bool
//
fun
primdec_node_encode(v: primdec_node_view): primdec_node
fun
primdec_node_view(x: primdec_node): primdec_node_view
fun
primdec_node_view_free(v: primdec_node_view): void
fun
primdec_node_tag(x: primdec_node): int
fun
primdec_node_PMDnone(): primdec_node
fun
primdec_node_PMDlist(a0: primdeclst): primdec_node
fun
primdec_node_PMDsaspdec(a0: s2aspdec): primdec_node
fun
primdec_node_PMDextvar(a0: string, a1: instrlst): primdec_node
fun
primdec_node_PMDdatdecs(a0: s2cstlst): primdec_node
fun
primdec_node_PMDexndecs(a0: d2conlst): primdec_node
fun
primdec_node_PMDfundecs(a0: funkind, a1: s2qualst, a2: hifundeclst): primdec_node
fun
primdec_node_PMDvaldecs(a0: valkind, a1: hivaldeclst, a2: instrlst): primdec_node
fun
primdec_node_PMDvaldecs_rec(a0: valkind, a1: hivaldeclst, a2: instrlst): primdec_node
fun
primdec_node_PMDvardecs(a0: hivardeclst, a1: instrlst): primdec_node
fun
primdec_node_PMDimpdec(a0: hiimpdec): primdec_node
fun
primdec_node_PMDinclude(a0: int, a1: primdeclst): primdec_node
fun
primdec_node_PMDstaload(a0: hidecl): primdec_node
fun
primdec_node_PMDstaloadloc(a0: filename, a1: symbol, a2: primdeclst): primdec_node
fun
primdec_node_PMDdynload(a0: hidecl): primdec_node
fun
primdec_node_PMDlocal(a0: primdeclst, a1: primdeclst): primdec_node
fun
primdec_node_is_PMDnone(x: primdec_node): bool
fun
primdec_node_is_PMDlist(x: primdec_node): bool
fun
primdec_node_is_PMDsaspdec(x: primdec_node): bool
fun
primdec_node_is_PMDextvar(x: primdec_node): bool
fun
primdec_node_is_PMDdatdecs(x: primdec_node): bool
fun
primdec_node_is_PMDexndecs(x: primdec_node): bool
fun
primdec_node_is_PMDfundecs(x: primdec_node): bool
fun
primdec_node_is_PMDvaldecs(x: primdec_node): bool
fun
primdec_node_is_PMDvaldecs_rec(x: primdec_node): bool
fun
primdec_node_is_PMDvardecs(x: primdec_node): bool
fun
primdec_node_is_PMDimpdec(x: primdec_node): bool
fun
primdec_node_is_PMDinclude(x: primdec_node): bool
fun
primdec_node_is_PMDstaload(x: primdec_node): bool
fun
primdec_node_is_PMDstaloadloc(x: primdec_node): bool
fun
primdec_node_is_PMDdynload(x: primdec_node): bool
fun
primdec_node_is_PMDlocal(x: primdec_node): bool
//
fun
primval_node_encode(v: primval_node_view): primval_node
fun
primval_node_view(x: primval_node): primval_node_view
fun
primval_node_view_free(v: primval_node_view): void
fun
primval_node_tag(x: primval_node): int
fun
primval_node_PMVtmp(a0: tmpvar): primval_node
fun
primval_node_PMVtmpref(a0: tmpvar): primval_node
fun
primval_node_PMVarg(a0: int): primval_node
fun
primval_node_PMVargref(a0: int): primval_node
fun
primval_node_PMVargenv(a0: int): primval_node
fun
primval_node_PMVargtmpref(a0: int): primval_node
fun
primval_node_PMVcst(a0: d2cst): primval_node
fun
primval_node_PMVenv(a0: d2var): primval_node
fun
primval_node_PMVint(a0: int): primval_node
fun
primval_node_PMVintrep(a0: string): primval_node
fun
primval_node_PMVbool(a0: bool): primval_node
fun
primval_node_PMVchar(a0: char): primval_node
fun
primval_node_PMVfloat(a0: double): primval_node
fun
primval_node_PMVstring(a0: string): primval_node
fun
primval_node_PMVi0nt(a0: i0nt): primval_node
fun
primval_node_PMVf0loat(a0: f0loat): primval_node
fun
primval_node_PMVcstsp(a0: primcstsp): primval_node
fun
primval_node_PMVtyrep(a0: hisexp): primval_node
fun
primval_node_PMVsizeof(a0: hisexp): primval_node
fun
primval_node_PMVtop(): primval_node
fun
primval_node_PMVempty(): primval_node
fun
primval_node_PMVextval(a0: string): primval_node
fun
primval_node_PMVcastfn(a0: d2cst, a1: primval): primval_node
fun
primval_node_PMVselcon(a0: primval, a1: hisexp, a2: label): primval_node
fun
primval_node_PMVselect(a0: primval, a1: hisexp, a2: primlab): primval_node
fun
primval_node_PMVselect2(a0: primval, a1: hisexp, a2: primlablst): primval_node
fun
primval_node_PMVselptr(a0: primval, a1: hisexp, a2: primlablst): primval_node
fun
primval_node_PMVptrof(a0: primval): primval_node
fun
primval_node_PMVptrofsel(a0: primval, a1: hisexp, a2: primlablst): primval_node
fun
primval_node_PMVvararg(a0: primvalist): primval_node
fun
primval_node_PMVrefarg(a0: int, a1: int, a2: primval): primval_node
fun
primval_node_PMVfunlab(a0: funlab): primval_node
fun
primval_node_PMVcfunlab(a0: int, a1: funlab): primval_node
fun
primval_node_PMVd2vfunlab(a0: d2var, a1: funlab): primval_node
fun
primval_node_PMVlamfix(a0: d2varopt, a1: primval): primval_node
fun
primval_node_PMVtmpltcst(a0: d2cst, a1: t2mpmarglst): primval_node
fun
primval_node_PMVtmpltvar(a0: d2var, a1: t2mpmarglst): primval_node
fun
primval_node_PMVtmpltcstmat(a0: d2cst, a1: t2mpmarglst, a2: tmpcstmat): primval_node
fun
primval_node_PMVtmpltvarmat(a0: d2var, a1: t2mpmarglst, a2: tmpvarmat): primval_node
fun
primval_node_PMVerror(): primval_node
fun
primval_node_is_PMVtmp(x: primval_node): bool
fun
primval_node_is_PMVtmpref(x: primval_node): bool
fun
primval_node_is_PMVarg(x: primval_node): bool
fun
primval_node_is_PMVargref(x: primval_node): bool
fun
primval_node_is_PMVargenv(x: primval_node): bool
fun
primval_node_is_PMVargtmpref(x: primval_node): bool
fun
primval_node_is_PMVcst(x: primval_node): bool
fun
primval_node_is_PMVenv(x: primval_node): bool
fun
primval_node_is_PMVint(x: primval_node): bool
fun
primval_node_is_PMVintrep(x: primval_node): bool
fun
primval_node_is_PMVbool(x: primval_node): bool
fun
primval_node_is_PMVchar(x: primval_node): bool
fun
primval_node_is_PMVfloat(x: primval_node): bool
fun
primval_node_is_PMVstring(x: primval_node): bool
fun
primval_node_is_PMVi0nt(x: primval_node): bool
fun
primval_node_is_PMVf0loat(x: primval_node): bool
fun
primval_node_is_PMVcstsp(x: primval_node): bool
fun
primval_node_is_PMVtyrep(x: primval_node): bool
fun
primval_node_is_PMVsizeof(x: primval_node): bool
fun
primval_node_is_PMVtop(x: primval_node): bool
fun
primval_node_is_PMVempty(x: primval_node): bool
fun
primval_node_is_PMVextval(x: primval_node): bool
fun
primval_node_is_PMVcastfn(x: primval_node): bool
fun
primval_node_is_PMVselcon(x: primval_node): bool
fun
primval_node_is_PMVselect(x: primval_node): bool
fun
primval_node_is_PMVselect2(x: primval_node): bool
fun
primval_node_is_PMVselptr(x: primval_node): bool
fun
primval_node_is_PMVptrof(x: primval_node): bool
fun
primval_node_is_PMVptrofsel(x: primval_node): bool
fun
primval_node_is_PMVvararg(x: primval_node): bool
fun
primval_node_is_PMVrefarg(x: primval_node): bool
fun
primval_node_is_PMVfunlab(x: primval_node): bool
fun
primval_node_is_PMVcfunlab(x: primval_node): bool
fun
primval_node_is_PMVd2vfunlab(x: primval_node): bool
fun
primval_node_is_PMVlamfix(x: primval_node): bool
fun
primval_node_is_PMVtmpltcst(x: primval_node): bool
fun
primval_node_is_PMVtmpltvar(x: primval_node): bool
fun
primval_node_is_PMVtmpltcstmat(x: primval_node): bool
fun
primval_node_is_PMVtmpltvarmat(x: primval_node): bool
fun
primval_node_is_PMVerror(x: primval_node): bool
//
fun
primlab_node_encode(v: primlab_node_view): primlab_node
fun
primlab_node_view(x: primlab_node): primlab_node_view
fun
primlab_node_view_free(v: primlab_node_view): void
fun
primlab_node_tag(x: primlab_node): int
fun
primlab_node_PMLlab(a0: label): primlab_node
fun
primlab_node_PMLind(a0: primvalist): primlab_node
fun
primlab_node_is_PMLlab(x: primlab_node): bool
fun
primlab_node_is_PMLind(x: primlab_node): bool
//
fun
labprimval_new(a0: label, a1: primval): labprimval
fun
labprimval_lab(x: labprimval): label
overload .labprimval_lab with labprimval_lab
fun
labprimval_elt(x: labprimval): primval
overload .labprimval_elt with labprimval_elt
//
fun
primdec_new(a0: location, a1: primdec_node): primdec
fun
primdec_loc(x: primdec): location
overload .primdec_loc with primdec_loc
fun
primdec_node(x: primdec): primdec_node
overload .primdec_node with primdec_node
//
fun
primval_new(a0: location, a1: hisexp, a2: primval_node): primval
fun
primval_loc(x: primval): location
overload .primval_loc with primval_loc
fun
primval_type(x: primval): hisexp
overload .primval_type with primval_type
fun
primval_node(x: primval): primval_node
overload .primval_node with primval_node
//
fun
primlab_new(a0: location, a1: primlab_node): primlab
fun
primlab_loc(x: primlab): location
overload .primlab_loc with primlab_loc
fun
primlab_node(x: primlab): primlab_node
overload .primlab_node with primlab_node
//
fun
patck_encode(v: patck_view): patck
fun
patck_view(x: patck): patck_view
fun
patck_view_free(v: patck_view): void
fun
patck_tag(x: patck): int
fun
patck_PATCKcon(a0: d2con): patck
fun
patck_PATCKint(a0: int): patck
fun
patck_PATCKbool(a0: bool): patck
fun
patck_PATCKchar(a0: char): patck
fun
patck_PATCKfloat(a0: double): patck
fun
patck_PATCKstring(a0: string): patck
fun
patck_PATCKi0nt(a0: i0nt): patck
fun
patck_PATCKf0loat(a0: f0loat): patck
fun
patck_is_PATCKcon(x: patck): bool
fun
patck_is_PATCKint(x: patck): bool
fun
patck_is_PATCKbool(x: patck): bool
fun
patck_is_PATCKchar(x: patck): bool
fun
patck_is_PATCKfloat(x: patck): bool
fun
patck_is_PATCKstring(x: patck): bool
fun
patck_is_PATCKi0nt(x: patck): bool
fun
patck_is_PATCKf0loat(x: patck): bool
//
fun
tmprimval_encode(v: tmprimval_view): tmprimval
fun
tmprimval_view(x: tmprimval): tmprimval_view
fun
tmprimval_view_free(v: tmprimval_view): void
fun
tmprimval_tag(x: tmprimval): int
fun
tmprimval_TPMVnone(a0: primval): tmprimval
fun
tmprimval_TPMVsome(a0: tmpvar, a1: primval): tmprimval
fun
tmprimval_is_TPMVnone(x: tmprimval): bool
fun
tmprimval_is_TPMVsome(x: tmprimval): bool
//
fun
tmpmov_new(a0: tmprimval, a1: tmpvar): tmpmov
fun
tmpmov_src(x: tmpmov): tmprimval
overload .tmpmov_src with tmpmov_src
fun
tmpmov_dst(x: tmpmov): tmpvar
overload .tmpmov_dst with tmpmov_dst
//
fun
patckont_encode(v: patckont_view): patckont
fun
patckont_view(x: patckont): patckont_view
fun
patckont_view_free(v: patckont_view): void
fun
patckont_tag(x: patckont): int
fun
patckont_PTCKNTnone(): patckont
fun
patckont_PTCKNTtmplab(a0: tmplab): patckont
fun
patckont_PTCKNTtmplabint(a0: tmplab, a1: int): patckont
fun
patckont_PTCKNTtmplabmov(a0: tmplab, a1: tmpmovlst): patckont
fun
patckont_PTCKNTcaseof_fail(a0: location): patckont
fun
patckont_PTCKNTfunarg_fail(a0: location, a1: funlab): patckont
fun
patckont_PTCKNTraise(a0: tmpvar, a1: primval): patckont
fun
patckont_is_PTCKNTnone(x: patckont): bool
fun
patckont_is_PTCKNTtmplab(x: patckont): bool
fun
patckont_is_PTCKNTtmplabint(x: patckont): bool
fun
patckont_is_PTCKNTtmplabmov(x: patckont): bool
fun
patckont_is_PTCKNTcaseof_fail(x: patckont): bool
fun
patckont_is_PTCKNTfunarg_fail(x: patckont): bool
fun
patckont_is_PTCKNTraise(x: patckont): bool
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
instr_node_INSfunlab(a0: funlab): instr_node
fun
instr_node_INStmplab(a0: tmplab): instr_node
fun
instr_node_INScomment(a0: string): instr_node
fun
instr_node_INSmove_val(a0: tmpvar, a1: primval): instr_node
fun
instr_node_INSpmove_val(a0: tmpvar, a1: primval): instr_node
fun
instr_node_INSmove_arg_val(a0: int, a1: primval): instr_node
fun
instr_node_INSfcall(a0: tmpvar, a1: primval, a2: hisexp, a3: primvalist): instr_node
fun
instr_node_INSfcall2(a0: tmpvar, a1: funlab, a2: int, a3: hisexp, a4: primvalist): instr_node
fun
instr_node_INSextfcall(a0: tmpvar, a1: string, a2: primvalist): instr_node
fun
instr_node_INSextmcall(a0: tmpvar, a1: primval, a2: string, a3: primvalist): instr_node
fun
instr_node_INScond(a0: primval, a1: instrlst, a2: instrlst): instr_node
fun
instr_node_INSfreecon(a0: primval): instr_node
fun
instr_node_INSloop(a0: tmplab, a1: tmplab, a2: tmplab, a3: instrlst, a4: primval, a5: instrlst, a6: instrlst, a7: instrlst): instr_node
fun
instr_node_INSloopexn(a0: int, a1: tmplab): instr_node
fun
instr_node_INScaseof(a0: ibranchlst): instr_node
fun
instr_node_INSletpop(): instr_node
fun
instr_node_INSletpush(a0: primdeclst): instr_node
fun
instr_node_INSmove_con(a0: tmpvar, a1: d2con, a2: hisexp, a3: labprimvalist): instr_node
fun
instr_node_INSmove_ref(a0: tmpvar, a1: primval): instr_node
fun
instr_node_INSmove_boxrec(a0: tmpvar, a1: labprimvalist, a2: hisexp): instr_node
fun
instr_node_INSmove_fltrec(a0: tmpvar, a1: labprimvalist, a2: hisexp): instr_node
fun
instr_node_INSpatck(a0: primval, a1: patck, a2: patckont): instr_node
fun
instr_node_INSmove_ptrofsel(a0: tmpvar, a1: primval, a2: hisexp, a3: primlablst): instr_node
fun
instr_node_INSstore_ptrofs(a0: primval, a1: hisexp, a2: primlablst, a3: primval): instr_node
fun
instr_node_INSxstore_ptrofs(a0: tmpvar, a1: primval, a2: hisexp, a3: primlablst, a4: primval): instr_node
fun
instr_node_INSraise(a0: tmpvar, a1: primval): instr_node
fun
instr_node_INSmove_delay(a0: tmpvar, a1: int, a2: hisexp, a3: primval): instr_node
fun
instr_node_INSmove_lazyeval(a0: tmpvar, a1: int, a2: hisexp, a3: primval): instr_node
fun
instr_node_INStrywith(a0: tmpvar, a1: instrlst, a2: ibranchlst): instr_node
fun
instr_node_INSmove_list_nil(a0: tmpvar): instr_node
fun
instr_node_INSpmove_list_nil(a0: tmpvar): instr_node
fun
instr_node_INSpmove_list_cons(a0: tmpvar, a1: hisexp): instr_node
fun
instr_node_INSmove_list_phead(a0: tmpvar, a1: tmpvar, a2: hisexp): instr_node
fun
instr_node_INSmove_list_ptail(a0: tmpvar, a1: tmpvar, a2: hisexp): instr_node
fun
instr_node_INSmove_arrpsz_ptr(a0: tmpvar, a1: tmpvar): instr_node
fun
instr_node_INSstore_arrpsz_asz(a0: tmpvar, a1: int): instr_node
fun
instr_node_INSstore_arrpsz_ptr(a0: tmpvar, a1: hisexp, a2: int): instr_node
fun
instr_node_INSupdate_ptrinc(a0: tmpvar, a1: hisexp): instr_node
fun
instr_node_INSupdate_ptrdec(a0: tmpvar, a1: hisexp): instr_node
fun
instr_node_INSclosure_initize(a0: tmpvar, a1: d2varopt, a2: funlab): instr_node
fun
instr_node_INStmpdec(a0: tmpvar): instr_node
fun
instr_node_INSextvar(a0: string, a1: primval): instr_node
fun
instr_node_INSdcstdef(a0: d2cst, a1: primval): instr_node
fun
instr_node_INStempenver(a0: d2varlst): instr_node
fun
instr_node_is_INSfunlab(x: instr_node): bool
fun
instr_node_is_INStmplab(x: instr_node): bool
fun
instr_node_is_INScomment(x: instr_node): bool
fun
instr_node_is_INSmove_val(x: instr_node): bool
fun
instr_node_is_INSpmove_val(x: instr_node): bool
fun
instr_node_is_INSmove_arg_val(x: instr_node): bool
fun
instr_node_is_INSfcall(x: instr_node): bool
fun
instr_node_is_INSfcall2(x: instr_node): bool
fun
instr_node_is_INSextfcall(x: instr_node): bool
fun
instr_node_is_INSextmcall(x: instr_node): bool
fun
instr_node_is_INScond(x: instr_node): bool
fun
instr_node_is_INSfreecon(x: instr_node): bool
fun
instr_node_is_INSloop(x: instr_node): bool
fun
instr_node_is_INSloopexn(x: instr_node): bool
fun
instr_node_is_INScaseof(x: instr_node): bool
fun
instr_node_is_INSletpop(x: instr_node): bool
fun
instr_node_is_INSletpush(x: instr_node): bool
fun
instr_node_is_INSmove_con(x: instr_node): bool
fun
instr_node_is_INSmove_ref(x: instr_node): bool
fun
instr_node_is_INSmove_boxrec(x: instr_node): bool
fun
instr_node_is_INSmove_fltrec(x: instr_node): bool
fun
instr_node_is_INSpatck(x: instr_node): bool
fun
instr_node_is_INSmove_ptrofsel(x: instr_node): bool
fun
instr_node_is_INSstore_ptrofs(x: instr_node): bool
fun
instr_node_is_INSxstore_ptrofs(x: instr_node): bool
fun
instr_node_is_INSraise(x: instr_node): bool
fun
instr_node_is_INSmove_delay(x: instr_node): bool
fun
instr_node_is_INSmove_lazyeval(x: instr_node): bool
fun
instr_node_is_INStrywith(x: instr_node): bool
fun
instr_node_is_INSmove_list_nil(x: instr_node): bool
fun
instr_node_is_INSpmove_list_nil(x: instr_node): bool
fun
instr_node_is_INSpmove_list_cons(x: instr_node): bool
fun
instr_node_is_INSmove_list_phead(x: instr_node): bool
fun
instr_node_is_INSmove_list_ptail(x: instr_node): bool
fun
instr_node_is_INSmove_arrpsz_ptr(x: instr_node): bool
fun
instr_node_is_INSstore_arrpsz_asz(x: instr_node): bool
fun
instr_node_is_INSstore_arrpsz_ptr(x: instr_node): bool
fun
instr_node_is_INSupdate_ptrinc(x: instr_node): bool
fun
instr_node_is_INSupdate_ptrdec(x: instr_node): bool
fun
instr_node_is_INSclosure_initize(x: instr_node): bool
fun
instr_node_is_INStmpdec(x: instr_node): bool
fun
instr_node_is_INSextvar(x: instr_node): bool
fun
instr_node_is_INSdcstdef(x: instr_node): bool
fun
instr_node_is_INStempenver(x: instr_node): bool
//
fun
instr_new(a0: location, a1: instr_node): instr
fun
instr_loc(x: instr): location
overload .instr_loc with instr_loc
fun
instr_node(x: instr): instr_node
overload .instr_node with instr_node
//
fun
ibranch_new(a0: location, a1: instrlst): ibranch
fun
ibranch_loc(x: ibranch): location
overload .ibranch_loc with ibranch_loc
fun
ibranch_inslst(x: ibranch): instrlst
overload .ibranch_inslst with ibranch_inslst
//
