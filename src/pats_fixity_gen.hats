abstype
fxty_type = ptr
typedef
fxty = fxty_type

//
datavtype
fxty_view =
  | FXTYnon of ()
  | FXTYinf of (prec, assoc)
  | FXTYpre of (prec)
  | FXTYpos of (prec)
//
fun
fxty_encode(v: fxty_view): fxty
fun
fxty_view(x: fxty): fxty_view
fun
fxty_view_free(v: fxty_view): void
fun
fxty_tag(x: fxty): int
fun
fxty_FXTYnon(): fxty
fun
fxty_FXTYinf(a0: prec, a1: assoc): fxty
fun
fxty_FXTYpre(a0: prec): fxty
fun
fxty_FXTYpos(a0: prec): fxty
fun
fxty_is_FXTYnon(x: fxty): bool
fun
fxty_is_FXTYinf(x: fxty): bool
fun
fxty_is_FXTYpre(x: fxty): bool
fun
fxty_is_FXTYpos(x: fxty): bool
//
