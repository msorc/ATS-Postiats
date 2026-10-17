abstype
parerr_type = ptr
typedef
parerr = parerr_type

//
datavtype
parerr_view =
  | PARERR of (loc_t, parerr_node)
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
