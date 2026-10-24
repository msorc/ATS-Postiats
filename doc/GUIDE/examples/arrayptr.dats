(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(*
** arrayref -> arrayptr: the array is owned and freed explicitly.
*)
#include "share/atspre_staload.hats"
//
implement main0 () = {
  val A = arrayptr_make_elt<int> (i2sz(5), 0)
  val () = A[1] := 10
  val () = A[3] := 30
  val () = println! ("A[1]+A[3] = ", A[1] + A[3])
  val () = arrayptr_free (A)
}
