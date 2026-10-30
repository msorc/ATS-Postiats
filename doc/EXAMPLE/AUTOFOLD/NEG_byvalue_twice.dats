(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(*
** HX-2026-10: fold on demand: a mutable variable that is folded because
** it is passed by value is consumed by the call; passing it again is an
** error (the folded value is not put back into the variable)
*)
#include "share/atspre_staload.hats"
//
fun
twice
  {n:nat}
  (xs: &list_vt (int, n) >> list_vt (int, 0)): void =
(
  case+ xs of
  | @list_vt_cons (_, _) => let
      val () = list_vt_free<int> (xs) // the fold is implied
      val () = list_vt_free<int> (xs) // error: [xs] is consumed
    in
      xs := list_vt_nil ()
    end // end of [@list_vt_cons]
  | @list_vt_nil () => fold@ (xs)
) (* end of [twice] *)
//
implement main0 () = ()
