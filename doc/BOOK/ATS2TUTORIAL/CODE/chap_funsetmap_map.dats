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
// the maps are linear (libats/linmap_avltree):
// a map is updated in place and it must be freed
//
staload "libats/SATS/linmap_avltree.sats"
//
staload _(*anon*) = "libats/DATS/qlist.dats"
staload _(*anon*) = "libats/DATS/linmap_avltree.dats"
//
typedef key = string and itm = int
//
implement
compare_key_key<key>(x, y) = compare(x, y)
//
(* ****** ****** *)

implement
main0 () = {
//
var mymap: map(key, itm) = linmap_make_nil{key,itm}()
//
val-~None_vt() = linmap_insert_opt(mymap, "a", 0)
val-~Some_vt(0) = linmap_insert_opt(mymap, "a", 1)
//
val-~None_vt() = linmap_insert_opt(mymap, "b", 1)
val-~Some_vt(1) = linmap_insert_opt(mymap, "b", 2)
//
val-~None_vt() = linmap_insert_opt(mymap, "c", 2)
val-~Some_vt(2) = linmap_insert_opt(mymap, "c", 3)
//
val () = assertloc (linmap_size(mymap) = 3)
val () = fprintln! (stdout_ref, "mymap = ", mymap)
//
val-~None_vt() = linmap_search_opt(mymap, "")
val-~Some_vt(1) = linmap_search_opt(mymap, "a")
//
val-true = linmap_remove(mymap, "a")
val-false = linmap_remove(mymap, "a")
//
val-~Some_vt(2) = linmap_takeout_opt(mymap, "b")
val-~Some_vt(3) = linmap_takeout_opt(mymap, "c")
//
val () = assertloc (linmap_size(mymap) = 0)
//
val-~None_vt() = linmap_insert_opt(mymap, "x", 10)
val-~None_vt() = linmap_insert_opt(mymap, "y", 20)
//
val () = let
  implement
  linmap_foreach$fwork<key,itm><void>
    (k, x, env) = println! ("k=", k, " and ", "x=", x)
in
  linmap_foreach<key,itm>(mymap)
end // end of [val]
//
val () = linmap_free(mymap)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [chap_funsetmap_map.dats] *)
