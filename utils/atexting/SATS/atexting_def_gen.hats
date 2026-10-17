abstype
atextdef_type = ptr
typedef
atextdef = atextdef_type

abstype
commarg_type = ptr
typedef
commarg = commarg_type

//
datavtype
atextdef_view =
  | TEXTDEFnil of ()
  | TEXTDEFval of (atext)
  | TEXTDEFfun of (atextfun)
  | TEXTDEFfstr of (atextfstr)
and
commarg_view =
  | CAhelp of (string)
  | CAgitem of (string)
  | CAnsharp of (string, gopt(string))
  | CAinpfil of (string, gopt(string))
  | CAoutfil of (string, gopt(string))
//
fun
atextdef_encode(v: atextdef_view): atextdef
fun
atextdef_view(x: atextdef): atextdef_view
fun
atextdef_view_free(v: atextdef_view): void
fun
atextdef_tag(x: atextdef): int
fun
atextdef_TEXTDEFnil(): atextdef
fun
atextdef_TEXTDEFval(a0: atext): atextdef
fun
atextdef_TEXTDEFfun(a0: atextfun): atextdef
fun
atextdef_TEXTDEFfstr(a0: atextfstr): atextdef
fun
atextdef_is_TEXTDEFnil(x: atextdef): bool
fun
atextdef_is_TEXTDEFval(x: atextdef): bool
fun
atextdef_is_TEXTDEFfun(x: atextdef): bool
fun
atextdef_is_TEXTDEFfstr(x: atextdef): bool
//
fun
commarg_encode(v: commarg_view): commarg
fun
commarg_view(x: commarg): commarg_view
fun
commarg_view_free(v: commarg_view): void
fun
commarg_tag(x: commarg): int
fun
commarg_CAhelp(a0: string): commarg
fun
commarg_CAgitem(a0: string): commarg
fun
commarg_CAnsharp(a0: string, a1: gopt(string)): commarg
fun
commarg_CAinpfil(a0: string, a1: gopt(string)): commarg
fun
commarg_CAoutfil(a0: string, a1: gopt(string)): commarg
fun
commarg_is_CAhelp(x: commarg): bool
fun
commarg_is_CAgitem(x: commarg): bool
fun
commarg_is_CAnsharp(x: commarg): bool
fun
commarg_is_CAinpfil(x: commarg): bool
fun
commarg_is_CAoutfil(x: commarg): bool
//
