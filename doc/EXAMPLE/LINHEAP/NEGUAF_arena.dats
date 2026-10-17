(*
** HX-2026-10: no GC
** a handle into an arena cannot be used once
** the arena is freed (the arena is consumed)
*)
#include "share/atspre_staload.hats"
staload "libats/SATS/arena.sats"
staload _ = "libats/DATS/arena.dats"
implement main0 () = {
  val ar = arena_make_nil()
  val s = astring_make(ar, "hello")
  val () = arena_free(ar)
  val () = astring_fprint(ar, stdout_ref, s)
}
