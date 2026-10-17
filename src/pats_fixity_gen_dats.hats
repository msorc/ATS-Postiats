implement
fxty_FXTYnon
  () = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
in
  $UN.cast{fxty}(p)
end // end of [fxty_FXTYnon]

implement
fxty_FXTYinf
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 1)
val () = arena_store<prec>(ptr_add<byte>(p, 8), a0)
val () = arena_store<assoc>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{fxty}(p)
end // end of [fxty_FXTYinf]

implement
fxty_FXTYpre
  (a0) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 2)
val () = arena_store<prec>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{fxty}(p)
end // end of [fxty_FXTYpre]

implement
fxty_FXTYpos
  (a0) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 3)
val () = arena_store<prec>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{fxty}(p)
end // end of [fxty_FXTYpos]

implement
fxty_encode
  (v) =
(
case+ v of
| ~FXTYnon() => fxty_FXTYnon()
| ~FXTYinf(a0, a1) => fxty_FXTYinf(a0, a1)
| ~FXTYpre(a0) => fxty_FXTYpre(a0)
| ~FXTYpos(a0) => fxty_FXTYpos(a0)
) (* end of [fxty_encode] *)

implement
fxty_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
fxty_is_FXTYnon
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
fxty_is_FXTYinf
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
fxty_is_FXTYpre
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 2)

implement
fxty_is_FXTYpos
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 3)

implement
fxty_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => FXTYnon()
| 1 => FXTYinf(arena_load<prec>(ptr_add<byte>(p, 8)), arena_load<assoc>(ptr_add<byte>(p, 16)))
| 2 => FXTYpre(arena_load<prec>(ptr_add<byte>(p, 8)))
| _ => FXTYpos(arena_load<prec>(ptr_add<byte>(p, 8)))
//
end // end of [fxty_view]

implement
fxty_view_free
  (v) =
(
case+ v of
| ~FXTYnon() => ()
| ~FXTYinf(_, _) => ()
| ~FXTYpre(_) => ()
| ~FXTYpos(_) => ()
) (* end of [fxty_view_free] *)

(* ****** ****** *)
