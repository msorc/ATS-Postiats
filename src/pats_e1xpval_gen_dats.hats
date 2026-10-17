fn pats_e1xpval_ld (p: ptr, k: int): ptr = $UN.ptr0_get<ptr> (ptr0_add_gint<byte> (p, k))
fn pats_e1xpval_st (p: ptr, k: int, x: ptr): void = $UN.ptr0_set<ptr> (ptr0_add_gint<byte> (p, k), x)
fn pats_e1xpval_alloc (n: int): ptr = the_garena_alloc ($UN.cast{size_t} (n))
//

implement
valerr_VE_valize
  (a0) = let
val p = pats_e1xpval_alloc (24)
val () = pats_e1xpval_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_e1xpval_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{valerr} (p)
end // end of [valerr_VE_valize]

implement
valerr_VE_valize_defined
  (a0) = let
val p = pats_e1xpval_alloc (24)
val () = pats_e1xpval_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_e1xpval_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{valerr} (p)
end // end of [valerr_VE_valize_defined]

implement
valerr_VE_valize_undefined
  (a0) = let
val p = pats_e1xpval_alloc (24)
val () = pats_e1xpval_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_e1xpval_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{valerr} (p)
end // end of [valerr_VE_valize_undefined]

implement
valerr_VE_maxlevel
  (a0, a1) = let
val p = pats_e1xpval_alloc (24)
val () = pats_e1xpval_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (3)))
val () = pats_e1xpval_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_e1xpval_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{valerr} (p)
end // end of [valerr_VE_maxlevel]

implement
valerr_VE_opr_arglst
  (a0, a1) = let
val p = pats_e1xpval_alloc (24)
val () = pats_e1xpval_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (4)))
val () = pats_e1xpval_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_e1xpval_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{valerr} (p)
end // end of [valerr_VE_opr_arglst]

implement
valerr_VE_E1XPide_unbound
  (a0) = let
val p = pats_e1xpval_alloc (24)
val () = pats_e1xpval_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (5)))
val () = pats_e1xpval_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{valerr} (p)
end // end of [valerr_VE_E1XPide_unbound]

implement
valerr_VE_E1XPundef
  (a0) = let
val p = pats_e1xpval_alloc (24)
val () = pats_e1xpval_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (6)))
val () = pats_e1xpval_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{valerr} (p)
end // end of [valerr_VE_E1XPundef]

implement
valerr_VE_E1XPlist
  (a0) = let
val p = pats_e1xpval_alloc (24)
val () = pats_e1xpval_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (7)))
val () = pats_e1xpval_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{valerr} (p)
end // end of [valerr_VE_E1XPlist]

implement
valerr_VE_E1XPapp_fun
  (a0) = let
val p = pats_e1xpval_alloc (24)
val () = pats_e1xpval_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (8)))
val () = pats_e1xpval_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{valerr} (p)
end // end of [valerr_VE_E1XPapp_fun]

implement
valerr_VE_E1XPappid_fun
  (a0, a1) = let
val p = pats_e1xpval_alloc (24)
val () = pats_e1xpval_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (9)))
val () = pats_e1xpval_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_e1xpval_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{valerr} (p)
end // end of [valerr_VE_E1XPappid_fun]

implement
valerr_VE_E1XPappid_opr
  (a0, a1) = let
val p = pats_e1xpval_alloc (24)
val () = pats_e1xpval_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (10)))
val () = pats_e1xpval_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_e1xpval_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{valerr} (p)
end // end of [valerr_VE_E1XPappid_opr]

implement
valerr_VE_E1XPappid_arity
  (a0, a1) = let
val p = pats_e1xpval_alloc (24)
val () = pats_e1xpval_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (11)))
val () = pats_e1xpval_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_e1xpval_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{valerr} (p)
end // end of [valerr_VE_E1XPappid_arity]

implement
valerr_VE_E1XPfun
  (a0) = let
val p = pats_e1xpval_alloc (24)
val () = pats_e1xpval_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (12)))
val () = pats_e1xpval_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{valerr} (p)
end // end of [valerr_VE_E1XPfun]

implement
valerr_VE_E1XPerr
  (a0) = let
val p = pats_e1xpval_alloc (24)
val () = pats_e1xpval_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (13)))
val () = pats_e1xpval_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{valerr} (p)
end // end of [valerr_VE_E1XPerr]

implement
valerr_encode
  (v) =
(
case+ v of
| ~VE_valize(a0) => valerr_VE_valize(a0)
| ~VE_valize_defined(a0) => valerr_VE_valize_defined(a0)
| ~VE_valize_undefined(a0) => valerr_VE_valize_undefined(a0)
| ~VE_maxlevel(a0, a1) => valerr_VE_maxlevel(a0, a1)
| ~VE_opr_arglst(a0, a1) => valerr_VE_opr_arglst(a0, a1)
| ~VE_E1XPide_unbound(a0) => valerr_VE_E1XPide_unbound(a0)
| ~VE_E1XPundef(a0) => valerr_VE_E1XPundef(a0)
| ~VE_E1XPlist(a0) => valerr_VE_E1XPlist(a0)
| ~VE_E1XPapp_fun(a0) => valerr_VE_E1XPapp_fun(a0)
| ~VE_E1XPappid_fun(a0, a1) => valerr_VE_E1XPappid_fun(a0, a1)
| ~VE_E1XPappid_opr(a0, a1) => valerr_VE_E1XPappid_opr(a0, a1)
| ~VE_E1XPappid_arity(a0, a1) => valerr_VE_E1XPappid_arity(a0, a1)
| ~VE_E1XPfun(a0) => valerr_VE_E1XPfun(a0)
| ~VE_E1XPerr(a0) => valerr_VE_E1XPerr(a0)
) (* end of [valerr_encode] *)

implement
valerr_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_e1xpval_ld ($UN.cast{ptr} (x), 0)))

implement
valerr_is_VE_valize
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_e1xpval_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
valerr_is_VE_valize_defined
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_e1xpval_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
valerr_is_VE_valize_undefined
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_e1xpval_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
valerr_is_VE_maxlevel
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_e1xpval_ld ($UN.cast{ptr} (x), 0))) = 3)

implement
valerr_is_VE_opr_arglst
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_e1xpval_ld ($UN.cast{ptr} (x), 0))) = 4)

implement
valerr_is_VE_E1XPide_unbound
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_e1xpval_ld ($UN.cast{ptr} (x), 0))) = 5)

implement
valerr_is_VE_E1XPundef
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_e1xpval_ld ($UN.cast{ptr} (x), 0))) = 6)

implement
valerr_is_VE_E1XPlist
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_e1xpval_ld ($UN.cast{ptr} (x), 0))) = 7)

implement
valerr_is_VE_E1XPapp_fun
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_e1xpval_ld ($UN.cast{ptr} (x), 0))) = 8)

implement
valerr_is_VE_E1XPappid_fun
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_e1xpval_ld ($UN.cast{ptr} (x), 0))) = 9)

implement
valerr_is_VE_E1XPappid_opr
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_e1xpval_ld ($UN.cast{ptr} (x), 0))) = 10)

implement
valerr_is_VE_E1XPappid_arity
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_e1xpval_ld ($UN.cast{ptr} (x), 0))) = 11)

implement
valerr_is_VE_E1XPfun
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_e1xpval_ld ($UN.cast{ptr} (x), 0))) = 12)

implement
valerr_is_VE_E1XPerr
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_e1xpval_ld ($UN.cast{ptr} (x), 0))) = 13)

implement
valerr_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_e1xpval_ld (p, 0)))
//
in
//
case+ tag of
| 0 => VE_valize($UN.cast{e1xp} ($UN.cast{lint} (pats_e1xpval_ld (p, 8))))
| 1 => VE_valize_defined($UN.cast{e1xp} ($UN.cast{lint} (pats_e1xpval_ld (p, 8))))
| 2 => VE_valize_undefined($UN.cast{e1xp} ($UN.cast{lint} (pats_e1xpval_ld (p, 8))))
| 3 => VE_maxlevel($UN.cast{int} ($UN.cast{lint} (pats_e1xpval_ld (p, 8))), $UN.cast{e1xp} ($UN.cast{lint} (pats_e1xpval_ld (p, 16))))
| 4 => VE_opr_arglst($UN.cast{e1xp} ($UN.cast{lint} (pats_e1xpval_ld (p, 8))), $UN.cast{symbol} ($UN.cast{lint} (pats_e1xpval_ld (p, 16))))
| 5 => VE_E1XPide_unbound($UN.cast{e1xp} ($UN.cast{lint} (pats_e1xpval_ld (p, 8))))
| 6 => VE_E1XPundef($UN.cast{e1xp} ($UN.cast{lint} (pats_e1xpval_ld (p, 8))))
| 7 => VE_E1XPlist($UN.cast{e1xp} ($UN.cast{lint} (pats_e1xpval_ld (p, 8))))
| 8 => VE_E1XPapp_fun($UN.cast{e1xp} ($UN.cast{lint} (pats_e1xpval_ld (p, 8))))
| 9 => VE_E1XPappid_fun($UN.cast{e1xp} ($UN.cast{lint} (pats_e1xpval_ld (p, 8))), $UN.cast{symbol} ($UN.cast{lint} (pats_e1xpval_ld (p, 16))))
| 10 => VE_E1XPappid_opr($UN.cast{e1xp} ($UN.cast{lint} (pats_e1xpval_ld (p, 8))), $UN.cast{symbol} ($UN.cast{lint} (pats_e1xpval_ld (p, 16))))
| 11 => VE_E1XPappid_arity($UN.cast{e1xp} ($UN.cast{lint} (pats_e1xpval_ld (p, 8))), $UN.cast{symbol} ($UN.cast{lint} (pats_e1xpval_ld (p, 16))))
| 12 => VE_E1XPfun($UN.cast{e1xp} ($UN.cast{lint} (pats_e1xpval_ld (p, 8))))
| _ => VE_E1XPerr($UN.cast{e1xp} ($UN.cast{lint} (pats_e1xpval_ld (p, 8))))
//
end // end of [valerr_view]

implement
valerr_view_free
  (v) =
(
case+ v of
| ~VE_valize(_) => ()
| ~VE_valize_defined(_) => ()
| ~VE_valize_undefined(_) => ()
| ~VE_maxlevel(_, _) => ()
| ~VE_opr_arglst(_, _) => ()
| ~VE_E1XPide_unbound(_) => ()
| ~VE_E1XPundef(_) => ()
| ~VE_E1XPlist(_) => ()
| ~VE_E1XPapp_fun(_) => ()
| ~VE_E1XPappid_fun(_, _) => ()
| ~VE_E1XPappid_opr(_, _) => ()
| ~VE_E1XPappid_arity(_, _) => ()
| ~VE_E1XPfun(_) => ()
| ~VE_E1XPerr(_) => ()
) (* end of [valerr_view_free] *)

(* ****** ****** *)
