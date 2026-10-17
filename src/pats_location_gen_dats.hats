implement
locpragma_LOCPRAGMA0
  () = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
in
  $UN.cast{locpragma}(p)
end // end of [locpragma_LOCPRAGMA0]

implement
locpragma_LOCPRAGMA1
  (a0) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 1)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{locpragma}(p)
end // end of [locpragma_LOCPRAGMA1]

implement
locpragma_LOCPRAGMA2
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 2)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
val () = arena_store<string>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{locpragma}(p)
end // end of [locpragma_LOCPRAGMA2]

implement
locpragma_encode
  (v) =
(
case+ v of
| ~LOCPRAGMA0() => locpragma_LOCPRAGMA0()
| ~LOCPRAGMA1(a0) => locpragma_LOCPRAGMA1(a0)
| ~LOCPRAGMA2(a0, a1) => locpragma_LOCPRAGMA2(a0, a1)
) (* end of [locpragma_encode] *)

implement
locpragma_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
locpragma_is_LOCPRAGMA0
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
locpragma_is_LOCPRAGMA1
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
locpragma_is_LOCPRAGMA2
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 2)

implement
locpragma_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => LOCPRAGMA0()
| 1 => LOCPRAGMA1(arena_load<string>(ptr_add<byte>(p, 8)))
| _ => LOCPRAGMA2(arena_load<string>(ptr_add<byte>(p, 8)), arena_load<string>(ptr_add<byte>(p, 16)))
//
end // end of [locpragma_view]

implement
locpragma_view_free
  (v) =
(
case+ v of
| ~LOCPRAGMA0() => ()
| ~LOCPRAGMA1(_) => ()
| ~LOCPRAGMA2(_, _) => ()
) (* end of [locpragma_view_free] *)

(* ****** ****** *)

implement
location_LOCATION
  (a0, a1, a2, a3, a4, a5, a6, a7) = let
val p = the_garena_alloc(i2sz(72))
val () = arena_store<int>(p, 0)
val () = arena_store<filename>(ptr_add<byte>(p, 8), a0)
val () = arena_store<lint>(ptr_add<byte>(p, 16), a1)
val () = arena_store<int>(ptr_add<byte>(p, 24), a2)
val () = arena_store<int>(ptr_add<byte>(p, 32), a3)
val () = arena_store<lint>(ptr_add<byte>(p, 40), a4)
val () = arena_store<int>(ptr_add<byte>(p, 48), a5)
val () = arena_store<int>(ptr_add<byte>(p, 56), a6)
val () = arena_store<locpragma>(ptr_add<byte>(p, 64), a7)
in
  $UN.cast{location}(p)
end // end of [location_LOCATION]

implement
location_encode
  (v) =
(
case+ v of
| ~LOCATION(a0, a1, a2, a3, a4, a5, a6, a7) => location_LOCATION(a0, a1, a2, a3, a4, a5, a6, a7)
) (* end of [location_encode] *)

implement
location_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
location_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| _ => LOCATION(arena_load<filename>(ptr_add<byte>(p, 8)), arena_load<lint>(ptr_add<byte>(p, 16)), arena_load<int>(ptr_add<byte>(p, 24)), arena_load<int>(ptr_add<byte>(p, 32)), arena_load<lint>(ptr_add<byte>(p, 40)), arena_load<int>(ptr_add<byte>(p, 48)), arena_load<int>(ptr_add<byte>(p, 56)), arena_load<locpragma>(ptr_add<byte>(p, 64)))
//
end // end of [location_view]

implement
location_view_free
  (v) =
(
case+ v of
| ~LOCATION(_, _, _, _, _, _, _, _) => ()
) (* end of [location_view_free] *)

implement
location_get_filename
  (x) =
  arena_load<filename>(ptr_add<byte>($UN.cast{ptr}(x), 8))

implement
location_get_beg_ntot
  (x) =
  arena_load<lint>(ptr_add<byte>($UN.cast{ptr}(x), 16))

implement
location_get_beg_nrow
  (x) =
  arena_load<int>(ptr_add<byte>($UN.cast{ptr}(x), 24))

implement
location_get_beg_ncol
  (x) =
  arena_load<int>(ptr_add<byte>($UN.cast{ptr}(x), 32))

implement
location_get_end_ntot
  (x) =
  arena_load<lint>(ptr_add<byte>($UN.cast{ptr}(x), 40))

implement
location_get_end_nrow
  (x) =
  arena_load<int>(ptr_add<byte>($UN.cast{ptr}(x), 48))

implement
location_get_end_ncol
  (x) =
  arena_load<int>(ptr_add<byte>($UN.cast{ptr}(x), 56))

implement
location_get_locpragma
  (x) =
  arena_load<locpragma>(ptr_add<byte>($UN.cast{ptr}(x), 64))

(* ****** ****** *)
