implement
token_node_T_NONE
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_NONE]

implement
token_node_T_AT
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 1)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_AT]

implement
token_node_T_BAR
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 2)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_BAR]

implement
token_node_T_BANG
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 3)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_BANG]

implement
token_node_T_BQUOTE
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 4)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_BQUOTE]

implement
token_node_T_BACKSLASH
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 5)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_BACKSLASH]

implement
token_node_T_COLON
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 6)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_COLON]

implement
token_node_T_COLONLT
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 7)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_COLONLT]

implement
token_node_T_DOLLAR
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 8)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DOLLAR]

implement
token_node_T_DOT
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 9)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DOT]

implement
token_node_T_DOTDOT
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 10)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DOTDOT]

implement
token_node_T_DOTDOTDOT
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 11)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DOTDOTDOT]

implement
token_node_T_DOTINT
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 12)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DOTINT]

implement
token_node_T_EQ
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 13)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_EQ]

implement
token_node_T_EQGT
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 14)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_EQGT]

implement
token_node_T_EQLT
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 15)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_EQLT]

implement
token_node_T_EQLTGT
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 16)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_EQLTGT]

implement
token_node_T_EQSLASHEQGT
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 17)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_EQSLASHEQGT]

implement
token_node_T_EQGTGT
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 18)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_EQGTGT]

implement
token_node_T_EQSLASHEQGTGT
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 19)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_EQSLASHEQGTGT]

implement
token_node_T_HASH
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 20)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_HASH]

implement
token_node_T_LT
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 21)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_LT]

implement
token_node_T_GT
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 22)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_GT]

implement
token_node_T_GTLT
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 23)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_GTLT]

implement
token_node_T_DOTLT
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 24)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DOTLT]

implement
token_node_T_GTDOT
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 25)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_GTDOT]

implement
token_node_T_DOTLTGTDOT
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 26)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DOTLTGTDOT]

implement
token_node_T_MINUSGT
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 27)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_MINUSGT]

implement
token_node_T_MINUSLT
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 28)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_MINUSLT]

implement
token_node_T_MINUSLTGT
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 29)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_MINUSLTGT]

implement
token_node_T_TILDE
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 30)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_TILDE]

implement
token_node_T_ABSTYPE
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 31)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_ABSTYPE]

implement
token_node_T_ASSUME
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 32)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_ASSUME]

implement
token_node_T_REASSUME
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 33)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_REASSUME]

implement
token_node_T_AS
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 34)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_AS]

implement
token_node_T_AND
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 35)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_AND]

implement
token_node_T_BEGIN
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 36)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_BEGIN]

implement
token_node_T_CASE
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 37)
val () = arena_store<caskind>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_CASE]

implement
token_node_T_CLASSDEC
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 38)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_CLASSDEC]

implement
token_node_T_DATASORT
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 39)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DATASORT]

implement
token_node_T_DATATYPE
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 40)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DATATYPE]

implement
token_node_T_DO
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 41)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DO]

implement
token_node_T_ELSE
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 42)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_ELSE]

implement
token_node_T_END
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 43)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_END]

implement
token_node_T_EXCEPTION
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 44)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_EXCEPTION]

implement
token_node_T_EXTERN
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 45)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_EXTERN]

implement
token_node_T_EXTYPE
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 46)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_EXTYPE]

implement
token_node_T_EXTVAR
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 47)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_EXTVAR]

implement
token_node_T_FIX
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 48)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_FIX]

implement
token_node_T_FIXITY
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 49)
val () = arena_store<fxtykind>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_FIXITY]

implement
token_node_T_FOR
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 50)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_FOR]

implement
token_node_T_FORSTAR
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 51)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_FORSTAR]

implement
token_node_T_FUN
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 52)
val () = arena_store<funkind>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_FUN]

implement
token_node_T_IF
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 53)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_IF]

implement
token_node_T_IFCASE
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 54)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_IFCASE]

implement
token_node_T_IMPLEMENT
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 55)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_IMPLEMENT]

implement
token_node_T_IMPORT
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 56)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_IMPORT]

implement
token_node_T_IN
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 57)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_IN]

implement
token_node_T_LAM
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 58)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_LAM]

implement
token_node_T_LET
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 59)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_LET]

implement
token_node_T_LOCAL
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 60)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_LOCAL]

implement
token_node_T_MACDEF
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 61)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_MACDEF]

implement
token_node_T_NONFIX
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 62)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_NONFIX]

implement
token_node_T_OF
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 63)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_OF]

implement
token_node_T_OP
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 64)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_OP]

implement
token_node_T_REC
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 65)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_REC]

implement
token_node_T_SIF
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 66)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SIF]

implement
token_node_T_SCASE
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 67)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SCASE]

implement
token_node_T_STACST
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 68)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_STACST]

implement
token_node_T_STADEF
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 69)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_STADEF]

implement
token_node_T_STATIC
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 70)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_STATIC]

implement
token_node_T_SORTDEF
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 71)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SORTDEF]

implement
token_node_T_SYMELIM
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 72)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SYMELIM]

implement
token_node_T_SYMINTR
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 73)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SYMINTR]

implement
token_node_T_SYMLOAD
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 74)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SYMLOAD]

implement
token_node_T_THEN
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 75)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_THEN]

implement
token_node_T_TKINDEF
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 76)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_TKINDEF]

implement
token_node_T_TRY
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 77)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_TRY]

implement
token_node_T_TYPE
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 78)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_TYPE]

implement
token_node_T_TYPEDEF
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 79)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_TYPEDEF]

implement
token_node_T_VAL
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 80)
val () = arena_store<valkind>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_VAL]

implement
token_node_T_VAR
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 81)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_VAR]

implement
token_node_T_WHEN
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 82)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_WHEN]

implement
token_node_T_WHERE
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 83)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_WHERE]

implement
token_node_T_WHILE
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 84)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_WHILE]

implement
token_node_T_WHILESTAR
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 85)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_WHILESTAR]

implement
token_node_T_WITH
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 86)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_WITH]

implement
token_node_T_WITHTYPE
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 87)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_WITHTYPE]

implement
token_node_T_ADDRAT
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 88)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_ADDRAT]

implement
token_node_T_FOLDAT
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 89)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_FOLDAT]

implement
token_node_T_FREEAT
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 90)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_FREEAT]

implement
token_node_T_VIEWAT
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 91)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_VIEWAT]

implement
token_node_T_DLRDELAY
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 92)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DLRDELAY]

implement
token_node_T_DLRARRPSZ
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 93)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DLRARRPSZ]

implement
token_node_T_DLRTYREP
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 94)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DLRTYREP]

implement
token_node_T_DLRD2CTYPE
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 95)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DLRD2CTYPE]

implement
token_node_T_DLREFFMASK
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 96)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DLREFFMASK]

implement
token_node_T_DLREFFMASK_ARG
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 97)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DLREFFMASK_ARG]

implement
token_node_T_DLREXTERN
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 98)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DLREXTERN]

implement
token_node_T_DLREXTYPE
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 99)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DLREXTYPE]

implement
token_node_T_DLREXTKIND
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 100)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DLREXTKIND]

implement
token_node_T_DLREXTYPE_STRUCT
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 101)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DLREXTYPE_STRUCT]

implement
token_node_T_DLREXTVAL
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 102)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DLREXTVAL]

implement
token_node_T_DLREXTFCALL
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 103)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DLREXTFCALL]

implement
token_node_T_DLREXTMCALL
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 104)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DLREXTMCALL]

implement
token_node_T_DLRLITERAL
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 105)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DLRLITERAL]

implement
token_node_T_DLRMYFILENAME
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 106)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DLRMYFILENAME]

implement
token_node_T_DLRMYLOCATION
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 107)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DLRMYLOCATION]

implement
token_node_T_DLRMYFUNCTION
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 108)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DLRMYFUNCTION]

implement
token_node_T_DLRLST
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 109)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DLRLST]

implement
token_node_T_DLRREC
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 110)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DLRREC]

implement
token_node_T_DLRTUP
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 111)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DLRTUP]

implement
token_node_T_DLRBREAK
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 112)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DLRBREAK]

implement
token_node_T_DLRCONTINUE
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 113)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DLRCONTINUE]

implement
token_node_T_DLRRAISE
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 114)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DLRRAISE]

implement
token_node_T_DLRVARARG
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 115)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DLRVARARG]

implement
token_node_T_DLRVCOPYENV
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 116)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DLRVCOPYENV]

implement
token_node_T_DLRSHOWTYPE
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 117)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DLRSHOWTYPE]

implement
token_node_T_DLRTEMPENVER
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 118)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DLRTEMPENVER]

implement
token_node_T_DLRSOLASSERT
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 119)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DLRSOLASSERT]

implement
token_node_T_DLRSOLVERIFY
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 120)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_DLRSOLVERIFY]

implement
token_node_T_SRPIF
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 121)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SRPIF]

implement
token_node_T_SRPIFDEF
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 122)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SRPIFDEF]

implement
token_node_T_SRPIFNDEF
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 123)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SRPIFNDEF]

implement
token_node_T_SRPTHEN
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 124)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SRPTHEN]

implement
token_node_T_SRPELIF
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 125)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SRPELIF]

implement
token_node_T_SRPELIFDEF
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 126)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SRPELIFDEF]

implement
token_node_T_SRPELIFNDEF
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 127)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SRPELIFNDEF]

implement
token_node_T_SRPELSE
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 128)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SRPELSE]

implement
token_node_T_SRPENDIF
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 129)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SRPENDIF]

implement
token_node_T_SRPERROR
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 130)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SRPERROR]

implement
token_node_T_SRPPRERR
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 131)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SRPPRERR]

implement
token_node_T_SRPPRINT
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 132)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SRPPRINT]

implement
token_node_T_SRPASSERT
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 133)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SRPASSERT]

implement
token_node_T_SRPUNDEF
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 134)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SRPUNDEF]

implement
token_node_T_SRPDEFINE
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 135)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SRPDEFINE]

implement
token_node_T_SRPINCLUDE
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 136)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SRPINCLUDE]

implement
token_node_T_SRPSTALOAD
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 137)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SRPSTALOAD]

implement
token_node_T_SRPDYNLOAD
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 138)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SRPDYNLOAD]

implement
token_node_T_SRPREQUIRE
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 139)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SRPREQUIRE]

implement
token_node_T_SRPPRAGMA
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 140)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SRPPRAGMA]

implement
token_node_T_SRPCODEGEN2
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 141)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SRPCODEGEN2]

implement
token_node_T_SRPCODEGEN3
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 142)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SRPCODEGEN3]

implement
token_node_T_IDENT_alp
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 143)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_IDENT_alp]

implement
token_node_T_IDENT_sym
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 144)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_IDENT_sym]

implement
token_node_T_IDENT_arr
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 145)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_IDENT_arr]

implement
token_node_T_IDENT_tmp
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 146)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_IDENT_tmp]

implement
token_node_T_IDENT_dlr
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 147)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_IDENT_dlr]

implement
token_node_T_IDENT_srp
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 148)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_IDENT_srp]

implement
token_node_T_IDENT_ext
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 149)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_IDENT_ext]

implement
token_node_T_INT
  (a0, a1, a2) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 150)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
val () = arena_store<string>(ptr_add<byte>(p, 16), a1)
val () = arena_store<uint>(ptr_add<byte>(p, 24), a2)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_INT]

implement
token_node_T_CHAR
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 151)
val () = arena_store<char>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_CHAR]

implement
token_node_T_FLOAT
  (a0, a1, a2) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 152)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
val () = arena_store<string>(ptr_add<byte>(p, 16), a1)
val () = arena_store<uint>(ptr_add<byte>(p, 24), a2)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_FLOAT]

implement
token_node_T_CDATA
  (a0, a1) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 153)
val () = arena_store<ptr>(ptr_add<byte>(p, 8), a0)
val () = arena_store<size_t>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_CDATA]

implement
token_node_T_STRING
  (a0) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 154)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_STRING]

implement
token_node_T_COMMA
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 155)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_COMMA]

implement
token_node_T_SEMICOLON
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 156)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_SEMICOLON]

implement
token_node_T_LPAREN
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 157)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_LPAREN]

implement
token_node_T_RPAREN
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 158)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_RPAREN]

implement
token_node_T_LBRACKET
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 159)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_LBRACKET]

implement
token_node_T_RBRACKET
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 160)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_RBRACKET]

implement
token_node_T_LBRACE
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 161)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_LBRACE]

implement
token_node_T_RBRACE
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 162)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_RBRACE]

implement
token_node_T_ATLPAREN
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 163)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_ATLPAREN]

implement
token_node_T_QUOTELPAREN
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 164)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_QUOTELPAREN]

implement
token_node_T_ATLBRACKET
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 165)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_ATLBRACKET]

implement
token_node_T_QUOTELBRACKET
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 166)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_QUOTELBRACKET]

implement
token_node_T_HASHLBRACKET
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 167)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_HASHLBRACKET]

implement
token_node_T_ATLBRACE
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 168)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_ATLBRACE]

implement
token_node_T_QUOTELBRACE
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 169)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_QUOTELBRACE]

implement
token_node_T_BQUOTELPAREN
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 170)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_BQUOTELPAREN]

implement
token_node_T_COMMALPAREN
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 171)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_COMMALPAREN]

implement
token_node_T_PERCENTLPAREN
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 172)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_PERCENTLPAREN]

implement
token_node_T_EXTCODE
  (a0, a1) = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 173)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
val () = arena_store<string>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_EXTCODE]

implement
token_node_T_COMMENT_line
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 174)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_COMMENT_line]

implement
token_node_T_COMMENT_rest
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 175)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_COMMENT_rest]

implement
token_node_T_COMMENT_block
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 176)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_COMMENT_block]

implement
token_node_T_ERR
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 177)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_ERR]

implement
token_node_T_EOF
  () = let
val p = the_garena_alloc(i2sz(32))
val () = arena_store<int>(p, 178)
in
  $UN.cast{token_node}(p)
end // end of [token_node_T_EOF]

implement
token_node_encode
  (v) =
(
case+ v of
| ~T_NONE() => token_node_T_NONE()
| ~T_AT() => token_node_T_AT()
| ~T_BAR() => token_node_T_BAR()
| ~T_BANG() => token_node_T_BANG()
| ~T_BQUOTE() => token_node_T_BQUOTE()
| ~T_BACKSLASH() => token_node_T_BACKSLASH()
| ~T_COLON() => token_node_T_COLON()
| ~T_COLONLT() => token_node_T_COLONLT()
| ~T_DOLLAR() => token_node_T_DOLLAR()
| ~T_DOT() => token_node_T_DOT()
| ~T_DOTDOT() => token_node_T_DOTDOT()
| ~T_DOTDOTDOT() => token_node_T_DOTDOTDOT()
| ~T_DOTINT(a0) => token_node_T_DOTINT(a0)
| ~T_EQ() => token_node_T_EQ()
| ~T_EQGT() => token_node_T_EQGT()
| ~T_EQLT() => token_node_T_EQLT()
| ~T_EQLTGT() => token_node_T_EQLTGT()
| ~T_EQSLASHEQGT() => token_node_T_EQSLASHEQGT()
| ~T_EQGTGT() => token_node_T_EQGTGT()
| ~T_EQSLASHEQGTGT() => token_node_T_EQSLASHEQGTGT()
| ~T_HASH() => token_node_T_HASH()
| ~T_LT() => token_node_T_LT()
| ~T_GT() => token_node_T_GT()
| ~T_GTLT() => token_node_T_GTLT()
| ~T_DOTLT() => token_node_T_DOTLT()
| ~T_GTDOT() => token_node_T_GTDOT()
| ~T_DOTLTGTDOT() => token_node_T_DOTLTGTDOT()
| ~T_MINUSGT() => token_node_T_MINUSGT()
| ~T_MINUSLT() => token_node_T_MINUSLT()
| ~T_MINUSLTGT() => token_node_T_MINUSLTGT()
| ~T_TILDE() => token_node_T_TILDE()
| ~T_ABSTYPE(a0) => token_node_T_ABSTYPE(a0)
| ~T_ASSUME() => token_node_T_ASSUME()
| ~T_REASSUME() => token_node_T_REASSUME()
| ~T_AS() => token_node_T_AS()
| ~T_AND() => token_node_T_AND()
| ~T_BEGIN() => token_node_T_BEGIN()
| ~T_CASE(a0) => token_node_T_CASE(a0)
| ~T_CLASSDEC() => token_node_T_CLASSDEC()
| ~T_DATASORT() => token_node_T_DATASORT()
| ~T_DATATYPE(a0) => token_node_T_DATATYPE(a0)
| ~T_DO() => token_node_T_DO()
| ~T_ELSE() => token_node_T_ELSE()
| ~T_END() => token_node_T_END()
| ~T_EXCEPTION() => token_node_T_EXCEPTION()
| ~T_EXTERN() => token_node_T_EXTERN()
| ~T_EXTYPE() => token_node_T_EXTYPE()
| ~T_EXTVAR() => token_node_T_EXTVAR()
| ~T_FIX(a0) => token_node_T_FIX(a0)
| ~T_FIXITY(a0) => token_node_T_FIXITY(a0)
| ~T_FOR() => token_node_T_FOR()
| ~T_FORSTAR() => token_node_T_FORSTAR()
| ~T_FUN(a0) => token_node_T_FUN(a0)
| ~T_IF() => token_node_T_IF()
| ~T_IFCASE() => token_node_T_IFCASE()
| ~T_IMPLEMENT(a0) => token_node_T_IMPLEMENT(a0)
| ~T_IMPORT() => token_node_T_IMPORT()
| ~T_IN() => token_node_T_IN()
| ~T_LAM(a0) => token_node_T_LAM(a0)
| ~T_LET() => token_node_T_LET()
| ~T_LOCAL() => token_node_T_LOCAL()
| ~T_MACDEF(a0) => token_node_T_MACDEF(a0)
| ~T_NONFIX() => token_node_T_NONFIX()
| ~T_OF() => token_node_T_OF()
| ~T_OP() => token_node_T_OP()
| ~T_REC() => token_node_T_REC()
| ~T_SIF() => token_node_T_SIF()
| ~T_SCASE() => token_node_T_SCASE()
| ~T_STACST() => token_node_T_STACST()
| ~T_STADEF() => token_node_T_STADEF()
| ~T_STATIC() => token_node_T_STATIC()
| ~T_SORTDEF() => token_node_T_SORTDEF()
| ~T_SYMELIM() => token_node_T_SYMELIM()
| ~T_SYMINTR() => token_node_T_SYMINTR()
| ~T_SYMLOAD() => token_node_T_SYMLOAD()
| ~T_THEN() => token_node_T_THEN()
| ~T_TKINDEF() => token_node_T_TKINDEF()
| ~T_TRY() => token_node_T_TRY()
| ~T_TYPE(a0) => token_node_T_TYPE(a0)
| ~T_TYPEDEF(a0) => token_node_T_TYPEDEF(a0)
| ~T_VAL(a0) => token_node_T_VAL(a0)
| ~T_VAR(a0) => token_node_T_VAR(a0)
| ~T_WHEN() => token_node_T_WHEN()
| ~T_WHERE() => token_node_T_WHERE()
| ~T_WHILE() => token_node_T_WHILE()
| ~T_WHILESTAR() => token_node_T_WHILESTAR()
| ~T_WITH() => token_node_T_WITH()
| ~T_WITHTYPE(a0) => token_node_T_WITHTYPE(a0)
| ~T_ADDRAT() => token_node_T_ADDRAT()
| ~T_FOLDAT() => token_node_T_FOLDAT()
| ~T_FREEAT() => token_node_T_FREEAT()
| ~T_VIEWAT() => token_node_T_VIEWAT()
| ~T_DLRDELAY(a0) => token_node_T_DLRDELAY(a0)
| ~T_DLRARRPSZ() => token_node_T_DLRARRPSZ()
| ~T_DLRTYREP() => token_node_T_DLRTYREP()
| ~T_DLRD2CTYPE() => token_node_T_DLRD2CTYPE()
| ~T_DLREFFMASK() => token_node_T_DLREFFMASK()
| ~T_DLREFFMASK_ARG(a0) => token_node_T_DLREFFMASK_ARG(a0)
| ~T_DLREXTERN() => token_node_T_DLREXTERN()
| ~T_DLREXTYPE() => token_node_T_DLREXTYPE()
| ~T_DLREXTKIND() => token_node_T_DLREXTKIND()
| ~T_DLREXTYPE_STRUCT() => token_node_T_DLREXTYPE_STRUCT()
| ~T_DLREXTVAL() => token_node_T_DLREXTVAL()
| ~T_DLREXTFCALL() => token_node_T_DLREXTFCALL()
| ~T_DLREXTMCALL() => token_node_T_DLREXTMCALL()
| ~T_DLRLITERAL() => token_node_T_DLRLITERAL()
| ~T_DLRMYFILENAME() => token_node_T_DLRMYFILENAME()
| ~T_DLRMYLOCATION() => token_node_T_DLRMYLOCATION()
| ~T_DLRMYFUNCTION() => token_node_T_DLRMYFUNCTION()
| ~T_DLRLST(a0) => token_node_T_DLRLST(a0)
| ~T_DLRREC(a0) => token_node_T_DLRREC(a0)
| ~T_DLRTUP(a0) => token_node_T_DLRTUP(a0)
| ~T_DLRBREAK() => token_node_T_DLRBREAK()
| ~T_DLRCONTINUE() => token_node_T_DLRCONTINUE()
| ~T_DLRRAISE() => token_node_T_DLRRAISE()
| ~T_DLRVARARG() => token_node_T_DLRVARARG()
| ~T_DLRVCOPYENV(a0) => token_node_T_DLRVCOPYENV(a0)
| ~T_DLRSHOWTYPE() => token_node_T_DLRSHOWTYPE()
| ~T_DLRTEMPENVER() => token_node_T_DLRTEMPENVER()
| ~T_DLRSOLASSERT() => token_node_T_DLRSOLASSERT()
| ~T_DLRSOLVERIFY() => token_node_T_DLRSOLVERIFY()
| ~T_SRPIF() => token_node_T_SRPIF()
| ~T_SRPIFDEF() => token_node_T_SRPIFDEF()
| ~T_SRPIFNDEF() => token_node_T_SRPIFNDEF()
| ~T_SRPTHEN() => token_node_T_SRPTHEN()
| ~T_SRPELIF() => token_node_T_SRPELIF()
| ~T_SRPELIFDEF() => token_node_T_SRPELIFDEF()
| ~T_SRPELIFNDEF() => token_node_T_SRPELIFNDEF()
| ~T_SRPELSE() => token_node_T_SRPELSE()
| ~T_SRPENDIF() => token_node_T_SRPENDIF()
| ~T_SRPERROR() => token_node_T_SRPERROR()
| ~T_SRPPRERR() => token_node_T_SRPPRERR()
| ~T_SRPPRINT() => token_node_T_SRPPRINT()
| ~T_SRPASSERT() => token_node_T_SRPASSERT()
| ~T_SRPUNDEF() => token_node_T_SRPUNDEF()
| ~T_SRPDEFINE() => token_node_T_SRPDEFINE()
| ~T_SRPINCLUDE() => token_node_T_SRPINCLUDE()
| ~T_SRPSTALOAD() => token_node_T_SRPSTALOAD()
| ~T_SRPDYNLOAD() => token_node_T_SRPDYNLOAD()
| ~T_SRPREQUIRE() => token_node_T_SRPREQUIRE()
| ~T_SRPPRAGMA() => token_node_T_SRPPRAGMA()
| ~T_SRPCODEGEN2() => token_node_T_SRPCODEGEN2()
| ~T_SRPCODEGEN3() => token_node_T_SRPCODEGEN3()
| ~T_IDENT_alp(a0) => token_node_T_IDENT_alp(a0)
| ~T_IDENT_sym(a0) => token_node_T_IDENT_sym(a0)
| ~T_IDENT_arr(a0) => token_node_T_IDENT_arr(a0)
| ~T_IDENT_tmp(a0) => token_node_T_IDENT_tmp(a0)
| ~T_IDENT_dlr(a0) => token_node_T_IDENT_dlr(a0)
| ~T_IDENT_srp(a0) => token_node_T_IDENT_srp(a0)
| ~T_IDENT_ext(a0) => token_node_T_IDENT_ext(a0)
| ~T_INT(a0, a1, a2) => token_node_T_INT(a0, a1, a2)
| ~T_CHAR(a0) => token_node_T_CHAR(a0)
| ~T_FLOAT(a0, a1, a2) => token_node_T_FLOAT(a0, a1, a2)
| ~T_CDATA(a0, a1) => token_node_T_CDATA(a0, a1)
| ~T_STRING(a0) => token_node_T_STRING(a0)
| ~T_COMMA() => token_node_T_COMMA()
| ~T_SEMICOLON() => token_node_T_SEMICOLON()
| ~T_LPAREN() => token_node_T_LPAREN()
| ~T_RPAREN() => token_node_T_RPAREN()
| ~T_LBRACKET() => token_node_T_LBRACKET()
| ~T_RBRACKET() => token_node_T_RBRACKET()
| ~T_LBRACE() => token_node_T_LBRACE()
| ~T_RBRACE() => token_node_T_RBRACE()
| ~T_ATLPAREN() => token_node_T_ATLPAREN()
| ~T_QUOTELPAREN() => token_node_T_QUOTELPAREN()
| ~T_ATLBRACKET() => token_node_T_ATLBRACKET()
| ~T_QUOTELBRACKET() => token_node_T_QUOTELBRACKET()
| ~T_HASHLBRACKET() => token_node_T_HASHLBRACKET()
| ~T_ATLBRACE() => token_node_T_ATLBRACE()
| ~T_QUOTELBRACE() => token_node_T_QUOTELBRACE()
| ~T_BQUOTELPAREN() => token_node_T_BQUOTELPAREN()
| ~T_COMMALPAREN() => token_node_T_COMMALPAREN()
| ~T_PERCENTLPAREN() => token_node_T_PERCENTLPAREN()
| ~T_EXTCODE(a0, a1) => token_node_T_EXTCODE(a0, a1)
| ~T_COMMENT_line() => token_node_T_COMMENT_line()
| ~T_COMMENT_rest() => token_node_T_COMMENT_rest()
| ~T_COMMENT_block() => token_node_T_COMMENT_block()
| ~T_ERR() => token_node_T_ERR()
| ~T_EOF() => token_node_T_EOF()
) (* end of [token_node_encode] *)

implement
token_node_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
token_node_is_T_NONE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
token_node_is_T_AT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
token_node_is_T_BAR
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 2)

implement
token_node_is_T_BANG
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 3)

implement
token_node_is_T_BQUOTE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 4)

implement
token_node_is_T_BACKSLASH
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 5)

implement
token_node_is_T_COLON
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 6)

implement
token_node_is_T_COLONLT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 7)

implement
token_node_is_T_DOLLAR
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 8)

implement
token_node_is_T_DOT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 9)

implement
token_node_is_T_DOTDOT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 10)

implement
token_node_is_T_DOTDOTDOT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 11)

implement
token_node_is_T_DOTINT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 12)

implement
token_node_is_T_EQ
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 13)

implement
token_node_is_T_EQGT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 14)

implement
token_node_is_T_EQLT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 15)

implement
token_node_is_T_EQLTGT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 16)

implement
token_node_is_T_EQSLASHEQGT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 17)

implement
token_node_is_T_EQGTGT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 18)

implement
token_node_is_T_EQSLASHEQGTGT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 19)

implement
token_node_is_T_HASH
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 20)

implement
token_node_is_T_LT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 21)

implement
token_node_is_T_GT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 22)

implement
token_node_is_T_GTLT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 23)

implement
token_node_is_T_DOTLT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 24)

implement
token_node_is_T_GTDOT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 25)

implement
token_node_is_T_DOTLTGTDOT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 26)

implement
token_node_is_T_MINUSGT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 27)

implement
token_node_is_T_MINUSLT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 28)

implement
token_node_is_T_MINUSLTGT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 29)

implement
token_node_is_T_TILDE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 30)

implement
token_node_is_T_ABSTYPE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 31)

implement
token_node_is_T_ASSUME
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 32)

implement
token_node_is_T_REASSUME
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 33)

implement
token_node_is_T_AS
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 34)

implement
token_node_is_T_AND
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 35)

implement
token_node_is_T_BEGIN
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 36)

implement
token_node_is_T_CASE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 37)

implement
token_node_is_T_CLASSDEC
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 38)

implement
token_node_is_T_DATASORT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 39)

implement
token_node_is_T_DATATYPE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 40)

implement
token_node_is_T_DO
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 41)

implement
token_node_is_T_ELSE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 42)

implement
token_node_is_T_END
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 43)

implement
token_node_is_T_EXCEPTION
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 44)

implement
token_node_is_T_EXTERN
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 45)

implement
token_node_is_T_EXTYPE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 46)

implement
token_node_is_T_EXTVAR
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 47)

implement
token_node_is_T_FIX
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 48)

implement
token_node_is_T_FIXITY
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 49)

implement
token_node_is_T_FOR
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 50)

implement
token_node_is_T_FORSTAR
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 51)

implement
token_node_is_T_FUN
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 52)

implement
token_node_is_T_IF
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 53)

implement
token_node_is_T_IFCASE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 54)

implement
token_node_is_T_IMPLEMENT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 55)

implement
token_node_is_T_IMPORT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 56)

implement
token_node_is_T_IN
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 57)

implement
token_node_is_T_LAM
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 58)

implement
token_node_is_T_LET
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 59)

implement
token_node_is_T_LOCAL
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 60)

implement
token_node_is_T_MACDEF
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 61)

implement
token_node_is_T_NONFIX
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 62)

implement
token_node_is_T_OF
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 63)

implement
token_node_is_T_OP
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 64)

implement
token_node_is_T_REC
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 65)

implement
token_node_is_T_SIF
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 66)

implement
token_node_is_T_SCASE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 67)

implement
token_node_is_T_STACST
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 68)

implement
token_node_is_T_STADEF
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 69)

implement
token_node_is_T_STATIC
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 70)

implement
token_node_is_T_SORTDEF
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 71)

implement
token_node_is_T_SYMELIM
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 72)

implement
token_node_is_T_SYMINTR
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 73)

implement
token_node_is_T_SYMLOAD
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 74)

implement
token_node_is_T_THEN
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 75)

implement
token_node_is_T_TKINDEF
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 76)

implement
token_node_is_T_TRY
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 77)

implement
token_node_is_T_TYPE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 78)

implement
token_node_is_T_TYPEDEF
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 79)

implement
token_node_is_T_VAL
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 80)

implement
token_node_is_T_VAR
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 81)

implement
token_node_is_T_WHEN
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 82)

implement
token_node_is_T_WHERE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 83)

implement
token_node_is_T_WHILE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 84)

implement
token_node_is_T_WHILESTAR
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 85)

implement
token_node_is_T_WITH
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 86)

implement
token_node_is_T_WITHTYPE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 87)

implement
token_node_is_T_ADDRAT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 88)

implement
token_node_is_T_FOLDAT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 89)

implement
token_node_is_T_FREEAT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 90)

implement
token_node_is_T_VIEWAT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 91)

implement
token_node_is_T_DLRDELAY
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 92)

implement
token_node_is_T_DLRARRPSZ
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 93)

implement
token_node_is_T_DLRTYREP
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 94)

implement
token_node_is_T_DLRD2CTYPE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 95)

implement
token_node_is_T_DLREFFMASK
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 96)

implement
token_node_is_T_DLREFFMASK_ARG
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 97)

implement
token_node_is_T_DLREXTERN
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 98)

implement
token_node_is_T_DLREXTYPE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 99)

implement
token_node_is_T_DLREXTKIND
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 100)

implement
token_node_is_T_DLREXTYPE_STRUCT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 101)

implement
token_node_is_T_DLREXTVAL
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 102)

implement
token_node_is_T_DLREXTFCALL
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 103)

implement
token_node_is_T_DLREXTMCALL
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 104)

implement
token_node_is_T_DLRLITERAL
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 105)

implement
token_node_is_T_DLRMYFILENAME
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 106)

implement
token_node_is_T_DLRMYLOCATION
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 107)

implement
token_node_is_T_DLRMYFUNCTION
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 108)

implement
token_node_is_T_DLRLST
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 109)

implement
token_node_is_T_DLRREC
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 110)

implement
token_node_is_T_DLRTUP
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 111)

implement
token_node_is_T_DLRBREAK
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 112)

implement
token_node_is_T_DLRCONTINUE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 113)

implement
token_node_is_T_DLRRAISE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 114)

implement
token_node_is_T_DLRVARARG
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 115)

implement
token_node_is_T_DLRVCOPYENV
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 116)

implement
token_node_is_T_DLRSHOWTYPE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 117)

implement
token_node_is_T_DLRTEMPENVER
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 118)

implement
token_node_is_T_DLRSOLASSERT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 119)

implement
token_node_is_T_DLRSOLVERIFY
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 120)

implement
token_node_is_T_SRPIF
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 121)

implement
token_node_is_T_SRPIFDEF
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 122)

implement
token_node_is_T_SRPIFNDEF
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 123)

implement
token_node_is_T_SRPTHEN
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 124)

implement
token_node_is_T_SRPELIF
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 125)

implement
token_node_is_T_SRPELIFDEF
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 126)

implement
token_node_is_T_SRPELIFNDEF
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 127)

implement
token_node_is_T_SRPELSE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 128)

implement
token_node_is_T_SRPENDIF
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 129)

implement
token_node_is_T_SRPERROR
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 130)

implement
token_node_is_T_SRPPRERR
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 131)

implement
token_node_is_T_SRPPRINT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 132)

implement
token_node_is_T_SRPASSERT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 133)

implement
token_node_is_T_SRPUNDEF
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 134)

implement
token_node_is_T_SRPDEFINE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 135)

implement
token_node_is_T_SRPINCLUDE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 136)

implement
token_node_is_T_SRPSTALOAD
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 137)

implement
token_node_is_T_SRPDYNLOAD
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 138)

implement
token_node_is_T_SRPREQUIRE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 139)

implement
token_node_is_T_SRPPRAGMA
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 140)

implement
token_node_is_T_SRPCODEGEN2
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 141)

implement
token_node_is_T_SRPCODEGEN3
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 142)

implement
token_node_is_T_IDENT_alp
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 143)

implement
token_node_is_T_IDENT_sym
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 144)

implement
token_node_is_T_IDENT_arr
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 145)

implement
token_node_is_T_IDENT_tmp
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 146)

implement
token_node_is_T_IDENT_dlr
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 147)

implement
token_node_is_T_IDENT_srp
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 148)

implement
token_node_is_T_IDENT_ext
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 149)

implement
token_node_is_T_INT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 150)

implement
token_node_is_T_CHAR
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 151)

implement
token_node_is_T_FLOAT
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 152)

implement
token_node_is_T_CDATA
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 153)

implement
token_node_is_T_STRING
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 154)

implement
token_node_is_T_COMMA
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 155)

implement
token_node_is_T_SEMICOLON
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 156)

implement
token_node_is_T_LPAREN
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 157)

implement
token_node_is_T_RPAREN
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 158)

implement
token_node_is_T_LBRACKET
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 159)

implement
token_node_is_T_RBRACKET
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 160)

implement
token_node_is_T_LBRACE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 161)

implement
token_node_is_T_RBRACE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 162)

implement
token_node_is_T_ATLPAREN
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 163)

implement
token_node_is_T_QUOTELPAREN
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 164)

implement
token_node_is_T_ATLBRACKET
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 165)

implement
token_node_is_T_QUOTELBRACKET
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 166)

implement
token_node_is_T_HASHLBRACKET
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 167)

implement
token_node_is_T_ATLBRACE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 168)

implement
token_node_is_T_QUOTELBRACE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 169)

implement
token_node_is_T_BQUOTELPAREN
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 170)

implement
token_node_is_T_COMMALPAREN
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 171)

implement
token_node_is_T_PERCENTLPAREN
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 172)

implement
token_node_is_T_EXTCODE
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 173)

implement
token_node_is_T_COMMENT_line
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 174)

implement
token_node_is_T_COMMENT_rest
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 175)

implement
token_node_is_T_COMMENT_block
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 176)

implement
token_node_is_T_ERR
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 177)

implement
token_node_is_T_EOF
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 178)

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
| 0 => T_NONE()
| 1 => T_AT()
| 2 => T_BAR()
| 3 => T_BANG()
| 4 => T_BQUOTE()
| 5 => T_BACKSLASH()
| 6 => T_COLON()
| 7 => T_COLONLT()
| 8 => T_DOLLAR()
| 9 => T_DOT()
| 10 => T_DOTDOT()
| 11 => T_DOTDOTDOT()
| 12 => T_DOTINT(arena_load<int>(ptr_add<byte>(p, 8)))
| 13 => T_EQ()
| 14 => T_EQGT()
| 15 => T_EQLT()
| 16 => T_EQLTGT()
| 17 => T_EQSLASHEQGT()
| 18 => T_EQGTGT()
| 19 => T_EQSLASHEQGTGT()
| 20 => T_HASH()
| 21 => T_LT()
| 22 => T_GT()
| 23 => T_GTLT()
| 24 => T_DOTLT()
| 25 => T_GTDOT()
| 26 => T_DOTLTGTDOT()
| 27 => T_MINUSGT()
| 28 => T_MINUSLT()
| 29 => T_MINUSLTGT()
| 30 => T_TILDE()
| 31 => T_ABSTYPE(arena_load<int>(ptr_add<byte>(p, 8)))
| 32 => T_ASSUME()
| 33 => T_REASSUME()
| 34 => T_AS()
| 35 => T_AND()
| 36 => T_BEGIN()
| 37 => T_CASE(arena_load<caskind>(ptr_add<byte>(p, 8)))
| 38 => T_CLASSDEC()
| 39 => T_DATASORT()
| 40 => T_DATATYPE(arena_load<int>(ptr_add<byte>(p, 8)))
| 41 => T_DO()
| 42 => T_ELSE()
| 43 => T_END()
| 44 => T_EXCEPTION()
| 45 => T_EXTERN()
| 46 => T_EXTYPE()
| 47 => T_EXTVAR()
| 48 => T_FIX(arena_load<int>(ptr_add<byte>(p, 8)))
| 49 => T_FIXITY(arena_load<fxtykind>(ptr_add<byte>(p, 8)))
| 50 => T_FOR()
| 51 => T_FORSTAR()
| 52 => T_FUN(arena_load<funkind>(ptr_add<byte>(p, 8)))
| 53 => T_IF()
| 54 => T_IFCASE()
| 55 => T_IMPLEMENT(arena_load<int>(ptr_add<byte>(p, 8)))
| 56 => T_IMPORT()
| 57 => T_IN()
| 58 => T_LAM(arena_load<int>(ptr_add<byte>(p, 8)))
| 59 => T_LET()
| 60 => T_LOCAL()
| 61 => T_MACDEF(arena_load<int>(ptr_add<byte>(p, 8)))
| 62 => T_NONFIX()
| 63 => T_OF()
| 64 => T_OP()
| 65 => T_REC()
| 66 => T_SIF()
| 67 => T_SCASE()
| 68 => T_STACST()
| 69 => T_STADEF()
| 70 => T_STATIC()
| 71 => T_SORTDEF()
| 72 => T_SYMELIM()
| 73 => T_SYMINTR()
| 74 => T_SYMLOAD()
| 75 => T_THEN()
| 76 => T_TKINDEF()
| 77 => T_TRY()
| 78 => T_TYPE(arena_load<int>(ptr_add<byte>(p, 8)))
| 79 => T_TYPEDEF(arena_load<int>(ptr_add<byte>(p, 8)))
| 80 => T_VAL(arena_load<valkind>(ptr_add<byte>(p, 8)))
| 81 => T_VAR(arena_load<int>(ptr_add<byte>(p, 8)))
| 82 => T_WHEN()
| 83 => T_WHERE()
| 84 => T_WHILE()
| 85 => T_WHILESTAR()
| 86 => T_WITH()
| 87 => T_WITHTYPE(arena_load<int>(ptr_add<byte>(p, 8)))
| 88 => T_ADDRAT()
| 89 => T_FOLDAT()
| 90 => T_FREEAT()
| 91 => T_VIEWAT()
| 92 => T_DLRDELAY(arena_load<int>(ptr_add<byte>(p, 8)))
| 93 => T_DLRARRPSZ()
| 94 => T_DLRTYREP()
| 95 => T_DLRD2CTYPE()
| 96 => T_DLREFFMASK()
| 97 => T_DLREFFMASK_ARG(arena_load<int>(ptr_add<byte>(p, 8)))
| 98 => T_DLREXTERN()
| 99 => T_DLREXTYPE()
| 100 => T_DLREXTKIND()
| 101 => T_DLREXTYPE_STRUCT()
| 102 => T_DLREXTVAL()
| 103 => T_DLREXTFCALL()
| 104 => T_DLREXTMCALL()
| 105 => T_DLRLITERAL()
| 106 => T_DLRMYFILENAME()
| 107 => T_DLRMYLOCATION()
| 108 => T_DLRMYFUNCTION()
| 109 => T_DLRLST(arena_load<int>(ptr_add<byte>(p, 8)))
| 110 => T_DLRREC(arena_load<int>(ptr_add<byte>(p, 8)))
| 111 => T_DLRTUP(arena_load<int>(ptr_add<byte>(p, 8)))
| 112 => T_DLRBREAK()
| 113 => T_DLRCONTINUE()
| 114 => T_DLRRAISE()
| 115 => T_DLRVARARG()
| 116 => T_DLRVCOPYENV(arena_load<int>(ptr_add<byte>(p, 8)))
| 117 => T_DLRSHOWTYPE()
| 118 => T_DLRTEMPENVER()
| 119 => T_DLRSOLASSERT()
| 120 => T_DLRSOLVERIFY()
| 121 => T_SRPIF()
| 122 => T_SRPIFDEF()
| 123 => T_SRPIFNDEF()
| 124 => T_SRPTHEN()
| 125 => T_SRPELIF()
| 126 => T_SRPELIFDEF()
| 127 => T_SRPELIFNDEF()
| 128 => T_SRPELSE()
| 129 => T_SRPENDIF()
| 130 => T_SRPERROR()
| 131 => T_SRPPRERR()
| 132 => T_SRPPRINT()
| 133 => T_SRPASSERT()
| 134 => T_SRPUNDEF()
| 135 => T_SRPDEFINE()
| 136 => T_SRPINCLUDE()
| 137 => T_SRPSTALOAD()
| 138 => T_SRPDYNLOAD()
| 139 => T_SRPREQUIRE()
| 140 => T_SRPPRAGMA()
| 141 => T_SRPCODEGEN2()
| 142 => T_SRPCODEGEN3()
| 143 => T_IDENT_alp(arena_load<string>(ptr_add<byte>(p, 8)))
| 144 => T_IDENT_sym(arena_load<string>(ptr_add<byte>(p, 8)))
| 145 => T_IDENT_arr(arena_load<string>(ptr_add<byte>(p, 8)))
| 146 => T_IDENT_tmp(arena_load<string>(ptr_add<byte>(p, 8)))
| 147 => T_IDENT_dlr(arena_load<string>(ptr_add<byte>(p, 8)))
| 148 => T_IDENT_srp(arena_load<string>(ptr_add<byte>(p, 8)))
| 149 => T_IDENT_ext(arena_load<string>(ptr_add<byte>(p, 8)))
| 150 => T_INT(arena_load<int>(ptr_add<byte>(p, 8)), arena_load<string>(ptr_add<byte>(p, 16)), arena_load<uint>(ptr_add<byte>(p, 24)))
| 151 => T_CHAR(arena_load<char>(ptr_add<byte>(p, 8)))
| 152 => T_FLOAT(arena_load<int>(ptr_add<byte>(p, 8)), arena_load<string>(ptr_add<byte>(p, 16)), arena_load<uint>(ptr_add<byte>(p, 24)))
| 153 => T_CDATA(arena_load<ptr>(ptr_add<byte>(p, 8)), arena_load<size_t>(ptr_add<byte>(p, 16)))
| 154 => T_STRING(arena_load<string>(ptr_add<byte>(p, 8)))
| 155 => T_COMMA()
| 156 => T_SEMICOLON()
| 157 => T_LPAREN()
| 158 => T_RPAREN()
| 159 => T_LBRACKET()
| 160 => T_RBRACKET()
| 161 => T_LBRACE()
| 162 => T_RBRACE()
| 163 => T_ATLPAREN()
| 164 => T_QUOTELPAREN()
| 165 => T_ATLBRACKET()
| 166 => T_QUOTELBRACKET()
| 167 => T_HASHLBRACKET()
| 168 => T_ATLBRACE()
| 169 => T_QUOTELBRACE()
| 170 => T_BQUOTELPAREN()
| 171 => T_COMMALPAREN()
| 172 => T_PERCENTLPAREN()
| 173 => T_EXTCODE(arena_load<int>(ptr_add<byte>(p, 8)), arena_load<string>(ptr_add<byte>(p, 16)))
| 174 => T_COMMENT_line()
| 175 => T_COMMENT_rest()
| 176 => T_COMMENT_block()
| 177 => T_ERR()
| _ => T_EOF()
//
end // end of [token_node_view]

implement
token_node_view_free
  (v) =
(
case+ v of
| ~T_NONE() => ()
| ~T_AT() => ()
| ~T_BAR() => ()
| ~T_BANG() => ()
| ~T_BQUOTE() => ()
| ~T_BACKSLASH() => ()
| ~T_COLON() => ()
| ~T_COLONLT() => ()
| ~T_DOLLAR() => ()
| ~T_DOT() => ()
| ~T_DOTDOT() => ()
| ~T_DOTDOTDOT() => ()
| ~T_DOTINT(_) => ()
| ~T_EQ() => ()
| ~T_EQGT() => ()
| ~T_EQLT() => ()
| ~T_EQLTGT() => ()
| ~T_EQSLASHEQGT() => ()
| ~T_EQGTGT() => ()
| ~T_EQSLASHEQGTGT() => ()
| ~T_HASH() => ()
| ~T_LT() => ()
| ~T_GT() => ()
| ~T_GTLT() => ()
| ~T_DOTLT() => ()
| ~T_GTDOT() => ()
| ~T_DOTLTGTDOT() => ()
| ~T_MINUSGT() => ()
| ~T_MINUSLT() => ()
| ~T_MINUSLTGT() => ()
| ~T_TILDE() => ()
| ~T_ABSTYPE(_) => ()
| ~T_ASSUME() => ()
| ~T_REASSUME() => ()
| ~T_AS() => ()
| ~T_AND() => ()
| ~T_BEGIN() => ()
| ~T_CASE(_) => ()
| ~T_CLASSDEC() => ()
| ~T_DATASORT() => ()
| ~T_DATATYPE(_) => ()
| ~T_DO() => ()
| ~T_ELSE() => ()
| ~T_END() => ()
| ~T_EXCEPTION() => ()
| ~T_EXTERN() => ()
| ~T_EXTYPE() => ()
| ~T_EXTVAR() => ()
| ~T_FIX(_) => ()
| ~T_FIXITY(_) => ()
| ~T_FOR() => ()
| ~T_FORSTAR() => ()
| ~T_FUN(_) => ()
| ~T_IF() => ()
| ~T_IFCASE() => ()
| ~T_IMPLEMENT(_) => ()
| ~T_IMPORT() => ()
| ~T_IN() => ()
| ~T_LAM(_) => ()
| ~T_LET() => ()
| ~T_LOCAL() => ()
| ~T_MACDEF(_) => ()
| ~T_NONFIX() => ()
| ~T_OF() => ()
| ~T_OP() => ()
| ~T_REC() => ()
| ~T_SIF() => ()
| ~T_SCASE() => ()
| ~T_STACST() => ()
| ~T_STADEF() => ()
| ~T_STATIC() => ()
| ~T_SORTDEF() => ()
| ~T_SYMELIM() => ()
| ~T_SYMINTR() => ()
| ~T_SYMLOAD() => ()
| ~T_THEN() => ()
| ~T_TKINDEF() => ()
| ~T_TRY() => ()
| ~T_TYPE(_) => ()
| ~T_TYPEDEF(_) => ()
| ~T_VAL(_) => ()
| ~T_VAR(_) => ()
| ~T_WHEN() => ()
| ~T_WHERE() => ()
| ~T_WHILE() => ()
| ~T_WHILESTAR() => ()
| ~T_WITH() => ()
| ~T_WITHTYPE(_) => ()
| ~T_ADDRAT() => ()
| ~T_FOLDAT() => ()
| ~T_FREEAT() => ()
| ~T_VIEWAT() => ()
| ~T_DLRDELAY(_) => ()
| ~T_DLRARRPSZ() => ()
| ~T_DLRTYREP() => ()
| ~T_DLRD2CTYPE() => ()
| ~T_DLREFFMASK() => ()
| ~T_DLREFFMASK_ARG(_) => ()
| ~T_DLREXTERN() => ()
| ~T_DLREXTYPE() => ()
| ~T_DLREXTKIND() => ()
| ~T_DLREXTYPE_STRUCT() => ()
| ~T_DLREXTVAL() => ()
| ~T_DLREXTFCALL() => ()
| ~T_DLREXTMCALL() => ()
| ~T_DLRLITERAL() => ()
| ~T_DLRMYFILENAME() => ()
| ~T_DLRMYLOCATION() => ()
| ~T_DLRMYFUNCTION() => ()
| ~T_DLRLST(_) => ()
| ~T_DLRREC(_) => ()
| ~T_DLRTUP(_) => ()
| ~T_DLRBREAK() => ()
| ~T_DLRCONTINUE() => ()
| ~T_DLRRAISE() => ()
| ~T_DLRVARARG() => ()
| ~T_DLRVCOPYENV(_) => ()
| ~T_DLRSHOWTYPE() => ()
| ~T_DLRTEMPENVER() => ()
| ~T_DLRSOLASSERT() => ()
| ~T_DLRSOLVERIFY() => ()
| ~T_SRPIF() => ()
| ~T_SRPIFDEF() => ()
| ~T_SRPIFNDEF() => ()
| ~T_SRPTHEN() => ()
| ~T_SRPELIF() => ()
| ~T_SRPELIFDEF() => ()
| ~T_SRPELIFNDEF() => ()
| ~T_SRPELSE() => ()
| ~T_SRPENDIF() => ()
| ~T_SRPERROR() => ()
| ~T_SRPPRERR() => ()
| ~T_SRPPRINT() => ()
| ~T_SRPASSERT() => ()
| ~T_SRPUNDEF() => ()
| ~T_SRPDEFINE() => ()
| ~T_SRPINCLUDE() => ()
| ~T_SRPSTALOAD() => ()
| ~T_SRPDYNLOAD() => ()
| ~T_SRPREQUIRE() => ()
| ~T_SRPPRAGMA() => ()
| ~T_SRPCODEGEN2() => ()
| ~T_SRPCODEGEN3() => ()
| ~T_IDENT_alp(_) => ()
| ~T_IDENT_sym(_) => ()
| ~T_IDENT_arr(_) => ()
| ~T_IDENT_tmp(_) => ()
| ~T_IDENT_dlr(_) => ()
| ~T_IDENT_srp(_) => ()
| ~T_IDENT_ext(_) => ()
| ~T_INT(_, _, _) => ()
| ~T_CHAR(_) => ()
| ~T_FLOAT(_, _, _) => ()
| ~T_CDATA(_, _) => ()
| ~T_STRING(_) => ()
| ~T_COMMA() => ()
| ~T_SEMICOLON() => ()
| ~T_LPAREN() => ()
| ~T_RPAREN() => ()
| ~T_LBRACKET() => ()
| ~T_RBRACKET() => ()
| ~T_LBRACE() => ()
| ~T_RBRACE() => ()
| ~T_ATLPAREN() => ()
| ~T_QUOTELPAREN() => ()
| ~T_ATLBRACKET() => ()
| ~T_QUOTELBRACKET() => ()
| ~T_HASHLBRACKET() => ()
| ~T_ATLBRACE() => ()
| ~T_QUOTELBRACE() => ()
| ~T_BQUOTELPAREN() => ()
| ~T_COMMALPAREN() => ()
| ~T_PERCENTLPAREN() => ()
| ~T_EXTCODE(_, _) => ()
| ~T_COMMENT_line() => ()
| ~T_COMMENT_rest() => ()
| ~T_COMMENT_block() => ()
| ~T_ERR() => ()
| ~T_EOF() => ()
) (* end of [token_node_view_free] *)

(* ****** ****** *)

implement
token_TOKEN
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<location>(ptr_add<byte>(p, 8), a0)
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
| _ => TOKEN(arena_load<location>(ptr_add<byte>(p, 8)), arena_load<token_node>(ptr_add<byte>(p, 16)))
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
  arena_load<location>(ptr_add<byte>($UN.cast{ptr}(x), 8))

implement
token_get_token_node
  (x) =
  arena_load<token_node>(ptr_add<byte>($UN.cast{ptr}(x), 16))

(* ****** ****** *)

implement
lexerr_node_LE_CHAR_oct
  () = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 0)
in
  $UN.cast{lexerr_node}(p)
end // end of [lexerr_node_LE_CHAR_oct]

implement
lexerr_node_LE_CHAR_hex
  () = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 1)
in
  $UN.cast{lexerr_node}(p)
end // end of [lexerr_node_LE_CHAR_hex]

implement
lexerr_node_LE_CHAR_unclose
  () = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 2)
in
  $UN.cast{lexerr_node}(p)
end // end of [lexerr_node_LE_CHAR_unclose]

implement
lexerr_node_LE_QUOTE_dangling
  () = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 3)
in
  $UN.cast{lexerr_node}(p)
end // end of [lexerr_node_LE_QUOTE_dangling]

implement
lexerr_node_LE_STRING_unclose
  () = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 4)
in
  $UN.cast{lexerr_node}(p)
end // end of [lexerr_node_LE_STRING_unclose]

implement
lexerr_node_LE_STRING_char_oct
  () = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 5)
in
  $UN.cast{lexerr_node}(p)
end // end of [lexerr_node_LE_STRING_char_oct]

implement
lexerr_node_LE_STRING_char_hex
  () = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 6)
in
  $UN.cast{lexerr_node}(p)
end // end of [lexerr_node_LE_STRING_char_hex]

implement
lexerr_node_LE_COMMENT_block_unclose
  () = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 7)
in
  $UN.cast{lexerr_node}(p)
end // end of [lexerr_node_LE_COMMENT_block_unclose]

implement
lexerr_node_LE_EXTCODE_unclose
  () = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 8)
in
  $UN.cast{lexerr_node}(p)
end // end of [lexerr_node_LE_EXTCODE_unclose]

implement
lexerr_node_LE_DIGIT_oct_89
  (a0) = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 9)
val () = arena_store<char>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{lexerr_node}(p)
end // end of [lexerr_node_LE_DIGIT_oct_89]

implement
lexerr_node_LE_IDIGITS_empty
  () = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 10)
in
  $UN.cast{lexerr_node}(p)
end // end of [lexerr_node_LE_IDIGITS_empty]

implement
lexerr_node_LE_FEXPONENT_empty
  () = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 11)
in
  $UN.cast{lexerr_node}(p)
end // end of [lexerr_node_LE_FEXPONENT_empty]

implement
lexerr_node_LE_FEXPONENT_missing
  () = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 12)
in
  $UN.cast{lexerr_node}(p)
end // end of [lexerr_node_LE_FEXPONENT_missing]

implement
lexerr_node_LE_FINTFRAC_missing
  () = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 13)
in
  $UN.cast{lexerr_node}(p)
end // end of [lexerr_node_LE_FINTFRAC_missing]

implement
lexerr_node_LE_UNSUPPORTED_char
  (a0) = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 14)
val () = arena_store<char>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{lexerr_node}(p)
end // end of [lexerr_node_LE_UNSUPPORTED_char]

implement
lexerr_node_encode
  (v) =
(
case+ v of
| ~LE_CHAR_oct() => lexerr_node_LE_CHAR_oct()
| ~LE_CHAR_hex() => lexerr_node_LE_CHAR_hex()
| ~LE_CHAR_unclose() => lexerr_node_LE_CHAR_unclose()
| ~LE_QUOTE_dangling() => lexerr_node_LE_QUOTE_dangling()
| ~LE_STRING_unclose() => lexerr_node_LE_STRING_unclose()
| ~LE_STRING_char_oct() => lexerr_node_LE_STRING_char_oct()
| ~LE_STRING_char_hex() => lexerr_node_LE_STRING_char_hex()
| ~LE_COMMENT_block_unclose() => lexerr_node_LE_COMMENT_block_unclose()
| ~LE_EXTCODE_unclose() => lexerr_node_LE_EXTCODE_unclose()
| ~LE_DIGIT_oct_89(a0) => lexerr_node_LE_DIGIT_oct_89(a0)
| ~LE_IDIGITS_empty() => lexerr_node_LE_IDIGITS_empty()
| ~LE_FEXPONENT_empty() => lexerr_node_LE_FEXPONENT_empty()
| ~LE_FEXPONENT_missing() => lexerr_node_LE_FEXPONENT_missing()
| ~LE_FINTFRAC_missing() => lexerr_node_LE_FINTFRAC_missing()
| ~LE_UNSUPPORTED_char(a0) => lexerr_node_LE_UNSUPPORTED_char(a0)
) (* end of [lexerr_node_encode] *)

implement
lexerr_node_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
lexerr_node_is_LE_CHAR_oct
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
lexerr_node_is_LE_CHAR_hex
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
lexerr_node_is_LE_CHAR_unclose
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 2)

implement
lexerr_node_is_LE_QUOTE_dangling
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 3)

implement
lexerr_node_is_LE_STRING_unclose
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 4)

implement
lexerr_node_is_LE_STRING_char_oct
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 5)

implement
lexerr_node_is_LE_STRING_char_hex
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 6)

implement
lexerr_node_is_LE_COMMENT_block_unclose
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 7)

implement
lexerr_node_is_LE_EXTCODE_unclose
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 8)

implement
lexerr_node_is_LE_DIGIT_oct_89
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 9)

implement
lexerr_node_is_LE_IDIGITS_empty
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 10)

implement
lexerr_node_is_LE_FEXPONENT_empty
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 11)

implement
lexerr_node_is_LE_FEXPONENT_missing
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 12)

implement
lexerr_node_is_LE_FINTFRAC_missing
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 13)

implement
lexerr_node_is_LE_UNSUPPORTED_char
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 14)

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
| 0 => LE_CHAR_oct()
| 1 => LE_CHAR_hex()
| 2 => LE_CHAR_unclose()
| 3 => LE_QUOTE_dangling()
| 4 => LE_STRING_unclose()
| 5 => LE_STRING_char_oct()
| 6 => LE_STRING_char_hex()
| 7 => LE_COMMENT_block_unclose()
| 8 => LE_EXTCODE_unclose()
| 9 => LE_DIGIT_oct_89(arena_load<char>(ptr_add<byte>(p, 8)))
| 10 => LE_IDIGITS_empty()
| 11 => LE_FEXPONENT_empty()
| 12 => LE_FEXPONENT_missing()
| 13 => LE_FINTFRAC_missing()
| _ => LE_UNSUPPORTED_char(arena_load<char>(ptr_add<byte>(p, 8)))
//
end // end of [lexerr_node_view]

implement
lexerr_node_view_free
  (v) =
(
case+ v of
| ~LE_CHAR_oct() => ()
| ~LE_CHAR_hex() => ()
| ~LE_CHAR_unclose() => ()
| ~LE_QUOTE_dangling() => ()
| ~LE_STRING_unclose() => ()
| ~LE_STRING_char_oct() => ()
| ~LE_STRING_char_hex() => ()
| ~LE_COMMENT_block_unclose() => ()
| ~LE_EXTCODE_unclose() => ()
| ~LE_DIGIT_oct_89(_) => ()
| ~LE_IDIGITS_empty() => ()
| ~LE_FEXPONENT_empty() => ()
| ~LE_FEXPONENT_missing() => ()
| ~LE_FINTFRAC_missing() => ()
| ~LE_UNSUPPORTED_char(_) => ()
) (* end of [lexerr_node_view_free] *)

(* ****** ****** *)

implement
lexerr_LEXERR
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<location>(ptr_add<byte>(p, 8), a0)
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
| _ => LEXERR(arena_load<location>(ptr_add<byte>(p, 8)), arena_load<lexerr_node>(ptr_add<byte>(p, 16)))
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
  arena_load<location>(ptr_add<byte>($UN.cast{ptr}(x), 8))

implement
lexerr_get_lexerr_node
  (x) =
  arena_load<lexerr_node>(ptr_add<byte>($UN.cast{ptr}(x), 16))

(* ****** ****** *)
