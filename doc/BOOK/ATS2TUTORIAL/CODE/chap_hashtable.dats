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
// the hashtable is linear (libats/hashtbl_chain)
//
staload "libats/SATS/hashtbl_chain.sats"
//
staload _(*anon*) = "libats/DATS/hashfun.dats"
staload _(*anon*) = "libats/DATS/linmap_list.dats"
staload _(*anon*) = "libats/DATS/qlist.dats"
staload _(*anon*) = "libats/DATS/hashtbl_chain.dats"
//
typedef key = string and itm = int
//
val mymap = hashtbl_make_nil<key,itm>(i2sz(1000))
//
val () =
fprintln! (stdout_ref, "mymap.size = ", hashtbl_get_size(mymap))
val () =
fprintln! (stdout_ref, "mymap.capacity = ", hashtbl_get_capacity(mymap))
//
val-~None_vt() = hashtbl_insert_opt(mymap, "a", 0)
val-~Some_vt(0) = hashtbl_insert_opt(mymap, "a", 1)
//
val-~None_vt() = hashtbl_insert_opt(mymap, "b", 1)
val-~Some_vt(1) = hashtbl_insert_opt(mymap, "b", 2)
//
val-~None_vt() = hashtbl_insert_opt(mymap, "c", 2)
val-~Some_vt(2) = hashtbl_insert_opt(mymap, "c", 3)
//
val () = assertloc (hashtbl_get_size(mymap) = 3)
val () = fprintln! (stdout_ref, "mymap = ", mymap)
//
val-~None_vt() = hashtbl_search_opt(mymap, "")
val-~Some_vt(1) = hashtbl_search_opt(mymap, "a")
//
val-true = hashtbl_remove(mymap, "a")
val-false = hashtbl_remove(mymap, "a")
//
val-~Some_vt(2) = hashtbl_takeout_opt(mymap, "b")
val-~Some_vt(3) = hashtbl_takeout_opt(mymap, "c")
//
val () = assertloc (hashtbl_get_size(mymap) = 0)
//
val () = hashtbl_insert_any(mymap, "a", 0)
val () = hashtbl_insert_any(mymap, "b", 1)
val () = hashtbl_insert_any(mymap, "c", 2)
val kxs = hashtbl_listize1(mymap)
val ((*void*)) = fprintln! (stdout_ref, "kxs = ", kxs)
val ((*void*)) = list_vt_free<(key,itm)>(kxs)
val kxs = hashtbl_takeout_all(mymap)
val ((*void*)) = fprintln! (stdout_ref, "kxs = ", kxs)
val ((*void*)) = list_vt_free<(key,itm)>(kxs)
//
val () = assertloc (hashtbl_get_size(mymap) = 0)
//
val () = hashtbl_insert_any(mymap, "a", 0)
val () = hashtbl_insert_any(mymap, "b", 1)
val () = hashtbl_insert_any(mymap, "c", 2)
//
val () = let
//
implement
hashtbl_foreach$fwork<key,itm><void>
  (k, x, env) = fprintln! (stdout_ref, "k=", k, " and ", "x=", x)
//
in
  hashtbl_foreach<key,itm> (mymap)
end // end of [val]
//
val () = hashtbl_free (mymap)
//
implement main0 () = {}

(* ****** ****** *)

(* end of [chap_hashtable.dats] *)
