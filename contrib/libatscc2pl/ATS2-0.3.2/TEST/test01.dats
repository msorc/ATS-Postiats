(* ****** ****** *)
//
// For testing libatscc2pl
//
(* ****** ****** *)
//
#include "./../staloadall.hats"
//
(* ****** ****** *)
//
#define
ATS_MAINATSFLAG 1
#define
ATS_DYNLOADNAME "test01_dynload"
//
#define ATS_STATIC_PREFIX "_test01__"
//
(* ****** ****** *)
//
//
// HX-2026-10: no GC (linear closures)
//
val () =
repeat(3, lam() =<cloptr1> println!("Hello, world!"))
val () =
int_foreach_cloptr(3, lam(i) =<cloptr1> println!(i, ": Hello, world!"))
//
(* ****** ****** *)

%{$
######
test01_dynload();
######
%} // end of [%{$]

(* ****** ****** *)

%{^
#######
require "./../output/libatscc2pl_all.pl";
#######
%} (* end of [%{^] *)

(* ****** ****** *)

(* end of [test01.dats] *)
