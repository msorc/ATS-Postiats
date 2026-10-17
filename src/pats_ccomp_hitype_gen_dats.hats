fn pats_ccomp_hitype_ld (p: ptr, k: int): ptr = $UN.ptr0_get<ptr> (ptr0_add_gint<byte> (p, k))
fn pats_ccomp_hitype_st (p: ptr, k: int, x: ptr): void = $UN.ptr0_set<ptr> (ptr0_add_gint<byte> (p, k), x)
fn pats_ccomp_hitype_alloc (n: int): ptr = the_garena_alloc ($UN.cast{size_t} (n))
//

implement
hit_HITnmd
  (a0) = let
val p = pats_ccomp_hitype_alloc (24)
val () = pats_ccomp_hitype_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_ccomp_hitype_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{hit} (p)
end // end of [hit_HITnmd]

implement
hit_HITapp
  (a0, a1) = let
val p = pats_ccomp_hitype_alloc (24)
val () = pats_ccomp_hitype_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_ccomp_hitype_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_hitype_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{hit} (p)
end // end of [hit_HITapp]

implement
hit_HITtyarr
  (a0, a1) = let
val p = pats_ccomp_hitype_alloc (24)
val () = pats_ccomp_hitype_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_ccomp_hitype_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_hitype_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{hit} (p)
end // end of [hit_HITtyarr]

implement
hit_HITtyrec
  (a0) = let
val p = pats_ccomp_hitype_alloc (24)
val () = pats_ccomp_hitype_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (3)))
val () = pats_ccomp_hitype_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{hit} (p)
end // end of [hit_HITtyrec]

implement
hit_HITtysum
  (a0, a1) = let
val p = pats_ccomp_hitype_alloc (24)
val () = pats_ccomp_hitype_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (4)))
val () = pats_ccomp_hitype_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_hitype_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{hit} (p)
end // end of [hit_HITtysum]

implement
hit_HITtyexn
  (a0) = let
val p = pats_ccomp_hitype_alloc (24)
val () = pats_ccomp_hitype_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (5)))
val () = pats_ccomp_hitype_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{hit} (p)
end // end of [hit_HITtyexn]

implement
hit_HITtyvar
  (a0) = let
val p = pats_ccomp_hitype_alloc (24)
val () = pats_ccomp_hitype_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (6)))
val () = pats_ccomp_hitype_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{hit} (p)
end // end of [hit_HITtyvar]

implement
hit_HITtyclo
  (a0) = let
val p = pats_ccomp_hitype_alloc (24)
val () = pats_ccomp_hitype_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (7)))
val () = pats_ccomp_hitype_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{hit} (p)
end // end of [hit_HITtyclo]

implement
hit_HITvararg
  (a0) = let
val p = pats_ccomp_hitype_alloc (24)
val () = pats_ccomp_hitype_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (8)))
val () = pats_ccomp_hitype_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{hit} (p)
end // end of [hit_HITvararg]

implement
hit_HITrefarg
  (a0, a1) = let
val p = pats_ccomp_hitype_alloc (24)
val () = pats_ccomp_hitype_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (9)))
val () = pats_ccomp_hitype_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_hitype_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{hit} (p)
end // end of [hit_HITrefarg]

implement
hit_HITundef
  (a0, a1) = let
val p = pats_ccomp_hitype_alloc (24)
val () = pats_ccomp_hitype_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (10)))
val () = pats_ccomp_hitype_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_hitype_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{hit} (p)
end // end of [hit_HITundef]

implement
hit_HITerror
  () = let
val p = pats_ccomp_hitype_alloc (24)
val () = pats_ccomp_hitype_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (11)))
in
  $UN.cast{hit} (p)
end // end of [hit_HITerror]

implement
hit_encode
  (v) =
(
case+ v of
| ~HITnmd(a0) => hit_HITnmd(a0)
| ~HITapp(a0, a1) => hit_HITapp(a0, a1)
| ~HITtyarr(a0, a1) => hit_HITtyarr(a0, a1)
| ~HITtyrec(a0) => hit_HITtyrec(a0)
| ~HITtysum(a0, a1) => hit_HITtysum(a0, a1)
| ~HITtyexn(a0) => hit_HITtyexn(a0)
| ~HITtyvar(a0) => hit_HITtyvar(a0)
| ~HITtyclo(a0) => hit_HITtyclo(a0)
| ~HITvararg(a0) => hit_HITvararg(a0)
| ~HITrefarg(a0, a1) => hit_HITrefarg(a0, a1)
| ~HITundef(a0, a1) => hit_HITundef(a0, a1)
| ~HITerror() => hit_HITerror()
) (* end of [hit_encode] *)

implement
hit_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_hitype_ld ($UN.cast{ptr} (x), 0)))

implement
hit_is_HITnmd
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_hitype_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
hit_is_HITapp
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_hitype_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
hit_is_HITtyarr
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_hitype_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
hit_is_HITtyrec
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_hitype_ld ($UN.cast{ptr} (x), 0))) = 3)

implement
hit_is_HITtysum
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_hitype_ld ($UN.cast{ptr} (x), 0))) = 4)

implement
hit_is_HITtyexn
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_hitype_ld ($UN.cast{ptr} (x), 0))) = 5)

implement
hit_is_HITtyvar
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_hitype_ld ($UN.cast{ptr} (x), 0))) = 6)

implement
hit_is_HITtyclo
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_hitype_ld ($UN.cast{ptr} (x), 0))) = 7)

implement
hit_is_HITvararg
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_hitype_ld ($UN.cast{ptr} (x), 0))) = 8)

implement
hit_is_HITrefarg
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_hitype_ld ($UN.cast{ptr} (x), 0))) = 9)

implement
hit_is_HITundef
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_hitype_ld ($UN.cast{ptr} (x), 0))) = 10)

implement
hit_is_HITerror
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_ccomp_hitype_ld ($UN.cast{ptr} (x), 0))) = 11)

implement
hit_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_ccomp_hitype_ld (p, 0)))
//
in
//
case+ tag of
| 0 => HITnmd($UN.cast{string} ($UN.cast{lint} (pats_ccomp_hitype_ld (p, 8))))
| 1 => HITapp($UN.cast{hit} ($UN.cast{lint} (pats_ccomp_hitype_ld (p, 8))), $UN.cast{hitlst} ($UN.cast{lint} (pats_ccomp_hitype_ld (p, 16))))
| 2 => HITtyarr($UN.cast{hit} ($UN.cast{lint} (pats_ccomp_hitype_ld (p, 8))), $UN.cast{s2explst} ($UN.cast{lint} (pats_ccomp_hitype_ld (p, 16))))
| 3 => HITtyrec($UN.cast{labhitlst} ($UN.cast{lint} (pats_ccomp_hitype_ld (p, 8))))
| 4 => HITtysum($UN.cast{int} ($UN.cast{lint} (pats_ccomp_hitype_ld (p, 8))), $UN.cast{labhitlst} ($UN.cast{lint} (pats_ccomp_hitype_ld (p, 16))))
| 5 => HITtyexn($UN.cast{labhitlst} ($UN.cast{lint} (pats_ccomp_hitype_ld (p, 8))))
| 6 => HITtyvar($UN.cast{s2var} ($UN.cast{lint} (pats_ccomp_hitype_ld (p, 8))))
| 7 => HITtyclo($UN.cast{funlab} ($UN.cast{lint} (pats_ccomp_hitype_ld (p, 8))))
| 8 => HITvararg($UN.cast{hit} ($UN.cast{lint} (pats_ccomp_hitype_ld (p, 8))))
| 9 => HITrefarg($UN.cast{int} ($UN.cast{lint} (pats_ccomp_hitype_ld (p, 8))), $UN.cast{hit} ($UN.cast{lint} (pats_ccomp_hitype_ld (p, 16))))
| 10 => HITundef($UN.cast{stamp} ($UN.cast{lint} (pats_ccomp_hitype_ld (p, 8))), $UN.cast{hisexp} ($UN.cast{lint} (pats_ccomp_hitype_ld (p, 16))))
| _ => HITerror()
//
end // end of [hit_view]

implement
hit_view_free
  (v) =
(
case+ v of
| ~HITnmd(_) => ()
| ~HITapp(_, _) => ()
| ~HITtyarr(_, _) => ()
| ~HITtyrec(_) => ()
| ~HITtysum(_, _) => ()
| ~HITtyexn(_) => ()
| ~HITtyvar(_) => ()
| ~HITtyclo(_) => ()
| ~HITvararg(_) => ()
| ~HITrefarg(_, _) => ()
| ~HITundef(_, _) => ()
| ~HITerror() => ()
) (* end of [hit_view_free] *)

(* ****** ****** *)

implement
labhit_new
  (a0, a1, a2) = let
val p = pats_ccomp_hitype_alloc (24)
val () = pats_ccomp_hitype_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_ccomp_hitype_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_ccomp_hitype_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{labhit} (p)
end // end of [labhit_new]

implement
labhit_lab
  (x) = $UN.cast{label} ($UN.cast{lint} (pats_ccomp_hitype_ld ($UN.cast{ptr} (x), 0)))

implement
labhit_opt
  (x) = $UN.cast{stringopt} ($UN.cast{lint} (pats_ccomp_hitype_ld ($UN.cast{ptr} (x), 8)))

implement
labhit_elt
  (x) = $UN.cast{hit} ($UN.cast{lint} (pats_ccomp_hitype_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)
