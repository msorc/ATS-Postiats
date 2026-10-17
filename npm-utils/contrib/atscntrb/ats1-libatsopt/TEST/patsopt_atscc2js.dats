(* ****** ****** *)
//
(*
staload
"./../DATS/libatsopt_ext.dats"
*)
//
(* ****** ****** *)
//
extern
fun
libatsopt_dynloadall
(
(*void*)
) : void = "ext#libatsopt_dynloadall"
//
(* ****** ****** *)
//
//
// HX-2026-10: no GC
// (the layout is the same as that of the ATS1
// datatype expected by libatsopt)
//
datavtype
comarg =
//
| COMARGstrlit of string
//
| COMARGstrinp of string
//
| COMARGprefil of string
| COMARGpostfil of string
//
vtypedef comarglst0 = List0_vt(comarg)
vtypedef comarglst1 = List1_vt(comarg)
//
fun
comarg_free
  (x: comarg): void =
(
case+ x of
| ~COMARGstrlit _ => ()
| ~COMARGstrinp _ => ()
| ~COMARGprefil _ => ()
| ~COMARGpostfil _ => ()
)
//
(* ****** ****** *)
//
//
// HX-2026-10:
// the strings are allocated by libatsopt
//
datavtype
patsoptres =
PATSOPTRES of
(
  int(*nerr*)
, string(*stdout*), string(*stderr*)
) (* end of [patsoptres] *)
//
(* ****** ****** *)
//
extern
fun
patsopt_main_arglst
  {n:pos}
(
  args: !list_vt(comarg, n)
) : int(*nerr*) =
  "ext#libatsopt_patsopt_main_arglst"
//
extern
fun
patsoptres_main_arglst
  {n:pos}
(
  args: !list_vt(comarg, n)
) : patsoptres =
  "ext#libatsopt_patsoptres_main_arglst"
//
(* ****** ****** *)

#define
HELLO_WORLD "\
//
extern
fun
hello(): void = \"mac#\"
implement
hello() = print(\"Hello, world!\")
//
(* ****** ****** *)
//
val () = hello()
//
(* ****** ****** *)
//
" (* HELLO_WORLD *)

(* ****** ****** *)

#define
PREAMBLE "\
//
#include
\"share/atspre_define.hats\"
#include
\"{$LIBATSCC2JS}/staloadall.hats\"

(* ****** ****** *)

staload
\"{$LIBATSCC2JS}/SATS/print.sats\"

(* ****** ****** *)

#define ATS_MAINATSFLAG 1
#define ATS_DYNLOADNAME \"myself_dynload\"

(* ****** ****** *)
//
" (* PREAMBLE *)

(* ****** ****** *)

#define
POSTAMBLE "\
//
%{$
//
ats2jspre_the_print_store_clear();
myself_dynload();
alert(ats2jspre_the_print_store_join());
//
%} // end of [%{$]
//
" (* POSTAMBLE *)

(* ****** ****** *)

implement
main0(argc, argv) =
{
//
val () =
println!
(
"Hello from [patsopt_atscc2js]!"
)
//
val () = libatsopt_dynloadall()
//
val arg1 = COMARGprefil(PREAMBLE)
val arg2 = COMARGpostfil(POSTAMBLE)
//
val arg3 = COMARGstrlit("--dynamic")
val arg4 = COMARGstrinp(HELLO_WORLD)
//
#define :: list_vt_cons
//
val
args =
(
  arg1::arg2::arg3::arg4::list_vt_nil()
) : comarglst1
//
(*
val
nerr = patsopt_main_arglst(args)
val () =
println! ("patsopt_main_arglst: nerr = ", nerr)
*)
//
val+
~PATSOPTRES
( nerr
, strout
, strerr ) = patsoptres_main_arglst(args)
//
val () =
list_vt_freelin_fun<comarg>(args, lam(x) =<fun1> comarg_free(x))
//
(*
val () =
println! ("patsoptres_main_arglst: nerr = ", nerr)
val () =
println! ("patsoptres_main_arglst: stdout = ", stdout)
val () =
println! ("patsoptres_main_arglst: stderr = ", stderr)
*)
//
} (* end of [main] *)

(* ****** ****** *)

(* end of [patsopt_atscc2js.dats] *)
