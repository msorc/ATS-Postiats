abstype
expr_type = ptr
typedef
expr = expr_type

//
datavtype
expr_view =
  | EXPRnum of (double)
  | EXPRbop of (char, expr, expr)
//
fun
expr_encode(v: expr_view): expr
fun
expr_view(x: expr): expr_view
fun
expr_view_free(v: expr_view): void
fun
expr_tag(x: expr): int
fun
expr_EXPRnum(a0: double): expr
fun
expr_EXPRbop(a0: char, a1: expr, a2: expr): expr
fun
expr_is_EXPRnum(x: expr): bool
fun
expr_is_EXPRbop(x: expr): bool
//
