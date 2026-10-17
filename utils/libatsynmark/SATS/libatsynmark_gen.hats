abstype
d0eclrep_type = ptr
typedef
d0eclrep = d0eclrep_type

abstype
guad0eclrep_type = ptr
typedef
guad0eclrep = guad0eclrep_type

typedef d0eclreplst = glist(d0eclrep)
//
datavtype
d0eclrep_view =
  | D0ECLREPsing of (d0ecl, charlst)
  | D0ECLREPinclude of (d0ecl, charlst, d0eclreplst)
  | D0ECLREPguadecl of (guad0eclrep)
and
guad0eclrep_view =
  | GUAD0ECLREPone of (d0eclreplst)
  | GUAD0ECLREPtwo of (d0eclreplst, d0eclreplst)
  | GUAD0ECLREPcons of (d0eclreplst, guad0eclrep)
//
fun
d0eclrep_encode(v: d0eclrep_view): d0eclrep
fun
d0eclrep_view(x: d0eclrep): d0eclrep_view
fun
d0eclrep_view_free(v: d0eclrep_view): void
fun
d0eclrep_tag(x: d0eclrep): int
fun
d0eclrep_D0ECLREPsing(a0: d0ecl, a1: charlst): d0eclrep
fun
d0eclrep_D0ECLREPinclude(a0: d0ecl, a1: charlst, a2: d0eclreplst): d0eclrep
fun
d0eclrep_D0ECLREPguadecl(a0: guad0eclrep): d0eclrep
fun
d0eclrep_is_D0ECLREPsing(x: d0eclrep): bool
fun
d0eclrep_is_D0ECLREPinclude(x: d0eclrep): bool
fun
d0eclrep_is_D0ECLREPguadecl(x: d0eclrep): bool
//
fun
guad0eclrep_encode(v: guad0eclrep_view): guad0eclrep
fun
guad0eclrep_view(x: guad0eclrep): guad0eclrep_view
fun
guad0eclrep_view_free(v: guad0eclrep_view): void
fun
guad0eclrep_tag(x: guad0eclrep): int
fun
guad0eclrep_GUAD0ECLREPone(a0: d0eclreplst): guad0eclrep
fun
guad0eclrep_GUAD0ECLREPtwo(a0: d0eclreplst, a1: d0eclreplst): guad0eclrep
fun
guad0eclrep_GUAD0ECLREPcons(a0: d0eclreplst, a1: guad0eclrep): guad0eclrep
fun
guad0eclrep_is_GUAD0ECLREPone(x: guad0eclrep): bool
fun
guad0eclrep_is_GUAD0ECLREPtwo(x: guad0eclrep): bool
fun
guad0eclrep_is_GUAD0ECLREPcons(x: guad0eclrep): bool
//
