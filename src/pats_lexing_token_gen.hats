abstype
token_node_type = ptr
typedef
token_node = token_node_type

abstype
token_type = ptr
typedef
token = token_type

abstype
lexerr_node_type = ptr
typedef
lexerr_node = lexerr_node_type

abstype
lexerr_type = ptr
typedef
lexerr = lexerr_type

//
datavtype
token_node_view =
  | T_NONE of ()
  | T_AT of ()
  | T_BAR of ()
  | T_BANG of ()
  | T_BQUOTE of ()
  | T_BACKSLASH of ()
  | T_COLON of ()
  | T_COLONLT of ()
  | T_DOLLAR of ()
  | T_DOT of ()
  | T_DOTDOT of ()
  | T_DOTDOTDOT of ()
  | T_DOTINT of (int)
  | T_EQ of ()
  | T_EQGT of ()
  | T_EQLT of ()
  | T_EQLTGT of ()
  | T_EQSLASHEQGT of ()
  | T_EQGTGT of ()
  | T_EQSLASHEQGTGT of ()
  | T_HASH of ()
  | T_LT of ()
  | T_GT of ()
  | T_GTLT of ()
  | T_DOTLT of ()
  | T_GTDOT of ()
  | T_DOTLTGTDOT of ()
  | T_MINUSGT of ()
  | T_MINUSLT of ()
  | T_MINUSLTGT of ()
  | T_TILDE of ()
  | T_ABSTYPE of (int)
  | T_ASSUME of ()
  | T_REASSUME of ()
  | T_AS of ()
  | T_AND of ()
  | T_BEGIN of ()
  | T_CASE of (caskind)
  | T_CLASSDEC of ()
  | T_DATASORT of ()
  | T_DATATYPE of (int)
  | T_DO of ()
  | T_ELSE of ()
  | T_END of ()
  | T_EXCEPTION of ()
  | T_EXTERN of ()
  | T_EXTYPE of ()
  | T_EXTVAR of ()
  | T_FIX of (int)
  | T_FIXITY of (fxtykind)
  | T_FOR of ()
  | T_FORSTAR of ()
  | T_FUN of (funkind)
  | T_IF of ()
  | T_IFCASE of ()
  | T_IMPLEMENT of (int)
  | T_IMPORT of ()
  | T_IN of ()
  | T_LAM of (int)
  | T_LET of ()
  | T_LOCAL of ()
  | T_MACDEF of (int)
  | T_NONFIX of ()
  | T_OF of ()
  | T_OP of ()
  | T_REC of ()
  | T_SIF of ()
  | T_SCASE of ()
  | T_STACST of ()
  | T_STADEF of ()
  | T_STATIC of ()
  | T_SORTDEF of ()
  | T_SYMELIM of ()
  | T_SYMINTR of ()
  | T_SYMLOAD of ()
  | T_THEN of ()
  | T_TKINDEF of ()
  | T_TRY of ()
  | T_TYPE of (int)
  | T_TYPEDEF of (int)
  | T_VAL of (valkind)
  | T_VAR of (int)
  | T_WHEN of ()
  | T_WHERE of ()
  | T_WHILE of ()
  | T_WHILESTAR of ()
  | T_WITH of ()
  | T_WITHTYPE of (int)
  | T_ADDRAT of ()
  | T_FOLDAT of ()
  | T_FREEAT of ()
  | T_VIEWAT of ()
  | T_DLRDELAY of (int)
  | T_DLRARRPSZ of ()
  | T_DLRTYREP of ()
  | T_DLRD2CTYPE of ()
  | T_DLREFFMASK of ()
  | T_DLREFFMASK_ARG of (int)
  | T_DLREXTERN of ()
  | T_DLREXTYPE of ()
  | T_DLREXTKIND of ()
  | T_DLREXTYPE_STRUCT of ()
  | T_DLREXTVAL of ()
  | T_DLREXTFCALL of ()
  | T_DLREXTMCALL of ()
  | T_DLRLITERAL of ()
  | T_DLRMYFILENAME of ()
  | T_DLRMYLOCATION of ()
  | T_DLRMYFUNCTION of ()
  | T_DLRLST of (int)
  | T_DLRREC of (int)
  | T_DLRTUP of (int)
  | T_DLRBREAK of ()
  | T_DLRCONTINUE of ()
  | T_DLRRAISE of ()
  | T_DLRVARARG of ()
  | T_DLRVCOPYENV of (int)
  | T_DLRSHOWTYPE of ()
  | T_DLRTEMPENVER of ()
  | T_DLRSOLASSERT of ()
  | T_DLRSOLVERIFY of ()
  | T_SRPIF of ()
  | T_SRPIFDEF of ()
  | T_SRPIFNDEF of ()
  | T_SRPTHEN of ()
  | T_SRPELIF of ()
  | T_SRPELIFDEF of ()
  | T_SRPELIFNDEF of ()
  | T_SRPELSE of ()
  | T_SRPENDIF of ()
  | T_SRPERROR of ()
  | T_SRPPRERR of ()
  | T_SRPPRINT of ()
  | T_SRPASSERT of ()
  | T_SRPUNDEF of ()
  | T_SRPDEFINE of ()
  | T_SRPINCLUDE of ()
  | T_SRPSTALOAD of ()
  | T_SRPDYNLOAD of ()
  | T_SRPREQUIRE of ()
  | T_SRPPRAGMA of ()
  | T_SRPCODEGEN2 of ()
  | T_SRPCODEGEN3 of ()
  | T_IDENT_alp of (string)
  | T_IDENT_sym of (string)
  | T_IDENT_arr of (string)
  | T_IDENT_tmp of (string)
  | T_IDENT_dlr of (string)
  | T_IDENT_srp of (string)
  | T_IDENT_ext of (string)
  | T_INT of (int, string, uint)
  | T_CHAR of (char)
  | T_FLOAT of (int, string, uint)
  | T_CDATA of (ptr, size_t)
  | T_STRING of (string)
  | T_COMMA of ()
  | T_SEMICOLON of ()
  | T_LPAREN of ()
  | T_RPAREN of ()
  | T_LBRACKET of ()
  | T_RBRACKET of ()
  | T_LBRACE of ()
  | T_RBRACE of ()
  | T_ATLPAREN of ()
  | T_QUOTELPAREN of ()
  | T_ATLBRACKET of ()
  | T_QUOTELBRACKET of ()
  | T_HASHLBRACKET of ()
  | T_ATLBRACE of ()
  | T_QUOTELBRACE of ()
  | T_BQUOTELPAREN of ()
  | T_COMMALPAREN of ()
  | T_PERCENTLPAREN of ()
  | T_EXTCODE of (int, string)
  | T_COMMENT_line of ()
  | T_COMMENT_rest of ()
  | T_COMMENT_block of ()
  | T_ERR of ()
  | T_EOF of ()
and
token_view =
  | TOKEN of (location, token_node)
and
lexerr_node_view =
  | LE_CHAR_oct of ()
  | LE_CHAR_hex of ()
  | LE_CHAR_unclose of ()
  | LE_QUOTE_dangling of ()
  | LE_STRING_unclose of ()
  | LE_STRING_char_oct of ()
  | LE_STRING_char_hex of ()
  | LE_COMMENT_block_unclose of ()
  | LE_EXTCODE_unclose of ()
  | LE_DIGIT_oct_89 of (char)
  | LE_IDIGITS_empty of ()
  | LE_FEXPONENT_empty of ()
  | LE_FEXPONENT_missing of ()
  | LE_FINTFRAC_missing of ()
  | LE_UNSUPPORTED_char of (char)
and
lexerr_view =
  | LEXERR of (location, lexerr_node)
//
fun
token_node_encode(v: token_node_view): token_node
fun
token_node_view(x: token_node): token_node_view
fun
token_node_view_free(v: token_node_view): void
fun
token_node_tag(x: token_node): int
fun
token_node_T_NONE(): token_node
fun
token_node_T_AT(): token_node
fun
token_node_T_BAR(): token_node
fun
token_node_T_BANG(): token_node
fun
token_node_T_BQUOTE(): token_node
fun
token_node_T_BACKSLASH(): token_node
fun
token_node_T_COLON(): token_node
fun
token_node_T_COLONLT(): token_node
fun
token_node_T_DOLLAR(): token_node
fun
token_node_T_DOT(): token_node
fun
token_node_T_DOTDOT(): token_node
fun
token_node_T_DOTDOTDOT(): token_node
fun
token_node_T_DOTINT(a0: int): token_node
fun
token_node_T_EQ(): token_node
fun
token_node_T_EQGT(): token_node
fun
token_node_T_EQLT(): token_node
fun
token_node_T_EQLTGT(): token_node
fun
token_node_T_EQSLASHEQGT(): token_node
fun
token_node_T_EQGTGT(): token_node
fun
token_node_T_EQSLASHEQGTGT(): token_node
fun
token_node_T_HASH(): token_node
fun
token_node_T_LT(): token_node
fun
token_node_T_GT(): token_node
fun
token_node_T_GTLT(): token_node
fun
token_node_T_DOTLT(): token_node
fun
token_node_T_GTDOT(): token_node
fun
token_node_T_DOTLTGTDOT(): token_node
fun
token_node_T_MINUSGT(): token_node
fun
token_node_T_MINUSLT(): token_node
fun
token_node_T_MINUSLTGT(): token_node
fun
token_node_T_TILDE(): token_node
fun
token_node_T_ABSTYPE(a0: int): token_node
fun
token_node_T_ASSUME(): token_node
fun
token_node_T_REASSUME(): token_node
fun
token_node_T_AS(): token_node
fun
token_node_T_AND(): token_node
fun
token_node_T_BEGIN(): token_node
fun
token_node_T_CASE(a0: caskind): token_node
fun
token_node_T_CLASSDEC(): token_node
fun
token_node_T_DATASORT(): token_node
fun
token_node_T_DATATYPE(a0: int): token_node
fun
token_node_T_DO(): token_node
fun
token_node_T_ELSE(): token_node
fun
token_node_T_END(): token_node
fun
token_node_T_EXCEPTION(): token_node
fun
token_node_T_EXTERN(): token_node
fun
token_node_T_EXTYPE(): token_node
fun
token_node_T_EXTVAR(): token_node
fun
token_node_T_FIX(a0: int): token_node
fun
token_node_T_FIXITY(a0: fxtykind): token_node
fun
token_node_T_FOR(): token_node
fun
token_node_T_FORSTAR(): token_node
fun
token_node_T_FUN(a0: funkind): token_node
fun
token_node_T_IF(): token_node
fun
token_node_T_IFCASE(): token_node
fun
token_node_T_IMPLEMENT(a0: int): token_node
fun
token_node_T_IMPORT(): token_node
fun
token_node_T_IN(): token_node
fun
token_node_T_LAM(a0: int): token_node
fun
token_node_T_LET(): token_node
fun
token_node_T_LOCAL(): token_node
fun
token_node_T_MACDEF(a0: int): token_node
fun
token_node_T_NONFIX(): token_node
fun
token_node_T_OF(): token_node
fun
token_node_T_OP(): token_node
fun
token_node_T_REC(): token_node
fun
token_node_T_SIF(): token_node
fun
token_node_T_SCASE(): token_node
fun
token_node_T_STACST(): token_node
fun
token_node_T_STADEF(): token_node
fun
token_node_T_STATIC(): token_node
fun
token_node_T_SORTDEF(): token_node
fun
token_node_T_SYMELIM(): token_node
fun
token_node_T_SYMINTR(): token_node
fun
token_node_T_SYMLOAD(): token_node
fun
token_node_T_THEN(): token_node
fun
token_node_T_TKINDEF(): token_node
fun
token_node_T_TRY(): token_node
fun
token_node_T_TYPE(a0: int): token_node
fun
token_node_T_TYPEDEF(a0: int): token_node
fun
token_node_T_VAL(a0: valkind): token_node
fun
token_node_T_VAR(a0: int): token_node
fun
token_node_T_WHEN(): token_node
fun
token_node_T_WHERE(): token_node
fun
token_node_T_WHILE(): token_node
fun
token_node_T_WHILESTAR(): token_node
fun
token_node_T_WITH(): token_node
fun
token_node_T_WITHTYPE(a0: int): token_node
fun
token_node_T_ADDRAT(): token_node
fun
token_node_T_FOLDAT(): token_node
fun
token_node_T_FREEAT(): token_node
fun
token_node_T_VIEWAT(): token_node
fun
token_node_T_DLRDELAY(a0: int): token_node
fun
token_node_T_DLRARRPSZ(): token_node
fun
token_node_T_DLRTYREP(): token_node
fun
token_node_T_DLRD2CTYPE(): token_node
fun
token_node_T_DLREFFMASK(): token_node
fun
token_node_T_DLREFFMASK_ARG(a0: int): token_node
fun
token_node_T_DLREXTERN(): token_node
fun
token_node_T_DLREXTYPE(): token_node
fun
token_node_T_DLREXTKIND(): token_node
fun
token_node_T_DLREXTYPE_STRUCT(): token_node
fun
token_node_T_DLREXTVAL(): token_node
fun
token_node_T_DLREXTFCALL(): token_node
fun
token_node_T_DLREXTMCALL(): token_node
fun
token_node_T_DLRLITERAL(): token_node
fun
token_node_T_DLRMYFILENAME(): token_node
fun
token_node_T_DLRMYLOCATION(): token_node
fun
token_node_T_DLRMYFUNCTION(): token_node
fun
token_node_T_DLRLST(a0: int): token_node
fun
token_node_T_DLRREC(a0: int): token_node
fun
token_node_T_DLRTUP(a0: int): token_node
fun
token_node_T_DLRBREAK(): token_node
fun
token_node_T_DLRCONTINUE(): token_node
fun
token_node_T_DLRRAISE(): token_node
fun
token_node_T_DLRVARARG(): token_node
fun
token_node_T_DLRVCOPYENV(a0: int): token_node
fun
token_node_T_DLRSHOWTYPE(): token_node
fun
token_node_T_DLRTEMPENVER(): token_node
fun
token_node_T_DLRSOLASSERT(): token_node
fun
token_node_T_DLRSOLVERIFY(): token_node
fun
token_node_T_SRPIF(): token_node
fun
token_node_T_SRPIFDEF(): token_node
fun
token_node_T_SRPIFNDEF(): token_node
fun
token_node_T_SRPTHEN(): token_node
fun
token_node_T_SRPELIF(): token_node
fun
token_node_T_SRPELIFDEF(): token_node
fun
token_node_T_SRPELIFNDEF(): token_node
fun
token_node_T_SRPELSE(): token_node
fun
token_node_T_SRPENDIF(): token_node
fun
token_node_T_SRPERROR(): token_node
fun
token_node_T_SRPPRERR(): token_node
fun
token_node_T_SRPPRINT(): token_node
fun
token_node_T_SRPASSERT(): token_node
fun
token_node_T_SRPUNDEF(): token_node
fun
token_node_T_SRPDEFINE(): token_node
fun
token_node_T_SRPINCLUDE(): token_node
fun
token_node_T_SRPSTALOAD(): token_node
fun
token_node_T_SRPDYNLOAD(): token_node
fun
token_node_T_SRPREQUIRE(): token_node
fun
token_node_T_SRPPRAGMA(): token_node
fun
token_node_T_SRPCODEGEN2(): token_node
fun
token_node_T_SRPCODEGEN3(): token_node
fun
token_node_T_IDENT_alp(a0: string): token_node
fun
token_node_T_IDENT_sym(a0: string): token_node
fun
token_node_T_IDENT_arr(a0: string): token_node
fun
token_node_T_IDENT_tmp(a0: string): token_node
fun
token_node_T_IDENT_dlr(a0: string): token_node
fun
token_node_T_IDENT_srp(a0: string): token_node
fun
token_node_T_IDENT_ext(a0: string): token_node
fun
token_node_T_INT(a0: int, a1: string, a2: uint): token_node
fun
token_node_T_CHAR(a0: char): token_node
fun
token_node_T_FLOAT(a0: int, a1: string, a2: uint): token_node
fun
token_node_T_CDATA(a0: ptr, a1: size_t): token_node
fun
token_node_T_STRING(a0: string): token_node
fun
token_node_T_COMMA(): token_node
fun
token_node_T_SEMICOLON(): token_node
fun
token_node_T_LPAREN(): token_node
fun
token_node_T_RPAREN(): token_node
fun
token_node_T_LBRACKET(): token_node
fun
token_node_T_RBRACKET(): token_node
fun
token_node_T_LBRACE(): token_node
fun
token_node_T_RBRACE(): token_node
fun
token_node_T_ATLPAREN(): token_node
fun
token_node_T_QUOTELPAREN(): token_node
fun
token_node_T_ATLBRACKET(): token_node
fun
token_node_T_QUOTELBRACKET(): token_node
fun
token_node_T_HASHLBRACKET(): token_node
fun
token_node_T_ATLBRACE(): token_node
fun
token_node_T_QUOTELBRACE(): token_node
fun
token_node_T_BQUOTELPAREN(): token_node
fun
token_node_T_COMMALPAREN(): token_node
fun
token_node_T_PERCENTLPAREN(): token_node
fun
token_node_T_EXTCODE(a0: int, a1: string): token_node
fun
token_node_T_COMMENT_line(): token_node
fun
token_node_T_COMMENT_rest(): token_node
fun
token_node_T_COMMENT_block(): token_node
fun
token_node_T_ERR(): token_node
fun
token_node_T_EOF(): token_node
fun
token_node_is_T_NONE(x: token_node): bool
fun
token_node_is_T_AT(x: token_node): bool
fun
token_node_is_T_BAR(x: token_node): bool
fun
token_node_is_T_BANG(x: token_node): bool
fun
token_node_is_T_BQUOTE(x: token_node): bool
fun
token_node_is_T_BACKSLASH(x: token_node): bool
fun
token_node_is_T_COLON(x: token_node): bool
fun
token_node_is_T_COLONLT(x: token_node): bool
fun
token_node_is_T_DOLLAR(x: token_node): bool
fun
token_node_is_T_DOT(x: token_node): bool
fun
token_node_is_T_DOTDOT(x: token_node): bool
fun
token_node_is_T_DOTDOTDOT(x: token_node): bool
fun
token_node_is_T_DOTINT(x: token_node): bool
fun
token_node_is_T_EQ(x: token_node): bool
fun
token_node_is_T_EQGT(x: token_node): bool
fun
token_node_is_T_EQLT(x: token_node): bool
fun
token_node_is_T_EQLTGT(x: token_node): bool
fun
token_node_is_T_EQSLASHEQGT(x: token_node): bool
fun
token_node_is_T_EQGTGT(x: token_node): bool
fun
token_node_is_T_EQSLASHEQGTGT(x: token_node): bool
fun
token_node_is_T_HASH(x: token_node): bool
fun
token_node_is_T_LT(x: token_node): bool
fun
token_node_is_T_GT(x: token_node): bool
fun
token_node_is_T_GTLT(x: token_node): bool
fun
token_node_is_T_DOTLT(x: token_node): bool
fun
token_node_is_T_GTDOT(x: token_node): bool
fun
token_node_is_T_DOTLTGTDOT(x: token_node): bool
fun
token_node_is_T_MINUSGT(x: token_node): bool
fun
token_node_is_T_MINUSLT(x: token_node): bool
fun
token_node_is_T_MINUSLTGT(x: token_node): bool
fun
token_node_is_T_TILDE(x: token_node): bool
fun
token_node_is_T_ABSTYPE(x: token_node): bool
fun
token_node_is_T_ASSUME(x: token_node): bool
fun
token_node_is_T_REASSUME(x: token_node): bool
fun
token_node_is_T_AS(x: token_node): bool
fun
token_node_is_T_AND(x: token_node): bool
fun
token_node_is_T_BEGIN(x: token_node): bool
fun
token_node_is_T_CASE(x: token_node): bool
fun
token_node_is_T_CLASSDEC(x: token_node): bool
fun
token_node_is_T_DATASORT(x: token_node): bool
fun
token_node_is_T_DATATYPE(x: token_node): bool
fun
token_node_is_T_DO(x: token_node): bool
fun
token_node_is_T_ELSE(x: token_node): bool
fun
token_node_is_T_END(x: token_node): bool
fun
token_node_is_T_EXCEPTION(x: token_node): bool
fun
token_node_is_T_EXTERN(x: token_node): bool
fun
token_node_is_T_EXTYPE(x: token_node): bool
fun
token_node_is_T_EXTVAR(x: token_node): bool
fun
token_node_is_T_FIX(x: token_node): bool
fun
token_node_is_T_FIXITY(x: token_node): bool
fun
token_node_is_T_FOR(x: token_node): bool
fun
token_node_is_T_FORSTAR(x: token_node): bool
fun
token_node_is_T_FUN(x: token_node): bool
fun
token_node_is_T_IF(x: token_node): bool
fun
token_node_is_T_IFCASE(x: token_node): bool
fun
token_node_is_T_IMPLEMENT(x: token_node): bool
fun
token_node_is_T_IMPORT(x: token_node): bool
fun
token_node_is_T_IN(x: token_node): bool
fun
token_node_is_T_LAM(x: token_node): bool
fun
token_node_is_T_LET(x: token_node): bool
fun
token_node_is_T_LOCAL(x: token_node): bool
fun
token_node_is_T_MACDEF(x: token_node): bool
fun
token_node_is_T_NONFIX(x: token_node): bool
fun
token_node_is_T_OF(x: token_node): bool
fun
token_node_is_T_OP(x: token_node): bool
fun
token_node_is_T_REC(x: token_node): bool
fun
token_node_is_T_SIF(x: token_node): bool
fun
token_node_is_T_SCASE(x: token_node): bool
fun
token_node_is_T_STACST(x: token_node): bool
fun
token_node_is_T_STADEF(x: token_node): bool
fun
token_node_is_T_STATIC(x: token_node): bool
fun
token_node_is_T_SORTDEF(x: token_node): bool
fun
token_node_is_T_SYMELIM(x: token_node): bool
fun
token_node_is_T_SYMINTR(x: token_node): bool
fun
token_node_is_T_SYMLOAD(x: token_node): bool
fun
token_node_is_T_THEN(x: token_node): bool
fun
token_node_is_T_TKINDEF(x: token_node): bool
fun
token_node_is_T_TRY(x: token_node): bool
fun
token_node_is_T_TYPE(x: token_node): bool
fun
token_node_is_T_TYPEDEF(x: token_node): bool
fun
token_node_is_T_VAL(x: token_node): bool
fun
token_node_is_T_VAR(x: token_node): bool
fun
token_node_is_T_WHEN(x: token_node): bool
fun
token_node_is_T_WHERE(x: token_node): bool
fun
token_node_is_T_WHILE(x: token_node): bool
fun
token_node_is_T_WHILESTAR(x: token_node): bool
fun
token_node_is_T_WITH(x: token_node): bool
fun
token_node_is_T_WITHTYPE(x: token_node): bool
fun
token_node_is_T_ADDRAT(x: token_node): bool
fun
token_node_is_T_FOLDAT(x: token_node): bool
fun
token_node_is_T_FREEAT(x: token_node): bool
fun
token_node_is_T_VIEWAT(x: token_node): bool
fun
token_node_is_T_DLRDELAY(x: token_node): bool
fun
token_node_is_T_DLRARRPSZ(x: token_node): bool
fun
token_node_is_T_DLRTYREP(x: token_node): bool
fun
token_node_is_T_DLRD2CTYPE(x: token_node): bool
fun
token_node_is_T_DLREFFMASK(x: token_node): bool
fun
token_node_is_T_DLREFFMASK_ARG(x: token_node): bool
fun
token_node_is_T_DLREXTERN(x: token_node): bool
fun
token_node_is_T_DLREXTYPE(x: token_node): bool
fun
token_node_is_T_DLREXTKIND(x: token_node): bool
fun
token_node_is_T_DLREXTYPE_STRUCT(x: token_node): bool
fun
token_node_is_T_DLREXTVAL(x: token_node): bool
fun
token_node_is_T_DLREXTFCALL(x: token_node): bool
fun
token_node_is_T_DLREXTMCALL(x: token_node): bool
fun
token_node_is_T_DLRLITERAL(x: token_node): bool
fun
token_node_is_T_DLRMYFILENAME(x: token_node): bool
fun
token_node_is_T_DLRMYLOCATION(x: token_node): bool
fun
token_node_is_T_DLRMYFUNCTION(x: token_node): bool
fun
token_node_is_T_DLRLST(x: token_node): bool
fun
token_node_is_T_DLRREC(x: token_node): bool
fun
token_node_is_T_DLRTUP(x: token_node): bool
fun
token_node_is_T_DLRBREAK(x: token_node): bool
fun
token_node_is_T_DLRCONTINUE(x: token_node): bool
fun
token_node_is_T_DLRRAISE(x: token_node): bool
fun
token_node_is_T_DLRVARARG(x: token_node): bool
fun
token_node_is_T_DLRVCOPYENV(x: token_node): bool
fun
token_node_is_T_DLRSHOWTYPE(x: token_node): bool
fun
token_node_is_T_DLRTEMPENVER(x: token_node): bool
fun
token_node_is_T_DLRSOLASSERT(x: token_node): bool
fun
token_node_is_T_DLRSOLVERIFY(x: token_node): bool
fun
token_node_is_T_SRPIF(x: token_node): bool
fun
token_node_is_T_SRPIFDEF(x: token_node): bool
fun
token_node_is_T_SRPIFNDEF(x: token_node): bool
fun
token_node_is_T_SRPTHEN(x: token_node): bool
fun
token_node_is_T_SRPELIF(x: token_node): bool
fun
token_node_is_T_SRPELIFDEF(x: token_node): bool
fun
token_node_is_T_SRPELIFNDEF(x: token_node): bool
fun
token_node_is_T_SRPELSE(x: token_node): bool
fun
token_node_is_T_SRPENDIF(x: token_node): bool
fun
token_node_is_T_SRPERROR(x: token_node): bool
fun
token_node_is_T_SRPPRERR(x: token_node): bool
fun
token_node_is_T_SRPPRINT(x: token_node): bool
fun
token_node_is_T_SRPASSERT(x: token_node): bool
fun
token_node_is_T_SRPUNDEF(x: token_node): bool
fun
token_node_is_T_SRPDEFINE(x: token_node): bool
fun
token_node_is_T_SRPINCLUDE(x: token_node): bool
fun
token_node_is_T_SRPSTALOAD(x: token_node): bool
fun
token_node_is_T_SRPDYNLOAD(x: token_node): bool
fun
token_node_is_T_SRPREQUIRE(x: token_node): bool
fun
token_node_is_T_SRPPRAGMA(x: token_node): bool
fun
token_node_is_T_SRPCODEGEN2(x: token_node): bool
fun
token_node_is_T_SRPCODEGEN3(x: token_node): bool
fun
token_node_is_T_IDENT_alp(x: token_node): bool
fun
token_node_is_T_IDENT_sym(x: token_node): bool
fun
token_node_is_T_IDENT_arr(x: token_node): bool
fun
token_node_is_T_IDENT_tmp(x: token_node): bool
fun
token_node_is_T_IDENT_dlr(x: token_node): bool
fun
token_node_is_T_IDENT_srp(x: token_node): bool
fun
token_node_is_T_IDENT_ext(x: token_node): bool
fun
token_node_is_T_INT(x: token_node): bool
fun
token_node_is_T_CHAR(x: token_node): bool
fun
token_node_is_T_FLOAT(x: token_node): bool
fun
token_node_is_T_CDATA(x: token_node): bool
fun
token_node_is_T_STRING(x: token_node): bool
fun
token_node_is_T_COMMA(x: token_node): bool
fun
token_node_is_T_SEMICOLON(x: token_node): bool
fun
token_node_is_T_LPAREN(x: token_node): bool
fun
token_node_is_T_RPAREN(x: token_node): bool
fun
token_node_is_T_LBRACKET(x: token_node): bool
fun
token_node_is_T_RBRACKET(x: token_node): bool
fun
token_node_is_T_LBRACE(x: token_node): bool
fun
token_node_is_T_RBRACE(x: token_node): bool
fun
token_node_is_T_ATLPAREN(x: token_node): bool
fun
token_node_is_T_QUOTELPAREN(x: token_node): bool
fun
token_node_is_T_ATLBRACKET(x: token_node): bool
fun
token_node_is_T_QUOTELBRACKET(x: token_node): bool
fun
token_node_is_T_HASHLBRACKET(x: token_node): bool
fun
token_node_is_T_ATLBRACE(x: token_node): bool
fun
token_node_is_T_QUOTELBRACE(x: token_node): bool
fun
token_node_is_T_BQUOTELPAREN(x: token_node): bool
fun
token_node_is_T_COMMALPAREN(x: token_node): bool
fun
token_node_is_T_PERCENTLPAREN(x: token_node): bool
fun
token_node_is_T_EXTCODE(x: token_node): bool
fun
token_node_is_T_COMMENT_line(x: token_node): bool
fun
token_node_is_T_COMMENT_rest(x: token_node): bool
fun
token_node_is_T_COMMENT_block(x: token_node): bool
fun
token_node_is_T_ERR(x: token_node): bool
fun
token_node_is_T_EOF(x: token_node): bool
//
fun
token_encode(v: token_view): token
fun
token_view(x: token): token_view
fun
token_view_free(v: token_view): void
fun
token_tag(x: token): int
fun
token_TOKEN(a0: location, a1: token_node): token
fun
token_get_token_loc(x: token): location
overload .token_loc with token_get_token_loc
fun
token_get_token_node(x: token): token_node
overload .token_node with token_get_token_node
//
fun
lexerr_node_encode(v: lexerr_node_view): lexerr_node
fun
lexerr_node_view(x: lexerr_node): lexerr_node_view
fun
lexerr_node_view_free(v: lexerr_node_view): void
fun
lexerr_node_tag(x: lexerr_node): int
fun
lexerr_node_LE_CHAR_oct(): lexerr_node
fun
lexerr_node_LE_CHAR_hex(): lexerr_node
fun
lexerr_node_LE_CHAR_unclose(): lexerr_node
fun
lexerr_node_LE_QUOTE_dangling(): lexerr_node
fun
lexerr_node_LE_STRING_unclose(): lexerr_node
fun
lexerr_node_LE_STRING_char_oct(): lexerr_node
fun
lexerr_node_LE_STRING_char_hex(): lexerr_node
fun
lexerr_node_LE_COMMENT_block_unclose(): lexerr_node
fun
lexerr_node_LE_EXTCODE_unclose(): lexerr_node
fun
lexerr_node_LE_DIGIT_oct_89(a0: char): lexerr_node
fun
lexerr_node_LE_IDIGITS_empty(): lexerr_node
fun
lexerr_node_LE_FEXPONENT_empty(): lexerr_node
fun
lexerr_node_LE_FEXPONENT_missing(): lexerr_node
fun
lexerr_node_LE_FINTFRAC_missing(): lexerr_node
fun
lexerr_node_LE_UNSUPPORTED_char(a0: char): lexerr_node
fun
lexerr_node_is_LE_CHAR_oct(x: lexerr_node): bool
fun
lexerr_node_is_LE_CHAR_hex(x: lexerr_node): bool
fun
lexerr_node_is_LE_CHAR_unclose(x: lexerr_node): bool
fun
lexerr_node_is_LE_QUOTE_dangling(x: lexerr_node): bool
fun
lexerr_node_is_LE_STRING_unclose(x: lexerr_node): bool
fun
lexerr_node_is_LE_STRING_char_oct(x: lexerr_node): bool
fun
lexerr_node_is_LE_STRING_char_hex(x: lexerr_node): bool
fun
lexerr_node_is_LE_COMMENT_block_unclose(x: lexerr_node): bool
fun
lexerr_node_is_LE_EXTCODE_unclose(x: lexerr_node): bool
fun
lexerr_node_is_LE_DIGIT_oct_89(x: lexerr_node): bool
fun
lexerr_node_is_LE_IDIGITS_empty(x: lexerr_node): bool
fun
lexerr_node_is_LE_FEXPONENT_empty(x: lexerr_node): bool
fun
lexerr_node_is_LE_FEXPONENT_missing(x: lexerr_node): bool
fun
lexerr_node_is_LE_FINTFRAC_missing(x: lexerr_node): bool
fun
lexerr_node_is_LE_UNSUPPORTED_char(x: lexerr_node): bool
//
fun
lexerr_encode(v: lexerr_view): lexerr
fun
lexerr_view(x: lexerr): lexerr_view
fun
lexerr_view_free(v: lexerr_view): void
fun
lexerr_tag(x: lexerr): int
fun
lexerr_LEXERR(a0: location, a1: lexerr_node): lexerr
fun
lexerr_get_lexerr_loc(x: lexerr): location
overload .lexerr_loc with lexerr_get_lexerr_loc
fun
lexerr_get_lexerr_node(x: lexerr): lexerr_node
overload .lexerr_node with lexerr_get_lexerr_node
//
