#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "contrib/afiber/SATS/afiber.sats"
staload _ = "contrib/afiber/DATS/afiber.dats"

var the_id: lint = 0L
val the_id_ref = ref_make_viewptr{lint}(view@ the_id | addr@ the_id)
var the_flag: int = 0
val the_flag_ref = ref_make_viewptr{int}(view@ the_flag | addr@ the_flag)

fun body1 (): void = let
  val () = afiber_yield ()
  val () = assertloc (~afiber_is_main ())
  val () = the_id_ref[] := afiber_self ()
in end

fun body2 (): void = let
  val () = afiber_yield ()
  val () = the_flag_ref[] := 1
in end

fun wait_done (fb: !afiber_vt, n: int): void =
  if afiber_is_done (fb) then ()
  else if n <= 0 then assertloc (false)
  else (afiber_yield (); wait_done (fb, n-1))

implement main0 () = {
  val () = assertloc (afiber_is_main ())
  val () = assertloc (afiber_nlive () = 0L)
  val f1 = afiber_spawn (llam () => body1 ())
  val () = assertloc (afiber_nlive () = 1L)
  val () = assertloc (~afiber_is_done (f1))
  val id1 = afiber_get_id (f1)
  val () = assertloc (id1 != 0L)
  val () = wait_done (f1, 100)
  val () = assertloc (afiber_nlive () = 0L)
  val () = afiber_join (f1)
  val () = assertloc (the_id_ref[] = id1)
  val f2 = afiber_spawn (llam () => body2 ())
  val () = assertloc (afiber_nlive () = 1L)
  val () = afiber_detach (f2)
  val () = afiber_run_until_done ()
  val () = assertloc (afiber_nlive () = 0L)
  val () = assertloc (the_flag_ref[] = 1)
  val () = assertloc (afiber_is_main ())
  val () = println! ("POS_join: passed")
}
