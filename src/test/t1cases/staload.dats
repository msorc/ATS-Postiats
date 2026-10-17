(* staload, dynload, include, require *)
staload "./staload_a.sats"
staload A = "./staload_a.sats"
staload B = "./staload_b.sats"
staload _ = "./staload_c.dats"
staload "./staload_a.sats"
staload X = "./nonexistent_file.sats"
#staload "./staload_a.sats"
#include "./staload_inc.hats"
#include "./staload_inc.hats"
dynload "./staload_c.dats"
#dynload "./staload_c.dats"
#require "./staload_a.sats"
staload "{$PATSHOME}/prelude/SATS/integer.sats"
staload "$PATSHOME/prelude/SATS/bool.sats"
staload "prelude/SATS/char.sats"
staload UN = "prelude/SATS/unsafe.sats"
staload _ = "prelude/DATS/unsafe.dats"
local
  staload "./staload_b.sats"
in
  val y = b_foo
end
val z = A_DEF
dynload "./nonexistent_dyn.dats"
#include "./nonexistent_inc.hats"
