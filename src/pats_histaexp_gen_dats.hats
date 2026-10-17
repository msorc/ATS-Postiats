fn pats_histaexp_ld (p: ptr, k: int): ptr = $UN.ptr0_get<ptr> (ptr0_add_gint<byte> (p, k))
fn pats_histaexp_st (p: ptr, k: int, x: ptr): void = $UN.ptr0_set<ptr> (ptr0_add_gint<byte> (p, k), x)
fn pats_histaexp_alloc (n: int): ptr = the_garena_alloc ($UN.cast{size_t} (n))
//

implement
hitnam_new
  (a0, a1, a2) = let
val p = pats_histaexp_alloc (24)
val () = pats_histaexp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_histaexp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_histaexp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{hitnam} (p)
end // end of [hitnam_new]

implement
hitnam_ptr
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_histaexp_ld ($UN.cast{ptr} (x), 0)))

implement
hitnam_fin
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_histaexp_ld ($UN.cast{ptr} (x), 8)))

implement
hitnam_name
  (x) = $UN.cast{string} ($UN.cast{lint} (pats_histaexp_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
hisexp_new
  (a0, a1) = let
val p = pats_histaexp_alloc (16)
val () = pats_histaexp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_histaexp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{hisexp} (p)
end // end of [hisexp_new]

implement
hisexp_name
  (x) = $UN.cast{hitnam} ($UN.cast{lint} (pats_histaexp_ld ($UN.cast{ptr} (x), 0)))

implement
hisexp_node
  (x) = $UN.cast{hisexp_node} ($UN.cast{lint} (pats_histaexp_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
labhisexp_new
  (a0, a1, a2) = let
val p = pats_histaexp_alloc (24)
val () = pats_histaexp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_histaexp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_histaexp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{labhisexp} (p)
end // end of [labhisexp_new]

implement
labhisexp_lab
  (x) = $UN.cast{label} ($UN.cast{lint} (pats_histaexp_ld ($UN.cast{ptr} (x), 0)))

implement
labhisexp_opt
  (x) = $UN.cast{stringopt} ($UN.cast{lint} (pats_histaexp_ld ($UN.cast{ptr} (x), 8)))

implement
labhisexp_elt
  (x) = $UN.cast{hisexp} ($UN.cast{lint} (pats_histaexp_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
hisexp_node_HSEcst
  (a0) = let
val p = pats_histaexp_alloc (32)
val () = pats_histaexp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_histaexp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{hisexp_node} (p)
end // end of [hisexp_node_HSEcst]

implement
hisexp_node_HSEtybox
  () = let
val p = pats_histaexp_alloc (32)
val () = pats_histaexp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
in
  $UN.cast{hisexp_node} (p)
end // end of [hisexp_node_HSEtybox]

implement
hisexp_node_HSEtyabs
  (a0) = let
val p = pats_histaexp_alloc (32)
val () = pats_histaexp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_histaexp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{hisexp_node} (p)
end // end of [hisexp_node_HSEtyabs]

implement
hisexp_node_HSEapp
  (a0, a1) = let
val p = pats_histaexp_alloc (32)
val () = pats_histaexp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (3)))
val () = pats_histaexp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_histaexp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{hisexp_node} (p)
end // end of [hisexp_node_HSEapp]

implement
hisexp_node_HSEextype
  (a0, a1) = let
val p = pats_histaexp_alloc (32)
val () = pats_histaexp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (4)))
val () = pats_histaexp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_histaexp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{hisexp_node} (p)
end // end of [hisexp_node_HSEextype]

implement
hisexp_node_HSEfun
  (a0, a1, a2) = let
val p = pats_histaexp_alloc (32)
val () = pats_histaexp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (5)))
val () = pats_histaexp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_histaexp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_histaexp_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{hisexp_node} (p)
end // end of [hisexp_node_HSEfun]

implement
hisexp_node_HSErefarg
  (a0, a1) = let
val p = pats_histaexp_alloc (32)
val () = pats_histaexp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (6)))
val () = pats_histaexp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_histaexp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{hisexp_node} (p)
end // end of [hisexp_node_HSErefarg]

implement
hisexp_node_HSEtyarr
  (a0, a1) = let
val p = pats_histaexp_alloc (32)
val () = pats_histaexp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (7)))
val () = pats_histaexp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_histaexp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{hisexp_node} (p)
end // end of [hisexp_node_HSEtyarr]

implement
hisexp_node_HSEtyrec
  (a0, a1) = let
val p = pats_histaexp_alloc (32)
val () = pats_histaexp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (8)))
val () = pats_histaexp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_histaexp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{hisexp_node} (p)
end // end of [hisexp_node_HSEtyrec]

implement
hisexp_node_HSEtyrecsin
  (a0) = let
val p = pats_histaexp_alloc (32)
val () = pats_histaexp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (9)))
val () = pats_histaexp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{hisexp_node} (p)
end // end of [hisexp_node_HSEtyrecsin]

implement
hisexp_node_HSEtysum
  (a0, a1) = let
val p = pats_histaexp_alloc (32)
val () = pats_histaexp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (10)))
val () = pats_histaexp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_histaexp_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{hisexp_node} (p)
end // end of [hisexp_node_HSEtysum]

implement
hisexp_node_HSEtyvar
  (a0) = let
val p = pats_histaexp_alloc (32)
val () = pats_histaexp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (11)))
val () = pats_histaexp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{hisexp_node} (p)
end // end of [hisexp_node_HSEtyvar]

implement
hisexp_node_HSEtyclo
  (a0) = let
val p = pats_histaexp_alloc (32)
val () = pats_histaexp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (12)))
val () = pats_histaexp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{hisexp_node} (p)
end // end of [hisexp_node_HSEtyclo]

implement
hisexp_node_HSEvararg
  (a0) = let
val p = pats_histaexp_alloc (32)
val () = pats_histaexp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (13)))
val () = pats_histaexp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{hisexp_node} (p)
end // end of [hisexp_node_HSEvararg]

implement
hisexp_node_HSEs2exp
  (a0) = let
val p = pats_histaexp_alloc (32)
val () = pats_histaexp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (14)))
val () = pats_histaexp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{hisexp_node} (p)
end // end of [hisexp_node_HSEs2exp]

implement
hisexp_node_HSEs2zexp
  (a0) = let
val p = pats_histaexp_alloc (32)
val () = pats_histaexp_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (15)))
val () = pats_histaexp_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{hisexp_node} (p)
end // end of [hisexp_node_HSEs2zexp]

implement
hisexp_node_encode
  (v) =
(
case+ v of
| ~HSEcst(a0) => hisexp_node_HSEcst(a0)
| ~HSEtybox() => hisexp_node_HSEtybox()
| ~HSEtyabs(a0) => hisexp_node_HSEtyabs(a0)
| ~HSEapp(a0, a1) => hisexp_node_HSEapp(a0, a1)
| ~HSEextype(a0, a1) => hisexp_node_HSEextype(a0, a1)
| ~HSEfun(a0, a1, a2) => hisexp_node_HSEfun(a0, a1, a2)
| ~HSErefarg(a0, a1) => hisexp_node_HSErefarg(a0, a1)
| ~HSEtyarr(a0, a1) => hisexp_node_HSEtyarr(a0, a1)
| ~HSEtyrec(a0, a1) => hisexp_node_HSEtyrec(a0, a1)
| ~HSEtyrecsin(a0) => hisexp_node_HSEtyrecsin(a0)
| ~HSEtysum(a0, a1) => hisexp_node_HSEtysum(a0, a1)
| ~HSEtyvar(a0) => hisexp_node_HSEtyvar(a0)
| ~HSEtyclo(a0) => hisexp_node_HSEtyclo(a0)
| ~HSEvararg(a0) => hisexp_node_HSEvararg(a0)
| ~HSEs2exp(a0) => hisexp_node_HSEs2exp(a0)
| ~HSEs2zexp(a0) => hisexp_node_HSEs2zexp(a0)
) (* end of [hisexp_node_encode] *)

implement
hisexp_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_histaexp_ld ($UN.cast{ptr} (x), 0)))

implement
hisexp_node_is_HSEcst
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_histaexp_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
hisexp_node_is_HSEtybox
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_histaexp_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
hisexp_node_is_HSEtyabs
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_histaexp_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
hisexp_node_is_HSEapp
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_histaexp_ld ($UN.cast{ptr} (x), 0))) = 3)

implement
hisexp_node_is_HSEextype
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_histaexp_ld ($UN.cast{ptr} (x), 0))) = 4)

implement
hisexp_node_is_HSEfun
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_histaexp_ld ($UN.cast{ptr} (x), 0))) = 5)

implement
hisexp_node_is_HSErefarg
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_histaexp_ld ($UN.cast{ptr} (x), 0))) = 6)

implement
hisexp_node_is_HSEtyarr
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_histaexp_ld ($UN.cast{ptr} (x), 0))) = 7)

implement
hisexp_node_is_HSEtyrec
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_histaexp_ld ($UN.cast{ptr} (x), 0))) = 8)

implement
hisexp_node_is_HSEtyrecsin
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_histaexp_ld ($UN.cast{ptr} (x), 0))) = 9)

implement
hisexp_node_is_HSEtysum
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_histaexp_ld ($UN.cast{ptr} (x), 0))) = 10)

implement
hisexp_node_is_HSEtyvar
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_histaexp_ld ($UN.cast{ptr} (x), 0))) = 11)

implement
hisexp_node_is_HSEtyclo
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_histaexp_ld ($UN.cast{ptr} (x), 0))) = 12)

implement
hisexp_node_is_HSEvararg
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_histaexp_ld ($UN.cast{ptr} (x), 0))) = 13)

implement
hisexp_node_is_HSEs2exp
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_histaexp_ld ($UN.cast{ptr} (x), 0))) = 14)

implement
hisexp_node_is_HSEs2zexp
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_histaexp_ld ($UN.cast{ptr} (x), 0))) = 15)

implement
hisexp_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_histaexp_ld (p, 0)))
//
in
//
case+ tag of
| 0 => HSEcst($UN.cast{s2cst} ($UN.cast{lint} (pats_histaexp_ld (p, 8))))
| 1 => HSEtybox()
| 2 => HSEtyabs($UN.cast{symbol} ($UN.cast{lint} (pats_histaexp_ld (p, 8))))
| 3 => HSEapp($UN.cast{hisexp} ($UN.cast{lint} (pats_histaexp_ld (p, 8))), $UN.cast{hisexplst} ($UN.cast{lint} (pats_histaexp_ld (p, 16))))
| 4 => HSEextype($UN.cast{string} ($UN.cast{lint} (pats_histaexp_ld (p, 8))), $UN.cast{hisexplstlst} ($UN.cast{lint} (pats_histaexp_ld (p, 16))))
| 5 => HSEfun($UN.cast{funclo} ($UN.cast{lint} (pats_histaexp_ld (p, 8))), $UN.cast{hisexplst} ($UN.cast{lint} (pats_histaexp_ld (p, 16))), $UN.cast{hisexp} ($UN.cast{lint} (pats_histaexp_ld (p, 24))))
| 6 => HSErefarg($UN.cast{int} ($UN.cast{lint} (pats_histaexp_ld (p, 8))), $UN.cast{hisexp} ($UN.cast{lint} (pats_histaexp_ld (p, 16))))
| 7 => HSEtyarr($UN.cast{hisexp} ($UN.cast{lint} (pats_histaexp_ld (p, 8))), $UN.cast{s2explst} ($UN.cast{lint} (pats_histaexp_ld (p, 16))))
| 8 => HSEtyrec($UN.cast{tyreckind} ($UN.cast{lint} (pats_histaexp_ld (p, 8))), $UN.cast{labhisexplst} ($UN.cast{lint} (pats_histaexp_ld (p, 16))))
| 9 => HSEtyrecsin($UN.cast{labhisexp} ($UN.cast{lint} (pats_histaexp_ld (p, 8))))
| 10 => HSEtysum($UN.cast{d2con} ($UN.cast{lint} (pats_histaexp_ld (p, 8))), $UN.cast{labhisexplst} ($UN.cast{lint} (pats_histaexp_ld (p, 16))))
| 11 => HSEtyvar($UN.cast{s2var} ($UN.cast{lint} (pats_histaexp_ld (p, 8))))
| 12 => HSEtyclo($UN.cast{funlab} ($UN.cast{lint} (pats_histaexp_ld (p, 8))))
| 13 => HSEvararg($UN.cast{s2exp} ($UN.cast{lint} (pats_histaexp_ld (p, 8))))
| 14 => HSEs2exp($UN.cast{s2exp} ($UN.cast{lint} (pats_histaexp_ld (p, 8))))
| _ => HSEs2zexp($UN.cast{s2zexp} ($UN.cast{lint} (pats_histaexp_ld (p, 8))))
//
end // end of [hisexp_node_view]

implement
hisexp_node_view_free
  (v) =
(
case+ v of
| ~HSEcst(_) => ()
| ~HSEtybox() => ()
| ~HSEtyabs(_) => ()
| ~HSEapp(_, _) => ()
| ~HSEextype(_, _) => ()
| ~HSEfun(_, _, _) => ()
| ~HSErefarg(_, _) => ()
| ~HSEtyarr(_, _) => ()
| ~HSEtyrec(_, _) => ()
| ~HSEtyrecsin(_) => ()
| ~HSEtysum(_, _) => ()
| ~HSEtyvar(_) => ()
| ~HSEtyclo(_) => ()
| ~HSEvararg(_) => ()
| ~HSEs2exp(_) => ()
| ~HSEs2zexp(_) => ()
) (* end of [hisexp_node_view_free] *)

(* ****** ****** *)
