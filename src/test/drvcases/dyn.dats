#include "share/atspre_staload.hats"
staload "./a.sats"
implement foo (x) = x + 1
implement main0 () = println! (foo(1))
