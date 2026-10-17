(* ****** ****** *)
//
// For testing libatscc2scm
//
(* ****** ****** *)
//
#define
ATS_MAINATSFLAG 1
#define
ATS_DYNLOADNAME "test02_dynload"
//
#define ATS_STATIC_PREFIX "_test02_"
//
(* ****** ****** *)
//
#include
"./../staloadall.hats"
//
(* ****** ****** *)

#define :: list_vt_cons

(* ****** ****** *)
//
// HX-2026-10: no GC (linear lists)
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
(* ****** ****** *)
//
implement
gprint_string<>(x) = print_string(x)
implement
gprint_newline<>() = print_newline()
//
val xs = mklist()
val () = print("xs = ")
val () = gprint_list<int>(xs)
val () = gprint_newline()
//
val xs = xs + mklist()
val () = print("xs + xs = ")
val () = gprint_list<int>(xs)
val () = gprint_newline()
val () = list_vt_free(xs)
//

(* ****** ****** *)


%{^
######
from libatscc2py3_all import *
######
sys.setrecursionlimit(1000000)
%} (* end of [%{^] *)

(* ****** ****** *)

%{$
if __name__=='__main__': test02_dynload()
//
%} (* end of [%{$] *)

(* ****** ****** *)

(* end of [test02.dats] *)
