implement
label_LABint
  (a0) = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 0)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{label}(p)
end // end of [label_LABint]

implement
label_LABsym
  (a0) = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 1)
val () = arena_store<symbol>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{label}(p)
end // end of [label_LABsym]

implement
label_encode
  (v) =
(
case+ v of
| ~LABint(a0) => label_LABint(a0)
| ~LABsym(a0) => label_LABsym(a0)
) (* end of [label_encode] *)

implement
label_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
label_is_LABint
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
label_is_LABsym
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
label_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => LABint(arena_load<int>(ptr_add<byte>(p, 8)))
| _ => LABsym(arena_load<symbol>(ptr_add<byte>(p, 8)))
//
end // end of [label_view]

implement
label_view_free
  (v) =
(
case+ v of
| ~LABint(_) => ()
| ~LABsym(_) => ()
) (* end of [label_view_free] *)

(* ****** ****** *)
