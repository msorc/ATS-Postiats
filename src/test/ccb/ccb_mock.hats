(* the test doubles of the functions of the modules of pats_ccomp.sats that the group B modules call and that are in other groups (pats_ccomp_emit*.dats,
   pats_ccomp_ccompenv.dats, pats_ccomp_decl.dats, ...): the same text for ATS1 and ATS2 (the common subset), included by the drivers only (not by the chunks:
   the functions have the C names of the sats). Every function that does something observable prints a line "MOCK ..." (stdout) so that the sequence of
   the calls of the modules under test is compared too. *)
(* ****** ****** *)

implement emit_text (out, txt) = fprint_string (out, txt)
implement emit_LPAREN (out) = emit_text (out, "(")
implement emit_RPAREN (out) = emit_text (out, ")")
implement emit_newline (out) = fprint_newline (out)
implement emit_ident (out, name) = ccb_c_emit_ident (out, name)
implement emit_label (out, lab) = $LAB.fprint_label (out, lab)
implement emit_atslabel (out, lab) = (emit_text (out, "atslab__"); $LAB.fprint_label (out, lab))
implement emit_labelext (out, knd, lab) = if knd > 0 then emit_label (out, lab) else emit_atslabel (out, lab)
implement emit_funlab (out, flab) = let
  val () = (
    if ccb_has_origin (flab) then emit_funlab (out, ccb_get_origin (flab))
    else emit_ident (out, funlab_get_name (flab))
  )
  val sfx = funlab_get_suffix (flab)
in
  if sfx > 0 then (emit_text (out, "__"); fprint_int (out, sfx)) else ()
end

(* ****** ****** *)
//
// the environment (ccompenv): the state is in ccb_stub.c (see there), the matching functions of pats_ccomp_template.dats are called from here
//
fun ccb_E (env: !ccompenv): ptr = $UN.castvwtp1{ptr} (env)
fun ccb_tr (s: string): void = (dd_ps "MOCK "; dd_ps s)

implement ccompenv_make () = let
  val p = ccb_env_make ()
  val env = $UN.castvwtp0{ccompenv} (p)
  val () = ccb_flabset_push (p, $UN.castvwtp0{ptr} (funlabset_vt_nil ()))   // toplevel flabs
  val () = ccb_dvarset_push (p, $UN.castvwtp0{ptr} (d2envset_vt_nil ()))    // toplevel d2vars
  val () = ccb_vbenv_push (p)                                                 // toplevel vbinds
in
  env
end // end of [ccompenv_make]

implement ccompenv_free (env) = let
  val p = $UN.castvwtp0{ptr} (env)
  fun flabs (p: ptr): void =
    if ccb_flabset_nonempty (p) > 0 then (funlabset_vt_free ($UN.castvwtp0{funlabset_vt} (ccb_flabset_pop p)); flabs p) else ()
  fun dvars (p: ptr): void =
    if ccb_dvarset_nonempty (p) > 0 then (d2envset_vt_free ($UN.castvwtp0{d2envset_vt} (ccb_dvarset_pop p)); dvars p) else ()
in
  flabs p; dvars p; ccb_env_free p
end // end of [ccompenv_free]

implement ccompenv_get_tmprecdepth (env) = ccb_env_tmprecdepth_get (ccb_E env)
implement ccompenv_inc_tmprecdepth (env) = (ccb_tr "inc_tmprecdepth\n"; ccb_env_tmprecdepth_set (ccb_E env, ccb_env_tmprecdepth_get (ccb_E env) + 1))
implement ccompenv_dec_tmprecdepth (env) = (ccb_tr "dec_tmprecdepth\n"; ccb_env_tmprecdepth_set (ccb_E env, ccb_env_tmprecdepth_get (ccb_E env) - 1))

(* ---- freeconenv *)
implement ccompenv_inc_freeconenv (env) = (ccb_tr "inc_freeconenv\n"; ccb_freecon_push (ccb_E env))
implement ccompenv_getdec_freeconenv (env) = let
  val () = ccb_tr "getdec_freeconenv\n"
  fun loop (l: ptr): primvalist_vt =
    if ptr_is_null (l) then list_vt_nil () else list_vt_cons ($UN.cast{primval} (ccb_lst_x l), loop (ccb_lst_next l))
  val l = ccb_freecon_pop (ccb_E env)
  val res = loop (l)
  val () = ccb_lst_free (l)
in
  res
end
fun ccb_add_freeconenv (env: !ccompenv, pmv: primval): void = (ccb_tr "add_freeconenv("; dd_primval pmv; dd_ps ")\n"; ccb_freecon_add (ccb_E env, $UN.cast{ptr} pmv))
implement ccompenv_add_freetupenv_if (env, pmv, pck) = if ccb_pck_is_free (pck) then ccb_add_freeconenv (env, pmv) else ()
implement ccompenv_add_freeconenv_if (env, pmv, pck, d2c) =
  if ccb_pck_is_free (pck) then (if d2con_is_nullary (d2c) then () else ccb_add_freeconenv (env, pmv)) else ()

(* ---- dvarsetenv, flabsetenv *)
implement ccompenv_incwth_dvarsetenv (env, d2es) = let
  val () = (ccb_tr "incwth_dvarsetenv("; dd_d2envlst d2es; dd_ps ")\n")
in
  ccb_dvarset_push (ccb_E env, $UN.castvwtp0{ptr} (d2envlst2set d2es))
end
implement ccompenv_getdec_dvarsetenv (env) = (ccb_tr "getdec_dvarsetenv\n"; $UN.castvwtp0{d2envset_vt} (ccb_dvarset_pop (ccb_E env)))
implement ccompenv_add_dvarsetenv_env (env, d2e) = let
  val lvl = d2var_get_level (d2env_get_var d2e)
in
  if lvl > 0 then let
    val p = ccb_E env
    val () = (ccb_tr "add_dvarsetenv_env("; dd_d2env d2e; dd_ps ")\n")
    val set = $UN.castvwtp0{d2envset_vt} (ccb_dvarset_top p)
    val set = d2envset_vt_add (set, d2e)
  in
    ccb_dvarset_settop (p, $UN.castvwtp0{ptr} (set))
  end else ()
end
implement ccompenv_inc_flabsetenv (env) = (ccb_tr "inc_flabsetenv\n"; ccb_flabset_push (ccb_E env, $UN.castvwtp0{ptr} (funlabset_vt_nil ())))
implement ccompenv_getdec_flabsetenv (env) = (ccb_tr "getdec_flabsetenv\n"; $UN.castvwtp0{funlabset_vt} (ccb_flabset_pop (ccb_E env)))
implement ccompenv_add_flabsetenv (env, fl) = let
  val p = ccb_E env
  val () = (ccb_tr "add_flabsetenv("; dd_funlab fl; dd_ps ")\n")
  val set = $UN.castvwtp0{funlabset_vt} (ccb_flabset_top p)
  val set = funlabset_vt_add (set, fl)
in
  ccb_flabset_settop (p, $UN.castvwtp0{ptr} (set))
end
implement ccompenv_addlst_flabsetenv_ifmap (env, flvl0, vbmap, fls0) = let
  val () = ccb_tr "addlst_flabsetenv_ifmap\n"
  fun addlst_if (env: !ccompenv, flvl0: int, vbmap: vbindmap, fls: funlablst_vt): funlablst_vt =
    case+ fls of
    | ~list_vt_cons (fl, fls) => let
        val flvl = funlab_get_level (fl)
      in
        if flvl > flvl0 then let
          val fent = ccb_funent_of (fl)
          val () = ccb_auxenv (env, vbmap, funent_get_d2envlst (fent))
        in
          addlst_if (env, flvl0, vbmap, fls)
        end else let
          val () = ccompenv_add_flabsetenv (env, fl)
          val fls = addlst_if (env, flvl0, vbmap, fls)
        in
          list_vt_cons (fl, fls)
        end
      end
    | ~list_vt_nil () => list_vt_nil ()
in
  addlst_if (env, flvl0, vbmap, fls0)
end

(* ---- the maps of the variables *)
implement ccompenv_add_vbindmapenvall (env, d2v, pmv) = let
  val () = (ccb_tr "add_vbindmapenvall("; dd_d2var d2v; dd_ps ","; dd_primval pmv; dd_ps ")\n")
  val p = ccb_E env
  val () = ccb_vbenv_add (p, $UN.cast{ptr} d2v, $UN.cast{ptr} pmv)
in
  ccb_vball_add (p, $UN.cast{ptr} d2v, $UN.cast{ptr} pmv)
end
implement ccompenv_find_vbindmapenv (env, d2v) = let
  var found: int = 0
  val r = ccb_vbenv_find (ccb_E env, $UN.cast{ptr} d2v, found)
in
  if found > 0 then Some_vt ($UN.cast{primval} r) else None_vt ()
end
implement ccompenv_find_vbindmapall (env, d2v) = let
  var found: int = 0
  val r = ccb_vball_find (ccb_E env, $UN.cast{ptr} d2v, found)
in
  if found > 0 then Some_vt ($UN.cast{primval} r) else None_vt ()
end

(* ---- the stack of marks *)
extern praxi ccb_pushv_make (): ccompenv_push_v
extern praxi ccb_pushv_free (pf: ccompenv_push_v): void
implement ccompenv_push (env) = (ccb_tr "push\n"; ccb_mark_push (ccb_E env); (ccb_pushv_make () | ()))
implement ccompenv_pop (pf | env) = let prval () = ccb_pushv_free (pf) in (ccb_tr "pop\n"; ccb_mark_pop (ccb_E env)) end
implement ccompenv_localjoin (pf1, pf2 | env) = let
  prval () = ccb_pushv_free (pf1)
  prval () = ccb_pushv_free (pf2)
in
  (ccb_tr "localjoin\n"; ccb_mark_join (ccb_E env))
end

(* ---- the other entries of markenvlst *)
implement ccompenv_add_tmpsub (env, tsub) = (ccb_tr "add_tmpsub("; dd_tmpsub tsub; dd_ps ")\n"; ccb_mark_add (ccb_E env, 7, $UN.cast{ptr} tsub))
implement ccompenv_add_staload (env, fenv) = (ccb_tr "add_staload\n"; ccb_mark_add (ccb_E env, 6, $UN.cast{ptr} fenv))
implement ccompenv_add_tmpcstmat (env, mat) = (ccb_tr "add_tmpcstmat("; dd_tmpcstmat mat; dd_ps ")\n"; ccb_mark_add (ccb_E env, 8, $UN.cast{ptr} mat))
implement ccompenv_add_tmpvarmat (env, mat) = (ccb_tr "add_tmpvarmat("; dd_tmpvarmat mat; dd_ps ")\n"; ccb_mark_add (ccb_E env, 9, $UN.cast{ptr} mat))
implement ccompenv_add_tempenver (env, d2vs) = (ccb_tr "add_tempenver("; dd_d2varlst d2vs; dd_ps ")\n"; ccb_tflag_set (1); ccb_mark_add (ccb_E env, 10, $UN.cast{ptr} d2vs))
implement ccompenv_add_fundec (env, hfd) = ccb_mark_add (ccb_E env, 2, $UN.cast{ptr} hfd)
implement ccompenv_add_fundec2 (env, hfd2) = (ccb_tr "add_fundec2\n"; ccb_mark_add (ccb_E env, 3, $UN.cast{ptr} hfd2))
implement ccompenv_add_impdec (env, imp) = ccb_mark_add (ccb_E env, 4, $UN.cast{ptr} imp)
implement ccompenv_add_impdec2 (env, imp2) = (ccb_tr "add_impdec2\n"; ccb_mark_add (ccb_E env, 5, $UN.cast{ptr} imp2))

fun ccb_find_tmpsub (env: !ccompenv): Option_vt (tmpsub) = let
  fun loop (c: ptr): Option_vt (tmpsub) =
    if ptr_is_null (c) then None_vt ()
    else if ccb_ent_kind c = 7 then Some_vt ($UN.cast{tmpsub} (ccb_ent_a c)) else loop (ccb_ent_next c)
in
  loop (ccb_marks (ccb_E env))
end
implement ccompenv_add_impdecloc (env, sub, imp) = let
  val () = ccb_tr "add_impdecloc\n"
  val opt = ccb_find_tmpsub (env)
in
  case+ opt of
  | ~Some_vt (tsub) => let
      val tmparg = s2explstlst_subst (sub, ccb_imp_tmparg imp)
    in
      ccompenv_add_impdec2 (env, K_hiimpdec2 (imp, tsub, tmparg))
    end
  | ~None_vt () => ()
end
implement ccompenv_add_fundecsloc (env, sub, knd, decarg, hfds) = let
  val () = ccb_tr "add_fundecsloc\n"
in
  if ccb_is_nil_s2qualst (decarg) then () else let
    val opt = ccb_find_tmpsub (env)
  in
    case+ opt of
    | ~Some_vt (tsub) => ccb_add_fundec2s (env, tsub, hfds)
    | ~None_vt () => ()
  end
end

(* ---- the matching of the instances of templates: the entries from the newest, the matching by the functions of pats_ccomp_template.dats *)
fun ccb_tcm_aux (c: ptr, d2c0: d2cst, t2mas: t2mpmarglst): tmpcstmat =
  if ptr_is_null (c) then K_TMPCSTMATnone ()
  else let
    val k = ccb_ent_kind c
    val res = (
      if k = 4 then hiimpdec_tmpcst_match ($UN.cast{hiimpdec} (ccb_ent_a c), d2c0, t2mas, 0)
      else if k = 5 then hiimpdec2_tmpcst_match ($UN.cast{hiimpdec2} (ccb_ent_a c), d2c0, t2mas, 0)
      else if k = 6 then ccb_stal_tc ($UN.cast{filenv} (ccb_ent_a c), d2c0, t2mas)
      else if k = 8 then tmpcstmat_tmpcst_match ($UN.cast{tmpcstmat} (ccb_ent_a c), d2c0, t2mas)
      else K_TMPCSTMATnone ()
    ) : tmpcstmat
  in
    if ccb_tc_isnone (res) then ccb_tcm_aux (ccb_ent_next c, d2c0, t2mas) else res
  end
implement ccompenv_tmpcst_match (env, d2c0, t2mas) = let
  val () = (ccb_tr "tmpcst_match("; dd_d2cst d2c0; dd_ps ")\n")
in
  ccb_tcm_aux (ccb_marks (ccb_E env), d2c0, t2mas)
end
fun ccb_tvm_aux (c: ptr, d2v0: d2var, t2mas: t2mpmarglst): tmpvarmat =
  if ptr_is_null (c) then K_TMPVARMATnone ()
  else let
    val k = ccb_ent_kind c
    val res = (
      if k = 2 then hifundec_tmpvar_match ($UN.cast{hifundec} (ccb_ent_a c), d2v0, t2mas)
      else if k = 3 then hifundec2_tmpvar_match ($UN.cast{hifundec2} (ccb_ent_a c), d2v0, t2mas)
      else if k = 6 then ccb_stal_tv ($UN.cast{filenv} (ccb_ent_a c), d2v0, t2mas)
      else if k = 9 then tmpvarmat_tmpvar_match ($UN.cast{tmpvarmat} (ccb_ent_a c), d2v0, t2mas)
      else K_TMPVARMATnone ()
    ) : tmpvarmat
  in
    if ccb_tv_isnone (res) then ccb_tvm_aux (ccb_ent_next c, d2v0, t2mas) else res
  end
implement ccompenv_tmpvar_match (env, d2v0, t2mas) = let
  val () = (ccb_tr "tmpvar_match("; dd_d2var d2v0; dd_ps ")\n")
in
  ccb_tvm_aux (ccb_marks (ccb_E env), d2v0, t2mas)
end

(* ---- the d2vars of the instrs INStempenver (get2_tempenver: only when a tempenver was added; the d2vars of the entries newest first) *)
implement ccompenv_dvarsetenv_add_tempenver (env, d2es) = let
  val () = ccb_tr "dvarsetenv_add_tempenver\n"
  fun aux (c: ptr, set: d2envset_vt): d2envset_vt =
    if ptr_is_null (c) then set
    else if ccb_ent_kind c = 10 then aux (ccb_ent_next c, ccb_d2vs_add (set, $UN.cast{d2varlst} (ccb_ent_a c)))
    else aux (ccb_ent_next c, set)
  fun nonempty (c: ptr): bool =
    if ptr_is_null (c) then false
    else if ccb_ent_kind c = 10 then (if ccb_d2vs_nonempty ($UN.cast{d2varlst} (ccb_ent_a c)) then true else nonempty (ccb_ent_next c))
    else nonempty (ccb_ent_next c)
in
  if ccb_tflag_get () > 0 then (
    if nonempty (ccb_marks (ccb_E env)) then aux (ccb_marks (ccb_E env), d2es) else (ccb_tflag_set (0); d2es)
  ) else d2es
end

(* ---- the compilation of the declarations of instances of templates (pats_ccomp_decl.dats): a function label and a function entry with a small body *)
implement hiimpdec_ccomp_if (env, level, imp, knd) = (ccb_tr "hiimpdec_ccomp_if("; dd_hiimpdec imp; dd_ps ")\n"; ccb_imp_mkfun (imp))
implement hifundeclst_ccomp (env, lvl0, knd, decarg, hfds) = (ccb_tr "hifundeclst_ccomp\n"; ccb_hfds_mkfun (hfds))

(* ---- the global lists of ccompenv (kinds: 0 exndec, 1 saspdec, 2 extype, 3 extcode, 4 staload, 5 dynload, 6 dyncon, 7 dyncst, 8 funlab) *)
fun ccb_mk_hideclist (l: ptr): hideclist = if ptr_is_null (l) then LN_hideclist () else LC_hideclist ($UN.cast{hidecl} (ccb_lst_x l), ccb_mk_hideclist (ccb_lst_next l))
fun ccb_mk_d2conlst (l: ptr): d2conlst = if ptr_is_null (l) then LN_d2conlst () else LC_d2conlst ($UN.cast{d2con} (ccb_lst_x l), ccb_mk_d2conlst (ccb_lst_next l))
fun ccb_mk_d2cstlst (l: ptr): d2cstlst = if ptr_is_null (l) then LN_d2cstlst () else LC_d2cstlst ($UN.cast{d2cst} (ccb_lst_x l), ccb_mk_d2cstlst (ccb_lst_next l))
fun ccb_mk_funlablst (l: ptr): funlablst = if ptr_is_null (l) then LN_funlablst () else LC_funlablst ($UN.cast{funlab} (ccb_lst_x l), ccb_mk_funlablst (ccb_lst_next l))
implement the_exndeclst_get () = let val l = ccb_gl_take 0 val res = ccb_mk_hideclist (l) val () = ccb_lst_free (l) in res end
implement the_exndeclst_add (x) = ccb_gl_add (0, $UN.cast{ptr} x)
implement the_saspdeclst_get () = let val l = ccb_gl_take 1 val res = ccb_mk_hideclist (l) val () = ccb_lst_free (l) in res end
implement the_saspdeclst_add (x) = ccb_gl_add (1, $UN.cast{ptr} x)
implement the_extypelst_get () = let val l = ccb_gl_take 2 val res = ccb_mk_hideclist (l) val () = ccb_lst_free (l) in res end
implement the_extypelst_add (x) = ccb_gl_add (2, $UN.cast{ptr} x)
implement the_extcodelst_get () = let val l = ccb_gl_take 3 val res = ccb_mk_hideclist (l) val () = ccb_lst_free (l) in res end
implement the_extcodelst_add (x) = ccb_gl_add (3, $UN.cast{ptr} x)
implement the_staloadlst_get () = let val l = ccb_gl_take 4 val res = ccb_mk_hideclist (l) val () = ccb_lst_free (l) in res end
implement the_staloadlst_add (x) = ccb_gl_add (4, $UN.cast{ptr} x)
implement the_dynloadlst_get () = let val l = ccb_gl_take 5 val res = ccb_mk_hideclist (l) val () = ccb_lst_free (l) in res end
implement the_dynloadlst_add (x) = ccb_gl_add (5, $UN.cast{ptr} x)
implement the_dynconlst_get () = let val l = ccb_gl_take 6 val res = ccb_mk_d2conlst (l) val () = ccb_lst_free (l) in res end
implement the_dynconlst_add (x) = ccb_gl_add (6, $UN.cast{ptr} x)
implement the_dyncstlst_get () = let val l = ccb_gl_take 7 val res = ccb_mk_d2cstlst (l) val () = ccb_lst_free (l) in res end
implement the_dyncstlst_add (x) = ccb_gl_add (7, $UN.cast{ptr} x)
implement the_funlablst_get () = let val l = ccb_gl_take 8 val res = ccb_mk_funlablst (l) val () = ccb_lst_free (l) in res end
implement the_funlablst_add (fl) = (ccb_tr "the_funlablst_add("; dd_funlab fl; dd_ps ")\n"; ccb_gl_add (8, $UN.cast{ptr} fl))
implement the_toplevel_getref_tmpvarlst () = $UN.cast{Ptr1} (ccb_toplevel_tmpvarlst_ref ())
implement the_toplevel_getref_primdeclst () = $UN.cast{Ptr1} (ccb_toplevel_primdeclst_ref ())

(* ---- the emitters that ccomp_main calls (pats_ccomp_emit*.dats): a line each, to the file that they are given *)
implement emit_time_stamp (out) = emit_text (out, "MOCK-TIME-STAMP\n")
implement emit_filename (out, fil) = $FIL.fprint_filename_full (out, fil)
implement emit_d2cst (out, d2c) = fprint_d2cst (out, d2c)
implement emit_d2conlst_extdec (out, d2cs) = (emit_text (out, "DYNCON-EXTDEC "); fprint_d2conlst (out, d2cs); emit_newline (out))
implement emit_d2conlst_initize (out, d2cs) = (emit_text (out, "DYNCON-INITIZE "); fprint_d2conlst (out, d2cs); emit_newline (out))
implement emit_d2cstlst_extdec (out, d2cs) = (emit_text (out, "DYNCST-EXTDEC "); fprint_d2cstlst (out, d2cs); emit_newline (out))
implement emit_exndec (out, hid) = (emit_text (out, "EXNDEC "); fprint_hidecl (out, hid); emit_newline (out))
implement emit_saspdec (out, hid) = (emit_text (out, "SASPDEC "); fprint_hidecl (out, hid); emit_newline (out))
implement emit_extype (out, hid) = (emit_text (out, "EXTYPE "); fprint_hidecl (out, hid); emit_newline (out))
implement emit_extcode (out, hid) = (emit_text (out, "EXTCODE "); fprint_hidecl (out, hid); emit_newline (out))
implement emit_staload (out, hid) = (emit_text (out, "STALOAD "); fprint_hidecl (out, hid); emit_newline (out))
implement emit_funent_ptype (out, fent) = (emit_text (out, "FUNENT-PTYPE "); fprint_funlab (out, funent_get_lab fent); emit_newline (out))
implement emit_funent_closure (out, fent) = (emit_text (out, "FUNENT-CLOSURE "); fprint_funlab (out, funent_get_lab fent); emit_newline (out))
implement emit_funent_implmnt (out, fent) = (emit_text (out, "FUNENT-IMPLMNT "); fprint_funlab (out, funent_get_lab fent); emit_newline (out))
implement emit_primdeclst (out, pmds) = (emit_text (out, "PRIMDECLST "); fprint_int (out, ccb_len_primdeclst pmds); emit_newline (out))
implement emit_tmpdeclst (out, tmps) = (emit_text (out, "TMPDECLST "); ccb_fprint_tmpvars (out, tmps); emit_newline (out))
implement hideclist_ccomp0 (hids) = (ccb_tr "hideclist_ccomp0\n"; ccb_ccomp0 (hids))
