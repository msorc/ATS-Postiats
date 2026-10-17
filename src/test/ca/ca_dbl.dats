(* TEST DOUBLES for the emit test (ccomp group A, see PORTING.md "ccomp group A (emit)"; test/ca/ca_gen.py).
   Stand-ins for the functions of the other ccomp modules (pats_ccomp.dats, _tmplab, _tmpvar, _funlab, _funent, _d2env, _util, _print, _environ,
   _hitype) that pats_ccomp_emit{,2,3}.dats call. They are written from the ATS1 sources of src/ (the ATS1 side of the test links the REAL
   modules, so every double is compared with the real thing through the emitted text), except the hitype/hisexp emitters: those are
   doubles on both sides (ca_dbl1.hats is the ATS1 twin), as they are another group's.
   This file is the only one that includes pats_ccomp_gen_dats.hats. *)
(* ****** ****** *)
#include "share/atspre_staload.hats"
(* ****** ****** *)
staload UN = "prelude/SATS/unsafe.sats"
staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"
(* ****** ****** *)
staload "../pats_basics.sats"
staload UT = "../pats_utils.sats"
staload _(*UT*) = "../pats_utils.dats"
staload ERR = "../pats_error.sats"
staload _(*ERR*) = "../pats_error.dats"
staload STMP = "../pats_stamp.sats"
staload LAB = "../pats_label.sats"
staload FIL = "../pats_filename.sats"
staload LOC = "../pats_location.sats"
staload SYM = "../pats_symbol.sats"
staload SYN = "../pats_syntax.sats"
staload "../pats_avlmap.sats"
staload "../pats_staexp2.sats"
staload "../pats_dynexp2.sats"
staload _(*dvar*) = "../pats_dynexp2_dvar.dats"
staload "../pats_histaexp.sats"
staload "../pats_hidynexp.sats"
staload TRENV2 = "../pats_trans2_env.sats"
staload "../pats_ccomp.sats"
(* ****** ****** *)
#include "../pats_ccomp_gen_dats.hats"
(* ****** ****** *)
//
// tmplab
//
implement tmplab_make (loc) = tmplab_new (loc, $STMP.tmplab_stamp_make ())
implement tmplab_get_loc (x) = x.tmplab_loc ()
implement tmplab_get_stamp (x) = x.tmplab_stamp ()
implement fprint_tmplab (out, tl) = {
  val () = fprint_string (out, "tmplab(")
  val () = $STMP.fprint_stamp (out, tmplab_get_stamp (tl))
  val () = fprint_string (out, ")")
}
//
// tmpvar
//
implement tmpvar_make (loc, hse) =
  tmpvar_new (loc, hse, 0, 0, 0, gopt_none{tmpvar}(), 0, $STMP.tmpvar_stamp_make ())
implement tmpvar_make_ref (loc, hse) = tmp where {
  val tmp = tmpvar_make (loc, hse)
  val () = set_tmpvar_ref (tmp, 1)
}
implement tmpvar_make_ret (loc, hse) = tmp where {
  val tmp = tmpvar_make (loc, hse)
  val () = set_tmpvar_ret (tmp, 1)
}
implement tmpvar_inc_tailcal (tmp) = set_tmpvar_ret (tmp, tmpvar_ret (tmp) + 1)
implement tmpvar_get_loc (tmp) = tmp.tmpvar_loc ()
implement tmpvar_get_type (tmp) = tmpvar_type (tmp)
implement tmpvar_isref (tmp) = tmpvar_ref (tmp) > 0
implement tmpvar_isret (tmp) = tmpvar_ret (tmp) > 0
implement tmpvar_get_topknd (tmp) = tmpvar_topknd (tmp)
implement tmpvar_get_origin (tmp) = tmpvar_origin (tmp)
implement tmpvar_get_suffix (tmp) = tmpvar_suffix (tmp)
implement tmpvar_get_stamp (tmp) = tmp.tmpvar_stamp ()
implement tmpvar_get_tailcal (tmp) = tmpvar_ret (tmp)
implement tmpvar_set_type (tmp, hse) = set_tmpvar_type (tmp, hse)
implement tmpvar_set_ref (tmp, k) = set_tmpvar_ref (tmp, k)
implement tmpvar_set_ret (tmp, k) = set_tmpvar_ret (tmp, k)
implement tmpvar_set_topknd (tmp, k) = set_tmpvar_topknd (tmp, k)
implement tmpvar_set_origin (tmp, opt) = set_tmpvar_origin (tmp, opt)
implement tmpvar_set_suffix (tmp, k) = set_tmpvar_suffix (tmp, k)
implement fprint_tmpvar (out, tmp) = {
  val () = fprint_string (out, "tmp")
  val () = if tmpvar_isref (tmp) then fprint_string (out, "ref")
  val () = if tmpvar_isret (tmp) then fprint_string (out, "ret")
  val () = fprint_string (out, "(")
  val () = $STMP.fprint_stamp (out, tmpvar_get_stamp (tmp))
  val () = fprint_string (out, ")")
}
implement tmpvar_is_void (tmp) = hisexp_is_void (tmpvar_get_type (tmp))
//
// d2env
//
implement d2env_get_var (x) = $effmask_all (x.d2env_var ())
implement d2env_get_type (x) = $effmask_all (x.d2env_type ())
implement d2env_make (d2v, hse) = d2env_new (d2v, hse)
implement fprint_d2env (out, d2e) = {
  val () = fprint_d2var (out, d2env_get_var (d2e))
  val () = fprint_string (out, "(")
  val () = fprint_hisexp (out, d2env_get_type (d2e))
  val () = fprint_string (out, ")")
}
fn fprint_d2env_ (out: FILEref, d2e: d2env): void = fprint_d2env (out, d2e)
implement fprint_d2envlst (out, d2es) = $UT.fprintlst<d2env> (out, d2es, ", ", fprint_d2env_)
//
// funlab
//
implement funlab_make (name, level, hse, fcopt, qopt, sopt, t2mas, stamp) = let
  val fc = (
    case+ fcopt of
    | ~Some_vt (fc) => fc
    | ~None_vt () => (
      case+ hisexp_node_view (hse.hisexp_node ()) of
      | ~HSEfun (fc, _, _) => fc
      | v => (hisexp_node_view_free (v); FUNCLOfun ())
      )
  ) : funclo
in
  funlab_new (name, level, fc, hse, ~1, qopt, sopt, 0, gopt_none{funlab}(), 0, t2mas, gopt_none{funent}(), stamp)
end
implement funlab_get_name (x) = funlab_name (x)
implement funlab_get_level (x) = funlab_level (x)
implement funlab_get_tmpknd (x) = funlab_tmpknd (x)
implement funlab_set_tmpknd (x, k) = set_funlab_tmpknd (x, k)
implement funlab_get_d2copt (x) = funlab_d2copt (x)
implement funlab_get_d2vopt (x) = funlab_d2vopt (x)
implement funlab_get_type (x) = funlab_type (x)
implement funlab_get_funclo (x) = funlab_funclo (x)
implement funlab_get_ncopy (x) = funlab_ncopy (x)
implement funlab_set_ncopy (x, k) = set_funlab_ncopy (x, k)
implement funlab_get_origin (x) = funlab_origin (x)
implement funlab_set_origin (x, o) = set_funlab_origin (x, o)
implement funlab_get_suffix (x) = funlab_suffix (x)
implement funlab_set_suffix (x, k) = set_funlab_suffix (x, k)
implement funlab_get_tmparg (x) = funlab_tmparg (x)
implement funlab_get_funent (x) = funlab_funent (x)
implement funlab_set_funent (x, o) = set_funlab_funent (x, o)
implement funlab_get_stamp (x) = $effmask_all (x.funlab_stamp ())
implement funlab_get_type_arg (flab) = let
  val hse = funlab_get_type (flab)
in
  case+ hisexp_node_view (hse.hisexp_node ()) of
  | ~HSEfun (_, arg, _) => arg
  | v => let
      val () = hisexp_node_view_free (v)
      val () = assertloc (false)
    in $ERR.abort<hisexplst> () end
end
implement funlab_get_type_res (flab) = let
  val hse = funlab_get_type (flab)
in
  case+ hisexp_node_view (hse.hisexp_node ()) of
  | ~HSEfun (_, _, res) => res
  | v => let
      val () = hisexp_node_view_free (v)
      val () = assertloc (false)
    in $ERR.abort<hisexp> () end
end
implement fprint_funlab (out, flab) = {
  val () = fprint_string (out, funlab_get_name (flab))
  val () = fprint_string (out, "$")
  val () = fprint_int (out, funlab_get_suffix (flab))
  val () = fprint_string (out, "(level=")
  val () = fprint_int (out, funlab_get_level (flab))
  val () = fprint_string (out, ")")
}
fn fprint_funlab_ (out: FILEref, x: funlab): void = fprint_funlab (out, x)
implement fprint_funlablst (out, fls) = $UT.fprintlst<funlab> (out, fls, ", ", fprint_funlab_)
// the C name that pats_histaexp_funlab.dats calls
extern fun funlab_get_name_c (flab: funlab): string = "ext#patsopt_funlab_get_name"
implement funlab_get_name_c (flab) = funlab_get_name (flab)
//
// funent (the closure of [funent_eval_*] is NOT computed: the cases set the _fin fields, see PORTING.md)
//
implement funent_make (loc, flab, imparg, tmparg, tmpsub, tmpret, fls0, d2es, vbmap, inss, tmplst) =
  funent_new (loc, flab, imparg, tmparg, tmpsub, tmpret, fls0, gopt_none{funlablst}(), d2es, gopt_none{d2envlst}(), vbmap, inss, tmplst, glist_nil{funlab}())
implement funent_get_loc (x) = x.funent_loc ()
implement funent_get_lab (x) = funent_lab (x)
implement funent_get_level (x) = funlab_get_level (funent_lab (x))
implement funent_get_imparg (x) = funent_imparg (x)
implement funent_get_tmparg (x) = funent_tmparg (x)
implement funent_get_tmpsub (x) = funent_tmpsub (x)
implement funent_get_tmpret (x) = funent_tmpret (x)
implement funent_get_flablst (x) = funent_flablst (x)
implement funent_get_flablst_fin (x) = funent_flablst_fin (x)
implement funent_get_d2envlst (x) = funent_d2envlst (x)
implement funent_get_d2envlst_fin (x) = funent_d2envlst_fin (x)
implement funent_get_vbindmap (x) = funent_vbindmap (x)
implement funent_get_instrlst (x) = funent_instrlst (x)
implement funent_get_tmpvarlst (x) = funent_tmpvarlst (x)
implement funent_get_fnxlablst (x) = funent_fnxlablst (x)
implement funent_set_tmpsub (x, o) = set_funent_tmpsub (x, o)
implement funent_set_flablst_fin (x, o) = set_funent_flablst_fin (x, o)
implement funent_set_d2envlst_fin (x, o) = set_funent_d2envlst_fin (x, o)
implement funent_set_fnxlablst (x, fls) = set_funent_fnxlablst (x, fls)
implement funent_is_tmplt (x) = glist_is_cons (funent_tmparg (x))
implement funent_eval_flablst (x) = let
  val opt = funent_flablst_fin (x)
in
  if gopt_is_some (opt) then gopt_unsome<funlablst> (opt) else $ERR.abort<funlablst> ()
end
implement funent_eval_d2envlst (x) = let
  val opt = funent_d2envlst_fin (x)
in
  if gopt_is_some (opt) then gopt_unsome<d2envlst> (opt) else $ERR.abort<d2envlst> ()
end
implement funlab_is_envful (flab) = let
  val opt = funlab_get_funent (flab)
  val d2es = (
    if gopt_is_some (opt) then funent_eval_d2envlst (gopt_unsome<funent> (opt)) else glist_nil{d2env}()
  ) : d2envlst
in
  glist_is_cons (d2es)
end
implement funlab_get_type_fullarg (flab) = let
  fun aux (d2es: d2envlst, hses: hisexplst): hisexplst =
    if glist_is_cons (d2es) then
      glist_cons<hisexp> (d2env_get_type (glist_head<d2env> (d2es)), aux (glist_tail<d2env> (d2es), hses))
    else hses
  val opt = funlab_get_funent (flab)
  val d2es = (
    if gopt_is_some (opt) then funent_eval_d2envlst (gopt_unsome<funent> (opt)) else glist_nil{d2env}()
  ) : d2envlst
  val hses = funlab_get_type_arg (flab)
in
  aux (d2es, hses)
end
//
// the variable bindings of the function being emitted (a list of (d2var, primval), the newest first)
//
val the_vbmap = the_garena_alloc (sizeof<ptr>)
val () = $UN.ptr0_set<ptr> (the_vbmap, the_null_ptr)
fn vbmap_get (): glist(@(d2var, primval)) = $UN.ptr0_get<glist(@(d2var, primval))> (the_vbmap)
fn vbmap_set (xs: glist(@(d2var, primval))): void = $UN.ptr0_set<glist(@(d2var, primval))> (the_vbmap, xs)
implement funent_varbindmap_initize (fent0) = let
  fun auxmap (vbs: List0_vt(@(d2var, primval))): void =
    case+ vbs of
    | ~list_vt_cons (vb, vbs) => (vbmap_set (glist_cons<@(d2var, primval)> (vb, vbmap_get ())); auxmap (vbs))
    | ~list_vt_nil () => ()
  fun auxenv (loc0: location, i: int, d2es: d2envlst): void =
    if glist_is_cons (d2es) then let
      val d2e = glist_head<d2env> (d2es)
      val argenv = primval_argenv (loc0, d2env_get_type (d2e), i)
      val () = vbmap_set (glist_cons<@(d2var, primval)> (@(d2env_get_var (d2e), argenv), vbmap_get ()))
    in auxenv (loc0, i+1, glist_tail<d2env> (d2es)) end
    else ()
  val loc0 = funent_get_loc (fent0)
  val () = auxmap (d2varmap_listize<primval> (funent_get_vbindmap (fent0)))
in
  auxenv (loc0, 0, funent_eval_d2envlst (fent0))
end
implement funent_varbindmap_initize2 (fent0) = let
  fun auxlst (fls: funlablst): void =
    if glist_is_cons (fls) then let
      val opt = funlab_get_funent (glist_head<funlab> (fls))
      val () = if gopt_is_some (opt) then funent_varbindmap_initize (gopt_unsome<funent> (opt))
    in auxlst (glist_tail<funlab> (fls)) end
    else ()
  val fls0 = funent_get_fnxlablst (fent0)
in
  if glist_is_cons (fls0) then auxlst (glist_tail<funlab> (fls0)) else ()
end
implement funent_varbindmap_uninitize (fent0) = vbmap_set (glist_nil{@(d2var, primval)}())
implement the_funent_varbindmap_find (d2v) = let
  fun find (xs: glist(@(d2var, primval))): Option_vt (primval) =
    if glist_is_cons (xs) then let
      val x = glist_head<@(d2var, primval)> (xs)
    in
      if compare_d2var_d2var (x.0, d2v) = 0 then Some_vt (x.1) else find (glist_tail<@(d2var, primval)> (xs))
    end else None_vt ()
in
  find (vbmap_get ())
end
//
// the hiimpdec cells (pats_ccomp.dats)
//
implement hiimpdec_get_instrlstopt (imp) = $UN.cast{gopt(instrlst)} (hiimpdec_instrlst (imp))
implement hiimpdec_set_instrlstopt (imp, opt) = set_hiimpdec_instrlst (imp, $UN.cast{hiinstrlstopt} (opt))
implement hiimpdec_get_funlabopt (imp) = $UN.cast{gopt(funlab)} (hiimpdec_funlab (imp))
implement hiimpdec_set_funlabopt (imp, opt) = set_hiimpdec_funlab (imp, $UN.cast{hifunlabopt} (opt))
//
// util
//
implement primval_is_void (pmv) = hisexp_is_void (pmv.primval_type ())
implement primval_is_top (pmv) = primval_node_is_PMVtop (pmv.primval_node ())
implement patckont_is_none (fail) = patckont_is_PTCKNTnone (fail)
implement primval_argenv (loc, hse, nenv) = primval_new (loc, hse, primval_node_PMVargenv (nenv))
implement primval_ptrof (loc, hse, pmv) = primval_new (loc, hse, primval_node_PMVptrof (pmv))
//
// the hitype / hisexp emitters (doubles on both sides): text = a marker and the printout of the hisexp
//
implement hisexp_typize (flag, hse) = let
  val p = the_garena_alloc (sizeof<ptr> + sizeof<ptr>)
  val () = $UN.ptr0_set<int> (p, flag)
  val () = $UN.ptr0_set<hisexp> (ptr0_add_gint<byte> (p, 8), hse)
in
  $UN.cast{hitype} (p)
end
implement fprint_hitype (out, x) = {
  val p = $UN.cast{ptr} (x)
  val () = fprint_string (out, "HIT[")
  val () = fprint_int (out, $UN.ptr0_get<int> (p))
  val () = fprint_string (out, ";")
  val () = fprint_hisexp (out, $UN.ptr0_get<hisexp> (ptr0_add_gint<byte> (p, 8)))
  val () = fprint_string (out, "]")
}
implement print_hitype (x) = fprint_hitype (stdout_ref, x)
implement prerr_hitype (x) = fprint_hitype (stderr_ref, x)
implement fprint_hitypelst (out, xs) = ()
implement emit_hitype (out, hit) = {
  val () = fprint_string (out, "{")
  val () = fprint_hitype (out, hit)
  val () = fprint_string (out, "}")
}
fn fprint_hname (out: FILEref, hse: hisexp): void = {
  val () = fprint_string (out, hitnam_name (hisexp_name (hse)))
  val () = fprint_string (out, " ")
}
implement emit_hisexp (out, hse) = {
  val () = fprint_string (out, "{HSE ")
  val () = fprint_hname (out, hse)
  val () = fprint_hisexp (out, hse)
  val () = fprint_string (out, "}")
}
implement emit_hisexp_sel (out, hse) = {
  val () = fprint_string (out, "{SEL ")
  val () = fprint_hname (out, hse)
  val () = fprint_hisexp (out, hse)
  val () = fprint_string (out, "}")
}
implement emit_hisexplst_sep (out, hses, sep) = let
  fun loop (hses: hisexplst, i: int): void =
    if glist_is_cons (hses) then let
      val () = if i > 0 then fprint_string (out, sep)
      val () = emit_hisexp (out, glist_head<hisexp> (hses))
    in loop (glist_tail<hisexp> (hses), i+1) end
    else ()
in
  loop (hses, 0)
end
//
// the printers (pats_ccomp_print.dats)
//
fn fprint_primval_ (out: FILEref, x: primval): void = fprint_primval (out, x)
fn fprint_primlab_ (out: FILEref, x: primlab): void = fprint_primlab (out, x)
fn fprint_labprimval_ (out: FILEref, lx: labprimval): void = {
  val () = $LAB.fprint_label (out, lx.labprimval_lab ())
  val () = fprint_string (out, "=")
  val () = fprint_primval (out, lx.labprimval_elt ())
}
implement fprint_primvalist (out, xs) = $UT.fprintlst<primval> (out, xs, ", ", fprint_primval_)
implement fprint_primlablst (out, xs) = $UT.fprintlst<primlab> (out, xs, ", ", fprint_primlab_)
implement fprint_labprimvalist (out, xs) = $UT.fprintlst<labprimval> (out, xs, ", ", fprint_labprimval_)
implement fprint_primlab (out, x) = (
  case+ primlab_node_view (x.primlab_node ()) of
  | ~PMLlab (l) => {
      val () = fprint_string (out, "PMLlab(")
      val () = $LAB.fprint_label (out, l)
      val () = fprint_string (out, ")")
    }
  | ~PMLind (pmvs) => {
      val () = fprint_string (out, "PMLind(")
      val () = fprint_primvalist (out, pmvs)
      val () = fprint_string (out, ")")
    }
)
implement fprint_tmpsub (out, xs) = let
  fun loop (out: FILEref, xs: tmpsub, i: int): void =
    case+ tmpsub_view (xs) of
    | ~TMPSUBcons (s2v, s2e, xs) => let
        val () = if i > 0 then fprint_string (out, "; ")
        val () = fprint_s2var (out, s2v)
        val () = fprint_string (out, " -> ")
        val () = fprint_s2exp (out, s2e)
      in loop (out, xs, i+1) end
    | ~TMPSUBnil () => ()
in
  loop (out, xs, 0)
end
implement fprint_tmpsubopt (out, opt) = (
  case+ gopt_view (opt) of
  | ~GOsome (tsub) => (fprint_string (out, "Some("); fprint_tmpsub (out, tsub); fprint_string (out, ")"))
  | ~GOnone () => fprint_string (out, "None()")
)
implement fprint_tmprimval (out, x) = (
  case+ tmprimval_view (x) of
  | ~TPMVnone (pmv) => (fprint_string (out, "TPMVnone("); fprint_primval (out, pmv); fprint_string (out, ")"))
  | ~TPMVsome (tmp, pmv) => (
      fprint_string (out, "TPMVsome("); fprint_tmpvar (out, tmp); fprint_string (out, "<-"); fprint_primval (out, pmv); fprint_string (out, ")")
    )
)
implement fprint_tmpmovlst (out, xs) = let
  fun fpr (out: FILEref, x: tmpmov): void = {
    val () = fprint_tmpvar (out, x.tmpmov_dst ())
    val () = fprint_string (out, "<-")
    val () = fprint_tmprimval (out, x.tmpmov_src ())
  }
in
  $UT.fprintlst<tmpmov> (out, xs, ", ", fpr)
end
implement fprint_patck (out, x) = (
  case+ patck_view (x) of
  | ~PATCKcon (d2c) => (fprint_string (out, "PATCKcon("); fprint_d2con (out, d2c); fprint_string (out, ")"))
  | ~PATCKint (i) => (fprint_string (out, "PATCKint("); fprint_int (out, i); fprint_string (out, ")"))
  | ~PATCKbool (b) => (fprint_string (out, "PATCKbool("); fprint_bool (out, b); fprint_string (out, ")"))
  | ~PATCKchar (c) => (fprint_string (out, "PATCKchar("); fprint_char (out, c); fprint_string (out, ")"))
  | ~PATCKfloat (f) => (fprint_string (out, "PATCKfloat("); fprint_double (out, f); fprint_string (out, ")"))
  | ~PATCKstring (str) => (fprint_string (out, "PATCKstring("); fprint_string (out, str); fprint_string (out, ")"))
  | ~PATCKi0nt (tok) => (fprint_string (out, "PATCKi0nt("); $SYN.fprint_i0nt (out, tok); fprint_string (out, ")"))
  | ~PATCKf0loat (tok) => (fprint_string (out, "PATCKf0loat("); $SYN.fprint_f0loat (out, tok); fprint_string (out, ")"))
)
implement fprint_patckont (out, x) = (
  case+ patckont_view (x) of
  | ~PTCKNTnone () => fprint_string (out, "PTCKNTnone()")
  | ~PTCKNTtmplab (tl) => (fprint_string (out, "PTCKNTtmplab("); fprint_tmplab (out, tl); fprint_string (out, ")"))
  | ~PTCKNTtmplabint (tl, i) => {
      val () = fprint_string (out, "PTCKNTtmplabint(")
      val () = fprint_tmplab (out, tl)
      val () = fprint_string (out, ", ")
      val () = fprint_int (out, i)
      val () = fprint_string (out, ")")
    }
  | ~PTCKNTtmplabmov (tl, tmvlst) => {
      val () = fprint_string (out, "PTCKNTtmplabmov(")
      val () = fprint_tmplab (out, tl)
      val () = fprint_string (out, "; ")
      val () = fprint_tmpmovlst (out, tmvlst)
      val () = fprint_string (out, ")")
    }
  | ~PTCKNTcaseof_fail (loc) => fprint_string (out, "PTCKNTcaseof_fail()")
  | ~PTCKNTfunarg_fail (loc, fl) => fprint_string (out, "PTCKNTfunarg_fail()")
  | ~PTCKNTraise (tmp, pmv) => {
      val () = fprint_string (out, "PTCKNTraise(")
      val () = fprint_tmpvar (out, tmp)
      val () = fprint_string (out, ", ")
      val () = fprint_primval (out, pmv)
      val () = fprint_string (out, ")")
    }
)
fn fprint_tmpcstmat_kind (out: FILEref, opt: tmpcstmat): void = let
  val knd = (
    case+ tmpcstmat_view (opt) of
    | ~TMPCSTMATnone () => 0 | ~TMPCSTMATsome _ => 1 | ~TMPCSTMATsome2 _ => 2
  ) : int
in fprint_int (out, knd) end
fn fprint_tmpvarmat_kind (out: FILEref, opt: tmpvarmat): void = let
  val knd = (
    case+ tmpvarmat_view (opt) of
    | ~TMPVARMATnone () => 0 | ~TMPVARMATsome _ => 1 | ~TMPVARMATsome2 _ => 2
  ) : int
in fprint_int (out, knd) end
implement fprint_primval (out, x) = let
  macdef prstr (s) = fprint_string (out, ,(s))
in
  case+ primval_node_view (x.primval_node ()) of
  | ~PMVtmp (tmp) => (prstr "PMVtmp("; fprint_tmpvar (out, tmp); prstr ")")
  | ~PMVtmpref (tmp) => (prstr "PMVtmpref("; fprint_tmpvar (out, tmp); prstr ")")
  | ~PMVarg (n) => (prstr "PMVarg("; fprint_int (out, n); prstr ")")
  | ~PMVargref (n) => (prstr "PMVargref("; fprint_int (out, n); prstr ")")
  | ~PMVargtmpref (n) => (prstr "PMVargtmpref("; fprint_int (out, n); prstr ")")
  | ~PMVargenv (n) => (prstr "PMVargenv("; fprint_int (out, n); prstr ")")
  | ~PMVcst (d2c) => (prstr "PMVcst("; fprint_d2cst (out, d2c); prstr ")")
  | ~PMVenv (d2v) => (prstr "PMVenv("; fprint_d2var (out, d2v); prstr ")")
  | ~PMVint (i) => (prstr "PMVint("; fprint_int (out, i); prstr ")")
  | ~PMVintrep (rep) => (prstr "PMVintrep("; fprint_string (out, rep); prstr ")")
  | ~PMVbool (b) => (prstr "PMVbool("; fprint_bool (out, b); prstr ")")
  | ~PMVchar (c) => {
      val () = prstr "PMVchar("
      val () = (
        if isprint_char (c) then fprint_char (out, c)
        else (prstr "int("; fprint_int (out, $UN.cast{int}(c)); prstr ")")
      ) : void
      val () = prstr ")"
    }
  | ~PMVfloat (f) => (prstr "PMVfloat("; fprint_double (out, f); prstr ")")
  | ~PMVstring (str) => (prstr "PMVstring("; fprint_string (out, str); prstr ")")
  | ~PMVi0nt (tok) => (prstr "PMVi0nt("; $SYN.fprint_i0nt (out, tok); prstr ")")
  | ~PMVf0loat (tok) => (prstr "PMVf0loat("; $SYN.fprint_f0loat (out, tok); prstr ")")
  | ~PMVcstsp (cst) => (
      case+ primcstsp_view (cst) of
      | ~PMCSTSPmyfil (fil) => (prstr "$myfilename("; $FIL.fprint_filename_full (out, fil); prstr ")")
      | ~PMCSTSPmyloc (loc) => (prstr "$mylocation("; $LOC.fprint_location (out, loc); prstr ")")
      | ~PMCSTSPmyfun (flab) => (prstr "$myfunction("; fprint_funlab (out, flab); prstr ")")
    )
  | ~PMVtyrep (hse) => (prstr "PMVtyrep("; fprint_hisexp (out, hse); prstr ")")
  | ~PMVsizeof (hse) => (prstr "PMVsizeof("; fprint_hisexp (out, hse); prstr ")")
  | ~PMVtop () => prstr "PMVtop()"
  | ~PMVempty () => prstr "PMVempty()"
  | ~PMVextval (name) => (prstr "PMVextval("; fprint_string (out, name); prstr ")")
  | ~PMVcastfn (d2c, arg) => (prstr "PMVcastfn("; fprint_d2cst (out, d2c); prstr ", "; fprint_primval (out, arg); prstr ")")
  | ~PMVselcon (pmv, hse_sum, lab) => {
      val () = prstr "PMVselcon("
      val () = fprint_primval (out, pmv)
      val () = prstr "; "
      val () = fprint_hisexp (out, hse_sum)
      val () = prstr "; "
      val () = $LAB.fprint_label (out, lab)
      val () = prstr ")"
    }
  | ~PMVselect (pmv, hse_sel, pml) => {
      val () = prstr "PMVselect("
      val () = fprint_primval (out, pmv)
      val () = prstr "; "
      val () = fprint_hisexp (out, hse_sel)
      val () = prstr "; "
      val () = fprint_primlab (out, pml)
      val () = prstr ")"
    }
  | ~PMVselect2 (pmv, hse_sel, pmls) => {
      val () = prstr "PMVselect2("
      val () = fprint_primval (out, pmv)
      val () = prstr "; "
      val () = fprint_hisexp (out, hse_sel)
      val () = prstr "; "
      val () = fprint_primlablst (out, pmls)
      val () = prstr ")"
    }
  | ~PMVselptr (pmv, hse_sel, pmls) => {
      val () = prstr "PMVselptr("
      val () = fprint_primval (out, pmv)
      val () = prstr "; "
      val () = fprint_hisexp (out, hse_sel)
      val () = prstr "; "
      val () = fprint_primlablst (out, pmls)
      val () = prstr ")"
    }
  | ~PMVptrof (pmv) => (prstr "PMVptrof("; fprint_primval (out, pmv); prstr ")")
  | ~PMVptrofsel (pmv, hse_rt, pmls) => {
      val () = prstr "PMVptrofsel("
      val () = fprint_primval (out, pmv)
      val () = prstr "; "
      val () = fprint_hisexp (out, hse_rt)
      val () = prstr "; "
      val () = fprint_primlablst (out, pmls)
      val () = prstr ")"
    }
  | ~PMVvararg (pmvs) => (prstr "PMVvararg("; fprint_primvalist (out, pmvs); prstr ")")
  | ~PMVrefarg (knd, freeknd, pmv) => {
      val () = prstr "PMVrefarg("
      val () = fprint_int (out, knd)
      val () = prstr "; "
      val () = fprint_int (out, freeknd)
      val () = prstr "; "
      val () = fprint_primval (out, pmv)
      val () = prstr ")"
    }
  | ~PMVfunlab (flab) => (prstr "PMVfunlab("; fprint_funlab (out, flab); prstr ")")
  | ~PMVcfunlab (knd, flab) => {
      val () = prstr "PMVcfunlab("
      val () = prstr "knd="
      val () = fprint_int (out, knd)
      val () = prstr "; flab="
      val () = fprint_funlab (out, flab)
      val () = prstr ")"
    }
  | ~PMVd2vfunlab (d2v, flab) => {
      val () = prstr "PMVd2vfunlab("
      val () = prstr "d2v="
      val () = fprint_d2var (out, d2v)
      val () = prstr ", flab="
      val () = fprint_funlab (out, flab)
      val () = prstr ")"
    }
  | ~PMVlamfix (knd, pmv) => {
      val () = prstr "PMVlamfix("
      val () = (
        if gopt_is_some (knd) then (
          prstr "knd=fix("; fprint_d2var (out, gopt_unsome<d2var> (knd)); prstr ")"
        ) else prstr "knd=lam"
      ) : void
      val () = prstr "; fun="
      val () = fprint_primval (out, pmv)
      val () = prstr ")"
    }
  | ~PMVtmpltcst (d2c, t2mas) => {
      val () = prstr "PMVtmpltcst("
      val () = fprint_d2cst (out, d2c)
      val () = prstr "<"
      val () = fpprint_t2mpmarglst (out, t2mas)
      val () = prstr ">"
      val () = prstr ")"
    }
  | ~PMVtmpltvar (d2v, t2mas) => {
      val () = prstr "PMVtmpltvar("
      val () = fprint_d2var (out, d2v)
      val () = prstr "<"
      val () = fpprint_t2mpmarglst (out, t2mas)
      val () = prstr ">"
      val () = prstr ")"
    }
  | ~PMVtmpltcstmat (d2c, t2mas, mat) => {
      val () = prstr "PMVtmpltcstmat["
      val () = fprint_tmpcstmat_kind (out, mat)
      val () = prstr "]("
      val () = fprint_d2cst (out, d2c)
      val () = prstr "<"
      val () = fpprint_t2mpmarglst (out, t2mas)
      val () = prstr ">"
      val () = prstr ")"
    }
  | ~PMVtmpltvarmat (d2v, t2mas, mat) => {
      val () = prstr "PMVtmpltvarmat["
      val () = fprint_tmpvarmat_kind (out, mat)
      val () = prstr "]("
      val () = fprint_d2var (out, d2v)
      val () = prstr "<"
      val () = fpprint_t2mpmarglst (out, t2mas)
      val () = prstr ">"
      val () = prstr ")"
    }
  | ~PMVerror () => prstr "PMVerror()"
end
fn fprint_instr_ (out: FILEref, x: instr): void = fprint_instr (out, x)
implement fprint_instrlst (out, xs) = {
  val () = $UT.fprintlst<instr> (out, xs, "\n", fprint_instr_)
  val () = fprint_newline (out)
}
fn fprint_primdec_ (out: FILEref, x: primdec): void = fprint_primdec (out, x)
fn fpr_hifundec_ (out: FILEref, hfd: hifundec): void = fprint_d2var (out, hfd.hifundec_var ())
fn fpr_hivaldec_ (out: FILEref, hvd: hivaldec): void = fprint_hipat (out, hvd.hivaldec_pat ())
fn fpr_hivardec_ (out: FILEref, hvd: hivardec): void = fprint_d2var (out, hvd.hivardec_dvar_ptr ())
fn fpr_s2explst_ (out: FILEref, xs: s2explst): void = fprint_s2explst (out, xs)
implement fprint_primdeclst (out, pmds) = {
  val () = $UT.fprintlst<primdec> (out, pmds, "\n", fprint_primdec_)
  val () = fprint_newline (out)
}
implement fprint_primdec (out, x) = let
  macdef prstr (s) = fprint_string (out, ,(s))
  val sep = ", "
in
  case+ primdec_node_view (x.primdec_node ()) of
  | ~PMDnone () => prstr "PMDnone()"
  | ~PMDlist (pmds) => (prstr "PMDlist(\n"; fprint_primdeclst (out, pmds); prstr ")")
  | ~PMDsaspdec (d2c) => (prstr "PMDsaspdec("; fprint_s2cst (out, d2c.s2aspdec_cst ()); prstr ")")
  | ~PMDextvar (name, inss) => (prstr "PMDextvar("; fprint_string (out, name); prstr ")")
  | ~PMDdatdecs (s2cs) => (prstr "PMDdatdecs("; fprint_s2cstlst (out, s2cs); prstr ")")
  | ~PMDexndecs (d2cs) => (prstr "PMDexndecs("; fprint_d2conlst (out, d2cs); prstr ")")
  | ~PMDimpdec (imp) => {
      val () = prstr "PMDimpdec("
      val () = fprint_d2cst (out, imp.hiimpdec_cst ())
      val () = prstr "; imparg="
      val () = fprint_s2varlst (out, imp.hiimpdec_imparg ())
      val () = prstr "; tmparg="
      val () = $UT.fprintlst<s2explst> (out, imp.hiimpdec_tmparg (), "; ", fpr_s2explst_)
      val () = prstr ")"
    }
  | ~PMDfundecs (knd, decarg, hfds) => {
      val () = prstr "PMDfundecs("
      val () = fprint_funkind (out, knd)
      val () = prstr "; "
      val () = fprint_s2qualst (out, decarg)
      val () = prstr "; "
      val () = $UT.fprintlst<hifundec> (out, hfds, sep, fpr_hifundec_)
      val () = prstr ")"
    }
  | ~PMDvaldecs (knd, hvds, inss) => {
      val () = prstr "PMDvaldecs("
      val () = fprint_valkind (out, knd)
      val () = prstr "; "
      val () = $UT.fprintlst<hivaldec> (out, hvds, sep, fpr_hivaldec_)
      val () = prstr ")"
    }
  | ~PMDvaldecs_rec (knd, hvds, inss) => {
      val () = prstr "PMDvaldecs_rec("
      val () = fprint_valkind (out, knd)
      val () = prstr "; "
      val () = $UT.fprintlst<hivaldec> (out, hvds, sep, fpr_hivaldec_)
      val () = prstr ")"
    }
  | ~PMDvardecs (hvds, inss) => {
      val () = prstr "PMDvardecs("
      val () = $UT.fprintlst<hivardec> (out, hvds, sep, fpr_hivardec_)
      val () = prstr ")"
    }
  | ~PMDinclude (knd, pmds) => {
      val () = prstr "PMDinclude("
      val () = fprint_int (out, knd)
      val () = prstr "\n"
      val () = fprint_primdeclst (out, pmds)
      val () = prstr ")"
    }
  | ~PMDstaload (hid) => {
      val-~HIDstaload (idopt, cfil, _, _, _) = hidecl_node_view (hid.hidecl_node ())
      val () = prstr "PMDstaload("
      val () = (if gopt_is_some (idopt) then $SYM.fprint_symbol (out, gopt_unsome<symbol> (idopt)))
      val () = (if gopt_is_some (idopt) then prstr " = ")
      val () = $FIL.fprint_filename_full (out, cfil)
      val () = prstr ")"
    }
  | ~PMDstaloadloc (pfil, nspace, pmds) => {
      val () = prstr "PMDstaloadloc("
      val () = $FIL.fprint_filename_full (out, pfil)
      val () = $SYM.fprint_symbol (out, nspace)
      val () = prstr " = (*primdeclist*)"
      val () = prstr ")"
    }
  | ~PMDdynload (hid) => {
      val-~HIDdynload (fil) = hidecl_node_view (hid.hidecl_node ())
      val () = prstr "PMDdynload("
      val () = $FIL.fprint_filename_full (out, fil)
      val () = prstr ")"
    }
  | ~PMDlocal (pmds_head, pmds_body) => (prstr "PMDlocal("; fprint_string (out, "..."); prstr ")")
end
implement fprint_instr (out, x) = let
  macdef prstr (str) = fprint_string (out, ,(str))
in
  case+ instr_node_view (x.instr_node ()) of
  | ~INSfunlab (fl) => (prstr "INSfunlab("; fprint_funlab (out, fl); prstr ")")
  | ~INStmplab (tl) => (prstr "INStmplab("; fprint_tmplab (out, tl); prstr ")")
  | ~INScomment (str) => (prstr "INScomment("; fprint_string (out, str); prstr ")")
  | ~INSmove_val (tmp, pmv) => (prstr "INSmove_val("; fprint_tmpvar (out, tmp); prstr " <- "; fprint_primval (out, pmv); prstr ")")
  | ~INSpmove_val (tmp, pmv) => (prstr "INSpmove_val("; fprint_tmpvar (out, tmp); prstr " <- "; fprint_primval (out, pmv); prstr ")")
  | ~INSmove_arg_val (i, pmv) => (prstr "INSmove_arg_val("; prstr "arg("; fprint_int (out, i); prstr ")"; prstr " <- "; fprint_primval (out, pmv); prstr ")")
  | ~INSfcall (tmpret, hde_fun, hse_fun, hdes_arg) => {
      val () = prstr "INSfcall("
      val () = fprint_tmpvar (out, tmpret)
      val () = prstr " <- "
      val () = fprint_primval (out, hde_fun)
      val () = prstr "("
      val () = fprint_hisexp (out, hse_fun)
      val () = prstr "; "
      val () = fprint_primvalist (out, hdes_arg)
      val () = prstr "))"
    }
  | ~INSfcall2 (tmpret, flab, ntl, hse_fun, hdes_arg) => {
      val () = prstr "INSfcall2("
      val () = fprint_tmpvar (out, tmpret)
      val () = prstr " <- "
      val () = fprint_funlab (out, flab)
      val () = prstr "("
      val () = fprint_int (out, ntl)
      val () = prstr "; "
      val () = fprint_hisexp (out, hse_fun)
      val () = prstr "; "
      val () = fprint_primvalist (out, hdes_arg)
      val () = prstr "))"
    }
  | ~INSextfcall (tmpret, fnm, arg) => {
      val () = prstr "INSextfcall("
      val () = fprint_tmpvar (out, tmpret)
      val () = prstr " <- "
      val () = fprint_string (out, fnm)
      val () = prstr "("
      val () = fprint_primvalist (out, arg)
      val () = prstr "))"
    }
  | ~INSextmcall (tmpret, obj, mtd, arg) => {
      val () = prstr "INSextmcall("
      val () = fprint_tmpvar (out, tmpret)
      val () = prstr " <- "
      val () = (fprint_primval (out, obj); prstr "."; fprint_string (out, mtd))
      val () = prstr "("
      val () = fprint_primvalist (out, arg)
      val () = prstr "))"
    }
  | ~INScond (pmv_cond, inss_then, inss_else) => {
      val () = prstr "INScond(\n"
      val () = prstr "**COND**\n"
      val () = fprint_primval (out, pmv_cond)
      val () = prstr "\n"
      val () = prstr "**THEN**\n"
      val () = fprint_instrlst (out, inss_then)
      val () = prstr "**ELSE**\n"
      val () = fprint_instrlst (out, inss_else)
      val () = prstr ")"
    }
  | ~INSfreecon (pmv) => (prstr "INSfreecon("; fprint_primval (out, pmv); prstr ")")
  | ~INSloop _ => prstr "INSloop(...)"
  | ~INSloopexn (knd, tlab) => (prstr "INSloopexn("; fprint_int (out, knd); prstr ", "; fprint_tmplab (out, tlab); prstr ")")
  | ~INScaseof _ => (prstr "INScaseof("; fprint_string (out, "..."); prstr ")")
  | ~INSletpop () => prstr "INSletpop()"
  | ~INSletpush (pmds) => (prstr "INSletpush(\n"; fprint_primdeclst (out, pmds); prstr ")")
  | ~INSmove_con (tmpret, d2c, hse_sum, lpmvs) => {
      val () = prstr "INSmove_con("
      val () = fprint_tmpvar (out, tmpret)
      val () = prstr " <- "
      val () = fprint_d2con (out, d2c)
      val () = prstr "("
      val () = fprint_hisexp (out, hse_sum)
      val () = prstr ";"
      val () = fprint_labprimvalist (out, lpmvs)
      val () = prstr "))"
    }
  | ~INSmove_boxrec _ => (prstr "INSmove_boxrec("; prstr "..."; prstr ")")
  | ~INSmove_fltrec _ => (prstr "INSmove_fltrec("; prstr "..."; prstr ")")
  | ~INSpatck (pmv, pck, pcknt) => (prstr "INSpatck("; fprint_patck (out, pck); prstr "; "; fprint_patckont (out, pcknt); prstr ")")
  | ~INSmove_ptrofsel (tmp, pmv, hse_sel, pmls) => {
      val () = prstr "INSmove_ptrofsel("
      val () = fprint_tmpvar (out, tmp)
      val () = prstr " <- "
      val () = fprint_primval (out, pmv)
      val () = prstr "; "
      val () = fprint_hisexp (out, hse_sel)
      val () = prstr "; "
      val () = fprint_primlablst (out, pmls)
      val () = prstr ")"
    }
  | ~INSstore_ptrofs (pmv_l, hse_rt, ofs, pmv_r) => {
      val () = prstr "INSstore_ptrofs("
      val () = fprint_primval (out, pmv_l)
      val () = prstr "("
      val () = fprint_hisexp (out, hse_rt)
      val () = prstr ")"
      val () = prstr "["
      val () = fprint_primlablst (out, ofs)
      val () = prstr "]"
      val () = prstr " := "
      val () = fprint_primval (out, pmv_r)
      val () = prstr ")"
    }
  | ~INSxstore_ptrofs _ => prstr "INSxstore_ptrofs(...)"
  | ~INSraise (tmp, pmv_exn) => (prstr "INSraise("; fprint_tmpvar (out, tmp); prstr "; "; fprint_primval (out, pmv_exn); prstr ")")
  | ~INSmove_delay (tmp, lin, hse, pmv_thk) => {
      val () = prstr "INSmove_delay("
      val () = fprint_tmpvar (out, tmp)
      val () = prstr "; "
      val () = fprint_int (out, lin)
      val () = prstr "; "
      val () = fprint_hisexp (out, hse)
      val () = prstr "; "
      val () = fprint_primval (out, pmv_thk)
      val () = prstr ")"
    }
  | ~INSmove_lazyeval (tmp, lin, hse, pmv_lazy) => {
      val () = prstr "INSmove_lazyeval("
      val () = fprint_tmpvar (out, tmp)
      val () = prstr "; "
      val () = fprint_int (out, lin)
      val () = prstr "; "
      val () = fprint_hisexp (out, hse)
      val () = prstr "; "
      val () = fprint_primval (out, pmv_lazy)
      val () = prstr ")"
    }
  | ~INStrywith _ => (prstr "INStrywith("; fprint_string (out, "..."); prstr ")")
  | ~INSmove_list_nil (tmp) => (prstr "INSmove_list_nil("; fprint_tmpvar (out, tmp); prstr ")")
  | ~INSpmove_list_nil (tmp) => (prstr "INSpmove_list_nil("; fprint_tmpvar (out, tmp); prstr ")")
  | ~INSpmove_list_cons (tmp, hse_elt) => (prstr "INSpmove_list_cons("; fprint_tmpvar (out, tmp); prstr ", "; fprint_hisexp (out, hse_elt); prstr ")")
  | ~INSmove_list_phead (tmphd, tmptl, hse_elt) => {
      val () = prstr "INSmove_list_phead("
      val () = fprint_tmpvar (out, tmphd)
      val () = prstr "; "
      val () = fprint_tmpvar (out, tmptl)
      val () = prstr "; "
      val () = fprint_hisexp (out, hse_elt)
      val () = prstr ")"
    }
  | ~INSmove_list_ptail (tmptl1, tmptl2, hse_elt) => {
      val () = prstr "INSmove_list_ptail("
      val () = fprint_tmpvar (out, tmptl1)
      val () = prstr "; "
      val () = fprint_tmpvar (out, tmptl2)
      val () = prstr "; "
      val () = fprint_hisexp (out, hse_elt)
      val () = prstr ")"
    }
  | ~INSstore_arrpsz_asz (tmp, asz) => (prstr "INSstore_arrpsz_asz("; fprint_tmpvar (out, tmp); prstr "; "; fprint_int (out, asz); prstr ")")
  | ~INSstore_arrpsz_ptr (tmp, hse_elt, asz) => {
      val () = prstr "INSstore_arrpsz_ptr("
      val () = fprint_tmpvar (out, tmp)
      val () = prstr "; "
      val () = fprint_hisexp (out, hse_elt)
      val () = prstr "; "
      val () = fprint_int (out, asz)
      val () = prstr ")"
    }
  | ~INSmove_arrpsz_ptr (tmp1, tmp2) => (prstr "INSmove_arrpsz_ptr("; fprint_tmpvar (out, tmp1); prstr "; "; fprint_tmpvar (out, tmp2); prstr ")")
  | ~INSupdate_ptrinc (tmp, hse_elt) => (prstr "INSupdate_ptrinc("; fprint_tmpvar (out, tmp); prstr "; "; fprint_hisexp (out, hse_elt); prstr ")")
  | ~INSupdate_ptrdec (tmp, hse_elt) => (prstr "INSupdate_ptrdec("; fprint_tmpvar (out, tmp); prstr "; "; fprint_hisexp (out, hse_elt); prstr ")")
  | ~INSclosure_initize (tmp, knd, flab) => (prstr "INSclosure_initize("; fprint_tmpvar (out, tmp); prstr " <- "; fprint_funlab (out, flab); prstr ")")
  | ~INStmpdec (tmp) => (prstr "INStmpdec("; fprint_tmpvar (out, tmp); prstr ")")
  | ~INSextvar (name, pmv) => (prstr "INSextvar("; fprint_string (out, name); prstr " = "; fprint_primval (out, pmv); prstr ")")
  | ~INSdcstdef (d2c, pmv) => (prstr "INSdcstdef("; fprint_d2cst (out, d2c); prstr " = "; fprint_primval (out, pmv); prstr ")")
  | ~INStempenver (d2vs) => (prstr "INStempenver("; fprint_d2varlst (out, d2vs); prstr ")")
  | v (*rest-of-instr*) => (instr_node_view_free (v); prstr "INS...(...)")
end
//
// [filenv] of trans2_env is not linked: the cell holds the list of the declarations
//
implement $TRENV2.filenv_get_d2eclist (fenv) = $UN.ptr0_get<d2eclist> ($UN.cast{ptr} (fenv))
//
(* end of [ca_dbl.dats] *)
