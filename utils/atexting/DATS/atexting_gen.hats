implement
token_node_TOKeol
  () = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_TOKeol]

implement
token_node_TOKeof
  () = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 1)
in
  $UN.cast{token_node}(p)
end // end of [token_node_TOKeof]

implement
token_node_TOKint
  (a0) = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 2)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_TOKint]

implement
token_node_TOKide
  (a0) = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 3)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_TOKide]

implement
token_node_TOKspchr
  (a0) = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 4)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_TOKspchr]

implement
token_node_TOKbslash
  (a0) = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 5)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_TOKbslash]

implement
token_node_TOKspace
  (a0) = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 6)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_TOKspace]

implement
token_node_TOKsharp
  (a0) = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 7)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_TOKsharp]

implement
token_node_TOKsquote
  () = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 8)
in
  $UN.cast{token_node}(p)
end // end of [token_node_TOKsquote]

implement
token_node_TOKdquote
  (a0) = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 9)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_TOKdquote]

implement
token_node_TOKcode_beg
  (a0) = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 10)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_TOKcode_beg]

implement
token_node_TOKcode_end
  (a0) = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 11)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_TOKcode_end]

implement
token_node_encode
  (v) =
(
case+ v of
| ~TOKeol() => token_node_TOKeol()
| ~TOKeof() => token_node_TOKeof()
| ~TOKint(a0) => token_node_TOKint(a0)
| ~TOKide(a0) => token_node_TOKide(a0)
| ~TOKspchr(a0) => token_node_TOKspchr(a0)
| ~TOKbslash(a0) => token_node_TOKbslash(a0)
| ~TOKspace(a0) => token_node_TOKspace(a0)
| ~TOKsharp(a0) => token_node_TOKsharp(a0)
| ~TOKsquote() => token_node_TOKsquote()
| ~TOKdquote(a0) => token_node_TOKdquote(a0)
| ~TOKcode_beg(a0) => token_node_TOKcode_beg(a0)
| ~TOKcode_end(a0) => token_node_TOKcode_end(a0)
) (* end of [token_node_encode] *)

implement
token_node_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
token_node_is_TOKeol
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
token_node_is_TOKeof
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
token_node_is_TOKint
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 2)

implement
token_node_is_TOKide
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 3)

implement
token_node_is_TOKspchr
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 4)

implement
token_node_is_TOKbslash
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 5)

implement
token_node_is_TOKspace
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 6)

implement
token_node_is_TOKsharp
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 7)

implement
token_node_is_TOKsquote
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 8)

implement
token_node_is_TOKdquote
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 9)

implement
token_node_is_TOKcode_beg
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 10)

implement
token_node_is_TOKcode_end
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 11)

implement
token_node_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => TOKeol()
| 1 => TOKeof()
| 2 => TOKint(arena_load<string>(ptr_add<byte>(p, 8)))
| 3 => TOKide(arena_load<string>(ptr_add<byte>(p, 8)))
| 4 => TOKspchr(arena_load<int>(ptr_add<byte>(p, 8)))
| 5 => TOKbslash(arena_load<int>(ptr_add<byte>(p, 8)))
| 6 => TOKspace(arena_load<string>(ptr_add<byte>(p, 8)))
| 7 => TOKsharp(arena_load<string>(ptr_add<byte>(p, 8)))
| 8 => TOKsquote()
| 9 => TOKdquote(arena_load<string>(ptr_add<byte>(p, 8)))
| 10 => TOKcode_beg(arena_load<string>(ptr_add<byte>(p, 8)))
| _ => TOKcode_end(arena_load<string>(ptr_add<byte>(p, 8)))
//
end // end of [token_node_view]

implement
token_node_view_free
  (v) =
(
case+ v of
| ~TOKeol() => ()
| ~TOKeof() => ()
| ~TOKint(_) => ()
| ~TOKide(_) => ()
| ~TOKspchr(_) => ()
| ~TOKbslash(_) => ()
| ~TOKspace(_) => ()
| ~TOKsharp(_) => ()
| ~TOKsquote() => ()
| ~TOKdquote(_) => ()
| ~TOKcode_beg(_) => ()
| ~TOKcode_end(_) => ()
) (* end of [token_node_view_free] *)

(* ****** ****** *)

implement
token_TOKEN
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<loc_t>(ptr_add<byte>(p, 8), a0)
val () = arena_store<token_node>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{token}(p)
end // end of [token_TOKEN]

implement
token_encode
  (v) =
(
case+ v of
| ~TOKEN(a0, a1) => token_TOKEN(a0, a1)
) (* end of [token_encode] *)

implement
token_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
token_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| _ => TOKEN(arena_load<loc_t>(ptr_add<byte>(p, 8)), arena_load<token_node>(ptr_add<byte>(p, 16)))
//
end // end of [token_view]

implement
token_view_free
  (v) =
(
case+ v of
| ~TOKEN(_, _) => ()
) (* end of [token_view_free] *)

implement
token_get_token_loc
  (x) =
  arena_load<loc_t>(ptr_add<byte>($UN.cast{ptr}(x), 8))

implement
token_get_token_node
  (x) =
  arena_load<token_node>(ptr_add<byte>($UN.cast{ptr}(x), 16))

(* ****** ****** *)

implement
atext_node_TEXTnil
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 0)
in
  $UN.cast{atext_node}(p)
end // end of [atext_node_TEXTnil]

implement
atext_node_TEXTtoken
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 1)
val () = arena_store<token>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{atext_node}(p)
end // end of [atext_node_TEXTtoken]

implement
atext_node_TEXTstring
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 2)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{atext_node}(p)
end // end of [atext_node_TEXTstring]

implement
atext_node_TEXTerrmsg
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 3)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{atext_node}(p)
end // end of [atext_node_TEXTerrmsg]

implement
atext_node_TEXTlist
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 4)
val () = arena_store<glist(atext)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{atext_node}(p)
end // end of [atext_node_TEXTlist]

implement
atext_node_TEXTsquote
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 5)
val () = arena_store<glist(atext)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{atext_node}(p)
end // end of [atext_node_TEXTsquote]

implement
atext_node_TEXTdquote
  (a0, a1) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 6)
val () = arena_store<token>(ptr_add<byte>(p, 8), a0)
val () = arena_store<glist(atext)>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{atext_node}(p)
end // end of [atext_node_TEXTdquote]

implement
atext_node_TEXTextcode
  (a0, a1, a2) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 7)
val () = arena_store<token>(ptr_add<byte>(p, 8), a0)
val () = arena_store<glist(atext)>(ptr_add<byte>(p, 16), a1)
val () = arena_store<token>(ptr_add<byte>(p, 24), a2)
in
  $UN.cast{atext_node}(p)
end // end of [atext_node_TEXTextcode]

implement
atext_node_TEXTdefname
  (a0, a1) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 8)
val () = arena_store<token>(ptr_add<byte>(p, 8), a0)
val () = arena_store<token>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{atext_node}(p)
end // end of [atext_node_TEXTdefname]

implement
atext_node_TEXTfuncall
  (a0, a1, a2) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 9)
val () = arena_store<token>(ptr_add<byte>(p, 8), a0)
val () = arena_store<token>(ptr_add<byte>(p, 16), a1)
val () = arena_store<glist(atext)>(ptr_add<byte>(p, 24), a2)
in
  $UN.cast{atext_node}(p)
end // end of [atext_node_TEXTfuncall]

implement
atext_node_encode
  (v) =
(
case+ v of
| ~TEXTnil() => atext_node_TEXTnil()
| ~TEXTtoken(a0) => atext_node_TEXTtoken(a0)
| ~TEXTstring(a0) => atext_node_TEXTstring(a0)
| ~TEXTerrmsg(a0) => atext_node_TEXTerrmsg(a0)
| ~TEXTlist(a0) => atext_node_TEXTlist(a0)
| ~TEXTsquote(a0) => atext_node_TEXTsquote(a0)
| ~TEXTdquote(a0, a1) => atext_node_TEXTdquote(a0, a1)
| ~TEXTextcode(a0, a1, a2) => atext_node_TEXTextcode(a0, a1, a2)
| ~TEXTdefname(a0, a1) => atext_node_TEXTdefname(a0, a1)
| ~TEXTfuncall(a0, a1, a2) => atext_node_TEXTfuncall(a0, a1, a2)
) (* end of [atext_node_encode] *)

implement
atext_node_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
atext_node_is_TEXTnil
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
atext_node_is_TEXTtoken
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
atext_node_is_TEXTstring
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 2)

implement
atext_node_is_TEXTerrmsg
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 3)

implement
atext_node_is_TEXTlist
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 4)

implement
atext_node_is_TEXTsquote
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 5)

implement
atext_node_is_TEXTdquote
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 6)

implement
atext_node_is_TEXTextcode
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 7)

implement
atext_node_is_TEXTdefname
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 8)

implement
atext_node_is_TEXTfuncall
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 9)

implement
atext_node_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => TEXTnil()
| 1 => TEXTtoken(arena_load<token>(ptr_add<byte>(p, 8)))
| 2 => TEXTstring(arena_load<string>(ptr_add<byte>(p, 8)))
| 3 => TEXTerrmsg(arena_load<string>(ptr_add<byte>(p, 8)))
| 4 => TEXTlist(arena_load<glist(atext)>(ptr_add<byte>(p, 8)))
| 5 => TEXTsquote(arena_load<glist(atext)>(ptr_add<byte>(p, 8)))
| 6 => TEXTdquote(arena_load<token>(ptr_add<byte>(p, 8)), arena_load<glist(atext)>(ptr_add<byte>(p, 16)))
| 7 => TEXTextcode(arena_load<token>(ptr_add<byte>(p, 8)), arena_load<glist(atext)>(ptr_add<byte>(p, 16)), arena_load<token>(ptr_add<byte>(p, 24)))
| 8 => TEXTdefname(arena_load<token>(ptr_add<byte>(p, 8)), arena_load<token>(ptr_add<byte>(p, 16)))
| _ => TEXTfuncall(arena_load<token>(ptr_add<byte>(p, 8)), arena_load<token>(ptr_add<byte>(p, 16)), arena_load<glist(atext)>(ptr_add<byte>(p, 24)))
//
end // end of [atext_node_view]

implement
atext_node_view_free
  (v) =
(
case+ v of
| ~TEXTnil() => ()
| ~TEXTtoken(_) => ()
| ~TEXTstring(_) => ()
| ~TEXTerrmsg(_) => ()
| ~TEXTlist(_) => ()
| ~TEXTsquote(_) => ()
| ~TEXTdquote(_, _) => ()
| ~TEXTextcode(_, _, _) => ()
| ~TEXTdefname(_, _) => ()
| ~TEXTfuncall(_, _, _) => ()
) (* end of [atext_node_view_free] *)

(* ****** ****** *)

implement
atext_ATEXT
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<loc_t>(ptr_add<byte>(p, 8), a0)
val () = arena_store<atext_node>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{atext}(p)
end // end of [atext_ATEXT]

implement
atext_encode
  (v) =
(
case+ v of
| ~ATEXT(a0, a1) => atext_ATEXT(a0, a1)
) (* end of [atext_encode] *)

implement
atext_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
atext_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| _ => ATEXT(arena_load<loc_t>(ptr_add<byte>(p, 8)), arena_load<atext_node>(ptr_add<byte>(p, 16)))
//
end // end of [atext_view]

implement
atext_view_free
  (v) =
(
case+ v of
| ~ATEXT(_, _) => ()
) (* end of [atext_view_free] *)

implement
atext_get_atext_loc
  (x) =
  arena_load<loc_t>(ptr_add<byte>($UN.cast{ptr}(x), 8))

implement
atext_get_atext_node
  (x) =
  arena_load<atext_node>(ptr_add<byte>($UN.cast{ptr}(x), 16))

(* ****** ****** *)

implement
parerr_node_PARERR_SQUOTE
  (a0) = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 0)
val () = arena_store<loc_t>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{parerr_node}(p)
end // end of [parerr_node_PARERR_SQUOTE]

implement
parerr_node_PARERR_DQUOTE
  (a0) = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 1)
val () = arena_store<loc_t>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{parerr_node}(p)
end // end of [parerr_node_PARERR_DQUOTE]

implement
parerr_node_PARERR_FUNARG
  (a0) = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 2)
val () = arena_store<loc_t>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{parerr_node}(p)
end // end of [parerr_node_PARERR_FUNARG]

implement
parerr_node_PARERR_EXTCODE
  (a0) = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 3)
val () = arena_store<loc_t>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{parerr_node}(p)
end // end of [parerr_node_PARERR_EXTCODE]

implement
parerr_node_encode
  (v) =
(
case+ v of
| ~PARERR_SQUOTE(a0) => parerr_node_PARERR_SQUOTE(a0)
| ~PARERR_DQUOTE(a0) => parerr_node_PARERR_DQUOTE(a0)
| ~PARERR_FUNARG(a0) => parerr_node_PARERR_FUNARG(a0)
| ~PARERR_EXTCODE(a0) => parerr_node_PARERR_EXTCODE(a0)
) (* end of [parerr_node_encode] *)

implement
parerr_node_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
parerr_node_is_PARERR_SQUOTE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
parerr_node_is_PARERR_DQUOTE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
parerr_node_is_PARERR_FUNARG
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 2)

implement
parerr_node_is_PARERR_EXTCODE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 3)

implement
parerr_node_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => PARERR_SQUOTE(arena_load<loc_t>(ptr_add<byte>(p, 8)))
| 1 => PARERR_DQUOTE(arena_load<loc_t>(ptr_add<byte>(p, 8)))
| 2 => PARERR_FUNARG(arena_load<loc_t>(ptr_add<byte>(p, 8)))
| _ => PARERR_EXTCODE(arena_load<loc_t>(ptr_add<byte>(p, 8)))
//
end // end of [parerr_node_view]

implement
parerr_node_view_free
  (v) =
(
case+ v of
| ~PARERR_SQUOTE(_) => ()
| ~PARERR_DQUOTE(_) => ()
| ~PARERR_FUNARG(_) => ()
| ~PARERR_EXTCODE(_) => ()
) (* end of [parerr_node_view_free] *)

(* ****** ****** *)

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
