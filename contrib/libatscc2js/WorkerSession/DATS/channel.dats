(* ****** ****** *)
(*
** For writing ATS code
** that translates into JavaScript
*)
(* ****** ****** *)

(*
** Permission to use, copy, modify, and distribute this software for any
** purpose with or without fee is hereby granted, provided that the above
** copyright notice and this permission notice appear in all copies.
** 
** THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
** WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
** MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
** ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
** WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
** ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
** OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*)

(* ****** ****** *)

(*
** Author: Hongwei Xi
** Authoremail: gmhwxi AT gmail DOT com
** Start Time: October, 2015
*)

(* ****** ****** *)
//
(*
#define
ATS_STALOADFLAG 0 // no staloading at run-time
*)
//
#define
ATS_EXTERN_PREFIX
"ats2js_workersession_" // prefix for external names
//
(* ****** ****** *)
//
#define
LIBATSCC2JS_targetloc
"$PATSHOME/contrib/libatscc2js"
//
#include
  "{$LIBATSCC2JS}/mylibies.hats"
//
(* ****** ****** *)
//
staload
UN = "prelude/SATS/unsafe.sats"
//
(* ****** ****** *)
//
staload "./../../SATS/JSarray.sats"
staload "./../SATS/channel.sats"
//
(* ****** ****** *)
//
implement
chmsg_parse<int>(msg) = let
  val msg = $UN.cast{string}(msg)
in
  $extfcall(int, "parseInt", msg)
end // end of [chmsg_parse<int>]
//
implement
chmsg_parse<double>(msg) = let
  val msg = $UN.cast{string}(msg)
in
  $extfcall(double, "parseFloat", msg)
end // end of [chmsg_parse<double>]
//
(* ****** ****** *)

implement
chmsg_parse<bool>(msg) = $UN.cast{bool}(msg)

(* ****** ****** *)
//
implement
chmsg_parse<string>(msg) = $UN.cast{string}(msg)
//
(* ****** ****** *)

//
// HX-2026-10: no GC
// (JSON) arrays are received as JSarrays (instead of list0)
//
implement
(a:t@ype)
chmsg_parse<JSarray(a)>(msg) = let
//
val A = $UN.cast{JSarray(chmsg(a))}(msg)
val n = JSarray_length(A)
val B = JSarray_nil{a}()
//
fun
loop(i: int): void =
  if i < n
    then let
      val _ = JSarray_push(B, chmsg_parse<a>(JSarray_get_at(A, i)))
    in
      loop(i+1)
    end // end of [then]
  // end of [if]
//
in
  loop(0); B
end // end of [chmsg_parse<JSarray(a)>]

(* ****** ****** *)

implement
(a:t@ype
,b:t0ype)
chmsg_parse<@(a,b)>(msg) = let
//
val
msg =
$UN.cast{@(chmsg(a),chmsg(b))}(msg)
//
in
  @(chmsg_parse<a>(msg.0), chmsg_parse<b>(msg.1))
end // end of [chmsg_parse<@(a,b)>]

(* ****** ****** *)

implement
(a:t@ype
,b:t0ype
,c:t0ype)
chmsg_parse<@(a,b,c)>(msg) = let
//
val
msg =
$UN.cast{@(chmsg(a),chmsg(b),chmsg(c))}(msg)
//
in
  @(chmsg_parse<a>(msg.0), chmsg_parse<b>(msg.1), chmsg_parse<c>(msg.2))
end // end of [chmsg_parse<@(a,b,c)>]

(* ****** ****** *)

(* end of [channel.dats] *)
