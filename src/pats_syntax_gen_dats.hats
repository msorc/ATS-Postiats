fn pats_syntax_ld (p: ptr, k: int): ptr = $UN.ptr0_get<ptr> (ptr0_add_gint<byte> (p, k))
fn pats_syntax_st (p: ptr, k: int, x: ptr): void = $UN.ptr0_set<ptr> (ptr0_add_gint<byte> (p, k), x)
fn pats_syntax_alloc (n: int): ptr = the_garena_alloc ($UN.cast{size_t} (n))
//

implement
i0de_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{i0de} (p)
end // end of [i0de_new]

implement
i0de_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
i0de_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
e0fftag_node_E0FFTAGint
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{e0fftag_node} (p)
end // end of [e0fftag_node_E0FFTAGint]

implement
e0fftag_node_E0FFTAGcst
  (a0, a1) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{e0fftag_node} (p)
end // end of [e0fftag_node_E0FFTAGcst]

implement
e0fftag_node_E0FFTAGvar
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{e0fftag_node} (p)
end // end of [e0fftag_node_E0FFTAGvar]

implement
e0fftag_node_E0FFTAGprf
  () = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (3)))
in
  $UN.cast{e0fftag_node} (p)
end // end of [e0fftag_node_E0FFTAGprf]

implement
e0fftag_node_E0FFTAGlin
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (4)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{e0fftag_node} (p)
end // end of [e0fftag_node_E0FFTAGlin]

implement
e0fftag_node_E0FFTAGfun
  (a0, a1) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (5)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{e0fftag_node} (p)
end // end of [e0fftag_node_E0FFTAGfun]

implement
e0fftag_node_E0FFTAGclo
  (a0, a1, a2) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (6)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{e0fftag_node} (p)
end // end of [e0fftag_node_E0FFTAGclo]

implement
e0fftag_node_encode
  (v) =
(
case+ v of
| ~E0FFTAGint(a0) => e0fftag_node_E0FFTAGint(a0)
| ~E0FFTAGcst(a0, a1) => e0fftag_node_E0FFTAGcst(a0, a1)
| ~E0FFTAGvar(a0) => e0fftag_node_E0FFTAGvar(a0)
| ~E0FFTAGprf() => e0fftag_node_E0FFTAGprf()
| ~E0FFTAGlin(a0) => e0fftag_node_E0FFTAGlin(a0)
| ~E0FFTAGfun(a0, a1) => e0fftag_node_E0FFTAGfun(a0, a1)
| ~E0FFTAGclo(a0, a1, a2) => e0fftag_node_E0FFTAGclo(a0, a1, a2)
) (* end of [e0fftag_node_encode] *)

implement
e0fftag_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
e0fftag_node_is_E0FFTAGint
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
e0fftag_node_is_E0FFTAGcst
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
e0fftag_node_is_E0FFTAGvar
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
e0fftag_node_is_E0FFTAGprf
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 3)

implement
e0fftag_node_is_E0FFTAGlin
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 4)

implement
e0fftag_node_is_E0FFTAGfun
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 5)

implement
e0fftag_node_is_E0FFTAGclo
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 6)

implement
e0fftag_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 0)))
//
in
//
case+ tag of
| 0 => E0FFTAGint($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 1 => E0FFTAGcst($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{string} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 2 => E0FFTAGvar($UN.cast{i0de} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 3 => E0FFTAGprf()
| 4 => E0FFTAGlin($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 5 => E0FFTAGfun($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| _ => E0FFTAGclo($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
//
end // end of [e0fftag_node_view]

implement
e0fftag_node_view_free
  (v) =
(
case+ v of
| ~E0FFTAGint(_) => ()
| ~E0FFTAGcst(_, _) => ()
| ~E0FFTAGvar(_) => ()
| ~E0FFTAGprf() => ()
| ~E0FFTAGlin(_) => ()
| ~E0FFTAGfun(_, _) => ()
| ~E0FFTAGclo(_, _, _) => ()
) (* end of [e0fftag_node_view_free] *)

(* ****** ****** *)

implement
e0fftag_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{e0fftag} (p)
end // end of [e0fftag_new]

implement
e0fftag_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
e0fftag_node
  (x) = $UN.cast{e0fftag_node} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
s0rtq_node_S0RTQnone
  () = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
in
  $UN.cast{s0rtq_node} (p)
end // end of [s0rtq_node_S0RTQnone]

implement
s0rtq_node_S0RTQsymdot
  (a0) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s0rtq_node} (p)
end // end of [s0rtq_node_S0RTQsymdot]

implement
s0rtq_node_encode
  (v) =
(
case+ v of
| ~S0RTQnone() => s0rtq_node_S0RTQnone()
| ~S0RTQsymdot(a0) => s0rtq_node_S0RTQsymdot(a0)
) (* end of [s0rtq_node_encode] *)

implement
s0rtq_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
s0rtq_node_is_S0RTQnone
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
s0rtq_node_is_S0RTQsymdot
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
s0rtq_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 0)))
//
in
//
case+ tag of
| 0 => S0RTQnone()
| _ => S0RTQsymdot($UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
//
end // end of [s0rtq_node_view]

implement
s0rtq_node_view_free
  (v) =
(
case+ v of
| ~S0RTQnone() => ()
| ~S0RTQsymdot(_) => ()
) (* end of [s0rtq_node_view_free] *)

(* ****** ****** *)

implement
s0rtq_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s0rtq} (p)
end // end of [s0rtq_new]

implement
s0rtq_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
s0rtq_node
  (x) = $UN.cast{s0rtq_node} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
s0taq_node_S0TAQnone
  () = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
in
  $UN.cast{s0taq_node} (p)
end // end of [s0taq_node_S0TAQnone]

implement
s0taq_node_S0TAQsymdot
  (a0) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s0taq_node} (p)
end // end of [s0taq_node_S0TAQsymdot]

implement
s0taq_node_encode
  (v) =
(
case+ v of
| ~S0TAQnone() => s0taq_node_S0TAQnone()
| ~S0TAQsymdot(a0) => s0taq_node_S0TAQsymdot(a0)
) (* end of [s0taq_node_encode] *)

implement
s0taq_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
s0taq_node_is_S0TAQnone
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
s0taq_node_is_S0TAQsymdot
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
s0taq_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 0)))
//
in
//
case+ tag of
| 0 => S0TAQnone()
| _ => S0TAQsymdot($UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
//
end // end of [s0taq_node_view]

implement
s0taq_node_view_free
  (v) =
(
case+ v of
| ~S0TAQnone() => ()
| ~S0TAQsymdot(_) => ()
) (* end of [s0taq_node_view_free] *)

(* ****** ****** *)

implement
s0taq_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s0taq} (p)
end // end of [s0taq_new]

implement
s0taq_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
s0taq_node
  (x) = $UN.cast{s0taq_node} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
sqi0de_new
  (a0, a1, a2) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{sqi0de} (p)
end // end of [sqi0de_new]

implement
sqi0de_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
sqi0de_qua
  (x) = $UN.cast{s0taq} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
sqi0de_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
d0ynq_node_D0YNQnone
  () = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
in
  $UN.cast{d0ynq_node} (p)
end // end of [d0ynq_node_D0YNQnone]

implement
d0ynq_node_D0YNQsymdot
  (a0) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0ynq_node} (p)
end // end of [d0ynq_node_D0YNQsymdot]

implement
d0ynq_node_encode
  (v) =
(
case+ v of
| ~D0YNQnone() => d0ynq_node_D0YNQnone()
| ~D0YNQsymdot(a0) => d0ynq_node_D0YNQsymdot(a0)
) (* end of [d0ynq_node_encode] *)

implement
d0ynq_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
d0ynq_node_is_D0YNQnone
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
d0ynq_node_is_D0YNQsymdot
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
d0ynq_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 0)))
//
in
//
case+ tag of
| 0 => D0YNQnone()
| _ => D0YNQsymdot($UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
//
end // end of [d0ynq_node_view]

implement
d0ynq_node_view_free
  (v) =
(
case+ v of
| ~D0YNQnone() => ()
| ~D0YNQsymdot(_) => ()
) (* end of [d0ynq_node_view_free] *)

(* ****** ****** *)

implement
d0ynq_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0ynq} (p)
end // end of [d0ynq_new]

implement
d0ynq_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
d0ynq_node
  (x) = $UN.cast{d0ynq_node} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
dqi0de_new
  (a0, a1, a2) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{dqi0de} (p)
end // end of [dqi0de_new]

implement
dqi0de_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
dqi0de_qua
  (x) = $UN.cast{d0ynq} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
dqi0de_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
p0rec_P0RECint
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{p0rec} (p)
end // end of [p0rec_P0RECint]

implement
p0rec_P0RECi0de
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{p0rec} (p)
end // end of [p0rec_P0RECi0de]

implement
p0rec_P0RECi0de_adj
  (a0, a1, a2) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{p0rec} (p)
end // end of [p0rec_P0RECi0de_adj]

implement
p0rec_encode
  (v) =
(
case+ v of
| ~P0RECint(a0) => p0rec_P0RECint(a0)
| ~P0RECi0de(a0) => p0rec_P0RECi0de(a0)
| ~P0RECi0de_adj(a0, a1, a2) => p0rec_P0RECi0de_adj(a0, a1, a2)
) (* end of [p0rec_encode] *)

implement
p0rec_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
p0rec_is_P0RECint
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
p0rec_is_P0RECi0de
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
p0rec_is_P0RECi0de_adj
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
p0rec_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 0)))
//
in
//
case+ tag of
| 0 => P0RECint($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 1 => P0RECi0de($UN.cast{i0de} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| _ => P0RECi0de_adj($UN.cast{i0de} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{i0de} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
//
end // end of [p0rec_view]

implement
p0rec_view_free
  (v) =
(
case+ v of
| ~P0RECint(_) => ()
| ~P0RECi0de(_) => ()
| ~P0RECi0de_adj(_, _, _) => ()
) (* end of [p0rec_view_free] *)

(* ****** ****** *)

implement
f0xty_F0XTYinf
  (a0, a1) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{f0xty} (p)
end // end of [f0xty_F0XTYinf]

implement
f0xty_F0XTYpre
  (a0) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{f0xty} (p)
end // end of [f0xty_F0XTYpre]

implement
f0xty_F0XTYpos
  (a0) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{f0xty} (p)
end // end of [f0xty_F0XTYpos]

implement
f0xty_encode
  (v) =
(
case+ v of
| ~F0XTYinf(a0, a1) => f0xty_F0XTYinf(a0, a1)
| ~F0XTYpre(a0) => f0xty_F0XTYpre(a0)
| ~F0XTYpos(a0) => f0xty_F0XTYpos(a0)
) (* end of [f0xty_encode] *)

implement
f0xty_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
f0xty_is_F0XTYinf
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
f0xty_is_F0XTYpre
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
f0xty_is_F0XTYpos
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
f0xty_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 0)))
//
in
//
case+ tag of
| 0 => F0XTYinf($UN.cast{p0rec} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{assoc} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 1 => F0XTYpre($UN.cast{p0rec} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| _ => F0XTYpos($UN.cast{p0rec} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
//
end // end of [f0xty_view]

implement
f0xty_view_free
  (v) =
(
case+ v of
| ~F0XTYinf(_, _) => ()
| ~F0XTYpre(_) => ()
| ~F0XTYpos(_) => ()
) (* end of [f0xty_view_free] *)

(* ****** ****** *)

implement
e0xp_node_E0XPide
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{e0xp_node} (p)
end // end of [e0xp_node_E0XPide]

implement
e0xp_node_E0XPint
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{e0xp_node} (p)
end // end of [e0xp_node_E0XPint]

implement
e0xp_node_E0XPchar
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{e0xp_node} (p)
end // end of [e0xp_node_E0XPchar]

implement
e0xp_node_E0XPfloat
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (3)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{e0xp_node} (p)
end // end of [e0xp_node_E0XPfloat]

implement
e0xp_node_E0XPstring
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (4)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{e0xp_node} (p)
end // end of [e0xp_node_E0XPstring]

implement
e0xp_node_E0XPstringid
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (5)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{e0xp_node} (p)
end // end of [e0xp_node_E0XPstringid]

implement
e0xp_node_E0XPapp
  (a0, a1) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (6)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{e0xp_node} (p)
end // end of [e0xp_node_E0XPapp]

implement
e0xp_node_E0XPfun
  (a0, a1) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (7)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{e0xp_node} (p)
end // end of [e0xp_node_E0XPfun]

implement
e0xp_node_E0XPeval
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (8)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{e0xp_node} (p)
end // end of [e0xp_node_E0XPeval]

implement
e0xp_node_E0XPlist
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (9)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{e0xp_node} (p)
end // end of [e0xp_node_E0XPlist]

implement
e0xp_node_E0XPif
  (a0, a1, a2) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (10)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{e0xp_node} (p)
end // end of [e0xp_node_E0XPif]

implement
e0xp_node_encode
  (v) =
(
case+ v of
| ~E0XPide(a0) => e0xp_node_E0XPide(a0)
| ~E0XPint(a0) => e0xp_node_E0XPint(a0)
| ~E0XPchar(a0) => e0xp_node_E0XPchar(a0)
| ~E0XPfloat(a0) => e0xp_node_E0XPfloat(a0)
| ~E0XPstring(a0) => e0xp_node_E0XPstring(a0)
| ~E0XPstringid(a0) => e0xp_node_E0XPstringid(a0)
| ~E0XPapp(a0, a1) => e0xp_node_E0XPapp(a0, a1)
| ~E0XPfun(a0, a1) => e0xp_node_E0XPfun(a0, a1)
| ~E0XPeval(a0) => e0xp_node_E0XPeval(a0)
| ~E0XPlist(a0) => e0xp_node_E0XPlist(a0)
| ~E0XPif(a0, a1, a2) => e0xp_node_E0XPif(a0, a1, a2)
) (* end of [e0xp_node_encode] *)

implement
e0xp_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
e0xp_node_is_E0XPide
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
e0xp_node_is_E0XPint
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
e0xp_node_is_E0XPchar
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
e0xp_node_is_E0XPfloat
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 3)

implement
e0xp_node_is_E0XPstring
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 4)

implement
e0xp_node_is_E0XPstringid
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 5)

implement
e0xp_node_is_E0XPapp
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 6)

implement
e0xp_node_is_E0XPfun
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 7)

implement
e0xp_node_is_E0XPeval
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 8)

implement
e0xp_node_is_E0XPlist
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 9)

implement
e0xp_node_is_E0XPif
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 10)

implement
e0xp_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 0)))
//
in
//
case+ tag of
| 0 => E0XPide($UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 1 => E0XPint($UN.cast{i0nt} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 2 => E0XPchar($UN.cast{c0har} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 3 => E0XPfloat($UN.cast{f0loat} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 4 => E0XPstring($UN.cast{s0tring} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 5 => E0XPstringid($UN.cast{string} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 6 => E0XPapp($UN.cast{e0xp} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{e0xp} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 7 => E0XPfun($UN.cast{symbolist} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{e0xp} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 8 => E0XPeval($UN.cast{e0xp} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 9 => E0XPlist($UN.cast{e0xplst} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| _ => E0XPif($UN.cast{e0xp} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{e0xp} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{e0xpopt} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
//
end // end of [e0xp_node_view]

implement
e0xp_node_view_free
  (v) =
(
case+ v of
| ~E0XPide(_) => ()
| ~E0XPint(_) => ()
| ~E0XPchar(_) => ()
| ~E0XPfloat(_) => ()
| ~E0XPstring(_) => ()
| ~E0XPstringid(_) => ()
| ~E0XPapp(_, _) => ()
| ~E0XPfun(_, _) => ()
| ~E0XPeval(_) => ()
| ~E0XPlist(_) => ()
| ~E0XPif(_, _, _) => ()
) (* end of [e0xp_node_view_free] *)

(* ****** ****** *)

implement
e0xp_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{e0xp} (p)
end // end of [e0xp_new]

implement
e0xp_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
e0xp_node
  (x) = $UN.cast{e0xp_node} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
l0ab_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{l0ab} (p)
end // end of [l0ab_new]

implement
l0ab_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
l0ab_lab
  (x) = $UN.cast{label} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
s0rt_node_S0RTide
  (a0) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s0rt_node} (p)
end // end of [s0rt_node_S0RTide]

implement
s0rt_node_S0RTqid
  (a0, a1) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s0rt_node} (p)
end // end of [s0rt_node_S0RTqid]

implement
s0rt_node_S0RTapp
  (a0, a1) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s0rt_node} (p)
end // end of [s0rt_node_S0RTapp]

implement
s0rt_node_S0RTlist
  (a0) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (3)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s0rt_node} (p)
end // end of [s0rt_node_S0RTlist]

implement
s0rt_node_S0RTtype
  (a0) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (4)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s0rt_node} (p)
end // end of [s0rt_node_S0RTtype]

implement
s0rt_node_encode
  (v) =
(
case+ v of
| ~S0RTide(a0) => s0rt_node_S0RTide(a0)
| ~S0RTqid(a0, a1) => s0rt_node_S0RTqid(a0, a1)
| ~S0RTapp(a0, a1) => s0rt_node_S0RTapp(a0, a1)
| ~S0RTlist(a0) => s0rt_node_S0RTlist(a0)
| ~S0RTtype(a0) => s0rt_node_S0RTtype(a0)
) (* end of [s0rt_node_encode] *)

implement
s0rt_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
s0rt_node_is_S0RTide
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
s0rt_node_is_S0RTqid
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
s0rt_node_is_S0RTapp
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
s0rt_node_is_S0RTlist
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 3)

implement
s0rt_node_is_S0RTtype
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 4)

implement
s0rt_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 0)))
//
in
//
case+ tag of
| 0 => S0RTide($UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 1 => S0RTqid($UN.cast{s0rtq} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 2 => S0RTapp($UN.cast{s0rt} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{s0rt} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 3 => S0RTlist($UN.cast{s0rtlst} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| _ => S0RTtype($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
//
end // end of [s0rt_node_view]

implement
s0rt_node_view_free
  (v) =
(
case+ v of
| ~S0RTide(_) => ()
| ~S0RTqid(_, _) => ()
| ~S0RTapp(_, _) => ()
| ~S0RTlist(_) => ()
| ~S0RTtype(_) => ()
) (* end of [s0rt_node_view_free] *)

(* ****** ****** *)

implement
s0rt_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s0rt} (p)
end // end of [s0rt_new]

implement
s0rt_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
s0rt_node
  (x) = $UN.cast{s0rt_node} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
s0rtpol_new
  (a0, a1, a2) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{s0rtpol} (p)
end // end of [s0rtpol_new]

implement
s0rtpol_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
s0rtpol_srt
  (x) = $UN.cast{s0rt} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
s0rtpol_pol
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
d0atsrtcon_new
  (a0, a1, a2) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d0atsrtcon} (p)
end // end of [d0atsrtcon_new]

implement
d0atsrtcon_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
d0atsrtcon_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
d0atsrtcon_arg
  (x) = $UN.cast{s0rtopt} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
d0atsrtdec_new
  (a0, a1, a2) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d0atsrtdec} (p)
end // end of [d0atsrtdec_new]

implement
d0atsrtdec_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
d0atsrtdec_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
d0atsrtdec_con
  (x) = $UN.cast{d0atsrtconlst} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
s0arg_new
  (a0, a1, a2) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{s0arg} (p)
end // end of [s0arg_new]

implement
s0arg_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
s0arg_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
s0arg_srt
  (x) = $UN.cast{s0rtopt} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
s0marg_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s0marg} (p)
end // end of [s0marg_new]

implement
s0marg_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
s0marg_arg
  (x) = $UN.cast{s0arglst} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
a0srt_new
  (a0, a1, a2) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{a0srt} (p)
end // end of [a0srt_new]

implement
a0srt_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
a0srt_sym
  (x) = $UN.cast{symbolopt} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
a0srt_srt
  (x) = $UN.cast{s0rt} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
a0msrt_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{a0msrt} (p)
end // end of [a0msrt_new]

implement
a0msrt_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
a0msrt_arg
  (x) = $UN.cast{a0srtlst} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
sp0at_node_SP0Tcstr
  (a0, a1) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{sp0at_node} (p)
end // end of [sp0at_node_SP0Tcstr]

implement
sp0at_node_encode
  (v) =
(
case+ v of
| ~SP0Tcstr(a0, a1) => sp0at_node_SP0Tcstr(a0, a1)
) (* end of [sp0at_node_encode] *)

implement
sp0at_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
sp0at_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 0)))
//
in
//
case+ tag of
| _ => SP0Tcstr($UN.cast{sqi0de} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{s0arglst} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
//
end // end of [sp0at_node_view]

implement
sp0at_node_view_free
  (v) =
(
case+ v of
| ~SP0Tcstr(_, _) => ()
) (* end of [sp0at_node_view_free] *)

(* ****** ****** *)

implement
sp0at_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{sp0at} (p)
end // end of [sp0at_new]

implement
sp0at_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
sp0at_node
  (x) = $UN.cast{sp0at_node} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
s0exp_node_S0Eide
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s0exp_node} (p)
end // end of [s0exp_node_S0Eide]

implement
s0exp_node_S0Esqid
  (a0, a1) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s0exp_node} (p)
end // end of [s0exp_node_S0Esqid]

implement
s0exp_node_S0Eopid
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s0exp_node} (p)
end // end of [s0exp_node_S0Eopid]

implement
s0exp_node_S0Eint
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (3)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s0exp_node} (p)
end // end of [s0exp_node_S0Eint]

implement
s0exp_node_S0Echar
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (4)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s0exp_node} (p)
end // end of [s0exp_node_S0Echar]

implement
s0exp_node_S0Efloat
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (5)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s0exp_node} (p)
end // end of [s0exp_node_S0Efloat]

implement
s0exp_node_S0Estring
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (6)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s0exp_node} (p)
end // end of [s0exp_node_S0Estring]

implement
s0exp_node_S0Eextype
  (a0, a1) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (7)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s0exp_node} (p)
end // end of [s0exp_node_S0Eextype]

implement
s0exp_node_S0Eextkind
  (a0, a1) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (8)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s0exp_node} (p)
end // end of [s0exp_node_S0Eextkind]

implement
s0exp_node_S0Eapp
  (a0, a1) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (9)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s0exp_node} (p)
end // end of [s0exp_node_S0Eapp]

implement
s0exp_node_S0Elam
  (a0, a1, a2) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (10)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{s0exp_node} (p)
end // end of [s0exp_node_S0Elam]

implement
s0exp_node_S0Eimp
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (11)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s0exp_node} (p)
end // end of [s0exp_node_S0Eimp]

implement
s0exp_node_S0Elist
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (12)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s0exp_node} (p)
end // end of [s0exp_node_S0Elist]

implement
s0exp_node_S0Elist2
  (a0, a1) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (13)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s0exp_node} (p)
end // end of [s0exp_node_S0Elist2]

implement
s0exp_node_S0Etyarr
  (a0, a1) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (14)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s0exp_node} (p)
end // end of [s0exp_node_S0Etyarr]

implement
s0exp_node_S0Etytup
  (a0, a1, a2) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (15)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{s0exp_node} (p)
end // end of [s0exp_node_S0Etytup]

implement
s0exp_node_S0Etyrec
  (a0, a1, a2) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (16)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{s0exp_node} (p)
end // end of [s0exp_node_S0Etyrec]

implement
s0exp_node_S0Etyrec_ext
  (a0, a1, a2) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (17)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{s0exp_node} (p)
end // end of [s0exp_node_S0Etyrec_ext]

implement
s0exp_node_S0Euni
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (18)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s0exp_node} (p)
end // end of [s0exp_node_S0Euni]

implement
s0exp_node_S0Eexi
  (a0, a1) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (19)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s0exp_node} (p)
end // end of [s0exp_node_S0Eexi]

implement
s0exp_node_S0Eann
  (a0, a1) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (20)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s0exp_node} (p)
end // end of [s0exp_node_S0Eann]

implement
s0exp_node_S0Ed2ctype
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (21)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s0exp_node} (p)
end // end of [s0exp_node_S0Ed2ctype]

implement
s0exp_node_encode
  (v) =
(
case+ v of
| ~S0Eide(a0) => s0exp_node_S0Eide(a0)
| ~S0Esqid(a0, a1) => s0exp_node_S0Esqid(a0, a1)
| ~S0Eopid(a0) => s0exp_node_S0Eopid(a0)
| ~S0Eint(a0) => s0exp_node_S0Eint(a0)
| ~S0Echar(a0) => s0exp_node_S0Echar(a0)
| ~S0Efloat(a0) => s0exp_node_S0Efloat(a0)
| ~S0Estring(a0) => s0exp_node_S0Estring(a0)
| ~S0Eextype(a0, a1) => s0exp_node_S0Eextype(a0, a1)
| ~S0Eextkind(a0, a1) => s0exp_node_S0Eextkind(a0, a1)
| ~S0Eapp(a0, a1) => s0exp_node_S0Eapp(a0, a1)
| ~S0Elam(a0, a1, a2) => s0exp_node_S0Elam(a0, a1, a2)
| ~S0Eimp(a0) => s0exp_node_S0Eimp(a0)
| ~S0Elist(a0) => s0exp_node_S0Elist(a0)
| ~S0Elist2(a0, a1) => s0exp_node_S0Elist2(a0, a1)
| ~S0Etyarr(a0, a1) => s0exp_node_S0Etyarr(a0, a1)
| ~S0Etytup(a0, a1, a2) => s0exp_node_S0Etytup(a0, a1, a2)
| ~S0Etyrec(a0, a1, a2) => s0exp_node_S0Etyrec(a0, a1, a2)
| ~S0Etyrec_ext(a0, a1, a2) => s0exp_node_S0Etyrec_ext(a0, a1, a2)
| ~S0Euni(a0) => s0exp_node_S0Euni(a0)
| ~S0Eexi(a0, a1) => s0exp_node_S0Eexi(a0, a1)
| ~S0Eann(a0, a1) => s0exp_node_S0Eann(a0, a1)
| ~S0Ed2ctype(a0) => s0exp_node_S0Ed2ctype(a0)
) (* end of [s0exp_node_encode] *)

implement
s0exp_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
s0exp_node_is_S0Eide
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
s0exp_node_is_S0Esqid
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
s0exp_node_is_S0Eopid
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
s0exp_node_is_S0Eint
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 3)

implement
s0exp_node_is_S0Echar
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 4)

implement
s0exp_node_is_S0Efloat
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 5)

implement
s0exp_node_is_S0Estring
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 6)

implement
s0exp_node_is_S0Eextype
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 7)

implement
s0exp_node_is_S0Eextkind
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 8)

implement
s0exp_node_is_S0Eapp
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 9)

implement
s0exp_node_is_S0Elam
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 10)

implement
s0exp_node_is_S0Eimp
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 11)

implement
s0exp_node_is_S0Elist
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 12)

implement
s0exp_node_is_S0Elist2
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 13)

implement
s0exp_node_is_S0Etyarr
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 14)

implement
s0exp_node_is_S0Etytup
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 15)

implement
s0exp_node_is_S0Etyrec
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 16)

implement
s0exp_node_is_S0Etyrec_ext
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 17)

implement
s0exp_node_is_S0Euni
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 18)

implement
s0exp_node_is_S0Eexi
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 19)

implement
s0exp_node_is_S0Eann
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 20)

implement
s0exp_node_is_S0Ed2ctype
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 21)

implement
s0exp_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 0)))
//
in
//
case+ tag of
| 0 => S0Eide($UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 1 => S0Esqid($UN.cast{s0taq} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 2 => S0Eopid($UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 3 => S0Eint($UN.cast{i0nt} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 4 => S0Echar($UN.cast{c0har} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 5 => S0Efloat($UN.cast{f0loat} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 6 => S0Estring($UN.cast{s0tring} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 7 => S0Eextype($UN.cast{string} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{s0explst} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 8 => S0Eextkind($UN.cast{string} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{s0explst} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 9 => S0Eapp($UN.cast{s0exp} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{s0exp} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 10 => S0Elam($UN.cast{s0marg} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{s0rtopt} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{s0exp} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
| 11 => S0Eimp($UN.cast{e0fftaglst} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 12 => S0Elist($UN.cast{s0explst} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 13 => S0Elist2($UN.cast{s0explst} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{s0explst} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 14 => S0Etyarr($UN.cast{s0exp} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{s0explst} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 15 => S0Etytup($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{s0explst} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
| 16 => S0Etyrec($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{labs0explst} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
| 17 => S0Etyrec_ext($UN.cast{string} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{labs0explst} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
| 18 => S0Euni($UN.cast{s0qualst} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 19 => S0Eexi($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{s0qualst} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 20 => S0Eann($UN.cast{s0exp} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{s0rt} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| _ => S0Ed2ctype($UN.cast{S0Ed2ctype} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
//
end // end of [s0exp_node_view]

implement
s0exp_node_view_free
  (v) =
(
case+ v of
| ~S0Eide(_) => ()
| ~S0Esqid(_, _) => ()
| ~S0Eopid(_) => ()
| ~S0Eint(_) => ()
| ~S0Echar(_) => ()
| ~S0Efloat(_) => ()
| ~S0Estring(_) => ()
| ~S0Eextype(_, _) => ()
| ~S0Eextkind(_, _) => ()
| ~S0Eapp(_, _) => ()
| ~S0Elam(_, _, _) => ()
| ~S0Eimp(_) => ()
| ~S0Elist(_) => ()
| ~S0Elist2(_, _) => ()
| ~S0Etyarr(_, _) => ()
| ~S0Etytup(_, _, _) => ()
| ~S0Etyrec(_, _, _) => ()
| ~S0Etyrec_ext(_, _, _) => ()
| ~S0Euni(_) => ()
| ~S0Eexi(_, _) => ()
| ~S0Eann(_, _) => ()
| ~S0Ed2ctype(_) => ()
) (* end of [s0exp_node_view_free] *)

(* ****** ****** *)

implement
s0rtext_node_S0TEsrt
  (a0) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s0rtext_node} (p)
end // end of [s0rtext_node_S0TEsrt]

implement
s0rtext_node_S0TEsub
  (a0, a1, a2, a3) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_syntax_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{s0rtext_node} (p)
end // end of [s0rtext_node_S0TEsub]

implement
s0rtext_node_encode
  (v) =
(
case+ v of
| ~S0TEsrt(a0) => s0rtext_node_S0TEsrt(a0)
| ~S0TEsub(a0, a1, a2, a3) => s0rtext_node_S0TEsub(a0, a1, a2, a3)
) (* end of [s0rtext_node_encode] *)

implement
s0rtext_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
s0rtext_node_is_S0TEsrt
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
s0rtext_node_is_S0TEsub
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
s0rtext_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 0)))
//
in
//
case+ tag of
| 0 => S0TEsrt($UN.cast{s0rt} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| _ => S0TEsub($UN.cast{i0de} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{s0rtext} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{s0exp} ($UN.cast{lint} (pats_syntax_ld (p, 24))), $UN.cast{s0explst} ($UN.cast{lint} (pats_syntax_ld (p, 32))))
//
end // end of [s0rtext_node_view]

implement
s0rtext_node_view_free
  (v) =
(
case+ v of
| ~S0TEsrt(_) => ()
| ~S0TEsub(_, _, _, _) => ()
) (* end of [s0rtext_node_view_free] *)

(* ****** ****** *)

implement
s0qua_node_S0QUAprop
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s0qua_node} (p)
end // end of [s0qua_node_S0QUAprop]

implement
s0qua_node_S0QUAvars
  (a0, a1, a2) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{s0qua_node} (p)
end // end of [s0qua_node_S0QUAvars]

implement
s0qua_node_encode
  (v) =
(
case+ v of
| ~S0QUAprop(a0) => s0qua_node_S0QUAprop(a0)
| ~S0QUAvars(a0, a1, a2) => s0qua_node_S0QUAvars(a0, a1, a2)
) (* end of [s0qua_node_encode] *)

implement
s0qua_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
s0qua_node_is_S0QUAprop
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
s0qua_node_is_S0QUAvars
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
s0qua_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 0)))
//
in
//
case+ tag of
| 0 => S0QUAprop($UN.cast{s0exp} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| _ => S0QUAvars($UN.cast{i0de} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{i0delst} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{s0rtext} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
//
end // end of [s0qua_node_view]

implement
s0qua_node_view_free
  (v) =
(
case+ v of
| ~S0QUAprop(_) => ()
| ~S0QUAvars(_, _, _) => ()
) (* end of [s0qua_node_view_free] *)

(* ****** ****** *)

implement
s0exp_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s0exp} (p)
end // end of [s0exp_new]

implement
s0exp_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
s0exp_node
  (x) = $UN.cast{s0exp_node} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
s0arrdim_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s0arrdim} (p)
end // end of [s0arrdim_new]

implement
s0arrdim_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
s0arrdim_dim
  (x) = $UN.cast{s0explst} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
s0rtext_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s0rtext} (p)
end // end of [s0rtext_new]

implement
s0rtext_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
s0rtext_node
  (x) = $UN.cast{s0rtext_node} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
s0qua_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s0qua} (p)
end // end of [s0qua_new]

implement
s0qua_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
s0qua_node
  (x) = $UN.cast{s0qua_node} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
witht0ype_WITHT0YPEsome
  (a0, a1) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{witht0ype} (p)
end // end of [witht0ype_WITHT0YPEsome]

implement
witht0ype_WITHT0YPEnone
  () = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
in
  $UN.cast{witht0ype} (p)
end // end of [witht0ype_WITHT0YPEnone]

implement
witht0ype_encode
  (v) =
(
case+ v of
| ~WITHT0YPEsome(a0, a1) => witht0ype_WITHT0YPEsome(a0, a1)
| ~WITHT0YPEnone() => witht0ype_WITHT0YPEnone()
) (* end of [witht0ype_encode] *)

implement
witht0ype_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
witht0ype_is_WITHT0YPEsome
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
witht0ype_is_WITHT0YPEnone
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
witht0ype_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 0)))
//
in
//
case+ tag of
| 0 => WITHT0YPEsome($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{s0exp} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| _ => WITHT0YPEnone()
//
end // end of [witht0ype_view]

implement
witht0ype_view_free
  (v) =
(
case+ v of
| ~WITHT0YPEsome(_, _) => ()
| ~WITHT0YPEnone() => ()
) (* end of [witht0ype_view_free] *)

(* ****** ****** *)

implement
q0marg_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{q0marg} (p)
end // end of [q0marg_new]

implement
q0marg_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
q0marg_arg
  (x) = $UN.cast{s0qualst} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
a0typ_new
  (a0, a1, a2) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{a0typ} (p)
end // end of [a0typ_new]

implement
a0typ_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
a0typ_sym
  (x) = $UN.cast{symbolopt} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
a0typ_typ
  (x) = $UN.cast{s0exp} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
d0cstarg_node_D0CSTARGsta
  (a0) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0cstarg_node} (p)
end // end of [d0cstarg_node_D0CSTARGsta]

implement
d0cstarg_node_D0CSTARGdyn
  (a0, a1) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0cstarg_node} (p)
end // end of [d0cstarg_node_D0CSTARGdyn]

implement
d0cstarg_node_encode
  (v) =
(
case+ v of
| ~D0CSTARGsta(a0) => d0cstarg_node_D0CSTARGsta(a0)
| ~D0CSTARGdyn(a0, a1) => d0cstarg_node_D0CSTARGdyn(a0, a1)
) (* end of [d0cstarg_node_encode] *)

implement
d0cstarg_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
d0cstarg_node_is_D0CSTARGsta
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
d0cstarg_node_is_D0CSTARGdyn
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
d0cstarg_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 0)))
//
in
//
case+ tag of
| 0 => D0CSTARGsta($UN.cast{s0qualst} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| _ => D0CSTARGdyn($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{a0typlst} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
//
end // end of [d0cstarg_node_view]

implement
d0cstarg_node_view_free
  (v) =
(
case+ v of
| ~D0CSTARGsta(_) => ()
| ~D0CSTARGdyn(_, _) => ()
) (* end of [d0cstarg_node_view_free] *)

(* ****** ****** *)

implement
d0cstarg_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0cstarg} (p)
end // end of [d0cstarg_new]

implement
d0cstarg_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
d0cstarg_node
  (x) = $UN.cast{d0cstarg_node} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
s0vararg_S0VARARGone
  (a0) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s0vararg} (p)
end // end of [s0vararg_S0VARARGone]

implement
s0vararg_S0VARARGall
  (a0) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s0vararg} (p)
end // end of [s0vararg_S0VARARGall]

implement
s0vararg_S0VARARGseq
  (a0, a1) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s0vararg} (p)
end // end of [s0vararg_S0VARARGseq]

implement
s0vararg_encode
  (v) =
(
case+ v of
| ~S0VARARGone(a0) => s0vararg_S0VARARGone(a0)
| ~S0VARARGall(a0) => s0vararg_S0VARARGall(a0)
| ~S0VARARGseq(a0, a1) => s0vararg_S0VARARGseq(a0, a1)
) (* end of [s0vararg_encode] *)

implement
s0vararg_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
s0vararg_is_S0VARARGone
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
s0vararg_is_S0VARARGall
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
s0vararg_is_S0VARARGseq
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
s0vararg_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 0)))
//
in
//
case+ tag of
| 0 => S0VARARGone($UN.cast{token} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 1 => S0VARARGall($UN.cast{token} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| _ => S0VARARGseq($UN.cast{location} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{s0arglst} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
//
end // end of [s0vararg_view]

implement
s0vararg_view_free
  (v) =
(
case+ v of
| ~S0VARARGone(_) => ()
| ~S0VARARGall(_) => ()
| ~S0VARARGseq(_, _) => ()
) (* end of [s0vararg_view_free] *)

(* ****** ****** *)

implement
s0exparg_S0EXPARGone
  () = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
in
  $UN.cast{s0exparg} (p)
end // end of [s0exparg_S0EXPARGone]

implement
s0exparg_S0EXPARGall
  () = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
in
  $UN.cast{s0exparg} (p)
end // end of [s0exparg_S0EXPARGall]

implement
s0exparg_S0EXPARGseq
  (a0) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{s0exparg} (p)
end // end of [s0exparg_S0EXPARGseq]

implement
s0exparg_encode
  (v) =
(
case+ v of
| ~S0EXPARGone() => s0exparg_S0EXPARGone()
| ~S0EXPARGall() => s0exparg_S0EXPARGall()
| ~S0EXPARGseq(a0) => s0exparg_S0EXPARGseq(a0)
) (* end of [s0exparg_encode] *)

implement
s0exparg_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
s0exparg_is_S0EXPARGone
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
s0exparg_is_S0EXPARGall
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
s0exparg_is_S0EXPARGseq
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
s0exparg_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 0)))
//
in
//
case+ tag of
| 0 => S0EXPARGone()
| 1 => S0EXPARGall()
| _ => S0EXPARGseq($UN.cast{s0explst} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
//
end // end of [s0exparg_view]

implement
s0exparg_view_free
  (v) =
(
case+ v of
| ~S0EXPARGone() => ()
| ~S0EXPARGall() => ()
| ~S0EXPARGseq(_) => ()
) (* end of [s0exparg_view_free] *)

(* ****** ****** *)

implement
m0acarg_node_M0ACARGdyn
  (a0) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{m0acarg_node} (p)
end // end of [m0acarg_node_M0ACARGdyn]

implement
m0acarg_node_M0ACARGsta
  (a0) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{m0acarg_node} (p)
end // end of [m0acarg_node_M0ACARGsta]

implement
m0acarg_node_encode
  (v) =
(
case+ v of
| ~M0ACARGdyn(a0) => m0acarg_node_M0ACARGdyn(a0)
| ~M0ACARGsta(a0) => m0acarg_node_M0ACARGsta(a0)
) (* end of [m0acarg_node_encode] *)

implement
m0acarg_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
m0acarg_node_is_M0ACARGdyn
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
m0acarg_node_is_M0ACARGsta
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
m0acarg_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 0)))
//
in
//
case+ tag of
| 0 => M0ACARGdyn($UN.cast{i0delst} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| _ => M0ACARGsta($UN.cast{s0arglst} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
//
end // end of [m0acarg_node_view]

implement
m0acarg_node_view_free
  (v) =
(
case+ v of
| ~M0ACARGdyn(_) => ()
| ~M0ACARGsta(_) => ()
) (* end of [m0acarg_node_view_free] *)

(* ****** ****** *)

implement
m0acarg_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{m0acarg} (p)
end // end of [m0acarg_new]

implement
m0acarg_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
m0acarg_node
  (x) = $UN.cast{m0acarg_node} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
s0rtdef_new
  (a0, a1, a2) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{s0rtdef} (p)
end // end of [s0rtdef_new]

implement
s0rtdef_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
s0rtdef_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
s0rtdef_def
  (x) = $UN.cast{s0rtext} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
scstextdef_SCSTEXTDEFnone
  () = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
in
  $UN.cast{scstextdef} (p)
end // end of [scstextdef_SCSTEXTDEFnone]

implement
scstextdef_SCSTEXTDEFsome
  (a0) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{scstextdef} (p)
end // end of [scstextdef_SCSTEXTDEFsome]

implement
scstextdef_encode
  (v) =
(
case+ v of
| ~SCSTEXTDEFnone() => scstextdef_SCSTEXTDEFnone()
| ~SCSTEXTDEFsome(a0) => scstextdef_SCSTEXTDEFsome(a0)
) (* end of [scstextdef_encode] *)

implement
scstextdef_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
scstextdef_is_SCSTEXTDEFnone
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
scstextdef_is_SCSTEXTDEFsome
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
scstextdef_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 0)))
//
in
//
case+ tag of
| 0 => SCSTEXTDEFnone()
| _ => SCSTEXTDEFsome($UN.cast{string} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
//
end // end of [scstextdef_view]

implement
scstextdef_view_free
  (v) =
(
case+ v of
| ~SCSTEXTDEFnone() => ()
| ~SCSTEXTDEFsome(_) => ()
) (* end of [scstextdef_view_free] *)

(* ****** ****** *)

implement
s0tacst_new
  (a0, a1, a2, a3, a4) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_syntax_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a4)))
in
  $UN.cast{s0tacst} (p)
end // end of [s0tacst_new]

implement
s0tacst_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
s0tacst_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
s0tacst_arg
  (x) = $UN.cast{a0msrtlst} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

implement
s0tacst_res
  (x) = $UN.cast{s0rt} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 24)))

implement
s0tacst_extopt
  (x) = $UN.cast{s0tringopt} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 32)))

(* ****** ****** *)

implement
s0tacon_new
  (a0, a1, a2, a3) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{s0tacon} (p)
end // end of [s0tacon_new]

implement
s0tacon_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
s0tacon_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
s0tacon_arg
  (x) = $UN.cast{a0msrtlst} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

implement
s0tacon_def
  (x) = $UN.cast{s0expopt} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 24)))

(* ****** ****** *)

implement
t0kindef_new
  (a0, a1, a2, a3) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{t0kindef} (p)
end // end of [t0kindef_new]

implement
t0kindef_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
t0kindef_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
t0kindef_loc_id
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

implement
t0kindef_def
  (x) = $UN.cast{s0exp} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 24)))

(* ****** ****** *)

implement
s0expdef_new
  (a0, a1, a2, a3, a4, a5) = let
val p = pats_syntax_alloc (48)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_syntax_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a4)))
val () = pats_syntax_st (p, 40, $UN.cast{ptr} ($UN.cast{lint} (a5)))
in
  $UN.cast{s0expdef} (p)
end // end of [s0expdef_new]

implement
s0expdef_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
s0expdef_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
s0expdef_loc_id
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

implement
s0expdef_arg
  (x) = $UN.cast{s0marglst} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 24)))

implement
s0expdef_res
  (x) = $UN.cast{s0rtopt} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 32)))

implement
s0expdef_def
  (x) = $UN.cast{s0exp} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 40)))

(* ****** ****** *)

implement
s0aspdec_new
  (a0, a1, a2, a3, a4) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_syntax_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a4)))
in
  $UN.cast{s0aspdec} (p)
end // end of [s0aspdec_new]

implement
s0aspdec_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
s0aspdec_qid
  (x) = $UN.cast{sqi0de} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
s0aspdec_arg
  (x) = $UN.cast{s0marglst} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

implement
s0aspdec_res
  (x) = $UN.cast{s0rtopt} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 24)))

implement
s0aspdec_def
  (x) = $UN.cast{s0exp} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 32)))

(* ****** ****** *)

implement
e0xndec_new
  (a0, a1, a2, a3, a4) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_syntax_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a4)))
in
  $UN.cast{e0xndec} (p)
end // end of [e0xndec_new]

implement
e0xndec_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
e0xndec_fil
  (x) = $UN.cast{filename} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
e0xndec_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

implement
e0xndec_qua
  (x) = $UN.cast{q0marglst} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 24)))

implement
e0xndec_arg
  (x) = $UN.cast{s0expopt} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 32)))

(* ****** ****** *)

implement
d0atcon_new
  (a0, a1, a2, a3, a4) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_syntax_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a4)))
in
  $UN.cast{d0atcon} (p)
end // end of [d0atcon_new]

implement
d0atcon_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
d0atcon_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
d0atcon_qua
  (x) = $UN.cast{q0marglst} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

implement
d0atcon_arg
  (x) = $UN.cast{s0expopt} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 24)))

implement
d0atcon_ind
  (x) = $UN.cast{s0expopt} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 32)))

(* ****** ****** *)

implement
d0atdec_new
  (a0, a1, a2, a3, a4, a5) = let
val p = pats_syntax_alloc (48)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_syntax_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a4)))
val () = pats_syntax_st (p, 40, $UN.cast{ptr} ($UN.cast{lint} (a5)))
in
  $UN.cast{d0atdec} (p)
end // end of [d0atdec_new]

implement
d0atdec_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
d0atdec_loc_hd
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
d0atdec_fil
  (x) = $UN.cast{filename} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

implement
d0atdec_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 24)))

implement
d0atdec_arg
  (x) = $UN.cast{a0msrtlst} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 32)))

implement
d0atdec_con
  (x) = $UN.cast{d0atconlst} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 40)))

(* ****** ****** *)

implement
dcstextdef_DCSTEXTDEFnone
  (a0) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{dcstextdef} (p)
end // end of [dcstextdef_DCSTEXTDEFnone]

implement
dcstextdef_DCSTEXTDEFsome_ext
  (a0) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{dcstextdef} (p)
end // end of [dcstextdef_DCSTEXTDEFsome_ext]

implement
dcstextdef_DCSTEXTDEFsome_mac
  (a0) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{dcstextdef} (p)
end // end of [dcstextdef_DCSTEXTDEFsome_mac]

implement
dcstextdef_DCSTEXTDEFsome_sta
  (a0) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (3)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{dcstextdef} (p)
end // end of [dcstextdef_DCSTEXTDEFsome_sta]

implement
dcstextdef_encode
  (v) =
(
case+ v of
| ~DCSTEXTDEFnone(a0) => dcstextdef_DCSTEXTDEFnone(a0)
| ~DCSTEXTDEFsome_ext(a0) => dcstextdef_DCSTEXTDEFsome_ext(a0)
| ~DCSTEXTDEFsome_mac(a0) => dcstextdef_DCSTEXTDEFsome_mac(a0)
| ~DCSTEXTDEFsome_sta(a0) => dcstextdef_DCSTEXTDEFsome_sta(a0)
) (* end of [dcstextdef_encode] *)

implement
dcstextdef_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
dcstextdef_is_DCSTEXTDEFnone
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
dcstextdef_is_DCSTEXTDEFsome_ext
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
dcstextdef_is_DCSTEXTDEFsome_mac
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
dcstextdef_is_DCSTEXTDEFsome_sta
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 3)

implement
dcstextdef_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 0)))
//
in
//
case+ tag of
| 0 => DCSTEXTDEFnone($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 1 => DCSTEXTDEFsome_ext($UN.cast{string} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 2 => DCSTEXTDEFsome_mac($UN.cast{string} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| _ => DCSTEXTDEFsome_sta($UN.cast{string} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
//
end // end of [dcstextdef_view]

implement
dcstextdef_view_free
  (v) =
(
case+ v of
| ~DCSTEXTDEFnone(_) => ()
| ~DCSTEXTDEFsome_ext(_) => ()
| ~DCSTEXTDEFsome_mac(_) => ()
| ~DCSTEXTDEFsome_sta(_) => ()
) (* end of [dcstextdef_view_free] *)

(* ****** ****** *)

implement
d0cstdec_new
  (a0, a1, a2, a3, a4, a5, a6) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_syntax_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a4)))
val () = pats_syntax_st (p, 40, $UN.cast{ptr} ($UN.cast{lint} (a5)))
val () = pats_syntax_st (p, 48, $UN.cast{ptr} ($UN.cast{lint} (a6)))
in
  $UN.cast{d0cstdec} (p)
end // end of [d0cstdec_new]

implement
d0cstdec_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
d0cstdec_fil
  (x) = $UN.cast{filename} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
d0cstdec_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

implement
d0cstdec_arg
  (x) = $UN.cast{d0cstarglst} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 24)))

implement
d0cstdec_eff
  (x) = $UN.cast{e0fftaglstopt} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 32)))

implement
d0cstdec_res
  (x) = $UN.cast{s0exp} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 40)))

implement
d0cstdec_extopt
  (x) = $UN.cast{s0tringopt} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 48)))

(* ****** ****** *)

implement
p0at_node_P0Tide
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{p0at_node} (p)
end // end of [p0at_node_P0Tide]

implement
p0at_node_P0Tdqid
  (a0, a1) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{p0at_node} (p)
end // end of [p0at_node_P0Tdqid]

implement
p0at_node_P0Topid
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{p0at_node} (p)
end // end of [p0at_node_P0Topid]

implement
p0at_node_P0Tint
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (3)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{p0at_node} (p)
end // end of [p0at_node_P0Tint]

implement
p0at_node_P0Tchar
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (4)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{p0at_node} (p)
end // end of [p0at_node_P0Tchar]

implement
p0at_node_P0Tfloat
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (5)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{p0at_node} (p)
end // end of [p0at_node_P0Tfloat]

implement
p0at_node_P0Tstring
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (6)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{p0at_node} (p)
end // end of [p0at_node_P0Tstring]

implement
p0at_node_P0Tapp
  (a0, a1) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (7)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{p0at_node} (p)
end // end of [p0at_node_P0Tapp]

implement
p0at_node_P0Tlist
  (a0, a1) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (8)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{p0at_node} (p)
end // end of [p0at_node_P0Tlist]

implement
p0at_node_P0Tlst
  (a0, a1) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (9)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{p0at_node} (p)
end // end of [p0at_node_P0Tlst]

implement
p0at_node_P0Ttup
  (a0, a1, a2) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (10)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{p0at_node} (p)
end // end of [p0at_node_P0Ttup]

implement
p0at_node_P0Trec
  (a0, a1, a2) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (11)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{p0at_node} (p)
end // end of [p0at_node_P0Trec]

implement
p0at_node_P0Tfree
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (12)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{p0at_node} (p)
end // end of [p0at_node_P0Tfree]

implement
p0at_node_P0Tunfold
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (13)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{p0at_node} (p)
end // end of [p0at_node_P0Tunfold]

implement
p0at_node_P0Texist
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (14)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{p0at_node} (p)
end // end of [p0at_node_P0Texist]

implement
p0at_node_P0Tsvararg
  (a0) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (15)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{p0at_node} (p)
end // end of [p0at_node_P0Tsvararg]

implement
p0at_node_P0Trefas
  (a0, a1, a2) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (16)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{p0at_node} (p)
end // end of [p0at_node_P0Trefas]

implement
p0at_node_P0Tann
  (a0, a1) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (17)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{p0at_node} (p)
end // end of [p0at_node_P0Tann]

implement
p0at_node_P0Terr
  () = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (18)))
in
  $UN.cast{p0at_node} (p)
end // end of [p0at_node_P0Terr]

implement
p0at_node_encode
  (v) =
(
case+ v of
| ~P0Tide(a0) => p0at_node_P0Tide(a0)
| ~P0Tdqid(a0, a1) => p0at_node_P0Tdqid(a0, a1)
| ~P0Topid(a0) => p0at_node_P0Topid(a0)
| ~P0Tint(a0) => p0at_node_P0Tint(a0)
| ~P0Tchar(a0) => p0at_node_P0Tchar(a0)
| ~P0Tfloat(a0) => p0at_node_P0Tfloat(a0)
| ~P0Tstring(a0) => p0at_node_P0Tstring(a0)
| ~P0Tapp(a0, a1) => p0at_node_P0Tapp(a0, a1)
| ~P0Tlist(a0, a1) => p0at_node_P0Tlist(a0, a1)
| ~P0Tlst(a0, a1) => p0at_node_P0Tlst(a0, a1)
| ~P0Ttup(a0, a1, a2) => p0at_node_P0Ttup(a0, a1, a2)
| ~P0Trec(a0, a1, a2) => p0at_node_P0Trec(a0, a1, a2)
| ~P0Tfree(a0) => p0at_node_P0Tfree(a0)
| ~P0Tunfold(a0) => p0at_node_P0Tunfold(a0)
| ~P0Texist(a0) => p0at_node_P0Texist(a0)
| ~P0Tsvararg(a0) => p0at_node_P0Tsvararg(a0)
| ~P0Trefas(a0, a1, a2) => p0at_node_P0Trefas(a0, a1, a2)
| ~P0Tann(a0, a1) => p0at_node_P0Tann(a0, a1)
| ~P0Terr() => p0at_node_P0Terr()
) (* end of [p0at_node_encode] *)

implement
p0at_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
p0at_node_is_P0Tide
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
p0at_node_is_P0Tdqid
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
p0at_node_is_P0Topid
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
p0at_node_is_P0Tint
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 3)

implement
p0at_node_is_P0Tchar
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 4)

implement
p0at_node_is_P0Tfloat
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 5)

implement
p0at_node_is_P0Tstring
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 6)

implement
p0at_node_is_P0Tapp
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 7)

implement
p0at_node_is_P0Tlist
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 8)

implement
p0at_node_is_P0Tlst
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 9)

implement
p0at_node_is_P0Ttup
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 10)

implement
p0at_node_is_P0Trec
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 11)

implement
p0at_node_is_P0Tfree
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 12)

implement
p0at_node_is_P0Tunfold
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 13)

implement
p0at_node_is_P0Texist
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 14)

implement
p0at_node_is_P0Tsvararg
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 15)

implement
p0at_node_is_P0Trefas
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 16)

implement
p0at_node_is_P0Tann
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 17)

implement
p0at_node_is_P0Terr
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 18)

implement
p0at_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 0)))
//
in
//
case+ tag of
| 0 => P0Tide($UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 1 => P0Tdqid($UN.cast{d0ynq} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 2 => P0Topid($UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 3 => P0Tint($UN.cast{i0nt} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 4 => P0Tchar($UN.cast{c0har} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 5 => P0Tfloat($UN.cast{f0loat} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 6 => P0Tstring($UN.cast{s0tring} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 7 => P0Tapp($UN.cast{p0at} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{p0at} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 8 => P0Tlist($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{p0atlst} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 9 => P0Tlst($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{p0atlst} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 10 => P0Ttup($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{p0atlst} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
| 11 => P0Trec($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{labp0atlst} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
| 12 => P0Tfree($UN.cast{p0at} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 13 => P0Tunfold($UN.cast{p0at} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 14 => P0Texist($UN.cast{s0arglst} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 15 => P0Tsvararg($UN.cast{s0vararg} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 16 => P0Trefas($UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{p0at} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
| 17 => P0Tann($UN.cast{p0at} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{s0exp} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| _ => P0Terr()
//
end // end of [p0at_node_view]

implement
p0at_node_view_free
  (v) =
(
case+ v of
| ~P0Tide(_) => ()
| ~P0Tdqid(_, _) => ()
| ~P0Topid(_) => ()
| ~P0Tint(_) => ()
| ~P0Tchar(_) => ()
| ~P0Tfloat(_) => ()
| ~P0Tstring(_) => ()
| ~P0Tapp(_, _) => ()
| ~P0Tlist(_, _) => ()
| ~P0Tlst(_, _) => ()
| ~P0Ttup(_, _, _) => ()
| ~P0Trec(_, _, _) => ()
| ~P0Tfree(_) => ()
| ~P0Tunfold(_) => ()
| ~P0Texist(_) => ()
| ~P0Tsvararg(_) => ()
| ~P0Trefas(_, _, _) => ()
| ~P0Tann(_, _) => ()
| ~P0Terr() => ()
) (* end of [p0at_node_view_free] *)

(* ****** ****** *)

implement
labp0at_node_LABP0ATnorm
  (a0, a1) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{labp0at_node} (p)
end // end of [labp0at_node_LABP0ATnorm]

implement
labp0at_node_LABP0ATomit
  () = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
in
  $UN.cast{labp0at_node} (p)
end // end of [labp0at_node_LABP0ATomit]

implement
labp0at_node_encode
  (v) =
(
case+ v of
| ~LABP0ATnorm(a0, a1) => labp0at_node_LABP0ATnorm(a0, a1)
| ~LABP0ATomit() => labp0at_node_LABP0ATomit()
) (* end of [labp0at_node_encode] *)

implement
labp0at_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
labp0at_node_is_LABP0ATnorm
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
labp0at_node_is_LABP0ATomit
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
labp0at_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 0)))
//
in
//
case+ tag of
| 0 => LABP0ATnorm($UN.cast{l0ab} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{p0at} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| _ => LABP0ATomit()
//
end // end of [labp0at_node_view]

implement
labp0at_node_view_free
  (v) =
(
case+ v of
| ~LABP0ATnorm(_, _) => ()
| ~LABP0ATomit() => ()
) (* end of [labp0at_node_view_free] *)

(* ****** ****** *)

implement
p0at_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{p0at} (p)
end // end of [p0at_new]

implement
p0at_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
p0at_node
  (x) = $UN.cast{p0at_node} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
labp0at_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{labp0at} (p)
end // end of [labp0at_new]

implement
labp0at_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
labp0at_node
  (x) = $UN.cast{labp0at_node} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
i0mparg_I0MPARG_sarglst
  (a0) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{i0mparg} (p)
end // end of [i0mparg_I0MPARG_sarglst]

implement
i0mparg_I0MPARG_svararglst
  (a0) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{i0mparg} (p)
end // end of [i0mparg_I0MPARG_svararglst]

implement
i0mparg_encode
  (v) =
(
case+ v of
| ~I0MPARG_sarglst(a0) => i0mparg_I0MPARG_sarglst(a0)
| ~I0MPARG_svararglst(a0) => i0mparg_I0MPARG_svararglst(a0)
) (* end of [i0mparg_encode] *)

implement
i0mparg_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
i0mparg_is_I0MPARG_sarglst
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
i0mparg_is_I0MPARG_svararglst
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
i0mparg_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 0)))
//
in
//
case+ tag of
| 0 => I0MPARG_sarglst($UN.cast{s0arglst} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| _ => I0MPARG_svararglst($UN.cast{s0vararglst} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
//
end // end of [i0mparg_view]

implement
i0mparg_view_free
  (v) =
(
case+ v of
| ~I0MPARG_sarglst(_) => ()
| ~I0MPARG_svararglst(_) => ()
) (* end of [i0mparg_view_free] *)

(* ****** ****** *)

implement
t0mpmarg_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{t0mpmarg} (p)
end // end of [t0mpmarg_new]

implement
t0mpmarg_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
t0mpmarg_arg
  (x) = $UN.cast{s0explst} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
impqi0de_new
  (a0, a1, a2, a3) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{impqi0de} (p)
end // end of [impqi0de_new]

implement
impqi0de_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
impqi0de_qua
  (x) = $UN.cast{d0ynq} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
impqi0de_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

implement
impqi0de_arg
  (x) = $UN.cast{t0mpmarglst} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 24)))

(* ****** ****** *)

implement
f0arg_node_F0ARGdyn
  (a0) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{f0arg_node} (p)
end // end of [f0arg_node_F0ARGdyn]

implement
f0arg_node_F0ARGsta1
  (a0) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{f0arg_node} (p)
end // end of [f0arg_node_F0ARGsta1]

implement
f0arg_node_F0ARGsta2
  (a0) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{f0arg_node} (p)
end // end of [f0arg_node_F0ARGsta2]

implement
f0arg_node_F0ARGmet3
  (a0) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (3)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{f0arg_node} (p)
end // end of [f0arg_node_F0ARGmet3]

implement
f0arg_node_encode
  (v) =
(
case+ v of
| ~F0ARGdyn(a0) => f0arg_node_F0ARGdyn(a0)
| ~F0ARGsta1(a0) => f0arg_node_F0ARGsta1(a0)
| ~F0ARGsta2(a0) => f0arg_node_F0ARGsta2(a0)
| ~F0ARGmet3(a0) => f0arg_node_F0ARGmet3(a0)
) (* end of [f0arg_node_encode] *)

implement
f0arg_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
f0arg_node_is_F0ARGdyn
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
f0arg_node_is_F0ARGsta1
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
f0arg_node_is_F0ARGsta2
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
f0arg_node_is_F0ARGmet3
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 3)

implement
f0arg_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 0)))
//
in
//
case+ tag of
| 0 => F0ARGdyn($UN.cast{p0at} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 1 => F0ARGsta1($UN.cast{s0qualst} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 2 => F0ARGsta2($UN.cast{s0vararg} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| _ => F0ARGmet3($UN.cast{s0explst} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
//
end // end of [f0arg_node_view]

implement
f0arg_node_view_free
  (v) =
(
case+ v of
| ~F0ARGdyn(_) => ()
| ~F0ARGsta1(_) => ()
| ~F0ARGsta2(_) => ()
| ~F0ARGmet3(_) => ()
) (* end of [f0arg_node_view_free] *)

(* ****** ****** *)

implement
f0arg_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{f0arg} (p)
end // end of [f0arg_new]

implement
f0arg_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
f0arg_node
  (x) = $UN.cast{f0arg_node} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
s0elop_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{s0elop} (p)
end // end of [s0elop_new]

implement
s0elop_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
s0elop_knd
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
i0nvarg_new
  (a0, a1, a2) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{i0nvarg} (p)
end // end of [i0nvarg_new]

implement
i0nvarg_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
i0nvarg_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
i0nvarg_typ
  (x) = $UN.cast{s0expopt} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
i0nvresstate_new
  (a0, a1, a2) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{i0nvresstate} (p)
end // end of [i0nvresstate_new]

implement
i0nvresstate_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
i0nvresstate_qua
  (x) = $UN.cast{s0qualstopt} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
i0nvresstate_arg
  (x) = $UN.cast{i0nvarglst} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
loopi0nv_new
  (a0, a1, a2, a3) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{loopi0nv} (p)
end // end of [loopi0nv_new]

implement
loopi0nv_qua
  (x) = $UN.cast{s0qualstopt} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
loopi0nv_met
  (x) = $UN.cast{s0explstopt} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
loopi0nv_arg
  (x) = $UN.cast{i0nvarglst} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

implement
loopi0nv_res
  (x) = $UN.cast{i0nvresstate} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 24)))

(* ****** ****** *)

implement
d0ecl_node_D0Cfixity
  (a0, a1) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Cfixity]

implement
d0ecl_node_D0Cnonfix
  (a0) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Cnonfix]

implement
d0ecl_node_D0Csymintr
  (a0) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Csymintr]

implement
d0ecl_node_D0Csymelim
  (a0) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (3)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Csymelim]

implement
d0ecl_node_D0Coverload
  (a0, a1, a2) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (4)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Coverload]

implement
d0ecl_node_D0Ce0xpdef
  (a0, a1) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (5)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Ce0xpdef]

implement
d0ecl_node_D0Ce0xpundef
  (a0) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (6)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Ce0xpundef]

implement
d0ecl_node_D0Ce0xpact
  (a0, a1) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (7)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Ce0xpact]

implement
d0ecl_node_D0Cpragma
  (a0) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (8)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Cpragma]

implement
d0ecl_node_D0Ccodegen
  (a0, a1) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (9)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Ccodegen]

implement
d0ecl_node_D0Cdatsrts
  (a0) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (10)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Cdatsrts]

implement
d0ecl_node_D0Csrtdefs
  (a0) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (11)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Csrtdefs]

implement
d0ecl_node_D0Cstacsts
  (a0) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (12)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Cstacsts]

implement
d0ecl_node_D0Cstacons
  (a0, a1) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (13)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Cstacons]

implement
d0ecl_node_D0Ctkindef
  (a0) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (14)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Ctkindef]

implement
d0ecl_node_D0Csexpdefs
  (a0, a1) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (15)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Csexpdefs]

implement
d0ecl_node_D0Csaspdec
  (a0) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (16)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Csaspdec]

implement
d0ecl_node_D0Creassume
  (a0) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (17)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Creassume]

implement
d0ecl_node_D0Cexndecs
  (a0) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (18)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Cexndecs]

implement
d0ecl_node_D0Cdatdecs
  (a0, a1, a2) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (19)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Cdatdecs]

implement
d0ecl_node_D0Cclassdec
  (a0, a1) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (20)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Cclassdec]

implement
d0ecl_node_D0Cextype
  (a0, a1) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (21)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Cextype]

implement
d0ecl_node_D0Cextype2
  (a0, a1, a2) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (22)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Cextype2]

implement
d0ecl_node_D0Cextvar
  (a0, a1) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (23)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Cextvar]

implement
d0ecl_node_D0Cextcode
  (a0, a1, a2) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (24)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Cextcode]

implement
d0ecl_node_D0Cdcstdecs
  (a0, a1, a2, a3) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (25)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_syntax_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Cdcstdecs]

implement
d0ecl_node_D0Cimpdec
  (a0, a1, a2) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (26)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Cimpdec]

implement
d0ecl_node_D0Cmacdefs
  (a0, a1, a2) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (27)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Cmacdefs]

implement
d0ecl_node_D0Cfundecs
  (a0, a1, a2) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (28)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Cfundecs]

implement
d0ecl_node_D0Cvaldecs
  (a0, a1, a2) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (29)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Cvaldecs]

implement
d0ecl_node_D0Cvardecs
  (a0, a1) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (30)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Cvardecs]

implement
d0ecl_node_D0Cinclude
  (a0, a1, a2) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (31)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Cinclude]

implement
d0ecl_node_D0Cstaload
  (a0, a1, a2) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (32)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Cstaload]

implement
d0ecl_node_D0Cstaloadnm
  (a0, a1, a2) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (33)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Cstaloadnm]

implement
d0ecl_node_D0Cstaloadloc
  (a0, a1, a2) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (34)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Cstaloadloc]

implement
d0ecl_node_D0Crequire
  (a0, a1) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (35)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Crequire]

implement
d0ecl_node_D0Cdynload
  (a0, a1) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (36)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Cdynload]

implement
d0ecl_node_D0Clocal
  (a0, a1) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (37)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Clocal]

implement
d0ecl_node_D0Cguadecl
  (a0, a1) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (38)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0ecl_node} (p)
end // end of [d0ecl_node_D0Cguadecl]

implement
d0ecl_node_encode
  (v) =
(
case+ v of
| ~D0Cfixity(a0, a1) => d0ecl_node_D0Cfixity(a0, a1)
| ~D0Cnonfix(a0) => d0ecl_node_D0Cnonfix(a0)
| ~D0Csymintr(a0) => d0ecl_node_D0Csymintr(a0)
| ~D0Csymelim(a0) => d0ecl_node_D0Csymelim(a0)
| ~D0Coverload(a0, a1, a2) => d0ecl_node_D0Coverload(a0, a1, a2)
| ~D0Ce0xpdef(a0, a1) => d0ecl_node_D0Ce0xpdef(a0, a1)
| ~D0Ce0xpundef(a0) => d0ecl_node_D0Ce0xpundef(a0)
| ~D0Ce0xpact(a0, a1) => d0ecl_node_D0Ce0xpact(a0, a1)
| ~D0Cpragma(a0) => d0ecl_node_D0Cpragma(a0)
| ~D0Ccodegen(a0, a1) => d0ecl_node_D0Ccodegen(a0, a1)
| ~D0Cdatsrts(a0) => d0ecl_node_D0Cdatsrts(a0)
| ~D0Csrtdefs(a0) => d0ecl_node_D0Csrtdefs(a0)
| ~D0Cstacsts(a0) => d0ecl_node_D0Cstacsts(a0)
| ~D0Cstacons(a0, a1) => d0ecl_node_D0Cstacons(a0, a1)
| ~D0Ctkindef(a0) => d0ecl_node_D0Ctkindef(a0)
| ~D0Csexpdefs(a0, a1) => d0ecl_node_D0Csexpdefs(a0, a1)
| ~D0Csaspdec(a0) => d0ecl_node_D0Csaspdec(a0)
| ~D0Creassume(a0) => d0ecl_node_D0Creassume(a0)
| ~D0Cexndecs(a0) => d0ecl_node_D0Cexndecs(a0)
| ~D0Cdatdecs(a0, a1, a2) => d0ecl_node_D0Cdatdecs(a0, a1, a2)
| ~D0Cclassdec(a0, a1) => d0ecl_node_D0Cclassdec(a0, a1)
| ~D0Cextype(a0, a1) => d0ecl_node_D0Cextype(a0, a1)
| ~D0Cextype2(a0, a1, a2) => d0ecl_node_D0Cextype2(a0, a1, a2)
| ~D0Cextvar(a0, a1) => d0ecl_node_D0Cextvar(a0, a1)
| ~D0Cextcode(a0, a1, a2) => d0ecl_node_D0Cextcode(a0, a1, a2)
| ~D0Cdcstdecs(a0, a1, a2, a3) => d0ecl_node_D0Cdcstdecs(a0, a1, a2, a3)
| ~D0Cimpdec(a0, a1, a2) => d0ecl_node_D0Cimpdec(a0, a1, a2)
| ~D0Cmacdefs(a0, a1, a2) => d0ecl_node_D0Cmacdefs(a0, a1, a2)
| ~D0Cfundecs(a0, a1, a2) => d0ecl_node_D0Cfundecs(a0, a1, a2)
| ~D0Cvaldecs(a0, a1, a2) => d0ecl_node_D0Cvaldecs(a0, a1, a2)
| ~D0Cvardecs(a0, a1) => d0ecl_node_D0Cvardecs(a0, a1)
| ~D0Cinclude(a0, a1, a2) => d0ecl_node_D0Cinclude(a0, a1, a2)
| ~D0Cstaload(a0, a1, a2) => d0ecl_node_D0Cstaload(a0, a1, a2)
| ~D0Cstaloadnm(a0, a1, a2) => d0ecl_node_D0Cstaloadnm(a0, a1, a2)
| ~D0Cstaloadloc(a0, a1, a2) => d0ecl_node_D0Cstaloadloc(a0, a1, a2)
| ~D0Crequire(a0, a1) => d0ecl_node_D0Crequire(a0, a1)
| ~D0Cdynload(a0, a1) => d0ecl_node_D0Cdynload(a0, a1)
| ~D0Clocal(a0, a1) => d0ecl_node_D0Clocal(a0, a1)
| ~D0Cguadecl(a0, a1) => d0ecl_node_D0Cguadecl(a0, a1)
) (* end of [d0ecl_node_encode] *)

implement
d0ecl_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
d0ecl_node_is_D0Cfixity
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
d0ecl_node_is_D0Cnonfix
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
d0ecl_node_is_D0Csymintr
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
d0ecl_node_is_D0Csymelim
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 3)

implement
d0ecl_node_is_D0Coverload
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 4)

implement
d0ecl_node_is_D0Ce0xpdef
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 5)

implement
d0ecl_node_is_D0Ce0xpundef
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 6)

implement
d0ecl_node_is_D0Ce0xpact
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 7)

implement
d0ecl_node_is_D0Cpragma
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 8)

implement
d0ecl_node_is_D0Ccodegen
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 9)

implement
d0ecl_node_is_D0Cdatsrts
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 10)

implement
d0ecl_node_is_D0Csrtdefs
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 11)

implement
d0ecl_node_is_D0Cstacsts
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 12)

implement
d0ecl_node_is_D0Cstacons
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 13)

implement
d0ecl_node_is_D0Ctkindef
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 14)

implement
d0ecl_node_is_D0Csexpdefs
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 15)

implement
d0ecl_node_is_D0Csaspdec
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 16)

implement
d0ecl_node_is_D0Creassume
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 17)

implement
d0ecl_node_is_D0Cexndecs
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 18)

implement
d0ecl_node_is_D0Cdatdecs
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 19)

implement
d0ecl_node_is_D0Cclassdec
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 20)

implement
d0ecl_node_is_D0Cextype
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 21)

implement
d0ecl_node_is_D0Cextype2
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 22)

implement
d0ecl_node_is_D0Cextvar
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 23)

implement
d0ecl_node_is_D0Cextcode
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 24)

implement
d0ecl_node_is_D0Cdcstdecs
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 25)

implement
d0ecl_node_is_D0Cimpdec
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 26)

implement
d0ecl_node_is_D0Cmacdefs
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 27)

implement
d0ecl_node_is_D0Cfundecs
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 28)

implement
d0ecl_node_is_D0Cvaldecs
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 29)

implement
d0ecl_node_is_D0Cvardecs
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 30)

implement
d0ecl_node_is_D0Cinclude
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 31)

implement
d0ecl_node_is_D0Cstaload
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 32)

implement
d0ecl_node_is_D0Cstaloadnm
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 33)

implement
d0ecl_node_is_D0Cstaloadloc
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 34)

implement
d0ecl_node_is_D0Crequire
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 35)

implement
d0ecl_node_is_D0Cdynload
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 36)

implement
d0ecl_node_is_D0Clocal
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 37)

implement
d0ecl_node_is_D0Cguadecl
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 38)

implement
d0ecl_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 0)))
//
in
//
case+ tag of
| 0 => D0Cfixity($UN.cast{f0xty} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{i0delst} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 1 => D0Cnonfix($UN.cast{i0delst} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 2 => D0Csymintr($UN.cast{i0delst} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 3 => D0Csymelim($UN.cast{i0delst} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 4 => D0Coverload($UN.cast{i0de} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{dqi0de} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
| 5 => D0Ce0xpdef($UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{e0xpopt} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 6 => D0Ce0xpundef($UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 7 => D0Ce0xpact($UN.cast{e0xpactkind} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{e0xp} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 8 => D0Cpragma($UN.cast{e0xplst} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 9 => D0Ccodegen($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{e0xplst} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 10 => D0Cdatsrts($UN.cast{d0atsrtdeclst} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 11 => D0Csrtdefs($UN.cast{s0rtdeflst} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 12 => D0Cstacsts($UN.cast{s0tacstlst} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 13 => D0Cstacons($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{s0taconlst} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 14 => D0Ctkindef($UN.cast{t0kindef} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 15 => D0Csexpdefs($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{s0expdeflst} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 16 => D0Csaspdec($UN.cast{s0aspdec} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 17 => D0Creassume($UN.cast{sqi0de} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 18 => D0Cexndecs($UN.cast{e0xndeclst} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 19 => D0Cdatdecs($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{d0atdeclst} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{s0expdeflst} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
| 20 => D0Cclassdec($UN.cast{i0de} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{s0expopt} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 21 => D0Cextype($UN.cast{string} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{s0exp} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 22 => D0Cextype2($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{string} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{s0exp} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
| 23 => D0Cextvar($UN.cast{string} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 24 => D0Cextcode($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{string} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
| 25 => D0Cdcstdecs($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{token} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{q0marglst} ($UN.cast{lint} (pats_syntax_ld (p, 24))), $UN.cast{d0cstdeclst} ($UN.cast{lint} (pats_syntax_ld (p, 32))))
| 26 => D0Cimpdec($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{i0mparg} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{i0mpdec} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
| 27 => D0Cmacdefs($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{bool} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{m0acdeflst} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
| 28 => D0Cfundecs($UN.cast{funkind} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{q0marglst} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{f0undeclst} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
| 29 => D0Cvaldecs($UN.cast{valkind} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{bool} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{v0aldeclst} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
| 30 => D0Cvardecs($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{v0ardeclst} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 31 => D0Cinclude($UN.cast{filename} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{string} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
| 32 => D0Cstaload($UN.cast{filename} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{symbolopt} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{string} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
| 33 => D0Cstaloadnm($UN.cast{filename} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{symbolopt} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
| 34 => D0Cstaloadloc($UN.cast{filename} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{d0eclist} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
| 35 => D0Crequire($UN.cast{filename} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{string} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 36 => D0Cdynload($UN.cast{filename} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{string} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 37 => D0Clocal($UN.cast{d0eclist} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{d0eclist} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| _ => D0Cguadecl($UN.cast{srpifkind} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{guad0ecl} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
//
end // end of [d0ecl_node_view]

implement
d0ecl_node_view_free
  (v) =
(
case+ v of
| ~D0Cfixity(_, _) => ()
| ~D0Cnonfix(_) => ()
| ~D0Csymintr(_) => ()
| ~D0Csymelim(_) => ()
| ~D0Coverload(_, _, _) => ()
| ~D0Ce0xpdef(_, _) => ()
| ~D0Ce0xpundef(_) => ()
| ~D0Ce0xpact(_, _) => ()
| ~D0Cpragma(_) => ()
| ~D0Ccodegen(_, _) => ()
| ~D0Cdatsrts(_) => ()
| ~D0Csrtdefs(_) => ()
| ~D0Cstacsts(_) => ()
| ~D0Cstacons(_, _) => ()
| ~D0Ctkindef(_) => ()
| ~D0Csexpdefs(_, _) => ()
| ~D0Csaspdec(_) => ()
| ~D0Creassume(_) => ()
| ~D0Cexndecs(_) => ()
| ~D0Cdatdecs(_, _, _) => ()
| ~D0Cclassdec(_, _) => ()
| ~D0Cextype(_, _) => ()
| ~D0Cextype2(_, _, _) => ()
| ~D0Cextvar(_, _) => ()
| ~D0Cextcode(_, _, _) => ()
| ~D0Cdcstdecs(_, _, _, _) => ()
| ~D0Cimpdec(_, _, _) => ()
| ~D0Cmacdefs(_, _, _) => ()
| ~D0Cfundecs(_, _, _) => ()
| ~D0Cvaldecs(_, _, _) => ()
| ~D0Cvardecs(_, _) => ()
| ~D0Cinclude(_, _, _) => ()
| ~D0Cstaload(_, _, _) => ()
| ~D0Cstaloadnm(_, _, _) => ()
| ~D0Cstaloadloc(_, _, _) => ()
| ~D0Crequire(_, _) => ()
| ~D0Cdynload(_, _) => ()
| ~D0Clocal(_, _) => ()
| ~D0Cguadecl(_, _) => ()
) (* end of [d0ecl_node_view_free] *)

(* ****** ****** *)

implement
staloadarg_STLDfname
  (a0, a1) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{staloadarg} (p)
end // end of [staloadarg_STLDfname]

implement
staloadarg_STLDnspace
  (a0, a1) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{staloadarg} (p)
end // end of [staloadarg_STLDnspace]

implement
staloadarg_STLDdeclist
  (a0, a1) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{staloadarg} (p)
end // end of [staloadarg_STLDdeclist]

implement
staloadarg_encode
  (v) =
(
case+ v of
| ~STLDfname(a0, a1) => staloadarg_STLDfname(a0, a1)
| ~STLDnspace(a0, a1) => staloadarg_STLDnspace(a0, a1)
| ~STLDdeclist(a0, a1) => staloadarg_STLDdeclist(a0, a1)
) (* end of [staloadarg_encode] *)

implement
staloadarg_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
staloadarg_is_STLDfname
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
staloadarg_is_STLDnspace
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
staloadarg_is_STLDdeclist
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
staloadarg_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 0)))
//
in
//
case+ tag of
| 0 => STLDfname($UN.cast{location} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{string} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 1 => STLDnspace($UN.cast{location} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{string} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| _ => STLDdeclist($UN.cast{location} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{d0eclist} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
//
end // end of [staloadarg_view]

implement
staloadarg_view_free
  (v) =
(
case+ v of
| ~STLDfname(_, _) => ()
| ~STLDnspace(_, _) => ()
| ~STLDdeclist(_, _) => ()
) (* end of [staloadarg_view_free] *)

(* ****** ****** *)

implement
guad0ecl_node_GD0Cone
  (a0, a1) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{guad0ecl_node} (p)
end // end of [guad0ecl_node_GD0Cone]

implement
guad0ecl_node_GD0Ctwo
  (a0, a1, a2) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{guad0ecl_node} (p)
end // end of [guad0ecl_node_GD0Ctwo]

implement
guad0ecl_node_GD0Ccons
  (a0, a1, a2, a3) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_syntax_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{guad0ecl_node} (p)
end // end of [guad0ecl_node_GD0Ccons]

implement
guad0ecl_node_encode
  (v) =
(
case+ v of
| ~GD0Cone(a0, a1) => guad0ecl_node_GD0Cone(a0, a1)
| ~GD0Ctwo(a0, a1, a2) => guad0ecl_node_GD0Ctwo(a0, a1, a2)
| ~GD0Ccons(a0, a1, a2, a3) => guad0ecl_node_GD0Ccons(a0, a1, a2, a3)
) (* end of [guad0ecl_node_encode] *)

implement
guad0ecl_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
guad0ecl_node_is_GD0Cone
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
guad0ecl_node_is_GD0Ctwo
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
guad0ecl_node_is_GD0Ccons
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
guad0ecl_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 0)))
//
in
//
case+ tag of
| 0 => GD0Cone($UN.cast{e0xp} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{d0eclist} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 1 => GD0Ctwo($UN.cast{e0xp} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{d0eclist} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{d0eclist} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
| _ => GD0Ccons($UN.cast{e0xp} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{d0eclist} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{srpifkind} ($UN.cast{lint} (pats_syntax_ld (p, 24))), $UN.cast{guad0ecl_node} ($UN.cast{lint} (pats_syntax_ld (p, 32))))
//
end // end of [guad0ecl_node_view]

implement
guad0ecl_node_view_free
  (v) =
(
case+ v of
| ~GD0Cone(_, _) => ()
| ~GD0Ctwo(_, _, _) => ()
| ~GD0Ccons(_, _, _, _) => ()
) (* end of [guad0ecl_node_view_free] *)

(* ****** ****** *)

implement
d0exp_node_D0Eide
  (a0) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Eide]

implement
d0exp_node_D0Edqid
  (a0, a1) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Edqid]

implement
d0exp_node_D0Eopid
  (a0) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Eopid]

implement
d0exp_node_D0Eidext
  (a0) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (3)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Eidext]

implement
d0exp_node_D0Eint
  (a0) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (4)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Eint]

implement
d0exp_node_D0Echar
  (a0) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (5)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Echar]

implement
d0exp_node_D0Efloat
  (a0) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (6)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Efloat]

implement
d0exp_node_D0Estring
  (a0) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (7)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Estring]

implement
d0exp_node_D0Eempty
  () = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (8)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Eempty]

implement
d0exp_node_D0Ecstsp
  (a0) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (9)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Ecstsp]

implement
d0exp_node_D0Etyrep
  (a0) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (10)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Etyrep]

implement
d0exp_node_D0Eliteral
  (a0) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (11)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Eliteral]

implement
d0exp_node_D0Eextval
  (a0, a1) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (12)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Eextval]

implement
d0exp_node_D0Eextfcall
  (a0, a1, a2) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (13)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Eextfcall]

implement
d0exp_node_D0Eextmcall
  (a0, a1, a2, a3) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (14)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_syntax_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Eextmcall]

implement
d0exp_node_D0Efoldat
  (a0) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (15)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Efoldat]

implement
d0exp_node_D0Efreeat
  (a0) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (16)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Efreeat]

implement
d0exp_node_D0Etmpid
  (a0, a1) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (17)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Etmpid]

implement
d0exp_node_D0Elet
  (a0, a1) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (18)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Elet]

implement
d0exp_node_D0Edeclseq
  (a0) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (19)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Edeclseq]

implement
d0exp_node_D0Ewhere
  (a0, a1) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (20)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Ewhere]

implement
d0exp_node_D0Eapp
  (a0, a1) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (21)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Eapp]

implement
d0exp_node_D0Elist
  (a0, a1) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (22)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Elist]

implement
d0exp_node_D0Eifhead
  (a0, a1, a2, a3) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (23)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_syntax_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Eifhead]

implement
d0exp_node_D0Esifhead
  (a0, a1, a2, a3) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (24)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_syntax_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Esifhead]

implement
d0exp_node_D0Eifcasehd
  (a0, a1) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (25)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Eifcasehd]

implement
d0exp_node_D0Ecasehead
  (a0, a1, a2) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (26)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Ecasehead]

implement
d0exp_node_D0Escasehead
  (a0, a1, a2) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (27)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Escasehead]

implement
d0exp_node_D0Elst
  (a0, a1, a2) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (28)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Elst]

implement
d0exp_node_D0Etup
  (a0, a1, a2) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (29)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Etup]

implement
d0exp_node_D0Erec
  (a0, a1, a2) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (30)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Erec]

implement
d0exp_node_D0Eseq
  (a0) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (31)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Eseq]

implement
d0exp_node_D0Earrsub
  (a0, a1, a2) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (32)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Earrsub]

implement
d0exp_node_D0Earrpsz
  (a0, a1) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (33)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Earrpsz]

implement
d0exp_node_D0Earrinit
  (a0, a1, a2) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (34)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Earrinit]

implement
d0exp_node_D0Eptrof
  () = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (35)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Eptrof]

implement
d0exp_node_D0Eviewat
  () = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (36)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Eviewat]

implement
d0exp_node_D0Esel_lab
  (a0, a1) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (37)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Esel_lab]

implement
d0exp_node_D0Esel_ind
  (a0, a1) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (38)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Esel_ind]

implement
d0exp_node_D0Eraise
  (a0) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (39)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Eraise]

implement
d0exp_node_D0Eeffmask
  (a0, a1) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (40)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Eeffmask]

implement
d0exp_node_D0Eeffmask_arg
  (a0, a1) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (41)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Eeffmask_arg]

implement
d0exp_node_D0Evararg
  (a0) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (42)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Evararg]

implement
d0exp_node_D0Evcopyenv
  (a0, a1) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (43)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Evcopyenv]

implement
d0exp_node_D0Eshowtype
  (a0) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (44)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Eshowtype]

implement
d0exp_node_D0Etempenver
  (a0) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (45)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Etempenver]

implement
d0exp_node_D0Esexparg
  (a0) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (46)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Esexparg]

implement
d0exp_node_D0Eexist
  (a0, a1, a2) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (47)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Eexist]

implement
d0exp_node_D0Eann
  (a0, a1) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (48)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Eann]

implement
d0exp_node_D0Elam
  (a0, a1, a2, a3, a4) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (49)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_syntax_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_syntax_st (p, 40, $UN.cast{ptr} ($UN.cast{lint} (a4)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Elam]

implement
d0exp_node_D0Efix
  (a0, a1, a2, a3, a4, a5) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (50)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_syntax_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_syntax_st (p, 40, $UN.cast{ptr} ($UN.cast{lint} (a4)))
val () = pats_syntax_st (p, 48, $UN.cast{ptr} ($UN.cast{lint} (a5)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Efix]

implement
d0exp_node_D0Edelay
  (a0, a1) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (51)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Edelay]

implement
d0exp_node_D0Efor
  (a0, a1, a2, a3) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (52)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_syntax_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Efor]

implement
d0exp_node_D0Ewhile
  (a0, a1, a2, a3) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (53)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_syntax_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Ewhile]

implement
d0exp_node_D0Eloopexn
  (a0) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (54)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Eloopexn]

implement
d0exp_node_D0Etrywith
  (a0, a1, a2) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (55)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Etrywith]

implement
d0exp_node_D0Emacsyn
  (a0, a1) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (56)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Emacsyn]

implement
d0exp_node_D0Esolassert
  (a0) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (57)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Esolassert]

implement
d0exp_node_D0Esolverify
  (a0) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (58)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0exp_node} (p)
end // end of [d0exp_node_D0Esolverify]

implement
d0exp_node_encode
  (v) =
(
case+ v of
| ~D0Eide(a0) => d0exp_node_D0Eide(a0)
| ~D0Edqid(a0, a1) => d0exp_node_D0Edqid(a0, a1)
| ~D0Eopid(a0) => d0exp_node_D0Eopid(a0)
| ~D0Eidext(a0) => d0exp_node_D0Eidext(a0)
| ~D0Eint(a0) => d0exp_node_D0Eint(a0)
| ~D0Echar(a0) => d0exp_node_D0Echar(a0)
| ~D0Efloat(a0) => d0exp_node_D0Efloat(a0)
| ~D0Estring(a0) => d0exp_node_D0Estring(a0)
| ~D0Eempty() => d0exp_node_D0Eempty()
| ~D0Ecstsp(a0) => d0exp_node_D0Ecstsp(a0)
| ~D0Etyrep(a0) => d0exp_node_D0Etyrep(a0)
| ~D0Eliteral(a0) => d0exp_node_D0Eliteral(a0)
| ~D0Eextval(a0, a1) => d0exp_node_D0Eextval(a0, a1)
| ~D0Eextfcall(a0, a1, a2) => d0exp_node_D0Eextfcall(a0, a1, a2)
| ~D0Eextmcall(a0, a1, a2, a3) => d0exp_node_D0Eextmcall(a0, a1, a2, a3)
| ~D0Efoldat(a0) => d0exp_node_D0Efoldat(a0)
| ~D0Efreeat(a0) => d0exp_node_D0Efreeat(a0)
| ~D0Etmpid(a0, a1) => d0exp_node_D0Etmpid(a0, a1)
| ~D0Elet(a0, a1) => d0exp_node_D0Elet(a0, a1)
| ~D0Edeclseq(a0) => d0exp_node_D0Edeclseq(a0)
| ~D0Ewhere(a0, a1) => d0exp_node_D0Ewhere(a0, a1)
| ~D0Eapp(a0, a1) => d0exp_node_D0Eapp(a0, a1)
| ~D0Elist(a0, a1) => d0exp_node_D0Elist(a0, a1)
| ~D0Eifhead(a0, a1, a2, a3) => d0exp_node_D0Eifhead(a0, a1, a2, a3)
| ~D0Esifhead(a0, a1, a2, a3) => d0exp_node_D0Esifhead(a0, a1, a2, a3)
| ~D0Eifcasehd(a0, a1) => d0exp_node_D0Eifcasehd(a0, a1)
| ~D0Ecasehead(a0, a1, a2) => d0exp_node_D0Ecasehead(a0, a1, a2)
| ~D0Escasehead(a0, a1, a2) => d0exp_node_D0Escasehead(a0, a1, a2)
| ~D0Elst(a0, a1, a2) => d0exp_node_D0Elst(a0, a1, a2)
| ~D0Etup(a0, a1, a2) => d0exp_node_D0Etup(a0, a1, a2)
| ~D0Erec(a0, a1, a2) => d0exp_node_D0Erec(a0, a1, a2)
| ~D0Eseq(a0) => d0exp_node_D0Eseq(a0)
| ~D0Earrsub(a0, a1, a2) => d0exp_node_D0Earrsub(a0, a1, a2)
| ~D0Earrpsz(a0, a1) => d0exp_node_D0Earrpsz(a0, a1)
| ~D0Earrinit(a0, a1, a2) => d0exp_node_D0Earrinit(a0, a1, a2)
| ~D0Eptrof() => d0exp_node_D0Eptrof()
| ~D0Eviewat() => d0exp_node_D0Eviewat()
| ~D0Esel_lab(a0, a1) => d0exp_node_D0Esel_lab(a0, a1)
| ~D0Esel_ind(a0, a1) => d0exp_node_D0Esel_ind(a0, a1)
| ~D0Eraise(a0) => d0exp_node_D0Eraise(a0)
| ~D0Eeffmask(a0, a1) => d0exp_node_D0Eeffmask(a0, a1)
| ~D0Eeffmask_arg(a0, a1) => d0exp_node_D0Eeffmask_arg(a0, a1)
| ~D0Evararg(a0) => d0exp_node_D0Evararg(a0)
| ~D0Evcopyenv(a0, a1) => d0exp_node_D0Evcopyenv(a0, a1)
| ~D0Eshowtype(a0) => d0exp_node_D0Eshowtype(a0)
| ~D0Etempenver(a0) => d0exp_node_D0Etempenver(a0)
| ~D0Esexparg(a0) => d0exp_node_D0Esexparg(a0)
| ~D0Eexist(a0, a1, a2) => d0exp_node_D0Eexist(a0, a1, a2)
| ~D0Eann(a0, a1) => d0exp_node_D0Eann(a0, a1)
| ~D0Elam(a0, a1, a2, a3, a4) => d0exp_node_D0Elam(a0, a1, a2, a3, a4)
| ~D0Efix(a0, a1, a2, a3, a4, a5) => d0exp_node_D0Efix(a0, a1, a2, a3, a4, a5)
| ~D0Edelay(a0, a1) => d0exp_node_D0Edelay(a0, a1)
| ~D0Efor(a0, a1, a2, a3) => d0exp_node_D0Efor(a0, a1, a2, a3)
| ~D0Ewhile(a0, a1, a2, a3) => d0exp_node_D0Ewhile(a0, a1, a2, a3)
| ~D0Eloopexn(a0) => d0exp_node_D0Eloopexn(a0)
| ~D0Etrywith(a0, a1, a2) => d0exp_node_D0Etrywith(a0, a1, a2)
| ~D0Emacsyn(a0, a1) => d0exp_node_D0Emacsyn(a0, a1)
| ~D0Esolassert(a0) => d0exp_node_D0Esolassert(a0)
| ~D0Esolverify(a0) => d0exp_node_D0Esolverify(a0)
) (* end of [d0exp_node_encode] *)

implement
d0exp_node_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
d0exp_node_is_D0Eide
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
d0exp_node_is_D0Edqid
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
d0exp_node_is_D0Eopid
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
d0exp_node_is_D0Eidext
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 3)

implement
d0exp_node_is_D0Eint
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 4)

implement
d0exp_node_is_D0Echar
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 5)

implement
d0exp_node_is_D0Efloat
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 6)

implement
d0exp_node_is_D0Estring
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 7)

implement
d0exp_node_is_D0Eempty
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 8)

implement
d0exp_node_is_D0Ecstsp
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 9)

implement
d0exp_node_is_D0Etyrep
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 10)

implement
d0exp_node_is_D0Eliteral
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 11)

implement
d0exp_node_is_D0Eextval
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 12)

implement
d0exp_node_is_D0Eextfcall
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 13)

implement
d0exp_node_is_D0Eextmcall
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 14)

implement
d0exp_node_is_D0Efoldat
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 15)

implement
d0exp_node_is_D0Efreeat
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 16)

implement
d0exp_node_is_D0Etmpid
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 17)

implement
d0exp_node_is_D0Elet
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 18)

implement
d0exp_node_is_D0Edeclseq
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 19)

implement
d0exp_node_is_D0Ewhere
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 20)

implement
d0exp_node_is_D0Eapp
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 21)

implement
d0exp_node_is_D0Elist
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 22)

implement
d0exp_node_is_D0Eifhead
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 23)

implement
d0exp_node_is_D0Esifhead
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 24)

implement
d0exp_node_is_D0Eifcasehd
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 25)

implement
d0exp_node_is_D0Ecasehead
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 26)

implement
d0exp_node_is_D0Escasehead
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 27)

implement
d0exp_node_is_D0Elst
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 28)

implement
d0exp_node_is_D0Etup
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 29)

implement
d0exp_node_is_D0Erec
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 30)

implement
d0exp_node_is_D0Eseq
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 31)

implement
d0exp_node_is_D0Earrsub
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 32)

implement
d0exp_node_is_D0Earrpsz
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 33)

implement
d0exp_node_is_D0Earrinit
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 34)

implement
d0exp_node_is_D0Eptrof
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 35)

implement
d0exp_node_is_D0Eviewat
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 36)

implement
d0exp_node_is_D0Esel_lab
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 37)

implement
d0exp_node_is_D0Esel_ind
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 38)

implement
d0exp_node_is_D0Eraise
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 39)

implement
d0exp_node_is_D0Eeffmask
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 40)

implement
d0exp_node_is_D0Eeffmask_arg
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 41)

implement
d0exp_node_is_D0Evararg
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 42)

implement
d0exp_node_is_D0Evcopyenv
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 43)

implement
d0exp_node_is_D0Eshowtype
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 44)

implement
d0exp_node_is_D0Etempenver
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 45)

implement
d0exp_node_is_D0Esexparg
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 46)

implement
d0exp_node_is_D0Eexist
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 47)

implement
d0exp_node_is_D0Eann
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 48)

implement
d0exp_node_is_D0Elam
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 49)

implement
d0exp_node_is_D0Efix
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 50)

implement
d0exp_node_is_D0Edelay
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 51)

implement
d0exp_node_is_D0Efor
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 52)

implement
d0exp_node_is_D0Ewhile
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 53)

implement
d0exp_node_is_D0Eloopexn
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 54)

implement
d0exp_node_is_D0Etrywith
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 55)

implement
d0exp_node_is_D0Emacsyn
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 56)

implement
d0exp_node_is_D0Esolassert
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 57)

implement
d0exp_node_is_D0Esolverify
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0))) = 58)

implement
d0exp_node_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 0)))
//
in
//
case+ tag of
| 0 => D0Eide($UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 1 => D0Edqid($UN.cast{d0ynq} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 2 => D0Eopid($UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 3 => D0Eidext($UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 4 => D0Eint($UN.cast{i0nt} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 5 => D0Echar($UN.cast{c0har} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 6 => D0Efloat($UN.cast{f0loat} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 7 => D0Estring($UN.cast{s0tring} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 8 => D0Eempty()
| 9 => D0Ecstsp($UN.cast{cstsp} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 10 => D0Etyrep($UN.cast{s0exp} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 11 => D0Eliteral($UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 12 => D0Eextval($UN.cast{s0exp} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{string} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 13 => D0Eextfcall($UN.cast{s0exp} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{string} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{d0explst} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
| 14 => D0Eextmcall($UN.cast{s0exp} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{string} ($UN.cast{lint} (pats_syntax_ld (p, 24))), $UN.cast{d0explst} ($UN.cast{lint} (pats_syntax_ld (p, 32))))
| 15 => D0Efoldat($UN.cast{d0explst} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 16 => D0Efreeat($UN.cast{d0explst} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 17 => D0Etmpid($UN.cast{dqi0de} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{t0mpmarglst} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 18 => D0Elet($UN.cast{d0eclist} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 19 => D0Edeclseq($UN.cast{d0eclist} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 20 => D0Ewhere($UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{d0eclist} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 21 => D0Eapp($UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 22 => D0Elist($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{d0explst} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 23 => D0Eifhead($UN.cast{ifhead} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld (p, 24))), $UN.cast{d0expopt} ($UN.cast{lint} (pats_syntax_ld (p, 32))))
| 24 => D0Esifhead($UN.cast{sifhead} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{s0exp} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld (p, 24))), $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld (p, 32))))
| 25 => D0Eifcasehd($UN.cast{ifhead} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{i0fclist} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 26 => D0Ecasehead($UN.cast{casehead} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{c0laulst} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
| 27 => D0Escasehead($UN.cast{scasehead} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{s0exp} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{sc0laulst} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
| 28 => D0Elst($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{s0expopt} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
| 29 => D0Etup($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{d0explst} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
| 30 => D0Erec($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{labd0explst} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
| 31 => D0Eseq($UN.cast{d0explst} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 32 => D0Earrsub($UN.cast{dqi0de} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{d0explstlst} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
| 33 => D0Earrpsz($UN.cast{s0expopt} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 34 => D0Earrinit($UN.cast{s0exp} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{d0expopt} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{d0explst} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
| 35 => D0Eptrof()
| 36 => D0Eviewat()
| 37 => D0Esel_lab($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{label} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 38 => D0Esel_ind($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{d0explstlst} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 39 => D0Eraise($UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 40 => D0Eeffmask($UN.cast{e0fftaglst} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 41 => D0Eeffmask_arg($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 42 => D0Evararg($UN.cast{d0explst} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 43 => D0Evcopyenv($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 44 => D0Eshowtype($UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 45 => D0Etempenver($UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 46 => D0Esexparg($UN.cast{s0exparg} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 47 => D0Eexist($UN.cast{location} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{s0exparg} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
| 48 => D0Eann($UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{s0exp} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 49 => D0Elam($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{f0arglst} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{s0expopt} ($UN.cast{lint} (pats_syntax_ld (p, 24))), $UN.cast{e0fftaglstopt} ($UN.cast{lint} (pats_syntax_ld (p, 32))), $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld (p, 40))))
| 50 => D0Efix($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{i0de} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{f0arglst} ($UN.cast{lint} (pats_syntax_ld (p, 24))), $UN.cast{s0expopt} ($UN.cast{lint} (pats_syntax_ld (p, 32))), $UN.cast{e0fftaglstopt} ($UN.cast{lint} (pats_syntax_ld (p, 40))), $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld (p, 48))))
| 51 => D0Edelay($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 52 => D0Efor($UN.cast{loopi0nvopt} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{initestpost} ($UN.cast{lint} (pats_syntax_ld (p, 24))), $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld (p, 32))))
| 53 => D0Ewhile($UN.cast{loopi0nvopt} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld (p, 24))), $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld (p, 32))))
| 54 => D0Eloopexn($UN.cast{int} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| 55 => D0Etrywith($UN.cast{tryhead} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld (p, 16))), $UN.cast{c0laulst} ($UN.cast{lint} (pats_syntax_ld (p, 24))))
| 56 => D0Emacsyn($UN.cast{macsynkind} ($UN.cast{lint} (pats_syntax_ld (p, 8))), $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld (p, 16))))
| 57 => D0Esolassert($UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
| _ => D0Esolverify($UN.cast{s0exp} ($UN.cast{lint} (pats_syntax_ld (p, 8))))
//
end // end of [d0exp_node_view]

implement
d0exp_node_view_free
  (v) =
(
case+ v of
| ~D0Eide(_) => ()
| ~D0Edqid(_, _) => ()
| ~D0Eopid(_) => ()
| ~D0Eidext(_) => ()
| ~D0Eint(_) => ()
| ~D0Echar(_) => ()
| ~D0Efloat(_) => ()
| ~D0Estring(_) => ()
| ~D0Eempty() => ()
| ~D0Ecstsp(_) => ()
| ~D0Etyrep(_) => ()
| ~D0Eliteral(_) => ()
| ~D0Eextval(_, _) => ()
| ~D0Eextfcall(_, _, _) => ()
| ~D0Eextmcall(_, _, _, _) => ()
| ~D0Efoldat(_) => ()
| ~D0Efreeat(_) => ()
| ~D0Etmpid(_, _) => ()
| ~D0Elet(_, _) => ()
| ~D0Edeclseq(_) => ()
| ~D0Ewhere(_, _) => ()
| ~D0Eapp(_, _) => ()
| ~D0Elist(_, _) => ()
| ~D0Eifhead(_, _, _, _) => ()
| ~D0Esifhead(_, _, _, _) => ()
| ~D0Eifcasehd(_, _) => ()
| ~D0Ecasehead(_, _, _) => ()
| ~D0Escasehead(_, _, _) => ()
| ~D0Elst(_, _, _) => ()
| ~D0Etup(_, _, _) => ()
| ~D0Erec(_, _, _) => ()
| ~D0Eseq(_) => ()
| ~D0Earrsub(_, _, _) => ()
| ~D0Earrpsz(_, _) => ()
| ~D0Earrinit(_, _, _) => ()
| ~D0Eptrof() => ()
| ~D0Eviewat() => ()
| ~D0Esel_lab(_, _) => ()
| ~D0Esel_ind(_, _) => ()
| ~D0Eraise(_) => ()
| ~D0Eeffmask(_, _) => ()
| ~D0Eeffmask_arg(_, _) => ()
| ~D0Evararg(_) => ()
| ~D0Evcopyenv(_, _) => ()
| ~D0Eshowtype(_) => ()
| ~D0Etempenver(_) => ()
| ~D0Esexparg(_) => ()
| ~D0Eexist(_, _, _) => ()
| ~D0Eann(_, _) => ()
| ~D0Elam(_, _, _, _, _) => ()
| ~D0Efix(_, _, _, _, _, _) => ()
| ~D0Edelay(_, _) => ()
| ~D0Efor(_, _, _, _) => ()
| ~D0Ewhile(_, _, _, _) => ()
| ~D0Eloopexn(_) => ()
| ~D0Etrywith(_, _, _) => ()
| ~D0Emacsyn(_, _) => ()
| ~D0Esolassert(_) => ()
| ~D0Esolverify(_) => ()
) (* end of [d0exp_node_view_free] *)

(* ****** ****** *)

implement
d0ecl_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0ecl} (p)
end // end of [d0ecl_new]

implement
d0ecl_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
d0ecl_node
  (x) = $UN.cast{d0ecl_node} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
guad0ecl_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{guad0ecl} (p)
end // end of [guad0ecl_new]

implement
guad0ecl_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
guad0ecl_node
  (x) = $UN.cast{guad0ecl_node} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
d0exp_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0exp} (p)
end // end of [d0exp_new]

implement
d0exp_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
d0exp_node
  (x) = $UN.cast{d0exp_node} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
d0arrind_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0arrind} (p)
end // end of [d0arrind_new]

implement
d0arrind_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
d0arrind_ind
  (x) = $UN.cast{d0explstlst} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
initestpost_new
  (a0, a1, a2) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{initestpost} (p)
end // end of [initestpost_new]

implement
itp_init
  (x) = $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
itp_test
  (x) = $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
itp_post
  (x) = $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
gm0at_new
  (a0, a1, a2) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{gm0at} (p)
end // end of [gm0at_new]

implement
gm0at_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
gm0at_exp
  (x) = $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
gm0at_pat
  (x) = $UN.cast{p0atopt} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
guap0at_new
  (a0, a1, a2) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{guap0at} (p)
end // end of [guap0at_new]

implement
guap0at_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
guap0at_pat
  (x) = $UN.cast{p0at} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
guap0at_gua
  (x) = $UN.cast{gm0atlst} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
ifhead_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{ifhead} (p)
end // end of [ifhead_new]

implement
ifhead_tok
  (x) = $UN.cast{token} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
ifhead_inv
  (x) = $UN.cast{i0nvresstate} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
sifhead_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{sifhead} (p)
end // end of [sifhead_new]

implement
sifhead_tok
  (x) = $UN.cast{token} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
sifhead_inv
  (x) = $UN.cast{i0nvresstate} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
casehead_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{casehead} (p)
end // end of [casehead_new]

implement
casehead_tok
  (x) = $UN.cast{token} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
casehead_inv
  (x) = $UN.cast{i0nvresstate} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
scasehead_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{scasehead} (p)
end // end of [scasehead_new]

implement
scasehead_tok
  (x) = $UN.cast{token} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
scasehead_inv
  (x) = $UN.cast{i0nvresstate} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
loophead_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{loophead} (p)
end // end of [loophead_new]

implement
loophead_tok
  (x) = $UN.cast{token} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
loophead_inv
  (x) = $UN.cast{loopi0nvopt} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
tryhead_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{tryhead} (p)
end // end of [tryhead_new]

implement
tryhead_tok
  (x) = $UN.cast{token} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
tryhead_inv
  (x) = $UN.cast{i0nvresstate} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
i0fcl_new
  (a0, a1, a2) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{i0fcl} (p)
end // end of [i0fcl_new]

implement
i0fcl_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
i0fcl_test
  (x) = $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
i0fcl_body
  (x) = $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
c0lau_new
  (a0, a1, a2, a3, a4) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_syntax_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a4)))
in
  $UN.cast{c0lau} (p)
end // end of [c0lau_new]

implement
c0lau_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
c0lau_pat
  (x) = $UN.cast{guap0at} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
c0lau_seq
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

implement
c0lau_neg
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 24)))

implement
c0lau_body
  (x) = $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 32)))

(* ****** ****** *)

implement
sc0lau_new
  (a0, a1, a2) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{sc0lau} (p)
end // end of [sc0lau_new]

implement
sc0lau_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
sc0lau_pat
  (x) = $UN.cast{sp0at} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
sc0lau_body
  (x) = $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
m0acdef_new
  (a0, a1, a2, a3) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{m0acdef} (p)
end // end of [m0acdef_new]

implement
m0acdef_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
m0acdef_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
m0acdef_arg
  (x) = $UN.cast{m0acarglst} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

implement
m0acdef_def
  (x) = $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 24)))

(* ****** ****** *)

implement
f0undec_new
  (a0, a1, a2, a3, a4, a5, a6, a7) = let
val p = pats_syntax_alloc (64)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_syntax_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a4)))
val () = pats_syntax_st (p, 40, $UN.cast{ptr} ($UN.cast{lint} (a5)))
val () = pats_syntax_st (p, 48, $UN.cast{ptr} ($UN.cast{lint} (a6)))
val () = pats_syntax_st (p, 56, $UN.cast{ptr} ($UN.cast{lint} (a7)))
in
  $UN.cast{f0undec} (p)
end // end of [f0undec_new]

implement
f0undec_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
f0undec_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
f0undec_sym_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

implement
f0undec_arg
  (x) = $UN.cast{f0arglst} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 24)))

implement
f0undec_eff
  (x) = $UN.cast{e0fftaglstopt} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 32)))

implement
f0undec_res
  (x) = $UN.cast{s0expopt} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 40)))

implement
f0undec_def
  (x) = $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 48)))

implement
f0undec_ann
  (x) = $UN.cast{witht0ype} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 56)))

(* ****** ****** *)

implement
v0aldec_new
  (a0, a1, a2, a3) = let
val p = pats_syntax_alloc (32)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
in
  $UN.cast{v0aldec} (p)
end // end of [v0aldec_new]

implement
v0aldec_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
v0aldec_pat
  (x) = $UN.cast{p0at} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
v0aldec_def
  (x) = $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

implement
v0aldec_ann
  (x) = $UN.cast{witht0ype} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 24)))

(* ****** ****** *)

implement
v0ardec_new
  (a0, a1, a2, a3, a4, a5, a6) = let
val p = pats_syntax_alloc (56)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_syntax_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a4)))
val () = pats_syntax_st (p, 40, $UN.cast{ptr} ($UN.cast{lint} (a5)))
val () = pats_syntax_st (p, 48, $UN.cast{ptr} ($UN.cast{lint} (a6)))
in
  $UN.cast{v0ardec} (p)
end // end of [v0ardec_new]

implement
v0ardec_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
v0ardec_knd
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
v0ardec_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

implement
v0ardec_sym_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 24)))

implement
v0ardec_pfat
  (x) = $UN.cast{i0deopt} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 32)))

implement
v0ardec_type
  (x) = $UN.cast{s0expopt} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 40)))

implement
v0ardec_init
  (x) = $UN.cast{d0expopt} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 48)))

(* ****** ****** *)

implement
i0mpdec_new
  (a0, a1, a2, a3, a4) = let
val p = pats_syntax_alloc (40)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
val () = pats_syntax_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a3)))
val () = pats_syntax_st (p, 32, $UN.cast{ptr} ($UN.cast{lint} (a4)))
in
  $UN.cast{i0mpdec} (p)
end // end of [i0mpdec_new]

implement
i0mpdec_loc
  (x) = $UN.cast{location} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
i0mpdec_qid
  (x) = $UN.cast{impqi0de} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
i0mpdec_arg
  (x) = $UN.cast{f0arglst} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

implement
i0mpdec_res
  (x) = $UN.cast{s0expopt} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 24)))

implement
i0mpdec_def
  (x) = $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 32)))

(* ****** ****** *)

implement
labs0exp_new
  (a0, a1, a2) = let
val p = pats_syntax_alloc (24)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = pats_syntax_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{labs0exp} (p)
end // end of [labs0exp_new]

implement
labs0exp_lab
  (x) = $UN.cast{l0ab} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
labs0exp_nam
  (x) = $UN.cast{s0tringopt} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

implement
labs0exp_elt
  (x) = $UN.cast{s0exp} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 16)))

(* ****** ****** *)

implement
labd0exp_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{labd0exp} (p)
end // end of [labd0exp_new]

implement
labd0exp_lab
  (x) = $UN.cast{l0ab} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
labd0exp_elt
  (x) = $UN.cast{d0exp} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)

implement
datsdef_new
  (a0, a1) = let
val p = pats_syntax_alloc (16)
val () = pats_syntax_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_syntax_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{datsdef} (p)
end // end of [datsdef_new]

implement
datsdef_sym
  (x) = $UN.cast{symbol} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 0)))

implement
datsdef_opt
  (x) = $UN.cast{e0xpopt} ($UN.cast{lint} (pats_syntax_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)
