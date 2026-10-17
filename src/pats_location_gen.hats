abstype
locpragma_type = ptr
typedef
locpragma = locpragma_type

abstype
location_type = ptr
typedef
location = location_type

//
datavtype
locpragma_view =
  | LOCPRAGMA0 of ()
  | LOCPRAGMA1 of (string)
  | LOCPRAGMA2 of (string, string)
and
location_view =
  | LOCATION of (filename, lint, int, int, lint, int, int, locpragma)
//
fun
locpragma_encode(v: locpragma_view): locpragma
fun
locpragma_view(x: locpragma): locpragma_view
fun
locpragma_view_free(v: locpragma_view): void
fun
locpragma_tag(x: locpragma): int
fun
locpragma_LOCPRAGMA0(): locpragma
fun
locpragma_LOCPRAGMA1(a0: string): locpragma
fun
locpragma_LOCPRAGMA2(a0: string, a1: string): locpragma
fun
locpragma_is_LOCPRAGMA0(x: locpragma): bool
fun
locpragma_is_LOCPRAGMA1(x: locpragma): bool
fun
locpragma_is_LOCPRAGMA2(x: locpragma): bool
//
fun
location_encode(v: location_view): location
fun
location_view(x: location): location_view
fun
location_view_free(v: location_view): void
fun
location_tag(x: location): int
fun
location_LOCATION(a0: filename, a1: lint, a2: int, a3: int, a4: lint, a5: int, a6: int, a7: locpragma): location
fun
location_get_filename(x: location): filename
overload .filename with location_get_filename
fun
location_get_beg_ntot(x: location): lint
overload .beg_ntot with location_get_beg_ntot
fun
location_get_beg_nrow(x: location): int
overload .beg_nrow with location_get_beg_nrow
fun
location_get_beg_ncol(x: location): int
overload .beg_ncol with location_get_beg_ncol
fun
location_get_end_ntot(x: location): lint
overload .end_ntot with location_get_end_ntot
fun
location_get_end_nrow(x: location): int
overload .end_nrow with location_get_end_nrow
fun
location_get_end_ncol(x: location): int
overload .end_ncol with location_get_end_ncol
fun
location_get_locpragma(x: location): locpragma
overload .locpragma with location_get_locpragma
//
