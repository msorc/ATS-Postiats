fn libatsdoc_atext_ld (p: ptr, k: int): ptr = $UN.ptr0_get<ptr> (ptr0_add_gint<byte> (p, k))
fn libatsdoc_atext_st (p: ptr, k: int, x: ptr): void = $UN.ptr0_set<ptr> (ptr0_add_gint<byte> (p, k), x)
fn libatsdoc_atext_alloc (n: int): ptr = the_garena_alloc ($UN.cast{size_t} (n))
//

implement
atext_ATEXTnil
  () = let
val p = libatsdoc_atext_alloc (32)
val () = libatsdoc_atext_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
in
  $UN.cast{atext} (p)
end // end of [atext_ATEXTnil]

implement
atext_ATEXTstrcst
  (a0) = let
val p = libatsdoc_atext_alloc (32)
val () = libatsdoc_atext_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = libatsdoc_atext_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{atext} (p)
end // end of [atext_ATEXTstrcst]

implement
atext_ATEXTstrsub
  (a0) = let
val p = libatsdoc_atext_alloc (32)
val () = libatsdoc_atext_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = libatsdoc_atext_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{atext} (p)
end // end of [atext_ATEXTstrsub]

implement
atext_ATEXTapptxt2
  (a0, a1) = let
val p = libatsdoc_atext_alloc (32)
val () = libatsdoc_atext_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (3)))
val () = libatsdoc_atext_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = libatsdoc_atext_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{atext} (p)
end // end of [atext_ATEXTapptxt2]

implement
atext_ATEXTappstr2
  (a0, a1) = let
val p = libatsdoc_atext_alloc (32)
val () = libatsdoc_atext_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (4)))
val () = libatsdoc_atext_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = libatsdoc_atext_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{atext} (p)
end // end of [atext_ATEXTappstr2]

implement
atext_ATEXTapptxt3
  (a0, a1, a2) = let
val p = libatsdoc_atext_alloc (32)
val () = libatsdoc_atext_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (5)))
val () = libatsdoc_atext_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = libatsdoc_atext_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = libatsdoc_atext_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{atext} (p)
end // end of [atext_ATEXTapptxt3]

implement
atext_ATEXTappstr3
  (a0, a1, a2) = let
val p = libatsdoc_atext_alloc (32)
val () = libatsdoc_atext_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (6)))
val () = libatsdoc_atext_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = libatsdoc_atext_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = libatsdoc_atext_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{atext} (p)
end // end of [atext_ATEXTappstr3]

implement
atext_ATEXTconcatxt
  (a0) = let
val p = libatsdoc_atext_alloc (32)
val () = libatsdoc_atext_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (7)))
val () = libatsdoc_atext_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{atext} (p)
end // end of [atext_ATEXTconcatxt]

implement
atext_ATEXTconcatxtsep
  (a0, a1) = let
val p = libatsdoc_atext_alloc (32)
val () = libatsdoc_atext_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (8)))
val () = libatsdoc_atext_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = libatsdoc_atext_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{atext} (p)
end // end of [atext_ATEXTconcatxtsep]

implement
atext_encode
  (v) =
(
case+ v of
| ~ATEXTnil() => atext_ATEXTnil()
| ~ATEXTstrcst(a0) => atext_ATEXTstrcst(a0)
| ~ATEXTstrsub(a0) => atext_ATEXTstrsub(a0)
| ~ATEXTapptxt2(a0, a1) => atext_ATEXTapptxt2(a0, a1)
| ~ATEXTappstr2(a0, a1) => atext_ATEXTappstr2(a0, a1)
| ~ATEXTapptxt3(a0, a1, a2) => atext_ATEXTapptxt3(a0, a1, a2)
| ~ATEXTappstr3(a0, a1, a2) => atext_ATEXTappstr3(a0, a1, a2)
| ~ATEXTconcatxt(a0) => atext_ATEXTconcatxt(a0)
| ~ATEXTconcatxtsep(a0, a1) => atext_ATEXTconcatxtsep(a0, a1)
) (* end of [atext_encode] *)

implement
atext_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (libatsdoc_atext_ld ($UN.cast{ptr} (x), 0)))

implement
atext_is_ATEXTnil
  (x) = ($UN.cast{int} ($UN.cast{lint} (libatsdoc_atext_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
atext_is_ATEXTstrcst
  (x) = ($UN.cast{int} ($UN.cast{lint} (libatsdoc_atext_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
atext_is_ATEXTstrsub
  (x) = ($UN.cast{int} ($UN.cast{lint} (libatsdoc_atext_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
atext_is_ATEXTapptxt2
  (x) = ($UN.cast{int} ($UN.cast{lint} (libatsdoc_atext_ld ($UN.cast{ptr} (x), 0))) = 3)

implement
atext_is_ATEXTappstr2
  (x) = ($UN.cast{int} ($UN.cast{lint} (libatsdoc_atext_ld ($UN.cast{ptr} (x), 0))) = 4)

implement
atext_is_ATEXTapptxt3
  (x) = ($UN.cast{int} ($UN.cast{lint} (libatsdoc_atext_ld ($UN.cast{ptr} (x), 0))) = 5)

implement
atext_is_ATEXTappstr3
  (x) = ($UN.cast{int} ($UN.cast{lint} (libatsdoc_atext_ld ($UN.cast{ptr} (x), 0))) = 6)

implement
atext_is_ATEXTconcatxt
  (x) = ($UN.cast{int} ($UN.cast{lint} (libatsdoc_atext_ld ($UN.cast{ptr} (x), 0))) = 7)

implement
atext_is_ATEXTconcatxtsep
  (x) = ($UN.cast{int} ($UN.cast{lint} (libatsdoc_atext_ld ($UN.cast{ptr} (x), 0))) = 8)

implement
atext_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (libatsdoc_atext_ld (p, 0)))
//
in
//
case+ tag of
| 0 => ATEXTnil()
| 1 => ATEXTstrcst($UN.cast{string} ($UN.cast{lint} (libatsdoc_atext_ld (p, 8))))
| 2 => ATEXTstrsub($UN.cast{string} ($UN.cast{lint} (libatsdoc_atext_ld (p, 8))))
| 3 => ATEXTapptxt2($UN.cast{atext} ($UN.cast{lint} (libatsdoc_atext_ld (p, 8))), $UN.cast{atext} ($UN.cast{lint} (libatsdoc_atext_ld (p, 16))))
| 4 => ATEXTappstr2($UN.cast{string} ($UN.cast{lint} (libatsdoc_atext_ld (p, 8))), $UN.cast{string} ($UN.cast{lint} (libatsdoc_atext_ld (p, 16))))
| 5 => ATEXTapptxt3($UN.cast{atext} ($UN.cast{lint} (libatsdoc_atext_ld (p, 8))), $UN.cast{atext} ($UN.cast{lint} (libatsdoc_atext_ld (p, 16))), $UN.cast{atext} ($UN.cast{lint} (libatsdoc_atext_ld (p, 24))))
| 6 => ATEXTappstr3($UN.cast{string} ($UN.cast{lint} (libatsdoc_atext_ld (p, 8))), $UN.cast{string} ($UN.cast{lint} (libatsdoc_atext_ld (p, 16))), $UN.cast{string} ($UN.cast{lint} (libatsdoc_atext_ld (p, 24))))
| 7 => ATEXTconcatxt($UN.cast{atextlst} ($UN.cast{lint} (libatsdoc_atext_ld (p, 8))))
| _ => ATEXTconcatxtsep($UN.cast{atextlst} ($UN.cast{lint} (libatsdoc_atext_ld (p, 8))), $UN.cast{atext} ($UN.cast{lint} (libatsdoc_atext_ld (p, 16))))
//
end // end of [atext_view]

implement
atext_view_free
  (v) =
(
case+ v of
| ~ATEXTnil() => ()
| ~ATEXTstrcst(_) => ()
| ~ATEXTstrsub(_) => ()
| ~ATEXTapptxt2(_, _) => ()
| ~ATEXTappstr2(_, _) => ()
| ~ATEXTapptxt3(_, _, _) => ()
| ~ATEXTappstr3(_, _, _) => ()
| ~ATEXTconcatxt(_) => ()
| ~ATEXTconcatxtsep(_, _) => ()
) (* end of [atext_view_free] *)

(* ****** ****** *)
