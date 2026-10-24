# the test doubles of the ccomp group C2 test (see cc2_gen.py): the functions of pats_ccomp.sats that pats_ccomp_{dynexp,decl,claulst}.dats call and that the other
# groups / phase 1 implement. One text for the two languages (the "neutral" part), the representation of the cells (cc2_cells{1,2}.hats) and a few
# shims that differ (SHIM1, SHIM2 below).
import os, re, sys
import cc2_gen as C
G = C.G
M = C.M

def parse_sats_funs():
    """the functions declared in src/pats_ccomp.sats: name -> [param types]"""
    txt = open(os.path.join(M, 'pats_ccomp.sats')).read()
    txt = re.sub(r'\(\*.*?\*\)', '', txt, flags=re.S)
    txt = re.sub(r'//[^\n]*', '', txt)
    res = {}
    for m in re.finditer(r'\bfun\s+(\w+)\s*\(([^()]*)\)\s*:', txt):
        ps = []
        for p in m.group(2).split(','):
            p = p.strip()
            if p: ps.append(p.split(':', 1)[1].strip())
        res.setdefault(m.group(1), ps)
    return res

def ctor(typ, prefix, name, nargs_after, funs, extra=''):
    """generated double: [typ]_<name> (loc, ..args) = K_<typ> (loc, K_<CON> (args))"""
    pass

def smart_constructors():
    funs = parse_sats_funs()
    node_con = {}
    for n in ('primval_node', 'primdec_node', 'instr_node', 'primlab_node'):
        for c, ts in C.CT[n]: node_con[(n, c)] = len(ts)
    out = []
    special = {'primval_lamfix', 'primval_sizeof', 'primval_make_sizeof', 'instr_move_fltrec2'}
    for name, ps in funs.items():
        m = re.match(r'^(primval|primdec|instr|primlab)_(\w+)$', name)
        if not m: continue
        kind, x = m.group(1), m.group(2)
        if name in special: continue
        if x.startswith('make') or x.startswith('is_') or x in ('tmpref_make',): continue
        node = kind + '_node'
        pre = {'primval': 'PMV', 'primdec': 'PMD', 'instr': 'INS', 'primlab': 'PML'}[kind]
        if kind == 'primlab': con = pre + x   # primlab_lab -> PMLlab
        else: con = pre + x
        if (node, con) not in node_con:
            # not a constructor wrapper (printers, fprint, etc. are not matched by the regex above)
            continue
        nfix = 2 if kind == 'primval' else 1
        nargs = len(ps) - nfix
        assert nargs == node_con[(node, con)], (name, ps, con, node_con[(node, con)])
        params = ['loc'] + (['hse'] if kind == 'primval' else []) + ['a%d' % i for i in range(nargs)]
        head = ', '.join(params[:nfix])
        args = ', '.join('a%d' % i for i in range(nargs))
        if kind == 'primval':
            out.append('implement %s (%s) = K_primval (loc, hse, K_%s (%s))' % (name, ', '.join(params), con, args))
        else:
            out.append('implement %s (%s) = K_%s (loc, K_%s (%s))' % (name, ', '.join(params), kind, con, args))
    return '\n'.join(out) + '\n'

# ---------------------------------------------------------------------------------------------------------------------------------- the shims
SHIM2 = r'''
(* ATS2 shims of the doubles *)
fun cl_funclo_fun (): funclo = FUNCLOfun
fun cl_funclo_is_fun (fc: funclo): bool = (case+ fc of FUNCLOfun () => true | _ => false)
fun cl_funclo_knd (fc: funclo): int = funclo_get_clokind (fc)
fun cl_vbmap_nil (): vbindmap = d2varmap_nil<primval> ()
fun cl_funentopt_ptr (x: funentopt): ptr = (case+ gopt_view (x) of ~GOsome (y) => $UN.cast{ptr} (y) | ~GOnone () => the_null_ptr)
fun cl_instrlst_len (xs: instrlst): int = let
  fun loop (xs: instrlst, n: int): int = if glist_is_cons (xs) then loop (glist_tail<instr> (xs), n+1) else n
in loop (xs, 0) end
fun cl_instrlst_nth (xs: instrlst, i: int): instr = if i <= 0 then glist_head<instr> (xs) else cl_instrlst_nth (glist_tail<instr> (xs), i-1)
fun cl_hipatlst_len (xs: hipatlst): int = let
  fun loop (xs: hipatlst, n: int): int = if glist_is_cons (xs) then loop (glist_tail<hipat> (xs), n+1) else n
in loop (xs, 0) end
fun cl_hipatlst_nth (xs: hipatlst, i: int): hipat = if i <= 0 then glist_head<hipat> (xs) else cl_hipatlst_nth (glist_tail<hipat> (xs), i-1)
fun cl_hip_var (hip: hipat): ptr = (case+ hipat_node_view (hip.hipat_node ()) of ~HIPvar (d2v) => $UN.cast{ptr} (d2v) | v => (hipat_node_view_free (v); the_null_ptr))
fun cl_hip_refas (hip: hipat): ptr = (case+ hipat_node_view (hip.hipat_node ()) of ~HIPrefas (d2v, _) => $UN.cast{ptr} (d2v) | v => (hipat_node_view_free (v); the_null_ptr))
fun cl_vbmap_find (d2v: d2var): ptr = cc2_vb_find ($UN.cast{ptr} (d2v))
fun cl_pv_loc (x: primval): location = x.primval_loc ()
fun cl_pv_type (x: primval): hisexp = x.primval_type ()
fun cl_hde_loc (x: hidexp): location = x.hidexp_loc ()
fun cl_hde_type (x: hidexp): hisexp = x.hidexp_type ()
fun cl_hip_loc (x: hipat): location = x.hipat_loc ()
fun cl_hip_type (x: hipat): hisexp = x.hipat_type ()
fun cl_ptrset_funlabopt (p: Ptr1, v: funlabopt): void = $UN.ptr0_set<funlabopt> (p, v)
fun cl_ptrget_funlabopt (p: Ptr1): funlabopt = $UN.ptr0_get<funlabopt> (p)
fun cl_ptrset_instrlstopt (p: Ptr1, v: instrlstopt): void = $UN.ptr0_set<instrlstopt> (p, v)
'''

SHIM1 = r'''
(* ATS1 shims of the doubles *)
macdef the_null_ptr = null
fun cl_funclo_fun (): funclo = FUNCLOfun ()
fun cl_funclo_is_fun (fc: funclo): bool = (case+ fc of FUNCLOfun () => true | _ => false)
fun cl_funclo_knd (fc: funclo): int = (case+ fc of FUNCLOclo (k) => k | _ => 0)
fun cl_vbmap_nil (): vbindmap = d2varmap_nil ()
fun cl_funentopt_ptr (x: funentopt): ptr = (case+ x of Some (y) => $UN.cast{ptr} (y) | None () => null)
fun cl_instrlst_len (xs: instrlst): int = let
  fun loop (xs: List (instr), n: int): int = case+ xs of list_cons (_, xs1) => loop (xs1, n+1) | list_nil () => n
in loop (xs, 0) end
fun cl_instrlst_nth (xs: instrlst, i: int): instr = let
  fun loop (xs: List (instr), i: int): instr = case+ xs of list_cons (x, xs1) => (if i <= 0 then x else loop (xs1, i-1)) | list_nil () => $UN.cast{instr} (null)
in loop (xs, i) end
fun cl_hipatlst_len (xs: hipatlst): int = let
  fun loop (xs: hipatlst, n: int): int = case+ xs of list_cons (_, xs1) => loop (xs1, n+1) | list_nil () => n
in loop (xs, 0) end
fun cl_hipatlst_nth (xs: hipatlst, i: int): hipat = let
  fun loop (xs: hipatlst, i: int): hipat = case+ xs of list_cons (x, xs1) => (if i <= 0 then x else loop (xs1, i-1)) | list_nil () => $UN.cast{hipat} (null)
in loop (xs, i) end
fun cl_hip_var (hip: hipat): ptr = (case+ hip.hipat_node of HIPvar (d2v) => $UN.cast{ptr} (d2v) | _ => null)
fun cl_hip_refas (hip: hipat): ptr = (case+ hip.hipat_node of HIPrefas (d2v, _) => $UN.cast{ptr} (d2v) | _ => null)
fun cl_vbmap_find (d2v: d2var): ptr = cc2_vb_find ($UN.cast{ptr} (d2v))
fun cl_pv_loc (x: primval): location = x.primval_loc
fun cl_pv_type (x: primval): hisexp = x.primval_type
fun cl_hde_loc (x: hidexp): location = x.hidexp_loc
fun cl_hde_type (x: hidexp): hisexp = x.hidexp_type
fun cl_hip_loc (x: hipat): location = x.hipat_loc
fun cl_hip_type (x: hipat): hisexp = x.hipat_type
fun cl_ptrset_funlabopt (p: Ptr1, v: funlabopt): void = $UN.ptrset<funlabopt> (p, v)
fun cl_ptrget_funlabopt (p: Ptr1): funlabopt = $UN.ptrget<funlabopt> (p)
fun cl_ptrset_instrlstopt (p: Ptr1, v: instrlstopt): void = $UN.ptrset<instrlstopt> (p, v)
'''

# ---------------------------------------------------------------------------------------------------------------------------------- the C functions
CDECL = r'''
%{^
#include "cc2_state.h"
extern char *cc2_fl_name (int stamp) ;
%}
extern fun cc2_reset (): void = "mac#cc2_reset"
extern fun cc2_lev_get (): int = "mac#cc2_lev_get"
extern fun cc2_lev_inc (): void = "mac#cc2_lev_inc"
extern fun cc2_lev_dec (): void = "mac#cc2_lev_dec"
extern fun cc2_vec_new (): ptr = "mac#cc2_vec_new"
extern fun cc2_vec_add (v: ptr, x: ptr): void = "mac#cc2_vec_add"
extern fun cc2_vec_len (v: ptr): int = "mac#cc2_vec_len"
extern fun cc2_vec_get (v: ptr, i: int): ptr = "mac#cc2_vec_get"
extern fun cc2_vec_free (v: ptr): void = "mac#cc2_vec_free"
extern fun cc2_vb_push (): void = "mac#cc2_vb_push"
extern fun cc2_vb_pop (): void = "mac#cc2_vb_pop"
extern fun cc2_vb_localjoin (): void = "mac#cc2_vb_localjoin"
extern fun cc2_vb_add (k: ptr, v: ptr): void = "mac#cc2_vb_add"
extern fun cc2_vb_find (k: ptr): ptr = "mac#cc2_vb_find"
extern fun cc2_tl_get (): int = "mac#cc2_tl_get"
extern fun cc2_tl_inc (): void = "mac#cc2_tl_inc"
extern fun cc2_tl_dec (): void = "mac#cc2_tl_dec"
extern fun cc2_tc_push (): void = "mac#cc2_tc_push"
extern fun cc2_tc_add (fl: ptr): void = "mac#cc2_tc_add"
extern fun cc2_tc_pop (): void = "mac#cc2_tc_pop"
extern fun cc2_tc_find (fl: ptr): int = "mac#cc2_tc_find"
extern fun cc2_fl_reg (fl: ptr, d2c: ptr, d2v: ptr, istmp: int): void = "mac#cc2_fl_reg"
extern fun cc2_tc_find_cst (d2c: ptr, istmp: int): ptr = "mac#cc2_tc_find_cst"
extern fun cc2_tc_find_var (d2v: ptr, istmp: int, ntl: &int): ptr = "mac#cc2_tc_find_var"
extern fun cc2_set_inc (kind: int): void = "mac#cc2_set_inc"
extern fun cc2_set_add (kind: int, x: ptr): void = "mac#cc2_set_add"
extern fun cc2_set_dec (kind: int): ptr = "mac#cc2_set_dec"
extern fun cc2_sizeof_set (d2c: ptr): void = "mac#cc2_sizeof_set"
extern fun cc2_sizeof_is (d2c: ptr): int = "mac#cc2_sizeof_is"
extern fun cc2_fl_name (stamp: int): string = "mac#cc2_fl_name"
extern fun cc2_fl_namereg (fl: ptr, name: string): void = "mac#cc2_fl_namereg"
extern fun cc2_flname_c (x: ptr): string = "mac#patsopt_funlab_get_name"
'''

# ---------------------------------------------------------------------------------------------------------------------------------- the neutral doubles
NEUTRAL = r'''
(* ---- logging *)
fun cc2_log (s: string): void = (dd_ps "  | "; dd_ps s; dd_nl ())
fun cc2_log_hid (s: string, hid: hidecl): void = (dd_ps "  | "; dd_ps s; dd_ps " "; dd_hidecl hid; dd_nl ())

(* ---- the global lists of the declarations (they only log) *)
implement the_exndeclst_add (hid) = cc2_log_hid ("the_exndeclst_add", hid)
implement the_saspdeclst_add (hid) = cc2_log_hid ("the_saspdeclst_add", hid)
implement the_extypelst_add (hid) = cc2_log_hid ("the_extypelst_add", hid)
implement the_extcodelst_add (hid) = cc2_log_hid ("the_extcodelst_add", hid)
implement the_staloadlst_add (hid) = cc2_log_hid ("the_staloadlst_add", hid)
implement the_dynloadlst_add (hid) = cc2_log_hid ("the_dynloadlst_add", hid)
implement the_dynconlst_add (d2c) = (dd_ps "  | the_dynconlst_add "; dd_d2con d2c; dd_nl ())
implement the_dyncstlst_add (d2c) = (dd_ps "  | the_dyncstlst_add "; dd_d2cst d2c; dd_nl ())
implement the_funlablst_add (fl) = (dd_ps "  | the_funlablst_add "; cd_funlab fl; dd_nl ())

(* ---- trans2_env: the level of the dynamic variables *)
implement the_d2varlev_get () = cc2_lev_get ()

(* ---- the [sizeof] constant of dyncst2, the integer of an i0nt *)
implement d2cst_is_sizeof (d2c) = (cc2_sizeof_is ($UN.cast{ptr} (d2c)) > 0)
implement i0nt2intinf (tok) = $INT.intinf_make_int (0)

(* ---- tmplab, tmpvar *)
implement tmplab_make (loc) = K_tmplab (loc, $STMP.tmplab_stamp_make ())
implement tmplab_get_loc (x) = cl_tmplab_loc (x)
implement tmplab_get_stamp (x) = cl_tmplab_stamp (x)
implement tmpvar_make (loc, hse) = K_tmpvar (loc, hse, 0, 0, 0, ON_tmpvaropt (), 0, $STMP.tmpvar_stamp_make ())
implement tmpvar_make_ref (loc, hse) = K_tmpvar (loc, hse, 1, 0, 0, ON_tmpvaropt (), 0, $STMP.tmpvar_stamp_make ())
implement tmpvar_make_ret (loc, hse) = K_tmpvar (loc, hse, 0, 1, 0, ON_tmpvaropt (), 0, $STMP.tmpvar_stamp_make ())
implement tmpvar_get_loc (x) = cl_tmpvar_loc (x)
implement tmpvar_get_type (x) = cl_tmpvar_type (x)
implement tmpvar_isref (x) = (cl_tmpvar_ref (x) > 0)
implement tmpvar_isret (x) = (cl_tmpvar_ret (x) > 0)
implement tmpvar_get_topknd (x) = cl_tmpvar_topknd (x)
implement tmpvar_get_origin (x) = cl_tmpvar_origin (x)
implement tmpvar_get_suffix (x) = cl_tmpvar_suffix (x)
implement tmpvar_get_stamp (x) = cl_tmpvar_stamp (x)
implement tmpvar_get_tailcal (x) = cl_tmpvar_ret (x)
implement tmpvar_inc_tailcal (x) = cl_set_tmpvar_ret (x, cl_tmpvar_ret (x) + 1)
implement tmpvar_set_tyclo (x, fl) = cl_set_tmpvar_suffix (x, 1000 + $STMP.stamp_get_int (funlab_get_stamp ($UN.cast{funlab} (fl))))
implement fprint_tmplab (out, x) = cd_tmplab (x)
implement fprint_tmpvar (out, x) = cd_tmpvar (x)

(* ---- funlab *)
fun cc2_funlab_mk (hse: hisexp, fc: funclo, d2copt: d2cstopt, d2vopt: d2varopt, t2mas: t2mpmarglst): funlab =
  let
    val st = $STMP.funlab_stamp_make ()
    val name = cc2_fl_name ($STMP.stamp_get_int st)
    val fl = K_funlab (name, cc2_lev_get (), fc, hse, 0, d2copt, d2vopt, 0, ON_funlabopt (), 0, t2mas, ON_funentopt (), st)
    val () = cc2_fl_namereg ($UN.cast{ptr} (fl), name)
  in fl end
fun cc2_funclo_of (opt: fcopt_vt): funclo = (case+ opt of ~Some_vt (fc) => fc | ~None_vt () => cl_funclo_fun ())
implement funlab_make_type (hse) = cc2_funlab_mk (hse, cl_funclo_fun (), ON_d2cstopt (), ON_d2varopt (), LN_t2mpmarglst ())
implement funlab_make_dcst_type (d2c, hse, opt) = let
  val fl = cc2_funlab_mk (hse, cc2_funclo_of (opt), OS_d2cstopt (d2c), ON_d2varopt (), LN_t2mpmarglst ())
  val () = cc2_fl_reg ($UN.cast{ptr} (fl), $UN.cast{ptr} (d2c), the_null_ptr, 0)
in fl end
implement funlab_make_dvar_type (d2v, hse, opt) = let
  val fl = cc2_funlab_mk (hse, cc2_funclo_of (opt), ON_d2cstopt (), OS_d2varopt (d2v), LN_t2mpmarglst ())
  val () = cc2_fl_reg ($UN.cast{ptr} (fl), the_null_ptr, $UN.cast{ptr} (d2v), 0)
in fl end
implement funlab_make_tmpcst_type (d2c, t2mas, hse, opt) = let
  val fl = cc2_funlab_mk (hse, cc2_funclo_of (opt), OS_d2cstopt (d2c), ON_d2varopt (), t2mas)
  val () = cc2_fl_reg ($UN.cast{ptr} (fl), $UN.cast{ptr} (d2c), the_null_ptr, 1)
in fl end
implement funlab_get_name (x) = cc2_flname_c ($UN.cast{ptr} (x))
implement funlab_get_level (x) = cl_funlab_level (x)
implement funlab_get_funclo (x) = cl_funlab_funclo (x)
implement funlab_get_type (x) = cl_funlab_type (x)
implement funlab_get_tmpknd (x) = cl_funlab_tmpknd (x)
implement funlab_set_tmpknd (x, k) = cl_set_funlab_tmpknd (x, k)
implement funlab_get_stamp (x) = $effmask_all (cl_funlab_stamp (x))
implement funlab_get_funent (x) = cl_funlab_funent (x)
implement funlab_set_funent (x, opt) = let
  val () = cl_set_funlab_funent (x, opt)
  val p = cl_funentopt_ptr (opt)
in
  if p > the_null_ptr then (dd_ps "  | funlab_set_funent "; cd_funlab x; dd_ps " "; cd_funent ($UN.cast{funent} (p)); dd_nl ())
  else (dd_ps "  | funlab_set_funent "; cd_funlab x; dd_ps " none"; dd_nl ())
end
implement fprint_funlab (out, x) = cd_funlab (x)

(* ---- funent *)
implement funent_make2 (loc, flab, imparg, tmparg, tmpret, fls0, d2es, vbmap, inss) =
  K_funent (loc, flab, imparg, tmparg, ON_tmpsubopt (), tmpret, fls0, ON_funlablstopt (), d2es, ON_d2envlstopt (), vbmap, inss, LN_tmpvarlst (), LN_funlablst ())
implement funent_get_tmpret (x) = cl_funent_tmpret (x)

(* ---- d2env *)
implement d2env_make (d2v, hse) = K_d2env (d2v, hse)
implement d2env_get_var (x) = $effmask_all (cl_d2env_var (x))
implement d2env_get_type (x) = $effmask_all (cl_d2env_type (x))

(* ---- the smart constructors of the trees *)
implement primval_lamfix (knd, pmv) = K_primval (cl_pv_loc (pmv), cl_pv_type (pmv), K_PMVlamfix (knd, pmv))
implement primval_sizeof (loc, hse0, hse) = K_primval (loc, hse0, K_PMVsizeof (hse))
implement primval_make_sizeof (loc, hselt) = primval_sizeof (loc, hisexp_size_t0ype (), hselt)
implement primval_make_tmp (loc, tmp) = primval_tmp (loc, tmpvar_get_type (tmp), tmp)
implement primval_make_tmpref (loc, tmp) = primval_tmpref (loc, tmpvar_get_type (tmp), tmp)
implement primval_make_ptrofsel (loc, pmv, hse_rt, pmls) =
  primval_ptrof (loc, hisexp_typtr, primval_selptr (loc, hisexp_undefined, pmv, hse_rt, pmls))
implement primval_make_funlab (loc, fl) = let
  val hse = funlab_get_type (fl)
in
  if cl_funclo_is_fun (funlab_get_funclo fl) then primval_funlab (loc, hse, fl) else primval_cfunlab (loc, hse, cl_funclo_knd (funlab_get_funclo fl), fl)
end
implement primval_make2_funlab (loc, hse0, fl) =
  if cl_funclo_is_fun (funlab_get_funclo fl) then primval_funlab (loc, hse0, fl) else primval_cfunlab (loc, hse0, cl_funclo_knd (funlab_get_funclo fl), fl)
implement primval_make_d2vfunlab (loc, d2v, fl) = primval_d2vfunlab (loc, funlab_get_type (fl), d2v, fl)
implement ibranch_make (loc, inss) = K_ibranch (loc, inss)
implement instr_move_fltrec2 (loc, tmp, arg, hse) = K_instr (loc, K_INSmove_fltrec (tmp, arg, hse))
implement fprint_primval (out, x) = cd_primval (x)
implement fprint_patck (out, x) = cd_patck (x)
implement fprint_patckont (out, x) = cd_patckont (x)

(* ---- the instruction sequences: a vector in cc2_state.c *)
implement instrseq_make_nil () = $UN.castvwtp0{instrseq} (cc2_vec_new ())
implement instrseq_add (res, x) = cc2_vec_add ($UN.castvwtp1{ptr} (res), $UN.cast{ptr} (x))
implement instrseq_get_free (res) = let
  val v = $UN.castvwtp0{ptr} (res)
  fun loop (v: ptr, i: int, acc: instrlst): instrlst =
    if i >= 0 then loop (v, i-1, LC_instrlst ($UN.cast{instr} (cc2_vec_get (v, i)), acc)) else acc
  val xs = loop (v, cc2_vec_len (v) - 1, LN_instrlst ())
  val () = cc2_vec_free (v)
in xs end
implement instrseq_add_comment (res, comment) = instrseq_add (res, instr_comment ($LOC.location_dummy, comment))
implement instrseq_add_tmpdec (res, loc, tmp) = instrseq_add (res, instr_tmpdec (loc, tmp))
implement instrseq_add_extvar (res, loc, xnm, pmv) = instrseq_add (res, instr_extvar (loc, xnm, pmv))
implement instrseq_add_dcstdef (res, loc, d2c, pmv) = instrseq_add (res, instr_dcstdef (loc, d2c, pmv))
implement instrseq_addlst (res, xs) = let
  val n = cl_instrlst_len (xs)
  fun loop (res: !instrseq, xs: instrlst, i: int, n: int): void =
    if i < n then (instrseq_add (res, cl_instrlst_nth (xs, i)); loop (res, xs, i+1, n)) else ()
in loop (res, xs, 0, n) end
implement instrseq_addlst_vt (res, xs) =
  case+ xs of
  | ~list_vt_cons (x, xs) => (instrseq_add (res, x); instrseq_addlst_vt (res, xs))
  | ~list_vt_nil () => ()
implement instrseq_add_freeconlst (res, loc0, pmvs) =
  case+ pmvs of
  | ~list_vt_cons (pmv, pmvs) => (instrseq_add (res, instr_freecon (loc0, pmv)); instrseq_add_freeconlst (res, loc0, pmvs))
  | ~list_vt_nil () => ()

(* ---- the environment of the compilation (cc2_state.c) *)
assume ccompenv_push_v = unit_v
implement ccompenv_make () = ($UN.castvwtp0{ccompenv} ($UN.cast{ptr} (1)))
implement ccompenv_free (env) = let val _ = $UN.castvwtp0{ptr} (env) in cc2_reset () end
implement ccompenv_get_tmplevel (env) = cc2_tl_get ()
implement ccompenv_inc_tmplevel (env) = (cc2_log "inc_tmplevel"; cc2_tl_inc ())
implement ccompenv_dec_tmplevel (env) = (cc2_log "dec_tmplevel"; cc2_tl_dec ())
implement ccompenv_push (env) = let prval pf = unit_v () in cc2_vb_push (); (pf | ()) end
implement ccompenv_pop (pf | env) = let prval unit_v () = pf in cc2_vb_pop () end
implement ccompenv_localjoin (pf1, pf2 | env) = let prval unit_v () = pf1 prval unit_v () = pf2 in cc2_log "localjoin"; cc2_vb_localjoin () end
implement ccompenv_add_vbindmapenvall (env, d2v, pmv) = (dd_ps "  | add_vbindmapenvall "; dd_d2var d2v; dd_ps " "; cd_primval pmv; dd_nl (); cc2_vb_add ($UN.cast{ptr} (d2v), $UN.cast{ptr} (pmv)))
implement ccompenv_find_vbindmapall (env, d2v) = let
  val p = cl_vbmap_find (d2v)
in if p > the_null_ptr then Some_vt ($UN.cast{primval} (p)) else None_vt () end
implement ccompenv_inc_vbindmapenv (env) = cc2_log "inc_vbindmapenv"
implement ccompenv_getdec_vbindmapenv (env) = (cc2_log "getdec_vbindmapenv"; cl_vbmap_nil ())
implement ccompenv_inc_freeconenv (env) = cc2_set_inc (2)
implement ccompenv_add_freeconenv_if (env, pmv, pck, d2c) = (dd_ps "  | add_freeconenv_if "; cd_primval pmv; dd_ps " "; dd_pckind pck; dd_ps " "; dd_d2con d2c; dd_nl (); cc2_set_add (2, $UN.cast{ptr} (pmv)))
implement ccompenv_getdec_freeconenv (env) = let
  val v = cc2_set_dec (2)
  fun loop (v: ptr, i: int, acc: List0_vt (primval)): List0_vt (primval) =
    if i >= 0 then loop (v, i-1, list_vt_cons ($UN.cast{primval} (cc2_vec_get (v, i)), acc)) else acc
  val xs = loop (v, cc2_vec_len (v) - 1, list_vt_nil ())
  val () = cc2_vec_free (v)
in xs end
implement ccompenv_inc_tailcalenv (env, fl) = (dd_ps "  | inc_tailcalenv "; cd_funlab fl; dd_nl (); cc2_tc_push (); cc2_tc_add ($UN.cast{ptr} (fl)))
implement ccompenv_dec_tailcalenv (env) = (cc2_log "dec_tailcalenv"; cc2_tc_pop ())
implement ccompenv_inc_tailcalenv_fnx (env, fls) = let
  val () = (cc2_log "inc_tailcalenv_fnx"; cc2_tc_push ())
  fun loop (fls: List0_vt (funlab)): void =
    case+ fls of
    | ~list_vt_cons (fl, fls) => (dd_ps "  |   "; cd_funlab fl; dd_nl (); cc2_tc_add ($UN.cast{ptr} (fl)); loop (fls))
    | ~list_vt_nil () => ()
in loop (fls) end
implement ccompenv_find_tailcalenv (env, fl) = cc2_tc_find ($UN.cast{ptr} (fl))
// HX-2026-10: the check of non-tail calls to the members of a [fnx]-group (patsopt only): no trace, never fires
implement ccompenv_find_tailcalenv_opt (env, fl) = ~1
implement ccompenv_find_tailcalenv_cst (env, d2c) = let
  val p = cc2_tc_find_cst ($UN.cast{ptr} (d2c), 0)
in if p > the_null_ptr then Some_vt ($UN.cast{funlab} (p)) else None_vt () end
implement ccompenv_find_tailcalenv_tmpcst (env, d2c, t2mas) = let
  val p = cc2_tc_find_cst ($UN.cast{ptr} (d2c), 1)
in if p > the_null_ptr then Some_vt ($UN.cast{funlab} (p)) else None_vt () end
implement ccompenv_find_tailcalenv_tmpvar (env, d2v, t2mas, ntl) = let
  val p = cc2_tc_find_var ($UN.cast{ptr} (d2v), 1, ntl)
in if p > the_null_ptr then Some_vt ($UN.cast{funlab} (p)) else None_vt () end
implement ccompenv_inc_flabsetenv (env) = cc2_set_inc (0)
implement ccompenv_add_flabsetenv (env, fl) = (dd_ps "  | add_flabsetenv "; cd_funlab fl; dd_nl (); cc2_set_add (0, $UN.cast{ptr} (fl)))
implement ccompenv_getdec_flabsetenv (env) = $UN.castvwtp0{funlabset_vt} (cc2_set_dec (0))
implement funlabset_vt_listize_free (fls) = let
  val v = $UN.castvwtp0{ptr} (fls)
  fun loop (v: ptr, i: int, acc: List0_vt (funlab)): List0_vt (funlab) =
    if i >= 0 then loop (v, i-1, list_vt_cons ($UN.cast{funlab} (cc2_vec_get (v, i)), acc)) else acc
  val xs = loop (v, cc2_vec_len (v) - 1, list_vt_nil ())
  val () = cc2_vec_free (v)
in xs end
implement ccompenv_inc_dvarsetenv (env) = cc2_set_inc (1)
implement ccompenv_add_dvarsetenv_var (env, d2v) = (dd_ps "  | add_dvarsetenv_var "; dd_d2var d2v; dd_nl (); cc2_set_add (1, $UN.cast{ptr} (d2v)))
implement ccompenv_getdec_dvarsetenv (env) = $UN.castvwtp0{d2envset_vt} (cc2_set_dec (1))
implement d2envset_vt_listize_free (d2es) = $effmask_all (let
  val v = $UN.castvwtp0{ptr} (d2es)
  fun loop (v: ptr, i: int, acc: List0_vt (d2env)): List0_vt (d2env) =
    if i >= 0 then loop (v, i-1, list_vt_cons (d2env_make ($UN.cast{d2var} (cc2_vec_get (v, i)), hisexp_typtr), acc)) else acc
  val xs = loop (v, cc2_vec_len (v) - 1, list_vt_nil ())
  val () = cc2_vec_free (v)
in xs end)
implement ccompenv_addlst_flabsetenv_ifmap (env, flev0, vbmap, fls0) = let
  fun loop (env: !ccompenv, flev0: int, fls: List0_vt (funlab)): List0_vt (funlab) =
    case+ fls of
    | ~list_vt_cons (fl, fls) => (
        if funlab_get_level (fl) > flev0 then list_vt_cons (fl, loop (env, flev0, fls))
        else (ccompenv_add_flabsetenv (env, fl); loop (env, flev0, fls))
      )
    | ~list_vt_nil () => list_vt_nil ()
in loop (env, flev0, fls0) end
implement ccompenv_add_tempenver (env, d2vs) = (dd_ps "  | add_tempenver "; dd_d2varlst d2vs; dd_nl ())
implement ccompenv_add_staload (env, fenv) = (dd_ps "  | add_staload "; dd_filenv fenv; dd_nl ())
implement ccompenv_add_fundec (env, hfd) = (dd_ps "  | add_fundec "; dd_hifundec hfd; dd_nl ())
implement ccompenv_add_impdec (env, imp) = (dd_ps "  | add_impdec "; dd_hiimpdec imp; dd_nl ())
implement ccompenv_tmpcst_match (env, d2c, t2mas) = K_TMPCSTMATnone ()
implement ccompenv_tmpvar_match (env, d2v, t2mas) = K_TMPVARMATnone ()
implement ccomp_tmpcstmat (env, loc0, hse0, d2c, t2ms, tmpmat) = primval_tmpltcstmat (loc0, hse0, d2c, t2ms, tmpmat)
implement ccomp_tmpvarmat (env, loc0, hse0, d2v, t2ms, tmpmat) = primval_tmpltvarmat (loc0, hse0, d2v, t2ms, tmpmat)

(* ---- the functions of the other groups: patterns, case, loops, lazy evaluation, try-with *)
fun cc2_hips (hips: hipatlst): void = let
  val n = cl_hipatlst_len (hips)
  fun loop (hips: hipatlst, i: int, n: int): void =
    if i < n then ((if i > 0 then dd_ps ","); dd_hipat (cl_hipatlst_nth (hips, i)); loop (hips, i+1, n)) else ()
in loop (hips, 0, n) end
implement hipatck_ccomp (env, res, fail, hip, pmv) = let
  val () = (dd_ps "  | hipatck_ccomp "; cd_patckont fail; dd_ps " "; dd_hipat hip; dd_ps " "; cd_primval pmv; dd_nl ())
in instrseq_add (res, instr_patck (cl_hip_loc (hip), pmv, K_PATCKbool (true), fail)) end
fun cc2_himatch (name: string, env: !ccompenv, res: !instrseq, lvl: int, hip: hipat, pmv: primval): void = let
  val () = (dd_ps "  | "; dd_ps name; dd_ps " "; dd_int lvl; dd_ps " "; dd_hipat hip; dd_ps " "; cd_primval pmv; dd_nl ())
  val p = cl_hip_var (hip)
  val () = if p > the_null_ptr then let val d2v = $UN.cast{d2var} (p) in (d2var_set_level (d2v, lvl); ccompenv_add_vbindmapenvall (env, d2v, pmv)) end
  val p2 = cl_hip_refas (hip)
  val () = if p2 > the_null_ptr then let val d2v = $UN.cast{d2var} (p2) in (d2var_set_level (d2v, lvl); ccompenv_add_vbindmapenvall (env, d2v, pmv)) end
in instrseq_add_comment (res, name) end
implement himatch_ccomp (env, res, lvl, hip, pmv) = cc2_himatch ("himatch", env, res, lvl, hip, pmv)
implement himatch2_ccomp (env, res, lvl, hip, pmv) = cc2_himatch ("himatch2", env, res, lvl, hip, pmv)
implement hifunarg_ccomp (env, res, flab, lvl, loc_fun, hips) = let
  val () = (dd_ps "  | hifunarg_ccomp "; cd_funlab flab; dd_ps " "; dd_int lvl; dd_ps " ["; cc2_hips hips; dd_ps "]"; dd_nl ())
  val n = cl_hipatlst_len (hips)
  fun loop (env: !ccompenv, res: !instrseq, hips: hipatlst, lvl: int, loc: location, i: int, n: int): void =
    if i < n then let
      val hip = cl_hipatlst_nth (hips, i)
      val pmv = primval_arg (loc, cl_hip_type (hip), i)
      val () = cc2_himatch ("hifunarg", env, res, lvl, hip, pmv)
    in loop (env, res, hips, lvl, loc, i+1, n) end else ()
in loop (env, res, hips, lvl, loc_fun, 0, n) end
fun cc2_ret (name: string, env: !ccompenv, res: !instrseq, tmpret: tmpvar, hde: hidexp): void = let
  val () = (dd_ps "  | "; dd_ps name; dd_ps " "; cd_tmpvar tmpret; dd_ps " "; dd_hidexp hde; dd_nl ())
in instrseq_add_comment (res, name) end
implement hidexp_ccomp_ret_case (env, res, tmpret, hde) = cc2_ret ("ret_case", env, res, tmpret, hde)
implement hidexp_ccomp_ret_delay (env, res, tmpret, hde) = cc2_ret ("ret_delay", env, res, tmpret, hde)
implement hidexp_ccomp_ret_ldelay (env, res, tmpret, hde) = cc2_ret ("ret_ldelay", env, res, tmpret, hde)
implement hidexp_ccomp_ret_lazyeval (env, res, tmpret, hde) = cc2_ret ("ret_lazyeval", env, res, tmpret, hde)
implement hidexp_ccomp_ret_trywith (env, res, tmpret, hde) = cc2_ret ("ret_trywith", env, res, tmpret, hde)
implement hidexp_ccomp_loop (env, res, hde) = let
  val () = (dd_ps "  | loop "; dd_hidexp hde; dd_nl ())
  val () = instrseq_add_comment (res, "loop")
in primval_empty (cl_hde_loc (hde), cl_hde_type (hde)) end
implement hidexp_ccomp_loopexn (env, res, hde) = let
  val () = (dd_ps "  | loopexn "; dd_hidexp hde; dd_nl ())
  val () = instrseq_add_comment (res, "loopexn")
in primval_empty (cl_hde_loc (hde), cl_hde_type (hde)) end
implement hisexp_typize (flag, hse) = (dd_ps "  | hisexp_typize "; dd_int flag; dd_ps " "; dd_hisexp hse; dd_nl (); $UN.cast{hitype} (the_null_ptr))
implement hifundec_set_funlabopt (hfd, opt) = let
  val () = (dd_ps "  | hifundec_set_funlabopt "; cd_funlabopt opt; dd_nl ())
in cl_ptrset_funlabopt (hifundec_getref_funlabopt (hfd), opt) end
implement hiimpdec_get_funlabopt (imp) = cl_ptrget_funlabopt (hiimpdec_getref_funlabopt (imp))
implement hiimpdec_set_funlabopt (imp, opt) = let
  val () = (dd_ps "  | hiimpdec_set_funlabopt "; cd_funlabopt opt; dd_nl ())
in cl_ptrset_funlabopt (hiimpdec_getref_funlabopt (imp), opt) end
implement hiimpdec_set_instrlstopt (imp, opt) = let
  val () = (dd_ps "  | hiimpdec_set_instrlstopt "; cd_instrlstopt opt; dd_nl ())
in cl_ptrset_instrlstopt (hiimpdec_getref_instrlstopt (imp), opt) end
'''

# ---------------------------------------------------------------------------------------------------------------------------------- the language specific lines of the doubles
DIALECT2 = r'''
implement the_d2varlev_inc () = cc2_lev_inc ()
implement the_d2varlev_dec () = cc2_lev_dec ()
implement funent_set_fnxlablst (x, fls) = cl_set_funent_fnxlablst (x, fls)
'''
DIALECT1 = r'''
assume the_d2varlev_inc_v = unit_v
implement the_d2varlev_inc () = (cc2_lev_inc (); (unit_v () | ()))
implement the_d2varlev_dec (pf | (*none*)) = let prval unit_v () = pf in cc2_lev_dec () end
extern fun cc2_funent_set_fnx (x: funent, fls: funlablst): void = "patsopt_funent_set_fnxlablst"
implement cc2_funent_set_fnx (x, fls) = cl_set_funent_fnxlablst (x, fls)
'''
