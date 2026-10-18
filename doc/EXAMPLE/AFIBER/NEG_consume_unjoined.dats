#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "libats/SATS/afiber.sats"
staload _ = "libats/DATS/afiber.dats"

implement main0 () = {
  val fb = afiber_spawn (llam () => ())
}
