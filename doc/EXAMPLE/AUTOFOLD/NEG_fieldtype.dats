(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(*
** HX-2026-10: fold on demand
** A field is given a value of a type that the constructor does not accept:
** [xs] cannot be folded (rejected, with a hint).
*)
#include "share/atspre_staload.hats"
//
fun
spoil_tail
  {n:pos}
  (xs: list_vt (int, n)): List0_vt (int) =
(
  case+ xs of
  | @list_vt_cons (_, xs1) => let
      val () = list_vt_free (xs1)
      val () = xs1 := 0
    in
      xs
    end // end of [list_vt_cons]
)
//
implement
main0 () = ()
//
(* end of [NEG_fieldtype.dats] *)
