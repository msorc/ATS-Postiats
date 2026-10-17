(* ****** ****** *)
//
// Some common list-functions
//
(* ****** ****** *)
//
// Author: Hongwei Xi
// Authoremail: gmhwxi AT gmail DOT com
// Start time: June, 2013
// 
(* ****** ****** *)
//
// HX-2013-06-19:
// For the first time, the ATS2 compiler (ATS/Postiats)
// is able to properly handle case-expressions, generating
// *highly* optimized code. Voila!
//
(* ****** ****** *)
//
#include "share/atspre_staload.hats"
//
(* ****** ****** *)

//
// HX-2026-10: no GC
// the lists are linear: they are only borrowed
// by [length] and [zip] and freed at the end
//
fun fromto
  (l: int, r: int): List0_vt (int) =
(
  if l < r
    then list_vt_cons{int}(l, fromto (l+1, r)) else list_vt_nil ()
  // end of [if]
) // end of [fromto]

(* ****** ****** *)

fun{a:t0p}
length (xs: !List0_vt (INV(a))): int =
(
case+ xs of
| list_vt_cons (_, xs) => 1 + length (xs) | list_vt_nil () => 0
) // end of [length]

(* ****** ****** *)

fun zip{n:int}
(
  xs: !list_vt (int, n)
, ys: !list_vt (int, n)
) : list_vt (@(int, int), n) = let
in
//
case+ xs of
| list_vt_cons (x, xs1) =>
  (
    case+ ys of
    | list_vt_cons (y, ys1) =>
        list_vt_cons{@(int,int)}(@(x, y), zip (xs1, ys1))
      // end of [list_vt_cons]
  )
| list_vt_nil () => list_vt_nil ()
//
end // end of [zip]

(* ****** ****** *)

implement
main0 () =
{
//
#define N 10
//
val out = stdout_ref
val xs = fromto (0, N)
val () = assertloc (length (xs) = N)
//
// HX: [xs] cannot be borrowed twice at once
//
val xs2 = list_vt_copy (xs)
val xxs = zip (xs, xs2)
val () = assertloc (length (xxs) = N)
//
val () = list_vt_free (xs)
val () = list_vt_free (xs2)
val () = list_vt_free (xxs)
//
} // end of [main0]

(* ****** ****** *)

(* end of [listfuns.dats] *)
