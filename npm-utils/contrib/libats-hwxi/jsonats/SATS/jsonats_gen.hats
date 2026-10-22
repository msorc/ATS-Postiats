abstype
jsonval_type = ptr
typedef
jsonval = jsonval_type

//
datavtype
jsonval_view =
  | JSONnul of ()
  | JSONbool of (bool)
  | JSONint of (int)
  | JSONfloat of (double)
  | JSONstring of (string)
  | JSONarray of (glist(jsonval))
  | JSONobject of (glist(@(string, jsonval)))
//
fun
jsonval_encode(v: jsonval_view): jsonval
fun
jsonval_view(x: jsonval): jsonval_view
fun
jsonval_view_free(v: jsonval_view): void
fun
jsonval_tag(x: jsonval): int
fun
jsonval_JSONnul(): jsonval
fun
jsonval_JSONbool(a0: bool): jsonval
fun
jsonval_JSONint(a0: int): jsonval
fun
jsonval_JSONfloat(a0: double): jsonval
fun
jsonval_JSONstring(a0: string): jsonval
fun
jsonval_JSONarray(a0: glist(jsonval)): jsonval
fun
jsonval_JSONobject(a0: glist(@(string, jsonval))): jsonval
fun
jsonval_is_JSONnul(x: jsonval): bool
fun
jsonval_is_JSONbool(x: jsonval): bool
fun
jsonval_is_JSONint(x: jsonval): bool
fun
jsonval_is_JSONfloat(x: jsonval): bool
fun
jsonval_is_JSONstring(x: jsonval): bool
fun
jsonval_is_JSONarray(x: jsonval): bool
fun
jsonval_is_JSONobject(x: jsonval): bool
//
