implement
tree_TREEnil
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 0)
in
  $UN.cast{tree}(p)
end // end of [tree_TREEnil]

implement
tree_TREEcons
  (a0, a1, a2) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 1)
val () = arena_store<tree>(ptr_add<byte>(p, 8), a0)
val () = arena_store<int>(ptr_add<byte>(p, 16), a1)
val () = arena_store<tree>(ptr_add<byte>(p, 24), a2)
in
  $UN.cast{tree}(p)
end // end of [tree_TREEcons]

implement
tree_encode
  (v) =
(
case+ v of
| ~TREEnil() => tree_TREEnil()
| ~TREEcons(a0, a1, a2) => tree_TREEcons(a0, a1, a2)
) (* end of [tree_encode] *)

implement
tree_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
tree_is_TREEnil
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
tree_is_TREEcons
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
tree_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => TREEnil()
| _ => TREEcons(arena_load<tree>(ptr_add<byte>(p, 8)), arena_load<int>(ptr_add<byte>(p, 16)), arena_load<tree>(ptr_add<byte>(p, 24)))
//
end // end of [tree_view]

implement
tree_view_free
  (v) =
(
case+ v of
| ~TREEnil() => ()
| ~TREEcons(_, _, _) => ()
) (* end of [tree_view_free] *)

(* ****** ****** *)
