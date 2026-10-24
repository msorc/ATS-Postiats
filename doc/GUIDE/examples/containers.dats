(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(*
** libats/ML (HashTable, list0, ...) -> the linear containers of
** libats: a map is updated in place and freed at the end.
*)
#include "share/atspre_staload.hats"
staload "libats/SATS/linmap_avltree.sats"
staload _ = "libats/DATS/qlist.dats"
staload _ = "libats/DATS/linmap_avltree.dats"
//
implement compare_key_key<string> (x, y) = compare (x, y)
//
implement main0 () = {
  var m: map(string, int) = linmap_make_nil{string,int}()
  val-~None_vt() = linmap_insert_opt (m, "one", 1)
  val-~None_vt() = linmap_insert_opt (m, "two", 2)
  val () = println! ("size = ", linmap_size (m))
  val-~Some_vt(v) = linmap_search_opt (m, "two")
  val () = println! ("two -> ", v)
  val () = linmap_free (m)
}
