(* ****** ****** *)
//
// A port of the ATS3 test
//
//   prelude/TEST/CATS/JS/test05_gdbg000.dats
//
// The ATS3 [gdbg] layer has a [trace] function that wraps a
// function into a function that prints the arguments and the
// result of every call.  In ATS2 the shim provides
// [gdbg_trace] (for a function of one integer argument) and
// [gdbg_trace_str] (for a function of two string arguments).
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

staload "prelude/SATS/integer.sats"
staload "prelude/SATS/string.sats"
staload "prelude/SATS/intrange.sats"

#include "../shim/xats3shim.hats"

(* ****** ****** *)

fun
fact (n: int): int =
  if n > 0 then n * fact (n - 1) else 1

(* ****** ****** *)

fun
strn_append (s1: string, s2: string): string =
  string_append2 (s1, s2)

(* ****** ****** *)

implement
main0 () = {
  val () =
  let
    typedef tenv = void
    implement
    intrange_foreach$fwork<tenv> (i, env) =
    let
      val _ = gdbg_trace (fact, i, "fact")
    in
      ()
    end // end of [let]
    var env: tenv = ()
    val _ = intrange_foreach_env<tenv> (0, 20, env)
  in
    ()
  end // end of [let]
  val _ = gdbg_trace_str (strn_append, "a", "bc", "strn_append")
  val _ = gdbg_trace_str (strn_append, "x", "yz", "strn_append")
} // end of [main0]

(* ****** ****** *)

(* end of [test05_gdbg000.dats] *)
