implement
expr_EXPRnum
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 0)
val () = arena_store<double>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{expr}(p)
end // end of [expr_EXPRnum]

implement
expr_EXPRbop
  (a0, a1, a2) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 1)
val () = arena_store<char>(ptr_add<byte>(p, 8), a0)
val () = arena_store<expr>(ptr_add<byte>(p, 16), a1)
val () = arena_store<expr>(ptr_add<byte>(p, 24), a2)
in
  $UN.cast{expr}(p)
end // end of [expr_EXPRbop]

implement
expr_encode
  (v) =
(
case+ v of
| ~EXPRnum(a0) => expr_EXPRnum(a0)
| ~EXPRbop(a0, a1, a2) => expr_EXPRbop(a0, a1, a2)
) (* end of [expr_encode] *)

implement
expr_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
expr_is_EXPRnum
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
expr_is_EXPRbop
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
expr_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => EXPRnum(arena_load<double>(ptr_add<byte>(p, 8)))
| _ => EXPRbop(arena_load<char>(ptr_add<byte>(p, 8)), arena_load<expr>(ptr_add<byte>(p, 16)), arena_load<expr>(ptr_add<byte>(p, 24)))
//
end // end of [expr_view]

implement
expr_view_free
  (v) =
(
case+ v of
| ~EXPRnum(_) => ()
| ~EXPRbop(_, _, _) => ()
) (* end of [expr_view_free] *)

(* ****** ****** *)
