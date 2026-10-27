(* the fold on demand fails: a field view is consumed *)
#include "share/atspre_staload.hats"
extern prfun consume_view {a:t@ype}{l:addr} (pf: a @ l): void
fun f {n:pos} (xs: !list_vt(int, n)): void =
  case+ xs of
  | @list_vt_cons (x, _) => consume_view (view@ x)
