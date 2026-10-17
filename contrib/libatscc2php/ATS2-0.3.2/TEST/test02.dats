(* ****** ****** *)
//
// For testing libatscc2php
//
(* ****** ****** *)
//
#define
ATS_MAINATSFLAG 1
#define
ATS_STATIC_PREFIX "_test02_"
#define
ATS_DYNLOADNAME "test02_dynload"
//
(* ****** ****** *)

#define :: list_cons

(* ****** ****** *)
//
#include "./../staloadall.hats"
//
(* ****** ****** *)

%{$
test02_dynload();
%} (* end of [%{$] *)

(* ****** ****** *)

%{^
include "./../output/libatscc2php_all.php";
%} (* end of [%{^] *)

(* ****** ****** *)

(* ****** ****** *)
//
// HX-2026-10: no GC (linear lists)
//
#define :: list_vt_cons
//
fun
mklist
(
// argless
) : List0_vt(int) =
(
  0 :: 1 :: 2 :: 3 :: 4 :: 5 :: 6 :: 7 :: 8 :: 9 :: list_vt_nil()
)
//
fun
print_intlist
  (xs: !List0_vt(int)): void = let
//
fun
loop
(
  xs: !List0_vt(int), i: int
) : void =
(
case+ xs of
| list_vt_nil() => ()
| list_vt_cons(x, xs1) =>
  (if i > 0 then print(", "); print(x); loop(xs1, i+1))
)
//
in
  print("("); loop(xs, 0); print(")")
end // end of [print_intlist]
//
(* ****** ****** *)
//
val xs = mklist()
val () = print("xs = ")
val () = print_intlist(xs)
val () = print_newline()
//
val xs = xs + mklist()
val () = print("xs + xs = ")
val () = print_intlist(xs)
val () = print_newline()
val () = list_vt_free(xs)
//
(* ****** ****** *)

(* end of [test02.dats] *)
