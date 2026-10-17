fn pats_ccomp_ld (p: ptr, k: int): ptr = $UN.ptr0_get<ptr> (ptr0_add_gint<byte> (p, k))
fn pats_ccomp_st (p: ptr, k: int, x: ptr): void = $UN.ptr0_set<ptr> (ptr0_add_gint<byte> (p, k), x)
fn pats_ccomp_alloc (n: int): ptr = the_garena_alloc ($UN.cast{size_t} (n))
//

fn pats_ccomp_ldd (p: ptr, k: int): double = $UN.ptr0_get<double> (ptr0_add_gint<byte> (p, k))
fn pats_ccomp_std (p: ptr, k: int, x: double): void = $UN.ptr0_set<double> (ptr0_add_gint<byte> (p, k), x)
//

implement
tmplab_new
  (a0, a1) = let
val p = pats_ccomp_alloc (16)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{tmplab} (p)
end // end of [tmplab_new]

implement
tmplab_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0)))

implement
tmplab_stamp
  (x) = $UN.cast{stamp} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
tmpvar_new
  (a0, a1, a2, a3, a4, a5, a6, a7) = let
val p = pats_ccomp_alloc (64)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_ccomp_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a4)))
val () = pats_ccomp_st (p, 40, $UN.cast{ptr} ($UN.cast{lint} (a5)))
val () = pats_ccomp_st (p, 48, $UN.cast{ptr} ($UN.cast{lint} (a6)))
val () = pats_ccomp_st (p, 56, $UN.cast{ptr} ($UN.cast{lint} (a7)))
in
  $UN.cast{tmpvar} (p)
end // end of [tmpvar_new]

implement
tmpvar_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0)))

implement
tmpvar_type
  (x) = $UN.cast{hisexp} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 8)))

implement
set_tmpvar_type
  (x, v) = pats_ccomp_st ($UN.cast{ptr} (x), 8, $UN.cast{ptr} ($UN.cast{lint} (v)))

implement
tmpvar_ref
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 16)))

implement
set_tmpvar_ref
  (x, v) = pats_ccomp_st ($UN.cast{ptr} (x), 16, $UN.cast{ptr} ($UN.cast{lint} (v)))

implement
tmpvar_ret
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 24)))

implement
set_tmpvar_ret
  (x, v) = pats_ccomp_st ($UN.cast{ptr} (x), 24, $UN.cast{ptr} ($UN.cast{lint} (v)))

implement
tmpvar_topknd
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 32)))

implement
set_tmpvar_topknd
  (x, v) = pats_ccomp_st ($UN.cast{ptr} (x), 32, $UN.cast{ptr} ($UN.cast{lint} (v)))

implement
tmpvar_origin
  (x) = $UN.cast{tmpvaropt} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 40)))

implement
set_tmpvar_origin
  (x, v) = pats_ccomp_st ($UN.cast{ptr} (x), 40, $UN.cast{ptr} ($UN.cast{lint} (v)))

implement
tmpvar_suffix
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 48)))

implement
set_tmpvar_suffix
  (x, v) = pats_ccomp_st ($UN.cast{ptr} (x), 48, $UN.cast{ptr} ($UN.cast{lint} (v)))

implement
tmpvar_stamp
  (x) = $UN.cast{stamp} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 56)))

(* ****** ****** *)

implement
d2env_new
  (a0, a1) = let
val p = pats_ccomp_alloc (16)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d2env} (p)
end // end of [d2env_new]

implement
d2env_var
  (x) = $UN.cast{d2var} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0)))

implement
d2env_type
  (x) = $UN.cast{hisexp} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
funlab_new
  (a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12) = let
val p = pats_ccomp_alloc (104)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_ccomp_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a4)))
val () = pats_ccomp_st (p, 40, $UN.cast{ptr} ($UN.cast{lint} (a5)))
val () = pats_ccomp_st (p, 48, $UN.cast{ptr} ($UN.cast{lint} (a6)))
val () = pats_ccomp_st (p, 56, $UN.cast{ptr} ($UN.cast{lint} (a7)))
val () = pats_ccomp_st (p, 64, $UN.cast{ptr} ($UN.cast{lint} (a8)))
val () = pats_ccomp_st (p, 72, $UN.cast{ptr} ($UN.cast{lint} (a9)))
val () = pats_ccomp_st (p, 80, $UN.cast{ptr} ($UN.cast{lint} (a10)))
val () = pats_ccomp_st (p, 88, $UN.cast{ptr} ($UN.cast{lint} (a11)))
val () = pats_ccomp_st (p, 96, $UN.cast{ptr} ($UN.cast{lint} (a12)))
in
  $UN.cast{funlab} (p)
end // end of [funlab_new]

implement
funlab_name
  (x) = $UN.cast{string} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0)))

implement
funlab_level
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 8)))

implement
funlab_funclo
  (x) = $UN.cast{funclo} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 16)))

implement
funlab_type
  (x) = $UN.cast{hisexp} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 24)))

implement
funlab_tmpknd
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 32)))

implement
set_funlab_tmpknd
  (x, v) = pats_ccomp_st ($UN.cast{ptr} (x), 32, $UN.cast{ptr} ($UN.cast{lint} (v)))

implement
funlab_d2copt
  (x) = $UN.cast{d2cstopt} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 40)))

implement
funlab_d2vopt
  (x) = $UN.cast{d2varopt} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 48)))

implement
funlab_ncopy
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 56)))

implement
set_funlab_ncopy
  (x, v) = pats_ccomp_st ($UN.cast{ptr} (x), 56, $UN.cast{ptr} ($UN.cast{lint} (v)))

implement
funlab_origin
  (x) = $UN.cast{funlabopt} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 64)))

implement
set_funlab_origin
  (x, v) = pats_ccomp_st ($UN.cast{ptr} (x), 64, $UN.cast{ptr} ($UN.cast{lint} (v)))

implement
funlab_suffix
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 72)))

implement
set_funlab_suffix
  (x, v) = pats_ccomp_st ($UN.cast{ptr} (x), 72, $UN.cast{ptr} ($UN.cast{lint} (v)))

implement
funlab_tmparg
  (x) = $UN.cast{t2mpmarglst} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 80)))

implement
funlab_funent
  (x) = $UN.cast{funentopt} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 88)))

implement
set_funlab_funent
  (x, v) = pats_ccomp_st ($UN.cast{ptr} (x), 88, $UN.cast{ptr} ($UN.cast{lint} (v)))

implement
funlab_stamp
  (x) = $UN.cast{stamp} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 96)))

(* ****** ****** *)

implement
funent_new
  (a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13) = let
val p = pats_ccomp_alloc (112)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_ccomp_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a4)))
val () = pats_ccomp_st (p, 40, $UN.cast{ptr} ($UN.cast{lint} (a5)))
val () = pats_ccomp_st (p, 48, $UN.cast{ptr} ($UN.cast{lint} (a6)))
val () = pats_ccomp_st (p, 56, $UN.cast{ptr} ($UN.cast{lint} (a7)))
val () = pats_ccomp_st (p, 64, $UN.cast{ptr} ($UN.cast{lint} (a8)))
val () = pats_ccomp_st (p, 72, $UN.cast{ptr} ($UN.cast{lint} (a9)))
val () = pats_ccomp_st (p, 80, $UN.cast{ptr} ($UN.cast{lint} (a10)))
val () = pats_ccomp_st (p, 88, $UN.cast{ptr} ($UN.cast{lint} (a11)))
val () = pats_ccomp_st (p, 96, $UN.cast{ptr} ($UN.cast{lint} (a12)))
val () = pats_ccomp_st (p, 104, $UN.cast{ptr} ($UN.cast{lint} (a13)))
in
  $UN.cast{funent} (p)
end // end of [funent_new]

implement
funent_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0)))

implement
funent_lab
  (x) = $UN.cast{funlab} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 8)))

implement
funent_imparg
  (x) = $UN.cast{s2varlst} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 16)))

implement
funent_tmparg
  (x) = $UN.cast{s2explstlst} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 24)))

implement
funent_tmpsub
  (x) = $UN.cast{tmpsubopt} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 32)))

implement
set_funent_tmpsub
  (x, v) = pats_ccomp_st ($UN.cast{ptr} (x), 32, $UN.cast{ptr} ($UN.cast{lint} (v)))

implement
funent_tmpret
  (x) = $UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 40)))

implement
funent_flablst
  (x) = $UN.cast{funlablst} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 48)))

implement
funent_flablst_fin
  (x) = $UN.cast{funlablstopt} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 56)))

implement
set_funent_flablst_fin
  (x, v) = pats_ccomp_st ($UN.cast{ptr} (x), 56, $UN.cast{ptr} ($UN.cast{lint} (v)))

implement
funent_d2envlst
  (x) = $UN.cast{d2envlst} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 64)))

implement
funent_d2envlst_fin
  (x) = $UN.cast{d2envlstopt} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 72)))

implement
set_funent_d2envlst_fin
  (x, v) = pats_ccomp_st ($UN.cast{ptr} (x), 72, $UN.cast{ptr} ($UN.cast{lint} (v)))

implement
funent_vbindmap
  (x) = $UN.cast{vbindmap} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 80)))

implement
funent_instrlst
  (x) = $UN.cast{instrlst} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 88)))

implement
funent_tmpvarlst
  (x) = $UN.cast{tmpvarlst} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 96)))

implement
funent_fnxlablst
  (x) = $UN.cast{funlablst} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 104)))

implement
set_funent_fnxlablst
  (x, v) = pats_ccomp_st ($UN.cast{ptr} (x), 104, $UN.cast{ptr} ($UN.cast{lint} (v)))

(* ****** ****** *)

implement
tmpsub_TMPSUBcons
  (a0, a1, a2) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{tmpsub} (p)
end // end of [tmpsub_TMPSUBcons]

implement
tmpsub_TMPSUBnil
  () = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
in
  $UN.cast{tmpsub} (p)
end // end of [tmpsub_TMPSUBnil]

implement
tmpsub_encode
  (v) =
(
case+ v of
| ~TMPSUBcons(a0, a1, a2) => tmpsub_TMPSUBcons(a0, a1, a2)
| ~TMPSUBnil() => tmpsub_TMPSUBnil()
) (* end of [tmpsub_encode] *)

implement
tmpsub_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0)))

implement
tmpsub_is_TMPSUBcons
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
tmpsub_is_TMPSUBnil
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
tmpsub_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld (p, 0)))
//
in
//
case+ tag of
| 0 => TMPSUBcons($UN.cast{s2var} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{s2exp} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{tmpsub} ($UN.cast{lint} (pats_ccomp_ld (p, 24))))
| _ => TMPSUBnil()
//
end // end of [tmpsub_view]

implement
tmpsub_view_free
  (v) =
(
case+ v of
| ~TMPSUBcons(_, _, _) => ()
| ~TMPSUBnil() => ()
) (* end of [tmpsub_view_free] *)

(* ****** ****** *)

implement
tmpcstmat_TMPCSTMATnone
  () = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
in
  $UN.cast{tmpcstmat} (p)
end // end of [tmpcstmat_TMPCSTMATnone]

implement
tmpcstmat_TMPCSTMATsome
  (a0, a1, a2) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{tmpcstmat} (p)
end // end of [tmpcstmat_TMPCSTMATsome]

implement
tmpcstmat_TMPCSTMATsome2
  (a0, a1, a2) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{tmpcstmat} (p)
end // end of [tmpcstmat_TMPCSTMATsome2]

implement
tmpcstmat_encode
  (v) =
(
case+ v of
| ~TMPCSTMATnone() => tmpcstmat_TMPCSTMATnone()
| ~TMPCSTMATsome(a0, a1, a2) => tmpcstmat_TMPCSTMATsome(a0, a1, a2)
| ~TMPCSTMATsome2(a0, a1, a2) => tmpcstmat_TMPCSTMATsome2(a0, a1, a2)
) (* end of [tmpcstmat_encode] *)

implement
tmpcstmat_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0)))

implement
tmpcstmat_is_TMPCSTMATnone
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
tmpcstmat_is_TMPCSTMATsome
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
tmpcstmat_is_TMPCSTMATsome2
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
tmpcstmat_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld (p, 0)))
//
in
//
case+ tag of
| 0 => TMPCSTMATnone()
| 1 => TMPCSTMATsome($UN.cast{hiimpdec} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{tmpsub} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld (p, 24))))
| _ => TMPCSTMATsome2($UN.cast{d2cst} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{s2explstlst} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{funlab} ($UN.cast{lint} (pats_ccomp_ld (p, 24))))
//
end // end of [tmpcstmat_view]

implement
tmpcstmat_view_free
  (v) =
(
case+ v of
| ~TMPCSTMATnone() => ()
| ~TMPCSTMATsome(_, _, _) => ()
| ~TMPCSTMATsome2(_, _, _) => ()
) (* end of [tmpcstmat_view_free] *)

(* ****** ****** *)

implement
tmpvarmat_TMPVARMATnone
  () = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
in
  $UN.cast{tmpvarmat} (p)
end // end of [tmpvarmat_TMPVARMATnone]

implement
tmpvarmat_TMPVARMATsome
  (a0, a1, a2) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{tmpvarmat} (p)
end // end of [tmpvarmat_TMPVARMATsome]

implement
tmpvarmat_TMPVARMATsome2
  (a0, a1, a2) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{tmpvarmat} (p)
end // end of [tmpvarmat_TMPVARMATsome2]

implement
tmpvarmat_encode
  (v) =
(
case+ v of
| ~TMPVARMATnone() => tmpvarmat_TMPVARMATnone()
| ~TMPVARMATsome(a0, a1, a2) => tmpvarmat_TMPVARMATsome(a0, a1, a2)
| ~TMPVARMATsome2(a0, a1, a2) => tmpvarmat_TMPVARMATsome2(a0, a1, a2)
) (* end of [tmpvarmat_encode] *)

implement
tmpvarmat_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0)))

implement
tmpvarmat_is_TMPVARMATnone
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
tmpvarmat_is_TMPVARMATsome
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
tmpvarmat_is_TMPVARMATsome2
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
tmpvarmat_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld (p, 0)))
//
in
//
case+ tag of
| 0 => TMPVARMATnone()
| 1 => TMPVARMATsome($UN.cast{hifundec} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{tmpsub} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld (p, 24))))
| _ => TMPVARMATsome2($UN.cast{d2var} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{s2explstlst} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{funlab} ($UN.cast{lint} (pats_ccomp_ld (p, 24))))
//
end // end of [tmpvarmat_view]

implement
tmpvarmat_view_free
  (v) =
(
case+ v of
| ~TMPVARMATnone() => ()
| ~TMPVARMATsome(_, _, _) => ()
| ~TMPVARMATsome2(_, _, _) => ()
) (* end of [tmpvarmat_view_free] *)

(* ****** ****** *)

implement
hifundec2_new
  (a0, a1) = let
val p = pats_ccomp_alloc (16)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{hifundec2} (p)
end // end of [hifundec2_new]

implement
hifundec2_hfd
  (x) = $UN.cast{hifundec} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0)))

implement
hifundec2_sub
  (x) = $UN.cast{tmpsub} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
hiimpdec2_new
  (a0, a1, a2) = let
val p = pats_ccomp_alloc (24)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{hiimpdec2} (p)
end // end of [hiimpdec2_new]

implement
hiimpdec2_imp
  (x) = $UN.cast{hiimpdec} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0)))

implement
hiimpdec2_sub
  (x) = $UN.cast{tmpsub} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 8)))

implement
hiimpdec2_arg
  (x) = $UN.cast{s2explstlst} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
primcstsp_PMCSTSPmyfil
  (a0) = let
val p = pats_ccomp_alloc (16)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primcstsp} (p)
end // end of [primcstsp_PMCSTSPmyfil]

implement
primcstsp_PMCSTSPmyloc
  (a0) = let
val p = pats_ccomp_alloc (16)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primcstsp} (p)
end // end of [primcstsp_PMCSTSPmyloc]

implement
primcstsp_PMCSTSPmyfun
  (a0) = let
val p = pats_ccomp_alloc (16)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primcstsp} (p)
end // end of [primcstsp_PMCSTSPmyfun]

implement
primcstsp_encode
  (v) =
(
case+ v of
| ~PMCSTSPmyfil(a0) => primcstsp_PMCSTSPmyfil(a0)
| ~PMCSTSPmyloc(a0) => primcstsp_PMCSTSPmyloc(a0)
| ~PMCSTSPmyfun(a0) => primcstsp_PMCSTSPmyfun(a0)
) (* end of [primcstsp_encode] *)

implement
primcstsp_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0)))

implement
primcstsp_is_PMCSTSPmyfil
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
primcstsp_is_PMCSTSPmyloc
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
primcstsp_is_PMCSTSPmyfun
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
primcstsp_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld (p, 0)))
//
in
//
case+ tag of
| 0 => PMCSTSPmyfil($UN.cast{filename} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 1 => PMCSTSPmyloc($UN.cast{location} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| _ => PMCSTSPmyfun($UN.cast{funlab} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
//
end // end of [primcstsp_view]

implement
primcstsp_view_free
  (v) =
(
case+ v of
| ~PMCSTSPmyfil(_) => ()
| ~PMCSTSPmyloc(_) => ()
| ~PMCSTSPmyfun(_) => ()
) (* end of [primcstsp_view_free] *)

(* ****** ****** *)

implement
primdec_node_PMDnone
  () = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
in
  $UN.cast{primdec_node} (p)
end // end of [primdec_node_PMDnone]

implement
primdec_node_PMDlist
  (a0) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primdec_node} (p)
end // end of [primdec_node_PMDlist]

implement
primdec_node_PMDsaspdec
  (a0) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primdec_node} (p)
end // end of [primdec_node_PMDsaspdec]

implement
primdec_node_PMDextvar
  (a0, a1) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (3)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{primdec_node} (p)
end // end of [primdec_node_PMDextvar]

implement
primdec_node_PMDdatdecs
  (a0) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (4)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primdec_node} (p)
end // end of [primdec_node_PMDdatdecs]

implement
primdec_node_PMDexndecs
  (a0) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (5)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primdec_node} (p)
end // end of [primdec_node_PMDexndecs]

implement
primdec_node_PMDfundecs
  (a0, a1, a2) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (6)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{primdec_node} (p)
end // end of [primdec_node_PMDfundecs]

implement
primdec_node_PMDvaldecs
  (a0, a1, a2) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (7)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{primdec_node} (p)
end // end of [primdec_node_PMDvaldecs]

implement
primdec_node_PMDvaldecs_rec
  (a0, a1, a2) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (8)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{primdec_node} (p)
end // end of [primdec_node_PMDvaldecs_rec]

implement
primdec_node_PMDvardecs
  (a0, a1) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (9)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{primdec_node} (p)
end // end of [primdec_node_PMDvardecs]

implement
primdec_node_PMDimpdec
  (a0) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (10)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primdec_node} (p)
end // end of [primdec_node_PMDimpdec]

implement
primdec_node_PMDinclude
  (a0, a1) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (11)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{primdec_node} (p)
end // end of [primdec_node_PMDinclude]

implement
primdec_node_PMDstaload
  (a0) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (12)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primdec_node} (p)
end // end of [primdec_node_PMDstaload]

implement
primdec_node_PMDstaloadloc
  (a0, a1, a2) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (13)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{primdec_node} (p)
end // end of [primdec_node_PMDstaloadloc]

implement
primdec_node_PMDdynload
  (a0) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (14)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primdec_node} (p)
end // end of [primdec_node_PMDdynload]

implement
primdec_node_PMDlocal
  (a0, a1) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (15)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{primdec_node} (p)
end // end of [primdec_node_PMDlocal]

implement
primdec_node_encode
  (v) =
(
case+ v of
| ~PMDnone() => primdec_node_PMDnone()
| ~PMDlist(a0) => primdec_node_PMDlist(a0)
| ~PMDsaspdec(a0) => primdec_node_PMDsaspdec(a0)
| ~PMDextvar(a0, a1) => primdec_node_PMDextvar(a0, a1)
| ~PMDdatdecs(a0) => primdec_node_PMDdatdecs(a0)
| ~PMDexndecs(a0) => primdec_node_PMDexndecs(a0)
| ~PMDfundecs(a0, a1, a2) => primdec_node_PMDfundecs(a0, a1, a2)
| ~PMDvaldecs(a0, a1, a2) => primdec_node_PMDvaldecs(a0, a1, a2)
| ~PMDvaldecs_rec(a0, a1, a2) => primdec_node_PMDvaldecs_rec(a0, a1, a2)
| ~PMDvardecs(a0, a1) => primdec_node_PMDvardecs(a0, a1)
| ~PMDimpdec(a0) => primdec_node_PMDimpdec(a0)
| ~PMDinclude(a0, a1) => primdec_node_PMDinclude(a0, a1)
| ~PMDstaload(a0) => primdec_node_PMDstaload(a0)
| ~PMDstaloadloc(a0, a1, a2) => primdec_node_PMDstaloadloc(a0, a1, a2)
| ~PMDdynload(a0) => primdec_node_PMDdynload(a0)
| ~PMDlocal(a0, a1) => primdec_node_PMDlocal(a0, a1)
) (* end of [primdec_node_encode] *)

implement
primdec_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0)))

implement
primdec_node_is_PMDnone
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
primdec_node_is_PMDlist
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
primdec_node_is_PMDsaspdec
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
primdec_node_is_PMDextvar
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 3)

implement
primdec_node_is_PMDdatdecs
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 4)

implement
primdec_node_is_PMDexndecs
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 5)

implement
primdec_node_is_PMDfundecs
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 6)

implement
primdec_node_is_PMDvaldecs
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 7)

implement
primdec_node_is_PMDvaldecs_rec
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 8)

implement
primdec_node_is_PMDvardecs
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 9)

implement
primdec_node_is_PMDimpdec
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 10)

implement
primdec_node_is_PMDinclude
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 11)

implement
primdec_node_is_PMDstaload
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 12)

implement
primdec_node_is_PMDstaloadloc
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 13)

implement
primdec_node_is_PMDdynload
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 14)

implement
primdec_node_is_PMDlocal
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 15)

implement
primdec_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld (p, 0)))
//
in
//
case+ tag of
| 0 => PMDnone()
| 1 => PMDlist($UN.cast{primdeclst} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 2 => PMDsaspdec($UN.cast{s2aspdec} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 3 => PMDextvar($UN.cast{string} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{instrlst} ($UN.cast{lint} (pats_ccomp_ld (p, 16))))
| 4 => PMDdatdecs($UN.cast{s2cstlst} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 5 => PMDexndecs($UN.cast{d2conlst} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 6 => PMDfundecs($UN.cast{funkind} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{s2qualst} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{hifundeclst} ($UN.cast{lint} (pats_ccomp_ld (p, 24))))
| 7 => PMDvaldecs($UN.cast{valkind} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{hivaldeclst} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{instrlst} ($UN.cast{lint} (pats_ccomp_ld (p, 24))))
| 8 => PMDvaldecs_rec($UN.cast{valkind} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{hivaldeclst} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{instrlst} ($UN.cast{lint} (pats_ccomp_ld (p, 24))))
| 9 => PMDvardecs($UN.cast{hivardeclst} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{instrlst} ($UN.cast{lint} (pats_ccomp_ld (p, 16))))
| 10 => PMDimpdec($UN.cast{hiimpdec} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 11 => PMDinclude($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{primdeclst} ($UN.cast{lint} (pats_ccomp_ld (p, 16))))
| 12 => PMDstaload($UN.cast{hidecl} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 13 => PMDstaloadloc($UN.cast{filename} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{symbol} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{primdeclst} ($UN.cast{lint} (pats_ccomp_ld (p, 24))))
| 14 => PMDdynload($UN.cast{hidecl} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| _ => PMDlocal($UN.cast{primdeclst} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{primdeclst} ($UN.cast{lint} (pats_ccomp_ld (p, 16))))
//
end // end of [primdec_node_view]

implement
primdec_node_view_free
  (v) =
(
case+ v of
| ~PMDnone() => ()
| ~PMDlist(_) => ()
| ~PMDsaspdec(_) => ()
| ~PMDextvar(_, _) => ()
| ~PMDdatdecs(_) => ()
| ~PMDexndecs(_) => ()
| ~PMDfundecs(_, _, _) => ()
| ~PMDvaldecs(_, _, _) => ()
| ~PMDvaldecs_rec(_, _, _) => ()
| ~PMDvardecs(_, _) => ()
| ~PMDimpdec(_) => ()
| ~PMDinclude(_, _) => ()
| ~PMDstaload(_) => ()
| ~PMDstaloadloc(_, _, _) => ()
| ~PMDdynload(_) => ()
| ~PMDlocal(_, _) => ()
) (* end of [primdec_node_view_free] *)

(* ****** ****** *)

implement
primval_node_PMVtmp
  (a0) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVtmp]

implement
primval_node_PMVtmpref
  (a0) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVtmpref]

implement
primval_node_PMVarg
  (a0) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVarg]

implement
primval_node_PMVargref
  (a0) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (3)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVargref]

implement
primval_node_PMVargenv
  (a0) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (4)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVargenv]

implement
primval_node_PMVargtmpref
  (a0) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (5)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVargtmpref]

implement
primval_node_PMVcst
  (a0) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (6)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVcst]

implement
primval_node_PMVenv
  (a0) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (7)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVenv]

implement
primval_node_PMVint
  (a0) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (8)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVint]

implement
primval_node_PMVintrep
  (a0) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (9)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVintrep]

implement
primval_node_PMVbool
  (a0) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (10)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVbool]

implement
primval_node_PMVchar
  (a0) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (11)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVchar]

implement
primval_node_PMVfloat
  (a0) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (12)))
val () = pats_ccomp_std (p, 8, a0)
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVfloat]

implement
primval_node_PMVstring
  (a0) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (13)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVstring]

implement
primval_node_PMVi0nt
  (a0) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (14)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVi0nt]

implement
primval_node_PMVf0loat
  (a0) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (15)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVf0loat]

implement
primval_node_PMVcstsp
  (a0) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (16)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVcstsp]

implement
primval_node_PMVtyrep
  (a0) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (17)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVtyrep]

implement
primval_node_PMVsizeof
  (a0) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (18)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVsizeof]

implement
primval_node_PMVtop
  () = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (19)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVtop]

implement
primval_node_PMVempty
  () = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (20)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVempty]

implement
primval_node_PMVextval
  (a0) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (21)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVextval]

implement
primval_node_PMVcastfn
  (a0, a1) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (22)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVcastfn]

implement
primval_node_PMVselcon
  (a0, a1, a2) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (23)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVselcon]

implement
primval_node_PMVselect
  (a0, a1, a2) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (24)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVselect]

implement
primval_node_PMVselect2
  (a0, a1, a2) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (25)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVselect2]

implement
primval_node_PMVselptr
  (a0, a1, a2) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (26)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVselptr]

implement
primval_node_PMVptrof
  (a0) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (27)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVptrof]

implement
primval_node_PMVptrofsel
  (a0, a1, a2) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (28)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVptrofsel]

implement
primval_node_PMVvararg
  (a0) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (29)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVvararg]

implement
primval_node_PMVrefarg
  (a0, a1, a2) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (30)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVrefarg]

implement
primval_node_PMVfunlab
  (a0) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (31)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVfunlab]

implement
primval_node_PMVcfunlab
  (a0, a1) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (32)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVcfunlab]

implement
primval_node_PMVd2vfunlab
  (a0, a1) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (33)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVd2vfunlab]

implement
primval_node_PMVlamfix
  (a0, a1) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (34)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVlamfix]

implement
primval_node_PMVtmpltcst
  (a0, a1) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (35)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVtmpltcst]

implement
primval_node_PMVtmpltvar
  (a0, a1) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (36)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVtmpltvar]

implement
primval_node_PMVtmpltcstmat
  (a0, a1, a2) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (37)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVtmpltcstmat]

implement
primval_node_PMVtmpltvarmat
  (a0, a1, a2) = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (38)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVtmpltvarmat]

implement
primval_node_PMVerror
  () = let
val p = pats_ccomp_alloc (32)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (39)))
in
  $UN.cast{primval_node} (p)
end // end of [primval_node_PMVerror]

implement
primval_node_encode
  (v) =
(
case+ v of
| ~PMVtmp(a0) => primval_node_PMVtmp(a0)
| ~PMVtmpref(a0) => primval_node_PMVtmpref(a0)
| ~PMVarg(a0) => primval_node_PMVarg(a0)
| ~PMVargref(a0) => primval_node_PMVargref(a0)
| ~PMVargenv(a0) => primval_node_PMVargenv(a0)
| ~PMVargtmpref(a0) => primval_node_PMVargtmpref(a0)
| ~PMVcst(a0) => primval_node_PMVcst(a0)
| ~PMVenv(a0) => primval_node_PMVenv(a0)
| ~PMVint(a0) => primval_node_PMVint(a0)
| ~PMVintrep(a0) => primval_node_PMVintrep(a0)
| ~PMVbool(a0) => primval_node_PMVbool(a0)
| ~PMVchar(a0) => primval_node_PMVchar(a0)
| ~PMVfloat(a0) => primval_node_PMVfloat(a0)
| ~PMVstring(a0) => primval_node_PMVstring(a0)
| ~PMVi0nt(a0) => primval_node_PMVi0nt(a0)
| ~PMVf0loat(a0) => primval_node_PMVf0loat(a0)
| ~PMVcstsp(a0) => primval_node_PMVcstsp(a0)
| ~PMVtyrep(a0) => primval_node_PMVtyrep(a0)
| ~PMVsizeof(a0) => primval_node_PMVsizeof(a0)
| ~PMVtop() => primval_node_PMVtop()
| ~PMVempty() => primval_node_PMVempty()
| ~PMVextval(a0) => primval_node_PMVextval(a0)
| ~PMVcastfn(a0, a1) => primval_node_PMVcastfn(a0, a1)
| ~PMVselcon(a0, a1, a2) => primval_node_PMVselcon(a0, a1, a2)
| ~PMVselect(a0, a1, a2) => primval_node_PMVselect(a0, a1, a2)
| ~PMVselect2(a0, a1, a2) => primval_node_PMVselect2(a0, a1, a2)
| ~PMVselptr(a0, a1, a2) => primval_node_PMVselptr(a0, a1, a2)
| ~PMVptrof(a0) => primval_node_PMVptrof(a0)
| ~PMVptrofsel(a0, a1, a2) => primval_node_PMVptrofsel(a0, a1, a2)
| ~PMVvararg(a0) => primval_node_PMVvararg(a0)
| ~PMVrefarg(a0, a1, a2) => primval_node_PMVrefarg(a0, a1, a2)
| ~PMVfunlab(a0) => primval_node_PMVfunlab(a0)
| ~PMVcfunlab(a0, a1) => primval_node_PMVcfunlab(a0, a1)
| ~PMVd2vfunlab(a0, a1) => primval_node_PMVd2vfunlab(a0, a1)
| ~PMVlamfix(a0, a1) => primval_node_PMVlamfix(a0, a1)
| ~PMVtmpltcst(a0, a1) => primval_node_PMVtmpltcst(a0, a1)
| ~PMVtmpltvar(a0, a1) => primval_node_PMVtmpltvar(a0, a1)
| ~PMVtmpltcstmat(a0, a1, a2) => primval_node_PMVtmpltcstmat(a0, a1, a2)
| ~PMVtmpltvarmat(a0, a1, a2) => primval_node_PMVtmpltvarmat(a0, a1, a2)
| ~PMVerror() => primval_node_PMVerror()
) (* end of [primval_node_encode] *)

implement
primval_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0)))

implement
primval_node_is_PMVtmp
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
primval_node_is_PMVtmpref
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
primval_node_is_PMVarg
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
primval_node_is_PMVargref
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 3)

implement
primval_node_is_PMVargenv
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 4)

implement
primval_node_is_PMVargtmpref
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 5)

implement
primval_node_is_PMVcst
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 6)

implement
primval_node_is_PMVenv
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 7)

implement
primval_node_is_PMVint
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 8)

implement
primval_node_is_PMVintrep
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 9)

implement
primval_node_is_PMVbool
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 10)

implement
primval_node_is_PMVchar
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 11)

implement
primval_node_is_PMVfloat
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 12)

implement
primval_node_is_PMVstring
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 13)

implement
primval_node_is_PMVi0nt
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 14)

implement
primval_node_is_PMVf0loat
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 15)

implement
primval_node_is_PMVcstsp
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 16)

implement
primval_node_is_PMVtyrep
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 17)

implement
primval_node_is_PMVsizeof
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 18)

implement
primval_node_is_PMVtop
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 19)

implement
primval_node_is_PMVempty
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 20)

implement
primval_node_is_PMVextval
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 21)

implement
primval_node_is_PMVcastfn
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 22)

implement
primval_node_is_PMVselcon
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 23)

implement
primval_node_is_PMVselect
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 24)

implement
primval_node_is_PMVselect2
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 25)

implement
primval_node_is_PMVselptr
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 26)

implement
primval_node_is_PMVptrof
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 27)

implement
primval_node_is_PMVptrofsel
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 28)

implement
primval_node_is_PMVvararg
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 29)

implement
primval_node_is_PMVrefarg
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 30)

implement
primval_node_is_PMVfunlab
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 31)

implement
primval_node_is_PMVcfunlab
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 32)

implement
primval_node_is_PMVd2vfunlab
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 33)

implement
primval_node_is_PMVlamfix
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 34)

implement
primval_node_is_PMVtmpltcst
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 35)

implement
primval_node_is_PMVtmpltvar
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 36)

implement
primval_node_is_PMVtmpltcstmat
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 37)

implement
primval_node_is_PMVtmpltvarmat
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 38)

implement
primval_node_is_PMVerror
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 39)

implement
primval_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld (p, 0)))
//
in
//
case+ tag of
| 0 => PMVtmp($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 1 => PMVtmpref($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 2 => PMVarg($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 3 => PMVargref($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 4 => PMVargenv($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 5 => PMVargtmpref($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 6 => PMVcst($UN.cast{d2cst} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 7 => PMVenv($UN.cast{d2var} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 8 => PMVint($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 9 => PMVintrep($UN.cast{string} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 10 => PMVbool($UN.cast{bool} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 11 => PMVchar($UN.cast{char} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 12 => PMVfloat(pats_ccomp_ldd (p, 8))
| 13 => PMVstring($UN.cast{string} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 14 => PMVi0nt($UN.cast{i0nt} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 15 => PMVf0loat($UN.cast{f0loat} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 16 => PMVcstsp($UN.cast{primcstsp} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 17 => PMVtyrep($UN.cast{hisexp} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 18 => PMVsizeof($UN.cast{hisexp} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 19 => PMVtop()
| 20 => PMVempty()
| 21 => PMVextval($UN.cast{string} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 22 => PMVcastfn($UN.cast{d2cst} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 16))))
| 23 => PMVselcon($UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{hisexp} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{label} ($UN.cast{lint} (pats_ccomp_ld (p, 24))))
| 24 => PMVselect($UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{hisexp} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{primlab} ($UN.cast{lint} (pats_ccomp_ld (p, 24))))
| 25 => PMVselect2($UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{hisexp} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{primlablst} ($UN.cast{lint} (pats_ccomp_ld (p, 24))))
| 26 => PMVselptr($UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{hisexp} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{primlablst} ($UN.cast{lint} (pats_ccomp_ld (p, 24))))
| 27 => PMVptrof($UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 28 => PMVptrofsel($UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{hisexp} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{primlablst} ($UN.cast{lint} (pats_ccomp_ld (p, 24))))
| 29 => PMVvararg($UN.cast{primvalist} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 30 => PMVrefarg($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 24))))
| 31 => PMVfunlab($UN.cast{funlab} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 32 => PMVcfunlab($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{funlab} ($UN.cast{lint} (pats_ccomp_ld (p, 16))))
| 33 => PMVd2vfunlab($UN.cast{d2var} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{funlab} ($UN.cast{lint} (pats_ccomp_ld (p, 16))))
| 34 => PMVlamfix($UN.cast{d2varopt} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 16))))
| 35 => PMVtmpltcst($UN.cast{d2cst} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{t2mpmarglst} ($UN.cast{lint} (pats_ccomp_ld (p, 16))))
| 36 => PMVtmpltvar($UN.cast{d2var} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{t2mpmarglst} ($UN.cast{lint} (pats_ccomp_ld (p, 16))))
| 37 => PMVtmpltcstmat($UN.cast{d2cst} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{t2mpmarglst} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{tmpcstmat} ($UN.cast{lint} (pats_ccomp_ld (p, 24))))
| 38 => PMVtmpltvarmat($UN.cast{d2var} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{t2mpmarglst} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{tmpvarmat} ($UN.cast{lint} (pats_ccomp_ld (p, 24))))
| _ => PMVerror()
//
end // end of [primval_node_view]

implement
primval_node_view_free
  (v) =
(
case+ v of
| ~PMVtmp(_) => ()
| ~PMVtmpref(_) => ()
| ~PMVarg(_) => ()
| ~PMVargref(_) => ()
| ~PMVargenv(_) => ()
| ~PMVargtmpref(_) => ()
| ~PMVcst(_) => ()
| ~PMVenv(_) => ()
| ~PMVint(_) => ()
| ~PMVintrep(_) => ()
| ~PMVbool(_) => ()
| ~PMVchar(_) => ()
| ~PMVfloat(_) => ()
| ~PMVstring(_) => ()
| ~PMVi0nt(_) => ()
| ~PMVf0loat(_) => ()
| ~PMVcstsp(_) => ()
| ~PMVtyrep(_) => ()
| ~PMVsizeof(_) => ()
| ~PMVtop() => ()
| ~PMVempty() => ()
| ~PMVextval(_) => ()
| ~PMVcastfn(_, _) => ()
| ~PMVselcon(_, _, _) => ()
| ~PMVselect(_, _, _) => ()
| ~PMVselect2(_, _, _) => ()
| ~PMVselptr(_, _, _) => ()
| ~PMVptrof(_) => ()
| ~PMVptrofsel(_, _, _) => ()
| ~PMVvararg(_) => ()
| ~PMVrefarg(_, _, _) => ()
| ~PMVfunlab(_) => ()
| ~PMVcfunlab(_, _) => ()
| ~PMVd2vfunlab(_, _) => ()
| ~PMVlamfix(_, _) => ()
| ~PMVtmpltcst(_, _) => ()
| ~PMVtmpltvar(_, _) => ()
| ~PMVtmpltcstmat(_, _, _) => ()
| ~PMVtmpltvarmat(_, _, _) => ()
| ~PMVerror() => ()
) (* end of [primval_node_view_free] *)

(* ****** ****** *)

implement
primlab_node_PMLlab
  (a0) = let
val p = pats_ccomp_alloc (16)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primlab_node} (p)
end // end of [primlab_node_PMLlab]

implement
primlab_node_PMLind
  (a0) = let
val p = pats_ccomp_alloc (16)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{primlab_node} (p)
end // end of [primlab_node_PMLind]

implement
primlab_node_encode
  (v) =
(
case+ v of
| ~PMLlab(a0) => primlab_node_PMLlab(a0)
| ~PMLind(a0) => primlab_node_PMLind(a0)
) (* end of [primlab_node_encode] *)

implement
primlab_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0)))

implement
primlab_node_is_PMLlab
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
primlab_node_is_PMLind
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
primlab_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld (p, 0)))
//
in
//
case+ tag of
| 0 => PMLlab($UN.cast{label} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| _ => PMLind($UN.cast{primvalist} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
//
end // end of [primlab_node_view]

implement
primlab_node_view_free
  (v) =
(
case+ v of
| ~PMLlab(_) => ()
| ~PMLind(_) => ()
) (* end of [primlab_node_view_free] *)

(* ****** ****** *)

implement
labprimval_new
  (a0, a1) = let
val p = pats_ccomp_alloc (16)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{labprimval} (p)
end // end of [labprimval_new]

implement
labprimval_lab
  (x) = $UN.cast{label} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0)))

implement
labprimval_elt
  (x) = $UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
primdec_new
  (a0, a1) = let
val p = pats_ccomp_alloc (16)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{primdec} (p)
end // end of [primdec_new]

implement
primdec_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0)))

implement
primdec_node
  (x) = $UN.cast{primdec_node} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
primval_new
  (a0, a1, a2) = let
val p = pats_ccomp_alloc (24)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{primval} (p)
end // end of [primval_new]

implement
primval_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0)))

implement
primval_type
  (x) = $UN.cast{hisexp} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 8)))

implement
primval_node
  (x) = $UN.cast{primval_node} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
primlab_new
  (a0, a1) = let
val p = pats_ccomp_alloc (16)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{primlab} (p)
end // end of [primlab_new]

implement
primlab_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0)))

implement
primlab_node
  (x) = $UN.cast{primlab_node} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
patck_PATCKcon
  (a0) = let
val p = pats_ccomp_alloc (16)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{patck} (p)
end // end of [patck_PATCKcon]

implement
patck_PATCKint
  (a0) = let
val p = pats_ccomp_alloc (16)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{patck} (p)
end // end of [patck_PATCKint]

implement
patck_PATCKbool
  (a0) = let
val p = pats_ccomp_alloc (16)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{patck} (p)
end // end of [patck_PATCKbool]

implement
patck_PATCKchar
  (a0) = let
val p = pats_ccomp_alloc (16)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (3)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{patck} (p)
end // end of [patck_PATCKchar]

implement
patck_PATCKfloat
  (a0) = let
val p = pats_ccomp_alloc (16)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (4)))
val () = pats_ccomp_std (p, 8, a0)
in
  $UN.cast{patck} (p)
end // end of [patck_PATCKfloat]

implement
patck_PATCKstring
  (a0) = let
val p = pats_ccomp_alloc (16)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (5)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{patck} (p)
end // end of [patck_PATCKstring]

implement
patck_PATCKi0nt
  (a0) = let
val p = pats_ccomp_alloc (16)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (6)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{patck} (p)
end // end of [patck_PATCKi0nt]

implement
patck_PATCKf0loat
  (a0) = let
val p = pats_ccomp_alloc (16)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (7)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{patck} (p)
end // end of [patck_PATCKf0loat]

implement
patck_encode
  (v) =
(
case+ v of
| ~PATCKcon(a0) => patck_PATCKcon(a0)
| ~PATCKint(a0) => patck_PATCKint(a0)
| ~PATCKbool(a0) => patck_PATCKbool(a0)
| ~PATCKchar(a0) => patck_PATCKchar(a0)
| ~PATCKfloat(a0) => patck_PATCKfloat(a0)
| ~PATCKstring(a0) => patck_PATCKstring(a0)
| ~PATCKi0nt(a0) => patck_PATCKi0nt(a0)
| ~PATCKf0loat(a0) => patck_PATCKf0loat(a0)
) (* end of [patck_encode] *)

implement
patck_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0)))

implement
patck_is_PATCKcon
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
patck_is_PATCKint
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
patck_is_PATCKbool
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
patck_is_PATCKchar
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 3)

implement
patck_is_PATCKfloat
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 4)

implement
patck_is_PATCKstring
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 5)

implement
patck_is_PATCKi0nt
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 6)

implement
patck_is_PATCKf0loat
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 7)

implement
patck_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld (p, 0)))
//
in
//
case+ tag of
| 0 => PATCKcon($UN.cast{d2con} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 1 => PATCKint($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 2 => PATCKbool($UN.cast{bool} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 3 => PATCKchar($UN.cast{char} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 4 => PATCKfloat(pats_ccomp_ldd (p, 8))
| 5 => PATCKstring($UN.cast{string} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 6 => PATCKi0nt($UN.cast{i0nt} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| _ => PATCKf0loat($UN.cast{f0loat} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
//
end // end of [patck_view]

implement
patck_view_free
  (v) =
(
case+ v of
| ~PATCKcon(_) => ()
| ~PATCKint(_) => ()
| ~PATCKbool(_) => ()
| ~PATCKchar(_) => ()
| ~PATCKfloat(_) => ()
| ~PATCKstring(_) => ()
| ~PATCKi0nt(_) => ()
| ~PATCKf0loat(_) => ()
) (* end of [patck_view_free] *)

(* ****** ****** *)

implement
tmprimval_TPMVnone
  (a0) = let
val p = pats_ccomp_alloc (24)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{tmprimval} (p)
end // end of [tmprimval_TPMVnone]

implement
tmprimval_TPMVsome
  (a0, a1) = let
val p = pats_ccomp_alloc (24)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{tmprimval} (p)
end // end of [tmprimval_TPMVsome]

implement
tmprimval_encode
  (v) =
(
case+ v of
| ~TPMVnone(a0) => tmprimval_TPMVnone(a0)
| ~TPMVsome(a0, a1) => tmprimval_TPMVsome(a0, a1)
) (* end of [tmprimval_encode] *)

implement
tmprimval_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0)))

implement
tmprimval_is_TPMVnone
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
tmprimval_is_TPMVsome
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
tmprimval_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld (p, 0)))
//
in
//
case+ tag of
| 0 => TPMVnone($UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| _ => TPMVsome($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 16))))
//
end // end of [tmprimval_view]

implement
tmprimval_view_free
  (v) =
(
case+ v of
| ~TPMVnone(_) => ()
| ~TPMVsome(_, _) => ()
) (* end of [tmprimval_view_free] *)

(* ****** ****** *)

implement
tmpmov_new
  (a0, a1) = let
val p = pats_ccomp_alloc (16)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{tmpmov} (p)
end // end of [tmpmov_new]

implement
tmpmov_src
  (x) = $UN.cast{tmprimval} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0)))

implement
tmpmov_dst
  (x) = $UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
patckont_PTCKNTnone
  () = let
val p = pats_ccomp_alloc (24)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
in
  $UN.cast{patckont} (p)
end // end of [patckont_PTCKNTnone]

implement
patckont_PTCKNTtmplab
  (a0) = let
val p = pats_ccomp_alloc (24)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{patckont} (p)
end // end of [patckont_PTCKNTtmplab]

implement
patckont_PTCKNTtmplabint
  (a0, a1) = let
val p = pats_ccomp_alloc (24)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{patckont} (p)
end // end of [patckont_PTCKNTtmplabint]

implement
patckont_PTCKNTtmplabmov
  (a0, a1) = let
val p = pats_ccomp_alloc (24)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (3)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{patckont} (p)
end // end of [patckont_PTCKNTtmplabmov]

implement
patckont_PTCKNTcaseof_fail
  (a0) = let
val p = pats_ccomp_alloc (24)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (4)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{patckont} (p)
end // end of [patckont_PTCKNTcaseof_fail]

implement
patckont_PTCKNTfunarg_fail
  (a0, a1) = let
val p = pats_ccomp_alloc (24)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (5)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{patckont} (p)
end // end of [patckont_PTCKNTfunarg_fail]

implement
patckont_PTCKNTraise
  (a0, a1) = let
val p = pats_ccomp_alloc (24)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (6)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{patckont} (p)
end // end of [patckont_PTCKNTraise]

implement
patckont_encode
  (v) =
(
case+ v of
| ~PTCKNTnone() => patckont_PTCKNTnone()
| ~PTCKNTtmplab(a0) => patckont_PTCKNTtmplab(a0)
| ~PTCKNTtmplabint(a0, a1) => patckont_PTCKNTtmplabint(a0, a1)
| ~PTCKNTtmplabmov(a0, a1) => patckont_PTCKNTtmplabmov(a0, a1)
| ~PTCKNTcaseof_fail(a0) => patckont_PTCKNTcaseof_fail(a0)
| ~PTCKNTfunarg_fail(a0, a1) => patckont_PTCKNTfunarg_fail(a0, a1)
| ~PTCKNTraise(a0, a1) => patckont_PTCKNTraise(a0, a1)
) (* end of [patckont_encode] *)

implement
patckont_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0)))

implement
patckont_is_PTCKNTnone
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
patckont_is_PTCKNTtmplab
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
patckont_is_PTCKNTtmplabint
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
patckont_is_PTCKNTtmplabmov
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 3)

implement
patckont_is_PTCKNTcaseof_fail
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 4)

implement
patckont_is_PTCKNTfunarg_fail
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 5)

implement
patckont_is_PTCKNTraise
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 6)

implement
patckont_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld (p, 0)))
//
in
//
case+ tag of
| 0 => PTCKNTnone()
| 1 => PTCKNTtmplab($UN.cast{tmplab} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 2 => PTCKNTtmplabint($UN.cast{tmplab} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld (p, 16))))
| 3 => PTCKNTtmplabmov($UN.cast{tmplab} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{tmpmovlst} ($UN.cast{lint} (pats_ccomp_ld (p, 16))))
| 4 => PTCKNTcaseof_fail($UN.cast{location} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 5 => PTCKNTfunarg_fail($UN.cast{location} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{funlab} ($UN.cast{lint} (pats_ccomp_ld (p, 16))))
| _ => PTCKNTraise($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 16))))
//
end // end of [patckont_view]

implement
patckont_view_free
  (v) =
(
case+ v of
| ~PTCKNTnone() => ()
| ~PTCKNTtmplab(_) => ()
| ~PTCKNTtmplabint(_, _) => ()
| ~PTCKNTtmplabmov(_, _) => ()
| ~PTCKNTcaseof_fail(_) => ()
| ~PTCKNTfunarg_fail(_, _) => ()
| ~PTCKNTraise(_, _) => ()
) (* end of [patckont_view_free] *)

(* ****** ****** *)

implement
instr_node_INSfunlab
  (a0) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSfunlab]

implement
instr_node_INStmplab
  (a0) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INStmplab]

implement
instr_node_INScomment
  (a0) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INScomment]

implement
instr_node_INSmove_val
  (a0, a1) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (3)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSmove_val]

implement
instr_node_INSpmove_val
  (a0, a1) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (4)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSpmove_val]

implement
instr_node_INSmove_arg_val
  (a0, a1) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (5)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSmove_arg_val]

implement
instr_node_INSfcall
  (a0, a1, a2, a3) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (6)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_ccomp_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSfcall]

implement
instr_node_INSfcall2
  (a0, a1, a2, a3, a4) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (7)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_ccomp_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_ccomp_st (p, 40, $UN.cast{ptr} ($UN.cast{lint} (a4)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSfcall2]

implement
instr_node_INSextfcall
  (a0, a1, a2) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (8)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSextfcall]

implement
instr_node_INSextmcall
  (a0, a1, a2, a3) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (9)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_ccomp_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSextmcall]

implement
instr_node_INScond
  (a0, a1, a2) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (10)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INScond]

implement
instr_node_INSfreecon
  (a0) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (11)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSfreecon]

implement
instr_node_INSloop
  (a0, a1, a2, a3, a4, a5, a6, a7) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (12)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_ccomp_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_ccomp_st (p, 40, $UN.cast{ptr} ($UN.cast{lint} (a4)))
val () = pats_ccomp_st (p, 48, $UN.cast{ptr} ($UN.cast{lint} (a5)))
val () = pats_ccomp_st (p, 56, $UN.cast{ptr} ($UN.cast{lint} (a6)))
val () = pats_ccomp_st (p, 64, $UN.cast{ptr} ($UN.cast{lint} (a7)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSloop]

implement
instr_node_INSloopexn
  (a0, a1) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (13)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSloopexn]

implement
instr_node_INScaseof
  (a0) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (14)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INScaseof]

implement
instr_node_INSletpop
  () = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (15)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSletpop]

implement
instr_node_INSletpush
  (a0) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (16)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSletpush]

implement
instr_node_INSmove_con
  (a0, a1, a2, a3) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (17)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_ccomp_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSmove_con]

implement
instr_node_INSmove_ref
  (a0, a1) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (18)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSmove_ref]

implement
instr_node_INSmove_boxrec
  (a0, a1, a2) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (19)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSmove_boxrec]

implement
instr_node_INSmove_fltrec
  (a0, a1, a2) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (20)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSmove_fltrec]

implement
instr_node_INSpatck
  (a0, a1, a2) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (21)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSpatck]

implement
instr_node_INSmove_ptrofsel
  (a0, a1, a2, a3) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (22)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_ccomp_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSmove_ptrofsel]

implement
instr_node_INSstore_ptrofs
  (a0, a1, a2, a3) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (23)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_ccomp_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSstore_ptrofs]

implement
instr_node_INSxstore_ptrofs
  (a0, a1, a2, a3, a4) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (24)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_ccomp_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_ccomp_st (p, 40, $UN.cast{ptr} ($UN.cast{lint} (a4)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSxstore_ptrofs]

implement
instr_node_INSraise
  (a0, a1) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (25)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSraise]

implement
instr_node_INSmove_delay
  (a0, a1, a2, a3) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (26)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_ccomp_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSmove_delay]

implement
instr_node_INSmove_lazyeval
  (a0, a1, a2, a3) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (27)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_ccomp_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSmove_lazyeval]

implement
instr_node_INStrywith
  (a0, a1, a2) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (28)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INStrywith]

implement
instr_node_INSmove_list_nil
  (a0) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (29)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSmove_list_nil]

implement
instr_node_INSpmove_list_nil
  (a0) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (30)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSpmove_list_nil]

implement
instr_node_INSpmove_list_cons
  (a0, a1) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (31)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSpmove_list_cons]

implement
instr_node_INSmove_list_phead
  (a0, a1, a2) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (32)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSmove_list_phead]

implement
instr_node_INSmove_list_ptail
  (a0, a1, a2) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (33)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSmove_list_ptail]

implement
instr_node_INSmove_arrpsz_ptr
  (a0, a1) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (34)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSmove_arrpsz_ptr]

implement
instr_node_INSstore_arrpsz_asz
  (a0, a1) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (35)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSstore_arrpsz_asz]

implement
instr_node_INSstore_arrpsz_ptr
  (a0, a1, a2) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (36)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSstore_arrpsz_ptr]

implement
instr_node_INSupdate_ptrinc
  (a0, a1) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (37)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSupdate_ptrinc]

implement
instr_node_INSupdate_ptrdec
  (a0, a1) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (38)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSupdate_ptrdec]

implement
instr_node_INSclosure_initize
  (a0, a1, a2) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (39)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSclosure_initize]

implement
instr_node_INStmpdec
  (a0) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (40)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INStmpdec]

implement
instr_node_INSextvar
  (a0, a1) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (41)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSextvar]

implement
instr_node_INSdcstdef
  (a0, a1) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (42)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INSdcstdef]

implement
instr_node_INStempenver
  (a0) = let
val p = pats_ccomp_alloc (72)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (43)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{instr_node} (p)
end // end of [instr_node_INStempenver]

implement
instr_node_encode
  (v) =
(
case+ v of
| ~INSfunlab(a0) => instr_node_INSfunlab(a0)
| ~INStmplab(a0) => instr_node_INStmplab(a0)
| ~INScomment(a0) => instr_node_INScomment(a0)
| ~INSmove_val(a0, a1) => instr_node_INSmove_val(a0, a1)
| ~INSpmove_val(a0, a1) => instr_node_INSpmove_val(a0, a1)
| ~INSmove_arg_val(a0, a1) => instr_node_INSmove_arg_val(a0, a1)
| ~INSfcall(a0, a1, a2, a3) => instr_node_INSfcall(a0, a1, a2, a3)
| ~INSfcall2(a0, a1, a2, a3, a4) => instr_node_INSfcall2(a0, a1, a2, a3, a4)
| ~INSextfcall(a0, a1, a2) => instr_node_INSextfcall(a0, a1, a2)
| ~INSextmcall(a0, a1, a2, a3) => instr_node_INSextmcall(a0, a1, a2, a3)
| ~INScond(a0, a1, a2) => instr_node_INScond(a0, a1, a2)
| ~INSfreecon(a0) => instr_node_INSfreecon(a0)
| ~INSloop(a0, a1, a2, a3, a4, a5, a6, a7) => instr_node_INSloop(a0, a1, a2, a3, a4, a5, a6, a7)
| ~INSloopexn(a0, a1) => instr_node_INSloopexn(a0, a1)
| ~INScaseof(a0) => instr_node_INScaseof(a0)
| ~INSletpop() => instr_node_INSletpop()
| ~INSletpush(a0) => instr_node_INSletpush(a0)
| ~INSmove_con(a0, a1, a2, a3) => instr_node_INSmove_con(a0, a1, a2, a3)
| ~INSmove_ref(a0, a1) => instr_node_INSmove_ref(a0, a1)
| ~INSmove_boxrec(a0, a1, a2) => instr_node_INSmove_boxrec(a0, a1, a2)
| ~INSmove_fltrec(a0, a1, a2) => instr_node_INSmove_fltrec(a0, a1, a2)
| ~INSpatck(a0, a1, a2) => instr_node_INSpatck(a0, a1, a2)
| ~INSmove_ptrofsel(a0, a1, a2, a3) => instr_node_INSmove_ptrofsel(a0, a1, a2, a3)
| ~INSstore_ptrofs(a0, a1, a2, a3) => instr_node_INSstore_ptrofs(a0, a1, a2, a3)
| ~INSxstore_ptrofs(a0, a1, a2, a3, a4) => instr_node_INSxstore_ptrofs(a0, a1, a2, a3, a4)
| ~INSraise(a0, a1) => instr_node_INSraise(a0, a1)
| ~INSmove_delay(a0, a1, a2, a3) => instr_node_INSmove_delay(a0, a1, a2, a3)
| ~INSmove_lazyeval(a0, a1, a2, a3) => instr_node_INSmove_lazyeval(a0, a1, a2, a3)
| ~INStrywith(a0, a1, a2) => instr_node_INStrywith(a0, a1, a2)
| ~INSmove_list_nil(a0) => instr_node_INSmove_list_nil(a0)
| ~INSpmove_list_nil(a0) => instr_node_INSpmove_list_nil(a0)
| ~INSpmove_list_cons(a0, a1) => instr_node_INSpmove_list_cons(a0, a1)
| ~INSmove_list_phead(a0, a1, a2) => instr_node_INSmove_list_phead(a0, a1, a2)
| ~INSmove_list_ptail(a0, a1, a2) => instr_node_INSmove_list_ptail(a0, a1, a2)
| ~INSmove_arrpsz_ptr(a0, a1) => instr_node_INSmove_arrpsz_ptr(a0, a1)
| ~INSstore_arrpsz_asz(a0, a1) => instr_node_INSstore_arrpsz_asz(a0, a1)
| ~INSstore_arrpsz_ptr(a0, a1, a2) => instr_node_INSstore_arrpsz_ptr(a0, a1, a2)
| ~INSupdate_ptrinc(a0, a1) => instr_node_INSupdate_ptrinc(a0, a1)
| ~INSupdate_ptrdec(a0, a1) => instr_node_INSupdate_ptrdec(a0, a1)
| ~INSclosure_initize(a0, a1, a2) => instr_node_INSclosure_initize(a0, a1, a2)
| ~INStmpdec(a0) => instr_node_INStmpdec(a0)
| ~INSextvar(a0, a1) => instr_node_INSextvar(a0, a1)
| ~INSdcstdef(a0, a1) => instr_node_INSdcstdef(a0, a1)
| ~INStempenver(a0) => instr_node_INStempenver(a0)
) (* end of [instr_node_encode] *)

implement
instr_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0)))

implement
instr_node_is_INSfunlab
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
instr_node_is_INStmplab
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
instr_node_is_INScomment
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
instr_node_is_INSmove_val
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 3)

implement
instr_node_is_INSpmove_val
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 4)

implement
instr_node_is_INSmove_arg_val
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 5)

implement
instr_node_is_INSfcall
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 6)

implement
instr_node_is_INSfcall2
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 7)

implement
instr_node_is_INSextfcall
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 8)

implement
instr_node_is_INSextmcall
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 9)

implement
instr_node_is_INScond
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 10)

implement
instr_node_is_INSfreecon
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 11)

implement
instr_node_is_INSloop
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 12)

implement
instr_node_is_INSloopexn
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 13)

implement
instr_node_is_INScaseof
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 14)

implement
instr_node_is_INSletpop
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 15)

implement
instr_node_is_INSletpush
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 16)

implement
instr_node_is_INSmove_con
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 17)

implement
instr_node_is_INSmove_ref
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 18)

implement
instr_node_is_INSmove_boxrec
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 19)

implement
instr_node_is_INSmove_fltrec
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 20)

implement
instr_node_is_INSpatck
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 21)

implement
instr_node_is_INSmove_ptrofsel
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 22)

implement
instr_node_is_INSstore_ptrofs
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 23)

implement
instr_node_is_INSxstore_ptrofs
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 24)

implement
instr_node_is_INSraise
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 25)

implement
instr_node_is_INSmove_delay
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 26)

implement
instr_node_is_INSmove_lazyeval
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 27)

implement
instr_node_is_INStrywith
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 28)

implement
instr_node_is_INSmove_list_nil
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 29)

implement
instr_node_is_INSpmove_list_nil
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 30)

implement
instr_node_is_INSpmove_list_cons
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 31)

implement
instr_node_is_INSmove_list_phead
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 32)

implement
instr_node_is_INSmove_list_ptail
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 33)

implement
instr_node_is_INSmove_arrpsz_ptr
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 34)

implement
instr_node_is_INSstore_arrpsz_asz
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 35)

implement
instr_node_is_INSstore_arrpsz_ptr
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 36)

implement
instr_node_is_INSupdate_ptrinc
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 37)

implement
instr_node_is_INSupdate_ptrdec
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 38)

implement
instr_node_is_INSclosure_initize
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 39)

implement
instr_node_is_INStmpdec
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 40)

implement
instr_node_is_INSextvar
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 41)

implement
instr_node_is_INSdcstdef
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 42)

implement
instr_node_is_INStempenver
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0))) = 43)

implement
instr_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld (p, 0)))
//
in
//
case+ tag of
| 0 => INSfunlab($UN.cast{funlab} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 1 => INStmplab($UN.cast{tmplab} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 2 => INScomment($UN.cast{string} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 3 => INSmove_val($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 16))))
| 4 => INSpmove_val($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 16))))
| 5 => INSmove_arg_val($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 16))))
| 6 => INSfcall($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{hisexp} ($UN.cast{lint} (pats_ccomp_ld (p, 24))), $UN.cast{primvalist} ($UN.cast{lint} (pats_ccomp_ld (p, 32))))
| 7 => INSfcall2($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{funlab} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld (p, 24))), $UN.cast{hisexp} ($UN.cast{lint} (pats_ccomp_ld (p, 32))), $UN.cast{primvalist} ($UN.cast{lint} (pats_ccomp_ld (p, 40))))
| 8 => INSextfcall($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{string} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{primvalist} ($UN.cast{lint} (pats_ccomp_ld (p, 24))))
| 9 => INSextmcall($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{string} ($UN.cast{lint} (pats_ccomp_ld (p, 24))), $UN.cast{primvalist} ($UN.cast{lint} (pats_ccomp_ld (p, 32))))
| 10 => INScond($UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{instrlst} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{instrlst} ($UN.cast{lint} (pats_ccomp_ld (p, 24))))
| 11 => INSfreecon($UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 12 => INSloop($UN.cast{tmplab} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{tmplab} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{tmplab} ($UN.cast{lint} (pats_ccomp_ld (p, 24))), $UN.cast{instrlst} ($UN.cast{lint} (pats_ccomp_ld (p, 32))), $UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 40))), $UN.cast{instrlst} ($UN.cast{lint} (pats_ccomp_ld (p, 48))), $UN.cast{instrlst} ($UN.cast{lint} (pats_ccomp_ld (p, 56))), $UN.cast{instrlst} ($UN.cast{lint} (pats_ccomp_ld (p, 64))))
| 13 => INSloopexn($UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{tmplab} ($UN.cast{lint} (pats_ccomp_ld (p, 16))))
| 14 => INScaseof($UN.cast{ibranchlst} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 15 => INSletpop()
| 16 => INSletpush($UN.cast{primdeclst} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 17 => INSmove_con($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{d2con} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{hisexp} ($UN.cast{lint} (pats_ccomp_ld (p, 24))), $UN.cast{labprimvalist} ($UN.cast{lint} (pats_ccomp_ld (p, 32))))
| 18 => INSmove_ref($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 16))))
| 19 => INSmove_boxrec($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{labprimvalist} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{hisexp} ($UN.cast{lint} (pats_ccomp_ld (p, 24))))
| 20 => INSmove_fltrec($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{labprimvalist} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{hisexp} ($UN.cast{lint} (pats_ccomp_ld (p, 24))))
| 21 => INSpatck($UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{patck} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{patckont} ($UN.cast{lint} (pats_ccomp_ld (p, 24))))
| 22 => INSmove_ptrofsel($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{hisexp} ($UN.cast{lint} (pats_ccomp_ld (p, 24))), $UN.cast{primlablst} ($UN.cast{lint} (pats_ccomp_ld (p, 32))))
| 23 => INSstore_ptrofs($UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{hisexp} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{primlablst} ($UN.cast{lint} (pats_ccomp_ld (p, 24))), $UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 32))))
| 24 => INSxstore_ptrofs($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{hisexp} ($UN.cast{lint} (pats_ccomp_ld (p, 24))), $UN.cast{primlablst} ($UN.cast{lint} (pats_ccomp_ld (p, 32))), $UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 40))))
| 25 => INSraise($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 16))))
| 26 => INSmove_delay($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{hisexp} ($UN.cast{lint} (pats_ccomp_ld (p, 24))), $UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 32))))
| 27 => INSmove_lazyeval($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{hisexp} ($UN.cast{lint} (pats_ccomp_ld (p, 24))), $UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 32))))
| 28 => INStrywith($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{instrlst} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{ibranchlst} ($UN.cast{lint} (pats_ccomp_ld (p, 24))))
| 29 => INSmove_list_nil($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 30 => INSpmove_list_nil($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 31 => INSpmove_list_cons($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{hisexp} ($UN.cast{lint} (pats_ccomp_ld (p, 16))))
| 32 => INSmove_list_phead($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{hisexp} ($UN.cast{lint} (pats_ccomp_ld (p, 24))))
| 33 => INSmove_list_ptail($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{hisexp} ($UN.cast{lint} (pats_ccomp_ld (p, 24))))
| 34 => INSmove_arrpsz_ptr($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 16))))
| 35 => INSstore_arrpsz_asz($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld (p, 16))))
| 36 => INSstore_arrpsz_ptr($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{hisexp} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{int} ($UN.cast{lint} (pats_ccomp_ld (p, 24))))
| 37 => INSupdate_ptrinc($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{hisexp} ($UN.cast{lint} (pats_ccomp_ld (p, 16))))
| 38 => INSupdate_ptrdec($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{hisexp} ($UN.cast{lint} (pats_ccomp_ld (p, 16))))
| 39 => INSclosure_initize($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{d2varopt} ($UN.cast{lint} (pats_ccomp_ld (p, 16))), $UN.cast{funlab} ($UN.cast{lint} (pats_ccomp_ld (p, 24))))
| 40 => INStmpdec($UN.cast{tmpvar} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
| 41 => INSextvar($UN.cast{string} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 16))))
| 42 => INSdcstdef($UN.cast{d2cst} ($UN.cast{lint} (pats_ccomp_ld (p, 8))), $UN.cast{primval} ($UN.cast{lint} (pats_ccomp_ld (p, 16))))
| _ => INStempenver($UN.cast{d2varlst} ($UN.cast{lint} (pats_ccomp_ld (p, 8))))
//
end // end of [instr_node_view]

implement
instr_node_view_free
  (v) =
(
case+ v of
| ~INSfunlab(_) => ()
| ~INStmplab(_) => ()
| ~INScomment(_) => ()
| ~INSmove_val(_, _) => ()
| ~INSpmove_val(_, _) => ()
| ~INSmove_arg_val(_, _) => ()
| ~INSfcall(_, _, _, _) => ()
| ~INSfcall2(_, _, _, _, _) => ()
| ~INSextfcall(_, _, _) => ()
| ~INSextmcall(_, _, _, _) => ()
| ~INScond(_, _, _) => ()
| ~INSfreecon(_) => ()
| ~INSloop(_, _, _, _, _, _, _, _) => ()
| ~INSloopexn(_, _) => ()
| ~INScaseof(_) => ()
| ~INSletpop() => ()
| ~INSletpush(_) => ()
| ~INSmove_con(_, _, _, _) => ()
| ~INSmove_ref(_, _) => ()
| ~INSmove_boxrec(_, _, _) => ()
| ~INSmove_fltrec(_, _, _) => ()
| ~INSpatck(_, _, _) => ()
| ~INSmove_ptrofsel(_, _, _, _) => ()
| ~INSstore_ptrofs(_, _, _, _) => ()
| ~INSxstore_ptrofs(_, _, _, _, _) => ()
| ~INSraise(_, _) => ()
| ~INSmove_delay(_, _, _, _) => ()
| ~INSmove_lazyeval(_, _, _, _) => ()
| ~INStrywith(_, _, _) => ()
| ~INSmove_list_nil(_) => ()
| ~INSpmove_list_nil(_) => ()
| ~INSpmove_list_cons(_, _) => ()
| ~INSmove_list_phead(_, _, _) => ()
| ~INSmove_list_ptail(_, _, _) => ()
| ~INSmove_arrpsz_ptr(_, _) => ()
| ~INSstore_arrpsz_asz(_, _) => ()
| ~INSstore_arrpsz_ptr(_, _, _) => ()
| ~INSupdate_ptrinc(_, _) => ()
| ~INSupdate_ptrdec(_, _) => ()
| ~INSclosure_initize(_, _, _) => ()
| ~INStmpdec(_) => ()
| ~INSextvar(_, _) => ()
| ~INSdcstdef(_, _) => ()
| ~INStempenver(_) => ()
) (* end of [instr_node_view_free] *)

(* ****** ****** *)

implement
instr_new
  (a0, a1) = let
val p = pats_ccomp_alloc (16)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{instr} (p)
end // end of [instr_new]

implement
instr_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0)))

implement
instr_node
  (x) = $UN.cast{instr_node} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
ibranch_new
  (a0, a1) = let
val p = pats_ccomp_alloc (16)
val () = pats_ccomp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{ibranch} (p)
end // end of [ibranch_new]

implement
ibranch_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 0)))

implement
ibranch_inslst
  (x) = $UN.cast{instrlst} ($UN.cast{lint} (pats_ccomp_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)
