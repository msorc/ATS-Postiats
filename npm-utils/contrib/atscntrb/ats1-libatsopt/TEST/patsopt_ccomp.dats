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
extern
fun
patsopt_main_arglst
  {n:pos}
(
  args: !list_vt(comarg, n)
) : int(*nerr*) =
  "ext#libatsopt_patsopt_main_arglst"
//
(* ****** ****** *)
//
#define
HELLO_WORLD "\
implement\n\
main0 () = println! \"Hello, world!\"\n\
"
//
(* ****** ****** *)

implement
main0(argc, argv) =
{
//
val () = libatsopt_dynloadall()
//
val arg1 = COMARGstrlit("--dynamic")
val arg2 = COMARGstrinp(HELLO_WORLD)
//
#define :: list_vt_cons
//
val
args =
(
  arg1::arg2::list_vt_nil()
) : comarglst1
//
val
nerr =
patsopt_main_arglst(args)
//
val () =
list_vt_freelin_fun<comarg>(args, lam(x) =<fun1> comarg_free(x))
//
val () =
if nerr > 0 then
  prerrln! ("[patsopt_main_arglst] encountered errors!")
//
} (* end of [main] *)

(* ****** ****** *)

(* end of [patsopt_ccomp.dats] *)
