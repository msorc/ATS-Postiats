implement
token_node_T_KWORD
  (a0) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<keyword>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_KWORD]

implement
token_node_T_IDENT_alp
  (a0) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 1)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_IDENT_alp]

implement
token_node_T_IDENT_sym
  (a0) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 2)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_IDENT_sym]

implement
token_node_T_IDENT_srp
  (a0) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 3)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_IDENT_srp]

implement
token_node_T_CHAR
  (a0) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 4)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_CHAR]

implement
token_node_T_INT
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 5)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
val () = arena_store<string>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_INT]

implement
token_node_T_FLOAT
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 6)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
val () = arena_store<string>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_FLOAT]

implement
token_node_T_STRING
  (a0) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 7)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_STRING]

implement
token_node_T_LPAREN
  () = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 8)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_LPAREN]

implement
token_node_T_RPAREN
  () = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 9)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_RPAREN]

implement
token_node_T_LBRACKET
  () = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 10)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_LBRACKET]

implement
token_node_T_RBRACKET
  () = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 11)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_RBRACKET]

implement
token_node_T_LBRACE
  () = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 12)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_LBRACE]

implement
token_node_T_RBRACE
  () = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 13)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_RBRACE]

implement
token_node_T_LT
  () = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 14)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_LT]

implement
token_node_T_GT
  () = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 15)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_GT]

implement
token_node_T_MINUS
  () = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 16)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_MINUS]

implement
token_node_T_COLON
  () = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 17)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_COLON]

implement
token_node_T_COMMA
  () = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 18)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_COMMA]

implement
token_node_T_SEMICOLON
  () = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 19)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SEMICOLON]

implement
token_node_T_SLASH
  () = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 20)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SLASH]

implement
token_node_T_ENDL
  () = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 21)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_ENDL]

implement
token_node_T_SPACES
  (a0) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 22)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SPACES]

implement
token_node_T_COMMENT_line
  (a0) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 23)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_COMMENT_line]

implement
token_node_T_COMMENT_block
  (a0) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 24)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_COMMENT_block]

implement
token_node_T_EOF
  () = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 25)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_EOF]

implement
token_node_encode
  (v) =
(
case+ v of
| ~T_KWORD(a0) => token_node_T_KWORD(a0)
| ~T_IDENT_alp(a0) => token_node_T_IDENT_alp(a0)
| ~T_IDENT_sym(a0) => token_node_T_IDENT_sym(a0)
| ~T_IDENT_srp(a0) => token_node_T_IDENT_srp(a0)
| ~T_CHAR(a0) => token_node_T_CHAR(a0)
| ~T_INT(a0, a1) => token_node_T_INT(a0, a1)
| ~T_FLOAT(a0, a1) => token_node_T_FLOAT(a0, a1)
| ~T_STRING(a0) => token_node_T_STRING(a0)
| ~T_LPAREN() => token_node_T_LPAREN()
| ~T_RPAREN() => token_node_T_RPAREN()
| ~T_LBRACKET() => token_node_T_LBRACKET()
| ~T_RBRACKET() => token_node_T_RBRACKET()
| ~T_LBRACE() => token_node_T_LBRACE()
| ~T_RBRACE() => token_node_T_RBRACE()
| ~T_LT() => token_node_T_LT()
| ~T_GT() => token_node_T_GT()
| ~T_MINUS() => token_node_T_MINUS()
| ~T_COLON() => token_node_T_COLON()
| ~T_COMMA() => token_node_T_COMMA()
| ~T_SEMICOLON() => token_node_T_SEMICOLON()
| ~T_SLASH() => token_node_T_SLASH()
| ~T_ENDL() => token_node_T_ENDL()
| ~T_SPACES(a0) => token_node_T_SPACES(a0)
| ~T_COMMENT_line(a0) => token_node_T_COMMENT_line(a0)
| ~T_COMMENT_block(a0) => token_node_T_COMMENT_block(a0)
| ~T_EOF() => token_node_T_EOF()
) (* end of [token_node_encode] *)

implement
token_node_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
token_node_is_T_KWORD
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
token_node_is_T_IDENT_alp
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
token_node_is_T_IDENT_sym
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 2)

implement
token_node_is_T_IDENT_srp
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 3)

implement
token_node_is_T_CHAR
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 4)

implement
token_node_is_T_INT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 5)

implement
token_node_is_T_FLOAT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 6)

implement
token_node_is_T_STRING
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 7)

implement
token_node_is_T_LPAREN
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 8)

implement
token_node_is_T_RPAREN
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 9)

implement
token_node_is_T_LBRACKET
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 10)

implement
token_node_is_T_RBRACKET
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 11)

implement
token_node_is_T_LBRACE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 12)

implement
token_node_is_T_RBRACE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 13)

implement
token_node_is_T_LT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 14)

implement
token_node_is_T_GT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 15)

implement
token_node_is_T_MINUS
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 16)

implement
token_node_is_T_COLON
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 17)

implement
token_node_is_T_COMMA
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 18)

implement
token_node_is_T_SEMICOLON
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 19)

implement
token_node_is_T_SLASH
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 20)

implement
token_node_is_T_ENDL
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 21)

implement
token_node_is_T_SPACES
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 22)

implement
token_node_is_T_COMMENT_line
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 23)

implement
token_node_is_T_COMMENT_block
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 24)

implement
token_node_is_T_EOF
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 25)

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
| 0 => T_KWORD(arena_load<keyword>(ptr_add<byte>(p, 8)))
| 1 => T_IDENT_alp(arena_load<string>(ptr_add<byte>(p, 8)))
| 2 => T_IDENT_sym(arena_load<string>(ptr_add<byte>(p, 8)))
| 3 => T_IDENT_srp(arena_load<string>(ptr_add<byte>(p, 8)))
| 4 => T_CHAR(arena_load<string>(ptr_add<byte>(p, 8)))
| 5 => T_INT(arena_load<int>(ptr_add<byte>(p, 8)), arena_load<string>(ptr_add<byte>(p, 16)))
| 6 => T_FLOAT(arena_load<int>(ptr_add<byte>(p, 8)), arena_load<string>(ptr_add<byte>(p, 16)))
| 7 => T_STRING(arena_load<string>(ptr_add<byte>(p, 8)))
| 8 => T_LPAREN()
| 9 => T_RPAREN()
| 10 => T_LBRACKET()
| 11 => T_RBRACKET()
| 12 => T_LBRACE()
| 13 => T_RBRACE()
| 14 => T_LT()
| 15 => T_GT()
| 16 => T_MINUS()
| 17 => T_COLON()
| 18 => T_COMMA()
| 19 => T_SEMICOLON()
| 20 => T_SLASH()
| 21 => T_ENDL()
| 22 => T_SPACES(arena_load<string>(ptr_add<byte>(p, 8)))
| 23 => T_COMMENT_line(arena_load<string>(ptr_add<byte>(p, 8)))
| 24 => T_COMMENT_block(arena_load<string>(ptr_add<byte>(p, 8)))
| _ => T_EOF()
//
end // end of [token_node_view]

implement
token_node_view_free
  (v) =
(
case+ v of
| ~T_KWORD(_) => ()
| ~T_IDENT_alp(_) => ()
| ~T_IDENT_sym(_) => ()
| ~T_IDENT_srp(_) => ()
| ~T_CHAR(_) => ()
| ~T_INT(_, _) => ()
| ~T_FLOAT(_, _) => ()
| ~T_STRING(_) => ()
| ~T_LPAREN() => ()
| ~T_RPAREN() => ()
| ~T_LBRACKET() => ()
| ~T_RBRACKET() => ()
| ~T_LBRACE() => ()
| ~T_RBRACE() => ()
| ~T_LT() => ()
| ~T_GT() => ()
| ~T_MINUS() => ()
| ~T_COLON() => ()
| ~T_COMMA() => ()
| ~T_SEMICOLON() => ()
| ~T_SLASH() => ()
| ~T_ENDL() => ()
| ~T_SPACES(_) => ()
| ~T_COMMENT_line(_) => ()
| ~T_COMMENT_block(_) => ()
| ~T_EOF() => ()
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
lexerr_node_LEXERR_FEXPONENT_nil
  () = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 0)
in
  $UN.cast{lexerr_node}(p)
end // end of [lexerr_node_LEXERR_FEXPONENT_nil]

implement
lexerr_node_LEXERR_UNSUPPORTED_char
  (a0) = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 1)
val () = arena_store<char>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{lexerr_node}(p)
end // end of [lexerr_node_LEXERR_UNSUPPORTED_char]

implement
lexerr_node_encode
  (v) =
(
case+ v of
| ~LEXERR_FEXPONENT_nil() => lexerr_node_LEXERR_FEXPONENT_nil()
| ~LEXERR_UNSUPPORTED_char(a0) => lexerr_node_LEXERR_UNSUPPORTED_char(a0)
) (* end of [lexerr_node_encode] *)

implement
lexerr_node_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
lexerr_node_is_LEXERR_FEXPONENT_nil
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
lexerr_node_is_LEXERR_UNSUPPORTED_char
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
lexerr_node_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => LEXERR_FEXPONENT_nil()
| _ => LEXERR_UNSUPPORTED_char(arena_load<char>(ptr_add<byte>(p, 8)))
//
end // end of [lexerr_node_view]

implement
lexerr_node_view_free
  (v) =
(
case+ v of
| ~LEXERR_FEXPONENT_nil() => ()
| ~LEXERR_UNSUPPORTED_char(_) => ()
) (* end of [lexerr_node_view_free] *)

(* ****** ****** *)

implement
lexerr_LEXERR
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<loc_t>(ptr_add<byte>(p, 8), a0)
val () = arena_store<lexerr_node>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{lexerr}(p)
end // end of [lexerr_LEXERR]

implement
lexerr_encode
  (v) =
(
case+ v of
| ~LEXERR(a0, a1) => lexerr_LEXERR(a0, a1)
) (* end of [lexerr_encode] *)

implement
lexerr_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
lexerr_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| _ => LEXERR(arena_load<loc_t>(ptr_add<byte>(p, 8)), arena_load<lexerr_node>(ptr_add<byte>(p, 16)))
//
end // end of [lexerr_view]

implement
lexerr_view_free
  (v) =
(
case+ v of
| ~LEXERR(_, _) => ()
) (* end of [lexerr_view_free] *)

implement
lexerr_get_lexerr_loc
  (x) =
  arena_load<loc_t>(ptr_add<byte>($UN.cast{ptr}(x), 8))

implement
lexerr_get_lexerr_node
  (x) =
  arena_load<lexerr_node>(ptr_add<byte>($UN.cast{ptr}(x), 16))

(* ****** ****** *)

implement
signed_SIGNED
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<loc_t>(ptr_add<byte>(p, 8), a0)
val () = arena_store<int>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{signed}(p)
end // end of [signed_SIGNED]

implement
signed_encode
  (v) =
(
case+ v of
| ~SIGNED(a0, a1) => signed_SIGNED(a0, a1)
) (* end of [signed_encode] *)

implement
signed_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
signed_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| _ => SIGNED(arena_load<loc_t>(ptr_add<byte>(p, 8)), arena_load<int>(ptr_add<byte>(p, 16)))
//
end // end of [signed_view]

implement
signed_view_free
  (v) =
(
case+ v of
| ~SIGNED(_, _) => ()
) (* end of [signed_view_free] *)

(* ****** ****** *)

implement
i0de_I0DE
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<loc_t>(ptr_add<byte>(p, 8), a0)
val () = arena_store<symbol>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{i0de}(p)
end // end of [i0de_I0DE]

implement
i0de_encode
  (v) =
(
case+ v of
| ~I0DE(a0, a1) => i0de_I0DE(a0, a1)
) (* end of [i0de_encode] *)

implement
i0de_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
i0de_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| _ => I0DE(arena_load<loc_t>(ptr_add<byte>(p, 8)), arena_load<symbol>(ptr_add<byte>(p, 16)))
//
end // end of [i0de_view]

implement
i0de_view_free
  (v) =
(
case+ v of
| ~I0DE(_, _) => ()
) (* end of [i0de_view_free] *)

implement
i0de_get_i0dex_loc
  (x) =
  arena_load<loc_t>(ptr_add<byte>($UN.cast{ptr}(x), 8))

implement
i0de_get_i0dex_sym
  (x) =
  arena_load<symbol>(ptr_add<byte>($UN.cast{ptr}(x), 16))

(* ****** ****** *)

implement
s0exp_node_S0Eide
  (a0) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<symbol>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{s0exp_node}(p)
end // end of [s0exp_node_S0Eide]

implement
s0exp_node_S0Elist
  (a0) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 1)
val () = arena_store<glist(s0exp)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{s0exp_node}(p)
end // end of [s0exp_node_S0Elist]

implement
s0exp_node_S0Eappid
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 2)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<glist(s0exp)>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{s0exp_node}(p)
end // end of [s0exp_node_S0Eappid]

implement
s0exp_node_encode
  (v) =
(
case+ v of
| ~S0Eide(a0) => s0exp_node_S0Eide(a0)
| ~S0Elist(a0) => s0exp_node_S0Elist(a0)
| ~S0Eappid(a0, a1) => s0exp_node_S0Eappid(a0, a1)
) (* end of [s0exp_node_encode] *)

implement
s0exp_node_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
s0exp_node_is_S0Eide
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
s0exp_node_is_S0Elist
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
s0exp_node_is_S0Eappid
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 2)

implement
s0exp_node_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => S0Eide(arena_load<symbol>(ptr_add<byte>(p, 8)))
| 1 => S0Elist(arena_load<glist(s0exp)>(ptr_add<byte>(p, 8)))
| _ => S0Eappid(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<glist(s0exp)>(ptr_add<byte>(p, 16)))
//
end // end of [s0exp_node_view]

implement
s0exp_node_view_free
  (v) =
(
case+ v of
| ~S0Eide(_) => ()
| ~S0Elist(_) => ()
| ~S0Eappid(_, _) => ()
) (* end of [s0exp_node_view_free] *)

(* ****** ****** *)

implement
s0exp_S0EXP
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<loc_t>(ptr_add<byte>(p, 8), a0)
val () = arena_store<s0exp_node>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{s0exp}(p)
end // end of [s0exp_S0EXP]

implement
s0exp_encode
  (v) =
(
case+ v of
| ~S0EXP(a0, a1) => s0exp_S0EXP(a0, a1)
) (* end of [s0exp_encode] *)

implement
s0exp_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
s0exp_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| _ => S0EXP(arena_load<loc_t>(ptr_add<byte>(p, 8)), arena_load<s0exp_node>(ptr_add<byte>(p, 16)))
//
end // end of [s0exp_view]

implement
s0exp_view_free
  (v) =
(
case+ v of
| ~S0EXP(_, _) => ()
) (* end of [s0exp_view_free] *)

implement
s0exp_get_s0exp_loc
  (x) =
  arena_load<loc_t>(ptr_add<byte>($UN.cast{ptr}(x), 8))

implement
s0exp_get_s0exp_node
  (x) =
  arena_load<s0exp_node>(ptr_add<byte>($UN.cast{ptr}(x), 16))

(* ****** ****** *)

implement
tyfld_node_TYFLD
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<s0exp>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{tyfld_node}(p)
end // end of [tyfld_node_TYFLD]

implement
tyfld_node_encode
  (v) =
(
case+ v of
| ~TYFLD(a0, a1) => tyfld_node_TYFLD(a0, a1)
) (* end of [tyfld_node_encode] *)

implement
tyfld_node_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
tyfld_node_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| _ => TYFLD(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<s0exp>(ptr_add<byte>(p, 16)))
//
end // end of [tyfld_node_view]

implement
tyfld_node_view_free
  (v) =
(
case+ v of
| ~TYFLD(_, _) => ()
) (* end of [tyfld_node_view_free] *)

(* ****** ****** *)

implement
tyfld_TYFLDREC
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<loc_t>(ptr_add<byte>(p, 8), a0)
val () = arena_store<tyfld_node>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{tyfld}(p)
end // end of [tyfld_TYFLDREC]

implement
tyfld_encode
  (v) =
(
case+ v of
| ~TYFLDREC(a0, a1) => tyfld_TYFLDREC(a0, a1)
) (* end of [tyfld_encode] *)

implement
tyfld_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
tyfld_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| _ => TYFLDREC(arena_load<loc_t>(ptr_add<byte>(p, 8)), arena_load<tyfld_node>(ptr_add<byte>(p, 16)))
//
end // end of [tyfld_view]

implement
tyfld_view_free
  (v) =
(
case+ v of
| ~TYFLDREC(_, _) => ()
) (* end of [tyfld_view_free] *)

implement
tyfld_get_tyfld_loc
  (x) =
  arena_load<loc_t>(ptr_add<byte>($UN.cast{ptr}(x), 8))

implement
tyfld_get_tyfld_node
  (x) =
  arena_load<tyfld_node>(ptr_add<byte>($UN.cast{ptr}(x), 16))

(* ****** ****** *)

implement
tyrec_TYREC
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<loc_t>(ptr_add<byte>(p, 8), a0)
val () = arena_store<glist(tyfld)>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{tyrec}(p)
end // end of [tyrec_TYREC]

implement
tyrec_encode
  (v) =
(
case+ v of
| ~TYREC(a0, a1) => tyrec_TYREC(a0, a1)
) (* end of [tyrec_encode] *)

implement
tyrec_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
tyrec_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| _ => TYREC(arena_load<loc_t>(ptr_add<byte>(p, 8)), arena_load<glist(tyfld)>(ptr_add<byte>(p, 16)))
//
end // end of [tyrec_view]

implement
tyrec_view_free
  (v) =
(
case+ v of
| ~TYREC(_, _) => ()
) (* end of [tyrec_view_free] *)

implement
tyrec_get_tyrec_loc
  (x) =
  arena_load<loc_t>(ptr_add<byte>($UN.cast{ptr}(x), 8))

implement
tyrec_get_tyrec_node
  (x) =
  arena_load<glist(tyfld)>(ptr_add<byte>($UN.cast{ptr}(x), 16))

(* ****** ****** *)

implement
d0exp_node_D0Eide
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 0)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_D0Eide]

implement
d0exp_node_D0Elist
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 1)
val () = arena_store<glist(d0exp)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_D0Elist]

implement
d0exp_node_D0Eappid
  (a0, a1) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 2)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<glist(d0exp)>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_D0Eappid]

implement
d0exp_node_D0Eappexp
  (a0, a1) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 3)
val () = arena_store<d0exp>(ptr_add<byte>(p, 8), a0)
val () = arena_store<glist(d0exp)>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_D0Eappexp]

implement
d0exp_node_ATSPMVint
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 4)
val () = arena_store<token>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSPMVint]

implement
d0exp_node_ATSPMVintrep
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 5)
val () = arena_store<token>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSPMVintrep]

implement
d0exp_node_ATSPMVbool
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 6)
val () = arena_store<bool>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSPMVbool]

implement
d0exp_node_ATSPMVfloat
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 7)
val () = arena_store<token>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSPMVfloat]

implement
d0exp_node_ATSPMVstring
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 8)
val () = arena_store<token>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSPMVstring]

implement
d0exp_node_ATSPMVi0nt
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 9)
val () = arena_store<token>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSPMVi0nt]

implement
d0exp_node_ATSPMVf0loat
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 10)
val () = arena_store<token>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSPMVf0loat]

implement
d0exp_node_ATSPMVempty
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 11)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSPMVempty]

implement
d0exp_node_ATSPMVextval
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 12)
val () = arena_store<glist(token)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSPMVextval]

implement
d0exp_node_ATSPMVrefarg0
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 13)
val () = arena_store<d0exp>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSPMVrefarg0]

implement
d0exp_node_ATSPMVrefarg1
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 14)
val () = arena_store<d0exp>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSPMVrefarg1]

implement
d0exp_node_ATSPMVfunlab
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 15)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSPMVfunlab]

implement
d0exp_node_ATSPMVcfunlab
  (a0, a1, a2) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 16)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
val () = arena_store<i0de>(ptr_add<byte>(p, 16), a1)
val () = arena_store<glist(d0exp)>(ptr_add<byte>(p, 24), a2)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSPMVcfunlab]

implement
d0exp_node_ATSPMVcastfn
  (a0, a1, a2) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 17)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<s0exp>(ptr_add<byte>(p, 16), a1)
val () = arena_store<d0exp>(ptr_add<byte>(p, 24), a2)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSPMVcastfn]

implement
d0exp_node_ATSCSTSPmyloc
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 18)
val () = arena_store<token>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSCSTSPmyloc]

implement
d0exp_node_ATSCKiseqz
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 19)
val () = arena_store<d0exp>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSCKiseqz]

implement
d0exp_node_ATSCKisneqz
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 20)
val () = arena_store<d0exp>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSCKisneqz]

implement
d0exp_node_ATSCKptriscons
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 21)
val () = arena_store<d0exp>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSCKptriscons]

implement
d0exp_node_ATSCKptrisnull
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 22)
val () = arena_store<d0exp>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSCKptrisnull]

implement
d0exp_node_ATSCKpat_int
  (a0, a1) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 23)
val () = arena_store<d0exp>(ptr_add<byte>(p, 8), a0)
val () = arena_store<d0exp>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSCKpat_int]

implement
d0exp_node_ATSCKpat_bool
  (a0, a1) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 24)
val () = arena_store<d0exp>(ptr_add<byte>(p, 8), a0)
val () = arena_store<d0exp>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSCKpat_bool]

implement
d0exp_node_ATSCKpat_string
  (a0, a1) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 25)
val () = arena_store<d0exp>(ptr_add<byte>(p, 8), a0)
val () = arena_store<d0exp>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSCKpat_string]

implement
d0exp_node_ATSCKpat_con0
  (a0, a1) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 26)
val () = arena_store<d0exp>(ptr_add<byte>(p, 8), a0)
val () = arena_store<int>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSCKpat_con0]

implement
d0exp_node_ATSCKpat_con1
  (a0, a1) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 27)
val () = arena_store<d0exp>(ptr_add<byte>(p, 8), a0)
val () = arena_store<int>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSCKpat_con1]

implement
d0exp_node_ATSSELcon
  (a0, a1, a2) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 28)
val () = arena_store<d0exp>(ptr_add<byte>(p, 8), a0)
val () = arena_store<s0exp>(ptr_add<byte>(p, 16), a1)
val () = arena_store<i0de>(ptr_add<byte>(p, 24), a2)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSSELcon]

implement
d0exp_node_ATSSELrecsin
  (a0, a1, a2) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 29)
val () = arena_store<d0exp>(ptr_add<byte>(p, 8), a0)
val () = arena_store<s0exp>(ptr_add<byte>(p, 16), a1)
val () = arena_store<i0de>(ptr_add<byte>(p, 24), a2)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSSELrecsin]

implement
d0exp_node_ATSSELboxrec
  (a0, a1, a2) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 30)
val () = arena_store<d0exp>(ptr_add<byte>(p, 8), a0)
val () = arena_store<s0exp>(ptr_add<byte>(p, 16), a1)
val () = arena_store<i0de>(ptr_add<byte>(p, 24), a2)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSSELboxrec]

implement
d0exp_node_ATSSELfltrec
  (a0, a1, a2) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 31)
val () = arena_store<d0exp>(ptr_add<byte>(p, 8), a0)
val () = arena_store<s0exp>(ptr_add<byte>(p, 16), a1)
val () = arena_store<i0de>(ptr_add<byte>(p, 24), a2)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSSELfltrec]

implement
d0exp_node_ATSextfcall
  (a0, a1) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 32)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<glist(d0exp)>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSextfcall]

implement
d0exp_node_ATSextmcall
  (a0, a1, a2) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 33)
val () = arena_store<d0exp>(ptr_add<byte>(p, 8), a0)
val () = arena_store<d0exp>(ptr_add<byte>(p, 16), a1)
val () = arena_store<glist(d0exp)>(ptr_add<byte>(p, 24), a2)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSextmcall]

implement
d0exp_node_ATSfunclo_fun
  (a0, a1, a2) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 34)
val () = arena_store<d0exp>(ptr_add<byte>(p, 8), a0)
val () = arena_store<s0exp>(ptr_add<byte>(p, 16), a1)
val () = arena_store<s0exp>(ptr_add<byte>(p, 24), a2)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSfunclo_fun]

implement
d0exp_node_ATSfunclo_clo
  (a0, a1, a2) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 35)
val () = arena_store<d0exp>(ptr_add<byte>(p, 8), a0)
val () = arena_store<s0exp>(ptr_add<byte>(p, 16), a1)
val () = arena_store<s0exp>(ptr_add<byte>(p, 24), a2)
in
  $UN.cast{d0exp_node}(p)
end // end of [d0exp_node_ATSfunclo_clo]

implement
d0exp_node_encode
  (v) =
(
case+ v of
| ~D0Eide(a0) => d0exp_node_D0Eide(a0)
| ~D0Elist(a0) => d0exp_node_D0Elist(a0)
| ~D0Eappid(a0, a1) => d0exp_node_D0Eappid(a0, a1)
| ~D0Eappexp(a0, a1) => d0exp_node_D0Eappexp(a0, a1)
| ~ATSPMVint(a0) => d0exp_node_ATSPMVint(a0)
| ~ATSPMVintrep(a0) => d0exp_node_ATSPMVintrep(a0)
| ~ATSPMVbool(a0) => d0exp_node_ATSPMVbool(a0)
| ~ATSPMVfloat(a0) => d0exp_node_ATSPMVfloat(a0)
| ~ATSPMVstring(a0) => d0exp_node_ATSPMVstring(a0)
| ~ATSPMVi0nt(a0) => d0exp_node_ATSPMVi0nt(a0)
| ~ATSPMVf0loat(a0) => d0exp_node_ATSPMVf0loat(a0)
| ~ATSPMVempty(a0) => d0exp_node_ATSPMVempty(a0)
| ~ATSPMVextval(a0) => d0exp_node_ATSPMVextval(a0)
| ~ATSPMVrefarg0(a0) => d0exp_node_ATSPMVrefarg0(a0)
| ~ATSPMVrefarg1(a0) => d0exp_node_ATSPMVrefarg1(a0)
| ~ATSPMVfunlab(a0) => d0exp_node_ATSPMVfunlab(a0)
| ~ATSPMVcfunlab(a0, a1, a2) => d0exp_node_ATSPMVcfunlab(a0, a1, a2)
| ~ATSPMVcastfn(a0, a1, a2) => d0exp_node_ATSPMVcastfn(a0, a1, a2)
| ~ATSCSTSPmyloc(a0) => d0exp_node_ATSCSTSPmyloc(a0)
| ~ATSCKiseqz(a0) => d0exp_node_ATSCKiseqz(a0)
| ~ATSCKisneqz(a0) => d0exp_node_ATSCKisneqz(a0)
| ~ATSCKptriscons(a0) => d0exp_node_ATSCKptriscons(a0)
| ~ATSCKptrisnull(a0) => d0exp_node_ATSCKptrisnull(a0)
| ~ATSCKpat_int(a0, a1) => d0exp_node_ATSCKpat_int(a0, a1)
| ~ATSCKpat_bool(a0, a1) => d0exp_node_ATSCKpat_bool(a0, a1)
| ~ATSCKpat_string(a0, a1) => d0exp_node_ATSCKpat_string(a0, a1)
| ~ATSCKpat_con0(a0, a1) => d0exp_node_ATSCKpat_con0(a0, a1)
| ~ATSCKpat_con1(a0, a1) => d0exp_node_ATSCKpat_con1(a0, a1)
| ~ATSSELcon(a0, a1, a2) => d0exp_node_ATSSELcon(a0, a1, a2)
| ~ATSSELrecsin(a0, a1, a2) => d0exp_node_ATSSELrecsin(a0, a1, a2)
| ~ATSSELboxrec(a0, a1, a2) => d0exp_node_ATSSELboxrec(a0, a1, a2)
| ~ATSSELfltrec(a0, a1, a2) => d0exp_node_ATSSELfltrec(a0, a1, a2)
| ~ATSextfcall(a0, a1) => d0exp_node_ATSextfcall(a0, a1)
| ~ATSextmcall(a0, a1, a2) => d0exp_node_ATSextmcall(a0, a1, a2)
| ~ATSfunclo_fun(a0, a1, a2) => d0exp_node_ATSfunclo_fun(a0, a1, a2)
| ~ATSfunclo_clo(a0, a1, a2) => d0exp_node_ATSfunclo_clo(a0, a1, a2)
) (* end of [d0exp_node_encode] *)

implement
d0exp_node_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
d0exp_node_is_D0Eide
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
d0exp_node_is_D0Elist
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
d0exp_node_is_D0Eappid
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 2)

implement
d0exp_node_is_D0Eappexp
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 3)

implement
d0exp_node_is_ATSPMVint
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 4)

implement
d0exp_node_is_ATSPMVintrep
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 5)

implement
d0exp_node_is_ATSPMVbool
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 6)

implement
d0exp_node_is_ATSPMVfloat
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 7)

implement
d0exp_node_is_ATSPMVstring
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 8)

implement
d0exp_node_is_ATSPMVi0nt
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 9)

implement
d0exp_node_is_ATSPMVf0loat
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 10)

implement
d0exp_node_is_ATSPMVempty
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 11)

implement
d0exp_node_is_ATSPMVextval
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 12)

implement
d0exp_node_is_ATSPMVrefarg0
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 13)

implement
d0exp_node_is_ATSPMVrefarg1
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 14)

implement
d0exp_node_is_ATSPMVfunlab
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 15)

implement
d0exp_node_is_ATSPMVcfunlab
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 16)

implement
d0exp_node_is_ATSPMVcastfn
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 17)

implement
d0exp_node_is_ATSCSTSPmyloc
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 18)

implement
d0exp_node_is_ATSCKiseqz
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 19)

implement
d0exp_node_is_ATSCKisneqz
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 20)

implement
d0exp_node_is_ATSCKptriscons
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 21)

implement
d0exp_node_is_ATSCKptrisnull
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 22)

implement
d0exp_node_is_ATSCKpat_int
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 23)

implement
d0exp_node_is_ATSCKpat_bool
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 24)

implement
d0exp_node_is_ATSCKpat_string
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 25)

implement
d0exp_node_is_ATSCKpat_con0
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 26)

implement
d0exp_node_is_ATSCKpat_con1
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 27)

implement
d0exp_node_is_ATSSELcon
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 28)

implement
d0exp_node_is_ATSSELrecsin
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 29)

implement
d0exp_node_is_ATSSELboxrec
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 30)

implement
d0exp_node_is_ATSSELfltrec
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 31)

implement
d0exp_node_is_ATSextfcall
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 32)

implement
d0exp_node_is_ATSextmcall
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 33)

implement
d0exp_node_is_ATSfunclo_fun
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 34)

implement
d0exp_node_is_ATSfunclo_clo
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 35)

implement
d0exp_node_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => D0Eide(arena_load<i0de>(ptr_add<byte>(p, 8)))
| 1 => D0Elist(arena_load<glist(d0exp)>(ptr_add<byte>(p, 8)))
| 2 => D0Eappid(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<glist(d0exp)>(ptr_add<byte>(p, 16)))
| 3 => D0Eappexp(arena_load<d0exp>(ptr_add<byte>(p, 8)), arena_load<glist(d0exp)>(ptr_add<byte>(p, 16)))
| 4 => ATSPMVint(arena_load<token>(ptr_add<byte>(p, 8)))
| 5 => ATSPMVintrep(arena_load<token>(ptr_add<byte>(p, 8)))
| 6 => ATSPMVbool(arena_load<bool>(ptr_add<byte>(p, 8)))
| 7 => ATSPMVfloat(arena_load<token>(ptr_add<byte>(p, 8)))
| 8 => ATSPMVstring(arena_load<token>(ptr_add<byte>(p, 8)))
| 9 => ATSPMVi0nt(arena_load<token>(ptr_add<byte>(p, 8)))
| 10 => ATSPMVf0loat(arena_load<token>(ptr_add<byte>(p, 8)))
| 11 => ATSPMVempty(arena_load<int>(ptr_add<byte>(p, 8)))
| 12 => ATSPMVextval(arena_load<glist(token)>(ptr_add<byte>(p, 8)))
| 13 => ATSPMVrefarg0(arena_load<d0exp>(ptr_add<byte>(p, 8)))
| 14 => ATSPMVrefarg1(arena_load<d0exp>(ptr_add<byte>(p, 8)))
| 15 => ATSPMVfunlab(arena_load<i0de>(ptr_add<byte>(p, 8)))
| 16 => ATSPMVcfunlab(arena_load<int>(ptr_add<byte>(p, 8)), arena_load<i0de>(ptr_add<byte>(p, 16)), arena_load<glist(d0exp)>(ptr_add<byte>(p, 24)))
| 17 => ATSPMVcastfn(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<s0exp>(ptr_add<byte>(p, 16)), arena_load<d0exp>(ptr_add<byte>(p, 24)))
| 18 => ATSCSTSPmyloc(arena_load<token>(ptr_add<byte>(p, 8)))
| 19 => ATSCKiseqz(arena_load<d0exp>(ptr_add<byte>(p, 8)))
| 20 => ATSCKisneqz(arena_load<d0exp>(ptr_add<byte>(p, 8)))
| 21 => ATSCKptriscons(arena_load<d0exp>(ptr_add<byte>(p, 8)))
| 22 => ATSCKptrisnull(arena_load<d0exp>(ptr_add<byte>(p, 8)))
| 23 => ATSCKpat_int(arena_load<d0exp>(ptr_add<byte>(p, 8)), arena_load<d0exp>(ptr_add<byte>(p, 16)))
| 24 => ATSCKpat_bool(arena_load<d0exp>(ptr_add<byte>(p, 8)), arena_load<d0exp>(ptr_add<byte>(p, 16)))
| 25 => ATSCKpat_string(arena_load<d0exp>(ptr_add<byte>(p, 8)), arena_load<d0exp>(ptr_add<byte>(p, 16)))
| 26 => ATSCKpat_con0(arena_load<d0exp>(ptr_add<byte>(p, 8)), arena_load<int>(ptr_add<byte>(p, 16)))
| 27 => ATSCKpat_con1(arena_load<d0exp>(ptr_add<byte>(p, 8)), arena_load<int>(ptr_add<byte>(p, 16)))
| 28 => ATSSELcon(arena_load<d0exp>(ptr_add<byte>(p, 8)), arena_load<s0exp>(ptr_add<byte>(p, 16)), arena_load<i0de>(ptr_add<byte>(p, 24)))
| 29 => ATSSELrecsin(arena_load<d0exp>(ptr_add<byte>(p, 8)), arena_load<s0exp>(ptr_add<byte>(p, 16)), arena_load<i0de>(ptr_add<byte>(p, 24)))
| 30 => ATSSELboxrec(arena_load<d0exp>(ptr_add<byte>(p, 8)), arena_load<s0exp>(ptr_add<byte>(p, 16)), arena_load<i0de>(ptr_add<byte>(p, 24)))
| 31 => ATSSELfltrec(arena_load<d0exp>(ptr_add<byte>(p, 8)), arena_load<s0exp>(ptr_add<byte>(p, 16)), arena_load<i0de>(ptr_add<byte>(p, 24)))
| 32 => ATSextfcall(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<glist(d0exp)>(ptr_add<byte>(p, 16)))
| 33 => ATSextmcall(arena_load<d0exp>(ptr_add<byte>(p, 8)), arena_load<d0exp>(ptr_add<byte>(p, 16)), arena_load<glist(d0exp)>(ptr_add<byte>(p, 24)))
| 34 => ATSfunclo_fun(arena_load<d0exp>(ptr_add<byte>(p, 8)), arena_load<s0exp>(ptr_add<byte>(p, 16)), arena_load<s0exp>(ptr_add<byte>(p, 24)))
| _ => ATSfunclo_clo(arena_load<d0exp>(ptr_add<byte>(p, 8)), arena_load<s0exp>(ptr_add<byte>(p, 16)), arena_load<s0exp>(ptr_add<byte>(p, 24)))
//
end // end of [d0exp_node_view]

implement
d0exp_node_view_free
  (v) =
(
case+ v of
| ~D0Eide(_) => ()
| ~D0Elist(_) => ()
| ~D0Eappid(_, _) => ()
| ~D0Eappexp(_, _) => ()
| ~ATSPMVint(_) => ()
| ~ATSPMVintrep(_) => ()
| ~ATSPMVbool(_) => ()
| ~ATSPMVfloat(_) => ()
| ~ATSPMVstring(_) => ()
| ~ATSPMVi0nt(_) => ()
| ~ATSPMVf0loat(_) => ()
| ~ATSPMVempty(_) => ()
| ~ATSPMVextval(_) => ()
| ~ATSPMVrefarg0(_) => ()
| ~ATSPMVrefarg1(_) => ()
| ~ATSPMVfunlab(_) => ()
| ~ATSPMVcfunlab(_, _, _) => ()
| ~ATSPMVcastfn(_, _, _) => ()
| ~ATSCSTSPmyloc(_) => ()
| ~ATSCKiseqz(_) => ()
| ~ATSCKisneqz(_) => ()
| ~ATSCKptriscons(_) => ()
| ~ATSCKptrisnull(_) => ()
| ~ATSCKpat_int(_, _) => ()
| ~ATSCKpat_bool(_, _) => ()
| ~ATSCKpat_string(_, _) => ()
| ~ATSCKpat_con0(_, _) => ()
| ~ATSCKpat_con1(_, _) => ()
| ~ATSSELcon(_, _, _) => ()
| ~ATSSELrecsin(_, _, _) => ()
| ~ATSSELboxrec(_, _, _) => ()
| ~ATSSELfltrec(_, _, _) => ()
| ~ATSextfcall(_, _) => ()
| ~ATSextmcall(_, _, _) => ()
| ~ATSfunclo_fun(_, _, _) => ()
| ~ATSfunclo_clo(_, _, _) => ()
) (* end of [d0exp_node_view_free] *)

(* ****** ****** *)

implement
d0exp_D0EXP
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<loc_t>(ptr_add<byte>(p, 8), a0)
val () = arena_store<d0exp_node>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{d0exp}(p)
end // end of [d0exp_D0EXP]

implement
d0exp_encode
  (v) =
(
case+ v of
| ~D0EXP(a0, a1) => d0exp_D0EXP(a0, a1)
) (* end of [d0exp_encode] *)

implement
d0exp_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
d0exp_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| _ => D0EXP(arena_load<loc_t>(ptr_add<byte>(p, 8)), arena_load<d0exp_node>(ptr_add<byte>(p, 16)))
//
end // end of [d0exp_view]

implement
d0exp_view_free
  (v) =
(
case+ v of
| ~D0EXP(_, _) => ()
) (* end of [d0exp_view_free] *)

implement
d0exp_get_d0exp_loc
  (x) =
  arena_load<loc_t>(ptr_add<byte>($UN.cast{ptr}(x), 8))

implement
d0exp_get_d0exp_node
  (x) =
  arena_load<d0exp_node>(ptr_add<byte>($UN.cast{ptr}(x), 16))

(* ****** ****** *)

implement
f0arg_node_F0ARGnone
  (a0) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<s0exp>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{f0arg_node}(p)
end // end of [f0arg_node_F0ARGnone]

implement
f0arg_node_F0ARGsome
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 1)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<s0exp>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{f0arg_node}(p)
end // end of [f0arg_node_F0ARGsome]

implement
f0arg_node_encode
  (v) =
(
case+ v of
| ~F0ARGnone(a0) => f0arg_node_F0ARGnone(a0)
| ~F0ARGsome(a0, a1) => f0arg_node_F0ARGsome(a0, a1)
) (* end of [f0arg_node_encode] *)

implement
f0arg_node_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
f0arg_node_is_F0ARGnone
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
f0arg_node_is_F0ARGsome
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
f0arg_node_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => F0ARGnone(arena_load<s0exp>(ptr_add<byte>(p, 8)))
| _ => F0ARGsome(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<s0exp>(ptr_add<byte>(p, 16)))
//
end // end of [f0arg_node_view]

implement
f0arg_node_view_free
  (v) =
(
case+ v of
| ~F0ARGnone(_) => ()
| ~F0ARGsome(_, _) => ()
) (* end of [f0arg_node_view_free] *)

(* ****** ****** *)

implement
f0arg_F0ARG
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<loc_t>(ptr_add<byte>(p, 8), a0)
val () = arena_store<f0arg_node>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{f0arg}(p)
end // end of [f0arg_F0ARG]

implement
f0arg_encode
  (v) =
(
case+ v of
| ~F0ARG(a0, a1) => f0arg_F0ARG(a0, a1)
) (* end of [f0arg_encode] *)

implement
f0arg_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
f0arg_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| _ => F0ARG(arena_load<loc_t>(ptr_add<byte>(p, 8)), arena_load<f0arg_node>(ptr_add<byte>(p, 16)))
//
end // end of [f0arg_view]

implement
f0arg_view_free
  (v) =
(
case+ v of
| ~F0ARG(_, _) => ()
) (* end of [f0arg_view_free] *)

implement
f0arg_get_f0arg_loc
  (x) =
  arena_load<loc_t>(ptr_add<byte>($UN.cast{ptr}(x), 8))

implement
f0arg_get_f0arg_node
  (x) =
  arena_load<f0arg_node>(ptr_add<byte>($UN.cast{ptr}(x), 16))

(* ****** ****** *)

implement
f0marg_F0MARG
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<loc_t>(ptr_add<byte>(p, 8), a0)
val () = arena_store<glist(f0arg)>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{f0marg}(p)
end // end of [f0marg_F0MARG]

implement
f0marg_encode
  (v) =
(
case+ v of
| ~F0MARG(a0, a1) => f0marg_F0MARG(a0, a1)
) (* end of [f0marg_encode] *)

implement
f0marg_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
f0marg_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| _ => F0MARG(arena_load<loc_t>(ptr_add<byte>(p, 8)), arena_load<glist(f0arg)>(ptr_add<byte>(p, 16)))
//
end // end of [f0marg_view]

implement
f0marg_view_free
  (v) =
(
case+ v of
| ~F0MARG(_, _) => ()
) (* end of [f0marg_view_free] *)

implement
f0marg_get_f0marg_loc
  (x) =
  arena_load<loc_t>(ptr_add<byte>($UN.cast{ptr}(x), 8))

implement
f0marg_get_f0marg_node
  (x) =
  arena_load<glist(f0arg)>(ptr_add<byte>($UN.cast{ptr}(x), 16))

(* ****** ****** *)

implement
fkind_FKIND
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<loc_t>(ptr_add<byte>(p, 8), a0)
val () = arena_store<fkind_node>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{fkind}(p)
end // end of [fkind_FKIND]

implement
fkind_encode
  (v) =
(
case+ v of
| ~FKIND(a0, a1) => fkind_FKIND(a0, a1)
) (* end of [fkind_encode] *)

implement
fkind_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
fkind_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| _ => FKIND(arena_load<loc_t>(ptr_add<byte>(p, 8)), arena_load<fkind_node>(ptr_add<byte>(p, 16)))
//
end // end of [fkind_view]

implement
fkind_view_free
  (v) =
(
case+ v of
| ~FKIND(_, _) => ()
) (* end of [fkind_view_free] *)

implement
fkind_get_fkind_loc
  (x) =
  arena_load<loc_t>(ptr_add<byte>($UN.cast{ptr}(x), 8))

implement
fkind_get_fkind_node
  (x) =
  arena_load<fkind_node>(ptr_add<byte>($UN.cast{ptr}(x), 16))

(* ****** ****** *)

implement
f0head_node_F0HEAD
  (a0, a1, a2) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 0)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<f0marg>(ptr_add<byte>(p, 16), a1)
val () = arena_store<s0exp>(ptr_add<byte>(p, 24), a2)
in
  $UN.cast{f0head_node}(p)
end // end of [f0head_node_F0HEAD]

implement
f0head_node_encode
  (v) =
(
case+ v of
| ~F0HEAD(a0, a1, a2) => f0head_node_F0HEAD(a0, a1, a2)
) (* end of [f0head_node_encode] *)

implement
f0head_node_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
f0head_node_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| _ => F0HEAD(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<f0marg>(ptr_add<byte>(p, 16)), arena_load<s0exp>(ptr_add<byte>(p, 24)))
//
end // end of [f0head_node_view]

implement
f0head_node_view_free
  (v) =
(
case+ v of
| ~F0HEAD(_, _, _) => ()
) (* end of [f0head_node_view_free] *)

(* ****** ****** *)

implement
f0head_F0HEADREC
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<loc_t>(ptr_add<byte>(p, 8), a0)
val () = arena_store<f0head_node>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{f0head}(p)
end // end of [f0head_F0HEADREC]

implement
f0head_encode
  (v) =
(
case+ v of
| ~F0HEADREC(a0, a1) => f0head_F0HEADREC(a0, a1)
) (* end of [f0head_encode] *)

implement
f0head_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
f0head_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| _ => F0HEADREC(arena_load<loc_t>(ptr_add<byte>(p, 8)), arena_load<f0head_node>(ptr_add<byte>(p, 16)))
//
end // end of [f0head_view]

implement
f0head_view_free
  (v) =
(
case+ v of
| ~F0HEADREC(_, _) => ()
) (* end of [f0head_view_free] *)

implement
f0head_get_f0head_loc
  (x) =
  arena_load<loc_t>(ptr_add<byte>($UN.cast{ptr}(x), 8))

implement
f0head_get_f0head_node
  (x) =
  arena_load<f0head_node>(ptr_add<byte>($UN.cast{ptr}(x), 16))

(* ****** ****** *)

implement
tmpdec_node_TMPDECnone
  (a0) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{tmpdec_node}(p)
end // end of [tmpdec_node_TMPDECnone]

implement
tmpdec_node_TMPDECsome
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 1)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<s0exp>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{tmpdec_node}(p)
end // end of [tmpdec_node_TMPDECsome]

implement
tmpdec_node_encode
  (v) =
(
case+ v of
| ~TMPDECnone(a0) => tmpdec_node_TMPDECnone(a0)
| ~TMPDECsome(a0, a1) => tmpdec_node_TMPDECsome(a0, a1)
) (* end of [tmpdec_node_encode] *)

implement
tmpdec_node_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
tmpdec_node_is_TMPDECnone
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
tmpdec_node_is_TMPDECsome
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
tmpdec_node_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => TMPDECnone(arena_load<i0de>(ptr_add<byte>(p, 8)))
| _ => TMPDECsome(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<s0exp>(ptr_add<byte>(p, 16)))
//
end // end of [tmpdec_node_view]

implement
tmpdec_node_view_free
  (v) =
(
case+ v of
| ~TMPDECnone(_) => ()
| ~TMPDECsome(_, _) => ()
) (* end of [tmpdec_node_view_free] *)

(* ****** ****** *)

implement
tmpdec_TMPDEC
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<loc_t>(ptr_add<byte>(p, 8), a0)
val () = arena_store<tmpdec_node>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{tmpdec}(p)
end // end of [tmpdec_TMPDEC]

implement
tmpdec_encode
  (v) =
(
case+ v of
| ~TMPDEC(a0, a1) => tmpdec_TMPDEC(a0, a1)
) (* end of [tmpdec_encode] *)

implement
tmpdec_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
tmpdec_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| _ => TMPDEC(arena_load<loc_t>(ptr_add<byte>(p, 8)), arena_load<tmpdec_node>(ptr_add<byte>(p, 16)))
//
end // end of [tmpdec_view]

implement
tmpdec_view_free
  (v) =
(
case+ v of
| ~TMPDEC(_, _) => ()
) (* end of [tmpdec_view_free] *)

implement
tmpdec_get_tmpdec_loc
  (x) =
  arena_load<loc_t>(ptr_add<byte>($UN.cast{ptr}(x), 8))

implement
tmpdec_get_tmpdec_node
  (x) =
  arena_load<tmpdec_node>(ptr_add<byte>($UN.cast{ptr}(x), 16))

(* ****** ****** *)

implement
instr_node_ATSif
  (a0, a1, a2) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 0)
val () = arena_store<d0exp>(ptr_add<byte>(p, 8), a0)
val () = arena_store<glist(instr)>(ptr_add<byte>(p, 16), a1)
val () = arena_store<gopt(glist(instr))>(ptr_add<byte>(p, 24), a2)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSif]

implement
instr_node_ATSthen
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 1)
val () = arena_store<glist(instr)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSthen]

implement
instr_node_ATSelse
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 2)
val () = arena_store<glist(instr)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSelse]

implement
instr_node_ATSifthen
  (a0, a1) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 3)
val () = arena_store<d0exp>(ptr_add<byte>(p, 8), a0)
val () = arena_store<glist(instr)>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSifthen]

implement
instr_node_ATSifnthen
  (a0, a1) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 4)
val () = arena_store<d0exp>(ptr_add<byte>(p, 8), a0)
val () = arena_store<glist(instr)>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSifnthen]

implement
instr_node_ATSbranchseq
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 5)
val () = arena_store<glist(instr)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSbranchseq]

implement
instr_node_ATScaseofseq
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 6)
val () = arena_store<glist(instr)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATScaseofseq]

implement
instr_node_ATSfunbodyseq
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 7)
val () = arena_store<glist(instr)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSfunbodyseq]

implement
instr_node_ATSreturn
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 8)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSreturn]

implement
instr_node_ATSreturn_void
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 9)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSreturn_void]

implement
instr_node_ATSlinepragma
  (a0, a1) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 10)
val () = arena_store<token>(ptr_add<byte>(p, 8), a0)
val () = arena_store<token>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSlinepragma]

implement
instr_node_ATSINSlab
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 11)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSINSlab]

implement
instr_node_ATSINSgoto
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 12)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSINSgoto]

implement
instr_node_ATSINSflab
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 13)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSINSflab]

implement
instr_node_ATSINSfgoto
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 14)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSINSfgoto]

implement
instr_node_ATSINSfreeclo
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 15)
val () = arena_store<d0exp>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSINSfreeclo]

implement
instr_node_ATSINSfreecon
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 16)
val () = arena_store<d0exp>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSINSfreecon]

implement
instr_node_ATSINSmove
  (a0, a1) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 17)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<d0exp>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSINSmove]

implement
instr_node_ATSINSmove_void
  (a0, a1) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 18)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<d0exp>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSINSmove_void]

implement
instr_node_ATSINSmove_nil
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 19)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSINSmove_nil]

implement
instr_node_ATSINSmove_con0
  (a0, a1) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 20)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<token>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSINSmove_con0]

implement
instr_node_ATSINSmove_con1
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 21)
val () = arena_store<glist(instr)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSINSmove_con1]

implement
instr_node_ATSINSmove_con1_new
  (a0, a1) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 22)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<s0exp>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSINSmove_con1_new]

implement
instr_node_ATSINSstore_con1_tag
  (a0, a1) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 23)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<token>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSINSstore_con1_tag]

implement
instr_node_ATSINSstore_con1_ofs
  (a0, a1, a2, a3) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 24)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<s0exp>(ptr_add<byte>(p, 16), a1)
val () = arena_store<i0de>(ptr_add<byte>(p, 24), a2)
val () = arena_store<d0exp>(ptr_add<byte>(p, 32), a3)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSINSstore_con1_ofs]

implement
instr_node_ATSINSmove_boxrec
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 25)
val () = arena_store<glist(instr)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSINSmove_boxrec]

implement
instr_node_ATSINSmove_boxrec_new
  (a0, a1) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 26)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<s0exp>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSINSmove_boxrec_new]

implement
instr_node_ATSINSstore_boxrec_ofs
  (a0, a1, a2, a3) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 27)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<s0exp>(ptr_add<byte>(p, 16), a1)
val () = arena_store<i0de>(ptr_add<byte>(p, 24), a2)
val () = arena_store<d0exp>(ptr_add<byte>(p, 32), a3)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSINSstore_boxrec_ofs]

implement
instr_node_ATSINSmove_fltrec
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 28)
val () = arena_store<glist(instr)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSINSmove_fltrec]

implement
instr_node_ATSINSstore_fltrec_ofs
  (a0, a1, a2, a3) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 29)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<s0exp>(ptr_add<byte>(p, 16), a1)
val () = arena_store<i0de>(ptr_add<byte>(p, 24), a2)
val () = arena_store<d0exp>(ptr_add<byte>(p, 32), a3)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSINSstore_fltrec_ofs]

implement
instr_node_ATSINSmove_delay
  (a0, a1, a2) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 30)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<s0exp>(ptr_add<byte>(p, 16), a1)
val () = arena_store<d0exp>(ptr_add<byte>(p, 24), a2)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSINSmove_delay]

implement
instr_node_ATSINSmove_lazyeval
  (a0, a1, a2) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 31)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<s0exp>(ptr_add<byte>(p, 16), a1)
val () = arena_store<d0exp>(ptr_add<byte>(p, 24), a2)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSINSmove_lazyeval]

implement
instr_node_ATSINSmove_ldelay
  (a0, a1, a2) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 32)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<s0exp>(ptr_add<byte>(p, 16), a1)
val () = arena_store<d0exp>(ptr_add<byte>(p, 24), a2)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSINSmove_ldelay]

implement
instr_node_ATSINSmove_llazyeval
  (a0, a1, a2) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 33)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<s0exp>(ptr_add<byte>(p, 16), a1)
val () = arena_store<d0exp>(ptr_add<byte>(p, 24), a2)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSINSmove_llazyeval]

implement
instr_node_ATStailcalseq
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 34)
val () = arena_store<glist(instr)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATStailcalseq]

implement
instr_node_ATSINSmove_tlcal
  (a0, a1) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 35)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<d0exp>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSINSmove_tlcal]

implement
instr_node_ATSINSargmove_tlcal
  (a0, a1) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 36)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<i0de>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSINSargmove_tlcal]

implement
instr_node_ATSINSextvar_assign
  (a0, a1) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 37)
val () = arena_store<d0exp>(ptr_add<byte>(p, 8), a0)
val () = arena_store<d0exp>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSINSextvar_assign]

implement
instr_node_ATSINSdyncst_valbind
  (a0, a1) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 38)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<d0exp>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSINSdyncst_valbind]

implement
instr_node_ATSINScaseof_fail
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 39)
val () = arena_store<token>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSINScaseof_fail]

implement
instr_node_ATSINSdeadcode_fail
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 40)
val () = arena_store<token>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSINSdeadcode_fail]

implement
instr_node_ATSdynload
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 41)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSdynload]

implement
instr_node_ATSdynloadset
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 42)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSdynloadset]

implement
instr_node_ATSdynloadfcall
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 43)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSdynloadfcall]

implement
instr_node_ATSdynloadflag_sta
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 44)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSdynloadflag_sta]

implement
instr_node_ATSdynloadflag_ext
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 45)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSdynloadflag_ext]

implement
instr_node_ATSdynloadflag_init
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 46)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSdynloadflag_init]

implement
instr_node_ATSdynloadflag_minit
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 47)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSdynloadflag_minit]

implement
instr_node_ATSdynexn_dec
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 48)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSdynexn_dec]

implement
instr_node_ATSdynexn_extdec
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 49)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSdynexn_extdec]

implement
instr_node_ATSdynexn_initize
  (a0, a1) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 50)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<string>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{instr_node}(p)
end // end of [instr_node_ATSdynexn_initize]

implement
instr_node_encode
  (v) =
(
case+ v of
| ~ATSif(a0, a1, a2) => instr_node_ATSif(a0, a1, a2)
| ~ATSthen(a0) => instr_node_ATSthen(a0)
| ~ATSelse(a0) => instr_node_ATSelse(a0)
| ~ATSifthen(a0, a1) => instr_node_ATSifthen(a0, a1)
| ~ATSifnthen(a0, a1) => instr_node_ATSifnthen(a0, a1)
| ~ATSbranchseq(a0) => instr_node_ATSbranchseq(a0)
| ~ATScaseofseq(a0) => instr_node_ATScaseofseq(a0)
| ~ATSfunbodyseq(a0) => instr_node_ATSfunbodyseq(a0)
| ~ATSreturn(a0) => instr_node_ATSreturn(a0)
| ~ATSreturn_void(a0) => instr_node_ATSreturn_void(a0)
| ~ATSlinepragma(a0, a1) => instr_node_ATSlinepragma(a0, a1)
| ~ATSINSlab(a0) => instr_node_ATSINSlab(a0)
| ~ATSINSgoto(a0) => instr_node_ATSINSgoto(a0)
| ~ATSINSflab(a0) => instr_node_ATSINSflab(a0)
| ~ATSINSfgoto(a0) => instr_node_ATSINSfgoto(a0)
| ~ATSINSfreeclo(a0) => instr_node_ATSINSfreeclo(a0)
| ~ATSINSfreecon(a0) => instr_node_ATSINSfreecon(a0)
| ~ATSINSmove(a0, a1) => instr_node_ATSINSmove(a0, a1)
| ~ATSINSmove_void(a0, a1) => instr_node_ATSINSmove_void(a0, a1)
| ~ATSINSmove_nil(a0) => instr_node_ATSINSmove_nil(a0)
| ~ATSINSmove_con0(a0, a1) => instr_node_ATSINSmove_con0(a0, a1)
| ~ATSINSmove_con1(a0) => instr_node_ATSINSmove_con1(a0)
| ~ATSINSmove_con1_new(a0, a1) => instr_node_ATSINSmove_con1_new(a0, a1)
| ~ATSINSstore_con1_tag(a0, a1) => instr_node_ATSINSstore_con1_tag(a0, a1)
| ~ATSINSstore_con1_ofs(a0, a1, a2, a3) => instr_node_ATSINSstore_con1_ofs(a0, a1, a2, a3)
| ~ATSINSmove_boxrec(a0) => instr_node_ATSINSmove_boxrec(a0)
| ~ATSINSmove_boxrec_new(a0, a1) => instr_node_ATSINSmove_boxrec_new(a0, a1)
| ~ATSINSstore_boxrec_ofs(a0, a1, a2, a3) => instr_node_ATSINSstore_boxrec_ofs(a0, a1, a2, a3)
| ~ATSINSmove_fltrec(a0) => instr_node_ATSINSmove_fltrec(a0)
| ~ATSINSstore_fltrec_ofs(a0, a1, a2, a3) => instr_node_ATSINSstore_fltrec_ofs(a0, a1, a2, a3)
| ~ATSINSmove_delay(a0, a1, a2) => instr_node_ATSINSmove_delay(a0, a1, a2)
| ~ATSINSmove_lazyeval(a0, a1, a2) => instr_node_ATSINSmove_lazyeval(a0, a1, a2)
| ~ATSINSmove_ldelay(a0, a1, a2) => instr_node_ATSINSmove_ldelay(a0, a1, a2)
| ~ATSINSmove_llazyeval(a0, a1, a2) => instr_node_ATSINSmove_llazyeval(a0, a1, a2)
| ~ATStailcalseq(a0) => instr_node_ATStailcalseq(a0)
| ~ATSINSmove_tlcal(a0, a1) => instr_node_ATSINSmove_tlcal(a0, a1)
| ~ATSINSargmove_tlcal(a0, a1) => instr_node_ATSINSargmove_tlcal(a0, a1)
| ~ATSINSextvar_assign(a0, a1) => instr_node_ATSINSextvar_assign(a0, a1)
| ~ATSINSdyncst_valbind(a0, a1) => instr_node_ATSINSdyncst_valbind(a0, a1)
| ~ATSINScaseof_fail(a0) => instr_node_ATSINScaseof_fail(a0)
| ~ATSINSdeadcode_fail(a0) => instr_node_ATSINSdeadcode_fail(a0)
| ~ATSdynload(a0) => instr_node_ATSdynload(a0)
| ~ATSdynloadset(a0) => instr_node_ATSdynloadset(a0)
| ~ATSdynloadfcall(a0) => instr_node_ATSdynloadfcall(a0)
| ~ATSdynloadflag_sta(a0) => instr_node_ATSdynloadflag_sta(a0)
| ~ATSdynloadflag_ext(a0) => instr_node_ATSdynloadflag_ext(a0)
| ~ATSdynloadflag_init(a0) => instr_node_ATSdynloadflag_init(a0)
| ~ATSdynloadflag_minit(a0) => instr_node_ATSdynloadflag_minit(a0)
| ~ATSdynexn_dec(a0) => instr_node_ATSdynexn_dec(a0)
| ~ATSdynexn_extdec(a0) => instr_node_ATSdynexn_extdec(a0)
| ~ATSdynexn_initize(a0, a1) => instr_node_ATSdynexn_initize(a0, a1)
) (* end of [instr_node_encode] *)

implement
instr_node_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
instr_node_is_ATSif
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
instr_node_is_ATSthen
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
instr_node_is_ATSelse
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 2)

implement
instr_node_is_ATSifthen
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 3)

implement
instr_node_is_ATSifnthen
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 4)

implement
instr_node_is_ATSbranchseq
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 5)

implement
instr_node_is_ATScaseofseq
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 6)

implement
instr_node_is_ATSfunbodyseq
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 7)

implement
instr_node_is_ATSreturn
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 8)

implement
instr_node_is_ATSreturn_void
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 9)

implement
instr_node_is_ATSlinepragma
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 10)

implement
instr_node_is_ATSINSlab
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 11)

implement
instr_node_is_ATSINSgoto
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 12)

implement
instr_node_is_ATSINSflab
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 13)

implement
instr_node_is_ATSINSfgoto
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 14)

implement
instr_node_is_ATSINSfreeclo
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 15)

implement
instr_node_is_ATSINSfreecon
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 16)

implement
instr_node_is_ATSINSmove
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 17)

implement
instr_node_is_ATSINSmove_void
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 18)

implement
instr_node_is_ATSINSmove_nil
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 19)

implement
instr_node_is_ATSINSmove_con0
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 20)

implement
instr_node_is_ATSINSmove_con1
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 21)

implement
instr_node_is_ATSINSmove_con1_new
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 22)

implement
instr_node_is_ATSINSstore_con1_tag
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 23)

implement
instr_node_is_ATSINSstore_con1_ofs
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 24)

implement
instr_node_is_ATSINSmove_boxrec
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 25)

implement
instr_node_is_ATSINSmove_boxrec_new
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 26)

implement
instr_node_is_ATSINSstore_boxrec_ofs
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 27)

implement
instr_node_is_ATSINSmove_fltrec
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 28)

implement
instr_node_is_ATSINSstore_fltrec_ofs
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 29)

implement
instr_node_is_ATSINSmove_delay
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 30)

implement
instr_node_is_ATSINSmove_lazyeval
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 31)

implement
instr_node_is_ATSINSmove_ldelay
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 32)

implement
instr_node_is_ATSINSmove_llazyeval
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 33)

implement
instr_node_is_ATStailcalseq
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 34)

implement
instr_node_is_ATSINSmove_tlcal
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 35)

implement
instr_node_is_ATSINSargmove_tlcal
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 36)

implement
instr_node_is_ATSINSextvar_assign
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 37)

implement
instr_node_is_ATSINSdyncst_valbind
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 38)

implement
instr_node_is_ATSINScaseof_fail
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 39)

implement
instr_node_is_ATSINSdeadcode_fail
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 40)

implement
instr_node_is_ATSdynload
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 41)

implement
instr_node_is_ATSdynloadset
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 42)

implement
instr_node_is_ATSdynloadfcall
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 43)

implement
instr_node_is_ATSdynloadflag_sta
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 44)

implement
instr_node_is_ATSdynloadflag_ext
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 45)

implement
instr_node_is_ATSdynloadflag_init
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 46)

implement
instr_node_is_ATSdynloadflag_minit
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 47)

implement
instr_node_is_ATSdynexn_dec
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 48)

implement
instr_node_is_ATSdynexn_extdec
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 49)

implement
instr_node_is_ATSdynexn_initize
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 50)

implement
instr_node_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => ATSif(arena_load<d0exp>(ptr_add<byte>(p, 8)), arena_load<glist(instr)>(ptr_add<byte>(p, 16)), arena_load<gopt(glist(instr))>(ptr_add<byte>(p, 24)))
| 1 => ATSthen(arena_load<glist(instr)>(ptr_add<byte>(p, 8)))
| 2 => ATSelse(arena_load<glist(instr)>(ptr_add<byte>(p, 8)))
| 3 => ATSifthen(arena_load<d0exp>(ptr_add<byte>(p, 8)), arena_load<glist(instr)>(ptr_add<byte>(p, 16)))
| 4 => ATSifnthen(arena_load<d0exp>(ptr_add<byte>(p, 8)), arena_load<glist(instr)>(ptr_add<byte>(p, 16)))
| 5 => ATSbranchseq(arena_load<glist(instr)>(ptr_add<byte>(p, 8)))
| 6 => ATScaseofseq(arena_load<glist(instr)>(ptr_add<byte>(p, 8)))
| 7 => ATSfunbodyseq(arena_load<glist(instr)>(ptr_add<byte>(p, 8)))
| 8 => ATSreturn(arena_load<i0de>(ptr_add<byte>(p, 8)))
| 9 => ATSreturn_void(arena_load<i0de>(ptr_add<byte>(p, 8)))
| 10 => ATSlinepragma(arena_load<token>(ptr_add<byte>(p, 8)), arena_load<token>(ptr_add<byte>(p, 16)))
| 11 => ATSINSlab(arena_load<i0de>(ptr_add<byte>(p, 8)))
| 12 => ATSINSgoto(arena_load<i0de>(ptr_add<byte>(p, 8)))
| 13 => ATSINSflab(arena_load<i0de>(ptr_add<byte>(p, 8)))
| 14 => ATSINSfgoto(arena_load<i0de>(ptr_add<byte>(p, 8)))
| 15 => ATSINSfreeclo(arena_load<d0exp>(ptr_add<byte>(p, 8)))
| 16 => ATSINSfreecon(arena_load<d0exp>(ptr_add<byte>(p, 8)))
| 17 => ATSINSmove(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<d0exp>(ptr_add<byte>(p, 16)))
| 18 => ATSINSmove_void(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<d0exp>(ptr_add<byte>(p, 16)))
| 19 => ATSINSmove_nil(arena_load<i0de>(ptr_add<byte>(p, 8)))
| 20 => ATSINSmove_con0(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<token>(ptr_add<byte>(p, 16)))
| 21 => ATSINSmove_con1(arena_load<glist(instr)>(ptr_add<byte>(p, 8)))
| 22 => ATSINSmove_con1_new(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<s0exp>(ptr_add<byte>(p, 16)))
| 23 => ATSINSstore_con1_tag(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<token>(ptr_add<byte>(p, 16)))
| 24 => ATSINSstore_con1_ofs(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<s0exp>(ptr_add<byte>(p, 16)), arena_load<i0de>(ptr_add<byte>(p, 24)), arena_load<d0exp>(ptr_add<byte>(p, 32)))
| 25 => ATSINSmove_boxrec(arena_load<glist(instr)>(ptr_add<byte>(p, 8)))
| 26 => ATSINSmove_boxrec_new(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<s0exp>(ptr_add<byte>(p, 16)))
| 27 => ATSINSstore_boxrec_ofs(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<s0exp>(ptr_add<byte>(p, 16)), arena_load<i0de>(ptr_add<byte>(p, 24)), arena_load<d0exp>(ptr_add<byte>(p, 32)))
| 28 => ATSINSmove_fltrec(arena_load<glist(instr)>(ptr_add<byte>(p, 8)))
| 29 => ATSINSstore_fltrec_ofs(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<s0exp>(ptr_add<byte>(p, 16)), arena_load<i0de>(ptr_add<byte>(p, 24)), arena_load<d0exp>(ptr_add<byte>(p, 32)))
| 30 => ATSINSmove_delay(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<s0exp>(ptr_add<byte>(p, 16)), arena_load<d0exp>(ptr_add<byte>(p, 24)))
| 31 => ATSINSmove_lazyeval(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<s0exp>(ptr_add<byte>(p, 16)), arena_load<d0exp>(ptr_add<byte>(p, 24)))
| 32 => ATSINSmove_ldelay(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<s0exp>(ptr_add<byte>(p, 16)), arena_load<d0exp>(ptr_add<byte>(p, 24)))
| 33 => ATSINSmove_llazyeval(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<s0exp>(ptr_add<byte>(p, 16)), arena_load<d0exp>(ptr_add<byte>(p, 24)))
| 34 => ATStailcalseq(arena_load<glist(instr)>(ptr_add<byte>(p, 8)))
| 35 => ATSINSmove_tlcal(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<d0exp>(ptr_add<byte>(p, 16)))
| 36 => ATSINSargmove_tlcal(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<i0de>(ptr_add<byte>(p, 16)))
| 37 => ATSINSextvar_assign(arena_load<d0exp>(ptr_add<byte>(p, 8)), arena_load<d0exp>(ptr_add<byte>(p, 16)))
| 38 => ATSINSdyncst_valbind(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<d0exp>(ptr_add<byte>(p, 16)))
| 39 => ATSINScaseof_fail(arena_load<token>(ptr_add<byte>(p, 8)))
| 40 => ATSINSdeadcode_fail(arena_load<token>(ptr_add<byte>(p, 8)))
| 41 => ATSdynload(arena_load<int>(ptr_add<byte>(p, 8)))
| 42 => ATSdynloadset(arena_load<i0de>(ptr_add<byte>(p, 8)))
| 43 => ATSdynloadfcall(arena_load<i0de>(ptr_add<byte>(p, 8)))
| 44 => ATSdynloadflag_sta(arena_load<i0de>(ptr_add<byte>(p, 8)))
| 45 => ATSdynloadflag_ext(arena_load<i0de>(ptr_add<byte>(p, 8)))
| 46 => ATSdynloadflag_init(arena_load<i0de>(ptr_add<byte>(p, 8)))
| 47 => ATSdynloadflag_minit(arena_load<i0de>(ptr_add<byte>(p, 8)))
| 48 => ATSdynexn_dec(arena_load<i0de>(ptr_add<byte>(p, 8)))
| 49 => ATSdynexn_extdec(arena_load<i0de>(ptr_add<byte>(p, 8)))
| _ => ATSdynexn_initize(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<string>(ptr_add<byte>(p, 16)))
//
end // end of [instr_node_view]

implement
instr_node_view_free
  (v) =
(
case+ v of
| ~ATSif(_, _, _) => ()
| ~ATSthen(_) => ()
| ~ATSelse(_) => ()
| ~ATSifthen(_, _) => ()
| ~ATSifnthen(_, _) => ()
| ~ATSbranchseq(_) => ()
| ~ATScaseofseq(_) => ()
| ~ATSfunbodyseq(_) => ()
| ~ATSreturn(_) => ()
| ~ATSreturn_void(_) => ()
| ~ATSlinepragma(_, _) => ()
| ~ATSINSlab(_) => ()
| ~ATSINSgoto(_) => ()
| ~ATSINSflab(_) => ()
| ~ATSINSfgoto(_) => ()
| ~ATSINSfreeclo(_) => ()
| ~ATSINSfreecon(_) => ()
| ~ATSINSmove(_, _) => ()
| ~ATSINSmove_void(_, _) => ()
| ~ATSINSmove_nil(_) => ()
| ~ATSINSmove_con0(_, _) => ()
| ~ATSINSmove_con1(_) => ()
| ~ATSINSmove_con1_new(_, _) => ()
| ~ATSINSstore_con1_tag(_, _) => ()
| ~ATSINSstore_con1_ofs(_, _, _, _) => ()
| ~ATSINSmove_boxrec(_) => ()
| ~ATSINSmove_boxrec_new(_, _) => ()
| ~ATSINSstore_boxrec_ofs(_, _, _, _) => ()
| ~ATSINSmove_fltrec(_) => ()
| ~ATSINSstore_fltrec_ofs(_, _, _, _) => ()
| ~ATSINSmove_delay(_, _, _) => ()
| ~ATSINSmove_lazyeval(_, _, _) => ()
| ~ATSINSmove_ldelay(_, _, _) => ()
| ~ATSINSmove_llazyeval(_, _, _) => ()
| ~ATStailcalseq(_) => ()
| ~ATSINSmove_tlcal(_, _) => ()
| ~ATSINSargmove_tlcal(_, _) => ()
| ~ATSINSextvar_assign(_, _) => ()
| ~ATSINSdyncst_valbind(_, _) => ()
| ~ATSINScaseof_fail(_) => ()
| ~ATSINSdeadcode_fail(_) => ()
| ~ATSdynload(_) => ()
| ~ATSdynloadset(_) => ()
| ~ATSdynloadfcall(_) => ()
| ~ATSdynloadflag_sta(_) => ()
| ~ATSdynloadflag_ext(_) => ()
| ~ATSdynloadflag_init(_) => ()
| ~ATSdynloadflag_minit(_) => ()
| ~ATSdynexn_dec(_) => ()
| ~ATSdynexn_extdec(_) => ()
| ~ATSdynexn_initize(_, _) => ()
) (* end of [instr_node_view_free] *)

(* ****** ****** *)

implement
instr_INSTR
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<loc_t>(ptr_add<byte>(p, 8), a0)
val () = arena_store<instr_node>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{instr}(p)
end // end of [instr_INSTR]

implement
instr_encode
  (v) =
(
case+ v of
| ~INSTR(a0, a1) => instr_INSTR(a0, a1)
) (* end of [instr_encode] *)

implement
instr_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
instr_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| _ => INSTR(arena_load<loc_t>(ptr_add<byte>(p, 8)), arena_load<instr_node>(ptr_add<byte>(p, 16)))
//
end // end of [instr_view]

implement
instr_view_free
  (v) =
(
case+ v of
| ~INSTR(_, _) => ()
) (* end of [instr_view_free] *)

implement
instr_get_instr_loc
  (x) =
  arena_load<loc_t>(ptr_add<byte>($UN.cast{ptr}(x), 8))

implement
instr_get_instr_node
  (x) =
  arena_load<instr_node>(ptr_add<byte>($UN.cast{ptr}(x), 16))

(* ****** ****** *)

implement
f0body_node_F0BODY
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<glist(tmpdec)>(ptr_add<byte>(p, 8), a0)
val () = arena_store<glist(instr)>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{f0body_node}(p)
end // end of [f0body_node_F0BODY]

implement
f0body_node_encode
  (v) =
(
case+ v of
| ~F0BODY(a0, a1) => f0body_node_F0BODY(a0, a1)
) (* end of [f0body_node_encode] *)

implement
f0body_node_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
f0body_node_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| _ => F0BODY(arena_load<glist(tmpdec)>(ptr_add<byte>(p, 8)), arena_load<glist(instr)>(ptr_add<byte>(p, 16)))
//
end // end of [f0body_node_view]

implement
f0body_node_view_free
  (v) =
(
case+ v of
| ~F0BODY(_, _) => ()
) (* end of [f0body_node_view_free] *)

(* ****** ****** *)

implement
f0body_F0BODYREC
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<loc_t>(ptr_add<byte>(p, 8), a0)
val () = arena_store<f0body_node>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{f0body}(p)
end // end of [f0body_F0BODYREC]

implement
f0body_encode
  (v) =
(
case+ v of
| ~F0BODYREC(a0, a1) => f0body_F0BODYREC(a0, a1)
) (* end of [f0body_encode] *)

implement
f0body_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
f0body_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| _ => F0BODYREC(arena_load<loc_t>(ptr_add<byte>(p, 8)), arena_load<f0body_node>(ptr_add<byte>(p, 16)))
//
end // end of [f0body_view]

implement
f0body_view_free
  (v) =
(
case+ v of
| ~F0BODYREC(_, _) => ()
) (* end of [f0body_view_free] *)

implement
f0body_get_f0body_loc
  (x) =
  arena_load<loc_t>(ptr_add<byte>($UN.cast{ptr}(x), 8))

implement
f0body_get_f0body_node
  (x) =
  arena_load<f0body_node>(ptr_add<byte>($UN.cast{ptr}(x), 16))

(* ****** ****** *)

implement
f0decl_node_F0DECLnone
  (a0) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<f0head>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{f0decl_node}(p)
end // end of [f0decl_node_F0DECLnone]

implement
f0decl_node_F0DECLsome
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 1)
val () = arena_store<f0head>(ptr_add<byte>(p, 8), a0)
val () = arena_store<f0body>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{f0decl_node}(p)
end // end of [f0decl_node_F0DECLsome]

implement
f0decl_node_encode
  (v) =
(
case+ v of
| ~F0DECLnone(a0) => f0decl_node_F0DECLnone(a0)
| ~F0DECLsome(a0, a1) => f0decl_node_F0DECLsome(a0, a1)
) (* end of [f0decl_node_encode] *)

implement
f0decl_node_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
f0decl_node_is_F0DECLnone
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
f0decl_node_is_F0DECLsome
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
f0decl_node_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => F0DECLnone(arena_load<f0head>(ptr_add<byte>(p, 8)))
| _ => F0DECLsome(arena_load<f0head>(ptr_add<byte>(p, 8)), arena_load<f0body>(ptr_add<byte>(p, 16)))
//
end // end of [f0decl_node_view]

implement
f0decl_node_view_free
  (v) =
(
case+ v of
| ~F0DECLnone(_) => ()
| ~F0DECLsome(_, _) => ()
) (* end of [f0decl_node_view_free] *)

(* ****** ****** *)

implement
f0decl_F0DECLREC
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<loc_t>(ptr_add<byte>(p, 8), a0)
val () = arena_store<f0decl_node>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{f0decl}(p)
end // end of [f0decl_F0DECLREC]

implement
f0decl_encode
  (v) =
(
case+ v of
| ~F0DECLREC(a0, a1) => f0decl_F0DECLREC(a0, a1)
) (* end of [f0decl_encode] *)

implement
f0decl_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
f0decl_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| _ => F0DECLREC(arena_load<loc_t>(ptr_add<byte>(p, 8)), arena_load<f0decl_node>(ptr_add<byte>(p, 16)))
//
end // end of [f0decl_view]

implement
f0decl_view_free
  (v) =
(
case+ v of
| ~F0DECLREC(_, _) => ()
) (* end of [f0decl_view_free] *)

implement
f0decl_get_f0decl_loc
  (x) =
  arena_load<loc_t>(ptr_add<byte>($UN.cast{ptr}(x), 8))

implement
f0decl_get_f0decl_node
  (x) =
  arena_load<f0decl_node>(ptr_add<byte>($UN.cast{ptr}(x), 16))

(* ****** ****** *)

implement
d0ecl_node_D0Cinclude
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 0)
val () = arena_store<token>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{d0ecl_node}(p)
end // end of [d0ecl_node_D0Cinclude]

implement
d0ecl_node_D0Cifdef
  (a0, a1) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 1)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<glist(d0ecl)>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{d0ecl_node}(p)
end // end of [d0ecl_node_D0Cifdef]

implement
d0ecl_node_D0Cifndef
  (a0, a1) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 2)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<glist(d0ecl)>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{d0ecl_node}(p)
end // end of [d0ecl_node_D0Cifndef]

implement
d0ecl_node_D0Ctypedef
  (a0, a1) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 3)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<tyrec>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{d0ecl_node}(p)
end // end of [d0ecl_node_D0Ctypedef]

implement
d0ecl_node_D0Cassume
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 4)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{d0ecl_node}(p)
end // end of [d0ecl_node_D0Cassume]

implement
d0ecl_node_D0Cdyncst_mac
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 5)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{d0ecl_node}(p)
end // end of [d0ecl_node_D0Cdyncst_mac]

implement
d0ecl_node_D0Cdyncst_extfun
  (a0, a1, a2) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 6)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<glist(s0exp)>(ptr_add<byte>(p, 16), a1)
val () = arena_store<s0exp>(ptr_add<byte>(p, 24), a2)
in
  $UN.cast{d0ecl_node}(p)
end // end of [d0ecl_node_D0Cdyncst_extfun]

implement
d0ecl_node_D0Cdyncst_valdec
  (a0, a1) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 7)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<s0exp>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{d0ecl_node}(p)
end // end of [d0ecl_node_D0Cdyncst_valdec]

implement
d0ecl_node_D0Cdyncst_valimp
  (a0, a1) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 8)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<s0exp>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{d0ecl_node}(p)
end // end of [d0ecl_node_D0Cdyncst_valimp]

implement
d0ecl_node_D0Cextcode
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 9)
val () = arena_store<glist(token)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{d0ecl_node}(p)
end // end of [d0ecl_node_D0Cextcode]

implement
d0ecl_node_D0Cstatmp
  (a0, a1) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 10)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<gopt(s0exp)>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{d0ecl_node}(p)
end // end of [d0ecl_node_D0Cstatmp]

implement
d0ecl_node_D0Cfundecl
  (a0, a1) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 11)
val () = arena_store<fkind>(ptr_add<byte>(p, 8), a0)
val () = arena_store<f0decl>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{d0ecl_node}(p)
end // end of [d0ecl_node_D0Cfundecl]

implement
d0ecl_node_D0Cclosurerize
  (a0, a1, a2, a3) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 12)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<s0exp>(ptr_add<byte>(p, 16), a1)
val () = arena_store<s0exp>(ptr_add<byte>(p, 24), a2)
val () = arena_store<s0exp>(ptr_add<byte>(p, 32), a3)
in
  $UN.cast{d0ecl_node}(p)
end // end of [d0ecl_node_D0Cclosurerize]

implement
d0ecl_node_D0Cdynloadflag_init
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 13)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{d0ecl_node}(p)
end // end of [d0ecl_node_D0Cdynloadflag_init]

implement
d0ecl_node_D0Cdynloadflag_minit
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 14)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{d0ecl_node}(p)
end // end of [d0ecl_node_D0Cdynloadflag_minit]

implement
d0ecl_node_D0Cdynexn_dec
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 15)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{d0ecl_node}(p)
end // end of [d0ecl_node_D0Cdynexn_dec]

implement
d0ecl_node_D0Cdynexn_extdec
  (a0) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 16)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{d0ecl_node}(p)
end // end of [d0ecl_node_D0Cdynexn_extdec]

implement
d0ecl_node_D0Cdynexn_initize
  (a0, a1) = let
val p = the_garena_alloc(i2sz(40))
val () = arena_store<int>(p, 17)
val () = arena_store<i0de>(ptr_add<byte>(p, 8), a0)
val () = arena_store<token>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{d0ecl_node}(p)
end // end of [d0ecl_node_D0Cdynexn_initize]

implement
d0ecl_node_encode
  (v) =
(
case+ v of
| ~D0Cinclude(a0) => d0ecl_node_D0Cinclude(a0)
| ~D0Cifdef(a0, a1) => d0ecl_node_D0Cifdef(a0, a1)
| ~D0Cifndef(a0, a1) => d0ecl_node_D0Cifndef(a0, a1)
| ~D0Ctypedef(a0, a1) => d0ecl_node_D0Ctypedef(a0, a1)
| ~D0Cassume(a0) => d0ecl_node_D0Cassume(a0)
| ~D0Cdyncst_mac(a0) => d0ecl_node_D0Cdyncst_mac(a0)
| ~D0Cdyncst_extfun(a0, a1, a2) => d0ecl_node_D0Cdyncst_extfun(a0, a1, a2)
| ~D0Cdyncst_valdec(a0, a1) => d0ecl_node_D0Cdyncst_valdec(a0, a1)
| ~D0Cdyncst_valimp(a0, a1) => d0ecl_node_D0Cdyncst_valimp(a0, a1)
| ~D0Cextcode(a0) => d0ecl_node_D0Cextcode(a0)
| ~D0Cstatmp(a0, a1) => d0ecl_node_D0Cstatmp(a0, a1)
| ~D0Cfundecl(a0, a1) => d0ecl_node_D0Cfundecl(a0, a1)
| ~D0Cclosurerize(a0, a1, a2, a3) => d0ecl_node_D0Cclosurerize(a0, a1, a2, a3)
| ~D0Cdynloadflag_init(a0) => d0ecl_node_D0Cdynloadflag_init(a0)
| ~D0Cdynloadflag_minit(a0) => d0ecl_node_D0Cdynloadflag_minit(a0)
| ~D0Cdynexn_dec(a0) => d0ecl_node_D0Cdynexn_dec(a0)
| ~D0Cdynexn_extdec(a0) => d0ecl_node_D0Cdynexn_extdec(a0)
| ~D0Cdynexn_initize(a0, a1) => d0ecl_node_D0Cdynexn_initize(a0, a1)
) (* end of [d0ecl_node_encode] *)

implement
d0ecl_node_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
d0ecl_node_is_D0Cinclude
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
d0ecl_node_is_D0Cifdef
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
d0ecl_node_is_D0Cifndef
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 2)

implement
d0ecl_node_is_D0Ctypedef
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 3)

implement
d0ecl_node_is_D0Cassume
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 4)

implement
d0ecl_node_is_D0Cdyncst_mac
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 5)

implement
d0ecl_node_is_D0Cdyncst_extfun
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 6)

implement
d0ecl_node_is_D0Cdyncst_valdec
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 7)

implement
d0ecl_node_is_D0Cdyncst_valimp
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 8)

implement
d0ecl_node_is_D0Cextcode
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 9)

implement
d0ecl_node_is_D0Cstatmp
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 10)

implement
d0ecl_node_is_D0Cfundecl
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 11)

implement
d0ecl_node_is_D0Cclosurerize
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 12)

implement
d0ecl_node_is_D0Cdynloadflag_init
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 13)

implement
d0ecl_node_is_D0Cdynloadflag_minit
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 14)

implement
d0ecl_node_is_D0Cdynexn_dec
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 15)

implement
d0ecl_node_is_D0Cdynexn_extdec
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 16)

implement
d0ecl_node_is_D0Cdynexn_initize
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 17)

implement
d0ecl_node_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => D0Cinclude(arena_load<token>(ptr_add<byte>(p, 8)))
| 1 => D0Cifdef(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<glist(d0ecl)>(ptr_add<byte>(p, 16)))
| 2 => D0Cifndef(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<glist(d0ecl)>(ptr_add<byte>(p, 16)))
| 3 => D0Ctypedef(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<tyrec>(ptr_add<byte>(p, 16)))
| 4 => D0Cassume(arena_load<i0de>(ptr_add<byte>(p, 8)))
| 5 => D0Cdyncst_mac(arena_load<i0de>(ptr_add<byte>(p, 8)))
| 6 => D0Cdyncst_extfun(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<glist(s0exp)>(ptr_add<byte>(p, 16)), arena_load<s0exp>(ptr_add<byte>(p, 24)))
| 7 => D0Cdyncst_valdec(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<s0exp>(ptr_add<byte>(p, 16)))
| 8 => D0Cdyncst_valimp(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<s0exp>(ptr_add<byte>(p, 16)))
| 9 => D0Cextcode(arena_load<glist(token)>(ptr_add<byte>(p, 8)))
| 10 => D0Cstatmp(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<gopt(s0exp)>(ptr_add<byte>(p, 16)))
| 11 => D0Cfundecl(arena_load<fkind>(ptr_add<byte>(p, 8)), arena_load<f0decl>(ptr_add<byte>(p, 16)))
| 12 => D0Cclosurerize(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<s0exp>(ptr_add<byte>(p, 16)), arena_load<s0exp>(ptr_add<byte>(p, 24)), arena_load<s0exp>(ptr_add<byte>(p, 32)))
| 13 => D0Cdynloadflag_init(arena_load<i0de>(ptr_add<byte>(p, 8)))
| 14 => D0Cdynloadflag_minit(arena_load<i0de>(ptr_add<byte>(p, 8)))
| 15 => D0Cdynexn_dec(arena_load<i0de>(ptr_add<byte>(p, 8)))
| 16 => D0Cdynexn_extdec(arena_load<i0de>(ptr_add<byte>(p, 8)))
| _ => D0Cdynexn_initize(arena_load<i0de>(ptr_add<byte>(p, 8)), arena_load<token>(ptr_add<byte>(p, 16)))
//
end // end of [d0ecl_node_view]

implement
d0ecl_node_view_free
  (v) =
(
case+ v of
| ~D0Cinclude(_) => ()
| ~D0Cifdef(_, _) => ()
| ~D0Cifndef(_, _) => ()
| ~D0Ctypedef(_, _) => ()
| ~D0Cassume(_) => ()
| ~D0Cdyncst_mac(_) => ()
| ~D0Cdyncst_extfun(_, _, _) => ()
| ~D0Cdyncst_valdec(_, _) => ()
| ~D0Cdyncst_valimp(_, _) => ()
| ~D0Cextcode(_) => ()
| ~D0Cstatmp(_, _) => ()
| ~D0Cfundecl(_, _) => ()
| ~D0Cclosurerize(_, _, _, _) => ()
| ~D0Cdynloadflag_init(_) => ()
| ~D0Cdynloadflag_minit(_) => ()
| ~D0Cdynexn_dec(_) => ()
| ~D0Cdynexn_extdec(_) => ()
| ~D0Cdynexn_initize(_, _) => ()
) (* end of [d0ecl_node_view_free] *)

(* ****** ****** *)

implement
d0ecl_D0ECLREC
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<loc_t>(ptr_add<byte>(p, 8), a0)
val () = arena_store<d0ecl_node>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{d0ecl}(p)
end // end of [d0ecl_D0ECLREC]

implement
d0ecl_encode
  (v) =
(
case+ v of
| ~D0ECLREC(a0, a1) => d0ecl_D0ECLREC(a0, a1)
) (* end of [d0ecl_encode] *)

implement
d0ecl_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
d0ecl_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| _ => D0ECLREC(arena_load<loc_t>(ptr_add<byte>(p, 8)), arena_load<d0ecl_node>(ptr_add<byte>(p, 16)))
//
end // end of [d0ecl_view]

implement
d0ecl_view_free
  (v) =
(
case+ v of
| ~D0ECLREC(_, _) => ()
) (* end of [d0ecl_view_free] *)

implement
d0ecl_get_d0ecl_loc
  (x) =
  arena_load<loc_t>(ptr_add<byte>($UN.cast{ptr}(x), 8))

implement
d0ecl_get_d0ecl_node
  (x) =
  arena_load<d0ecl_node>(ptr_add<byte>($UN.cast{ptr}(x), 16))

(* ****** ****** *)
