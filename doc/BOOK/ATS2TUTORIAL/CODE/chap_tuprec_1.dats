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
// boxed tuples and records are no longer supported
// (they could never be freed); flat ones are shown here
//
typedef
abc_tup = @(int, int, string) // for tuples
typedef
abc_rec = @{a=int, b=int, c=string} // for records
//
var x_tup = @(0, 1, "2") : abc_tup
var x_rec = @{a=0, b=1, c="2"} : abc_rec
//
val () = assertloc(x_tup.0 = x_rec.a)
val () = assertloc(x_tup.1 = x_rec.b)
val () = assertloc(x_tup.2 = x_rec.c)
//
val () = x_tup.0 := 100 // *OKAY*: x_tup.0 is a left-value
val () = x_rec.a := 100 // *OKAY*: x_rec.a is a left-value
//
val () = assertloc(x_tup.0 = x_rec.a)
//
(* ****** ****** *)
//
absvtype myrec = ptr  
//
extern
fun{}
myrec_make
(
  a: int, b: int, c: string
) : myrec // end-of-function
//
extern
fun{}
myrec_free : myrec -> void
//
extern
fun{}
myrec_get_a : (!myrec) -> int
extern
fun{}
myrec_set_a : (!myrec, int) -> void
extern
fun{}
myrec_get_b : (!myrec) -> int
extern
fun{}
myrec_set_b : (!myrec, int) -> void
extern
fun{}
myrec_get_c : (!myrec) -> string
//
overload .a with myrec_get_a
overload .a with myrec_set_a
overload .b with myrec_get_b
overload .b with myrec_set_b
overload .c with myrec_get_c
//
local
//
datavtype
myrec_rep = MYREC of (int, int, string)
//
assume myrec = myrec_rep
//
in (* in-of-local *)
//
implement
{}(*tmp*)
myrec_make
  (a, b, c) = MYREC(a, b, c)
implement
{}(*tmp*)
myrec_free
  (x) = let val~MYREC(_, _, _) = x in (*none*) end
//
implement{} myrec_get_a(x) = let val+MYREC(a, _, _) = x in a end
implement{} myrec_set_a(x, a) =
  let val+@MYREC(a0, _, _) = x in a0 := a; fold@(x) end
//
implement{} myrec_get_b(x) = let val+MYREC(_, b, _) = x in b end
implement{} myrec_set_b(x, b) =
  let val+@MYREC(_, b0, _) = x in b0 := b; fold@(x) end
//
implement{} myrec_get_c(x) = let val+MYREC(_, _, c) = x in c end
// there is no update for the c-field
//
end // end of [local]
//
val x_abc = myrec_make(0, 1, "2")
//
val ((*void*)) = assertloc(x_abc.a() = 0)
val ((*void*)) = assertloc(x_abc.b() = 1)
val ((*void*)) = assertloc(x_abc.c() = "2")
//
val ((*void*)) = x_abc.a(100)
val ((*void*)) = assertloc(x_abc.a() = 100)
//
val ((*void*)) = x_abc.b(101)
val ((*void*)) = assertloc(x_abc.b() = 101)
//
val ((*void*)) = myrec_free(x_abc)
//
implement main0 () = {}

(* ****** ****** *)

(* end of [chap_tuprec_1.dats] *)
