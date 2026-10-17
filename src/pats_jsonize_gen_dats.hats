fn pats_jsonize_ld (p: ptr, k: int): ptr = $UN.ptr0_get<ptr> (ptr0_add_gint<byte> (p, k))
fn pats_jsonize_st (p: ptr, k: int, x: ptr): void = $UN.ptr0_set<ptr> (ptr0_add_gint<byte> (p, k), x)
fn pats_jsonize_alloc (n: int): ptr = the_garena_alloc ($UN.cast{size_t} (n))
//

fn pats_jsonize_ldd (p: ptr, k: int): double = $UN.ptr0_get<double> (ptr0_add_gint<byte> (p, k))
fn pats_jsonize_std (p: ptr, k: int, x: double): void = $UN.ptr0_set<double> (ptr0_add_gint<byte> (p, k), x)
//

implement
jsonval_JSONnul
  () = let
val p = pats_jsonize_alloc (16)
val () = pats_jsonize_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
in
  $UN.cast{jsonval} (p)
end // end of [jsonval_JSONnul]

implement
jsonval_JSONint
  (a0) = let
val p = pats_jsonize_alloc (16)
val () = pats_jsonize_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = pats_jsonize_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{jsonval} (p)
end // end of [jsonval_JSONint]

implement
jsonval_JSONintinf
  (a0) = let
val p = pats_jsonize_alloc (16)
val () = pats_jsonize_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = pats_jsonize_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{jsonval} (p)
end // end of [jsonval_JSONintinf]

implement
jsonval_JSONbool
  (a0) = let
val p = pats_jsonize_alloc (16)
val () = pats_jsonize_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (3)))
val () = pats_jsonize_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{jsonval} (p)
end // end of [jsonval_JSONbool]

implement
jsonval_JSONfloat
  (a0) = let
val p = pats_jsonize_alloc (16)
val () = pats_jsonize_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (4)))
val () = pats_jsonize_std (p, 8, a0)
in
  $UN.cast{jsonval} (p)
end // end of [jsonval_JSONfloat]

implement
jsonval_JSONstring
  (a0) = let
val p = pats_jsonize_alloc (16)
val () = pats_jsonize_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (5)))
val () = pats_jsonize_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{jsonval} (p)
end // end of [jsonval_JSONstring]

implement
jsonval_JSONlocation
  (a0) = let
val p = pats_jsonize_alloc (16)
val () = pats_jsonize_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (6)))
val () = pats_jsonize_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{jsonval} (p)
end // end of [jsonval_JSONlocation]

implement
jsonval_JSONfilename
  (a0) = let
val p = pats_jsonize_alloc (16)
val () = pats_jsonize_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (7)))
val () = pats_jsonize_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{jsonval} (p)
end // end of [jsonval_JSONfilename]

implement
jsonval_JSONlist
  (a0) = let
val p = pats_jsonize_alloc (16)
val () = pats_jsonize_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (8)))
val () = pats_jsonize_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{jsonval} (p)
end // end of [jsonval_JSONlist]

implement
jsonval_JSONlablist
  (a0) = let
val p = pats_jsonize_alloc (16)
val () = pats_jsonize_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (9)))
val () = pats_jsonize_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{jsonval} (p)
end // end of [jsonval_JSONlablist]

implement
jsonval_JSONoption
  (a0) = let
val p = pats_jsonize_alloc (16)
val () = pats_jsonize_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (10)))
val () = pats_jsonize_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{jsonval} (p)
end // end of [jsonval_JSONoption]

implement
jsonval_encode
  (v) =
(
case+ v of
| ~JSONnul() => jsonval_JSONnul()
| ~JSONint(a0) => jsonval_JSONint(a0)
| ~JSONintinf(a0) => jsonval_JSONintinf(a0)
| ~JSONbool(a0) => jsonval_JSONbool(a0)
| ~JSONfloat(a0) => jsonval_JSONfloat(a0)
| ~JSONstring(a0) => jsonval_JSONstring(a0)
| ~JSONlocation(a0) => jsonval_JSONlocation(a0)
| ~JSONfilename(a0) => jsonval_JSONfilename(a0)
| ~JSONlist(a0) => jsonval_JSONlist(a0)
| ~JSONlablist(a0) => jsonval_JSONlablist(a0)
| ~JSONoption(a0) => jsonval_JSONoption(a0)
) (* end of [jsonval_encode] *)

implement
jsonval_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (pats_jsonize_ld ($UN.cast{ptr} (x), 0)))

implement
jsonval_is_JSONnul
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_jsonize_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
jsonval_is_JSONint
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_jsonize_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
jsonval_is_JSONintinf
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_jsonize_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
jsonval_is_JSONbool
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_jsonize_ld ($UN.cast{ptr} (x), 0))) = 3)

implement
jsonval_is_JSONfloat
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_jsonize_ld ($UN.cast{ptr} (x), 0))) = 4)

implement
jsonval_is_JSONstring
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_jsonize_ld ($UN.cast{ptr} (x), 0))) = 5)

implement
jsonval_is_JSONlocation
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_jsonize_ld ($UN.cast{ptr} (x), 0))) = 6)

implement
jsonval_is_JSONfilename
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_jsonize_ld ($UN.cast{ptr} (x), 0))) = 7)

implement
jsonval_is_JSONlist
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_jsonize_ld ($UN.cast{ptr} (x), 0))) = 8)

implement
jsonval_is_JSONlablist
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_jsonize_ld ($UN.cast{ptr} (x), 0))) = 9)

implement
jsonval_is_JSONoption
  (x) = ($UN.cast{int} ($UN.cast{lint} (pats_jsonize_ld ($UN.cast{ptr} (x), 0))) = 10)

implement
jsonval_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (pats_jsonize_ld (p, 0)))
//
in
//
case+ tag of
| 0 => JSONnul()
| 1 => JSONint($UN.cast{int} ($UN.cast{lint} (pats_jsonize_ld (p, 8))))
| 2 => JSONintinf($UN.cast{intinf} ($UN.cast{lint} (pats_jsonize_ld (p, 8))))
| 3 => JSONbool($UN.cast{bool} ($UN.cast{lint} (pats_jsonize_ld (p, 8))))
| 4 => JSONfloat(pats_jsonize_ldd (p, 8))
| 5 => JSONstring($UN.cast{string} ($UN.cast{lint} (pats_jsonize_ld (p, 8))))
| 6 => JSONlocation($UN.cast{location} ($UN.cast{lint} (pats_jsonize_ld (p, 8))))
| 7 => JSONfilename($UN.cast{filename} ($UN.cast{lint} (pats_jsonize_ld (p, 8))))
| 8 => JSONlist($UN.cast{jsonvalist} ($UN.cast{lint} (pats_jsonize_ld (p, 8))))
| 9 => JSONlablist($UN.cast{labjsonvalist} ($UN.cast{lint} (pats_jsonize_ld (p, 8))))
| _ => JSONoption($UN.cast{jsonvalopt} ($UN.cast{lint} (pats_jsonize_ld (p, 8))))
//
end // end of [jsonval_view]

implement
jsonval_view_free
  (v) =
(
case+ v of
| ~JSONnul() => ()
| ~JSONint(_) => ()
| ~JSONintinf(_) => ()
| ~JSONbool(_) => ()
| ~JSONfloat(_) => ()
| ~JSONstring(_) => ()
| ~JSONlocation(_) => ()
| ~JSONfilename(_) => ()
| ~JSONlist(_) => ()
| ~JSONlablist(_) => ()
| ~JSONoption(_) => ()
) (* end of [jsonval_view_free] *)

(* ****** ****** *)

implement
labjsonval_new
  (a0, a1) = let
val p = pats_jsonize_alloc (16)
val () = pats_jsonize_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = pats_jsonize_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{labjsonval} (p)
end // end of [labjsonval_new]

implement
labjsonval_lab
  (x) = $UN.cast{string} ($UN.cast{lint} (pats_jsonize_ld ($UN.cast{ptr} (x), 0)))

implement
labjsonval_val
  (x) = $UN.cast{jsonval} ($UN.cast{lint} (pats_jsonize_ld ($UN.cast{ptr} (x), 8)))

(* ****** ****** *)
