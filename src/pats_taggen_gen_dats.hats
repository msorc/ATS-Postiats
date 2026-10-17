fn pats_taggen_ld (p: ptr, k: int): ptr = $UN.ptr0_get<ptr> (ptr0_add_gint<byte> (p, k))
fn pats_taggen_st (p: ptr, k: int, x: ptr): void = $UN.ptr0_set<ptr> (ptr0_add_gint<byte> (p, k), x)
fn pats_taggen_alloc (n: int): ptr = the_garena_alloc ($UN.cast{size_t} (n))
//

implement
tagent_new
  (a0, a1) = let
val p = pats_taggen_alloc (16)
val () = pats_taggen_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_taggen_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{tagent} (p)
end // end of [tagent_new]

implement
tagent_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_taggen_ld ($UN.cast{ptr} (x), 0)))

implement
tagent_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_taggen_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)
