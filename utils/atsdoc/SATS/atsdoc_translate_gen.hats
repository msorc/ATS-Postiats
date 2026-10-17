abstype
funarg_type = ptr
typedef
funarg = funarg_type

abstype
tranitm_node_type = ptr
typedef
tranitm_node = tranitm_node_type

abstype
tranitm_type = ptr
typedef
tranitm = tranitm_type

abstype
docerr_type = ptr
typedef
docerr = docerr_type

typedef funarglst = glist(funarg)
//
datavtype
funarg_view =
  | FAint of (string)
  | FAident of (string)
  | FAstrsub of (string)
  | FAfunres of (string)
  | FAnil of ()
and
tranitm_node_view =
  | EXTCODE of (string)
  | FUNCALL of (string, int, funarglst, string)
and
tranitm_view =
  | TRANITM of (location, tranitm_node)
and
docerr_view =
  | DOCERR of (location, int)
//
fun
funarg_encode(v: funarg_view): funarg
fun
funarg_view(x: funarg): funarg_view
fun
funarg_view_free(v: funarg_view): void
fun
funarg_tag(x: funarg): int
fun
funarg_FAint(a0: string): funarg
fun
funarg_FAident(a0: string): funarg
fun
funarg_FAstrsub(a0: string): funarg
fun
funarg_FAfunres(a0: string): funarg
fun
funarg_FAnil(): funarg
fun
funarg_is_FAint(x: funarg): bool
fun
funarg_is_FAident(x: funarg): bool
fun
funarg_is_FAstrsub(x: funarg): bool
fun
funarg_is_FAfunres(x: funarg): bool
fun
funarg_is_FAnil(x: funarg): bool
//
fun
tranitm_node_encode(v: tranitm_node_view): tranitm_node
fun
tranitm_node_view(x: tranitm_node): tranitm_node_view
fun
tranitm_node_view_free(v: tranitm_node_view): void
fun
tranitm_node_tag(x: tranitm_node): int
fun
tranitm_node_EXTCODE(a0: string): tranitm_node
fun
tranitm_node_FUNCALL(a0: string, a1: int, a2: funarglst, a3: string): tranitm_node
fun
tranitm_node_is_EXTCODE(x: tranitm_node): bool
fun
tranitm_node_is_FUNCALL(x: tranitm_node): bool
//
fun
tranitm_encode(v: tranitm_view): tranitm
fun
tranitm_view(x: tranitm): tranitm_view
fun
tranitm_view_free(v: tranitm_view): void
fun
tranitm_tag(x: tranitm): int
fun
tranitm_TRANITM(a0: location, a1: tranitm_node): tranitm
fun
tranitm_get_tranitm_loc(x: tranitm): location
overload .tranitm_loc with tranitm_get_tranitm_loc
fun
tranitm_get_tranitm_node(x: tranitm): tranitm_node
overload .tranitm_node with tranitm_get_tranitm_node
//
fun
docerr_encode(v: docerr_view): docerr
fun
docerr_view(x: docerr): docerr_view
fun
docerr_view_free(v: docerr_view): void
fun
docerr_tag(x: docerr): int
fun
docerr_DOCERR(a0: location, a1: int): docerr
fun
docerr_get_docerr_loc(x: docerr): location
overload .docerr_loc with docerr_get_docerr_loc
fun
docerr_get_docerr_node(x: docerr): int
overload .docerr_node with docerr_get_docerr_node
//
