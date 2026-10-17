abstype
label_type = ptr
typedef
label = label_type

//
datavtype
label_view =
  | LABint of (int)
  | LABsym of (symbol)
//
fun
label_encode(v: label_view): label
fun
label_view(x: label): label_view
fun
label_view_free(v: label_view): void
fun
label_tag(x: label): int
fun
label_LABint(a0: int): label
fun
label_LABsym(a0: symbol): label
fun
label_is_LABint(x: label): bool
fun
label_is_LABsym(x: label): bool
//
