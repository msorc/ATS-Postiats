(* ****** ****** *)
//
// RPC based on WebWorker
//
(* ****** ****** *)
//
#define
ATS_MAINATSFLAG 1
#define
ATS_DYNLOADNAME "theWorker_start"
//
(* ****** ****** *)
//
#include
"share/atspre_define.hats"
#include
"{$LIBATSCC2JS}/mylibies.hats"
//
(* ****** ****** *)

staload
UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)
//
#define
WORKERSESSION_CHANPOS 1
//
#include "./../mylibies.dats"
#include "./../mylibies.hats"
//
(* ****** ****** *)
//
// HX-2026-10: no GC (the arguments form a JSarray)
fun
JSarray_add
(
  xs: JSarray(int)
) : int = loop(0, 0) where
{
  val n = JSarray_length(xs)
  fun loop(i: int, res: int): int =
    if i < n then loop(i+1, res + JSarray_get_at(xs, i)) else res
}
//
(* ****** ****** *)
//
vtypedef
chanpos() = $CHANNEL.chanpos()
//
(* ****** ****** *)

local
//
(*
implement
{a}{b}
rpc_server_cont(ch, f) = chanpos_close(ch)
*)
//
typedef ARG = JSarray(int) and RES = int
//
in
//
val ((*void*)) =
$CHANNEL.rpc_server<ARG><RES>
  ($UN.cast{chanpos()}(0), lam(xs) => JSarray_add(xs))
//
end // end of [local]
//
(* ****** ****** *)

%{$
//
theWorker_start();
//
%} // end of [%{$]

(* ****** ****** *)

(* end of [rpc_server.dats] *)
