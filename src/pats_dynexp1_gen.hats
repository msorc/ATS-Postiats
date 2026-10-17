abstype
p1at_node_type = ptr
typedef
p1at_node = p1at_node_type

abstype
labp1at_node_type = ptr
typedef
labp1at_node = labp1at_node_type

abstype
p1at_type = ptr
typedef
p1at = p1at_type

abstype
labp1at_type = ptr
typedef
labp1at = labp1at_type

abstype
i1nvarg_type = ptr
typedef
i1nvarg = i1nvarg_type

abstype
i1nvresstate_type = ptr
typedef
i1nvresstate = i1nvresstate_type

abstype
loopi1nv_type = ptr
typedef
loopi1nv = loopi1nv_type

abstype
d1ecl_node_type = ptr
typedef
d1ecl_node = d1ecl_node_type

abstype
d1exp_node_type = ptr
typedef
d1exp_node = d1exp_node_type

abstype
d1lab_node_type = ptr
typedef
d1lab_node = d1lab_node_type

abstype
d1ecl_type = ptr
typedef
d1ecl = d1ecl_type

abstype
d1exp_type = ptr
typedef
d1exp = d1exp_type

abstype
labd1exp_type = ptr
typedef
labd1exp = labd1exp_type

abstype
d1lab_type = ptr
typedef
d1lab = d1lab_type

abstype
i1fcl_type = ptr
typedef
i1fcl = i1fcl_type

abstype
gm1at_type = ptr
typedef
gm1at = gm1at_type

abstype
c1lau_type = ptr
typedef
c1lau = c1lau_type

abstype
sc1lau_type = ptr
typedef
sc1lau = sc1lau_type

abstype
m1acdef_type = ptr
typedef
m1acdef = m1acdef_type

abstype
f1undec_type = ptr
typedef
f1undec = f1undec_type

abstype
v1aldec_type = ptr
typedef
v1aldec = v1aldec_type

abstype
v1ardec_type = ptr
typedef
v1ardec = v1ardec_type

abstype
i1mpdec_type = ptr
typedef
i1mpdec = i1mpdec_type

typedef p1atlst = glist(p1at)
typedef p1atopt = gopt(p1at)
typedef labp1atlst = glist(labp1at)
typedef i1nvarglst = glist(i1nvarg)
typedef intlst = glist(int)
typedef d1eclist = glist(d1ecl)
typedef d1explst = glist(d1exp)
typedef d1expopt = gopt(d1exp)
typedef labd1explst = glist(labd1exp)
typedef d1lablst = glist(d1lab)
typedef i1fclist = glist(i1fcl)
typedef gm1atlst = glist(gm1at)
typedef c1laulst = glist(c1lau)
typedef sc1laulst = glist(sc1lau)
typedef m1acdeflst = glist(m1acdef)
typedef f1undeclst = glist(f1undec)
typedef v1aldeclst = glist(v1aldec)
typedef v1ardeclst = glist(v1ardec)
//
datavtype
p1at_node_view =
  | P1Tany of ()
  | P1Tany2 of ()
  | P1Tide of (symbol)
  | P1Tdqid of (d0ynq, symbol)
  | P1Tint of (int)
  | P1Tintrep of (string)
  | P1Tchar of (char)
  | P1Tfloat of (string)
  | P1Tstring of (string)
  | P1Ti0nt of (i0nt)
  | P1Tf0loat of (f0loat)
  | P1Tempty of ()
  | P1Tapp_sta of (p1at, s1vararglst)
  | P1Tapp_dyn of (p1at, loc_t, int, p1atlst)
  | P1Tlist of (int, p1atlst)
  | P1Ttup of (int, int, p1atlst)
  | P1Trec of (int, int, labp1atlst)
  | P1Tlst of (int, p1atlst)
  | P1Tfree of (p1at)
  | P1Tunfold of (p1at)
  | P1Trefas of (symbol, loc_t, p1at)
  | P1Texist of (s1arglst, p1at)
  | P1Tsvararg of (s1vararg)
  | P1Tann of (p1at, s1exp)
  | P1Terrpat of ()
and
labp1at_node_view =
  | LABP1ATomit of ()
  | LABP1ATnorm of (l0ab, p1at)
and
d1ecl_node_view =
  | D1Cnone of ()
  | D1Clist of (d1eclist)
  | D1Cpackname of (Stropt)
  | D1Csymintr of (i0delst)
  | D1Csymelim of (i0delst)
  | D1Coverload of (i0de, dqi0de, int)
  | D1Ce1xpdef of (symbol, e1xp)
  | D1Ce1xpundef of (symbol, e1xp)
  | D1Cpragma of (e1xplst)
  | D1Ccodegen of (int, e1xplst)
  | D1Cdatsrts of (d1atsrtdeclst)
  | D1Csrtdefs of (s1rtdeflst)
  | D1Cstacsts of (s1tacstlst)
  | D1Cstacons of (int, s1taconlst)
  | D1Ctkindef of (t1kindef)
  | D1Csexpdefs of (int, s1expdeflst)
  | D1Csaspdec of (s1aspdec)
  | D1Creassume of (sqi0de)
  | D1Cexndecs of (e1xndeclst)
  | D1Cdatdecs of (int, d1atdeclst, s1expdeflst)
  | D1Cclassdec of (i0de, s1expopt)
  | D1Cextype of (string, s1exp)
  | D1Cextype2 of (int, string, s1exp)
  | D1Cextvar of (string, d1exp)
  | D1Cextcode of (int, int, string)
  | D1Cdcstdecs of (int, dcstkind, q1marglst, d1cstdeclst)
  | D1Cmacdefs of (int, bool, m1acdeflst)
  | D1Cimpdec of (int, i1mparg, i1mpdec)
  | D1Cfundecs of (funkind, q1marglst, f1undeclst)
  | D1Cvaldecs of (valkind, bool, v1aldeclst)
  | D1Cvardecs of (int, v1ardeclst)
  | D1Cinclude of (int, d1eclist)
  | D1Cstaload of (symbolopt, filename, int, d1eclist)
  | D1Cstaloadnm of (symbolopt, symbol)
  | D1Cstaloadloc of (filename, symbol, d1eclist)
  | D1Cdynload of (filename)
  | D1Clocal of (d1eclist, d1eclist)
and
d1exp_node_view =
  | D1Eide of (symbol)
  | D1Edqid of (d0ynq, symbol)
  | D1Eidextapp of (symbol, d1explst)
  | D1Eint of (int)
  | D1Eintrep of (string)
  | D1Ebool of (bool)
  | D1Echar of (char)
  | D1Efloat of (string)
  | D1Estring of (string)
  | D1Ei0nt of (i0nt)
  | D1Ec0har of (c0har)
  | D1Ef0loat of (f0loat)
  | D1Es0tring of (s0tring)
  | D1Etop of ()
  | D1Eempty of ()
  | D1Ecstsp of (cstsp)
  | D1Etyrep of (s1exp)
  | D1Eliteral of (d1exp)
  | D1Eextval of (s1exp, string)
  | D1Eextfcall of (s1exp, string, d1explst)
  | D1Eextmcall of (s1exp, d1exp, string, d1explst)
  | D1Efoldat of (s1exparglst, d1exp)
  | D1Efreeat of (s1exparglst, d1exp)
  | D1Etmpid of (dqi0de, t1mpmarglst)
  | D1Elet of (d1eclist, d1exp)
  | D1Ewhere of (d1exp, d1eclist)
  | D1Edecseq of (d1eclist)
  | D1Eapp_dyn of (d1exp, loc_t, int, d1explst)
  | D1Eapp_sta of (d1exp, s1exparglst)
  | D1Esing of (d1exp)
  | D1Elist of (int, d1explst)
  | D1Eifhead of (i1nvresstate, d1exp, d1exp, d1expopt)
  | D1Esifhead of (i1nvresstate, s1exp, d1exp, d1exp)
  | D1Eifcasehd of (i1nvresstate, i1fclist)
  | D1Ecasehead of (caskind, i1nvresstate, d1explst, c1laulst)
  | D1Escasehead of (i1nvresstate, s1exp, sc1laulst)
  | D1Elst of (int, s1expopt, d1explst)
  | D1Etup of (int, int, d1explst)
  | D1Erec of (int, int, labd1explst)
  | D1Eseq of (d1explst)
  | D1Earrsub of (d1exp, loc_t, d1explst)
  | D1Earrinit of (s1exp, d1expopt, d1explst)
  | D1Earrpsz of (s1expopt, d1explst)
  | D1Eptrof of (d1exp)
  | D1Eviewat of (d1exp)
  | D1Eselab of (int, d1exp, d1lab)
  | D1Eraise of (d1exp)
  | D1Eeffmask of (effcst, d1exp)
  | D1Evararg of (d1explst)
  | D1Evcopyenv of (int, d1exp)
  | D1Eshowtype of (d1exp)
  | D1Etempenver of (d1exp)
  | D1Esexparg of (s1exparg)
  | D1Eexist of (s1exparg, d1exp)
  | D1Elam_dyn of (int, p1at, d1exp)
  | D1Elaminit_dyn of (int, p1at, d1exp)
  | D1Elam_met of (loc_t, s1explst, d1exp)
  | D1Elam_sta_ana of (loc_t, s1vararg, d1exp)
  | D1Elam_sta_syn of (loc_t, s1qualst, d1exp)
  | D1Efix of (int, i0de, d1exp)
  | D1Edelay of (int, d1exp)
  | D1Efor of (loopi1nv, d1exp, d1exp, d1exp, d1exp)
  | D1Ewhile of (loopi1nv, d1exp, d1exp)
  | D1Eloopexn of (int)
  | D1Etrywith of (i1nvresstate, d1exp, c1laulst)
  | D1Eann_type of (d1exp, s1exp)
  | D1Eann_effc of (d1exp, effcst)
  | D1Eann_funclo of (d1exp, funclo)
  | D1Emacsyn of (macsynkind, d1exp)
  | D1Emacfun of (symbol, d1explst)
  | D1Esolassert of (d1exp)
  | D1Esolverify of (s1exp)
  | D1Eerrexp of ()
and
d1lab_node_view =
  | D1LABlab of (label)
  | D1LABind of (d1explst)
//
fun
p1at_node_encode(v: p1at_node_view): p1at_node
fun
p1at_node_view(x: p1at_node): p1at_node_view
fun
p1at_node_view_free(v: p1at_node_view): void
fun
p1at_node_tag(x: p1at_node): int
fun
p1at_node_P1Tany(): p1at_node
fun
p1at_node_P1Tany2(): p1at_node
fun
p1at_node_P1Tide(a0: symbol): p1at_node
fun
p1at_node_P1Tdqid(a0: d0ynq, a1: symbol): p1at_node
fun
p1at_node_P1Tint(a0: int): p1at_node
fun
p1at_node_P1Tintrep(a0: string): p1at_node
fun
p1at_node_P1Tchar(a0: char): p1at_node
fun
p1at_node_P1Tfloat(a0: string): p1at_node
fun
p1at_node_P1Tstring(a0: string): p1at_node
fun
p1at_node_P1Ti0nt(a0: i0nt): p1at_node
fun
p1at_node_P1Tf0loat(a0: f0loat): p1at_node
fun
p1at_node_P1Tempty(): p1at_node
fun
p1at_node_P1Tapp_sta(a0: p1at, a1: s1vararglst): p1at_node
fun
p1at_node_P1Tapp_dyn(a0: p1at, a1: loc_t, a2: int, a3: p1atlst): p1at_node
fun
p1at_node_P1Tlist(a0: int, a1: p1atlst): p1at_node
fun
p1at_node_P1Ttup(a0: int, a1: int, a2: p1atlst): p1at_node
fun
p1at_node_P1Trec(a0: int, a1: int, a2: labp1atlst): p1at_node
fun
p1at_node_P1Tlst(a0: int, a1: p1atlst): p1at_node
fun
p1at_node_P1Tfree(a0: p1at): p1at_node
fun
p1at_node_P1Tunfold(a0: p1at): p1at_node
fun
p1at_node_P1Trefas(a0: symbol, a1: loc_t, a2: p1at): p1at_node
fun
p1at_node_P1Texist(a0: s1arglst, a1: p1at): p1at_node
fun
p1at_node_P1Tsvararg(a0: s1vararg): p1at_node
fun
p1at_node_P1Tann(a0: p1at, a1: s1exp): p1at_node
fun
p1at_node_P1Terrpat(): p1at_node
fun
p1at_node_is_P1Tany(x: p1at_node): bool
fun
p1at_node_is_P1Tany2(x: p1at_node): bool
fun
p1at_node_is_P1Tide(x: p1at_node): bool
fun
p1at_node_is_P1Tdqid(x: p1at_node): bool
fun
p1at_node_is_P1Tint(x: p1at_node): bool
fun
p1at_node_is_P1Tintrep(x: p1at_node): bool
fun
p1at_node_is_P1Tchar(x: p1at_node): bool
fun
p1at_node_is_P1Tfloat(x: p1at_node): bool
fun
p1at_node_is_P1Tstring(x: p1at_node): bool
fun
p1at_node_is_P1Ti0nt(x: p1at_node): bool
fun
p1at_node_is_P1Tf0loat(x: p1at_node): bool
fun
p1at_node_is_P1Tempty(x: p1at_node): bool
fun
p1at_node_is_P1Tapp_sta(x: p1at_node): bool
fun
p1at_node_is_P1Tapp_dyn(x: p1at_node): bool
fun
p1at_node_is_P1Tlist(x: p1at_node): bool
fun
p1at_node_is_P1Ttup(x: p1at_node): bool
fun
p1at_node_is_P1Trec(x: p1at_node): bool
fun
p1at_node_is_P1Tlst(x: p1at_node): bool
fun
p1at_node_is_P1Tfree(x: p1at_node): bool
fun
p1at_node_is_P1Tunfold(x: p1at_node): bool
fun
p1at_node_is_P1Trefas(x: p1at_node): bool
fun
p1at_node_is_P1Texist(x: p1at_node): bool
fun
p1at_node_is_P1Tsvararg(x: p1at_node): bool
fun
p1at_node_is_P1Tann(x: p1at_node): bool
fun
p1at_node_is_P1Terrpat(x: p1at_node): bool
//
fun
labp1at_node_encode(v: labp1at_node_view): labp1at_node
fun
labp1at_node_view(x: labp1at_node): labp1at_node_view
fun
labp1at_node_view_free(v: labp1at_node_view): void
fun
labp1at_node_tag(x: labp1at_node): int
fun
labp1at_node_LABP1ATomit(): labp1at_node
fun
labp1at_node_LABP1ATnorm(a0: l0ab, a1: p1at): labp1at_node
fun
labp1at_node_is_LABP1ATomit(x: labp1at_node): bool
fun
labp1at_node_is_LABP1ATnorm(x: labp1at_node): bool
//
fun
p1at_new(a0: loc_t, a1: p1at_node): p1at
fun
p1at_loc(x: p1at): loc_t
overload .p1at_loc with p1at_loc
fun
p1at_node(x: p1at): p1at_node
overload .p1at_node with p1at_node
//
fun
labp1at_new(a0: loc_t, a1: labp1at_node): labp1at
fun
labp1at_loc(x: labp1at): loc_t
overload .labp1at_loc with labp1at_loc
fun
labp1at_node(x: labp1at): labp1at_node
overload .labp1at_node with labp1at_node
//
fun
i1nvarg_new(a0: loc_t, a1: symbol, a2: s1expopt): i1nvarg
fun
i1nvarg_loc(x: i1nvarg): loc_t
overload .i1nvarg_loc with i1nvarg_loc
fun
i1nvarg_sym(x: i1nvarg): symbol
overload .i1nvarg_sym with i1nvarg_sym
fun
i1nvarg_type(x: i1nvarg): s1expopt
overload .i1nvarg_type with i1nvarg_type
//
fun
i1nvresstate_new(a0: s1qualst, a1: i1nvarglst): i1nvresstate
fun
i1nvresstate_qua(x: i1nvresstate): s1qualst
overload .i1nvresstate_qua with i1nvresstate_qua
fun
i1nvresstate_arg(x: i1nvresstate): i1nvarglst
overload .i1nvresstate_arg with i1nvresstate_arg
//
fun
loopi1nv_new(a0: loc_t, a1: s1qualst, a2: s1explstopt, a3: i1nvarglst, a4: i1nvresstate): loopi1nv
fun
loopi1nv_loc(x: loopi1nv): loc_t
overload .loopi1nv_loc with loopi1nv_loc
fun
loopi1nv_qua(x: loopi1nv): s1qualst
overload .loopi1nv_qua with loopi1nv_qua
fun
loopi1nv_met(x: loopi1nv): s1explstopt
overload .loopi1nv_met with loopi1nv_met
fun
loopi1nv_arg(x: loopi1nv): i1nvarglst
overload .loopi1nv_arg with loopi1nv_arg
fun
loopi1nv_res(x: loopi1nv): i1nvresstate
overload .loopi1nv_res with loopi1nv_res
//
fun
d1ecl_node_encode(v: d1ecl_node_view): d1ecl_node
fun
d1ecl_node_view(x: d1ecl_node): d1ecl_node_view
fun
d1ecl_node_view_free(v: d1ecl_node_view): void
fun
d1ecl_node_tag(x: d1ecl_node): int
fun
d1ecl_node_D1Cnone(): d1ecl_node
fun
d1ecl_node_D1Clist(a0: d1eclist): d1ecl_node
fun
d1ecl_node_D1Cpackname(a0: Stropt): d1ecl_node
fun
d1ecl_node_D1Csymintr(a0: i0delst): d1ecl_node
fun
d1ecl_node_D1Csymelim(a0: i0delst): d1ecl_node
fun
d1ecl_node_D1Coverload(a0: i0de, a1: dqi0de, a2: int): d1ecl_node
fun
d1ecl_node_D1Ce1xpdef(a0: symbol, a1: e1xp): d1ecl_node
fun
d1ecl_node_D1Ce1xpundef(a0: symbol, a1: e1xp): d1ecl_node
fun
d1ecl_node_D1Cpragma(a0: e1xplst): d1ecl_node
fun
d1ecl_node_D1Ccodegen(a0: int, a1: e1xplst): d1ecl_node
fun
d1ecl_node_D1Cdatsrts(a0: d1atsrtdeclst): d1ecl_node
fun
d1ecl_node_D1Csrtdefs(a0: s1rtdeflst): d1ecl_node
fun
d1ecl_node_D1Cstacsts(a0: s1tacstlst): d1ecl_node
fun
d1ecl_node_D1Cstacons(a0: int, a1: s1taconlst): d1ecl_node
fun
d1ecl_node_D1Ctkindef(a0: t1kindef): d1ecl_node
fun
d1ecl_node_D1Csexpdefs(a0: int, a1: s1expdeflst): d1ecl_node
fun
d1ecl_node_D1Csaspdec(a0: s1aspdec): d1ecl_node
fun
d1ecl_node_D1Creassume(a0: sqi0de): d1ecl_node
fun
d1ecl_node_D1Cexndecs(a0: e1xndeclst): d1ecl_node
fun
d1ecl_node_D1Cdatdecs(a0: int, a1: d1atdeclst, a2: s1expdeflst): d1ecl_node
fun
d1ecl_node_D1Cclassdec(a0: i0de, a1: s1expopt): d1ecl_node
fun
d1ecl_node_D1Cextype(a0: string, a1: s1exp): d1ecl_node
fun
d1ecl_node_D1Cextype2(a0: int, a1: string, a2: s1exp): d1ecl_node
fun
d1ecl_node_D1Cextvar(a0: string, a1: d1exp): d1ecl_node
fun
d1ecl_node_D1Cextcode(a0: int, a1: int, a2: string): d1ecl_node
fun
d1ecl_node_D1Cdcstdecs(a0: int, a1: dcstkind, a2: q1marglst, a3: d1cstdeclst): d1ecl_node
fun
d1ecl_node_D1Cmacdefs(a0: int, a1: bool, a2: m1acdeflst): d1ecl_node
fun
d1ecl_node_D1Cimpdec(a0: int, a1: i1mparg, a2: i1mpdec): d1ecl_node
fun
d1ecl_node_D1Cfundecs(a0: funkind, a1: q1marglst, a2: f1undeclst): d1ecl_node
fun
d1ecl_node_D1Cvaldecs(a0: valkind, a1: bool, a2: v1aldeclst): d1ecl_node
fun
d1ecl_node_D1Cvardecs(a0: int, a1: v1ardeclst): d1ecl_node
fun
d1ecl_node_D1Cinclude(a0: int, a1: d1eclist): d1ecl_node
fun
d1ecl_node_D1Cstaload(a0: symbolopt, a1: filename, a2: int, a3: d1eclist): d1ecl_node
fun
d1ecl_node_D1Cstaloadnm(a0: symbolopt, a1: symbol): d1ecl_node
fun
d1ecl_node_D1Cstaloadloc(a0: filename, a1: symbol, a2: d1eclist): d1ecl_node
fun
d1ecl_node_D1Cdynload(a0: filename): d1ecl_node
fun
d1ecl_node_D1Clocal(a0: d1eclist, a1: d1eclist): d1ecl_node
fun
d1ecl_node_is_D1Cnone(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Clist(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Cpackname(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Csymintr(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Csymelim(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Coverload(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Ce1xpdef(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Ce1xpundef(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Cpragma(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Ccodegen(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Cdatsrts(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Csrtdefs(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Cstacsts(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Cstacons(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Ctkindef(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Csexpdefs(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Csaspdec(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Creassume(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Cexndecs(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Cdatdecs(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Cclassdec(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Cextype(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Cextype2(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Cextvar(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Cextcode(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Cdcstdecs(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Cmacdefs(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Cimpdec(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Cfundecs(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Cvaldecs(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Cvardecs(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Cinclude(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Cstaload(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Cstaloadnm(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Cstaloadloc(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Cdynload(x: d1ecl_node): bool
fun
d1ecl_node_is_D1Clocal(x: d1ecl_node): bool
//
fun
d1exp_node_encode(v: d1exp_node_view): d1exp_node
fun
d1exp_node_view(x: d1exp_node): d1exp_node_view
fun
d1exp_node_view_free(v: d1exp_node_view): void
fun
d1exp_node_tag(x: d1exp_node): int
fun
d1exp_node_D1Eide(a0: symbol): d1exp_node
fun
d1exp_node_D1Edqid(a0: d0ynq, a1: symbol): d1exp_node
fun
d1exp_node_D1Eidextapp(a0: symbol, a1: d1explst): d1exp_node
fun
d1exp_node_D1Eint(a0: int): d1exp_node
fun
d1exp_node_D1Eintrep(a0: string): d1exp_node
fun
d1exp_node_D1Ebool(a0: bool): d1exp_node
fun
d1exp_node_D1Echar(a0: char): d1exp_node
fun
d1exp_node_D1Efloat(a0: string): d1exp_node
fun
d1exp_node_D1Estring(a0: string): d1exp_node
fun
d1exp_node_D1Ei0nt(a0: i0nt): d1exp_node
fun
d1exp_node_D1Ec0har(a0: c0har): d1exp_node
fun
d1exp_node_D1Ef0loat(a0: f0loat): d1exp_node
fun
d1exp_node_D1Es0tring(a0: s0tring): d1exp_node
fun
d1exp_node_D1Etop(): d1exp_node
fun
d1exp_node_D1Eempty(): d1exp_node
fun
d1exp_node_D1Ecstsp(a0: cstsp): d1exp_node
fun
d1exp_node_D1Etyrep(a0: s1exp): d1exp_node
fun
d1exp_node_D1Eliteral(a0: d1exp): d1exp_node
fun
d1exp_node_D1Eextval(a0: s1exp, a1: string): d1exp_node
fun
d1exp_node_D1Eextfcall(a0: s1exp, a1: string, a2: d1explst): d1exp_node
fun
d1exp_node_D1Eextmcall(a0: s1exp, a1: d1exp, a2: string, a3: d1explst): d1exp_node
fun
d1exp_node_D1Efoldat(a0: s1exparglst, a1: d1exp): d1exp_node
fun
d1exp_node_D1Efreeat(a0: s1exparglst, a1: d1exp): d1exp_node
fun
d1exp_node_D1Etmpid(a0: dqi0de, a1: t1mpmarglst): d1exp_node
fun
d1exp_node_D1Elet(a0: d1eclist, a1: d1exp): d1exp_node
fun
d1exp_node_D1Ewhere(a0: d1exp, a1: d1eclist): d1exp_node
fun
d1exp_node_D1Edecseq(a0: d1eclist): d1exp_node
fun
d1exp_node_D1Eapp_dyn(a0: d1exp, a1: loc_t, a2: int, a3: d1explst): d1exp_node
fun
d1exp_node_D1Eapp_sta(a0: d1exp, a1: s1exparglst): d1exp_node
fun
d1exp_node_D1Esing(a0: d1exp): d1exp_node
fun
d1exp_node_D1Elist(a0: int, a1: d1explst): d1exp_node
fun
d1exp_node_D1Eifhead(a0: i1nvresstate, a1: d1exp, a2: d1exp, a3: d1expopt): d1exp_node
fun
d1exp_node_D1Esifhead(a0: i1nvresstate, a1: s1exp, a2: d1exp, a3: d1exp): d1exp_node
fun
d1exp_node_D1Eifcasehd(a0: i1nvresstate, a1: i1fclist): d1exp_node
fun
d1exp_node_D1Ecasehead(a0: caskind, a1: i1nvresstate, a2: d1explst, a3: c1laulst): d1exp_node
fun
d1exp_node_D1Escasehead(a0: i1nvresstate, a1: s1exp, a2: sc1laulst): d1exp_node
fun
d1exp_node_D1Elst(a0: int, a1: s1expopt, a2: d1explst): d1exp_node
fun
d1exp_node_D1Etup(a0: int, a1: int, a2: d1explst): d1exp_node
fun
d1exp_node_D1Erec(a0: int, a1: int, a2: labd1explst): d1exp_node
fun
d1exp_node_D1Eseq(a0: d1explst): d1exp_node
fun
d1exp_node_D1Earrsub(a0: d1exp, a1: loc_t, a2: d1explst): d1exp_node
fun
d1exp_node_D1Earrinit(a0: s1exp, a1: d1expopt, a2: d1explst): d1exp_node
fun
d1exp_node_D1Earrpsz(a0: s1expopt, a1: d1explst): d1exp_node
fun
d1exp_node_D1Eptrof(a0: d1exp): d1exp_node
fun
d1exp_node_D1Eviewat(a0: d1exp): d1exp_node
fun
d1exp_node_D1Eselab(a0: int, a1: d1exp, a2: d1lab): d1exp_node
fun
d1exp_node_D1Eraise(a0: d1exp): d1exp_node
fun
d1exp_node_D1Eeffmask(a0: effcst, a1: d1exp): d1exp_node
fun
d1exp_node_D1Evararg(a0: d1explst): d1exp_node
fun
d1exp_node_D1Evcopyenv(a0: int, a1: d1exp): d1exp_node
fun
d1exp_node_D1Eshowtype(a0: d1exp): d1exp_node
fun
d1exp_node_D1Etempenver(a0: d1exp): d1exp_node
fun
d1exp_node_D1Esexparg(a0: s1exparg): d1exp_node
fun
d1exp_node_D1Eexist(a0: s1exparg, a1: d1exp): d1exp_node
fun
d1exp_node_D1Elam_dyn(a0: int, a1: p1at, a2: d1exp): d1exp_node
fun
d1exp_node_D1Elaminit_dyn(a0: int, a1: p1at, a2: d1exp): d1exp_node
fun
d1exp_node_D1Elam_met(a0: loc_t, a1: s1explst, a2: d1exp): d1exp_node
fun
d1exp_node_D1Elam_sta_ana(a0: loc_t, a1: s1vararg, a2: d1exp): d1exp_node
fun
d1exp_node_D1Elam_sta_syn(a0: loc_t, a1: s1qualst, a2: d1exp): d1exp_node
fun
d1exp_node_D1Efix(a0: int, a1: i0de, a2: d1exp): d1exp_node
fun
d1exp_node_D1Edelay(a0: int, a1: d1exp): d1exp_node
fun
d1exp_node_D1Efor(a0: loopi1nv, a1: d1exp, a2: d1exp, a3: d1exp, a4: d1exp): d1exp_node
fun
d1exp_node_D1Ewhile(a0: loopi1nv, a1: d1exp, a2: d1exp): d1exp_node
fun
d1exp_node_D1Eloopexn(a0: int): d1exp_node
fun
d1exp_node_D1Etrywith(a0: i1nvresstate, a1: d1exp, a2: c1laulst): d1exp_node
fun
d1exp_node_D1Eann_type(a0: d1exp, a1: s1exp): d1exp_node
fun
d1exp_node_D1Eann_effc(a0: d1exp, a1: effcst): d1exp_node
fun
d1exp_node_D1Eann_funclo(a0: d1exp, a1: funclo): d1exp_node
fun
d1exp_node_D1Emacsyn(a0: macsynkind, a1: d1exp): d1exp_node
fun
d1exp_node_D1Emacfun(a0: symbol, a1: d1explst): d1exp_node
fun
d1exp_node_D1Esolassert(a0: d1exp): d1exp_node
fun
d1exp_node_D1Esolverify(a0: s1exp): d1exp_node
fun
d1exp_node_D1Eerrexp(): d1exp_node
fun
d1exp_node_is_D1Eide(x: d1exp_node): bool
fun
d1exp_node_is_D1Edqid(x: d1exp_node): bool
fun
d1exp_node_is_D1Eidextapp(x: d1exp_node): bool
fun
d1exp_node_is_D1Eint(x: d1exp_node): bool
fun
d1exp_node_is_D1Eintrep(x: d1exp_node): bool
fun
d1exp_node_is_D1Ebool(x: d1exp_node): bool
fun
d1exp_node_is_D1Echar(x: d1exp_node): bool
fun
d1exp_node_is_D1Efloat(x: d1exp_node): bool
fun
d1exp_node_is_D1Estring(x: d1exp_node): bool
fun
d1exp_node_is_D1Ei0nt(x: d1exp_node): bool
fun
d1exp_node_is_D1Ec0har(x: d1exp_node): bool
fun
d1exp_node_is_D1Ef0loat(x: d1exp_node): bool
fun
d1exp_node_is_D1Es0tring(x: d1exp_node): bool
fun
d1exp_node_is_D1Etop(x: d1exp_node): bool
fun
d1exp_node_is_D1Eempty(x: d1exp_node): bool
fun
d1exp_node_is_D1Ecstsp(x: d1exp_node): bool
fun
d1exp_node_is_D1Etyrep(x: d1exp_node): bool
fun
d1exp_node_is_D1Eliteral(x: d1exp_node): bool
fun
d1exp_node_is_D1Eextval(x: d1exp_node): bool
fun
d1exp_node_is_D1Eextfcall(x: d1exp_node): bool
fun
d1exp_node_is_D1Eextmcall(x: d1exp_node): bool
fun
d1exp_node_is_D1Efoldat(x: d1exp_node): bool
fun
d1exp_node_is_D1Efreeat(x: d1exp_node): bool
fun
d1exp_node_is_D1Etmpid(x: d1exp_node): bool
fun
d1exp_node_is_D1Elet(x: d1exp_node): bool
fun
d1exp_node_is_D1Ewhere(x: d1exp_node): bool
fun
d1exp_node_is_D1Edecseq(x: d1exp_node): bool
fun
d1exp_node_is_D1Eapp_dyn(x: d1exp_node): bool
fun
d1exp_node_is_D1Eapp_sta(x: d1exp_node): bool
fun
d1exp_node_is_D1Esing(x: d1exp_node): bool
fun
d1exp_node_is_D1Elist(x: d1exp_node): bool
fun
d1exp_node_is_D1Eifhead(x: d1exp_node): bool
fun
d1exp_node_is_D1Esifhead(x: d1exp_node): bool
fun
d1exp_node_is_D1Eifcasehd(x: d1exp_node): bool
fun
d1exp_node_is_D1Ecasehead(x: d1exp_node): bool
fun
d1exp_node_is_D1Escasehead(x: d1exp_node): bool
fun
d1exp_node_is_D1Elst(x: d1exp_node): bool
fun
d1exp_node_is_D1Etup(x: d1exp_node): bool
fun
d1exp_node_is_D1Erec(x: d1exp_node): bool
fun
d1exp_node_is_D1Eseq(x: d1exp_node): bool
fun
d1exp_node_is_D1Earrsub(x: d1exp_node): bool
fun
d1exp_node_is_D1Earrinit(x: d1exp_node): bool
fun
d1exp_node_is_D1Earrpsz(x: d1exp_node): bool
fun
d1exp_node_is_D1Eptrof(x: d1exp_node): bool
fun
d1exp_node_is_D1Eviewat(x: d1exp_node): bool
fun
d1exp_node_is_D1Eselab(x: d1exp_node): bool
fun
d1exp_node_is_D1Eraise(x: d1exp_node): bool
fun
d1exp_node_is_D1Eeffmask(x: d1exp_node): bool
fun
d1exp_node_is_D1Evararg(x: d1exp_node): bool
fun
d1exp_node_is_D1Evcopyenv(x: d1exp_node): bool
fun
d1exp_node_is_D1Eshowtype(x: d1exp_node): bool
fun
d1exp_node_is_D1Etempenver(x: d1exp_node): bool
fun
d1exp_node_is_D1Esexparg(x: d1exp_node): bool
fun
d1exp_node_is_D1Eexist(x: d1exp_node): bool
fun
d1exp_node_is_D1Elam_dyn(x: d1exp_node): bool
fun
d1exp_node_is_D1Elaminit_dyn(x: d1exp_node): bool
fun
d1exp_node_is_D1Elam_met(x: d1exp_node): bool
fun
d1exp_node_is_D1Elam_sta_ana(x: d1exp_node): bool
fun
d1exp_node_is_D1Elam_sta_syn(x: d1exp_node): bool
fun
d1exp_node_is_D1Efix(x: d1exp_node): bool
fun
d1exp_node_is_D1Edelay(x: d1exp_node): bool
fun
d1exp_node_is_D1Efor(x: d1exp_node): bool
fun
d1exp_node_is_D1Ewhile(x: d1exp_node): bool
fun
d1exp_node_is_D1Eloopexn(x: d1exp_node): bool
fun
d1exp_node_is_D1Etrywith(x: d1exp_node): bool
fun
d1exp_node_is_D1Eann_type(x: d1exp_node): bool
fun
d1exp_node_is_D1Eann_effc(x: d1exp_node): bool
fun
d1exp_node_is_D1Eann_funclo(x: d1exp_node): bool
fun
d1exp_node_is_D1Emacsyn(x: d1exp_node): bool
fun
d1exp_node_is_D1Emacfun(x: d1exp_node): bool
fun
d1exp_node_is_D1Esolassert(x: d1exp_node): bool
fun
d1exp_node_is_D1Esolverify(x: d1exp_node): bool
fun
d1exp_node_is_D1Eerrexp(x: d1exp_node): bool
//
fun
d1lab_node_encode(v: d1lab_node_view): d1lab_node
fun
d1lab_node_view(x: d1lab_node): d1lab_node_view
fun
d1lab_node_view_free(v: d1lab_node_view): void
fun
d1lab_node_tag(x: d1lab_node): int
fun
d1lab_node_D1LABlab(a0: label): d1lab_node
fun
d1lab_node_D1LABind(a0: d1explst): d1lab_node
fun
d1lab_node_is_D1LABlab(x: d1lab_node): bool
fun
d1lab_node_is_D1LABind(x: d1lab_node): bool
//
fun
d1ecl_new(a0: loc_t, a1: d1ecl_node): d1ecl
fun
d1ecl_loc(x: d1ecl): loc_t
overload .d1ecl_loc with d1ecl_loc
fun
d1ecl_node(x: d1ecl): d1ecl_node
overload .d1ecl_node with d1ecl_node
//
fun
d1exp_new(a0: loc_t, a1: d1exp_node): d1exp
fun
d1exp_loc(x: d1exp): loc_t
overload .d1exp_loc with d1exp_loc
fun
d1exp_node(x: d1exp): d1exp_node
overload .d1exp_node with d1exp_node
//
fun
labd1exp_new(a0: l0ab, a1: d1exp): labd1exp
fun
labd1exp_lab(x: labd1exp): l0ab
overload .labd1exp_lab with labd1exp_lab
fun
labd1exp_elt(x: labd1exp): d1exp
overload .labd1exp_elt with labd1exp_elt
//
fun
d1lab_new(a0: loc_t, a1: d1lab_node): d1lab
fun
d1lab_loc(x: d1lab): loc_t
overload .d1lab_loc with d1lab_loc
fun
d1lab_node(x: d1lab): d1lab_node
overload .d1lab_node with d1lab_node
//
fun
i1fcl_new(a0: loc_t, a1: d1exp, a2: d1exp): i1fcl
fun
i1fcl_loc(x: i1fcl): loc_t
overload .i1fcl_loc with i1fcl_loc
fun
i1fcl_test(x: i1fcl): d1exp
overload .i1fcl_test with i1fcl_test
fun
i1fcl_body(x: i1fcl): d1exp
overload .i1fcl_body with i1fcl_body
//
fun
gm1at_new(a0: loc_t, a1: d1exp, a2: p1atopt): gm1at
fun
gm1at_loc(x: gm1at): loc_t
overload .gm1at_loc with gm1at_loc
fun
gm1at_exp(x: gm1at): d1exp
overload .gm1at_exp with gm1at_exp
fun
gm1at_pat(x: gm1at): p1atopt
overload .gm1at_pat with gm1at_pat
//
fun
c1lau_new(a0: loc_t, a1: p1at, a2: gm1atlst, a3: int, a4: int, a5: d1exp): c1lau
fun
c1lau_loc(x: c1lau): loc_t
overload .c1lau_loc with c1lau_loc
fun
c1lau_pat(x: c1lau): p1at
overload .c1lau_pat with c1lau_pat
fun
c1lau_gua(x: c1lau): gm1atlst
overload .c1lau_gua with c1lau_gua
fun
c1lau_seq(x: c1lau): int
overload .c1lau_seq with c1lau_seq
fun
c1lau_neg(x: c1lau): int
overload .c1lau_neg with c1lau_neg
fun
c1lau_body(x: c1lau): d1exp
overload .c1lau_body with c1lau_body
//
fun
sc1lau_new(a0: loc_t, a1: sp1at, a2: d1exp): sc1lau
fun
sc1lau_loc(x: sc1lau): loc_t
overload .sc1lau_loc with sc1lau_loc
fun
sc1lau_pat(x: sc1lau): sp1at
overload .sc1lau_pat with sc1lau_pat
fun
sc1lau_body(x: sc1lau): d1exp
overload .sc1lau_body with sc1lau_body
//
fun
m1acdef_new(a0: loc_t, a1: symbol, a2: m1acarglst, a3: d1exp): m1acdef
fun
m1acdef_loc(x: m1acdef): loc_t
overload .m1acdef_loc with m1acdef_loc
fun
m1acdef_sym(x: m1acdef): symbol
overload .m1acdef_sym with m1acdef_sym
fun
m1acdef_arg(x: m1acdef): m1acarglst
overload .m1acdef_arg with m1acdef_arg
fun
m1acdef_def(x: m1acdef): d1exp
overload .m1acdef_def with m1acdef_def
//
fun
f1undec_new(a0: loc_t, a1: symbol, a2: loc_t, a3: d1exp, a4: witht1ype): f1undec
fun
f1undec_loc(x: f1undec): loc_t
overload .f1undec_loc with f1undec_loc
fun
f1undec_sym(x: f1undec): symbol
overload .f1undec_sym with f1undec_sym
fun
f1undec_sym_loc(x: f1undec): loc_t
overload .f1undec_sym_loc with f1undec_sym_loc
fun
f1undec_def(x: f1undec): d1exp
overload .f1undec_def with f1undec_def
fun
f1undec_ann(x: f1undec): witht1ype
overload .f1undec_ann with f1undec_ann
//
fun
v1aldec_new(a0: loc_t, a1: p1at, a2: d1exp, a3: witht1ype): v1aldec
fun
v1aldec_loc(x: v1aldec): loc_t
overload .v1aldec_loc with v1aldec_loc
fun
v1aldec_pat(x: v1aldec): p1at
overload .v1aldec_pat with v1aldec_pat
fun
v1aldec_def(x: v1aldec): d1exp
overload .v1aldec_def with v1aldec_def
fun
v1aldec_ann(x: v1aldec): witht1ype
overload .v1aldec_ann with v1aldec_ann
//
fun
v1ardec_new(a0: loc_t, a1: int, a2: symbol, a3: loc_t, a4: i0deopt, a5: s1expopt, a6: d1expopt): v1ardec
fun
v1ardec_loc(x: v1ardec): loc_t
overload .v1ardec_loc with v1ardec_loc
fun
v1ardec_knd(x: v1ardec): int
overload .v1ardec_knd with v1ardec_knd
fun
v1ardec_sym(x: v1ardec): symbol
overload .v1ardec_sym with v1ardec_sym
fun
v1ardec_sym_loc(x: v1ardec): loc_t
overload .v1ardec_sym_loc with v1ardec_sym_loc
fun
v1ardec_pfat(x: v1ardec): i0deopt
overload .v1ardec_pfat with v1ardec_pfat
fun
v1ardec_type(x: v1ardec): s1expopt
overload .v1ardec_type with v1ardec_type
fun
v1ardec_init(x: v1ardec): d1expopt
overload .v1ardec_init with v1ardec_init
//
fun
i1mpdec_new(a0: loc_t, a1: impqi0de, a2: t1mpmarglst, a3: d1exp): i1mpdec
fun
i1mpdec_loc(x: i1mpdec): loc_t
overload .i1mpdec_loc with i1mpdec_loc
fun
i1mpdec_qid(x: i1mpdec): impqi0de
overload .i1mpdec_qid with i1mpdec_qid
fun
i1mpdec_tmparg(x: i1mpdec): t1mpmarglst
overload .i1mpdec_tmparg with i1mpdec_tmparg
fun
i1mpdec_def(x: i1mpdec): d1exp
overload .i1mpdec_def with i1mpdec_def
//
