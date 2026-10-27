(* ****** ****** *)
//
// Statically allocated reference
//
// Author: Hongwei Xi (June, 2013)
//
(* ****** ****** *)
//
#include "share/atspre_staload.hats"
//
(* ****** ****** *)

local
//
// HX-2026-10: no GC
// the view of the statically allocated variable
// is stored in a box (instead of a reference)
//
var _count_: int = 0 // it is statically allocated
prval pfbox = vbox_make_view{int @ _count_}(view@(_count_))
//
in (* in of [local] *)

fun
theCount_get
  (): int = let
  prval vbox(pf) = pfbox
in
  $effmask_ref(ptr_get<int>(addr@(_count_)))
end // end of [theCount_get]

fun
theCount_inc
  (): void = let
  prval vbox(pf) = pfbox
  val n = $effmask_ref(ptr_get<int>(addr@(_count_)))
in
  $effmask_ref(ptr_set<int>(addr@(_count_), n + 1))
end // end of [theCount_inc]

fun
theCount_getinc
  (): int = let
  prval vbox(pf) = pfbox
  val n = $effmask_ref(ptr_get<int>(addr@(_count_)))
  val () = $effmask_ref(ptr_set<int>(addr@(_count_), n + 1))
in
  (n)
end // end of [theCount_getinc]

fun
theCount_reset
  (): void = let
  prval vbox(pf) = pfbox
in
  $effmask_ref(ptr_set<int>(addr@(_count_), 0))
end // end of [theCount_reset]

end // end of [local]

(* ****** ****** *)

implement
main0 () =
{
//
val () = assertloc (theCount_getinc () = 0)
val () = assertloc (theCount_getinc () = 1)
val () = assertloc (theCount_getinc () = 2)
//
} // end of [main0]

(* ****** ****** *)

(* end of [staref.dats] *)
