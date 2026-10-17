implement
funarg_FAint
  (a0) = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 0)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{funarg}(p)
end // end of [funarg_FAint]

implement
funarg_FAident
  (a0) = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 1)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{funarg}(p)
end // end of [funarg_FAident]

implement
funarg_FAstrsub
  (a0) = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 2)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{funarg}(p)
end // end of [funarg_FAstrsub]

implement
funarg_FAfunres
  (a0) = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 3)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{funarg}(p)
end // end of [funarg_FAfunres]

implement
funarg_FAnil
  () = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 4)
in
  $UN.cast{funarg}(p)
end // end of [funarg_FAnil]

implement
funarg_encode
  (v) =
(
case+ v of
| ~FAint(a0) => funarg_FAint(a0)
| ~FAident(a0) => funarg_FAident(a0)
| ~FAstrsub(a0) => funarg_FAstrsub(a0)
| ~FAfunres(a0) => funarg_FAfunres(a0)
| ~FAnil() => funarg_FAnil()
) (* end of [funarg_encode] *)

implement
funarg_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
funarg_is_FAint
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
funarg_is_FAident
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
funarg_is_FAstrsub
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 2)

implement
funarg_is_FAfunres
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 3)

implement
funarg_is_FAnil
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 4)

implement
funarg_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => FAint(arena_load<string>(ptr_add<byte>(p, 8)))
| 1 => FAident(arena_load<string>(ptr_add<byte>(p, 8)))
| 2 => FAstrsub(arena_load<string>(ptr_add<byte>(p, 8)))
| 3 => FAfunres(arena_load<string>(ptr_add<byte>(p, 8)))
| _ => FAnil()
//
end // end of [funarg_view]

implement
funarg_view_free
  (v) =
(
case+ v of
| ~FAint(_) => ()
| ~FAident(_) => ()
| ~FAstrsub(_) => ()
| ~FAfunres(_) => ()
| ~FAnil() => ()
) (* end of [funarg_view_free] *)

(* ****** ****** *)

implement
tranitm_node_EXTCODE
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 0)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{tranitm_node}(p)
end // end of [tranitm_node_EXTCODE]

implement
tranitm_node_FUNCALL
  (a0, a1, a2, a3) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 1)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
val () = arena_store<int>(ptr_add<byte>(p, 16), a1)
val () = arena_store<funarglst>(ptr_add<byte>(p, 24), a2)
val () = arena_store<string>(ptr_add<byte>(p, 32), a3)
in
  $UN.cast{tranitm_node}(p)
end // end of [tranitm_node_FUNCALL]

implement
tranitm_node_encode
  (v) =
(
case+ v of
| ~EXTCODE(a0) => tranitm_node_EXTCODE(a0)
| ~FUNCALL(a0, a1, a2, a3) => tranitm_node_FUNCALL(a0, a1, a2, a3)
) (* end of [tranitm_node_encode] *)

implement
tranitm_node_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
tranitm_node_is_EXTCODE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
tranitm_node_is_FUNCALL
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
tranitm_node_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => EXTCODE(arena_load<string>(ptr_add<byte>(p, 8)))
| _ => FUNCALL(arena_load<string>(ptr_add<byte>(p, 8)), arena_load<int>(ptr_add<byte>(p, 16)), arena_load<funarglst>(ptr_add<byte>(p, 24)), arena_load<string>(ptr_add<byte>(p, 32)))
//
end // end of [tranitm_node_view]

implement
tranitm_node_view_free
  (v) =
(
case+ v of
| ~EXTCODE(_) => ()
| ~FUNCALL(_, _, _, _) => ()
) (* end of [tranitm_node_view_free] *)

(* ****** ****** *)

implement
tranitm_TRANITM
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<location>(ptr_add<byte>(p, 8), a0)
val () = arena_store<tranitm_node>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{tranitm}(p)
end // end of [tranitm_TRANITM]

implement
tranitm_encode
  (v) =
(
case+ v of
| ~TRANITM(a0, a1) => tranitm_TRANITM(a0, a1)
) (* end of [tranitm_encode] *)

implement
tranitm_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
tranitm_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| _ => TRANITM(arena_load<location>(ptr_add<byte>(p, 8)), arena_load<tranitm_node>(ptr_add<byte>(p, 16)))
//
end // end of [tranitm_view]

implement
tranitm_view_free
  (v) =
(
case+ v of
| ~TRANITM(_, _) => ()
) (* end of [tranitm_view_free] *)

implement
tranitm_get_tranitm_loc
  (x) =
  arena_load<location>(ptr_add<byte>($UN.cast{ptr}(x), 8))

implement
tranitm_get_tranitm_node
  (x) =
  arena_load<tranitm_node>(ptr_add<byte>($UN.cast{ptr}(x), 16))

(* ****** ****** *)

implement
docerr_DOCERR
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<location>(ptr_add<byte>(p, 8), a0)
val () = arena_store<int>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{docerr}(p)
end // end of [docerr_DOCERR]

implement
docerr_encode
  (v) =
(
case+ v of
| ~DOCERR(a0, a1) => docerr_DOCERR(a0, a1)
) (* end of [docerr_encode] *)

implement
docerr_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
docerr_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| _ => DOCERR(arena_load<location>(ptr_add<byte>(p, 8)), arena_load<int>(ptr_add<byte>(p, 16)))
//
end // end of [docerr_view]

implement
docerr_view_free
  (v) =
(
case+ v of
| ~DOCERR(_, _) => ()
) (* end of [docerr_view_free] *)

implement
docerr_get_docerr_loc
  (x) =
  arena_load<location>(ptr_add<byte>($UN.cast{ptr}(x), 8))

implement
docerr_get_docerr_node
  (x) =
  arena_load<int>(ptr_add<byte>($UN.cast{ptr}(x), 16))

(* ****** ****** *)
