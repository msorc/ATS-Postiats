(*
** For ATS2TUTORIAL
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)
//
// HX-2026-10: no GC
// the sets are linear (libats/linset_avltree):
// a set is updated in place and it must be freed
//
staload "libats/SATS/linset_avltree.sats"
//
staload _(*anon*) = "libats/DATS/qlist.dats"
staload _(*anon*) = "libats/DATS/linset_avltree.dats"
//
typedef elt = int
//
implement
compare_elt_elt<elt>(x, y) = compare(x, y)
//
(* ****** ****** *)

implement
main0 () = {
//
var myset: set(elt) = linset_make_nil{elt}()
//
val-false = linset_insert(myset, 0) // inserted
val-(true) = linset_insert(myset, 0) // not actually inserted
val-false = linset_insert(myset, 1) // inserted
val-(true) = linset_insert(myset, 1) // not actually inserted
//
val () = assertloc (linset_size(myset) = 2)
val () = fprintln! (stdout_ref, "myset = ", myset)
//
val-true = linset_remove(myset, 0) // removed
val-false = linset_remove(myset, 0) // not actually removed
val-true = linset_remove(myset, 1) // removed
val-false = linset_remove(myset, 1) // not actually removed
//
val () = assertloc (linset_size(myset) = 0)
//
val-false = linset_insert(myset, 3)
val-false = linset_insert(myset, 1)
val-false = linset_insert(myset, 2)
//
val () = let
  implement
  linset_foreach$fwork<elt><void>(x, env) = println! ("x = ", x)
in
  linset_foreach<elt>(myset)
end // end of [val]
//
val xs = linset_listize(myset) // [myset] is consumed
val () = println! ("xs = ", xs)
val () = list_vt_free<elt>(xs)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [chap_funsetmap_set.dats] *)
