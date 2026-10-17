(* the part of the C1 test (cc1_drv.dats, cc1_drv1.dats) that is written once for ATS1 and ATS2 (see cc1_gen.py) *)
(* ****** ****** *)
//
// Everything here is in the common subset of ATS1 and ATS2: the API of pats_ccomp.sats has the same names in both.
// The including driver provides: dd_out, the staload aliases and the language layer (cc1_lang1.hats / cc1_lang2.hats).
//
(* ****** ****** *)

fun dd_ps (s: string): void = fprint_string (dd_out, s)
fun dd_nl (): void = fprint_newline (dd_out)
fun dd_flush (): void = fflush_stdout ()
fun dd_int (x: int): void = fprint_int (dd_out, x)
fun dd_bool (x: bool): void = fprint_bool (dd_out, x)
fun dd_loc (x: location): void = $LOC.fprint_location (dd_out, x)
fun dd_d2var (x: d2var): void = fprint_d2var (dd_out, x)
fun dd_d2cst (x: d2cst): void = fprint_d2cst (dd_out, x)
fun dd_d2env (x: d2env): void = fprint_d2env (dd_out, x)
fun dd_funlab (x: funlab): void = fprint_funlab (dd_out, x)
fun dd_tmplab (x: tmplab): void = fprint_tmplab (dd_out, x)
fun dd_tmpvar (x: tmpvar): void = fprint_tmpvar (dd_out, x)
fun dd_hisexp (x: hisexp): void = fprint_hisexp (dd_out, x)
fun dd_primval (x: primval): void = fprint_primval (dd_out, x)
fun dd_instr (x: instr): void = fprint_instr (dd_out, x)
fun dd_instrlst (x: instrlst): void = fprint_instrlst (dd_out, x)
fun dd_tmpcstmat (x: tmpcstmat): void = fprint_tmpcstmat (dd_out, x)
fun dd_tmpvarmat (x: tmpvarmat): void = fprint_tmpvarmat (dd_out, x)
fun dd_vbindmap (x: vbindmap): void = fprint_vbindmap (dd_out, x)
fun mkhse (k: int): hisexp = hisexp_tyabs (mksym (k))
fun mkhfun (k: int): hisexp = hisexp_fun (mkfunclo (k), LC_hisexplst (mkhse (k), LC_hisexplst (mkhse (k+2), LN_hisexplst ())), mkhse (k+1))

fun dd_optvt_primval (x: Option_vt (primval)): void =
  case+ x of ~Some_vt (e) => (dd_ps "Some("; dd_primval e; dd_ps ")") | ~None_vt () => dd_ps "None"
fun dd_optvt_funlab (x: Option_vt (funlab)): void =
  case+ x of ~Some_vt (e) => (dd_ps "Some("; dd_funlab e; dd_ps ")") | ~None_vt () => dd_ps "None"

fun dd_listvt_primval (xs: List0_vt (primval)): void = let
  fun loop (xs: List0_vt (primval), i: int): void =
    case+ xs of
    | ~list_vt_cons (x, xs) => ((if i > 0 then dd_ps ","); dd_primval x; loop (xs, i+1))
    | ~list_vt_nil () => ()
in
  dd_ps "["; loop (xs, 0); dd_ps "]"
end
fun dd_listvt_funlab (xs: List0_vt (funlab)): void = let
  fun loop (xs: List0_vt (funlab), i: int): void =
    case+ xs of
    | ~list_vt_cons (x, xs) => ((if i > 0 then dd_ps ","); dd_funlab x; loop (xs, i+1))
    | ~list_vt_nil () => ()
in
  dd_ps "["; loop (xs, 0); dd_ps "]"
end
fun dd_listvt_d2env (xs: List0_vt (d2env)): void = let
  fun loop (xs: List0_vt (d2env), i: int): void =
    case+ xs of
    | ~list_vt_cons (x, xs) => ((if i > 0 then dd_ps ","); dd_d2env x; loop (xs, i+1))
    | ~list_vt_nil () => ()
in
  dd_ps "["; loop (xs, 0); dd_ps "]"
end
fun dd_listvt_d2var (xs: List0_vt (d2var)): void = let
  fun loop (xs: List0_vt (d2var), i: int): void =
    case+ xs of
    | ~list_vt_cons (x, xs) => ((if i > 0 then dd_ps ","); dd_d2var x; loop (xs, i+1))
    | ~list_vt_nil () => ()
in
  dd_ps "["; loop (xs, 0); dd_ps "]"
end
fun dd_d2envset_vt (xs: d2envset_vt): void = dd_listvt_d2env (d2envset_vt_listize_free (xs))
fun dd_funlabset_vt (xs: funlabset_vt): void = dd_listvt_funlab (funlabset_vt_listize_free (xs))

(* ****** ****** *)
//
// the operations on the compilation environment: each one runs the function, prints its result
// and (when it changes the environment) the markenvlst of the environment
//
fun p_env (env: !ccompenv): void = fprint_ccompenv (dd_out, env)

fun op_tmplevel (env: !ccompenv, d: int): void = let
  val () = if d > 0 then ccompenv_inc_tmplevel (env) else ccompenv_dec_tmplevel (env)
in
  dd_ps "tmplevel "; dd_int (ccompenv_get_tmplevel env); dd_nl ()
end
fun op_tmprecdepth (env: !ccompenv, d: int): void = let
  val () = if d > 0 then ccompenv_inc_tmprecdepth (env) else ccompenv_dec_tmprecdepth (env)
in
  dd_ps "tmprecdepth "; dd_int (ccompenv_get_tmprecdepth env); dd_nl ()
end

fun op_freeconenv_inc (env: !ccompenv): void = (ccompenv_inc_freeconenv (env); dd_ps "freeconenv_inc\n")
fun op_freeconenv_add (env: !ccompenv, pmv: primval): void = (ccompenv_add_freeconenv (env, pmv); dd_ps "freeconenv_add "; dd_primval pmv; dd_nl ())
fun op_freetupenv_add_if (env: !ccompenv, pmv: primval, pck: pckind): void = let
  val () = ccompenv_add_freetupenv_if (env, pmv, pck)
in
  dd_ps "freetupenv_add_if "; dd_primval pmv; dd_nl ()
end
fun op_freeconenv_add_if (env: !ccompenv, pmv: primval, pck: pckind, d2c: d2con): void = let
  val () = ccompenv_add_freeconenv_if (env, pmv, pck, d2c)
in
  dd_ps "freeconenv_add_if "; dd_primval pmv; dd_nl ()
end
fun op_freeconenv_getdec (env: !ccompenv): void = let
  val pmvs = ccompenv_getdec_freeconenv (env)
in
  dd_ps "freeconenv_getdec "; dd_listvt_primval pmvs; dd_nl ()
end

fun op_loopexn_inc (env: !ccompenv, t1: tmplab, t2: tmplab, t3: tmplab): void = let
  val () = ccompenv_inc_loopexnenv (env, t1, t2, t3)
in
  dd_ps "loopexn_inc\n"
end
fun op_loopexn_dec (env: !ccompenv): void = (ccompenv_dec_loopexnenv (env); dd_ps "loopexn_dec\n")
fun op_loopfini (env: !ccompenv): void = (dd_ps "loopfini "; dd_tmplab (ccompenv_get_loopfini env); dd_nl ())
fun op_loopcont (env: !ccompenv): void = (dd_ps "loopcont "; dd_tmplab (ccompenv_get_loopcont env); dd_nl ())

fun op_tailcal_inc (env: !ccompenv, fl: funlab): void = (ccompenv_inc_tailcalenv (env, fl); dd_ps "tailcal_inc "; dd_funlab fl; dd_nl ())
fun op_tailcal_inc_fnx (env: !ccompenv, fls: List0_vt (funlab)): void = let
  val () = (dd_ps "tailcal_inc_fnx "; dd_listvt_funlab (list_vt_copy fls); dd_nl ())
in
  ccompenv_inc_tailcalenv_fnx (env, fls)
end
fun op_tailcal_dec (env: !ccompenv): void = (ccompenv_dec_tailcalenv (env); dd_ps "tailcal_dec\n")
fun op_tailcal_find (env: !ccompenv, fl: funlab): void = let
  val n = ccompenv_find_tailcalenv (env, fl)
in
  dd_ps "tailcal_find "; dd_funlab fl; dd_ps " -> "; dd_int n; dd_nl ()
end
fun op_tailcal_find_cst (env: !ccompenv, d2c: d2cst): void = let
  val r = ccompenv_find_tailcalenv_cst (env, d2c)
in
  dd_ps "tailcal_find_cst "; dd_d2cst d2c; dd_ps " -> "; dd_optvt_funlab r; dd_nl ()
end
fun op_tailcal_find_var (env: !ccompenv, d2v: d2var): void = let
  var ntl: int = 7
  val r = ccompenv_find_tailcalenv_var (env, d2v, ntl)
in
  dd_ps "tailcal_find_var "; dd_d2var d2v; dd_ps " -> "; dd_optvt_funlab r; dd_ps " ntl="; dd_int ntl; dd_nl ()
end
fun op_tailcal_find_tmpcst (env: !ccompenv, d2c: d2cst): void = let
  val r = ccompenv_find_tailcalenv_tmpcst (env, d2c, LN_t2mpmarglst ())
in
  dd_ps "tailcal_find_tmpcst "; dd_d2cst d2c; dd_ps " -> "; dd_optvt_funlab r; dd_nl ()
end
fun op_tailcal_find_tmpvar (env: !ccompenv, d2v: d2var): void = let
  var ntl: int = 7
  val r = ccompenv_find_tailcalenv_tmpvar (env, d2v, LN_t2mpmarglst (), ntl)
in
  dd_ps "tailcal_find_tmpvar "; dd_d2var d2v; dd_ps " -> "; dd_optvt_funlab r; dd_ps " ntl="; dd_int ntl; dd_nl ()
end

fun op_dvarset_inc (env: !ccompenv): void = (ccompenv_inc_dvarsetenv (env); dd_ps "dvarset_inc\n")
fun op_dvarset_incwth (env: !ccompenv, d2es: d2envlst): void = (ccompenv_incwth_dvarsetenv (env, d2es); dd_ps "dvarset_incwth\n")
fun op_dvarset_getdec (env: !ccompenv): void = let
  val d2es = ccompenv_getdec_dvarsetenv (env)
in
  dd_ps "dvarset_getdec "; dd_d2envset_vt d2es; dd_nl ()
end
fun op_dvarset_add_var (env: !ccompenv, d2v: d2var): void = (ccompenv_add_dvarsetenv_var (env, d2v); dd_ps "dvarset_add_var "; dd_d2var d2v; dd_nl ())
fun op_dvarset_add_env (env: !ccompenv, d2e: d2env): void = (ccompenv_add_dvarsetenv_env (env, d2e); dd_ps "dvarset_add_env "; dd_d2env d2e; dd_nl ())
fun op_dvarset_addlst_if (env: !ccompenv, flvl: int, d2es: d2envlst): void = (ccompenv_addlst_dvarsetenv_if (env, flvl, d2es); dd_ps "dvarset_addlst_if "; dd_int flvl; dd_nl ())
fun op_dvarset_add_tempenver (env: !ccompenv, d2e0: d2env): void = let
  val set = d2envset_vt_add (d2envset_vt_nil (), d2e0)
  val set = ccompenv_dvarsetenv_add_tempenver (env, set)
in
  dd_ps "dvarset_add_tempenver -> "; dd_d2envset_vt set; dd_nl ()
end

fun op_flabset_inc (env: !ccompenv): void = (ccompenv_inc_flabsetenv (env); dd_ps "flabset_inc\n")
fun op_flabset_getdec (env: !ccompenv): void = let
  val fls = ccompenv_getdec_flabsetenv (env)
in
  dd_ps "flabset_getdec "; dd_funlabset_vt fls; dd_nl ()
end
fun op_flabset_add (env: !ccompenv, fl: funlab): void = (ccompenv_add_flabsetenv (env, fl); dd_ps "flabset_add "; dd_funlab fl; dd_nl ())
fun op_flabset_addlst_ifmap (env: !ccompenv, flvl: int, vbmap: vbindmap, fls: List0_vt (funlab)): void = let
  val () = (dd_ps "flabset_addlst_ifmap "; dd_int flvl; dd_ps " "; dd_listvt_funlab (list_vt_copy fls); dd_ps " vbmap="; dd_vbindmap vbmap; dd_nl ())
  val fls1 = ccompenv_addlst_flabsetenv_ifmap (env, flvl, vbmap, fls)
in
  dd_ps "  -> "; dd_listvt_funlab fls1; dd_nl ()
end

fun op_vbindmapenv_inc (env: !ccompenv): void = (ccompenv_inc_vbindmapenv (env); dd_ps "vbindmapenv_inc\n")
fun op_vbindmapenv_getdec (env: !ccompenv): void = let
  val vbm = ccompenv_getdec_vbindmapenv (env)
in
  dd_ps "vbindmapenv_getdec "; dd_vbindmap vbm; dd_nl ()
end
fun op_vbindmapenv_add (env: !ccompenv, d2v: d2var, pmv: primval): void = let
  val () = ccompenv_add_vbindmapenv (env, d2v, pmv)
in
  dd_ps "vbindmapenv_add "; dd_d2var d2v; dd_nl ()
end
fun op_vbindmapenv_find (env: !ccompenv, d2v: d2var): void = let
  val r = ccompenv_find_vbindmapenv (env, d2v)
in
  dd_ps "vbindmapenv_find "; dd_d2var d2v; dd_ps " -> "; dd_optvt_primval r; dd_nl ()
end

fun op_push (env: !ccompenv): (ccompenv_push_v | void) = let
  val (pf | ()) = ccompenv_push (env)
in
  dd_ps "push\n"; (pf | ())
end
fun op_pop (pf: ccompenv_push_v | env: !ccompenv): void = let
  val () = ccompenv_pop (pf | env)
in
  dd_ps "pop\n"
end
fun op_localjoin (pf1: ccompenv_push_v, pf2: ccompenv_push_v | env: !ccompenv): void = let
  val () = ccompenv_localjoin (pf1, pf2 | env)
in
  dd_ps "localjoin\n"
end

fun op_vbindmapall_add (env: !ccompenv, d2v: d2var, pmv: primval): void = let
  val () = ccompenv_add_vbindmapall (env, d2v, pmv)
in
  dd_ps "vbindmapall_add "; dd_d2var d2v; dd_nl ()
end
fun op_vbindmapall_find (env: !ccompenv, d2v: d2var): void = let
  val r = ccompenv_find_vbindmapall (env, d2v)
in
  dd_ps "vbindmapall_find "; dd_d2var d2v; dd_ps " -> "; dd_optvt_primval r; dd_nl ()
end
fun op_vbindmapenvall_add (env: !ccompenv, d2v: d2var, pmv: primval): void = let
  val () = ccompenv_add_vbindmapenvall (env, d2v, pmv)
in
  dd_ps "vbindmapenvall_add "; dd_d2var d2v; dd_nl ()
end

fun op_add_tmpsub (env: !ccompenv, ts: tmpsub): void = (ccompenv_add_tmpsub (env, ts); dd_ps "add_tmpsub\n")
fun op_add_fundec (env: !ccompenv, hfd: hifundec): void = (ccompenv_add_fundec (env, hfd); dd_ps "add_fundec "; dd_d2var (hfd_var hfd); dd_nl ())
fun op_add_fundec2 (env: !ccompenv, hfd2: hifundec2): void = (ccompenv_add_fundec2 (env, hfd2); dd_ps "add_fundec2\n")
fun op_add_impdec (env: !ccompenv, imp: hiimpdec): void = (ccompenv_add_impdec (env, imp); dd_ps "add_impdec "; dd_d2cst (imp_cst imp); dd_nl ())
fun op_add_impdec2 (env: !ccompenv, imp2: hiimpdec2): void = (ccompenv_add_impdec2 (env, imp2); dd_ps "add_impdec2\n")
fun op_add_staload (env: !ccompenv, fenv: filenv): void = (ccompenv_add_staload (env, fenv); dd_ps "add_staload\n")
fun op_add_impdecloc (env: !ccompenv, imp: hiimpdec, sv: s2var, k: int): void = let
  var sub = stasub_make_nil ()
  val () = stasub_add (sub, sv, s2exp_int (k))
  val () = ccompenv_add_impdecloc (env, sub, imp)
  val () = stasub_free (sub)
in
  dd_ps "add_impdecloc "; dd_d2cst (imp_cst imp); dd_nl ()
end
fun op_add_fundecsloc (env: !ccompenv, decarg: s2qualst, hfds: hifundeclst): void = let
  val sub = stasub_make_nil ()
  val () = ccompenv_add_fundecsloc (env, sub, mkfunkind 0, decarg, hfds)
  val () = stasub_free (sub)
in
  dd_ps "add_fundecsloc\n"
end
fun op_add_tmpcstmat (env: !ccompenv, mat: tmpcstmat): void = (ccompenv_add_tmpcstmat (env, mat); dd_ps "add_tmpcstmat\n")
fun op_add_tmpvarmat (env: !ccompenv, mat: tmpvarmat): void = (ccompenv_add_tmpvarmat (env, mat); dd_ps "add_tmpvarmat\n")
fun op_tmpcst_match (env: !ccompenv, d2c: d2cst): void = let
  val r = ccompenv_tmpcst_match (env, d2c, LN_t2mpmarglst ())
in
  dd_ps "tmpcst_match "; dd_d2cst d2c; dd_ps " -> "; dd_tmpcstmat r; dd_nl ()
end
fun op_tmpvar_match (env: !ccompenv, d2v: d2var): void = let
  val r = ccompenv_tmpvar_match (env, d2v, LN_t2mpmarglst ())
in
  dd_ps "tmpvar_match "; dd_d2var d2v; dd_ps " -> "; dd_tmpvarmat r; dd_nl ()
end

fun op_add_tempenver (env: !ccompenv, d2vs: d2varlst): void = (ccompenv_add_tempenver (env, d2vs); dd_ps "add_tempenver\n")
fun op_get_tempenver (env: !ccompenv): void = let
  val d2vs = ccompenv_get_tempenver (env)
in
  dd_ps "get_tempenver "; dd_listvt_d2var d2vs; dd_nl ()
end
fun op_get2_tempenver (env: !ccompenv): void = let
  val d2vs = ccompenv_get2_tempenver (env)
in
  dd_ps "get2_tempenver "; dd_listvt_d2var d2vs; dd_nl ()
end

(* ****** ****** *)
//
// the global lists of the declarations
//
fun op_the_lst_add (k: int, hid: hidecl): void = let
  val () = (
    case+ k of
    | 0 => the_exndeclst_add (hid)
    | 1 => the_saspdeclst_add (hid)
    | 2 => the_extypelst_add (hid)
    | 3 => the_extcodelst_add (hid)
    | 4 => the_staloadlst_add (hid)
    | _ => the_dynloadlst_add (hid)
  ) : void
in
  dd_ps "the_lst_add "; dd_int k; dd_ps " "; fprint_hidecl (dd_out, hid); dd_nl ()
end
fun op_the_lst_get (k: int): void = let
  val hids = (
    case+ k of
    | 0 => the_exndeclst_get ()
    | 1 => the_saspdeclst_get ()
    | 2 => the_extypelst_get ()
    | 3 => the_extcodelst_get ()
    | 4 => the_staloadlst_get ()
    | _ => the_dynloadlst_get ()
  ) : hideclist
in
  dd_ps "the_lst_get "; dd_int k; dd_ps " "; dd_hideclist hids; dd_nl ()
end

(* ****** ****** *)
//
// the free variables / environment of the functions (pats_ccomp_environ.dats)
//
fun op_eval_flablst (fent: funent): void = let
  val fls = funent_eval_flablst (fent)
in
  dd_ps "eval_flablst "; fprint_funlablst (dd_out, fls); dd_ps " fin="; fprint_funlablstopt (dd_out, funent_get_flablst_fin fent); dd_nl ()
end
fun op_eval_d2envlst (fent: funent): void = let
  val d2es = funent_eval_d2envlst (fent)
in
  dd_ps "eval_d2envlst "; fprint_d2envlst (dd_out, d2es); dd_ps " fin="; fprint_d2envlstopt (dd_out, funent_get_d2envlst_fin fent); dd_nl ()
end
fun op_envful (fl: funlab): void = (dd_ps "envful "; dd_funlab fl; dd_ps " -> "; dd_bool (funlab_is_envful fl); dd_nl ())
fun op_fullarg (fl: funlab): void = let
  val hses = funlab_get_type_fullarg (fl)
in
  dd_ps "fullarg "; dd_funlab fl; dd_ps " -> "; fprint_hisexplst (dd_out, hses); dd_nl ()
end
fun op_vbmap_init (fent: funent): void = (funent_varbindmap_initize (fent); dd_ps "vbmap_initize\n")
fun op_vbmap_init2 (fent: funent): void = (funent_varbindmap_initize2 (fent); dd_ps "vbmap_initize2\n")
fun op_vbmap_uninit (fent: funent): void = (funent_varbindmap_uninitize (fent); dd_ps "vbmap_uninitize\n")
fun op_vbmap_find (d2v: d2var): void = let
  val r = the_funent_varbindmap_find (d2v)
in
  dd_ps "vbmap_find "; dd_d2var d2v; dd_ps " -> "; dd_optvt_primval r; dd_nl ()
end

(* ****** ****** *)
//
// the compilation of erased expressions (caseof, looping, trywith, lazyeval, through the doubles of cc1_impl.hats)
//
fun op_comp (env: !ccompenv, hde: hidexp): void = let
  val res = instrseq_make_nil ()
  val () = (dd_ps "comp "; fprint_hidexp (dd_out, hde); dd_nl ())
  val pmv = hidexp_ccomp (env, res, hde)
  val inss = instrseq_get_free (res)
in
  dd_ps "result "; dd_primval pmv; dd_nl (); dd_ps "instrs\n"; dd_instrlst_deep (inss, 1)
end
fun op_comp_ret (env: !ccompenv, tmp: tmpvar, hde: hidexp): void = let
  val res = instrseq_make_nil ()
  val () = (dd_ps "comp_ret "; dd_tmpvar tmp; dd_ps " "; fprint_hidexp (dd_out, hde); dd_nl ())
  val () = hidexp_ccomp_ret (env, res, tmp, hde)
  val inss = instrseq_get_free (res)
in
  dd_ps "instrs\n"; dd_instrlst_deep (inss, 1)
end
fun op_funlablst_add (fl: funlab): void = (the_funlablst_add (fl); dd_ps "funlablst_add "; dd_funlab fl; dd_nl ())
fun op_funlablst_addlst (fls: funlablst): void = (the_funlablst_addlst (fls); dd_ps "funlablst_addlst\n")
fun op_funlablst_get (): void = let
  val fls = the_funlablst_get ()
in
  dd_ps "funlablst_get\n"; dd_funlablst_ents fls; dd_nl ()
end
fun op_dyncstlst_add (d2c: d2cst): void = (the_dyncstlst_add (d2c); dd_ps "dyncstlst_add "; dd_d2cst d2c; dd_nl ())
fun op_dyncstlst_get (): void = (dd_ps "dyncstlst_get "; fprint_d2cstlst (dd_out, the_dyncstlst_get ()); dd_nl ())
fun op_dynconlst_add (d2c: d2con): void = (the_dynconlst_add (d2c); dd_ps "dynconlst_add "; fprint_d2con (dd_out, d2c); dd_nl ())
fun op_dynconlst_get (): void = (dd_ps "dynconlst_get "; fprint_d2conlst (dd_out, the_dynconlst_get ()); dd_nl ())
fun op_toplevel_cells (loc: location, tmp: tmpvar, n: int): void = let
  val p = the_toplevel_getref_tmpvarlst ()
  val q = the_toplevel_getref_primdeclst ()
  val () = (dd_ps "toplevel cells: "; dd_int (len_tmpvarlst (rd_tmpvarlst p)); dd_ps ","; dd_int (len_primdeclst (rd_primdeclst q)))
  val () = wr_tmpvarlst (p, mk_tmpvarlst_n (tmp, n))
  val () = wr_primdeclst (q, mk_primdeclst_n (loc, n+1))
  val () = (dd_ps " -> "; dd_int (len_tmpvarlst (rd_tmpvarlst (the_toplevel_getref_tmpvarlst ())))
    ; dd_ps ","; dd_int (len_primdeclst (rd_primdeclst (the_toplevel_getref_primdeclst ()))); dd_nl ())
in
  ()
end
