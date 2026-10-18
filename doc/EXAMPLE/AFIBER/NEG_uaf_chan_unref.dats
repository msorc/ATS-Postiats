(* HX-2026-10: using a channel after [chan_unref] must be rejected *)
#include "share/atspre_staload.hats"
staload "libats/SATS/afiber.sats"
staload _ = "libats/DATS/afiber.dats"
staload "libats/SATS/afiberchan.sats"
staload _ = "libats/DATS/afiberchan.dats"

implement main0 () = {
  val ch = chan_make<int> (1)
  val () = chan_unref_type<int> (ch)
  val () = chan_send<int> (ch, 1)
}
