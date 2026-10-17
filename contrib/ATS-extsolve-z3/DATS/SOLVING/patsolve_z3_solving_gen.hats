implement
s2cinterp_S2CINTnone
  {l}(ar) = let
val p = arena_alloc(ar, i2sz(16))
val () = arena_store<int>(p, 0)
in
  $UN.cast{s2cinterp(l)}(p)
end // end of [s2cinterp_S2CINTnone]

implement
s2cinterp_S2CINTsome
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(16))
val () = arena_store<int>(p, 1)
val () = arena_store<ptr>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{s2cinterp(l)}(p)
end // end of [s2cinterp_S2CINTsome]

implement
s2cinterp_S2CINTbuiltin_0
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(16))
val () = arena_store<int>(p, 2)
val () = arena_store<fopr0>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{s2cinterp(l)}(p)
end // end of [s2cinterp_S2CINTbuiltin_0]

implement
s2cinterp_S2CINTbuiltin_1
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(16))
val () = arena_store<int>(p, 3)
val () = arena_store<fopr1>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{s2cinterp(l)}(p)
end // end of [s2cinterp_S2CINTbuiltin_1]

implement
s2cinterp_S2CINTbuiltin_2
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(16))
val () = arena_store<int>(p, 4)
val () = arena_store<fopr2>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{s2cinterp(l)}(p)
end // end of [s2cinterp_S2CINTbuiltin_2]

implement
s2cinterp_S2CINTbuiltin_list
  {l}(ar) = let
val p = arena_alloc(ar, i2sz(16))
val () = arena_store<int>(p, 5)
in
  $UN.cast{s2cinterp(l)}(p)
end // end of [s2cinterp_S2CINTbuiltin_list]

implement
s2cinterp_encode
  {l}(ar, v) =
(
case+ v of
| ~S2CINTnone() => s2cinterp_S2CINTnone(ar)
| ~S2CINTsome(a0) => s2cinterp_S2CINTsome(ar, a0)
| ~S2CINTbuiltin_0(a0) => s2cinterp_S2CINTbuiltin_0(ar, a0)
| ~S2CINTbuiltin_1(a0) => s2cinterp_S2CINTbuiltin_1(ar, a0)
| ~S2CINTbuiltin_2(a0) => s2cinterp_S2CINTbuiltin_2(ar, a0)
| ~S2CINTbuiltin_list() => s2cinterp_S2CINTbuiltin_list(ar)
) (* end of [s2cinterp_encode] *)

implement
s2cinterp_tag
  (ar, x) = arena_load<int>($UN.cast{ptr}(x))

implement
s2cinterp_is_S2CINTnone
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
s2cinterp_is_S2CINTsome
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
s2cinterp_is_S2CINTbuiltin_0
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 2)

implement
s2cinterp_is_S2CINTbuiltin_1
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 3)

implement
s2cinterp_is_S2CINTbuiltin_2
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 4)

implement
s2cinterp_is_S2CINTbuiltin_list
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 5)

implement
s2cinterp_view
  {l}(ar, x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => S2CINTnone()
| 1 => S2CINTsome(arena_load<ptr>(ptr_add<byte>(p, 8)))
| 2 => S2CINTbuiltin_0(arena_load<fopr0>(ptr_add<byte>(p, 8)))
| 3 => S2CINTbuiltin_1(arena_load<fopr1>(ptr_add<byte>(p, 8)))
| 4 => S2CINTbuiltin_2(arena_load<fopr2>(ptr_add<byte>(p, 8)))
| _ => S2CINTbuiltin_list()
//
end // end of [s2cinterp_view]

implement
s2cinterp_view_free
  (v) =
(
case+ v of
| ~S2CINTnone() => ()
| ~S2CINTsome(_) => ()
| ~S2CINTbuiltin_0(_) => ()
| ~S2CINTbuiltin_1(_) => ()
| ~S2CINTbuiltin_2(_) => ()
| ~S2CINTbuiltin_list() => ()
) (* end of [s2cinterp_view_free] *)

(* ****** ****** *)
