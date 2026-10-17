implement
form_FORMint
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{form(l)}(p)
end // end of [form_FORMint]

implement
form_FORMbool
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 1)
val () = arena_store<bool>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{form(l)}(p)
end // end of [form_FORMbool]

implement
form_FORMintrep
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 2)
val () = arena_store<astring(l)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{form(l)}(p)
end // end of [form_FORMintrep]

implement
form_FORMs2var
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 3)
val () = arena_store<s2var(l)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{form(l)}(p)
end // end of [form_FORMs2var]

implement
form_FORMs2cst
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 4)
val () = arena_store<s2cst(l)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{form(l)}(p)
end // end of [form_FORMs2cst]

implement
form_FORMs2exp
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 5)
val () = arena_store<s2exp(l)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{form(l)}(p)
end // end of [form_FORMs2exp]

implement
form_FORMnot
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 6)
val () = arena_store<form(l)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{form(l)}(p)
end // end of [form_FORMnot]

implement
form_FORMconj
  {l}(ar, a0, a1) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 7)
val () = arena_store<form(l)>(ptr_add<byte>(p, 8), a0)
val () = arena_store<form(l)>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{form(l)}(p)
end // end of [form_FORMconj]

implement
form_FORMdisj
  {l}(ar, a0, a1) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 8)
val () = arena_store<form(l)>(ptr_add<byte>(p, 8), a0)
val () = arena_store<form(l)>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{form(l)}(p)
end // end of [form_FORMdisj]

implement
form_FORMimpl
  {l}(ar, a0, a1) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 9)
val () = arena_store<form(l)>(ptr_add<byte>(p, 8), a0)
val () = arena_store<form(l)>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{form(l)}(p)
end // end of [form_FORMimpl]

implement
form_encode
  {l}(ar, v) =
(
case+ v of
| ~FORMint(a0) => form_FORMint(ar, a0)
| ~FORMbool(a0) => form_FORMbool(ar, a0)
| ~FORMintrep(a0) => form_FORMintrep(ar, a0)
| ~FORMs2var(a0) => form_FORMs2var(ar, a0)
| ~FORMs2cst(a0) => form_FORMs2cst(ar, a0)
| ~FORMs2exp(a0) => form_FORMs2exp(ar, a0)
| ~FORMnot(a0) => form_FORMnot(ar, a0)
| ~FORMconj(a0, a1) => form_FORMconj(ar, a0, a1)
| ~FORMdisj(a0, a1) => form_FORMdisj(ar, a0, a1)
| ~FORMimpl(a0, a1) => form_FORMimpl(ar, a0, a1)
) (* end of [form_encode] *)

implement
form_tag
  (ar, x) = arena_load<int>($UN.cast{ptr}(x))

implement
form_is_FORMint
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
form_is_FORMbool
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
form_is_FORMintrep
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 2)

implement
form_is_FORMs2var
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 3)

implement
form_is_FORMs2cst
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 4)

implement
form_is_FORMs2exp
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 5)

implement
form_is_FORMnot
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 6)

implement
form_is_FORMconj
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 7)

implement
form_is_FORMdisj
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 8)

implement
form_is_FORMimpl
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 9)

implement
form_view
  {l}(ar, x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => FORMint(arena_load<int>(ptr_add<byte>(p, 8)))
| 1 => FORMbool(arena_load<bool>(ptr_add<byte>(p, 8)))
| 2 => FORMintrep(arena_load<astring(l)>(ptr_add<byte>(p, 8)))
| 3 => FORMs2var(arena_load<s2var(l)>(ptr_add<byte>(p, 8)))
| 4 => FORMs2cst(arena_load<s2cst(l)>(ptr_add<byte>(p, 8)))
| 5 => FORMs2exp(arena_load<s2exp(l)>(ptr_add<byte>(p, 8)))
| 6 => FORMnot(arena_load<form(l)>(ptr_add<byte>(p, 8)))
| 7 => FORMconj(arena_load<form(l)>(ptr_add<byte>(p, 8)), arena_load<form(l)>(ptr_add<byte>(p, 16)))
| 8 => FORMdisj(arena_load<form(l)>(ptr_add<byte>(p, 8)), arena_load<form(l)>(ptr_add<byte>(p, 16)))
| _ => FORMimpl(arena_load<form(l)>(ptr_add<byte>(p, 8)), arena_load<form(l)>(ptr_add<byte>(p, 16)))
//
end // end of [form_view]

implement
form_view_free
  (v) =
(
case+ v of
| ~FORMint(_) => ()
| ~FORMbool(_) => ()
| ~FORMintrep(_) => ()
| ~FORMs2var(_) => ()
| ~FORMs2cst(_) => ()
| ~FORMs2exp(_) => ()
| ~FORMnot(_) => ()
| ~FORMconj(_, _) => ()
| ~FORMdisj(_, _) => ()
| ~FORMimpl(_, _) => ()
) (* end of [form_view_free] *)

(* ****** ****** *)
