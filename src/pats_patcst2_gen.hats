abstype
p2atcst_type = ptr
typedef
p2atcst = p2atcst_type

abstype
labp2atcst_type = ptr
typedef
labp2atcst = labp2atcst_type

typedef p2atcstlst = glist(p2atcst)
typedef labp2atcstlst = glist(labp2atcst)
vtypedef p2atcstlst_vt = List0_vt(p2atcst)
vtypedef labp2atcstlst_vt = List0_vt(labp2atcst)
//
datavtype
p2atcst_view =
  | P2TCany of ()
  | P2TCcon of (d2con, p2atcstlst)
  | P2TCempty of ()
  | P2TCint of (intinf)
  | P2TCintc of (intinfset)
  | P2TCbool of (bool)
  | P2TCchar of (char)
  | P2TCcharc of (charset)
  | P2TCfloat of (string)
  | P2TCstring of (string)
  | P2TCrec of (int, labp2atcstlst)
//
fun
p2atcst_encode(v: p2atcst_view): p2atcst
fun
p2atcst_view(x: p2atcst): p2atcst_view
fun
p2atcst_view_free(v: p2atcst_view): void
fun
p2atcst_tag(x: p2atcst): int
fun
p2atcst_P2TCany(): p2atcst
fun
p2atcst_P2TCcon(a0: d2con, a1: p2atcstlst): p2atcst
fun
p2atcst_P2TCempty(): p2atcst
fun
p2atcst_P2TCint(a0: intinf): p2atcst
fun
p2atcst_P2TCintc(a0: intinfset): p2atcst
fun
p2atcst_P2TCbool(a0: bool): p2atcst
fun
p2atcst_P2TCchar(a0: char): p2atcst
fun
p2atcst_P2TCcharc(a0: charset): p2atcst
fun
p2atcst_P2TCfloat(a0: string): p2atcst
fun
p2atcst_P2TCstring(a0: string): p2atcst
fun
p2atcst_P2TCrec(a0: int, a1: labp2atcstlst): p2atcst
fun
p2atcst_is_P2TCany(x: p2atcst): bool
fun
p2atcst_is_P2TCcon(x: p2atcst): bool
fun
p2atcst_is_P2TCempty(x: p2atcst): bool
fun
p2atcst_is_P2TCint(x: p2atcst): bool
fun
p2atcst_is_P2TCintc(x: p2atcst): bool
fun
p2atcst_is_P2TCbool(x: p2atcst): bool
fun
p2atcst_is_P2TCchar(x: p2atcst): bool
fun
p2atcst_is_P2TCcharc(x: p2atcst): bool
fun
p2atcst_is_P2TCfloat(x: p2atcst): bool
fun
p2atcst_is_P2TCstring(x: p2atcst): bool
fun
p2atcst_is_P2TCrec(x: p2atcst): bool
//
fun
labp2atcst_new(a0: label, a1: p2atcst): labp2atcst
fun
labp2atcst_lab(x: labp2atcst): label
overload .labp2atcst_lab with labp2atcst_lab
fun
labp2atcst_elt(x: labp2atcst): p2atcst
overload .labp2atcst_elt with labp2atcst_elt
//
