implement
parerr_PARERR
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<loc_t>(ptr_add<byte>(p, 8), a0)
val () = arena_store<parerr_node>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{parerr}(p)
end // end of [parerr_PARERR]

implement
parerr_encode
  (v) =
(
case+ v of
| ~PARERR(a0, a1) => parerr_PARERR(a0, a1)
) (* end of [parerr_encode] *)

implement
parerr_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
parerr_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| _ => PARERR(arena_load<loc_t>(ptr_add<byte>(p, 8)), arena_load<parerr_node>(ptr_add<byte>(p, 16)))
//
end // end of [parerr_view]

implement
parerr_view_free
  (v) =
(
case+ v of
| ~PARERR(_, _) => ()
) (* end of [parerr_view_free] *)

implement
parerr_get_parerr_loc
  (x) =
  arena_load<loc_t>(ptr_add<byte>($UN.cast{ptr}(x), 8))

implement
parerr_get_parerr_node
  (x) =
  arena_load<parerr_node>(ptr_add<byte>($UN.cast{ptr}(x), 16))

(* ****** ****** *)
