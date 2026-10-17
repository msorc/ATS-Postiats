(*
** a boxed record
*)
#include "share/atspre_staload.hats"
implement main0 () = { val r = '{a=1, b=2} val () = println! (r.a) }
