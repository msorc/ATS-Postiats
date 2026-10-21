(* ****** ****** *)
//
// A port of the ATS3 test
//
//   prelude/TEST/CATS/JS/test02_a1rf000.dats
//
// ATS3's [array(n, f)] is an array of [n] elements, the [i]-th
// one being [f(i)].  In ATS2 an array is an [arrayptr], whose
// size is a static argument; [arrayptr_make_elt] fills an array
// with a single value and [arrayptr_make_intrange] fills it with
// a range of integers.
//
// The product of the elements of an array (the ATS3
// [GSEQ(xs).prod()]) is computed here with [intrange_foreach_env],
// which is the ATS2 way of folding over a range.
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

staload "prelude/SATS/integer.sats"
staload "prelude/SATS/list_vt.sats"
staload "prelude/SATS/arrayptr.sats"
staload "prelude/SATS/intrange.sats"

(* ****** ****** *)
//
// [fact]: the product of the elements 1, 2, ..., n.
//
fun
fact (n: int): int =
let
  typedef tenv = int
  implement
  intrange_foreach$fwork<tenv> (i, env) = env := env * (i + 1)
  var env: tenv = 1
  val _ = intrange_foreach_env<tenv> (0, n, env)
in
  env
end // end of [fact]

(* ****** ****** *)

implement
main0 () = {
  val sz0 = size_of_int (10)
  val A0 = arrayptr_make_elt<int> (sz0, 1)
  val () = fprint_arrayptr (stdout_ref, A0, sz0)
  val () = println! ()
  val N = 10
  val sz1 = size_of_int (N)
  val A1 = arrayptr_make_elt<int> (sz1, 0)
  val () =
  let
    typedef tenv = size_t
    implement
    array_iforeach$fwork<int><tenv> (i, x, env) = x := g0uint2int_size_int (i) + 1
    var env: tenv = i2sz (0)
    val _ = arrayptr_iforeach_env<int><tenv> (A1, sz1, env)
  in
    ()
  end // end of [let]
  val () = fprint_arrayptr (stdout_ref, A1, sz1)
  val () = println! ()
  val () = println! ("fact(10) = ", fact (10))
  val () = arrayptr_free (A0)
  val () = arrayptr_free (A1)
} // end of [main0]

(* ****** ****** *)

(* end of [test02_a1rf000.dats] *)
