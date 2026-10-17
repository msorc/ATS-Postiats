(*
** A wrapper for atscc2js
*)

(* ****** ****** *)
//
#define
ATS_MAINATSFLAG 1
#define
ATS_DYNLOADNAME
"wktest_libatscc2js_dynload"
//
(* ****** ****** *)
//
#define
LIBATSCC2JS_targetloc
"$PATSHOME\
/contrib/libatscc2js"
//
(* ****** ****** *)
//
#include
"{$LIBATSCC2JS}/mylibies.hats"
//
(* ****** ****** *)
//
#staload
"{$LIBATSCC2JS}/WorkerSession/SATS/channel.sats"
#staload
"{$LIBATSCC2JS}/WorkerSession/DATS/channel.dats"
#include
"{$LIBATSCC2JS}/WorkerSession/DATS/channeg.dats"
//
(* ****** ****** *)
//
//
// HX-2026-10: no GC
// the protocol between the client and the worker:
// a command-line argument is a flat pair (tag, string),
// the arguments form a JSarray, and the result is a flat
// triple (nerr, stdout, stderr); they are parsed by the
// generic chmsg_parse of WorkerSession
//
typedef comarg = @(int, string)
typedef comarglst = JSarray(comarg)
typedef atscc2jsres = @(int, string, string)
//
//
(* ****** ****** *)


(* ****** ****** *)
//
%{^
//
function
theExample_dats_c_get_value()
{
  return document.getElementById("theExample_dats_c").value;
}
function
theExample_dats_js_set_value(code)
{
  return document.getElementById("theExample_dats_js").value = code;
}
//
function
theExample_atscc2js_optstr_get_value()
{
  return document.getElementById("theExample_atscc2js_optstr").value;
}
//
%} // end of [%{^]
//
extern
fun
theExample_dats_c_get_value(): string = "mac#"
extern
fun
theExample_dats_js_set_value(code: string): void = "mac#"
//
extern
fun
theExample_atscc2js_optstr_get_value(): string = "mac#"
//
(* ****** ****** *)

extern
fun
theExample_atscc2js_getarg
  ((*void*)): comarglst
//
implement
theExample_atscc2js_getarg
  ((*void*)) = let
//
val
args = JSarray_nil{comarg}()
//
val
delim = " "
val
optstr =
theExample_atscc2js_optstr_get_value()
val
optarr =
$extmcall(JSarray(string), optstr, "split", delim)
//
fun
loop(i: int, n: int): void =
  if i < n
    then let
      val _ = JSarray_push(args, @(0(*strlit*), optarr[i]))
    in
      loop(i+1, n)
    end // end of [then]
//
val () = loop(0, length(optarr))
val _ =
JSarray_push
  (args, @(1(*strinp*), theExample_dats_c_get_value()))
//
in
  args
end // end of [theExample_atscc2js_getarg]

(* ****** ****** *)
//
extern
fun
theExample_atscc2js_arglst
(
  arglst: comarglst
, fpost: (int) -> void
) : void // end-of-function
//
implement
theExample_atscc2js_arglst
  (args, fpost) = () where
{
//
val
chn =
channeg0_new_file
(
  "./libatscc2js_ext_worker.js"
) (* end of [val] *)
//
(*
val () = alert("Worker is ready!")
*)
//
val () =
channeg0_send{int}
(
chn
,
llam(chn, res) =>
// theWorker is ready
channeg0_recv{comarglst}
(
chn
,
args
,
llam(chn) =>
channeg0_send{atscc2jsres}
(
chn
,
llam(chn, res) => let
//
val
res =
chmsg_parse<atscc2jsres>(res)
//
val () = channeg0_close(chn)
//
val
@(nerr, stdout, stderr) = res
// end of [val]
(*
val () = alert("nerr = " + String(nerr))
*)
val () =
  if (nerr = 0)
    then theExample_dats_js_set_value(stdout)
  // end of [if]
val () =
  if (nerr > 0)
    then theExample_dats_js_set_value(stderr)
   // end of [if]
//
in
  fpost(nerr) // for the post action
end // end of [lam]
) (* send{atscc2jsres} *)
) (* recv{comarglst} *)
) (* channeg_send{int} *)
//
} (* end of [theExample_atscc2js_arglst] *)
//
(* ****** ****** *)
//
extern
fun
theExample_atscc2js_onclick(): void = "mac#"
//
implement
theExample_atscc2js_onclick() = let
//
val args = theExample_atscc2js_getarg()
//
fun
fpost(nerr: int): void =
(
case+ nerr of
//
| 0 => alert("Atscc2js finished normally!")
//
| 1 => alert("Atscc2js encountered an error!")
//
| _ when nerr >= 2 => alert("Atscc2js encountered some errors!")
//
| _ => ((*unused*))
) (* end of [fpost] *)
//
in
  theExample_atscc2js_arglst(args, lam(nerr) => fpost(nerr))
end // end of [theExample_atscc2js_onclick]

(* ****** ****** *)

%{$
//
function
the_libatscc2js_main()
{
  jQuery(document).ready(function(){wktest_libatscc2js_dynload();});
}
//
%} // end of [%{$]

(* ****** ****** *)

(* end of [wktest_libatscc2js.dats] *)
