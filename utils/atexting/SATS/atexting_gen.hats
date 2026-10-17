abstype
token_node_type = ptr
typedef
token_node = token_node_type

abstype
token_type = ptr
typedef
token = token_type

abstype
atext_node_type = ptr
typedef
atext_node = atext_node_type

abstype
atext_type = ptr
typedef
atext = atext_type

abstype
parerr_node_type = ptr
typedef
parerr_node = parerr_node_type

abstype
parerr_type = ptr
typedef
parerr = parerr_type

//
datavtype
token_node_view =
  | TOKeol of ()
  | TOKeof of ()
  | TOKint of (string)
  | TOKide of (string)
  | TOKspchr of (int)
  | TOKbslash of (int)
  | TOKspace of (string)
  | TOKsharp of (string)
  | TOKsquote of ()
  | TOKdquote of (string)
  | TOKcode_beg of (string)
  | TOKcode_end of (string)
and
token_view =
  | TOKEN of (loc_t, token_node)
and
atext_node_view =
  | TEXTnil of ()
  | TEXTtoken of (token)
  | TEXTstring of (string)
  | TEXTerrmsg of (string)
  | TEXTlist of (glist(atext))
  | TEXTsquote of (glist(atext))
  | TEXTdquote of (token, glist(atext))
  | TEXTextcode of (token, glist(atext), token)
  | TEXTdefname of (token, token)
  | TEXTfuncall of (token, token, glist(atext))
and
atext_view =
  | ATEXT of (loc_t, atext_node)
and
parerr_node_view =
  | PARERR_SQUOTE of (loc_t)
  | PARERR_DQUOTE of (loc_t)
  | PARERR_FUNARG of (loc_t)
  | PARERR_EXTCODE of (loc_t)
and
parerr_view =
  | PARERR of (loc_t, parerr_node)
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
token_node_TOKeol(): token_node
fun
token_node_TOKeof(): token_node
fun
token_node_TOKint(a0: string): token_node
fun
token_node_TOKide(a0: string): token_node
fun
token_node_TOKspchr(a0: int): token_node
fun
token_node_TOKbslash(a0: int): token_node
fun
token_node_TOKspace(a0: string): token_node
fun
token_node_TOKsharp(a0: string): token_node
fun
token_node_TOKsquote(): token_node
fun
token_node_TOKdquote(a0: string): token_node
fun
token_node_TOKcode_beg(a0: string): token_node
fun
token_node_TOKcode_end(a0: string): token_node
fun
token_node_is_TOKeol(x: token_node): bool
fun
token_node_is_TOKeof(x: token_node): bool
fun
token_node_is_TOKint(x: token_node): bool
fun
token_node_is_TOKide(x: token_node): bool
fun
token_node_is_TOKspchr(x: token_node): bool
fun
token_node_is_TOKbslash(x: token_node): bool
fun
token_node_is_TOKspace(x: token_node): bool
fun
token_node_is_TOKsharp(x: token_node): bool
fun
token_node_is_TOKsquote(x: token_node): bool
fun
token_node_is_TOKdquote(x: token_node): bool
fun
token_node_is_TOKcode_beg(x: token_node): bool
fun
token_node_is_TOKcode_end(x: token_node): bool
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
token_TOKEN(a0: loc_t, a1: token_node): token
fun
token_get_token_loc(x: token): loc_t
overload .token_loc with token_get_token_loc
fun
token_get_token_node(x: token): token_node
overload .token_node with token_get_token_node
//
fun
atext_node_encode(v: atext_node_view): atext_node
fun
atext_node_view(x: atext_node): atext_node_view
fun
atext_node_view_free(v: atext_node_view): void
fun
atext_node_tag(x: atext_node): int
fun
atext_node_TEXTnil(): atext_node
fun
atext_node_TEXTtoken(a0: token): atext_node
fun
atext_node_TEXTstring(a0: string): atext_node
fun
atext_node_TEXTerrmsg(a0: string): atext_node
fun
atext_node_TEXTlist(a0: glist(atext)): atext_node
fun
atext_node_TEXTsquote(a0: glist(atext)): atext_node
fun
atext_node_TEXTdquote(a0: token, a1: glist(atext)): atext_node
fun
atext_node_TEXTextcode(a0: token, a1: glist(atext), a2: token): atext_node
fun
atext_node_TEXTdefname(a0: token, a1: token): atext_node
fun
atext_node_TEXTfuncall(a0: token, a1: token, a2: glist(atext)): atext_node
fun
atext_node_is_TEXTnil(x: atext_node): bool
fun
atext_node_is_TEXTtoken(x: atext_node): bool
fun
atext_node_is_TEXTstring(x: atext_node): bool
fun
atext_node_is_TEXTerrmsg(x: atext_node): bool
fun
atext_node_is_TEXTlist(x: atext_node): bool
fun
atext_node_is_TEXTsquote(x: atext_node): bool
fun
atext_node_is_TEXTdquote(x: atext_node): bool
fun
atext_node_is_TEXTextcode(x: atext_node): bool
fun
atext_node_is_TEXTdefname(x: atext_node): bool
fun
atext_node_is_TEXTfuncall(x: atext_node): bool
//
fun
atext_encode(v: atext_view): atext
fun
atext_view(x: atext): atext_view
fun
atext_view_free(v: atext_view): void
fun
atext_tag(x: atext): int
fun
atext_ATEXT(a0: loc_t, a1: atext_node): atext
fun
atext_get_atext_loc(x: atext): loc_t
overload .atext_loc with atext_get_atext_loc
fun
atext_get_atext_node(x: atext): atext_node
overload .atext_node with atext_get_atext_node
//
fun
parerr_node_encode(v: parerr_node_view): parerr_node
fun
parerr_node_view(x: parerr_node): parerr_node_view
fun
parerr_node_view_free(v: parerr_node_view): void
fun
parerr_node_tag(x: parerr_node): int
fun
parerr_node_PARERR_SQUOTE(a0: loc_t): parerr_node
fun
parerr_node_PARERR_DQUOTE(a0: loc_t): parerr_node
fun
parerr_node_PARERR_FUNARG(a0: loc_t): parerr_node
fun
parerr_node_PARERR_EXTCODE(a0: loc_t): parerr_node
fun
parerr_node_is_PARERR_SQUOTE(x: parerr_node): bool
fun
parerr_node_is_PARERR_DQUOTE(x: parerr_node): bool
fun
parerr_node_is_PARERR_FUNARG(x: parerr_node): bool
fun
parerr_node_is_PARERR_EXTCODE(x: parerr_node): bool
//
fun
parerr_encode(v: parerr_view): parerr
fun
parerr_view(x: parerr): parerr_view
fun
parerr_view_free(v: parerr_view): void
fun
parerr_tag(x: parerr): int
fun
parerr_PARERR(a0: loc_t, a1: parerr_node): parerr
fun
parerr_get_parerr_loc(x: parerr): loc_t
overload .parerr_loc with parerr_get_parerr_loc
fun
parerr_get_parerr_node(x: parerr): parerr_node
overload .parerr_node with parerr_get_parerr_node
//
