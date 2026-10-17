abstype
jsonval_type = ptr
typedef
jsonval = jsonval_type

abstype
labjsonval_type = ptr
typedef
labjsonval = labjsonval_type

typedef jsonvalist = glist(jsonval)
typedef labjsonvalist = glist(labjsonval)
typedef jsonvalopt = gopt(jsonval)
//
datavtype
jsonval_view =
  | JSONnul of ()
  | JSONint of (int)
  | JSONintinf of (intinf)
  | JSONbool of (bool)
  | JSONfloat of (double)
  | JSONstring of (string)
  | JSONlocation of (location)
  | JSONfilename of (filename)
  | JSONlist of (jsonvalist)
  | JSONlablist of (labjsonvalist)
  | JSONoption of (jsonvalopt)
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
jsonval_JSONint(a0: int): jsonval
fun
jsonval_JSONintinf(a0: intinf): jsonval
fun
jsonval_JSONbool(a0: bool): jsonval
fun
jsonval_JSONfloat(a0: double): jsonval
fun
jsonval_JSONstring(a0: string): jsonval
fun
jsonval_JSONlocation(a0: location): jsonval
fun
jsonval_JSONfilename(a0: filename): jsonval
fun
jsonval_JSONlist(a0: jsonvalist): jsonval
fun
jsonval_JSONlablist(a0: labjsonvalist): jsonval
fun
jsonval_JSONoption(a0: jsonvalopt): jsonval
fun
jsonval_is_JSONnul(x: jsonval): bool
fun
jsonval_is_JSONint(x: jsonval): bool
fun
jsonval_is_JSONintinf(x: jsonval): bool
fun
jsonval_is_JSONbool(x: jsonval): bool
fun
jsonval_is_JSONfloat(x: jsonval): bool
fun
jsonval_is_JSONstring(x: jsonval): bool
fun
jsonval_is_JSONlocation(x: jsonval): bool
fun
jsonval_is_JSONfilename(x: jsonval): bool
fun
jsonval_is_JSONlist(x: jsonval): bool
fun
jsonval_is_JSONlablist(x: jsonval): bool
fun
jsonval_is_JSONoption(x: jsonval): bool
//
fun
labjsonval_new(a0: string, a1: jsonval): labjsonval
fun
labjsonval_lab(x: labjsonval): string
overload .labjsonval_lab with labjsonval_lab
fun
labjsonval_val(x: labjsonval): jsonval
overload .labjsonval_val with labjsonval_val
//
