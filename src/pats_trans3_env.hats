(* ****** ****** *)
//
// HX-2026-10: no GC. Helpers shared by pats_trans3_env*.dats (see PORTING.md, "Type-checking environment (trans3_env)")
// The state of the environment lives in cells of the global arena (never freed); a stack is an immutable [glist]
// that the cell replaces. Needs [staload "libats/SATS/arena.sats"] and [staload UN = "prelude/SATS/unsafe.sats"].
//
(* ****** ****** *)

fun{a:t@ype}
gcell_make (x: a): ptr = let
  val p = the_garena_alloc (sizeof<a>)
  val () = $UN.ptr0_set<a> (p, x)
in
  p
end // end of [gcell_make]

fun{a:t@ype}
gcell_get (p: ptr): a = $UN.ptr0_get<a> (p)
fun{a:t@ype}
gcell_set (p: ptr, x: a): void = $UN.ptr0_set<a> (p, x)

(* ****** ****** *)
//
#define l2l glist_make_list_vt
//
(* ****** ****** *)

(* end of [pats_trans3_env.hats] *)
