(* ****** ****** *)
//
// For testing libatscc2php
//
(* ****** ****** *)
//
#define
ATS_MAINATSFLAG 1
#define
ATS_STATIC_PREFIX "_test01_"
#define
ATS_DYNLOADNAME "test01_dynload"
//
(* ****** ****** *)
//
#include "./../staloadall.hats"
//
(* ****** ****** *)

%{$
test01_dynload();
%} (* end of [%{$] *)

(* ****** ****** *)

%{^
include "./../output/libatscc2php_all.php";
%} (* end of [%{^] *)

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

(* end of [test01.dats] *)
