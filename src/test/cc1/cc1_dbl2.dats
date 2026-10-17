(* ATS2 TEST DOUBLE (group C1 test, see ../../PORTING.md, "ccomp group C1"): the few functions of pats_ccomp.dats (constructors), pats_ccomp_instrseq.dats
   and pats_ccomp_funent.dats that the C1 modules call, with the bodies of src/. When the real modules of phase 1 are in src/ the test uses them instead
   (cc1_2.sh: CC1_REAL=1) and this file is not compiled. It also includes the generated constructors (pats_ccomp_gen_dats.hats must be included once). *)
(* ****** ****** *)
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"
staload "../pats_basics.sats"
staload "../pats_staexp2.sats"
staload "../pats_dynexp2.sats"
staload _ = "../pats_dynexp2_dvar.dats"
staload "../pats_histaexp.sats"
staload "../pats_hidynexp.sats"
staload "../pats_ccomp.sats"
(* ****** ****** *)
#include "../pats_ccomp_gen_dats.hats"
(* ****** ****** *)

implement primval_argenv (loc, hse, nenv) = primval_new (loc, hse, primval_node_PMVargenv (nenv))
implement primval_int (loc, hse, i) = primval_new (loc, hse, primval_node_PMVint (i))
implement primval_empty (loc, hse) = primval_new (loc, hse, primval_node_PMVempty ())
implement primval_tmp (loc, hse, tmp) = primval_new (loc, hse, primval_node_PMVtmp (tmp))
implement primval_funlab (loc, hse, fl) = primval_new (loc, hse, primval_node_PMVfunlab (fl))
implement primval_cfunlab (loc, hse, knd, fl) = primval_new (loc, hse, primval_node_PMVcfunlab (knd, fl))
implement primval_lamfix (knd, pmv_funval) = let
  val loc = pmv_funval.primval_loc ()
  val hse = pmv_funval.primval_type ()
in
  primval_new (loc, hse, primval_node_PMVlamfix (knd, pmv_funval))
end
implement primval_make_tmp (loc, tmp) = primval_tmp (loc, tmpvar_get_type (tmp), tmp)
implement primval_make_funlab (loc, fl) = let
  val hse = funlab_get_type (fl)
  val funclo = funlab_get_funclo (fl)
in
  case+ funclo of
  | FUNCLOfun () => primval_funlab (loc, hse, fl)
  | _ => primval_cfunlab (loc, hse, funclo_get_clokind (funclo), fl)
end
implement ibranch_make (loc, inss) = ibranch_new (loc, inss)
implement instr_funlab (loc, fl) = instr_new (loc, instr_node_INSfunlab (fl))
implement instr_comment (loc, str) = instr_new (loc, instr_node_INScomment (str))
implement instr_move_val (loc, tmp, pmv) = instr_new (loc, instr_node_INSmove_val (tmp, pmv))
implement instr_loop (loc, tlab_init, tlab_fini, tlab_cont, inss_init, pmv_test, inss_test, inss_post, inss_body) =
  instr_new (loc, instr_node_INSloop (tlab_init, tlab_fini, tlab_cont, inss_init, pmv_test, inss_test, inss_post, inss_body))
implement instr_loopexn (loc, knd, tlab) = instr_new (loc, instr_node_INSloopexn (knd, tlab))
implement instr_caseof (loc, xs) = instr_new (loc, instr_node_INScaseof (xs))
implement instr_move_delay (loc, tmp, lin, hse, thunk) = instr_new (loc, instr_node_INSmove_delay (tmp, lin, hse, thunk))
implement instr_move_lazyeval (loc, tmp, lin, hse, pmv_lazy) = instr_new (loc, instr_node_INSmove_lazyeval (tmp, lin, hse, pmv_lazy))
implement instr_trywith (loc, tmp, _try, _with) = instr_new (loc, instr_node_INStrywith (tmp, _try, _with))

(* ****** ****** *)
//
// the sequence of instructions: a cell with the instructions in reverse order
//
assume instrseq_vtype = ptr
implement instrseq_make_nil () = let
  val p = the_garena_alloc (sizeof<ptr>)
  val () = $UN.ptr0_set<ptr> (p, the_null_ptr)
in
  p
end
implement instrseq_add (res, x) = let
  val xs = $UN.cast{instrlst} ($UN.ptr0_get<ptr> (res))
in
  $UN.ptr0_set<ptr> (res, $UN.cast{ptr} (glist_cons<instr> (x, xs)))
end
implement instrseq_get_free (res) = let
  val xs = $UN.cast{instrlst} ($UN.ptr0_get<ptr> (res))
in
  glist_reverse<instr> (xs)
end

(* ****** ****** *)
//
implement funent_make (loc, flab, imparg, tmparg, tmpsub, tmpret, fls0, d2es, vbmap, inss, tmplst) =
  funent_new (loc, flab, imparg, tmparg, tmpsub, tmpret, fls0, gopt_none (), d2es, gopt_none (), vbmap, inss, tmplst, glist_nil ())
implement funent_get_loc (fent) = fent.funent_loc ()
implement funent_get_lab (fent) = fent.funent_lab ()
implement funent_get_level (fent) = funlab_get_level (fent.funent_lab ())
implement funent_get_imparg (fent) = fent.funent_imparg ()
implement funent_get_tmparg (fent) = fent.funent_tmparg ()
implement funent_get_tmpsub (fent) = fent.funent_tmpsub ()
implement funent_get_tmpret (fent) = fent.funent_tmpret ()
implement funent_get_flablst (fent) = fent.funent_flablst ()
implement funent_get_flablst_fin (fent) = fent.funent_flablst_fin ()
implement funent_get_d2envlst (fent) = fent.funent_d2envlst ()
implement funent_get_d2envlst_fin (fent) = fent.funent_d2envlst_fin ()
implement funent_get_vbindmap (fent) = fent.funent_vbindmap ()
implement funent_get_instrlst (fent) = fent.funent_instrlst ()
implement funent_get_tmpvarlst (fent) = fent.funent_tmpvarlst ()
implement funent_get_fnxlablst (fent) = fent.funent_fnxlablst ()
implement funent_set_tmpsub (fent, opt) = set_funent_tmpsub (fent, opt)
implement funent_set_flablst_fin (fent, opt) = set_funent_flablst_fin (fent, opt)
implement funent_set_d2envlst_fin (fent, opt) = set_funent_d2envlst_fin (fent, opt)
implement funent_set_fnxlablst (fent, fls) = set_funent_fnxlablst (fent, fls)
