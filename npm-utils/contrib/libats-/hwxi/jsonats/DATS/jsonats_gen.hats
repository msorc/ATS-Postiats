implement
jsonval_JSONnul
  () = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 0)
in
  $UN.cast{jsonval}(p)
end // end of [jsonval_JSONnul]

implement
jsonval_JSONbool
  (a0) = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 1)
val () = arena_store<bool>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{jsonval}(p)
end // end of [jsonval_JSONbool]

implement
jsonval_JSONint
  (a0) = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 2)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{jsonval}(p)
end // end of [jsonval_JSONint]

implement
jsonval_JSONfloat
  (a0) = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 3)
val () = arena_store<double>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{jsonval}(p)
end // end of [jsonval_JSONfloat]

implement
jsonval_JSONstring
  (a0) = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 4)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{jsonval}(p)
end // end of [jsonval_JSONstring]

implement
jsonval_JSONarray
  (a0) = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 5)
val () = arena_store<glist(jsonval)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{jsonval}(p)
end // end of [jsonval_JSONarray]

implement
jsonval_JSONobject
  (a0) = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 6)
val () = arena_store<glist(@(string, jsonval))>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{jsonval}(p)
end // end of [jsonval_JSONobject]

implement
jsonval_encode
  (v) =
(
case+ v of
| ~JSONnul() => jsonval_JSONnul()
| ~JSONbool(a0) => jsonval_JSONbool(a0)
| ~JSONint(a0) => jsonval_JSONint(a0)
| ~JSONfloat(a0) => jsonval_JSONfloat(a0)
| ~JSONstring(a0) => jsonval_JSONstring(a0)
| ~JSONarray(a0) => jsonval_JSONarray(a0)
| ~JSONobject(a0) => jsonval_JSONobject(a0)
) (* end of [jsonval_encode] *)

implement
jsonval_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
jsonval_is_JSONnul
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
jsonval_is_JSONbool
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
jsonval_is_JSONint
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 2)

implement
jsonval_is_JSONfloat
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 3)

implement
jsonval_is_JSONstring
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 4)

implement
jsonval_is_JSONarray
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 5)

implement
jsonval_is_JSONobject
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 6)

implement
jsonval_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => JSONnul()
| 1 => JSONbool(arena_load<bool>(ptr_add<byte>(p, 8)))
| 2 => JSONint(arena_load<int>(ptr_add<byte>(p, 8)))
| 3 => JSONfloat(arena_load<double>(ptr_add<byte>(p, 8)))
| 4 => JSONstring(arena_load<string>(ptr_add<byte>(p, 8)))
| 5 => JSONarray(arena_load<glist(jsonval)>(ptr_add<byte>(p, 8)))
| _ => JSONobject(arena_load<glist(@(string, jsonval))>(ptr_add<byte>(p, 8)))
//
end // end of [jsonval_view]

implement
jsonval_view_free
  (v) =
(
case+ v of
| ~JSONnul() => ()
| ~JSONbool(_) => ()
| ~JSONint(_) => ()
| ~JSONfloat(_) => ()
| ~JSONstring(_) => ()
| ~JSONarray(_) => ()
| ~JSONobject(_) => ()
) (* end of [jsonval_view_free] *)

(* ****** ****** *)
