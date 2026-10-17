(* the part of the emit test that is written once for ATS1 and ATS2, after pats_ccomp.sats and the wrappers (see ca_gen.py) *)
(* ****** ****** *)
//
// Everything here is in the common subset of ATS1 and ATS2.
//
(* ****** ****** *)

fun H_fil (k: int): filename = $FIL.filename_make (H_str (20 + k), H_str (20 + k), H_str (20 + k))

(* ****** ****** *)

fun H_tmpvar
  (loc: location, hse: hisexp, kind: int, topknd: int, origin: tmpvaropt, sfx: int): tmpvar = let
  val tmp = (
    if kind = 1 then tmpvar_make_ref (loc, hse)
    else if kind >= 2 then tmpvar_make_ret (loc, hse)
    else tmpvar_make (loc, hse)
  ) : tmpvar
  val () = if kind = 3 then tmpvar_set_ref (tmp, 1)
  val () = tmpvar_set_topknd (tmp, topknd)
  val () = tmpvar_set_origin (tmp, origin)
  val () = tmpvar_set_suffix (tmp, sfx)
in
  tmp
end // end of [H_tmpvar]

fun H_tmpvar_tl (tmp: tmpvar, n: int): tmpvar = let
  fun loop (tmp: tmpvar, i: int): void = if i > 0 then (tmpvar_inc_tailcal (tmp); loop (tmp, i-1))
in
  loop (tmp, n); tmp
end // end of [H_tmpvar_tl]

fun H_tmplab (loc: location): tmplab = tmplab_make (loc)

fun H_funlab
(
  name: string, level: int, hse: hisexp
, qopt: d2cstopt, tmpknd: int, origin: funlabopt, sfx: int
, t2mas: t2mpmarglst
) : funlab = let
  val flab = funlab_make
    (name, level, hse, None_vt (), qopt, ON_d2varopt (), t2mas, $STMP.funlab_stamp_make ())
  val () = funlab_set_tmpknd (flab, tmpknd)
  val () = funlab_set_origin (flab, origin)
  val () = funlab_set_suffix (flab, sfx)
in
  flab
end // end of [H_funlab]

fun H_funent
(
  loc: location, flab: funlab
, imparg: s2varlst, tmparg: s2explstlst, tmpsub: tmpsubopt
, tmpret: tmpvar, fls0: funlablst, d2es: d2envlst, vbmap: vbindmap
, inss: instrlst, tmps: tmpvarlst
, flfin: funlablst, d2fin: d2envlst, fnxs: funlablst
) : funent = let
  val fent = funent_make (loc, flab, imparg, tmparg, tmpsub, tmpret, fls0, d2es, vbmap, inss, tmps)
  val () = funent_set_flablst_fin (fent, OS_funlablstopt (flfin))
  val () = funent_set_d2envlst_fin (fent, OS_d2envlstopt (d2fin))
  val () = funent_set_fnxlablst (fent, fnxs)
  val () = funlab_set_funent (flab, OS_funentopt (fent))
in
  fent
end // end of [H_funent]

(* ****** ****** *)

fun H_e (out: FILEref, s: string): void = (fprint_string (out, "@@ "); fprint_string (out, s); fprint_newline (out))
