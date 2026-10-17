fn pats_staexp1_ld (p: ptr, k: int): ptr = $UN.ptr0_get<ptr> (ptr0_add_gint<byte> (p, k))
fn pats_staexp1_st (p: ptr, k: int, x: ptr): void = $UN.ptr0_set<ptr> (ptr0_add_gint<byte> (p, k), x)
fn pats_staexp1_alloc (n: int): ptr = the_garena_alloc ($UN.cast{size_t} (n))
//

fn pats_staexp1_ldd (p: ptr, k: int): double = $UN.ptr0_get<double> (ptr0_add_gint<byte> (p, k))
fn pats_staexp1_std (p: ptr, k: int, x: double): void = $UN.ptr0_set<double> (ptr0_add_gint<byte> (p, k), x)
//

implement
v1al_V1ALint
  (a0) = let
val p = pats_staexp1_alloc (16)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{v1al} (p)
end // end of [v1al_V1ALint]

implement
v1al_V1ALchar
  (a0) = let
val p = pats_staexp1_alloc (16)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{v1al} (p)
end // end of [v1al_V1ALchar]

implement
v1al_V1ALstring
  (a0) = let
val p = pats_staexp1_alloc (16)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{v1al} (p)
end // end of [v1al_V1ALstring]

implement
v1al_V1ALfloat
  (a0) = let
val p = pats_staexp1_alloc (16)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (3)))
val () = pats_staexp1_std (p, 8, a0)
in
  $UN.cast{v1al} (p)
end // end of [v1al_V1ALfloat]

implement
v1al_V1ALerr
  () = let
val p = pats_staexp1_alloc (16)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (4)))
in
  $UN.cast{v1al} (p)
end // end of [v1al_V1ALerr]

implement
v1al_encode
  (v) =
(
case+ v of
| ~V1ALint(a0) => v1al_V1ALint(a0)
| ~V1ALchar(a0) => v1al_V1ALchar(a0)
| ~V1ALstring(a0) => v1al_V1ALstring(a0)
| ~V1ALfloat(a0) => v1al_V1ALfloat(a0)
| ~V1ALerr() => v1al_V1ALerr()
) (* end of [v1al_encode] *)

implement
v1al_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
v1al_is_V1ALint
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
v1al_is_V1ALchar
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
v1al_is_V1ALstring
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
v1al_is_V1ALfloat
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 3)

implement
v1al_is_V1ALerr
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 4)

implement
v1al_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 0)))
//
in
//
case+ tag of
| 0 => V1ALint($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 8))))
| 1 => V1ALchar($UN.cast{char} ($UN.cast{lint} (pats_staexp1_ld (p, 8))))
| 2 => V1ALstring($UN.cast{string} ($UN.cast{lint} (pats_staexp1_ld (p, 8))))
| 3 => V1ALfloat(pats_staexp1_ldd (p, 8))
| _ => V1ALerr()
//
end // end of [v1al_view]

implement
v1al_view_free
  (v) =
(
case+ v of
| ~V1ALint(_) => ()
| ~V1ALchar(_) => ()
| ~V1ALstring(_) => ()
| ~V1ALfloat(_) => ()
| ~V1ALerr() => ()
) (* end of [v1al_view_free] *)

(* ****** ****** *)

implement
e1xp_node_E1XPide
  (a0) = let
val p = pats_staexp1_alloc (32)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{e1xp_node} (p)
end // end of [e1xp_node_E1XPide]

implement
e1xp_node_E1XPint
  (a0) = let
val p = pats_staexp1_alloc (32)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{e1xp_node} (p)
end // end of [e1xp_node_E1XPint]

implement
e1xp_node_E1XPintrep
  (a0) = let
val p = pats_staexp1_alloc (32)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{e1xp_node} (p)
end // end of [e1xp_node_E1XPintrep]

implement
e1xp_node_E1XPchar
  (a0) = let
val p = pats_staexp1_alloc (32)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (3)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{e1xp_node} (p)
end // end of [e1xp_node_E1XPchar]

implement
e1xp_node_E1XPfloat
  (a0) = let
val p = pats_staexp1_alloc (32)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (4)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{e1xp_node} (p)
end // end of [e1xp_node_E1XPfloat]

implement
e1xp_node_E1XPstring
  (a0) = let
val p = pats_staexp1_alloc (32)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (5)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{e1xp_node} (p)
end // end of [e1xp_node_E1XPstring]

implement
e1xp_node_E1XPv1al
  (a0) = let
val p = pats_staexp1_alloc (32)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (6)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{e1xp_node} (p)
end // end of [e1xp_node_E1XPv1al]

implement
e1xp_node_E1XPnone
  () = let
val p = pats_staexp1_alloc (32)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (7)))
in
  $UN.cast{e1xp_node} (p)
end // end of [e1xp_node_E1XPnone]

implement
e1xp_node_E1XPundef
  () = let
val p = pats_staexp1_alloc (32)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (8)))
in
  $UN.cast{e1xp_node} (p)
end // end of [e1xp_node_E1XPundef]

implement
e1xp_node_E1XPapp
  (a0, a1, a2) = let
val p = pats_staexp1_alloc (32)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (9)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_staexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{e1xp_node} (p)
end // end of [e1xp_node_E1XPapp]

implement
e1xp_node_E1XPfun
  (a0, a1) = let
val p = pats_staexp1_alloc (32)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (10)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{e1xp_node} (p)
end // end of [e1xp_node_E1XPfun]

implement
e1xp_node_E1XPif
  (a0, a1, a2) = let
val p = pats_staexp1_alloc (32)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (11)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_staexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{e1xp_node} (p)
end // end of [e1xp_node_E1XPif]

implement
e1xp_node_E1XPeval
  (a0) = let
val p = pats_staexp1_alloc (32)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (12)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{e1xp_node} (p)
end // end of [e1xp_node_E1XPeval]

implement
e1xp_node_E1XPlist
  (a0) = let
val p = pats_staexp1_alloc (32)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (13)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{e1xp_node} (p)
end // end of [e1xp_node_E1XPlist]

implement
e1xp_node_E1XPerr
  () = let
val p = pats_staexp1_alloc (32)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (14)))
in
  $UN.cast{e1xp_node} (p)
end // end of [e1xp_node_E1XPerr]

implement
e1xp_node_encode
  (v) =
(
case+ v of
| ~E1XPide(a0) => e1xp_node_E1XPide(a0)
| ~E1XPint(a0) => e1xp_node_E1XPint(a0)
| ~E1XPintrep(a0) => e1xp_node_E1XPintrep(a0)
| ~E1XPchar(a0) => e1xp_node_E1XPchar(a0)
| ~E1XPfloat(a0) => e1xp_node_E1XPfloat(a0)
| ~E1XPstring(a0) => e1xp_node_E1XPstring(a0)
| ~E1XPv1al(a0) => e1xp_node_E1XPv1al(a0)
| ~E1XPnone() => e1xp_node_E1XPnone()
| ~E1XPundef() => e1xp_node_E1XPundef()
| ~E1XPapp(a0, a1, a2) => e1xp_node_E1XPapp(a0, a1, a2)
| ~E1XPfun(a0, a1) => e1xp_node_E1XPfun(a0, a1)
| ~E1XPif(a0, a1, a2) => e1xp_node_E1XPif(a0, a1, a2)
| ~E1XPeval(a0) => e1xp_node_E1XPeval(a0)
| ~E1XPlist(a0) => e1xp_node_E1XPlist(a0)
| ~E1XPerr() => e1xp_node_E1XPerr()
) (* end of [e1xp_node_encode] *)

implement
e1xp_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
e1xp_node_is_E1XPide
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
e1xp_node_is_E1XPint
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
e1xp_node_is_E1XPintrep
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
e1xp_node_is_E1XPchar
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 3)

implement
e1xp_node_is_E1XPfloat
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 4)

implement
e1xp_node_is_E1XPstring
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 5)

implement
e1xp_node_is_E1XPv1al
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 6)

implement
e1xp_node_is_E1XPnone
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 7)

implement
e1xp_node_is_E1XPundef
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 8)

implement
e1xp_node_is_E1XPapp
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 9)

implement
e1xp_node_is_E1XPfun
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 10)

implement
e1xp_node_is_E1XPif
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 11)

implement
e1xp_node_is_E1XPeval
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 12)

implement
e1xp_node_is_E1XPlist
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 13)

implement
e1xp_node_is_E1XPerr
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 14)

implement
e1xp_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 0)))
//
in
//
case+ tag of
| 0 => E1XPide($UN.cast{symbol} ($UN.cast{lint} (pats_staexp1_ld (p, 8))))
| 1 => E1XPint($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 8))))
| 2 => E1XPintrep($UN.cast{string} ($UN.cast{lint} (pats_staexp1_ld (p, 8))))
| 3 => E1XPchar($UN.cast{char} ($UN.cast{lint} (pats_staexp1_ld (p, 8))))
| 4 => E1XPfloat($UN.cast{string} ($UN.cast{lint} (pats_staexp1_ld (p, 8))))
| 5 => E1XPstring($UN.cast{string} ($UN.cast{lint} (pats_staexp1_ld (p, 8))))
| 6 => E1XPv1al($UN.cast{v1al} ($UN.cast{lint} (pats_staexp1_ld (p, 8))))
| 7 => E1XPnone()
| 8 => E1XPundef()
| 9 => E1XPapp($UN.cast{e1xp} ($UN.cast{lint} (pats_staexp1_ld (p, 8))), $UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld (p, 16))), $UN.cast{e1xplst} ($UN.cast{lint} (pats_staexp1_ld (p, 24))))
| 10 => E1XPfun($UN.cast{symbolist} ($UN.cast{lint} (pats_staexp1_ld (p, 8))), $UN.cast{e1xp} ($UN.cast{lint} (pats_staexp1_ld (p, 16))))
| 11 => E1XPif($UN.cast{e1xp} ($UN.cast{lint} (pats_staexp1_ld (p, 8))), $UN.cast{e1xp} ($UN.cast{lint} (pats_staexp1_ld (p, 16))), $UN.cast{e1xp} ($UN.cast{lint} (pats_staexp1_ld (p, 24))))
| 12 => E1XPeval($UN.cast{e1xp} ($UN.cast{lint} (pats_staexp1_ld (p, 8))))
| 13 => E1XPlist($UN.cast{e1xplst} ($UN.cast{lint} (pats_staexp1_ld (p, 8))))
| _ => E1XPerr()
//
end // end of [e1xp_node_view]

implement
e1xp_node_view_free
  (v) =
(
case+ v of
| ~E1XPide(_) => ()
| ~E1XPint(_) => ()
| ~E1XPintrep(_) => ()
| ~E1XPchar(_) => ()
| ~E1XPfloat(_) => ()
| ~E1XPstring(_) => ()
| ~E1XPv1al(_) => ()
| ~E1XPnone() => ()
| ~E1XPundef() => ()
| ~E1XPapp(_, _, _) => ()
| ~E1XPfun(_, _) => ()
| ~E1XPif(_, _, _) => ()
| ~E1XPeval(_) => ()
| ~E1XPlist(_) => ()
| ~E1XPerr() => ()
) (* end of [e1xp_node_view_free] *)

(* ****** ****** *)

implement
e1xp_new
  (a0, a1) = let
val p = pats_staexp1_alloc (16)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{e1xp} (p)
end // end of [e1xp_new]

implement
e1xp_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
e1xp_node
  (x) = $UN.cast{e1xp_node} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
effcst_EFFCSTall
  () = let
val p = pats_staexp1_alloc (24)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
in
  $UN.cast{effcst} (p)
end // end of [effcst_EFFCSTall]

implement
effcst_EFFCSTnil
  () = let
val p = pats_staexp1_alloc (24)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
in
  $UN.cast{effcst} (p)
end // end of [effcst_EFFCSTnil]

implement
effcst_EFFCSTset
  (a0, a1) = let
val p = pats_staexp1_alloc (24)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{effcst} (p)
end // end of [effcst_EFFCSTset]

implement
effcst_encode
  (v) =
(
case+ v of
| ~EFFCSTall() => effcst_EFFCSTall()
| ~EFFCSTnil() => effcst_EFFCSTnil()
| ~EFFCSTset(a0, a1) => effcst_EFFCSTset(a0, a1)
) (* end of [effcst_encode] *)

implement
effcst_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
effcst_is_EFFCSTall
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
effcst_is_EFFCSTnil
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
effcst_is_EFFCSTset
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
effcst_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 0)))
//
in
//
case+ tag of
| 0 => EFFCSTall()
| 1 => EFFCSTnil()
| _ => EFFCSTset($UN.cast{effset} ($UN.cast{lint} (pats_staexp1_ld (p, 8))), $UN.cast{effvarlst} ($UN.cast{lint} (pats_staexp1_ld (p, 16))))
//
end // end of [effcst_view]

implement
effcst_view_free
  (v) =
(
case+ v of
| ~EFFCSTall() => ()
| ~EFFCSTnil() => ()
| ~EFFCSTset(_, _) => ()
) (* end of [effcst_view_free] *)

(* ****** ****** *)

implement
s1rt_node_S1RTapp
  (a0, a1) = let
val p = pats_staexp1_alloc (24)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s1rt_node} (p)
end // end of [s1rt_node_S1RTapp]

implement
s1rt_node_S1RTlist
  (a0) = let
val p = pats_staexp1_alloc (24)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s1rt_node} (p)
end // end of [s1rt_node_S1RTlist]

implement
s1rt_node_S1RTqid
  (a0, a1) = let
val p = pats_staexp1_alloc (24)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s1rt_node} (p)
end // end of [s1rt_node_S1RTqid]

implement
s1rt_node_S1RTtype
  (a0) = let
val p = pats_staexp1_alloc (24)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (3)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s1rt_node} (p)
end // end of [s1rt_node_S1RTtype]

implement
s1rt_node_S1RTerr
  () = let
val p = pats_staexp1_alloc (24)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (4)))
in
  $UN.cast{s1rt_node} (p)
end // end of [s1rt_node_S1RTerr]

implement
s1rt_node_encode
  (v) =
(
case+ v of
| ~S1RTapp(a0, a1) => s1rt_node_S1RTapp(a0, a1)
| ~S1RTlist(a0) => s1rt_node_S1RTlist(a0)
| ~S1RTqid(a0, a1) => s1rt_node_S1RTqid(a0, a1)
| ~S1RTtype(a0) => s1rt_node_S1RTtype(a0)
| ~S1RTerr() => s1rt_node_S1RTerr()
) (* end of [s1rt_node_encode] *)

implement
s1rt_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
s1rt_node_is_S1RTapp
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
s1rt_node_is_S1RTlist
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
s1rt_node_is_S1RTqid
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
s1rt_node_is_S1RTtype
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 3)

implement
s1rt_node_is_S1RTerr
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 4)

implement
s1rt_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 0)))
//
in
//
case+ tag of
| 0 => S1RTapp($UN.cast{s1rt} ($UN.cast{lint} (pats_staexp1_ld (p, 8))), $UN.cast{s1rtlst} ($UN.cast{lint} (pats_staexp1_ld (p, 16))))
| 1 => S1RTlist($UN.cast{s1rtlst} ($UN.cast{lint} (pats_staexp1_ld (p, 8))))
| 2 => S1RTqid($UN.cast{s0rtq} ($UN.cast{lint} (pats_staexp1_ld (p, 8))), $UN.cast{symbol} ($UN.cast{lint} (pats_staexp1_ld (p, 16))))
| 3 => S1RTtype($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 8))))
| _ => S1RTerr()
//
end // end of [s1rt_node_view]

implement
s1rt_node_view_free
  (v) =
(
case+ v of
| ~S1RTapp(_, _) => ()
| ~S1RTlist(_) => ()
| ~S1RTqid(_, _) => ()
| ~S1RTtype(_) => ()
| ~S1RTerr() => ()
) (* end of [s1rt_node_view_free] *)

(* ****** ****** *)

implement
s1rt_new
  (a0, a1) = let
val p = pats_staexp1_alloc (16)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s1rt} (p)
end // end of [s1rt_new]

implement
s1rt_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
s1rt_node
  (x) = $UN.cast{s1rt_node} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
s1rtpol_new
  (a0, a1, a2) = let
val p = pats_staexp1_alloc (24)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{s1rtpol} (p)
end // end of [s1rtpol_new]

implement
s1rtpol_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
s1rtpol_srt
  (x) = $UN.cast{s1rt} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 8)))

implement
s1rtpol_pol
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
d1atsrtcon_new
  (a0, a1, a2) = let
val p = pats_staexp1_alloc (24)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d1atsrtcon} (p)
end // end of [d1atsrtcon_new]

implement
d1atsrtcon_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
d1atsrtcon_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 8)))

implement
d1atsrtcon_arg
  (x) = $UN.cast{s1rtlst} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
d1atsrtdec_new
  (a0, a1, a2) = let
val p = pats_staexp1_alloc (24)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d1atsrtdec} (p)
end // end of [d1atsrtdec_new]

implement
d1atsrtdec_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
d1atsrtdec_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 8)))

implement
d1atsrtdec_con
  (x) = $UN.cast{d1atsrtconlst} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
s1arg_new
  (a0, a1, a2) = let
val p = pats_staexp1_alloc (24)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{s1arg} (p)
end // end of [s1arg_new]

implement
s1arg_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
s1arg_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 8)))

implement
s1arg_srt
  (x) = $UN.cast{s1rtopt} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
s1marg_new
  (a0, a1) = let
val p = pats_staexp1_alloc (16)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s1marg} (p)
end // end of [s1marg_new]

implement
s1marg_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
s1marg_arg
  (x) = $UN.cast{s1arglst} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
s1var_new
  (a0, a1, a2) = let
val p = pats_staexp1_alloc (24)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{s1var} (p)
end // end of [s1var_new]

implement
s1var_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
s1var_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 8)))

implement
s1var_srt
  (x) = $UN.cast{s1rt} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
a1srt_new
  (a0, a1, a2) = let
val p = pats_staexp1_alloc (24)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{a1srt} (p)
end // end of [a1srt_new]

implement
a1srt_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
a1srt_sym
  (x) = $UN.cast{symbolopt} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 8)))

implement
a1srt_srt
  (x) = $UN.cast{s1rt} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
a1msrt_new
  (a0, a1) = let
val p = pats_staexp1_alloc (16)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{a1msrt} (p)
end // end of [a1msrt_new]

implement
a1msrt_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
a1msrt_arg
  (x) = $UN.cast{a1srtlst} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
sp1at_node_SP1Tcstr
  (a0, a1, a2) = let
val p = pats_staexp1_alloc (32)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_staexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{sp1at_node} (p)
end // end of [sp1at_node_SP1Tcstr]

implement
sp1at_node_encode
  (v) =
(
case+ v of
| ~SP1Tcstr(a0, a1, a2) => sp1at_node_SP1Tcstr(a0, a1, a2)
) (* end of [sp1at_node_encode] *)

implement
sp1at_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
sp1at_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 0)))
//
in
//
case+ tag of
| _ => SP1Tcstr($UN.cast{s0taq} ($UN.cast{lint} (pats_staexp1_ld (p, 8))), $UN.cast{symbol} ($UN.cast{lint} (pats_staexp1_ld (p, 16))), $UN.cast{s1arglst} ($UN.cast{lint} (pats_staexp1_ld (p, 24))))
//
end // end of [sp1at_node_view]

implement
sp1at_node_view_free
  (v) =
(
case+ v of
| ~SP1Tcstr(_, _, _) => ()
) (* end of [sp1at_node_view_free] *)

(* ****** ****** *)

implement
sp1at_new
  (a0, a1) = let
val p = pats_staexp1_alloc (16)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{sp1at} (p)
end // end of [sp1at_new]

implement
sp1at_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
sp1at_node
  (x) = $UN.cast{sp1at_node} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
s1exp_node_S1Eide
  (a0) = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s1exp_node} (p)
end // end of [s1exp_node_S1Eide]

implement
s1exp_node_S1Esqid
  (a0, a1) = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s1exp_node} (p)
end // end of [s1exp_node_S1Esqid]

implement
s1exp_node_S1Eint
  (a0) = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s1exp_node} (p)
end // end of [s1exp_node_S1Eint]

implement
s1exp_node_S1Eintrep
  (a0) = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (3)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s1exp_node} (p)
end // end of [s1exp_node_S1Eintrep]

implement
s1exp_node_S1Echar
  (a0) = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (4)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s1exp_node} (p)
end // end of [s1exp_node_S1Echar]

implement
s1exp_node_S1Efloat
  (a0) = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (5)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s1exp_node} (p)
end // end of [s1exp_node_S1Efloat]

implement
s1exp_node_S1Estring
  (a0) = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (6)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s1exp_node} (p)
end // end of [s1exp_node_S1Estring]

implement
s1exp_node_S1Eextype
  (a0, a1) = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (7)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s1exp_node} (p)
end // end of [s1exp_node_S1Eextype]

implement
s1exp_node_S1Eextkind
  (a0, a1) = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (8)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s1exp_node} (p)
end // end of [s1exp_node_S1Eextkind]

implement
s1exp_node_S1Eapp
  (a0, a1, a2) = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (9)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_staexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{s1exp_node} (p)
end // end of [s1exp_node_S1Eapp]

implement
s1exp_node_S1Elam
  (a0, a1, a2) = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (10)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_staexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{s1exp_node} (p)
end // end of [s1exp_node_S1Elam]

implement
s1exp_node_S1Eimp
  (a0, a1, a2, a3) = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (11)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_staexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_staexp1_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{s1exp_node} (p)
end // end of [s1exp_node_S1Eimp]

implement
s1exp_node_S1Etop
  (a0, a1) = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (12)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s1exp_node} (p)
end // end of [s1exp_node_S1Etop]

implement
s1exp_node_S1Elist
  (a0, a1) = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (13)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s1exp_node} (p)
end // end of [s1exp_node_S1Elist]

implement
s1exp_node_S1Einvar
  (a0, a1) = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (14)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s1exp_node} (p)
end // end of [s1exp_node_S1Einvar]

implement
s1exp_node_S1Etrans
  (a0, a1) = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (15)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s1exp_node} (p)
end // end of [s1exp_node_S1Etrans]

implement
s1exp_node_S1Etyarr
  (a0, a1) = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (16)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s1exp_node} (p)
end // end of [s1exp_node_S1Etyarr]

implement
s1exp_node_S1Etytup
  (a0, a1, a2) = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (17)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_staexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{s1exp_node} (p)
end // end of [s1exp_node_S1Etytup]

implement
s1exp_node_S1Etyrec
  (a0, a1, a2) = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (18)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_staexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{s1exp_node} (p)
end // end of [s1exp_node_S1Etyrec]

implement
s1exp_node_S1Etyrec_ext
  (a0, a1, a2) = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (19)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_staexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{s1exp_node} (p)
end // end of [s1exp_node_S1Etyrec_ext]

implement
s1exp_node_S1Euni
  (a0, a1) = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (20)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s1exp_node} (p)
end // end of [s1exp_node_S1Euni]

implement
s1exp_node_S1Eexi
  (a0, a1, a2) = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (21)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_staexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{s1exp_node} (p)
end // end of [s1exp_node_S1Eexi]

implement
s1exp_node_S1Eann
  (a0, a1) = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (22)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s1exp_node} (p)
end // end of [s1exp_node_S1Eann]

implement
s1exp_node_S1Ed2ctype
  (a0) = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (23)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s1exp_node} (p)
end // end of [s1exp_node_S1Ed2ctype]

implement
s1exp_node_S1Eerr
  () = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (24)))
in
  $UN.cast{s1exp_node} (p)
end // end of [s1exp_node_S1Eerr]

implement
s1exp_node_encode
  (v) =
(
case+ v of
| ~S1Eide(a0) => s1exp_node_S1Eide(a0)
| ~S1Esqid(a0, a1) => s1exp_node_S1Esqid(a0, a1)
| ~S1Eint(a0) => s1exp_node_S1Eint(a0)
| ~S1Eintrep(a0) => s1exp_node_S1Eintrep(a0)
| ~S1Echar(a0) => s1exp_node_S1Echar(a0)
| ~S1Efloat(a0) => s1exp_node_S1Efloat(a0)
| ~S1Estring(a0) => s1exp_node_S1Estring(a0)
| ~S1Eextype(a0, a1) => s1exp_node_S1Eextype(a0, a1)
| ~S1Eextkind(a0, a1) => s1exp_node_S1Eextkind(a0, a1)
| ~S1Eapp(a0, a1, a2) => s1exp_node_S1Eapp(a0, a1, a2)
| ~S1Elam(a0, a1, a2) => s1exp_node_S1Elam(a0, a1, a2)
| ~S1Eimp(a0, a1, a2, a3) => s1exp_node_S1Eimp(a0, a1, a2, a3)
| ~S1Etop(a0, a1) => s1exp_node_S1Etop(a0, a1)
| ~S1Elist(a0, a1) => s1exp_node_S1Elist(a0, a1)
| ~S1Einvar(a0, a1) => s1exp_node_S1Einvar(a0, a1)
| ~S1Etrans(a0, a1) => s1exp_node_S1Etrans(a0, a1)
| ~S1Etyarr(a0, a1) => s1exp_node_S1Etyarr(a0, a1)
| ~S1Etytup(a0, a1, a2) => s1exp_node_S1Etytup(a0, a1, a2)
| ~S1Etyrec(a0, a1, a2) => s1exp_node_S1Etyrec(a0, a1, a2)
| ~S1Etyrec_ext(a0, a1, a2) => s1exp_node_S1Etyrec_ext(a0, a1, a2)
| ~S1Euni(a0, a1) => s1exp_node_S1Euni(a0, a1)
| ~S1Eexi(a0, a1, a2) => s1exp_node_S1Eexi(a0, a1, a2)
| ~S1Eann(a0, a1) => s1exp_node_S1Eann(a0, a1)
| ~S1Ed2ctype(a0) => s1exp_node_S1Ed2ctype(a0)
| ~S1Eerr() => s1exp_node_S1Eerr()
) (* end of [s1exp_node_encode] *)

implement
s1exp_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
s1exp_node_is_S1Eide
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
s1exp_node_is_S1Esqid
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
s1exp_node_is_S1Eint
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
s1exp_node_is_S1Eintrep
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 3)

implement
s1exp_node_is_S1Echar
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 4)

implement
s1exp_node_is_S1Efloat
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 5)

implement
s1exp_node_is_S1Estring
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 6)

implement
s1exp_node_is_S1Eextype
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 7)

implement
s1exp_node_is_S1Eextkind
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 8)

implement
s1exp_node_is_S1Eapp
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 9)

implement
s1exp_node_is_S1Elam
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 10)

implement
s1exp_node_is_S1Eimp
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 11)

implement
s1exp_node_is_S1Etop
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 12)

implement
s1exp_node_is_S1Elist
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 13)

implement
s1exp_node_is_S1Einvar
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 14)

implement
s1exp_node_is_S1Etrans
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 15)

implement
s1exp_node_is_S1Etyarr
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 16)

implement
s1exp_node_is_S1Etytup
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 17)

implement
s1exp_node_is_S1Etyrec
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 18)

implement
s1exp_node_is_S1Etyrec_ext
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 19)

implement
s1exp_node_is_S1Euni
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 20)

implement
s1exp_node_is_S1Eexi
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 21)

implement
s1exp_node_is_S1Eann
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 22)

implement
s1exp_node_is_S1Ed2ctype
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 23)

implement
s1exp_node_is_S1Eerr
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 24)

implement
s1exp_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 0)))
//
in
//
case+ tag of
| 0 => S1Eide($UN.cast{symbol} ($UN.cast{lint} (pats_staexp1_ld (p, 8))))
| 1 => S1Esqid($UN.cast{s0taq} ($UN.cast{lint} (pats_staexp1_ld (p, 8))), $UN.cast{symbol} ($UN.cast{lint} (pats_staexp1_ld (p, 16))))
| 2 => S1Eint($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 8))))
| 3 => S1Eintrep($UN.cast{string} ($UN.cast{lint} (pats_staexp1_ld (p, 8))))
| 4 => S1Echar($UN.cast{char} ($UN.cast{lint} (pats_staexp1_ld (p, 8))))
| 5 => S1Efloat($UN.cast{string} ($UN.cast{lint} (pats_staexp1_ld (p, 8))))
| 6 => S1Estring($UN.cast{string} ($UN.cast{lint} (pats_staexp1_ld (p, 8))))
| 7 => S1Eextype($UN.cast{string} ($UN.cast{lint} (pats_staexp1_ld (p, 8))), $UN.cast{s1explstlst} ($UN.cast{lint} (pats_staexp1_ld (p, 16))))
| 8 => S1Eextkind($UN.cast{string} ($UN.cast{lint} (pats_staexp1_ld (p, 8))), $UN.cast{s1explstlst} ($UN.cast{lint} (pats_staexp1_ld (p, 16))))
| 9 => S1Eapp($UN.cast{s1exp} ($UN.cast{lint} (pats_staexp1_ld (p, 8))), $UN.cast{loc_t} ($UN.cast{lint} (pats_staexp1_ld (p, 16))), $UN.cast{s1explst} ($UN.cast{lint} (pats_staexp1_ld (p, 24))))
| 10 => S1Elam($UN.cast{s1marg} ($UN.cast{lint} (pats_staexp1_ld (p, 8))), $UN.cast{s1rtopt} ($UN.cast{lint} (pats_staexp1_ld (p, 16))), $UN.cast{s1exp} ($UN.cast{lint} (pats_staexp1_ld (p, 24))))
| 11 => S1Eimp($UN.cast{funclo} ($UN.cast{lint} (pats_staexp1_ld (p, 8))), $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 16))), $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 24))), $UN.cast{effcstopt} ($UN.cast{lint} (pats_staexp1_ld (p, 32))))
| 12 => S1Etop($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 8))), $UN.cast{s1exp} ($UN.cast{lint} (pats_staexp1_ld (p, 16))))
| 13 => S1Elist($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 8))), $UN.cast{s1explst} ($UN.cast{lint} (pats_staexp1_ld (p, 16))))
| 14 => S1Einvar($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 8))), $UN.cast{s1exp} ($UN.cast{lint} (pats_staexp1_ld (p, 16))))
| 15 => S1Etrans($UN.cast{s1exp} ($UN.cast{lint} (pats_staexp1_ld (p, 8))), $UN.cast{s1exp} ($UN.cast{lint} (pats_staexp1_ld (p, 16))))
| 16 => S1Etyarr($UN.cast{s1exp} ($UN.cast{lint} (pats_staexp1_ld (p, 8))), $UN.cast{s1explst} ($UN.cast{lint} (pats_staexp1_ld (p, 16))))
| 17 => S1Etytup($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 8))), $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 16))), $UN.cast{s1explst} ($UN.cast{lint} (pats_staexp1_ld (p, 24))))
| 18 => S1Etyrec($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 8))), $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 16))), $UN.cast{labs1explst} ($UN.cast{lint} (pats_staexp1_ld (p, 24))))
| 19 => S1Etyrec_ext($UN.cast{string} ($UN.cast{lint} (pats_staexp1_ld (p, 8))), $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 16))), $UN.cast{labs1explst} ($UN.cast{lint} (pats_staexp1_ld (p, 24))))
| 20 => S1Euni($UN.cast{s1qualst} ($UN.cast{lint} (pats_staexp1_ld (p, 8))), $UN.cast{s1exp} ($UN.cast{lint} (pats_staexp1_ld (p, 16))))
| 21 => S1Eexi($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 8))), $UN.cast{s1qualst} ($UN.cast{lint} (pats_staexp1_ld (p, 16))), $UN.cast{s1exp} ($UN.cast{lint} (pats_staexp1_ld (p, 24))))
| 22 => S1Eann($UN.cast{s1exp} ($UN.cast{lint} (pats_staexp1_ld (p, 8))), $UN.cast{s1rt} ($UN.cast{lint} (pats_staexp1_ld (p, 16))))
| 23 => S1Ed2ctype($UN.cast{S1Ed2ctype} ($UN.cast{lint} (pats_staexp1_ld (p, 8))))
| _ => S1Eerr()
//
end // end of [s1exp_node_view]

implement
s1exp_node_view_free
  (v) =
(
case+ v of
| ~S1Eide(_) => ()
| ~S1Esqid(_, _) => ()
| ~S1Eint(_) => ()
| ~S1Eintrep(_) => ()
| ~S1Echar(_) => ()
| ~S1Efloat(_) => ()
| ~S1Estring(_) => ()
| ~S1Eextype(_, _) => ()
| ~S1Eextkind(_, _) => ()
| ~S1Eapp(_, _, _) => ()
| ~S1Elam(_, _, _) => ()
| ~S1Eimp(_, _, _, _) => ()
| ~S1Etop(_, _) => ()
| ~S1Elist(_, _) => ()
| ~S1Einvar(_, _) => ()
| ~S1Etrans(_, _) => ()
| ~S1Etyarr(_, _) => ()
| ~S1Etytup(_, _, _) => ()
| ~S1Etyrec(_, _, _) => ()
| ~S1Etyrec_ext(_, _, _) => ()
| ~S1Euni(_, _) => ()
| ~S1Eexi(_, _, _) => ()
| ~S1Eann(_, _) => ()
| ~S1Ed2ctype(_) => ()
| ~S1Eerr() => ()
) (* end of [s1exp_node_view_free] *)

(* ****** ****** *)

implement
s1rtext_node_S1TEsrt
  (a0) = let
val p = pats_staexp1_alloc (32)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s1rtext_node} (p)
end // end of [s1rtext_node_S1TEsrt]

implement
s1rtext_node_S1TEsub
  (a0, a1, a2) = let
val p = pats_staexp1_alloc (32)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_staexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{s1rtext_node} (p)
end // end of [s1rtext_node_S1TEsub]

implement
s1rtext_node_encode
  (v) =
(
case+ v of
| ~S1TEsrt(a0) => s1rtext_node_S1TEsrt(a0)
| ~S1TEsub(a0, a1, a2) => s1rtext_node_S1TEsub(a0, a1, a2)
) (* end of [s1rtext_node_encode] *)

implement
s1rtext_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
s1rtext_node_is_S1TEsrt
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
s1rtext_node_is_S1TEsub
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
s1rtext_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 0)))
//
in
//
case+ tag of
| 0 => S1TEsrt($UN.cast{s1rt} ($UN.cast{lint} (pats_staexp1_ld (p, 8))))
| _ => S1TEsub($UN.cast{symbol} ($UN.cast{lint} (pats_staexp1_ld (p, 8))), $UN.cast{s1rtext} ($UN.cast{lint} (pats_staexp1_ld (p, 16))), $UN.cast{s1explst} ($UN.cast{lint} (pats_staexp1_ld (p, 24))))
//
end // end of [s1rtext_node_view]

implement
s1rtext_node_view_free
  (v) =
(
case+ v of
| ~S1TEsrt(_) => ()
| ~S1TEsub(_, _, _) => ()
) (* end of [s1rtext_node_view_free] *)

(* ****** ****** *)

implement
s1qua_node_S1Qprop
  (a0) = let
val p = pats_staexp1_alloc (24)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s1qua_node} (p)
end // end of [s1qua_node_S1Qprop]

implement
s1qua_node_S1Qvars
  (a0, a1) = let
val p = pats_staexp1_alloc (24)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s1qua_node} (p)
end // end of [s1qua_node_S1Qvars]

implement
s1qua_node_encode
  (v) =
(
case+ v of
| ~S1Qprop(a0) => s1qua_node_S1Qprop(a0)
| ~S1Qvars(a0, a1) => s1qua_node_S1Qvars(a0, a1)
) (* end of [s1qua_node_encode] *)

implement
s1qua_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
s1qua_node_is_S1Qprop
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
s1qua_node_is_S1Qvars
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
s1qua_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 0)))
//
in
//
case+ tag of
| 0 => S1Qprop($UN.cast{s1exp} ($UN.cast{lint} (pats_staexp1_ld (p, 8))))
| _ => S1Qvars($UN.cast{i0delst} ($UN.cast{lint} (pats_staexp1_ld (p, 8))), $UN.cast{s1rtext} ($UN.cast{lint} (pats_staexp1_ld (p, 16))))
//
end // end of [s1qua_node_view]

implement
s1qua_node_view_free
  (v) =
(
case+ v of
| ~S1Qprop(_) => ()
| ~S1Qvars(_, _) => ()
) (* end of [s1qua_node_view_free] *)

(* ****** ****** *)

implement
wths1explst_WTHS1EXPLSTnil
  () = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
in
  $UN.cast{wths1explst} (p)
end // end of [wths1explst_WTHS1EXPLSTnil]

implement
wths1explst_WTHS1EXPLSTcons_some
  (a0, a1, a2, a3) = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_staexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_staexp1_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{wths1explst} (p)
end // end of [wths1explst_WTHS1EXPLSTcons_some]

implement
wths1explst_WTHS1EXPLSTcons_none
  (a0) = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{wths1explst} (p)
end // end of [wths1explst_WTHS1EXPLSTcons_none]

implement
wths1explst_encode
  (v) =
(
case+ v of
| ~WTHS1EXPLSTnil() => wths1explst_WTHS1EXPLSTnil()
| ~WTHS1EXPLSTcons_some(a0, a1, a2, a3) => wths1explst_WTHS1EXPLSTcons_some(a0, a1, a2, a3)
| ~WTHS1EXPLSTcons_none(a0) => wths1explst_WTHS1EXPLSTcons_none(a0)
) (* end of [wths1explst_encode] *)

implement
wths1explst_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
wths1explst_is_WTHS1EXPLSTnil
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
wths1explst_is_WTHS1EXPLSTcons_some
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
wths1explst_is_WTHS1EXPLSTcons_none
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
wths1explst_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 0)))
//
in
//
case+ tag of
| 0 => WTHS1EXPLSTnil()
| 1 => WTHS1EXPLSTcons_some($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 8))), $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 16))), $UN.cast{s1exp} ($UN.cast{lint} (pats_staexp1_ld (p, 24))), $UN.cast{wths1explst} ($UN.cast{lint} (pats_staexp1_ld (p, 32))))
| _ => WTHS1EXPLSTcons_none($UN.cast{wths1explst} ($UN.cast{lint} (pats_staexp1_ld (p, 8))))
//
end // end of [wths1explst_view]

implement
wths1explst_view_free
  (v) =
(
case+ v of
| ~WTHS1EXPLSTnil() => ()
| ~WTHS1EXPLSTcons_some(_, _, _, _) => ()
| ~WTHS1EXPLSTcons_none(_) => ()
) (* end of [wths1explst_view_free] *)

(* ****** ****** *)

implement
s1exp_new
  (a0, a1) = let
val p = pats_staexp1_alloc (16)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s1exp} (p)
end // end of [s1exp_new]

implement
s1exp_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
s1exp_node
  (x) = $UN.cast{s1exp_node} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
labs1exp_new
  (a0, a1, a2) = let
val p = pats_staexp1_alloc (24)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{labs1exp} (p)
end // end of [labs1exp_new]

implement
labs1exp_lab
  (x) = $UN.cast{l0ab} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
labs1exp_nam
  (x) = $UN.cast{s0tringopt} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 8)))

implement
labs1exp_elt
  (x) = $UN.cast{s1exp} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
s1rtext_new
  (a0, a1) = let
val p = pats_staexp1_alloc (16)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s1rtext} (p)
end // end of [s1rtext_new]

implement
s1rtext_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
s1rtext_node
  (x) = $UN.cast{s1rtext_node} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
s1qua_new
  (a0, a1) = let
val p = pats_staexp1_alloc (16)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s1qua} (p)
end // end of [s1qua_new]

implement
s1qua_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
s1qua_node
  (x) = $UN.cast{s1qua_node} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
s1vararg_S1VARARGone
  (a0) = let
val p = pats_staexp1_alloc (24)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s1vararg} (p)
end // end of [s1vararg_S1VARARGone]

implement
s1vararg_S1VARARGall
  (a0) = let
val p = pats_staexp1_alloc (24)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s1vararg} (p)
end // end of [s1vararg_S1VARARGall]

implement
s1vararg_S1VARARGseq
  (a0, a1) = let
val p = pats_staexp1_alloc (24)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s1vararg} (p)
end // end of [s1vararg_S1VARARGseq]

implement
s1vararg_encode
  (v) =
(
case+ v of
| ~S1VARARGone(a0) => s1vararg_S1VARARGone(a0)
| ~S1VARARGall(a0) => s1vararg_S1VARARGall(a0)
| ~S1VARARGseq(a0, a1) => s1vararg_S1VARARGseq(a0, a1)
) (* end of [s1vararg_encode] *)

implement
s1vararg_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
s1vararg_is_S1VARARGone
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
s1vararg_is_S1VARARGall
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
s1vararg_is_S1VARARGseq
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
s1vararg_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 0)))
//
in
//
case+ tag of
| 0 => S1VARARGone($UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld (p, 8))))
| 1 => S1VARARGall($UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld (p, 8))))
| _ => S1VARARGseq($UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld (p, 8))), $UN.cast{s1arglst} ($UN.cast{lint} (pats_staexp1_ld (p, 16))))
//
end // end of [s1vararg_view]

implement
s1vararg_view_free
  (v) =
(
case+ v of
| ~S1VARARGone(_) => ()
| ~S1VARARGall(_) => ()
| ~S1VARARGseq(_, _) => ()
) (* end of [s1vararg_view_free] *)

(* ****** ****** *)

implement
s1exparg_node_S1EXPARGone
  () = let
val p = pats_staexp1_alloc (16)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
in
  $UN.cast{s1exparg_node} (p)
end // end of [s1exparg_node_S1EXPARGone]

implement
s1exparg_node_S1EXPARGall
  () = let
val p = pats_staexp1_alloc (16)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
in
  $UN.cast{s1exparg_node} (p)
end // end of [s1exparg_node_S1EXPARGall]

implement
s1exparg_node_S1EXPARGseq
  (a0) = let
val p = pats_staexp1_alloc (16)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s1exparg_node} (p)
end // end of [s1exparg_node_S1EXPARGseq]

implement
s1exparg_node_encode
  (v) =
(
case+ v of
| ~S1EXPARGone() => s1exparg_node_S1EXPARGone()
| ~S1EXPARGall() => s1exparg_node_S1EXPARGall()
| ~S1EXPARGseq(a0) => s1exparg_node_S1EXPARGseq(a0)
) (* end of [s1exparg_node_encode] *)

implement
s1exparg_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
s1exparg_node_is_S1EXPARGone
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
s1exparg_node_is_S1EXPARGall
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
s1exparg_node_is_S1EXPARGseq
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
s1exparg_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 0)))
//
in
//
case+ tag of
| 0 => S1EXPARGone()
| 1 => S1EXPARGall()
| _ => S1EXPARGseq($UN.cast{s1explst} ($UN.cast{lint} (pats_staexp1_ld (p, 8))))
//
end // end of [s1exparg_node_view]

implement
s1exparg_node_view_free
  (v) =
(
case+ v of
| ~S1EXPARGone() => ()
| ~S1EXPARGall() => ()
| ~S1EXPARGseq(_) => ()
) (* end of [s1exparg_node_view_free] *)

(* ****** ****** *)

implement
s1exparg_new
  (a0, a1) = let
val p = pats_staexp1_alloc (16)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s1exparg} (p)
end // end of [s1exparg_new]

implement
s1exparg_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
s1exparg_node
  (x) = $UN.cast{s1exparg_node} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
m1acarg_node_M1ACARGdyn
  (a0) = let
val p = pats_staexp1_alloc (16)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{m1acarg_node} (p)
end // end of [m1acarg_node_M1ACARGdyn]

implement
m1acarg_node_M1ACARGsta
  (a0) = let
val p = pats_staexp1_alloc (16)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{m1acarg_node} (p)
end // end of [m1acarg_node_M1ACARGsta]

implement
m1acarg_node_encode
  (v) =
(
case+ v of
| ~M1ACARGdyn(a0) => m1acarg_node_M1ACARGdyn(a0)
| ~M1ACARGsta(a0) => m1acarg_node_M1ACARGsta(a0)
) (* end of [m1acarg_node_encode] *)

implement
m1acarg_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
m1acarg_node_is_M1ACARGdyn
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
m1acarg_node_is_M1ACARGsta
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
m1acarg_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 0)))
//
in
//
case+ tag of
| 0 => M1ACARGdyn($UN.cast{i0delst} ($UN.cast{lint} (pats_staexp1_ld (p, 8))))
| _ => M1ACARGsta($UN.cast{s1arglst} ($UN.cast{lint} (pats_staexp1_ld (p, 8))))
//
end // end of [m1acarg_node_view]

implement
m1acarg_node_view_free
  (v) =
(
case+ v of
| ~M1ACARGdyn(_) => ()
| ~M1ACARGsta(_) => ()
) (* end of [m1acarg_node_view_free] *)

(* ****** ****** *)

implement
m1acarg_new
  (a0, a1) = let
val p = pats_staexp1_alloc (16)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{m1acarg} (p)
end // end of [m1acarg_new]

implement
m1acarg_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
m1acarg_node
  (x) = $UN.cast{m1acarg_node} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
witht1ype_WITHT1YPEsome
  (a0, a1) = let
val p = pats_staexp1_alloc (24)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{witht1ype} (p)
end // end of [witht1ype_WITHT1YPEsome]

implement
witht1ype_WITHT1YPEnone
  () = let
val p = pats_staexp1_alloc (24)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
in
  $UN.cast{witht1ype} (p)
end // end of [witht1ype_WITHT1YPEnone]

implement
witht1ype_encode
  (v) =
(
case+ v of
| ~WITHT1YPEsome(a0, a1) => witht1ype_WITHT1YPEsome(a0, a1)
| ~WITHT1YPEnone() => witht1ype_WITHT1YPEnone()
) (* end of [witht1ype_encode] *)

implement
witht1ype_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
witht1ype_is_WITHT1YPEsome
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
witht1ype_is_WITHT1YPEnone
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
witht1ype_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 0)))
//
in
//
case+ tag of
| 0 => WITHT1YPEsome($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 8))), $UN.cast{s1exp} ($UN.cast{lint} (pats_staexp1_ld (p, 16))))
| _ => WITHT1YPEnone()
//
end // end of [witht1ype_view]

implement
witht1ype_view_free
  (v) =
(
case+ v of
| ~WITHT1YPEsome(_, _) => ()
| ~WITHT1YPEnone() => ()
) (* end of [witht1ype_view_free] *)

(* ****** ****** *)

implement
s1rtdef_new
  (a0, a1, a2) = let
val p = pats_staexp1_alloc (24)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{s1rtdef} (p)
end // end of [s1rtdef_new]

implement
s1rtdef_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
s1rtdef_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 8)))

implement
s1rtdef_def
  (x) = $UN.cast{s1rtext} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
s1tacst_new
  (a0, a1, a2, a3, a4, a5) = let
val p = pats_staexp1_alloc (48)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_staexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_staexp1_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a4)))
val () = pats_staexp1_st (p, 40, $UN.cast{ptr} ($UN.cast{lint} (a5)))
in
  $UN.cast{s1tacst} (p)
end // end of [s1tacst_new]

implement
s1tacst_loc
  (x) = $UN.cast{loc_t} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
s1tacst_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 8)))

implement
s1tacst_fil
  (x) = $UN.cast{filename} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 16)))

implement
s1tacst_arg
  (x) = $UN.cast{a1msrtlst} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 24)))

implement
s1tacst_res
  (x) = $UN.cast{s1rt} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 32)))

implement
s1tacst_extdef
  (x) = $UN.cast{scstextdef} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 40)))

(* ****** ****** *)

implement
s1tacon_new
  (a0, a1, a2, a3, a4) = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_staexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_staexp1_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a4)))
in
  $UN.cast{s1tacon} (p)
end // end of [s1tacon_new]

implement
s1tacon_loc
  (x) = $UN.cast{loc_t} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
s1tacon_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 8)))

implement
s1tacon_fil
  (x) = $UN.cast{filename} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 16)))

implement
s1tacon_arg
  (x) = $UN.cast{a1msrtlst} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 24)))

implement
s1tacon_def
  (x) = $UN.cast{s1expopt} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 32)))

(* ****** ****** *)

implement
t1kindef_new
  (a0, a1, a2, a3) = let
val p = pats_staexp1_alloc (32)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_staexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{t1kindef} (p)
end // end of [t1kindef_new]

implement
t1kindef_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
t1kindef_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 8)))

implement
t1kindef_loc_id
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 16)))

implement
t1kindef_def
  (x) = $UN.cast{s1exp} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 24)))

(* ****** ****** *)

implement
s1expdef_new
  (a0, a1, a2, a3, a4, a5) = let
val p = pats_staexp1_alloc (48)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_staexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_staexp1_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a4)))
val () = pats_staexp1_st (p, 40, $UN.cast{ptr} ($UN.cast{lint} (a5)))
in
  $UN.cast{s1expdef} (p)
end // end of [s1expdef_new]

implement
s1expdef_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
s1expdef_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 8)))

implement
s1expdef_loc_id
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 16)))

implement
s1expdef_arg
  (x) = $UN.cast{s1marglst} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 24)))

implement
s1expdef_res
  (x) = $UN.cast{s1rtopt} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 32)))

implement
s1expdef_def
  (x) = $UN.cast{s1exp} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 40)))

(* ****** ****** *)

implement
s1aspdec_new
  (a0, a1, a2, a3, a4) = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_staexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_staexp1_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a4)))
in
  $UN.cast{s1aspdec} (p)
end // end of [s1aspdec_new]

implement
s1aspdec_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
s1aspdec_qid
  (x) = $UN.cast{sqi0de} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 8)))

implement
s1aspdec_arg
  (x) = $UN.cast{s1marglst} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 16)))

implement
s1aspdec_res
  (x) = $UN.cast{s1rtopt} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 24)))

implement
s1aspdec_def
  (x) = $UN.cast{s1exp} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 32)))

(* ****** ****** *)

implement
q1marg_new
  (a0, a1) = let
val p = pats_staexp1_alloc (16)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{q1marg} (p)
end // end of [q1marg_new]

implement
q1marg_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
q1marg_arg
  (x) = $UN.cast{s1qualst} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
i1mparg_I1MPARG_sarglst
  (a0) = let
val p = pats_staexp1_alloc (16)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{i1mparg} (p)
end // end of [i1mparg_I1MPARG_sarglst]

implement
i1mparg_I1MPARG_svararglst
  (a0) = let
val p = pats_staexp1_alloc (16)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{i1mparg} (p)
end // end of [i1mparg_I1MPARG_svararglst]

implement
i1mparg_encode
  (v) =
(
case+ v of
| ~I1MPARG_sarglst(a0) => i1mparg_I1MPARG_sarglst(a0)
| ~I1MPARG_svararglst(a0) => i1mparg_I1MPARG_svararglst(a0)
) (* end of [i1mparg_encode] *)

implement
i1mparg_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
i1mparg_is_I1MPARG_sarglst
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
i1mparg_is_I1MPARG_svararglst
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
i1mparg_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld (p, 0)))
//
in
//
case+ tag of
| 0 => I1MPARG_sarglst($UN.cast{s1arglst} ($UN.cast{lint} (pats_staexp1_ld (p, 8))))
| _ => I1MPARG_svararglst($UN.cast{s1vararglst} ($UN.cast{lint} (pats_staexp1_ld (p, 8))))
//
end // end of [i1mparg_view]

implement
i1mparg_view_free
  (v) =
(
case+ v of
| ~I1MPARG_sarglst(_) => ()
| ~I1MPARG_svararglst(_) => ()
) (* end of [i1mparg_view_free] *)

(* ****** ****** *)

implement
t1mpmarg_new
  (a0, a1) = let
val p = pats_staexp1_alloc (16)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{t1mpmarg} (p)
end // end of [t1mpmarg_new]

implement
t1mpmarg_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
t1mpmarg_arg
  (x) = $UN.cast{s1explst} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
d1atcon_new
  (a0, a1, a2, a3, a4, a5) = let
val p = pats_staexp1_alloc (48)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_staexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_staexp1_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a4)))
val () = pats_staexp1_st (p, 40, $UN.cast{ptr} ($UN.cast{lint} (a5)))
in
  $UN.cast{d1atcon} (p)
end // end of [d1atcon_new]

implement
d1atcon_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
d1atcon_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 8)))

implement
d1atcon_qua
  (x) = $UN.cast{q1marglst} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 16)))

implement
d1atcon_npf
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 24)))

implement
d1atcon_arg
  (x) = $UN.cast{s1explst} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 32)))

implement
d1atcon_ind
  (x) = $UN.cast{s1explstopt} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 40)))

(* ****** ****** *)

implement
d1atdec_new
  (a0, a1, a2, a3, a4) = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_staexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_staexp1_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a4)))
in
  $UN.cast{d1atdec} (p)
end // end of [d1atdec_new]

implement
d1atdec_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
d1atdec_fil
  (x) = $UN.cast{filename} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 8)))

implement
d1atdec_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 16)))

implement
d1atdec_arg
  (x) = $UN.cast{a1msrtlst} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 24)))

implement
d1atdec_con
  (x) = $UN.cast{d1atconlst} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 32)))

(* ****** ****** *)

implement
e1xndec_new
  (a0, a1, a2, a3, a4, a5) = let
val p = pats_staexp1_alloc (48)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_staexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_staexp1_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a4)))
val () = pats_staexp1_st (p, 40, $UN.cast{ptr} ($UN.cast{lint} (a5)))
in
  $UN.cast{e1xndec} (p)
end // end of [e1xndec_new]

implement
e1xndec_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
e1xndec_fil
  (x) = $UN.cast{filename} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 8)))

implement
e1xndec_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 16)))

implement
e1xndec_qua
  (x) = $UN.cast{q1marglst} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 24)))

implement
e1xndec_npf
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 32)))

implement
e1xndec_arg
  (x) = $UN.cast{s1explst} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 40)))

(* ****** ****** *)

implement
d1cstdec_new
  (a0, a1, a2, a3, a4) = let
val p = pats_staexp1_alloc (40)
val () = pats_staexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_staexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_staexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_staexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_staexp1_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a4)))
in
  $UN.cast{d1cstdec} (p)
end // end of [d1cstdec_new]

implement
d1cstdec_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 0)))

implement
d1cstdec_fil
  (x) = $UN.cast{filename} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 8)))

implement
d1cstdec_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 16)))

implement
d1cstdec_type
  (x) = $UN.cast{s1exp} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 24)))

implement
d1cstdec_extdef
  (x) = $UN.cast{dcstextdef} ($UN.cast{lint} (pats_staexp1_ld ($UN.cast{ptr} (x), 32)))

(* ****** ****** *)
