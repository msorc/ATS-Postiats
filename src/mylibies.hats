(*
** HX-2026-10:
** Include this file (#include "./mylibies.hats") in a driver that
** instantiates the templates of the ported modules: the implementations
** of all the templates used (transitively!) must be in scope at the point
** of instantiation, so a .dats file that is only linked is not enough.
*)
//
staload _ = "libats/DATS/arena.dats"
//
staload _ = "libats/DATS/qlist.dats"
staload _ = "libats/DATS/linmap_avltree.dats"
staload _ = "libats/DATS/linset_avltree.dats"
staload _ = "libats/DATS/hashtbl_linprb.dats"
staload _ = "libats/DATS/hashfun.dats"
//
