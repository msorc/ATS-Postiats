(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(*
** HX-2026-10: fold on demand (the demand points of the round 2)
** A value that is passed by value (to an unsafe cast whose type is a
** template parameter) and a mutable variable that is passed as an
** argument (by reference or by value) are folded by the checker: the
** fold@ that preceded those calls is not written any more.
*)
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
//
// ****** ****** *)
//
// a value that is passed by value to an unsafe cast: the type of the
// argument is a template parameter, so the value is consumed and the
// checker folds it (no fold@ before the cast)
//
fun
byvalue
  (xs: list_vt (int, 1)): int = let
  val+@list_vt_cons (x, _) = xs
  val x = x
  // the fold of [xs] is implied: the cast consumes it
  val xs = $UN.castvwtp0{list_vt(int, 1)}(xs)
  val () = list_vt_free<int> (xs)
in
  x
end // end of [byvalue]
//
// ****** ****** *)
//
// a mutable variable that is passed by reference: the callee uses the
// value, so the checker folds it (no fold@ before the call)
//
fun
takes_ref
  {n:nat}
  (xs: &list_vt (int, n)): int =
  list_vt_length<int> (xs)
//
fun
byref
  {n:nat}
  (xs: &list_vt (int, n)): int =
(
  case+ xs of
  | @list_vt_cons (_, _) => takes_ref (xs) // the fold of [xs] is implied
  | list_vt_nil () => 0
) (* end of [byref] *)
//
// ****** ****** *)
//
// a mutable variable that is passed by value: the callee consumes the
// value, so the checker folds it (no fold@ before the call), and the
// variable is then uninitialized (the folded value is not put back)
//
fun
byvalue_mut
  {n:nat}
  (xs: &list_vt (int, n) >> list_vt (int, 0)): int =
(
  case+ xs of
  | @list_vt_cons (_, _) => let
      val n = list_vt_length<int> (xs) // by reference
      val () = list_vt_free<int> (xs) // by value: the fold is implied
      val () = xs := list_vt_nil ()
    in
      n
    end // end of [@list_vt_cons]
  | @list_vt_nil () => (fold@ (xs); 0)
) (* end of [byvalue_mut] *)
//
// ****** ****** *)
//
implement
main0 () = {
//
val xs1 = list_vt_cons (1, list_vt_nil ())
val () = assertloc (byvalue (xs1) = 1)
val () = println! ("byvalue: ok")
var xs2 = list_vt_cons (1, list_vt_nil ())
val () = assertloc (byref (xs2) = 1)
val () = println! ("byref: ok")
val () = assertloc (byvalue_mut (xs2) = 1)
val () = println! ("byvalue_mut: ok")
val () = list_vt_free (xs2)
//
} (* end of [main0] *)

(* end of [POS_byvalue.dats] *)
