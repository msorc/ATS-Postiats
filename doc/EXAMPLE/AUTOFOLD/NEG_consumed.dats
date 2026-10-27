(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(*
** HX-2026-10: fold on demand
** The view of a field is consumed before the end of the clause:
** [xs] cannot be folded (rejected, with a hint).
*)
#include "share/atspre_staload.hats"
//
extern
prfun
consume_view {a:t@ype}{l:addr} (pf: a @ l): void
//
fun
drop_head
  {n:pos}
  (xs: !list_vt (int, n)): void =
(
  case+ xs of
  | @list_vt_cons (x, _) => let
      prval () = consume_view (view@ x)
    in
      // nothing
    end // end of [list_vt_cons]
)
//
implement
main0 () = ()
//
(* end of [NEG_consumed.dats] *)
