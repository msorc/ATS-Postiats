(* ****** ****** *)
//
// For testing libatscc2clj
//
(* ****** ****** *)
//
#define
ATS_MAINATSFLAG 1
#define
ATS_DYNLOADNAME "test01_dynload"
//
#define ATS_STATIC_PREFIX "_test01_"
//
(* ****** ****** *)
//
#include "./../staloadall.hats"
//
(* ****** ****** *)
//
// HX-2026-10: no GC (linear closures)
//
val () =
repeat(3, lam() =<cloptr1> println!("Hello, world!"))
//
val () =
int_foreach_cloptr(3, lam(i) =<cloptr1> println!(i, ": Hello, world!"))
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
if __name__=='__main__': test01_dynload()
//
%} (* end of [%{$] *)

(* ****** ****** *)

(* end of [test01.dats] *)
