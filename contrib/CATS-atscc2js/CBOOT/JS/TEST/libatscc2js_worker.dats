(* ****** ****** *)
//
// WebWorker for libatscc2js
//
(* ****** ****** *)
//
#define
ATS_MAINATSFLAG 1
#define
ATS_DYNLOADNAME
"the_libatscc2js_worker_start"
//
(* ****** ****** *)
//  
#define
LIBATSCC2JS_targetloc
"$PATSHOME\
/contrib/libatscc2js"
//
#include
"{$LIBATSCC2JS}/mylibies.hats"
//
//
staload
"{$LIBATSCC2JS}/WorkerSession/SATS/channel.sats"
staload
"{$LIBATSCC2JS}/WorkerSession/DATS/channel.dats"
#include
"{$LIBATSCC2JS}/WorkerSession/DATS/chanpos.dats"
//
(* ****** ****** *)

#staload
UN = "prelude/SATS/unsafe.sats"

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
//

//
(* ****** ****** *)
//
abstype emcc_int
abstype emcc_string
//
abstype emcc_comarg
abstype emcc_comarglst
//
(* ****** ****** *)
//
extern
castfn emcc_int(x: int): emcc_int
extern
castfn un_emcc_int(x: emcc_int): int
//
(* ****** ****** *)
//
%{^
//
function
emcc_string(inp)
{
//
var
out = Module._malloc(inp.length+1);
//
Module.writeStringToMemory(inp, out); return out;
//
} // end of [emcc_string]
//
function
un_emcc_string(ptr) { return Pointer_stringify(ptr); }
//
%} // end of [%{^]
//
extern
fun
emcc_string
  (inp: string) : emcc_string = "mac#emcc_string"
//
extern
fun
un_emcc_string(emcc_string): string = "mac#un_emcc_string"
//
(* ****** ****** *)
//
extern
fun
_comarg_strlit
  (emcc_string): emcc_comarg
  = "mac#_libatscc2js_comarg_strlit"
and
_comarg_strinp
  (emcc_string): emcc_comarg
  = "mac#_libatscc2js_comarg_strinp"
and
_comarg_prefil
  (emcc_string): emcc_comarg
  = "mac#_libatscc2js_comarg_prefil"
and
_comarg_postfil
  (emcc_string): emcc_comarg
  = "mac#_libatscc2js_comarg_postfil"
//
extern
fun
_comarglst_nil
  ((*void*)): emcc_comarglst
  = "mac#_libatscc2js_comarglst_nil"
and
_comarglst_cons
(
  emcc_comarg, emcc_comarglst
) : emcc_comarglst
  = "mac#_libatscc2js_comarglst_cons"
//
(* ****** ****** *)
//
extern
fun
emcc_comarg
  (arg: comarg): emcc_comarg = "mac#emcc_comarg"
extern
fun
emcc_comarglst
  (args: comarglst): emcc_comarglst = "mac#emcc_comarglst"
//
(* ****** ****** *)
//
implement
emcc_comarg(arg) =
(
case+ arg.0 of
| 0 => _comarg_strlit(emcc_string(arg.1))
| 1 => _comarg_strinp(emcc_string(arg.1))
| 2 => _comarg_prefil(emcc_string(arg.1))
| _ => _comarg_postfil(emcc_string(arg.1))
)
//
implement
emcc_comarglst(args) = let
//
fun
loop
(
  i: int, res: emcc_comarglst
) : emcc_comarglst =
  if i > 0
    then loop(i-1, _comarglst_cons(emcc_comarg(args[i-1]), res))
    else res
//
in
  loop(JSarray_length(args), _comarglst_nil())
end // end of [emcc_comarglst]

(* ****** ****** *)
//
extern
fun
atscc2js_main0_arglst
  (emcc_comarglst): emcc_int
  = "mac#_libatscc2js_atscc2js_main0_arglst"
//
extern
fun
my_atscc2jsres_main_arglst
  (args: comarglst): atscc2jsres
//
implement
my_atscc2jsres_main_arglst
  (args) = let
//
val () =
$extfcall(void, "_libatscc2js_dynload")
//
in
//
if
JSarray_length(args) = 0
then @(0, "", "")
else let
    val
    args = emcc_comarglst(args)
    val
    nerr = atscc2js_main0_arglst(args)
    val
    stdout =
    $extfcall
      (string, "libatscc2js_stdout_store_join")
    // end of [val]
    val
    stderr =
    $extfcall
      (string, "libatscc2js_stderr_store_join")
    // end of [val]
  in
    @(un_emcc_int(nerr), stdout, stderr)
  end // end of [else]
//
end (* end of [my_atscc2jsres_main_arglst] *)
//
(* ****** ****** *)
//
local
//
implement
{a}{b}
rpc_server_cont
  (chp, f) = chanpos0_close(chp)
//
in
//
val
chp = $UN.cast{chanpos()}(0)
//
val () =
chanpos0_send
( chp, 0
, llam(chp) =>
  rpc_server<comarglst><atscc2jsres>
    (chp, lam(args) => my_atscc2jsres_main_arglst(args))
  // end of [rpc_server] // end of [lam]
) (* end of [chanpos_send] *)
//
end // end of [local]

(* ****** ****** *)

%{$
//
function
the_libatscc2js_main() { return the_libatscc2js_worker_start(); }
//
%} // end of [%{$]

(* ****** ****** *)

(* end of [libatscc2js_worker.dats] *)
