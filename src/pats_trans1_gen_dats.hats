fn pats_trans1_ld (p: ptr, k: int): ptr = $UN.ptr0_get<ptr> (ptr0_add_gint<byte> (p, k))
fn pats_trans1_st (p: ptr, k: int, x: ptr): void = $UN.ptr0_set<ptr> (ptr0_add_gint<byte> (p, k), x)
fn pats_trans1_alloc (n: int): ptr = the_garena_alloc ($UN.cast{size_t} (n))
//

implement
trans1err_T1E_prec_tr
  (a0) = let
val p = pats_trans1_alloc (16)
val () = pats_trans1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_trans1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{trans1err} (p)
end // end of [trans1err_T1E_prec_tr]

implement
trans1err_T1E_e0xp_tr
  (a0) = let
val p = pats_trans1_alloc (16)
val () = pats_trans1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_trans1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{trans1err} (p)
end // end of [trans1err_T1E_e0xp_tr]

implement
trans1err_T1E_s0rt_tr
  (a0) = let
val p = pats_trans1_alloc (16)
val () = pats_trans1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_trans1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{trans1err} (p)
end // end of [trans1err_T1E_s0rt_tr]

implement
trans1err_T1E_s0exp_tr
  (a0) = let
val p = pats_trans1_alloc (16)
val () = pats_trans1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (3)))
val () = pats_trans1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{trans1err} (p)
end // end of [trans1err_T1E_s0exp_tr]

implement
trans1err_T1E_p0at_tr
  (a0) = let
val p = pats_trans1_alloc (16)
val () = pats_trans1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (4)))
val () = pats_trans1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{trans1err} (p)
end // end of [trans1err_T1E_p0at_tr]

implement
trans1err_T1E_d0exp_tr
  (a0) = let
val p = pats_trans1_alloc (16)
val () = pats_trans1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (5)))
val () = pats_trans1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{trans1err} (p)
end // end of [trans1err_T1E_d0exp_tr]

implement
trans1err_T1E_d0cstdec_tr
  (a0) = let
val p = pats_trans1_alloc (16)
val () = pats_trans1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (6)))
val () = pats_trans1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{trans1err} (p)
end // end of [trans1err_T1E_d0cstdec_tr]

implement
trans1err_T1E_termet_check
  (a0) = let
val p = pats_trans1_alloc (16)
val () = pats_trans1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (7)))
val () = pats_trans1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{trans1err} (p)
end // end of [trans1err_T1E_termet_check]

implement
trans1err_T1E_i0nclude_tr
  (a0) = let
val p = pats_trans1_alloc (16)
val () = pats_trans1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (8)))
val () = pats_trans1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{trans1err} (p)
end // end of [trans1err_T1E_i0nclude_tr]

implement
trans1err_T1E_s0taload_tr
  (a0) = let
val p = pats_trans1_alloc (16)
val () = pats_trans1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (9)))
val () = pats_trans1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{trans1err} (p)
end // end of [trans1err_T1E_s0taload_tr]

implement
trans1err_T1E_d0ynload_tr
  (a0) = let
val p = pats_trans1_alloc (16)
val () = pats_trans1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (10)))
val () = pats_trans1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{trans1err} (p)
end // end of [trans1err_T1E_d0ynload_tr]

implement
trans1err_encode
  (v) =
(
case+ v of
| ~T1E_prec_tr(a0) => trans1err_T1E_prec_tr(a0)
| ~T1E_e0xp_tr(a0) => trans1err_T1E_e0xp_tr(a0)
| ~T1E_s0rt_tr(a0) => trans1err_T1E_s0rt_tr(a0)
| ~T1E_s0exp_tr(a0) => trans1err_T1E_s0exp_tr(a0)
| ~T1E_p0at_tr(a0) => trans1err_T1E_p0at_tr(a0)
| ~T1E_d0exp_tr(a0) => trans1err_T1E_d0exp_tr(a0)
| ~T1E_d0cstdec_tr(a0) => trans1err_T1E_d0cstdec_tr(a0)
| ~T1E_termet_check(a0) => trans1err_T1E_termet_check(a0)
| ~T1E_i0nclude_tr(a0) => trans1err_T1E_i0nclude_tr(a0)
| ~T1E_s0taload_tr(a0) => trans1err_T1E_s0taload_tr(a0)
| ~T1E_d0ynload_tr(a0) => trans1err_T1E_d0ynload_tr(a0)
) (* end of [trans1err_encode] *)

implement
trans1err_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_trans1_ld ($UN.cast{ptr} (x), 0)))

implement
trans1err_is_T1E_prec_tr
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_trans1_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
trans1err_is_T1E_e0xp_tr
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_trans1_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
trans1err_is_T1E_s0rt_tr
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_trans1_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
trans1err_is_T1E_s0exp_tr
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_trans1_ld ($UN.cast{ptr} (x), 0))) = 3)

implement
trans1err_is_T1E_p0at_tr
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_trans1_ld ($UN.cast{ptr} (x), 0))) = 4)

implement
trans1err_is_T1E_d0exp_tr
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_trans1_ld ($UN.cast{ptr} (x), 0))) = 5)

implement
trans1err_is_T1E_d0cstdec_tr
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_trans1_ld ($UN.cast{ptr} (x), 0))) = 6)

implement
trans1err_is_T1E_termet_check
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_trans1_ld ($UN.cast{ptr} (x), 0))) = 7)

implement
trans1err_is_T1E_i0nclude_tr
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_trans1_ld ($UN.cast{ptr} (x), 0))) = 8)

implement
trans1err_is_T1E_s0taload_tr
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_trans1_ld ($UN.cast{ptr} (x), 0))) = 9)

implement
trans1err_is_T1E_d0ynload_tr
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_trans1_ld ($UN.cast{ptr} (x), 0))) = 10)

implement
trans1err_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_trans1_ld (p, 0)))
//
in
//
case+ tag of
| 0 => T1E_prec_tr($UN.cast{i0de} ($UN.cast{lint} (pats_trans1_ld (p, 8))))
| 1 => T1E_e0xp_tr($UN.cast{e0xp} ($UN.cast{lint} (pats_trans1_ld (p, 8))))
| 2 => T1E_s0rt_tr($UN.cast{s0rt} ($UN.cast{lint} (pats_trans1_ld (p, 8))))
| 3 => T1E_s0exp_tr($UN.cast{s0exp} ($UN.cast{lint} (pats_trans1_ld (p, 8))))
| 4 => T1E_p0at_tr($UN.cast{p0at} ($UN.cast{lint} (pats_trans1_ld (p, 8))))
| 5 => T1E_d0exp_tr($UN.cast{d0exp} ($UN.cast{lint} (pats_trans1_ld (p, 8))))
| 6 => T1E_d0cstdec_tr($UN.cast{d0cstdec} ($UN.cast{lint} (pats_trans1_ld (p, 8))))
| 7 => T1E_termet_check($UN.cast{location} ($UN.cast{lint} (pats_trans1_ld (p, 8))))
| 8 => T1E_i0nclude_tr($UN.cast{d0ecl} ($UN.cast{lint} (pats_trans1_ld (p, 8))))
| 9 => T1E_s0taload_tr($UN.cast{d0ecl} ($UN.cast{lint} (pats_trans1_ld (p, 8))))
| _ => T1E_d0ynload_tr($UN.cast{d0ecl} ($UN.cast{lint} (pats_trans1_ld (p, 8))))
//
end // end of [trans1err_view]

implement
trans1err_view_free
  (v) =
(
case+ v of
| ~T1E_prec_tr(_) => ()
| ~T1E_e0xp_tr(_) => ()
| ~T1E_s0rt_tr(_) => ()
| ~T1E_s0exp_tr(_) => ()
| ~T1E_p0at_tr(_) => ()
| ~T1E_d0exp_tr(_) => ()
| ~T1E_d0cstdec_tr(_) => ()
| ~T1E_termet_check(_) => ()
| ~T1E_i0nclude_tr(_) => ()
| ~T1E_s0taload_tr(_) => ()
| ~T1E_d0ynload_tr(_) => ()
) (* end of [trans1err_view_free] *)

(* ****** ****** *)
