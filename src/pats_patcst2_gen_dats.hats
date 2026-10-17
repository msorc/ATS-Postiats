fn pats_patcst2_ld (p: ptr, k: int): ptr = $UN.ptr0_get<ptr> (ptr0_add_gint<byte> (p, k))
fn pats_patcst2_st (p: ptr, k: int, x: ptr): void = $UN.ptr0_set<ptr> (ptr0_add_gint<byte> (p, k), x)
fn pats_patcst2_alloc (n: int): ptr = the_garena_alloc ($UN.cast{size_t} (n))
//

implement
p2atcst_P2TCany
  () = let
val p = pats_patcst2_alloc (24)
val () = pats_patcst2_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
in
  $UN.cast{p2atcst} (p)
end // end of [p2atcst_P2TCany]

implement
p2atcst_P2TCcon
  (a0, a1) = let
val p = pats_patcst2_alloc (24)
val () = pats_patcst2_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_patcst2_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_patcst2_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{p2atcst} (p)
end // end of [p2atcst_P2TCcon]

implement
p2atcst_P2TCempty
  () = let
val p = pats_patcst2_alloc (24)
val () = pats_patcst2_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
in
  $UN.cast{p2atcst} (p)
end // end of [p2atcst_P2TCempty]

implement
p2atcst_P2TCint
  (a0) = let
val p = pats_patcst2_alloc (24)
val () = pats_patcst2_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (3)))
val () = pats_patcst2_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{p2atcst} (p)
end // end of [p2atcst_P2TCint]

implement
p2atcst_P2TCintc
  (a0) = let
val p = pats_patcst2_alloc (24)
val () = pats_patcst2_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (4)))
val () = pats_patcst2_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{p2atcst} (p)
end // end of [p2atcst_P2TCintc]

implement
p2atcst_P2TCbool
  (a0) = let
val p = pats_patcst2_alloc (24)
val () = pats_patcst2_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (5)))
val () = pats_patcst2_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{p2atcst} (p)
end // end of [p2atcst_P2TCbool]

implement
p2atcst_P2TCchar
  (a0) = let
val p = pats_patcst2_alloc (24)
val () = pats_patcst2_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (6)))
val () = pats_patcst2_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{p2atcst} (p)
end // end of [p2atcst_P2TCchar]

implement
p2atcst_P2TCcharc
  (a0) = let
val p = pats_patcst2_alloc (24)
val () = pats_patcst2_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (7)))
val () = pats_patcst2_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{p2atcst} (p)
end // end of [p2atcst_P2TCcharc]

implement
p2atcst_P2TCfloat
  (a0) = let
val p = pats_patcst2_alloc (24)
val () = pats_patcst2_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (8)))
val () = pats_patcst2_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{p2atcst} (p)
end // end of [p2atcst_P2TCfloat]

implement
p2atcst_P2TCstring
  (a0) = let
val p = pats_patcst2_alloc (24)
val () = pats_patcst2_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (9)))
val () = pats_patcst2_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{p2atcst} (p)
end // end of [p2atcst_P2TCstring]

implement
p2atcst_P2TCrec
  (a0, a1) = let
val p = pats_patcst2_alloc (24)
val () = pats_patcst2_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (10)))
val () = pats_patcst2_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_patcst2_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{p2atcst} (p)
end // end of [p2atcst_P2TCrec]

implement
p2atcst_encode
  (v) =
(
case+ v of
| ~P2TCany() => p2atcst_P2TCany()
| ~P2TCcon(a0, a1) => p2atcst_P2TCcon(a0, a1)
| ~P2TCempty() => p2atcst_P2TCempty()
| ~P2TCint(a0) => p2atcst_P2TCint(a0)
| ~P2TCintc(a0) => p2atcst_P2TCintc(a0)
| ~P2TCbool(a0) => p2atcst_P2TCbool(a0)
| ~P2TCchar(a0) => p2atcst_P2TCchar(a0)
| ~P2TCcharc(a0) => p2atcst_P2TCcharc(a0)
| ~P2TCfloat(a0) => p2atcst_P2TCfloat(a0)
| ~P2TCstring(a0) => p2atcst_P2TCstring(a0)
| ~P2TCrec(a0, a1) => p2atcst_P2TCrec(a0, a1)
) (* end of [p2atcst_encode] *)

implement
p2atcst_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_patcst2_ld ($UN.cast{ptr} (x), 0)))

implement
p2atcst_is_P2TCany
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_patcst2_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
p2atcst_is_P2TCcon
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_patcst2_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
p2atcst_is_P2TCempty
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_patcst2_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
p2atcst_is_P2TCint
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_patcst2_ld ($UN.cast{ptr} (x), 0))) = 3)

implement
p2atcst_is_P2TCintc
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_patcst2_ld ($UN.cast{ptr} (x), 0))) = 4)

implement
p2atcst_is_P2TCbool
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_patcst2_ld ($UN.cast{ptr} (x), 0))) = 5)

implement
p2atcst_is_P2TCchar
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_patcst2_ld ($UN.cast{ptr} (x), 0))) = 6)

implement
p2atcst_is_P2TCcharc
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_patcst2_ld ($UN.cast{ptr} (x), 0))) = 7)

implement
p2atcst_is_P2TCfloat
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_patcst2_ld ($UN.cast{ptr} (x), 0))) = 8)

implement
p2atcst_is_P2TCstring
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_patcst2_ld ($UN.cast{ptr} (x), 0))) = 9)

implement
p2atcst_is_P2TCrec
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_patcst2_ld ($UN.cast{ptr} (x), 0))) = 10)

implement
p2atcst_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_patcst2_ld (p, 0)))
//
in
//
case+ tag of
| 0 => P2TCany()
| 1 => P2TCcon($UN.cast{d2con} ($UN.cast{lint} (pats_patcst2_ld (p, 8))), $UN.cast{p2atcstlst} ($UN.cast{lint} (pats_patcst2_ld (p, 16))))
| 2 => P2TCempty()
| 3 => P2TCint($UN.cast{intinf} ($UN.cast{lint} (pats_patcst2_ld (p, 8))))
| 4 => P2TCintc($UN.cast{intinfset} ($UN.cast{lint} (pats_patcst2_ld (p, 8))))
| 5 => P2TCbool($UN.cast{bool} ($UN.cast{lint} (pats_patcst2_ld (p, 8))))
| 6 => P2TCchar($UN.cast{char} ($UN.cast{lint} (pats_patcst2_ld (p, 8))))
| 7 => P2TCcharc($UN.cast{charset} ($UN.cast{lint} (pats_patcst2_ld (p, 8))))
| 8 => P2TCfloat($UN.cast{string} ($UN.cast{lint} (pats_patcst2_ld (p, 8))))
| 9 => P2TCstring($UN.cast{string} ($UN.cast{lint} (pats_patcst2_ld (p, 8))))
| _ => P2TCrec($UN.cast{int} ($UN.cast{lint} (pats_patcst2_ld (p, 8))), $UN.cast{labp2atcstlst} ($UN.cast{lint} (pats_patcst2_ld (p, 16))))
//
end // end of [p2atcst_view]

implement
p2atcst_view_free
  (v) =
(
case+ v of
| ~P2TCany() => ()
| ~P2TCcon(_, _) => ()
| ~P2TCempty() => ()
| ~P2TCint(_) => ()
| ~P2TCintc(_) => ()
| ~P2TCbool(_) => ()
| ~P2TCchar(_) => ()
| ~P2TCcharc(_) => ()
| ~P2TCfloat(_) => ()
| ~P2TCstring(_) => ()
| ~P2TCrec(_, _) => ()
) (* end of [p2atcst_view_free] *)

(* ****** ****** *)

implement
labp2atcst_new
  (a0, a1) = let
val p = pats_patcst2_alloc (16)
val () = pats_patcst2_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_patcst2_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{labp2atcst} (p)
end // end of [labp2atcst_new]

implement
labp2atcst_lab
  (x) = $UN.cast{label} ($UN.cast{lint} (pats_patcst2_ld ($UN.cast{ptr} (x), 0)))

implement
labp2atcst_elt
  (x) = $UN.cast{p2atcst} ($UN.cast{lint} (pats_patcst2_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)
