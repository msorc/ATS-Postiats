(*
** For ATS2TUTORIAL
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)
//
// HX-2026-10: no GC
// a reference can only be made from memory that is never
// freed (here, a toplevel variable); there is no function
// for allocating a reference on heap
//
(* ****** ****** *)

local
//
var theCount: int = 0
//
val count = ref_make_viewptr{int} (view@(theCount) | addr@(theCount))
//
in (* in of [local] *)

fun genNewName
  (prfx: string): Strptr0 = let
  val n = !count
  val () = !count := n + 1
  val s1 = string0_copy(prfx)
  val s2 = tostrptr_int(n)
  val res = strptr_append(s1, s2)
  val () = strptr_free(s1)
  val () = strptr_free(s2)
in
  res
end // end of [genNewName]

end // end of [local]

(* ****** ****** *)
//
// the C code (the loop is a while-loop)
// [int fact(int n) { int res = 1 ; while (n > 0) { res = n * res; n = n - 1; } ; return (res) ; }]
// is not a reason to use a reference
//
fun fact
  (n: int): int = let
  fun loop (n: int, res: &int >> _): void =
    if n > 0 then (res := n * res; loop(n-1, res)) else ()
  var res: int = 1
  val () = loop (n, res)
in
  res
end // end of [fact]

fun fact2
  (n: int): int = let
  fun loop (n: int, res: int): int =
    if n > 0 then loop (n-1, n * res) else res
  // end of [loop]
in
  loop (n, 1)
end // end of [fact2]

(* ****** ****** *)

var myvar: int = 0
val myref = ref_make_viewptr{int} (view@(myvar) | addr@(myvar))

(* ****** ****** *)

implement
main0 () = {
//
val s1 = genNewName("x")
val s2 = genNewName("x")
val () = println! (s1, " ", s2)
val () = strptr_free(s1)
val () = strptr_free(s2)
//
val () = println! ("fact(10) = ", fact(10))
val () = println! ("fact2(10) = ", fact2(10))
//
val () = myref[] := 1
val () = !myref := !myref + 1
val () = println! ("!myref = ", !myref)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [chap_reference.dats] *)
