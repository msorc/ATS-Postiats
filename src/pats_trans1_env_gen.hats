abstype
atsrelocitm_type = ptr
typedef
atsrelocitm = atsrelocitm_type

//
datavtype
atsrelocitm_view =
  | ATSRELOCITM of (d0ecl, string)
  | ATSRELOCITM2 of (d0ecl, string, string)
//
fun
atsrelocitm_encode(v: atsrelocitm_view): atsrelocitm
fun
atsrelocitm_view(x: atsrelocitm): atsrelocitm_view
fun
atsrelocitm_view_free(v: atsrelocitm_view): void
fun
atsrelocitm_tag(x: atsrelocitm): int
fun
atsrelocitm_ATSRELOCITM(a0: d0ecl, a1: string): atsrelocitm
fun
atsrelocitm_ATSRELOCITM2(a0: d0ecl, a1: string, a2: string): atsrelocitm
fun
atsrelocitm_is_ATSRELOCITM(x: atsrelocitm): bool
fun
atsrelocitm_is_ATSRELOCITM2(x: atsrelocitm): bool
//
