abstype
valerr_type = ptr
typedef
valerr = valerr_type

//
datavtype
valerr_view =
  | VE_valize of (e1xp)
  | VE_valize_defined of (e1xp)
  | VE_valize_undefined of (e1xp)
  | VE_maxlevel of (int, e1xp)
  | VE_opr_arglst of (e1xp, symbol)
  | VE_E1XPide_unbound of (e1xp)
  | VE_E1XPundef of (e1xp)
  | VE_E1XPlist of (e1xp)
  | VE_E1XPapp_fun of (e1xp)
  | VE_E1XPappid_fun of (e1xp, symbol)
  | VE_E1XPappid_opr of (e1xp, symbol)
  | VE_E1XPappid_arity of (e1xp, symbol)
  | VE_E1XPfun of (e1xp)
  | VE_E1XPerr of (e1xp)
//
fun
valerr_encode(v: valerr_view): valerr
fun
valerr_view(x: valerr): valerr_view
fun
valerr_view_free(v: valerr_view): void
fun
valerr_tag(x: valerr): int
fun
valerr_VE_valize(a0: e1xp): valerr
fun
valerr_VE_valize_defined(a0: e1xp): valerr
fun
valerr_VE_valize_undefined(a0: e1xp): valerr
fun
valerr_VE_maxlevel(a0: int, a1: e1xp): valerr
fun
valerr_VE_opr_arglst(a0: e1xp, a1: symbol): valerr
fun
valerr_VE_E1XPide_unbound(a0: e1xp): valerr
fun
valerr_VE_E1XPundef(a0: e1xp): valerr
fun
valerr_VE_E1XPlist(a0: e1xp): valerr
fun
valerr_VE_E1XPapp_fun(a0: e1xp): valerr
fun
valerr_VE_E1XPappid_fun(a0: e1xp, a1: symbol): valerr
fun
valerr_VE_E1XPappid_opr(a0: e1xp, a1: symbol): valerr
fun
valerr_VE_E1XPappid_arity(a0: e1xp, a1: symbol): valerr
fun
valerr_VE_E1XPfun(a0: e1xp): valerr
fun
valerr_VE_E1XPerr(a0: e1xp): valerr
fun
valerr_is_VE_valize(x: valerr): bool
fun
valerr_is_VE_valize_defined(x: valerr): bool
fun
valerr_is_VE_valize_undefined(x: valerr): bool
fun
valerr_is_VE_maxlevel(x: valerr): bool
fun
valerr_is_VE_opr_arglst(x: valerr): bool
fun
valerr_is_VE_E1XPide_unbound(x: valerr): bool
fun
valerr_is_VE_E1XPundef(x: valerr): bool
fun
valerr_is_VE_E1XPlist(x: valerr): bool
fun
valerr_is_VE_E1XPapp_fun(x: valerr): bool
fun
valerr_is_VE_E1XPappid_fun(x: valerr): bool
fun
valerr_is_VE_E1XPappid_opr(x: valerr): bool
fun
valerr_is_VE_E1XPappid_arity(x: valerr): bool
fun
valerr_is_VE_E1XPfun(x: valerr): bool
fun
valerr_is_VE_E1XPerr(x: valerr): bool
//
