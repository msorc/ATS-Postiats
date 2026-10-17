abstype
s2cinterp_type(l:addr) = ptr
typedef
s2cinterp(l:addr) = s2cinterp_type(l)

//
datavtype
s2cinterp_view(l:addr) =
  | S2CINTnone of ()
  | S2CINTsome of (ptr)
  | S2CINTbuiltin_0 of (fopr0)
  | S2CINTbuiltin_1 of (fopr1)
  | S2CINTbuiltin_2 of (fopr2)
  | S2CINTbuiltin_list of ()
//
fun
s2cinterp_encode{l:addr}(ar: !arena(l), v: s2cinterp_view(l)): s2cinterp(l)
fun
s2cinterp_view{l:addr}(ar: !arena(l), x: s2cinterp(l)): s2cinterp_view(l)
fun
s2cinterp_view_free{l:addr}(v: s2cinterp_view(l)): void
fun
s2cinterp_tag{l:addr}(ar: !arena(l), x: s2cinterp(l)): int
fun
s2cinterp_S2CINTnone{l:addr}(ar: !arena(l)): s2cinterp(l)
fun
s2cinterp_S2CINTsome{l:addr}(ar: !arena(l), a0: ptr): s2cinterp(l)
fun
s2cinterp_S2CINTbuiltin_0{l:addr}(ar: !arena(l), a0: fopr0): s2cinterp(l)
fun
s2cinterp_S2CINTbuiltin_1{l:addr}(ar: !arena(l), a0: fopr1): s2cinterp(l)
fun
s2cinterp_S2CINTbuiltin_2{l:addr}(ar: !arena(l), a0: fopr2): s2cinterp(l)
fun
s2cinterp_S2CINTbuiltin_list{l:addr}(ar: !arena(l)): s2cinterp(l)
fun
s2cinterp_is_S2CINTnone{l:addr}(ar: !arena(l), x: s2cinterp(l)): bool
fun
s2cinterp_is_S2CINTsome{l:addr}(ar: !arena(l), x: s2cinterp(l)): bool
fun
s2cinterp_is_S2CINTbuiltin_0{l:addr}(ar: !arena(l), x: s2cinterp(l)): bool
fun
s2cinterp_is_S2CINTbuiltin_1{l:addr}(ar: !arena(l), x: s2cinterp(l)): bool
fun
s2cinterp_is_S2CINTbuiltin_2{l:addr}(ar: !arena(l), x: s2cinterp(l)): bool
fun
s2cinterp_is_S2CINTbuiltin_list{l:addr}(ar: !arena(l), x: s2cinterp(l)): bool
//
