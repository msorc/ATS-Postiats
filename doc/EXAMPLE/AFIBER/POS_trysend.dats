(* HX-2026-10: afiberchan try operations and close, single fiber *)
#include "share/atspre_staload.hats"
staload "libats/SATS/afiber.sats"
staload _ = "libats/DATS/afiber.dats"
staload "libats/SATS/afiberchan.sats"
staload _ = "libats/DATS/afiberchan.dats"

implement main0 () = {
  val ch = chan_make<int> (2)
  val () = assertloc (chan_capacity (ch) = 2)
  val () = assertloc (~chan_is_closed (ch))
  val-~None_vt() = chan_tryrecv<int> (ch)
  val-~None_vt() = chan_trysend<int> (ch, 10)
  val-~None_vt() = chan_trysend<int> (ch, 20)
  val () = assertloc (chan_size<int> (ch) = 2)
  val-~Some_vt(x) = chan_trysend<int> (ch, 30)
  val () = assertloc (x = 30)
  val-~Some_vt(a) = chan_tryrecv<int> (ch)
  val () = assertloc (a = 10)
  val-~Some_vt(b) = chan_tryrecv<int> (ch)
  val () = assertloc (b = 20)
  val-~None_vt() = chan_tryrecv<int> (ch)
  val () = assertloc (chan_size<int> (ch) = 0)
  val-~None_vt() = chan_send_opt<int> (ch, 5)
  val () = chan_close (ch)
  val () = chan_close (ch)
  val () = assertloc (chan_is_closed (ch))
  val-~Some_vt(y) = chan_send_opt<int> (ch, 7)
  val () = assertloc (y = 7)
  val-~Some_vt(z) = chan_trysend<int> (ch, 8)
  val () = assertloc (z = 8)
  val-~Some_vt(w) = chan_recv<int> (ch) // buffered item 5 drains first
  val () = assertloc (w = 5)
  val-~None_vt() = chan_recv<int> (ch)
  val () = chan_unref_type<int> (ch)
  val () = println! ("POS_trysend: passed")
}
