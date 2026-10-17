#!/usr/bin/env python3
"""camutate.py OUTDIR REFERENCE.out [REFERENCE.err] [N...]   Mutation test of the ATS2 port of pats_ccomp_emit{,2,3}: for each deliberate bug below the module is
mutated, recompiled in the staging directory of ca2.sh (OUTDIR/stage2), relinked, run, and its stdout (the line of the time stamp masked) and stderr compared with the
reference (the output of ca1, the ATS1 build). With numbers: only those mutations."""
import sys, os, re, shutil, subprocess, tempfile
OUT = os.path.abspath(sys.argv[1]); REF = os.path.abspath(sys.argv[2])
REFERR = os.path.abspath(sys.argv[3]) if len(sys.argv) > 3 and not sys.argv[3].isdigit() else None
SEL = [int(a) for a in sys.argv[3:] if a.isdigit()] if REFERR is None else [int(a) for a in sys.argv[4:] if a.isdigit()]
W = os.path.join(OUT, 'stage2')
E1 = 'pats_ccomp_emit.dats'; E2 = 'pats_ccomp_emit2.dats'; E3 = 'pats_ccomp_emit3.dats'
M = [
 # ---- pats_ccomp_emit.dats
 ('emit_char: the escape of the quote', E1, '''| '\\'' => emit_text (out, "\\\\'")''', '''| '\\'' => emit_text (out, "'")'''),
 ('emit_string: the escape of the double quote', E1, '''| '"' => emit_text (out, "\\\\\\"")''', '''| '"' => emit_text (out, "\\"")'''),
 ('emit_char: the escape of the backslash', E1, '''| '\\\\' => emit_text (out, "\\\\\\\\")
| _ => (''', '''| '\\\\' => emit_text (out, "\\\\")
| _ => ('''),
 ('emit_char: the octal escape of a non-printable', E1, '''isprint_char (c)
      then fprint_char (out, c)
      else (emit_text (out, "\\\\"); emit_fprint_oct3 (out, $UN.cast{uint}($UN.cast{uchar}(c))))
    // end of [if]
  ) // end of [_]''', '''isprint_char (c)
      then fprint_char (out, c)
      else (emit_text (out, "\\\\"); emit_fprint_oct3 (out, $UN.cast{uint}(c)))
    // end of [if]
  ) // end of [_]'''),
 ('emit_string: the newline', E1, '''| '\\n' => emit_text (out, "\\\\n")
| '\\t' => emit_text (out, "\\\\t")
| '\\\\' => emit_text (out, "\\\\\\\\")
| _ (*rest-of-char*)''', '''| '\\n' => emit_text (out, "\\\\t")
| '\\t' => emit_text (out, "\\\\t")
| '\\\\' => emit_text (out, "\\\\\\\\")
| _ (*rest-of-char*)'''),
 ('emit_ident: the dollar', E1, '''else if (c = '$') then fprint_string (out, "__")''', '''else if (c = '$') then fprint_string (out, "_")'''),
 ('emit_ident: the underscore', E1, '''else if (c = '_') then fprint_char (out, '_')''', '''else if (c = '_') then fprint_string (out, "__")'''),
 ('emit_ident: the octal code is signed', E1, '''val () = emit_fprint_oct3 (out, $UN.cast{uint}(c))
in
  fprint_string (out, "_")''', '''val () = emit_fprint_oct3 (out, $UN.cast{uint}($UN.cast{uchar}(c)))
in
  fprint_string (out, "_")'''),
 ('C: the format of the floats', E1, '"%.18f"', '"%.17f"'),
 ('emit_d2con: the tag of an exception', E1, '''  if tag >= 0
    then let // HX: not exncon''', '''  if tag > 0
    then let // HX: not exncon'''),
 ('emit_d2cst: the stamp of a static constant', E1, '''    if (knd = 0) then
    {
      val () = emit_text (out, "__")
      val stamp = d2cst_get_stamp (d2c)''', '''    if (knd = 1) then
    {
      val () = emit_text (out, "__")
      val stamp = d2cst_get_stamp (d2c)'''),
 ('emit_primcstsp: the location', E1, '''ATSCSTSPmyloc(\\""''', '''ATSCSTSPmyloc("'''),
 ('emit_tmplabint: the separator', E1, '''  val () = emit_tmplab (out, tlab)
  val () = emit_text (out, "__")
  val () = fprint_int (out, i)''', '''  val () = emit_tmplab (out, tlab)
  val () = emit_text (out, "_")
  val () = fprint_int (out, i)'''),
 ('emit_funarg: the case of one function', E1, '''emit_funarg
  (out, narg) = let
  val nfnx = $UN.ptr0_get<int> (the_nfnx)
in
  if nfnx <= 1''', '''emit_funarg
  (out, narg) = let
  val nfnx = $UN.ptr0_get<int> (the_nfnx)
in
  if nfnx <= 0'''),
 ('emit_funapy: the name', E1, '''    emit_text (out, "a"); fprint_int (out, nfnx);
    emit_text (out, "py"); fprint_int (out, narg)''', '''    emit_text (out, "a"); fprint_int (out, nfnx);
    emit_text (out, "rg"); fprint_int (out, narg)'''),
 ('emit_tmpvar: the static prefix', E1, '''  if knd = 0
    then emit_tmp(out) // local
    else emit_statmp(out) // toplevel''', '''  if knd = 1
    then emit_tmp(out) // local
    else emit_statmp(out) // toplevel'''),
 ('emit_tmpvar: ref before ret', E1, '''val isref = tmpvar_isref(tmp)
val () = if isref then emit_text(out, "ref")
val isret = tmpvar_isret(tmp)
val () = if isret then emit_text(out, "ret")''', '''val isret = tmpvar_isret(tmp)
val () = if isret then emit_text(out, "ret")
val isref = tmpvar_isref(tmp)
val () = if isref then emit_text(out, "ref")'''),
 ('emit_tmpvar: the suffix of a copy', E1, '''    val ((*void*)) = emit_text (out, "__")
    val ((*void*)) = fprint_int (out, sfx)''', '''    val ((*void*)) = emit_text (out, "_")
    val ((*void*)) = fprint_int (out, sfx)'''),
 ('emit_funlab: the stamp of a template instance', E1, '''if tmpknd > 0 then''', '''if tmpknd >= 0 then'''),
 ('emit_funlab: the suffix', E1, '''if sfx > 0 then (emit_text(out, "__"); fprint_int(out, sfx))''', '''if sfx > 1 then (emit_text(out, "__"); fprint_int(out, sfx))'''),
 ('emit2_funlab: the constant name', E1, '''  | ~GOsome (d2c) => d2cst_get_name(d2c)
  | ~GOnone ((*void*)) => funlab_get_name(flab)''', '''  | ~GOsome (d2c) => funlab_get_name(flab)
  | ~GOnone ((*void*)) => funlab_get_name(flab)'''),
 ('emit_arrdim: the separator', E1, '''then emit_text (out, "][")''', '''then emit_text (out, "][ ")'''),
 ('emit_tmpdec: the comment of a void', E1, '''if isvoid then emit_text (out, "// ")
//
val () = (''', '''if isvoid then emit_text (out, "/// ")
//
val () = ('''),
 ('emit_tmpdec: the element of an array', E1, '''| ~HSEtyarr
  (
    hse_elt, _(*dim*)
  ) => emit_hisexp (out, hse_elt)
| v (*non-tyarr*)''', '''| ~HSEtyarr
  (
    hse_elt, _(*dim*)
  ) => emit_hisexp (out, hse)
| v (*non-tyarr*)'''),
 ('emit_primval_funlab: the envless test', E1, '''val-~PMVfunlab
  (flab) = primval_node_view (pmv0.primval_node ())
//
val isenv = funlab_is_envful (flab)''', '''val-~PMVfunlab
  (flab) = primval_node_view (pmv0.primval_node ())
//
val isenv = not (funlab_is_envful (flab))'''),
 ('emit_primval_cfunlab: the environment starts at 0', E1, '''val nenv = emit_d2envlst (out, d2es, 0)
val ((*closing*)) = emit_text (out, "))")''', '''val nenv = emit_d2envlst (out, d2es, 1)
val ((*closing*)) = emit_text (out, "))")'''),
 ('emit_d2envlst: the separator', E1, '''    if (i > 0)
      then emit_text(out, ", ")''', '''    if (i > 1)
      then emit_text(out, ", ")'''),
 ('emit_primval_ptrof2: the array', E1, '''val () = if istyarr then emit_text (out, "[0]")''', '''val () = if not (istyarr) then emit_text (out, "[0]")'''),
 ('emit_primval_ptrof2: the void', E1, '''val () = if isvoid then emit_text (out, "_void")
val () = emit_LPAREN (out)''', '''val () = if not (isvoid) then emit_text (out, "_void")
val () = emit_LPAREN (out)'''),
 ('emit_primval_refarg: the kind', E1, '''  if (knd > 0) then emit_primval_ptrof2 (out, pmv)''', '''  if (knd > 0) then emit_primval (out, pmv)'''),
 ('emit_primval_deref: a ptrof', E1, '''| ~PMVptrof (pmv) => emit_primval (out, pmv)
| v (* non-ptrof *)''', '''| ~PMVptrof (pmv) => auxmain (out, pmv, hse)
| v (* non-ptrof *)'''),
 ('emit_primval: the vararg', E1, '''then emit_text(out, "ATSPMVvararg0(")
else emit_text(out, "ATSPMVvararg1(")''', '''then emit_text(out, "ATSPMVvararg1(")
else emit_text(out, "ATSPMVvararg0(")'''),
 ('emit_instr: the else branch', E1, '''    val () = emit_text (out, "\\n} ATSelse() {\\n")
    val () = emit_instrlst (out, inss_else)''', '''    val () = emit_text (out, "\\n} ATSelse() {\\n")
    val () = emit_instrlst (out, inss_then)'''),
 ('emit_instr: the post-update of a loop', E1, '''    val ispost = glist_is_cons (inss_post)''', '''    val ispost = glist_is_cons (inss_body)'''),
 ('emit_instr: the kind of a loop exit', E1, '''      if knd = 0
        then emit_text (out, "ATSbreak2(")''', '''      if knd = 1
        then emit_text (out, "ATSbreak2(")'''),
 ('emit_instr: the closure environment starts at 1', E1, '''val _(*nenv+1*) = emit_d2envlst (out, d2es, 1)''', '''val _(*nenv+1*) = emit_d2envlst (out, d2es, 0)'''),
 ('emit_instrlst: the empty list', E1, '''emit_text (out, "/* (*nothing*) */")''', '''emit_text (out, "/* nothing */")'''),
 ('emit_instr: the debugging line', E1, '''then $LOC.fprint_line_pragma(out, loc0)''', '''then ()'''),
 ('auxcon0: the listlike', E1, '''val islst = d2con_is_listlike (d2c)
//
in
//
if
islst''', '''val islst = d2con_is_singular (d2c)
//
in
//
if
islst'''),
 ('auxtag: the singular', E1, '''else if d2con_is_singular (d2c) then 0
else 1''', '''else 1'''),
 ('auxarg: the uninitialized argument', E1, '''      if istop then emit_text (out, "#endif\\n")''', '''      if istop then emit_text (out, "")'''),
 ('auxcon1: the linear status', E1, '''if d2con_is_linear(d2c) then 0 else 1''', '''if d2con_is_linear(d2c) then 1 else 0'''),
 ('emit_instr_move_con: the exception', E1, '''  val () = (
    if isexn then auxexn1 (out, tmp, d2c, hit_con, arg)''', '''  val () = (
    if isnul then auxexn1 (out, tmp, d2c, hit_con, arg)'''),
 ('emit_instr_move_rec: the kind of a flat record', E1, '''    val hit = hisexp_typize (1, hse_rec)''', '''    val hit = hisexp_typize (0, hse_rec)'''),
 ('emit_instr_move_rec: the kind of a boxed record', E1, '''    val hit = hisexp_typize (0, hse_rec)
    val extknd = hisexp_get_extknd (hse_rec)
//
    val () =
      fprint_string''', '''    val hit = hisexp_typize (1, hse_rec)
    val extknd = hisexp_get_extknd (hse_rec)
//
    val () =
      fprint_string'''),
 ('emit_instr_move_rec: the separator of the fields', E1, '''      if i > 0 then emit_text (out, "\\n")
    val () =
      if boxknd = 0''', '''      if i > 1 then emit_text (out, "\\n")
    val () =
      if boxknd = 0'''),
 ('auxmain: the array element on the top', E1, '''          val istop = list_vt_is_nil (xys)''', '''          val istop = list_vt_is_cons (xys)'''),
 ('auxmain: the flat record', E1, '''            if boxknd >= 0 // HX: it is a rec''', '''            if boxknd > 0 // HX: it is a rec'''),
 ('auxmain: the singleton', E1, '''        if issin
          then emit_text (out, "ATSSELrecsin(")''', '''        if not (issin)
          then emit_text (out, "ATSSELrecsin(")'''),
 ('auxmain: the pointer kind', E1, '''    case+ knd of
    | 0 => emit_primval (out, pmv)''', '''    case+ knd of
    | 1 => emit_primval (out, pmv)'''),
 ('auxsel: the singleton record', E1, '''      (lhse) => labhisexp_get_elt (lhse)
    // end of [HSEtyrecsin]
  | ~HSEtysum''', '''      (lhse) => hse0
    // end of [HSEtyrecsin]
  | ~HSEtysum'''),
 ('auxselist: the order of the path', E1, '''      val res = list_vt_cons ( @(hse0, pml), res )''', '''      val res = list_vt_cons ( @(hse1, pml), res )'''),
 ('emit_primval_ptrofsel: the pointer kind', E1, '''  auxmain (out, 1(*ptr*), pmv, hse_rt, xys, 0)
end // end of [val]
//
val ((*closing*)) = emit_RPAREN (out)''', '''  auxmain (out, 0(*ptr*), pmv, hse_rt, xys, 0)
end // end of [val]
//
val ((*closing*)) = emit_RPAREN (out)'''),
 ('emit_instr_xstore_ptrofs: the argument', E1, '''val () = auxmain (out, 1(*non*), pmv_l, hse_rt, xys, 0)''', '''val () = auxmain (out, 0(*non*), pmv_l, hse_rt, xys, 0)'''),
 ('emit_instr_move_delay: the linear kind', E1, '''if (lin = 0)
  then emit_text (out, "ATSINSmove_delay(")''', '''if (lin = 1)
  then emit_text (out, "ATSINSmove_delay(")'''),
 ('emit_instr_move_delay: the void thunk', E1, '''if hisexp_is_void(hse) then hisexp_int_t0ype() else hse''', '''if hisexp_is_void(hse) then hse else hisexp_int_t0ype()'''),
 ('emit_instr_move_lazyeval: the linear kind', E1, ''') = if (lin > 0) then emit_text (out, "ATSINSmove_llazyeval(")''', ''') = if (lin >= 0) then emit_text (out, "ATSINSmove_llazyeval(")'''),
 # ---- pats_ccomp_emit2.dats
 ('aux_funval2: the closure kind', E2, '''| FUNCLOclo0 () => isclo := true''', '''| FUNCLOclo0 () => ()'''),
 ('aux_funval2: the type of the closure', E2, '''  then glist_cons<hisexp> (hisexp_cloptr, hses_arg)''', '''  then glist_cons<hisexp> (hisexp_typtr, hses_arg)'''),
 ('aux_funval: a constant that is not a function declaration', E2, '''    if isfun
      then emit_d2cst (out, d2c)''', '''    if not (isfun)
      then emit_d2cst (out, d2c)'''),
 ('emit_instr_fcall: the closure is the first argument', E2, '''  then glist_cons<primval> (pmv_fun, pmvs_arg) else (pmvs_arg)''', '''  then glist_append<primval> (pmvs_arg, glist_sing<primval> (pmv_fun)) else (pmvs_arg)'''),
 ('emit_instr_fcall: a function that does not return', E2, '''  if noret then true else funval_isbot (pmv_fun)''', '''  if noret then true else false'''),
 ('emit_fparamlst: the comma after the environment', E2, '''    if (n > 0) then
      emit_text (out, ", ")''', '''    if (n > 1) then
      emit_text (out, ", ")'''),
 ('emit_freeaft_fun: the free kind', E2, '''  if freeknd > 0 then''', '''  if freeknd > 1 then'''),
 ('aux1: the tail call counter', E2, '''if ntl <= 1
  then (emit_text(out, "apy"); fprint_int(out, i))''', '''if ntl <= 2
  then (emit_text(out, "apy"); fprint_int(out, i))'''),
 ('aux2: the second name of the tail call', E2, '''then (emit_text(out, ", apy"); fprint_int(out, i))''', '''then (emit_text(out, ", arg"); fprint_int(out, i))'''),
 ('emit_instr_fcall2: the order of the moves', E2, '''aux1lst(out, ntl, pmvs_arg, 0(*i*))
val () =
aux2lst(out, ntl, pmvs_arg, 0(*i*))''', '''aux2lst(out, ntl, pmvs_arg, 0(*i*))
val () =
aux1lst(out, ntl, pmvs_arg, 0(*i*))'''),
 ('emit_instr_extfcall: the void', E2, '''if ~noret
  then emit_text(out, "ATSINSmove(")
  else emit_text(out, "ATSINSmove_void(")
// end of [if]
) : void // end of [val]
//
val () =
(
  emit_tmpvar(out, tmp); emit_text(out, ", ")
) (* end of [val] *)
//
val () =
emit_text
(
out, "ATSextfcall("''', '''if noret
  then emit_text(out, "ATSINSmove(")
  else emit_text(out, "ATSINSmove_void(")
// end of [if]
) : void // end of [val]
//
val () =
(
  emit_tmpvar(out, tmp); emit_text(out, ", ")
) (* end of [val] *)
//
val () =
emit_text
(
out, "ATSextfcall("'''),
 ('emit_instr_extmcall: the method name', E2, '''val () = emit_text(out, mtd_name)''', '''val () = emit_text(out, "")'''),
 ('emit_funenvlst: the separator', E2, '''    if i > 0
      then emit_text(out, sep)
    // end of [val]
    val () = emit_hisexp(out, hse)
    val () = (emit_text(out, " env")''', '''    if i > 1
      then emit_text(out, sep)
    // end of [val]
    val () = emit_hisexp(out, hse)
    val () = (emit_text(out, " env")'''),
 ('emit_funarglst: the separator after the environment', E2, '''    if n > 0
      then emit_text(out, sep)''', '''    if n > 1
      then emit_text(out, sep)'''),
 # ---- pats_ccomp_emit3.dats
 ('emit_exndec: the declaration', E3, '''"ATSdynexn_dec("''', '''"ATSdynexn_decl("'''),
 ('emit_extype: the sum type', E3, '''hisexp_node_is_HSEtysum (hse_def.hisexp_node ())''', '''hisexp_node_is_HSEtyrec (hse_def.hisexp_node ())'''),
 ('auxsta: the position of the code', E3, '''      (pos = 0) // %{#
      then let
        val loc = d2c.d2ecl_loc ()
      in
        auxloc(out, loc); emit_text(out, code)
      end // end of [then] // end of [if]
//
      ) (* end of [D2Cextcode] *)
//
    | ~D2Cstaload
      (
        idopt
      , fil, flag, fenv, _(*loaded*)''', '''      (pos = 1) // %{#
      then let
        val loc = d2c.d2ecl_loc ()
      in
        auxloc(out, loc); emit_text(out, code)
      end // end of [then] // end of [if]
//
      ) (* end of [D2Cextcode] *)
//
    | ~D2Cstaload
      (
        idopt
      , fil, flag, fenv, _(*loaded*)'''),
 ('auxdyn: the include kind', E3, '''        if knd = 0
          then auxsta(out, d2cs) else auxdyn(out, d2cs)
        // end of [if]
      ) (* end of [D2Cinclude] *)''', '''        if knd = 1
          then auxsta(out, d2cs) else auxdyn(out, d2cs)
        // end of [if]
      ) (* end of [D2Cinclude] *)'''),
 ('auxdyn: the order of local', E3, '''        auxdyn(out, d2cs_head); auxdyn(out, d2cs_body)''', '''        auxdyn(out, d2cs_body); auxdyn(out, d2cs_head)'''),
 ('emit_staload: the sats', E3, '''  if issta then auxsta(out, d2cs) else auxdyn(out, d2cs)
end // end of [emit_staload]''', '''  if issta then auxdyn(out, d2cs) else auxdyn(out, d2cs)
end // end of [emit_staload]'''),
 ('emit_tmpmovlst: the destination', E3, '''    val () = emit_tmpvar (out, x.tmpmov_dst ())
    val () = emit_text (out, ", ")''', '''    val () = emit_tmpvar (out, x.tmpmov_dst ())
    val () = emit_text (out, " ")'''),
 ('emit_patckont: the moves before the goto', E3, '''    emit_tmpmovlst (out, tmvlst)
    val () =
    emit_text (out, "ATSINSgoto(")''', '''    emit_text (out, "")
    val () =
    emit_text (out, "ATSINSgoto(")'''),
 ('emit_patckont: the int label', E3, '''    val () = emit_tmplabint (out, tlab, int)''', '''    val () = emit_tmplab (out, tlab)'''),
 ('auxcon: the nil of a list', E3, '''          eq_d2con_d2con (d2c, d2conpair_0 (xx))''', '''          eq_d2con_d2con (d2c, d2conpair_1 (xx))'''),
 ('auxcon: the nullary constructor', E3, '''      if isnul
        then emit_text (out, "ATSCKpat_con0(")''', '''      if not (isnul)
        then emit_text (out, "ATSCKpat_con0(")'''),
 ('auxexn: the arity', E3, '''  if narg = 0
    then emit_text (out, "ATSCKpat_exn0(")''', '''  if narg = 1
    then emit_text (out, "ATSCKpat_exn0(")'''),
 ('auxmain: the integer pattern of a token', E3, '''    val () = emit_text (out, "ATSCKpat_int(")
    val () = emit_primval (out, pmv)
    val () = emit_text (out, ", ")
    val () = emit_ATSPMVi0nt (out, tok)''', '''    val () = emit_text (out, "ATSCKpat_float(")
    val () = emit_primval (out, pmv)
    val () = emit_text (out, ", ")
    val () = emit_ATSPMVi0nt (out, tok)'''),
 ('emit_instr_patck: the dead code', E3, '''if isnone then emit_text (out, "#if(0)\\n")''', '''if not (isnone) then emit_text (out, "#if(0)\\n")'''),
 ('emit_ibranchlst: the header', E3, '''"/*\\n** ibranchlst-beg\\n*/\\n"''', '''"/*\\n** ibranchlst-begin\\n*/\\n"'''),
 ('auxfun: the template guard', E3, '''val () = if istmp then emit_text (out, "#if(0)\\n")
val () = if isqua then emit_text (out, "#if(0)\\n")''', '''val () = if istmp then emit_text (out, "#if(0)\\n")
val () = if isqua then emit_text (out, "")'''),
 ('auxfun: the origin makes it non-qualified', E3, '''  if gopt_is_some (flopt) then false else isqua''', '''  isqua'''),
 ('auxfun: the static', E3, '''    (if d2cst_is_static(gopt_unsome<d2cst>(qopt)) then false else true)
else false
) : bool // end of [val]
//
val flopt = funlab_get_origin(flab)
val isqua''', '''    (if d2cst_is_static(gopt_unsome<d2cst>(qopt)) then true else false)
else false
) : bool // end of [val]
//
val flopt = funlab_get_origin(flab)
val isqua'''),
 ('aux1_arglst: the comma', E3, '''    if n0+i > 0 then emit_text (out, ", ")
    val () =
    (
      emit_hisexp (out, hse); emit_text (out, " arg"); emit_int (out, i)''', '''    if n0+i > 1 then emit_text (out, ", ")
    val () =
    (
      emit_hisexp (out, hse); emit_text (out, " arg"); emit_int (out, i)'''),
 ('auxclo_cfun: the comma after the environment', E3, '''val () = aux2_arglst (out, hses_arg, n0, 0)''', '''val () = aux2_arglst (out, hses_arg, 0, 0)'''),
 ('aux5_envlst: the assignment', E3, '''emit_text (out, " = "); emit_text (out, "env"); emit_int (out, i)''', '''emit_text (out, " = "); emit_text (out, "env"); emit_int (out, i+1)'''),
 ('auxclo_create: the argumentless closure', E3, '''val () = if n0 = 0 then emit_text (out, "// argumentless")''', '''val () = if n0 = 1 then emit_text (out, "// argumentless")'''),
 ('emit_funent_closure: the creation', E3, '''if funclo_is_ptr(fc)
  then auxclo_create (out, flab, d2es)''', '''if funclo_is_cloptr(fc)
  then auxclo_create (out, flab, d2es)'''),
 ('emit_funent_fundec: the tail call', E3, '''  if ntlcal >= 2 then emit_funlab_funapy(out, flab)''', '''  if ntlcal >= 3 then emit_funlab_funapy(out, flab)'''),
 ('emit_funent_funbody: the void', E3, '''  if ~isvoid
    then emit_text(out, "ATSreturn(") else emit_text(out, "ATSreturn_void(")''', '''  if isvoid
    then emit_text(out, "ATSreturn(") else emit_text(out, "ATSreturn_void(")'''),
 ('emit_funent_fnxdeclst: the index', E3, '''  auxflist (out, fent0, glist_tail<funlab> (fls), 2(*i*))
  // end of [list_cons]
else ((*void*))
//
end // end of [emit_funent_fnxdeclst]''', '''  auxflist (out, fent0, glist_tail<funlab> (fls), 1(*i*))
  // end of [list_cons]
else ((*void*))
//
end // end of [emit_funent_fnxdeclst]'''),
 ('emit_funent_fnxbodylst: the first function', E3, '''  auxflist (out, fent0, glist_tail<funlab> (fls), 2(*i*))
  // end of [list_cons]
else ((*void*))
//
end // end of [emit_funent_fnxbodylst]''', '''  auxflist (out, fent0, fls, 2(*i*))
  // end of [list_cons]
else ((*void*))
//
end // end of [emit_funent_fnxbodylst]'''),
 ('emit_funent_implmnt: the template header', E3, '''val istmp = funent_is_tmplt (fent)
val () = if istmp then auxtmp (out, fent)''', '''val istmp = funent_is_tmplt (fent)
val () = if not (istmp) then auxtmp (out, fent)'''),
 ('emit_funent_implmnt: the initialization of the bindings', E3, '''val () = funent_varbindmap_initize2 (fent)''', '''val () = ()'''),
 ('emit_dynload: the suffix', E3, '''emit_filename (out, fil); emit_text (out, "__dynload")''', '''emit_filename (out, fil); emit_text (out, "_dynload")'''),
 ('emit_primdec: the extvar', E3, '''| ~PMDextvar
    (name, inss) =>
    emit_instrlst_ln (out, inss)''', '''| ~PMDextvar
    (name, inss) =>
    emit_instrlst (out, inss)'''),
 ('emit_primdec: the implementation', E3, '''    | ~GOsome (inss) => emit_instrlst_ln (out, inss)
    | ~GOnone () => ()''', '''    | ~GOsome (inss) => emit_instrlst (out, inss)
    | ~GOnone () => ()'''),
 ('emit_primdec: the local', E3, '''emit_primdeclst (out, pmds_head)
    val (
    ) = emit_text (out, "/* in of [local] */\\n")''', '''emit_primdeclst (out, pmds_body)
    val (
    ) = emit_text (out, "/* in of [local] */\\n")'''),
 ('emit_d2conlst_initize: the exceptions only', E3, '''    val isexn = d2con_is_exn (d2c)
    val ((*void*)) = if isexn then aux (out, d2c)''', '''    val isexn = d2con_is_con (d2c)
    val ((*void*)) = if isexn then aux (out, d2c)'''),
 ('emit_d2cst_extdec: the static functions', E3, '''      if issta then
        emit_text (out, "ATSdyncst_stafun(")''', '''      if not (issta) then
        emit_text (out, "ATSdyncst_stafun(")'''),
 ('emit_d2cst_extdec: the macros come first', E3, '''ismac (d2c) then let
    val () = emit_text (out, "ATSdyncst_mac(")''', '''iscastfn (d2c) then let
    val () = emit_text (out, "ATSdyncst_mac(")'''),
]
MASK = lambda b: re.sub(rb'^\*\* The starting compilation time is: .*$', b'STARTTIME', b, flags=re.M)
def run(arg):
    i, (name, fn, old, new) = arg
    tmp = tempfile.mkdtemp(prefix='camut')
    path = os.path.join(W, fn)
    src = open(path).read()
    try:
        n = src.count(old)
        if n != 1: return (i, name, 'ERROR', 'occurs %d times' % n)
        open(path, 'w').write(src.replace(old, new))
        mod = fn[:-5]
        cc = ['patscc', '-DATS_MEMALLOC_LIBC', '-D_GNU_SOURCE', '-include', 'alloca.h', '-I' + W, '-c', '-o', os.path.join(tmp, mod + '.o'), path]
        r = subprocess.run(cc, capture_output=True, text=True, cwd=tmp)
        open(path, 'w').write(src)
        if r.returncode != 0: return (i, name, 'BUILD-FAILED', (r.stdout + r.stderr)[-300:].replace('\n', ' '))
        objs = [os.path.join(W, 'obj', f) for f in sorted(os.listdir(os.path.join(W, 'obj'))) if f.endswith('.o') and f != mod + '.o']
        exe = os.path.join(tmp, 'ca2m')
        r = subprocess.run(['gcc', '-o', exe, os.path.join(tmp, mod + '.o')] + objs + ['-lgmp'], capture_output=True, text=True)
        if r.returncode != 0: return (i, name, 'LINK-FAILED', r.stderr[-200:].replace('\n', ' '))
        try:
            p = subprocess.run([exe], capture_output=True, timeout=300)
        except subprocess.TimeoutExpired:
            return (i, name, 'DETECTED', 'timeout')
        ref = open(REF, 'rb').read()
        if p.returncode != 0: return (i, name, 'DETECTED', 'exit %d' % p.returncode)
        if MASK(p.stdout) != ref:
            a, b = p.stdout.split(b'\n'), ref.split(b'\n')
            return (i, name, 'DETECTED', '%d lines differ' % (sum(1 for x, y in zip(a, b) if x != y) + abs(len(a) - len(b))))
        if REFERR and p.stderr != open(REFERR, 'rb').read(): return (i, name, 'DETECTED', 'stderr differs')
        return (i, name, 'SURVIVED', '')
    finally:
        open(path, 'w').write(src)
        shutil.rmtree(tmp, ignore_errors=True)
bad = 0; cnt = 0
for i, name, st, info in map(run, [(i, m) for i, m in enumerate(M) if not SEL or i in SEL]):
    cnt += 1
    print('%-12s %2d %s %s' % (st, i, name, info)); sys.stdout.flush()
    if st != 'DETECTED': bad += 1
print('mutations: %d, not detected: %d' % (cnt, bad))
