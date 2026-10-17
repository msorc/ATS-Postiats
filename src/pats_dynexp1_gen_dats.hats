fn pats_dynexp1_ld (p: ptr, k: int): ptr = $UN.ptr0_get<ptr> (ptr0_add_gint<byte> (p, k))
fn pats_dynexp1_st (p: ptr, k: int, x: ptr): void = $UN.ptr0_set<ptr> (ptr0_add_gint<byte> (p, k), x)
fn pats_dynexp1_alloc (n: int): ptr = the_garena_alloc ($UN.cast{size_t} (n))
//

implement
p1at_node_P1Tany
  () = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
in
  $UN.cast{p1at_node} (p)
end // end of [p1at_node_P1Tany]

implement
p1at_node_P1Tany2
  () = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
in
  $UN.cast{p1at_node} (p)
end // end of [p1at_node_P1Tany2]

implement
p1at_node_P1Tide
  (a0) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{p1at_node} (p)
end // end of [p1at_node_P1Tide]

implement
p1at_node_P1Tdqid
  (a0, a1) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (3)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{p1at_node} (p)
end // end of [p1at_node_P1Tdqid]

implement
p1at_node_P1Tint
  (a0) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (4)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{p1at_node} (p)
end // end of [p1at_node_P1Tint]

implement
p1at_node_P1Tintrep
  (a0) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (5)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{p1at_node} (p)
end // end of [p1at_node_P1Tintrep]

implement
p1at_node_P1Tchar
  (a0) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (6)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{p1at_node} (p)
end // end of [p1at_node_P1Tchar]

implement
p1at_node_P1Tfloat
  (a0) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (7)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{p1at_node} (p)
end // end of [p1at_node_P1Tfloat]

implement
p1at_node_P1Tstring
  (a0) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (8)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{p1at_node} (p)
end // end of [p1at_node_P1Tstring]

implement
p1at_node_P1Ti0nt
  (a0) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (9)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{p1at_node} (p)
end // end of [p1at_node_P1Ti0nt]

implement
p1at_node_P1Tf0loat
  (a0) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (10)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{p1at_node} (p)
end // end of [p1at_node_P1Tf0loat]

implement
p1at_node_P1Tempty
  () = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (11)))
in
  $UN.cast{p1at_node} (p)
end // end of [p1at_node_P1Tempty]

implement
p1at_node_P1Tapp_sta
  (a0, a1) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (12)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{p1at_node} (p)
end // end of [p1at_node_P1Tapp_sta]

implement
p1at_node_P1Tapp_dyn
  (a0, a1, a2, a3) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (13)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_dynexp1_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{p1at_node} (p)
end // end of [p1at_node_P1Tapp_dyn]

implement
p1at_node_P1Tlist
  (a0, a1) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (14)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{p1at_node} (p)
end // end of [p1at_node_P1Tlist]

implement
p1at_node_P1Ttup
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (15)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{p1at_node} (p)
end // end of [p1at_node_P1Ttup]

implement
p1at_node_P1Trec
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (16)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{p1at_node} (p)
end // end of [p1at_node_P1Trec]

implement
p1at_node_P1Tlst
  (a0, a1) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (17)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{p1at_node} (p)
end // end of [p1at_node_P1Tlst]

implement
p1at_node_P1Tfree
  (a0) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (18)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{p1at_node} (p)
end // end of [p1at_node_P1Tfree]

implement
p1at_node_P1Tunfold
  (a0) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (19)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{p1at_node} (p)
end // end of [p1at_node_P1Tunfold]

implement
p1at_node_P1Trefas
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (20)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{p1at_node} (p)
end // end of [p1at_node_P1Trefas]

implement
p1at_node_P1Texist
  (a0, a1) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (21)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{p1at_node} (p)
end // end of [p1at_node_P1Texist]

implement
p1at_node_P1Tsvararg
  (a0) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (22)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{p1at_node} (p)
end // end of [p1at_node_P1Tsvararg]

implement
p1at_node_P1Tann
  (a0, a1) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (23)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{p1at_node} (p)
end // end of [p1at_node_P1Tann]

implement
p1at_node_P1Terrpat
  () = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (24)))
in
  $UN.cast{p1at_node} (p)
end // end of [p1at_node_P1Terrpat]

implement
p1at_node_encode
  (v) =
(
case+ v of
| ~P1Tany() => p1at_node_P1Tany()
| ~P1Tany2() => p1at_node_P1Tany2()
| ~P1Tide(a0) => p1at_node_P1Tide(a0)
| ~P1Tdqid(a0, a1) => p1at_node_P1Tdqid(a0, a1)
| ~P1Tint(a0) => p1at_node_P1Tint(a0)
| ~P1Tintrep(a0) => p1at_node_P1Tintrep(a0)
| ~P1Tchar(a0) => p1at_node_P1Tchar(a0)
| ~P1Tfloat(a0) => p1at_node_P1Tfloat(a0)
| ~P1Tstring(a0) => p1at_node_P1Tstring(a0)
| ~P1Ti0nt(a0) => p1at_node_P1Ti0nt(a0)
| ~P1Tf0loat(a0) => p1at_node_P1Tf0loat(a0)
| ~P1Tempty() => p1at_node_P1Tempty()
| ~P1Tapp_sta(a0, a1) => p1at_node_P1Tapp_sta(a0, a1)
| ~P1Tapp_dyn(a0, a1, a2, a3) => p1at_node_P1Tapp_dyn(a0, a1, a2, a3)
| ~P1Tlist(a0, a1) => p1at_node_P1Tlist(a0, a1)
| ~P1Ttup(a0, a1, a2) => p1at_node_P1Ttup(a0, a1, a2)
| ~P1Trec(a0, a1, a2) => p1at_node_P1Trec(a0, a1, a2)
| ~P1Tlst(a0, a1) => p1at_node_P1Tlst(a0, a1)
| ~P1Tfree(a0) => p1at_node_P1Tfree(a0)
| ~P1Tunfold(a0) => p1at_node_P1Tunfold(a0)
| ~P1Trefas(a0, a1, a2) => p1at_node_P1Trefas(a0, a1, a2)
| ~P1Texist(a0, a1) => p1at_node_P1Texist(a0, a1)
| ~P1Tsvararg(a0) => p1at_node_P1Tsvararg(a0)
| ~P1Tann(a0, a1) => p1at_node_P1Tann(a0, a1)
| ~P1Terrpat() => p1at_node_P1Terrpat()
) (* end of [p1at_node_encode] *)

implement
p1at_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0)))

implement
p1at_node_is_P1Tany
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
p1at_node_is_P1Tany2
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
p1at_node_is_P1Tide
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
p1at_node_is_P1Tdqid
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 3)

implement
p1at_node_is_P1Tint
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 4)

implement
p1at_node_is_P1Tintrep
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 5)

implement
p1at_node_is_P1Tchar
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 6)

implement
p1at_node_is_P1Tfloat
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 7)

implement
p1at_node_is_P1Tstring
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 8)

implement
p1at_node_is_P1Ti0nt
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 9)

implement
p1at_node_is_P1Tf0loat
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 10)

implement
p1at_node_is_P1Tempty
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 11)

implement
p1at_node_is_P1Tapp_sta
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 12)

implement
p1at_node_is_P1Tapp_dyn
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 13)

implement
p1at_node_is_P1Tlist
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 14)

implement
p1at_node_is_P1Ttup
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 15)

implement
p1at_node_is_P1Trec
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 16)

implement
p1at_node_is_P1Tlst
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 17)

implement
p1at_node_is_P1Tfree
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 18)

implement
p1at_node_is_P1Tunfold
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 19)

implement
p1at_node_is_P1Trefas
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 20)

implement
p1at_node_is_P1Texist
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 21)

implement
p1at_node_is_P1Tsvararg
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 22)

implement
p1at_node_is_P1Tann
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 23)

implement
p1at_node_is_P1Terrpat
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 24)

implement
p1at_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 0)))
//
in
//
case+ tag of
| 0 => P1Tany()
| 1 => P1Tany2()
| 2 => P1Tide($UN.cast{symbol} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 3 => P1Tdqid($UN.cast{d0ynq} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{symbol} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 4 => P1Tint($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 5 => P1Tintrep($UN.cast{string} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 6 => P1Tchar($UN.cast{char} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 7 => P1Tfloat($UN.cast{string} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 8 => P1Tstring($UN.cast{string} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 9 => P1Ti0nt($UN.cast{i0nt} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 10 => P1Tf0loat($UN.cast{f0loat} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 11 => P1Tempty()
| 12 => P1Tapp_sta($UN.cast{p1at} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{s1vararglst} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 13 => P1Tapp_dyn($UN.cast{p1at} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{loc_t} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))), $UN.cast{p1atlst} ($UN.cast{lint} (pats_dynexp1_ld (p, 32))))
| 14 => P1Tlist($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{p1atlst} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 15 => P1Ttup($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{p1atlst} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))))
| 16 => P1Trec($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{labp1atlst} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))))
| 17 => P1Tlst($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{p1atlst} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 18 => P1Tfree($UN.cast{p1at} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 19 => P1Tunfold($UN.cast{p1at} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 20 => P1Trefas($UN.cast{symbol} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{loc_t} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{p1at} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))))
| 21 => P1Texist($UN.cast{s1arglst} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{p1at} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 22 => P1Tsvararg($UN.cast{s1vararg} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 23 => P1Tann($UN.cast{p1at} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{s1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| _ => P1Terrpat()
//
end // end of [p1at_node_view]

implement
p1at_node_view_free
  (v) =
(
case+ v of
| ~P1Tany() => ()
| ~P1Tany2() => ()
| ~P1Tide(_) => ()
| ~P1Tdqid(_, _) => ()
| ~P1Tint(_) => ()
| ~P1Tintrep(_) => ()
| ~P1Tchar(_) => ()
| ~P1Tfloat(_) => ()
| ~P1Tstring(_) => ()
| ~P1Ti0nt(_) => ()
| ~P1Tf0loat(_) => ()
| ~P1Tempty() => ()
| ~P1Tapp_sta(_, _) => ()
| ~P1Tapp_dyn(_, _, _, _) => ()
| ~P1Tlist(_, _) => ()
| ~P1Ttup(_, _, _) => ()
| ~P1Trec(_, _, _) => ()
| ~P1Tlst(_, _) => ()
| ~P1Tfree(_) => ()
| ~P1Tunfold(_) => ()
| ~P1Trefas(_, _, _) => ()
| ~P1Texist(_, _) => ()
| ~P1Tsvararg(_) => ()
| ~P1Tann(_, _) => ()
| ~P1Terrpat() => ()
) (* end of [p1at_node_view_free] *)

(* ****** ****** *)

implement
labp1at_node_LABP1ATomit
  () = let
val p = pats_dynexp1_alloc (24)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
in
  $UN.cast{labp1at_node} (p)
end // end of [labp1at_node_LABP1ATomit]

implement
labp1at_node_LABP1ATnorm
  (a0, a1) = let
val p = pats_dynexp1_alloc (24)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{labp1at_node} (p)
end // end of [labp1at_node_LABP1ATnorm]

implement
labp1at_node_encode
  (v) =
(
case+ v of
| ~LABP1ATomit() => labp1at_node_LABP1ATomit()
| ~LABP1ATnorm(a0, a1) => labp1at_node_LABP1ATnorm(a0, a1)
) (* end of [labp1at_node_encode] *)

implement
labp1at_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0)))

implement
labp1at_node_is_LABP1ATomit
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
labp1at_node_is_LABP1ATnorm
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
labp1at_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 0)))
//
in
//
case+ tag of
| 0 => LABP1ATomit()
| _ => LABP1ATnorm($UN.cast{l0ab} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{p1at} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
//
end // end of [labp1at_node_view]

implement
labp1at_node_view_free
  (v) =
(
case+ v of
| ~LABP1ATomit() => ()
| ~LABP1ATnorm(_, _) => ()
) (* end of [labp1at_node_view_free] *)

(* ****** ****** *)

implement
p1at_new
  (a0, a1) = let
val p = pats_dynexp1_alloc (16)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{p1at} (p)
end // end of [p1at_new]

implement
p1at_loc
  (x) = $UN.cast{loc_t} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0)))

implement
p1at_node
  (x) = $UN.cast{p1at_node} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
labp1at_new
  (a0, a1) = let
val p = pats_dynexp1_alloc (16)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{labp1at} (p)
end // end of [labp1at_new]

implement
labp1at_loc
  (x) = $UN.cast{loc_t} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0)))

implement
labp1at_node
  (x) = $UN.cast{labp1at_node} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
i1nvarg_new
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (24)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{i1nvarg} (p)
end // end of [i1nvarg_new]

implement
i1nvarg_loc
  (x) = $UN.cast{loc_t} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0)))

implement
i1nvarg_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 8)))

implement
i1nvarg_type
  (x) = $UN.cast{s1expopt} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
i1nvresstate_new
  (a0, a1) = let
val p = pats_dynexp1_alloc (16)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{i1nvresstate} (p)
end // end of [i1nvresstate_new]

implement
i1nvresstate_qua
  (x) = $UN.cast{s1qualst} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0)))

implement
i1nvresstate_arg
  (x) = $UN.cast{i1nvarglst} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
loopi1nv_new
  (a0, a1, a2, a3, a4) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_dynexp1_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a4)))
in
  $UN.cast{loopi1nv} (p)
end // end of [loopi1nv_new]

implement
loopi1nv_loc
  (x) = $UN.cast{loc_t} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0)))

implement
loopi1nv_qua
  (x) = $UN.cast{s1qualst} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 8)))

implement
loopi1nv_met
  (x) = $UN.cast{s1explstopt} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 16)))

implement
loopi1nv_arg
  (x) = $UN.cast{i1nvarglst} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 24)))

implement
loopi1nv_res
  (x) = $UN.cast{i1nvresstate} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 32)))

(* ****** ****** *)

implement
d1ecl_node_D1Cnone
  () = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Cnone]

implement
d1ecl_node_D1Clist
  (a0) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Clist]

implement
d1ecl_node_D1Cpackname
  (a0) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Cpackname]

implement
d1ecl_node_D1Csymintr
  (a0) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (3)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Csymintr]

implement
d1ecl_node_D1Csymelim
  (a0) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (4)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Csymelim]

implement
d1ecl_node_D1Coverload
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (5)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Coverload]

implement
d1ecl_node_D1Ce1xpdef
  (a0, a1) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (6)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Ce1xpdef]

implement
d1ecl_node_D1Ce1xpundef
  (a0, a1) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (7)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Ce1xpundef]

implement
d1ecl_node_D1Cpragma
  (a0) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (8)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Cpragma]

implement
d1ecl_node_D1Ccodegen
  (a0, a1) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (9)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Ccodegen]

implement
d1ecl_node_D1Cdatsrts
  (a0) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (10)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Cdatsrts]

implement
d1ecl_node_D1Csrtdefs
  (a0) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (11)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Csrtdefs]

implement
d1ecl_node_D1Cstacsts
  (a0) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (12)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Cstacsts]

implement
d1ecl_node_D1Cstacons
  (a0, a1) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (13)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Cstacons]

implement
d1ecl_node_D1Ctkindef
  (a0) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (14)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Ctkindef]

implement
d1ecl_node_D1Csexpdefs
  (a0, a1) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (15)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Csexpdefs]

implement
d1ecl_node_D1Csaspdec
  (a0) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (16)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Csaspdec]

implement
d1ecl_node_D1Creassume
  (a0) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (17)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Creassume]

implement
d1ecl_node_D1Cexndecs
  (a0) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (18)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Cexndecs]

implement
d1ecl_node_D1Cdatdecs
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (19)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Cdatdecs]

implement
d1ecl_node_D1Cclassdec
  (a0, a1) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (20)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Cclassdec]

implement
d1ecl_node_D1Cextype
  (a0, a1) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (21)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Cextype]

implement
d1ecl_node_D1Cextype2
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (22)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Cextype2]

implement
d1ecl_node_D1Cextvar
  (a0, a1) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (23)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Cextvar]

implement
d1ecl_node_D1Cextcode
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (24)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Cextcode]

implement
d1ecl_node_D1Cdcstdecs
  (a0, a1, a2, a3) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (25)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_dynexp1_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Cdcstdecs]

implement
d1ecl_node_D1Cmacdefs
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (26)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Cmacdefs]

implement
d1ecl_node_D1Cimpdec
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (27)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Cimpdec]

implement
d1ecl_node_D1Cfundecs
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (28)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Cfundecs]

implement
d1ecl_node_D1Cvaldecs
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (29)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Cvaldecs]

implement
d1ecl_node_D1Cvardecs
  (a0, a1) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (30)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Cvardecs]

implement
d1ecl_node_D1Cinclude
  (a0, a1) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (31)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Cinclude]

implement
d1ecl_node_D1Cstaload
  (a0, a1, a2, a3) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (32)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_dynexp1_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Cstaload]

implement
d1ecl_node_D1Cstaloadnm
  (a0, a1) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (33)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Cstaloadnm]

implement
d1ecl_node_D1Cstaloadloc
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (34)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Cstaloadloc]

implement
d1ecl_node_D1Cdynload
  (a0) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (35)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Cdynload]

implement
d1ecl_node_D1Clocal
  (a0, a1) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (36)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1ecl_node} (p)
end // end of [d1ecl_node_D1Clocal]

implement
d1ecl_node_encode
  (v) =
(
case+ v of
| ~D1Cnone() => d1ecl_node_D1Cnone()
| ~D1Clist(a0) => d1ecl_node_D1Clist(a0)
| ~D1Cpackname(a0) => d1ecl_node_D1Cpackname(a0)
| ~D1Csymintr(a0) => d1ecl_node_D1Csymintr(a0)
| ~D1Csymelim(a0) => d1ecl_node_D1Csymelim(a0)
| ~D1Coverload(a0, a1, a2) => d1ecl_node_D1Coverload(a0, a1, a2)
| ~D1Ce1xpdef(a0, a1) => d1ecl_node_D1Ce1xpdef(a0, a1)
| ~D1Ce1xpundef(a0, a1) => d1ecl_node_D1Ce1xpundef(a0, a1)
| ~D1Cpragma(a0) => d1ecl_node_D1Cpragma(a0)
| ~D1Ccodegen(a0, a1) => d1ecl_node_D1Ccodegen(a0, a1)
| ~D1Cdatsrts(a0) => d1ecl_node_D1Cdatsrts(a0)
| ~D1Csrtdefs(a0) => d1ecl_node_D1Csrtdefs(a0)
| ~D1Cstacsts(a0) => d1ecl_node_D1Cstacsts(a0)
| ~D1Cstacons(a0, a1) => d1ecl_node_D1Cstacons(a0, a1)
| ~D1Ctkindef(a0) => d1ecl_node_D1Ctkindef(a0)
| ~D1Csexpdefs(a0, a1) => d1ecl_node_D1Csexpdefs(a0, a1)
| ~D1Csaspdec(a0) => d1ecl_node_D1Csaspdec(a0)
| ~D1Creassume(a0) => d1ecl_node_D1Creassume(a0)
| ~D1Cexndecs(a0) => d1ecl_node_D1Cexndecs(a0)
| ~D1Cdatdecs(a0, a1, a2) => d1ecl_node_D1Cdatdecs(a0, a1, a2)
| ~D1Cclassdec(a0, a1) => d1ecl_node_D1Cclassdec(a0, a1)
| ~D1Cextype(a0, a1) => d1ecl_node_D1Cextype(a0, a1)
| ~D1Cextype2(a0, a1, a2) => d1ecl_node_D1Cextype2(a0, a1, a2)
| ~D1Cextvar(a0, a1) => d1ecl_node_D1Cextvar(a0, a1)
| ~D1Cextcode(a0, a1, a2) => d1ecl_node_D1Cextcode(a0, a1, a2)
| ~D1Cdcstdecs(a0, a1, a2, a3) => d1ecl_node_D1Cdcstdecs(a0, a1, a2, a3)
| ~D1Cmacdefs(a0, a1, a2) => d1ecl_node_D1Cmacdefs(a0, a1, a2)
| ~D1Cimpdec(a0, a1, a2) => d1ecl_node_D1Cimpdec(a0, a1, a2)
| ~D1Cfundecs(a0, a1, a2) => d1ecl_node_D1Cfundecs(a0, a1, a2)
| ~D1Cvaldecs(a0, a1, a2) => d1ecl_node_D1Cvaldecs(a0, a1, a2)
| ~D1Cvardecs(a0, a1) => d1ecl_node_D1Cvardecs(a0, a1)
| ~D1Cinclude(a0, a1) => d1ecl_node_D1Cinclude(a0, a1)
| ~D1Cstaload(a0, a1, a2, a3) => d1ecl_node_D1Cstaload(a0, a1, a2, a3)
| ~D1Cstaloadnm(a0, a1) => d1ecl_node_D1Cstaloadnm(a0, a1)
| ~D1Cstaloadloc(a0, a1, a2) => d1ecl_node_D1Cstaloadloc(a0, a1, a2)
| ~D1Cdynload(a0) => d1ecl_node_D1Cdynload(a0)
| ~D1Clocal(a0, a1) => d1ecl_node_D1Clocal(a0, a1)
) (* end of [d1ecl_node_encode] *)

implement
d1ecl_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0)))

implement
d1ecl_node_is_D1Cnone
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
d1ecl_node_is_D1Clist
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
d1ecl_node_is_D1Cpackname
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
d1ecl_node_is_D1Csymintr
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 3)

implement
d1ecl_node_is_D1Csymelim
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 4)

implement
d1ecl_node_is_D1Coverload
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 5)

implement
d1ecl_node_is_D1Ce1xpdef
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 6)

implement
d1ecl_node_is_D1Ce1xpundef
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 7)

implement
d1ecl_node_is_D1Cpragma
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 8)

implement
d1ecl_node_is_D1Ccodegen
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 9)

implement
d1ecl_node_is_D1Cdatsrts
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 10)

implement
d1ecl_node_is_D1Csrtdefs
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 11)

implement
d1ecl_node_is_D1Cstacsts
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 12)

implement
d1ecl_node_is_D1Cstacons
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 13)

implement
d1ecl_node_is_D1Ctkindef
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 14)

implement
d1ecl_node_is_D1Csexpdefs
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 15)

implement
d1ecl_node_is_D1Csaspdec
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 16)

implement
d1ecl_node_is_D1Creassume
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 17)

implement
d1ecl_node_is_D1Cexndecs
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 18)

implement
d1ecl_node_is_D1Cdatdecs
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 19)

implement
d1ecl_node_is_D1Cclassdec
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 20)

implement
d1ecl_node_is_D1Cextype
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 21)

implement
d1ecl_node_is_D1Cextype2
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 22)

implement
d1ecl_node_is_D1Cextvar
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 23)

implement
d1ecl_node_is_D1Cextcode
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 24)

implement
d1ecl_node_is_D1Cdcstdecs
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 25)

implement
d1ecl_node_is_D1Cmacdefs
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 26)

implement
d1ecl_node_is_D1Cimpdec
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 27)

implement
d1ecl_node_is_D1Cfundecs
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 28)

implement
d1ecl_node_is_D1Cvaldecs
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 29)

implement
d1ecl_node_is_D1Cvardecs
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 30)

implement
d1ecl_node_is_D1Cinclude
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 31)

implement
d1ecl_node_is_D1Cstaload
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 32)

implement
d1ecl_node_is_D1Cstaloadnm
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 33)

implement
d1ecl_node_is_D1Cstaloadloc
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 34)

implement
d1ecl_node_is_D1Cdynload
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 35)

implement
d1ecl_node_is_D1Clocal
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 36)

implement
d1ecl_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 0)))
//
in
//
case+ tag of
| 0 => D1Cnone()
| 1 => D1Clist($UN.cast{d1eclist} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 2 => D1Cpackname($UN.cast{Stropt} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 3 => D1Csymintr($UN.cast{i0delst} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 4 => D1Csymelim($UN.cast{i0delst} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 5 => D1Coverload($UN.cast{i0de} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{dqi0de} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))))
| 6 => D1Ce1xpdef($UN.cast{symbol} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{e1xp} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 7 => D1Ce1xpundef($UN.cast{symbol} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{e1xp} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 8 => D1Cpragma($UN.cast{e1xplst} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 9 => D1Ccodegen($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{e1xplst} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 10 => D1Cdatsrts($UN.cast{d1atsrtdeclst} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 11 => D1Csrtdefs($UN.cast{s1rtdeflst} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 12 => D1Cstacsts($UN.cast{s1tacstlst} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 13 => D1Cstacons($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{s1taconlst} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 14 => D1Ctkindef($UN.cast{t1kindef} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 15 => D1Csexpdefs($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{s1expdeflst} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 16 => D1Csaspdec($UN.cast{s1aspdec} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 17 => D1Creassume($UN.cast{sqi0de} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 18 => D1Cexndecs($UN.cast{e1xndeclst} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 19 => D1Cdatdecs($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{d1atdeclst} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{s1expdeflst} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))))
| 20 => D1Cclassdec($UN.cast{i0de} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{s1expopt} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 21 => D1Cextype($UN.cast{string} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{s1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 22 => D1Cextype2($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{string} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{s1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))))
| 23 => D1Cextvar($UN.cast{string} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 24 => D1Cextcode($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{string} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))))
| 25 => D1Cdcstdecs($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{dcstkind} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{q1marglst} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))), $UN.cast{d1cstdeclst} ($UN.cast{lint} (pats_dynexp1_ld (p, 32))))
| 26 => D1Cmacdefs($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{bool} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{m1acdeflst} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))))
| 27 => D1Cimpdec($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{i1mparg} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{i1mpdec} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))))
| 28 => D1Cfundecs($UN.cast{funkind} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{q1marglst} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{f1undeclst} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))))
| 29 => D1Cvaldecs($UN.cast{valkind} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{bool} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{v1aldeclst} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))))
| 30 => D1Cvardecs($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{v1ardeclst} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 31 => D1Cinclude($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{d1eclist} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 32 => D1Cstaload($UN.cast{symbolopt} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{filename} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))), $UN.cast{d1eclist} ($UN.cast{lint} (pats_dynexp1_ld (p, 32))))
| 33 => D1Cstaloadnm($UN.cast{symbolopt} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{symbol} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 34 => D1Cstaloadloc($UN.cast{filename} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{symbol} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{d1eclist} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))))
| 35 => D1Cdynload($UN.cast{filename} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| _ => D1Clocal($UN.cast{d1eclist} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{d1eclist} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
//
end // end of [d1ecl_node_view]

implement
d1ecl_node_view_free
  (v) =
(
case+ v of
| ~D1Cnone() => ()
| ~D1Clist(_) => ()
| ~D1Cpackname(_) => ()
| ~D1Csymintr(_) => ()
| ~D1Csymelim(_) => ()
| ~D1Coverload(_, _, _) => ()
| ~D1Ce1xpdef(_, _) => ()
| ~D1Ce1xpundef(_, _) => ()
| ~D1Cpragma(_) => ()
| ~D1Ccodegen(_, _) => ()
| ~D1Cdatsrts(_) => ()
| ~D1Csrtdefs(_) => ()
| ~D1Cstacsts(_) => ()
| ~D1Cstacons(_, _) => ()
| ~D1Ctkindef(_) => ()
| ~D1Csexpdefs(_, _) => ()
| ~D1Csaspdec(_) => ()
| ~D1Creassume(_) => ()
| ~D1Cexndecs(_) => ()
| ~D1Cdatdecs(_, _, _) => ()
| ~D1Cclassdec(_, _) => ()
| ~D1Cextype(_, _) => ()
| ~D1Cextype2(_, _, _) => ()
| ~D1Cextvar(_, _) => ()
| ~D1Cextcode(_, _, _) => ()
| ~D1Cdcstdecs(_, _, _, _) => ()
| ~D1Cmacdefs(_, _, _) => ()
| ~D1Cimpdec(_, _, _) => ()
| ~D1Cfundecs(_, _, _) => ()
| ~D1Cvaldecs(_, _, _) => ()
| ~D1Cvardecs(_, _) => ()
| ~D1Cinclude(_, _) => ()
| ~D1Cstaload(_, _, _, _) => ()
| ~D1Cstaloadnm(_, _) => ()
| ~D1Cstaloadloc(_, _, _) => ()
| ~D1Cdynload(_) => ()
| ~D1Clocal(_, _) => ()
) (* end of [d1ecl_node_view_free] *)

(* ****** ****** *)

implement
d1exp_node_D1Eide
  (a0) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Eide]

implement
d1exp_node_D1Edqid
  (a0, a1) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Edqid]

implement
d1exp_node_D1Eidextapp
  (a0, a1) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Eidextapp]

implement
d1exp_node_D1Eint
  (a0) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (3)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Eint]

implement
d1exp_node_D1Eintrep
  (a0) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (4)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Eintrep]

implement
d1exp_node_D1Ebool
  (a0) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (5)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Ebool]

implement
d1exp_node_D1Echar
  (a0) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (6)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Echar]

implement
d1exp_node_D1Efloat
  (a0) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (7)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Efloat]

implement
d1exp_node_D1Estring
  (a0) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (8)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Estring]

implement
d1exp_node_D1Ei0nt
  (a0) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (9)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Ei0nt]

implement
d1exp_node_D1Ec0har
  (a0) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (10)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Ec0har]

implement
d1exp_node_D1Ef0loat
  (a0) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (11)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Ef0loat]

implement
d1exp_node_D1Es0tring
  (a0) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (12)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Es0tring]

implement
d1exp_node_D1Etop
  () = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (13)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Etop]

implement
d1exp_node_D1Eempty
  () = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (14)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Eempty]

implement
d1exp_node_D1Ecstsp
  (a0) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (15)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Ecstsp]

implement
d1exp_node_D1Etyrep
  (a0) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (16)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Etyrep]

implement
d1exp_node_D1Eliteral
  (a0) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (17)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Eliteral]

implement
d1exp_node_D1Eextval
  (a0, a1) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (18)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Eextval]

implement
d1exp_node_D1Eextfcall
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (19)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Eextfcall]

implement
d1exp_node_D1Eextmcall
  (a0, a1, a2, a3) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (20)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_dynexp1_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Eextmcall]

implement
d1exp_node_D1Efoldat
  (a0, a1) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (21)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Efoldat]

implement
d1exp_node_D1Efreeat
  (a0, a1) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (22)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Efreeat]

implement
d1exp_node_D1Etmpid
  (a0, a1) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (23)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Etmpid]

implement
d1exp_node_D1Elet
  (a0, a1) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (24)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Elet]

implement
d1exp_node_D1Ewhere
  (a0, a1) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (25)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Ewhere]

implement
d1exp_node_D1Edecseq
  (a0) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (26)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Edecseq]

implement
d1exp_node_D1Eapp_dyn
  (a0, a1, a2, a3) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (27)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_dynexp1_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Eapp_dyn]

implement
d1exp_node_D1Eapp_sta
  (a0, a1) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (28)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Eapp_sta]

implement
d1exp_node_D1Esing
  (a0) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (29)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Esing]

implement
d1exp_node_D1Elist
  (a0, a1) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (30)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Elist]

implement
d1exp_node_D1Eifhead
  (a0, a1, a2, a3) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (31)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_dynexp1_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Eifhead]

implement
d1exp_node_D1Esifhead
  (a0, a1, a2, a3) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (32)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_dynexp1_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Esifhead]

implement
d1exp_node_D1Eifcasehd
  (a0, a1) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (33)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Eifcasehd]

implement
d1exp_node_D1Ecasehead
  (a0, a1, a2, a3) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (34)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_dynexp1_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Ecasehead]

implement
d1exp_node_D1Escasehead
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (35)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Escasehead]

implement
d1exp_node_D1Elst
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (36)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Elst]

implement
d1exp_node_D1Etup
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (37)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Etup]

implement
d1exp_node_D1Erec
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (38)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Erec]

implement
d1exp_node_D1Eseq
  (a0) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (39)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Eseq]

implement
d1exp_node_D1Earrsub
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (40)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Earrsub]

implement
d1exp_node_D1Earrinit
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (41)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Earrinit]

implement
d1exp_node_D1Earrpsz
  (a0, a1) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (42)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Earrpsz]

implement
d1exp_node_D1Eptrof
  (a0) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (43)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Eptrof]

implement
d1exp_node_D1Eviewat
  (a0) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (44)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Eviewat]

implement
d1exp_node_D1Eselab
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (45)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Eselab]

implement
d1exp_node_D1Eraise
  (a0) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (46)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Eraise]

implement
d1exp_node_D1Eeffmask
  (a0, a1) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (47)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Eeffmask]

implement
d1exp_node_D1Evararg
  (a0) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (48)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Evararg]

implement
d1exp_node_D1Evcopyenv
  (a0, a1) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (49)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Evcopyenv]

implement
d1exp_node_D1Eshowtype
  (a0) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (50)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Eshowtype]

implement
d1exp_node_D1Etempenver
  (a0) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (51)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Etempenver]

implement
d1exp_node_D1Esexparg
  (a0) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (52)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Esexparg]

implement
d1exp_node_D1Eexist
  (a0, a1) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (53)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Eexist]

implement
d1exp_node_D1Elam_dyn
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (54)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Elam_dyn]

implement
d1exp_node_D1Elaminit_dyn
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (55)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Elaminit_dyn]

implement
d1exp_node_D1Elam_met
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (56)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Elam_met]

implement
d1exp_node_D1Elam_sta_ana
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (57)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Elam_sta_ana]

implement
d1exp_node_D1Elam_sta_syn
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (58)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Elam_sta_syn]

implement
d1exp_node_D1Efix
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (59)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Efix]

implement
d1exp_node_D1Edelay
  (a0, a1) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (60)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Edelay]

implement
d1exp_node_D1Efor
  (a0, a1, a2, a3, a4) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (61)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_dynexp1_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_dynexp1_st (p, 40, $UN.cast{ptr} ($UN.cast{lint} (a4)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Efor]

implement
d1exp_node_D1Ewhile
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (62)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Ewhile]

implement
d1exp_node_D1Eloopexn
  (a0) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (63)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Eloopexn]

implement
d1exp_node_D1Etrywith
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (64)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Etrywith]

implement
d1exp_node_D1Eann_type
  (a0, a1) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (65)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Eann_type]

implement
d1exp_node_D1Eann_effc
  (a0, a1) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (66)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Eann_effc]

implement
d1exp_node_D1Eann_funclo
  (a0, a1) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (67)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Eann_funclo]

implement
d1exp_node_D1Emacsyn
  (a0, a1) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (68)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Emacsyn]

implement
d1exp_node_D1Emacfun
  (a0, a1) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (69)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Emacfun]

implement
d1exp_node_D1Esolassert
  (a0) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (70)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Esolassert]

implement
d1exp_node_D1Esolverify
  (a0) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (71)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Esolverify]

implement
d1exp_node_D1Eerrexp
  () = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (72)))
in
  $UN.cast{d1exp_node} (p)
end // end of [d1exp_node_D1Eerrexp]

implement
d1exp_node_encode
  (v) =
(
case+ v of
| ~D1Eide(a0) => d1exp_node_D1Eide(a0)
| ~D1Edqid(a0, a1) => d1exp_node_D1Edqid(a0, a1)
| ~D1Eidextapp(a0, a1) => d1exp_node_D1Eidextapp(a0, a1)
| ~D1Eint(a0) => d1exp_node_D1Eint(a0)
| ~D1Eintrep(a0) => d1exp_node_D1Eintrep(a0)
| ~D1Ebool(a0) => d1exp_node_D1Ebool(a0)
| ~D1Echar(a0) => d1exp_node_D1Echar(a0)
| ~D1Efloat(a0) => d1exp_node_D1Efloat(a0)
| ~D1Estring(a0) => d1exp_node_D1Estring(a0)
| ~D1Ei0nt(a0) => d1exp_node_D1Ei0nt(a0)
| ~D1Ec0har(a0) => d1exp_node_D1Ec0har(a0)
| ~D1Ef0loat(a0) => d1exp_node_D1Ef0loat(a0)
| ~D1Es0tring(a0) => d1exp_node_D1Es0tring(a0)
| ~D1Etop() => d1exp_node_D1Etop()
| ~D1Eempty() => d1exp_node_D1Eempty()
| ~D1Ecstsp(a0) => d1exp_node_D1Ecstsp(a0)
| ~D1Etyrep(a0) => d1exp_node_D1Etyrep(a0)
| ~D1Eliteral(a0) => d1exp_node_D1Eliteral(a0)
| ~D1Eextval(a0, a1) => d1exp_node_D1Eextval(a0, a1)
| ~D1Eextfcall(a0, a1, a2) => d1exp_node_D1Eextfcall(a0, a1, a2)
| ~D1Eextmcall(a0, a1, a2, a3) => d1exp_node_D1Eextmcall(a0, a1, a2, a3)
| ~D1Efoldat(a0, a1) => d1exp_node_D1Efoldat(a0, a1)
| ~D1Efreeat(a0, a1) => d1exp_node_D1Efreeat(a0, a1)
| ~D1Etmpid(a0, a1) => d1exp_node_D1Etmpid(a0, a1)
| ~D1Elet(a0, a1) => d1exp_node_D1Elet(a0, a1)
| ~D1Ewhere(a0, a1) => d1exp_node_D1Ewhere(a0, a1)
| ~D1Edecseq(a0) => d1exp_node_D1Edecseq(a0)
| ~D1Eapp_dyn(a0, a1, a2, a3) => d1exp_node_D1Eapp_dyn(a0, a1, a2, a3)
| ~D1Eapp_sta(a0, a1) => d1exp_node_D1Eapp_sta(a0, a1)
| ~D1Esing(a0) => d1exp_node_D1Esing(a0)
| ~D1Elist(a0, a1) => d1exp_node_D1Elist(a0, a1)
| ~D1Eifhead(a0, a1, a2, a3) => d1exp_node_D1Eifhead(a0, a1, a2, a3)
| ~D1Esifhead(a0, a1, a2, a3) => d1exp_node_D1Esifhead(a0, a1, a2, a3)
| ~D1Eifcasehd(a0, a1) => d1exp_node_D1Eifcasehd(a0, a1)
| ~D1Ecasehead(a0, a1, a2, a3) => d1exp_node_D1Ecasehead(a0, a1, a2, a3)
| ~D1Escasehead(a0, a1, a2) => d1exp_node_D1Escasehead(a0, a1, a2)
| ~D1Elst(a0, a1, a2) => d1exp_node_D1Elst(a0, a1, a2)
| ~D1Etup(a0, a1, a2) => d1exp_node_D1Etup(a0, a1, a2)
| ~D1Erec(a0, a1, a2) => d1exp_node_D1Erec(a0, a1, a2)
| ~D1Eseq(a0) => d1exp_node_D1Eseq(a0)
| ~D1Earrsub(a0, a1, a2) => d1exp_node_D1Earrsub(a0, a1, a2)
| ~D1Earrinit(a0, a1, a2) => d1exp_node_D1Earrinit(a0, a1, a2)
| ~D1Earrpsz(a0, a1) => d1exp_node_D1Earrpsz(a0, a1)
| ~D1Eptrof(a0) => d1exp_node_D1Eptrof(a0)
| ~D1Eviewat(a0) => d1exp_node_D1Eviewat(a0)
| ~D1Eselab(a0, a1, a2) => d1exp_node_D1Eselab(a0, a1, a2)
| ~D1Eraise(a0) => d1exp_node_D1Eraise(a0)
| ~D1Eeffmask(a0, a1) => d1exp_node_D1Eeffmask(a0, a1)
| ~D1Evararg(a0) => d1exp_node_D1Evararg(a0)
| ~D1Evcopyenv(a0, a1) => d1exp_node_D1Evcopyenv(a0, a1)
| ~D1Eshowtype(a0) => d1exp_node_D1Eshowtype(a0)
| ~D1Etempenver(a0) => d1exp_node_D1Etempenver(a0)
| ~D1Esexparg(a0) => d1exp_node_D1Esexparg(a0)
| ~D1Eexist(a0, a1) => d1exp_node_D1Eexist(a0, a1)
| ~D1Elam_dyn(a0, a1, a2) => d1exp_node_D1Elam_dyn(a0, a1, a2)
| ~D1Elaminit_dyn(a0, a1, a2) => d1exp_node_D1Elaminit_dyn(a0, a1, a2)
| ~D1Elam_met(a0, a1, a2) => d1exp_node_D1Elam_met(a0, a1, a2)
| ~D1Elam_sta_ana(a0, a1, a2) => d1exp_node_D1Elam_sta_ana(a0, a1, a2)
| ~D1Elam_sta_syn(a0, a1, a2) => d1exp_node_D1Elam_sta_syn(a0, a1, a2)
| ~D1Efix(a0, a1, a2) => d1exp_node_D1Efix(a0, a1, a2)
| ~D1Edelay(a0, a1) => d1exp_node_D1Edelay(a0, a1)
| ~D1Efor(a0, a1, a2, a3, a4) => d1exp_node_D1Efor(a0, a1, a2, a3, a4)
| ~D1Ewhile(a0, a1, a2) => d1exp_node_D1Ewhile(a0, a1, a2)
| ~D1Eloopexn(a0) => d1exp_node_D1Eloopexn(a0)
| ~D1Etrywith(a0, a1, a2) => d1exp_node_D1Etrywith(a0, a1, a2)
| ~D1Eann_type(a0, a1) => d1exp_node_D1Eann_type(a0, a1)
| ~D1Eann_effc(a0, a1) => d1exp_node_D1Eann_effc(a0, a1)
| ~D1Eann_funclo(a0, a1) => d1exp_node_D1Eann_funclo(a0, a1)
| ~D1Emacsyn(a0, a1) => d1exp_node_D1Emacsyn(a0, a1)
| ~D1Emacfun(a0, a1) => d1exp_node_D1Emacfun(a0, a1)
| ~D1Esolassert(a0) => d1exp_node_D1Esolassert(a0)
| ~D1Esolverify(a0) => d1exp_node_D1Esolverify(a0)
| ~D1Eerrexp() => d1exp_node_D1Eerrexp()
) (* end of [d1exp_node_encode] *)

implement
d1exp_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0)))

implement
d1exp_node_is_D1Eide
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
d1exp_node_is_D1Edqid
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
d1exp_node_is_D1Eidextapp
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
d1exp_node_is_D1Eint
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 3)

implement
d1exp_node_is_D1Eintrep
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 4)

implement
d1exp_node_is_D1Ebool
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 5)

implement
d1exp_node_is_D1Echar
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 6)

implement
d1exp_node_is_D1Efloat
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 7)

implement
d1exp_node_is_D1Estring
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 8)

implement
d1exp_node_is_D1Ei0nt
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 9)

implement
d1exp_node_is_D1Ec0har
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 10)

implement
d1exp_node_is_D1Ef0loat
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 11)

implement
d1exp_node_is_D1Es0tring
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 12)

implement
d1exp_node_is_D1Etop
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 13)

implement
d1exp_node_is_D1Eempty
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 14)

implement
d1exp_node_is_D1Ecstsp
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 15)

implement
d1exp_node_is_D1Etyrep
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 16)

implement
d1exp_node_is_D1Eliteral
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 17)

implement
d1exp_node_is_D1Eextval
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 18)

implement
d1exp_node_is_D1Eextfcall
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 19)

implement
d1exp_node_is_D1Eextmcall
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 20)

implement
d1exp_node_is_D1Efoldat
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 21)

implement
d1exp_node_is_D1Efreeat
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 22)

implement
d1exp_node_is_D1Etmpid
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 23)

implement
d1exp_node_is_D1Elet
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 24)

implement
d1exp_node_is_D1Ewhere
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 25)

implement
d1exp_node_is_D1Edecseq
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 26)

implement
d1exp_node_is_D1Eapp_dyn
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 27)

implement
d1exp_node_is_D1Eapp_sta
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 28)

implement
d1exp_node_is_D1Esing
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 29)

implement
d1exp_node_is_D1Elist
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 30)

implement
d1exp_node_is_D1Eifhead
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 31)

implement
d1exp_node_is_D1Esifhead
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 32)

implement
d1exp_node_is_D1Eifcasehd
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 33)

implement
d1exp_node_is_D1Ecasehead
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 34)

implement
d1exp_node_is_D1Escasehead
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 35)

implement
d1exp_node_is_D1Elst
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 36)

implement
d1exp_node_is_D1Etup
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 37)

implement
d1exp_node_is_D1Erec
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 38)

implement
d1exp_node_is_D1Eseq
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 39)

implement
d1exp_node_is_D1Earrsub
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 40)

implement
d1exp_node_is_D1Earrinit
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 41)

implement
d1exp_node_is_D1Earrpsz
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 42)

implement
d1exp_node_is_D1Eptrof
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 43)

implement
d1exp_node_is_D1Eviewat
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 44)

implement
d1exp_node_is_D1Eselab
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 45)

implement
d1exp_node_is_D1Eraise
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 46)

implement
d1exp_node_is_D1Eeffmask
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 47)

implement
d1exp_node_is_D1Evararg
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 48)

implement
d1exp_node_is_D1Evcopyenv
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 49)

implement
d1exp_node_is_D1Eshowtype
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 50)

implement
d1exp_node_is_D1Etempenver
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 51)

implement
d1exp_node_is_D1Esexparg
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 52)

implement
d1exp_node_is_D1Eexist
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 53)

implement
d1exp_node_is_D1Elam_dyn
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 54)

implement
d1exp_node_is_D1Elaminit_dyn
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 55)

implement
d1exp_node_is_D1Elam_met
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 56)

implement
d1exp_node_is_D1Elam_sta_ana
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 57)

implement
d1exp_node_is_D1Elam_sta_syn
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 58)

implement
d1exp_node_is_D1Efix
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 59)

implement
d1exp_node_is_D1Edelay
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 60)

implement
d1exp_node_is_D1Efor
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 61)

implement
d1exp_node_is_D1Ewhile
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 62)

implement
d1exp_node_is_D1Eloopexn
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 63)

implement
d1exp_node_is_D1Etrywith
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 64)

implement
d1exp_node_is_D1Eann_type
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 65)

implement
d1exp_node_is_D1Eann_effc
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 66)

implement
d1exp_node_is_D1Eann_funclo
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 67)

implement
d1exp_node_is_D1Emacsyn
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 68)

implement
d1exp_node_is_D1Emacfun
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 69)

implement
d1exp_node_is_D1Esolassert
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 70)

implement
d1exp_node_is_D1Esolverify
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 71)

implement
d1exp_node_is_D1Eerrexp
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 72)

implement
d1exp_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 0)))
//
in
//
case+ tag of
| 0 => D1Eide($UN.cast{symbol} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 1 => D1Edqid($UN.cast{d0ynq} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{symbol} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 2 => D1Eidextapp($UN.cast{symbol} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{d1explst} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 3 => D1Eint($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 4 => D1Eintrep($UN.cast{string} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 5 => D1Ebool($UN.cast{bool} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 6 => D1Echar($UN.cast{char} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 7 => D1Efloat($UN.cast{string} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 8 => D1Estring($UN.cast{string} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 9 => D1Ei0nt($UN.cast{i0nt} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 10 => D1Ec0har($UN.cast{c0har} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 11 => D1Ef0loat($UN.cast{f0loat} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 12 => D1Es0tring($UN.cast{s0tring} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 13 => D1Etop()
| 14 => D1Eempty()
| 15 => D1Ecstsp($UN.cast{cstsp} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 16 => D1Etyrep($UN.cast{s1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 17 => D1Eliteral($UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 18 => D1Eextval($UN.cast{s1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{string} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 19 => D1Eextfcall($UN.cast{s1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{string} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{d1explst} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))))
| 20 => D1Eextmcall($UN.cast{s1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{string} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))), $UN.cast{d1explst} ($UN.cast{lint} (pats_dynexp1_ld (p, 32))))
| 21 => D1Efoldat($UN.cast{s1exparglst} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 22 => D1Efreeat($UN.cast{s1exparglst} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 23 => D1Etmpid($UN.cast{dqi0de} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{t1mpmarglst} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 24 => D1Elet($UN.cast{d1eclist} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 25 => D1Ewhere($UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{d1eclist} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 26 => D1Edecseq($UN.cast{d1eclist} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 27 => D1Eapp_dyn($UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{loc_t} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))), $UN.cast{d1explst} ($UN.cast{lint} (pats_dynexp1_ld (p, 32))))
| 28 => D1Eapp_sta($UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{s1exparglst} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 29 => D1Esing($UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 30 => D1Elist($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{d1explst} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 31 => D1Eifhead($UN.cast{i1nvresstate} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))), $UN.cast{d1expopt} ($UN.cast{lint} (pats_dynexp1_ld (p, 32))))
| 32 => D1Esifhead($UN.cast{i1nvresstate} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{s1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))), $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 32))))
| 33 => D1Eifcasehd($UN.cast{i1nvresstate} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{i1fclist} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 34 => D1Ecasehead($UN.cast{caskind} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{i1nvresstate} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{d1explst} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))), $UN.cast{c1laulst} ($UN.cast{lint} (pats_dynexp1_ld (p, 32))))
| 35 => D1Escasehead($UN.cast{i1nvresstate} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{s1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{sc1laulst} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))))
| 36 => D1Elst($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{s1expopt} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{d1explst} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))))
| 37 => D1Etup($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{d1explst} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))))
| 38 => D1Erec($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{labd1explst} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))))
| 39 => D1Eseq($UN.cast{d1explst} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 40 => D1Earrsub($UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{loc_t} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{d1explst} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))))
| 41 => D1Earrinit($UN.cast{s1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{d1expopt} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{d1explst} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))))
| 42 => D1Earrpsz($UN.cast{s1expopt} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{d1explst} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 43 => D1Eptrof($UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 44 => D1Eviewat($UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 45 => D1Eselab($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{d1lab} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))))
| 46 => D1Eraise($UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 47 => D1Eeffmask($UN.cast{effcst} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 48 => D1Evararg($UN.cast{d1explst} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 49 => D1Evcopyenv($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 50 => D1Eshowtype($UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 51 => D1Etempenver($UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 52 => D1Esexparg($UN.cast{s1exparg} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 53 => D1Eexist($UN.cast{s1exparg} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 54 => D1Elam_dyn($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{p1at} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))))
| 55 => D1Elaminit_dyn($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{p1at} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))))
| 56 => D1Elam_met($UN.cast{loc_t} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{s1explst} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))))
| 57 => D1Elam_sta_ana($UN.cast{loc_t} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{s1vararg} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))))
| 58 => D1Elam_sta_syn($UN.cast{loc_t} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{s1qualst} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))))
| 59 => D1Efix($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{i0de} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))))
| 60 => D1Edelay($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 61 => D1Efor($UN.cast{loopi1nv} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))), $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 32))), $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 40))))
| 62 => D1Ewhile($UN.cast{loopi1nv} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))))
| 63 => D1Eloopexn($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 64 => D1Etrywith($UN.cast{i1nvresstate} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))), $UN.cast{c1laulst} ($UN.cast{lint} (pats_dynexp1_ld (p, 24))))
| 65 => D1Eann_type($UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{s1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 66 => D1Eann_effc($UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{effcst} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 67 => D1Eann_funclo($UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{funclo} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 68 => D1Emacsyn($UN.cast{macsynkind} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 69 => D1Emacfun($UN.cast{symbol} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))), $UN.cast{d1explst} ($UN.cast{lint} (pats_dynexp1_ld (p, 16))))
| 70 => D1Esolassert($UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| 71 => D1Esolverify($UN.cast{s1exp} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| _ => D1Eerrexp()
//
end // end of [d1exp_node_view]

implement
d1exp_node_view_free
  (v) =
(
case+ v of
| ~D1Eide(_) => ()
| ~D1Edqid(_, _) => ()
| ~D1Eidextapp(_, _) => ()
| ~D1Eint(_) => ()
| ~D1Eintrep(_) => ()
| ~D1Ebool(_) => ()
| ~D1Echar(_) => ()
| ~D1Efloat(_) => ()
| ~D1Estring(_) => ()
| ~D1Ei0nt(_) => ()
| ~D1Ec0har(_) => ()
| ~D1Ef0loat(_) => ()
| ~D1Es0tring(_) => ()
| ~D1Etop() => ()
| ~D1Eempty() => ()
| ~D1Ecstsp(_) => ()
| ~D1Etyrep(_) => ()
| ~D1Eliteral(_) => ()
| ~D1Eextval(_, _) => ()
| ~D1Eextfcall(_, _, _) => ()
| ~D1Eextmcall(_, _, _, _) => ()
| ~D1Efoldat(_, _) => ()
| ~D1Efreeat(_, _) => ()
| ~D1Etmpid(_, _) => ()
| ~D1Elet(_, _) => ()
| ~D1Ewhere(_, _) => ()
| ~D1Edecseq(_) => ()
| ~D1Eapp_dyn(_, _, _, _) => ()
| ~D1Eapp_sta(_, _) => ()
| ~D1Esing(_) => ()
| ~D1Elist(_, _) => ()
| ~D1Eifhead(_, _, _, _) => ()
| ~D1Esifhead(_, _, _, _) => ()
| ~D1Eifcasehd(_, _) => ()
| ~D1Ecasehead(_, _, _, _) => ()
| ~D1Escasehead(_, _, _) => ()
| ~D1Elst(_, _, _) => ()
| ~D1Etup(_, _, _) => ()
| ~D1Erec(_, _, _) => ()
| ~D1Eseq(_) => ()
| ~D1Earrsub(_, _, _) => ()
| ~D1Earrinit(_, _, _) => ()
| ~D1Earrpsz(_, _) => ()
| ~D1Eptrof(_) => ()
| ~D1Eviewat(_) => ()
| ~D1Eselab(_, _, _) => ()
| ~D1Eraise(_) => ()
| ~D1Eeffmask(_, _) => ()
| ~D1Evararg(_) => ()
| ~D1Evcopyenv(_, _) => ()
| ~D1Eshowtype(_) => ()
| ~D1Etempenver(_) => ()
| ~D1Esexparg(_) => ()
| ~D1Eexist(_, _) => ()
| ~D1Elam_dyn(_, _, _) => ()
| ~D1Elaminit_dyn(_, _, _) => ()
| ~D1Elam_met(_, _, _) => ()
| ~D1Elam_sta_ana(_, _, _) => ()
| ~D1Elam_sta_syn(_, _, _) => ()
| ~D1Efix(_, _, _) => ()
| ~D1Edelay(_, _) => ()
| ~D1Efor(_, _, _, _, _) => ()
| ~D1Ewhile(_, _, _) => ()
| ~D1Eloopexn(_) => ()
| ~D1Etrywith(_, _, _) => ()
| ~D1Eann_type(_, _) => ()
| ~D1Eann_effc(_, _) => ()
| ~D1Eann_funclo(_, _) => ()
| ~D1Emacsyn(_, _) => ()
| ~D1Emacfun(_, _) => ()
| ~D1Esolassert(_) => ()
| ~D1Esolverify(_) => ()
| ~D1Eerrexp() => ()
) (* end of [d1exp_node_view_free] *)

(* ****** ****** *)

implement
d1lab_node_D1LABlab
  (a0) = let
val p = pats_dynexp1_alloc (16)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1lab_node} (p)
end // end of [d1lab_node_D1LABlab]

implement
d1lab_node_D1LABind
  (a0) = let
val p = pats_dynexp1_alloc (16)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d1lab_node} (p)
end // end of [d1lab_node_D1LABind]

implement
d1lab_node_encode
  (v) =
(
case+ v of
| ~D1LABlab(a0) => d1lab_node_D1LABlab(a0)
| ~D1LABind(a0) => d1lab_node_D1LABind(a0)
) (* end of [d1lab_node_encode] *)

implement
d1lab_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0)))

implement
d1lab_node_is_D1LABlab
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
d1lab_node_is_D1LABind
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
d1lab_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld (p, 0)))
//
in
//
case+ tag of
| 0 => D1LABlab($UN.cast{label} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
| _ => D1LABind($UN.cast{d1explst} ($UN.cast{lint} (pats_dynexp1_ld (p, 8))))
//
end // end of [d1lab_node_view]

implement
d1lab_node_view_free
  (v) =
(
case+ v of
| ~D1LABlab(_) => ()
| ~D1LABind(_) => ()
) (* end of [d1lab_node_view_free] *)

(* ****** ****** *)

implement
d1ecl_new
  (a0, a1) = let
val p = pats_dynexp1_alloc (16)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1ecl} (p)
end // end of [d1ecl_new]

implement
d1ecl_loc
  (x) = $UN.cast{loc_t} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0)))

implement
d1ecl_node
  (x) = $UN.cast{d1ecl_node} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
d1exp_new
  (a0, a1) = let
val p = pats_dynexp1_alloc (16)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1exp} (p)
end // end of [d1exp_new]

implement
d1exp_loc
  (x) = $UN.cast{loc_t} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0)))

implement
d1exp_node
  (x) = $UN.cast{d1exp_node} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
labd1exp_new
  (a0, a1) = let
val p = pats_dynexp1_alloc (16)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{labd1exp} (p)
end // end of [labd1exp_new]

implement
labd1exp_lab
  (x) = $UN.cast{l0ab} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0)))

implement
labd1exp_elt
  (x) = $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
d1lab_new
  (a0, a1) = let
val p = pats_dynexp1_alloc (16)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d1lab} (p)
end // end of [d1lab_new]

implement
d1lab_loc
  (x) = $UN.cast{loc_t} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0)))

implement
d1lab_node
  (x) = $UN.cast{d1lab_node} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
i1fcl_new
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (24)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{i1fcl} (p)
end // end of [i1fcl_new]

implement
i1fcl_loc
  (x) = $UN.cast{loc_t} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0)))

implement
i1fcl_test
  (x) = $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 8)))

implement
i1fcl_body
  (x) = $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
gm1at_new
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (24)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{gm1at} (p)
end // end of [gm1at_new]

implement
gm1at_loc
  (x) = $UN.cast{loc_t} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0)))

implement
gm1at_exp
  (x) = $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 8)))

implement
gm1at_pat
  (x) = $UN.cast{p1atopt} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
c1lau_new
  (a0, a1, a2, a3, a4, a5) = let
val p = pats_dynexp1_alloc (48)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_dynexp1_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a4)))
val () = pats_dynexp1_st (p, 40, $UN.cast{ptr} ($UN.cast{lint} (a5)))
in
  $UN.cast{c1lau} (p)
end // end of [c1lau_new]

implement
c1lau_loc
  (x) = $UN.cast{loc_t} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0)))

implement
c1lau_pat
  (x) = $UN.cast{p1at} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 8)))

implement
c1lau_gua
  (x) = $UN.cast{gm1atlst} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 16)))

implement
c1lau_seq
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 24)))

implement
c1lau_neg
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 32)))

implement
c1lau_body
  (x) = $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 40)))

(* ****** ****** *)

implement
sc1lau_new
  (a0, a1, a2) = let
val p = pats_dynexp1_alloc (24)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{sc1lau} (p)
end // end of [sc1lau_new]

implement
sc1lau_loc
  (x) = $UN.cast{loc_t} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0)))

implement
sc1lau_pat
  (x) = $UN.cast{sp1at} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 8)))

implement
sc1lau_body
  (x) = $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
m1acdef_new
  (a0, a1, a2, a3) = let
val p = pats_dynexp1_alloc (32)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{m1acdef} (p)
end // end of [m1acdef_new]

implement
m1acdef_loc
  (x) = $UN.cast{loc_t} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0)))

implement
m1acdef_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 8)))

implement
m1acdef_arg
  (x) = $UN.cast{m1acarglst} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 16)))

implement
m1acdef_def
  (x) = $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 24)))

(* ****** ****** *)

implement
f1undec_new
  (a0, a1, a2, a3, a4) = let
val p = pats_dynexp1_alloc (40)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_dynexp1_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a4)))
in
  $UN.cast{f1undec} (p)
end // end of [f1undec_new]

implement
f1undec_loc
  (x) = $UN.cast{loc_t} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0)))

implement
f1undec_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 8)))

implement
f1undec_sym_loc
  (x) = $UN.cast{loc_t} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 16)))

implement
f1undec_def
  (x) = $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 24)))

implement
f1undec_ann
  (x) = $UN.cast{witht1ype} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 32)))

(* ****** ****** *)

implement
v1aldec_new
  (a0, a1, a2, a3) = let
val p = pats_dynexp1_alloc (32)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{v1aldec} (p)
end // end of [v1aldec_new]

implement
v1aldec_loc
  (x) = $UN.cast{loc_t} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0)))

implement
v1aldec_pat
  (x) = $UN.cast{p1at} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 8)))

implement
v1aldec_def
  (x) = $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 16)))

implement
v1aldec_ann
  (x) = $UN.cast{witht1ype} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 24)))

(* ****** ****** *)

implement
v1ardec_new
  (a0, a1, a2, a3, a4, a5, a6) = let
val p = pats_dynexp1_alloc (56)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_dynexp1_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a4)))
val () = pats_dynexp1_st (p, 40, $UN.cast{ptr} ($UN.cast{lint} (a5)))
val () = pats_dynexp1_st (p, 48, $UN.cast{ptr} ($UN.cast{lint} (a6)))
in
  $UN.cast{v1ardec} (p)
end // end of [v1ardec_new]

implement
v1ardec_loc
  (x) = $UN.cast{loc_t} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0)))

implement
v1ardec_knd
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 8)))

implement
v1ardec_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 16)))

implement
v1ardec_sym_loc
  (x) = $UN.cast{loc_t} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 24)))

implement
v1ardec_pfat
  (x) = $UN.cast{i0deopt} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 32)))

implement
v1ardec_type
  (x) = $UN.cast{s1expopt} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 40)))

implement
v1ardec_init
  (x) = $UN.cast{d1expopt} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 48)))

(* ****** ****** *)

implement
i1mpdec_new
  (a0, a1, a2, a3) = let
val p = pats_dynexp1_alloc (32)
val () = pats_dynexp1_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_dynexp1_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_dynexp1_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_dynexp1_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{i1mpdec} (p)
end // end of [i1mpdec_new]

implement
i1mpdec_loc
  (x) = $UN.cast{loc_t} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 0)))

implement
i1mpdec_qid
  (x) = $UN.cast{impqi0de} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 8)))

implement
i1mpdec_tmparg
  (x) = $UN.cast{t1mpmarglst} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 16)))

implement
i1mpdec_def
  (x) = $UN.cast{d1exp} ($UN.cast{lint} (pats_dynexp1_ld ($UN.cast{ptr} (x), 24)))

(* ****** ****** *)
