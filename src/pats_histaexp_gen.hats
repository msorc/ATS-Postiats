abstype
hitnam_type = ptr
typedef
hitnam = hitnam_type

abstype
hisexp_type = ptr
typedef
hisexp = hisexp_type

abstype
labhisexp_type = ptr
typedef
labhisexp = labhisexp_type

abstype
hisexp_node_type = ptr
typedef
hisexp_node = hisexp_node_type

typedef hisexplst = glist(hisexp)
typedef hisexpopt = gopt(hisexp)
typedef hisexplstlst = glist(hisexplst)
typedef labhisexplst = glist(labhisexp)
//
datavtype
hisexp_node_view =
  | HSEcst of (s2cst)
  | HSEtybox of ()
  | HSEtyabs of (symbol)
  | HSEapp of (hisexp, hisexplst)
  | HSEextype of (string, hisexplstlst)
  | HSEfun of (funclo, hisexplst, hisexp)
  | HSErefarg of (int, hisexp)
  | HSEtyarr of (hisexp, s2explst)
  | HSEtyrec of (tyreckind, labhisexplst)
  | HSEtyrecsin of (labhisexp)
  | HSEtysum of (d2con, labhisexplst)
  | HSEtyvar of (s2var)
  | HSEtyclo of (funlab)
  | HSEvararg of (s2exp)
  | HSEs2exp of (s2exp)
  | HSEs2zexp of (s2zexp)
//
fun
hitnam_new(a0: int, a1: int, a2: string): hitnam
fun
hitnam_ptr(x: hitnam): int
overload .hitnam_ptr with hitnam_ptr
fun
hitnam_fin(x: hitnam): int
overload .hitnam_fin with hitnam_fin
fun
hitnam_name(x: hitnam): string
overload .hitnam_name with hitnam_name
//
fun
hisexp_new(a0: hitnam, a1: hisexp_node): hisexp
fun
hisexp_name(x: hisexp): hitnam
overload .hisexp_name with hisexp_name
fun
hisexp_node(x: hisexp): hisexp_node
overload .hisexp_node with hisexp_node
//
fun
labhisexp_new(a0: label, a1: stringopt, a2: hisexp): labhisexp
fun
labhisexp_lab(x: labhisexp): label
overload .labhisexp_lab with labhisexp_lab
fun
labhisexp_opt(x: labhisexp): stringopt
overload .labhisexp_opt with labhisexp_opt
fun
labhisexp_elt(x: labhisexp): hisexp
overload .labhisexp_elt with labhisexp_elt
//
fun
hisexp_node_encode(v: hisexp_node_view): hisexp_node
fun
hisexp_node_view(x: hisexp_node): hisexp_node_view
fun
hisexp_node_view_free(v: hisexp_node_view): void
fun
hisexp_node_tag(x: hisexp_node): int
fun
hisexp_node_HSEcst(a0: s2cst): hisexp_node
fun
hisexp_node_HSEtybox(): hisexp_node
fun
hisexp_node_HSEtyabs(a0: symbol): hisexp_node
fun
hisexp_node_HSEapp(a0: hisexp, a1: hisexplst): hisexp_node
fun
hisexp_node_HSEextype(a0: string, a1: hisexplstlst): hisexp_node
fun
hisexp_node_HSEfun(a0: funclo, a1: hisexplst, a2: hisexp): hisexp_node
fun
hisexp_node_HSErefarg(a0: int, a1: hisexp): hisexp_node
fun
hisexp_node_HSEtyarr(a0: hisexp, a1: s2explst): hisexp_node
fun
hisexp_node_HSEtyrec(a0: tyreckind, a1: labhisexplst): hisexp_node
fun
hisexp_node_HSEtyrecsin(a0: labhisexp): hisexp_node
fun
hisexp_node_HSEtysum(a0: d2con, a1: labhisexplst): hisexp_node
fun
hisexp_node_HSEtyvar(a0: s2var): hisexp_node
fun
hisexp_node_HSEtyclo(a0: funlab): hisexp_node
fun
hisexp_node_HSEvararg(a0: s2exp): hisexp_node
fun
hisexp_node_HSEs2exp(a0: s2exp): hisexp_node
fun
hisexp_node_HSEs2zexp(a0: s2zexp): hisexp_node
fun
hisexp_node_is_HSEcst(x: hisexp_node): bool
fun
hisexp_node_is_HSEtybox(x: hisexp_node): bool
fun
hisexp_node_is_HSEtyabs(x: hisexp_node): bool
fun
hisexp_node_is_HSEapp(x: hisexp_node): bool
fun
hisexp_node_is_HSEextype(x: hisexp_node): bool
fun
hisexp_node_is_HSEfun(x: hisexp_node): bool
fun
hisexp_node_is_HSErefarg(x: hisexp_node): bool
fun
hisexp_node_is_HSEtyarr(x: hisexp_node): bool
fun
hisexp_node_is_HSEtyrec(x: hisexp_node): bool
fun
hisexp_node_is_HSEtyrecsin(x: hisexp_node): bool
fun
hisexp_node_is_HSEtysum(x: hisexp_node): bool
fun
hisexp_node_is_HSEtyvar(x: hisexp_node): bool
fun
hisexp_node_is_HSEtyclo(x: hisexp_node): bool
fun
hisexp_node_is_HSEvararg(x: hisexp_node): bool
fun
hisexp_node_is_HSEs2exp(x: hisexp_node): bool
fun
hisexp_node_is_HSEs2zexp(x: hisexp_node): bool
//
