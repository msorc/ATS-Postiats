fn pats_trans1_env_ld (p: ptr, k: int): ptr = $UN.ptr0_get<ptr> (ptr0_add_gint<byte> (p, k))
fn pats_trans1_env_st (p: ptr, k: int, x: ptr): void = $UN.ptr0_set<ptr> (ptr0_add_gint<byte> (p, k), x)
fn pats_trans1_env_alloc (n: int): ptr = the_garena_alloc ($UN.cast{size_t} (n))
//

implement
atsrelocitm_ATSRELOCITM
  (a0, a1) = let
val p = pats_trans1_env_alloc (32)
val () = pats_trans1_env_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_trans1_env_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_trans1_env_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{atsrelocitm} (p)
end // end of [atsrelocitm_ATSRELOCITM]

implement
atsrelocitm_ATSRELOCITM2
  (a0, a1, a2) = let
val p = pats_trans1_env_alloc (32)
val () = pats_trans1_env_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_trans1_env_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_trans1_env_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_trans1_env_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{atsrelocitm} (p)
end // end of [atsrelocitm_ATSRELOCITM2]

implement
atsrelocitm_encode
  (v) =
(
case+ v of
| ~ATSRELOCITM(a0, a1) => atsrelocitm_ATSRELOCITM(a0, a1)
| ~ATSRELOCITM2(a0, a1, a2) => atsrelocitm_ATSRELOCITM2(a0, a1, a2)
) (* end of [atsrelocitm_encode] *)

implement
atsrelocitm_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_trans1_env_ld ($UN.cast{ptr} (x), 0)))

implement
atsrelocitm_is_ATSRELOCITM
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_trans1_env_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
atsrelocitm_is_ATSRELOCITM2
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_trans1_env_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
atsrelocitm_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_trans1_env_ld (p, 0)))
//
in
//
case+ tag of
| 0 => ATSRELOCITM($UN.cast{d0ecl} ($UN.cast{lint} (pats_trans1_env_ld (p, 8))), $UN.cast{string} ($UN.cast{lint} (pats_trans1_env_ld (p, 16))))
| _ => ATSRELOCITM2($UN.cast{d0ecl} ($UN.cast{lint} (pats_trans1_env_ld (p, 8))), $UN.cast{string} ($UN.cast{lint} (pats_trans1_env_ld (p, 16))), $UN.cast{string} ($UN.cast{lint} (pats_trans1_env_ld (p, 24))))
//
end // end of [atsrelocitm_view]

implement
atsrelocitm_view_free
  (v) =
(
case+ v of
| ~ATSRELOCITM(_, _) => ()
| ~ATSRELOCITM2(_, _, _) => ()
) (* end of [atsrelocitm_view_free] *)

(* ****** ****** *)
