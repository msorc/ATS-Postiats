(* ****** ****** *)
//
// A web page for computing factorials:
// ATS (high-level) plus JS (low-level)
//
(* ****** ****** *)
//
#define ATS_MAINATSFLAG 1
#define ATS_DYNLOADNAME "Factorial__dynload"
//
(* ****** ****** *)
//
#define
LIBATSCC2JS_targetloc
"$PATSHOME/contrib/libatscc2js"
//
#include "{$LIBATSCC2JS}/mylibies.hats" // for prelude stuff
#staload "{$LIBATSCC2JS}/SATS/print.sats" // for printing into a store
//
(* ****** ****** *)
//
fun
fact(n: int): int =
if n > 0 then n * fact(n-1) else 1
//
(* ****** ****** *)
//
extern
fun
funarg1_get(): int = "mac#"
//
%{^
function funarg1_get()
{
  return parseInt(document.getElementById("funarg1").value);
}
%} (* end of external code *)
//
extern
fun
theOutput_set(text: string): void = "mac#"
//
%{^
function theOutput_set(text)
{
  document.getElementById("theOutput").innerHTML = text;
}
%} (* end of external code *)
//
(* ****** ****** *)
//
extern
fun
Factorial__evaluate
  ((*void*)): void = "mac#"
//
implement
Factorial__evaluate
  ((*void*)) = let
  val () =
  the_print_store_clear()
  val arg = funarg1_get()
  val () =
  println!
  ("The factorial of ", arg, " is ", fact(arg))
  // end of [val]
in
  theOutput_set(the_print_store_join())
end // end of [Factorial__evaluate]
//
(* ****** ****** *)

(* end of [Factorial.dats] *)
