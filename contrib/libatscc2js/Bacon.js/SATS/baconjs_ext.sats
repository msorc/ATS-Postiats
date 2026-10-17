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
** Start Time: October, 2015
** Authoremail: gmhwxiATgmailDOTcom
*)

(* ****** ****** *)
//
// HX:
// for external names
//
#define
ATS_EXTERN_PREFIX
"ats2js_baconjs_ext_"
//
(*
#define // no staloading at
ATS_STALOADFLAG 0 // run-time
*)
//
(* ****** ****** *)
//
#define
LIBATSCC2JS_targetloc
"$PATSHOME/contrib/libatscc2js"
//
#staload
"{$LIBATSCC2JS}/basics_js.sats"
//
(* ****** ****** *)
//
#staload
"./baconjs.sats" // basics for Bacon.js
//
(* ****** ****** *)
//
abstype
EValue(a:t@ype) = ptr // updated by EStream
//
(* ****** ****** *)
//
fun
EStream_scan_stream_opt
  {a,b,c:t0p}
(
  xs: EStream(b)
, ini: a, ys: stream_vt(c)
, fopr: cfun(a, b, c, Option_vt(a))
) : Property(a) = "mac#%" // end-of-function
//
// HX-2026-10: no GC
// [ys] and [fopr] are consumed; an element of [ys]
// is used up only if [fopr] returns some new state
//
//
overload scan with EStream_scan_stream_opt
overload .scan with EStream_scan_stream_opt
//
(* ****** ****** *)
//
fun
EValue_get_elt
  {a:t0p}
  (x: EValue(a)): (a) = "mac#%"
//
overload [] with EValue_get_elt
//
fun
EValue_make_property
  {a:t0p}(Property(a)): EValue(a) = "mac#%"
fun
EValue_make_estream_scan
  {a,b:t0p}
(
  x0: a, ys: EStream(b), fopr: cfun(a, b, a)
) : EValue(a) = "mac#%" // EValue_make_estream_scan
//
(* ****** ****** *)
//
// HX-2026-10: no GC
// A singpair is either a single (Sing(x0)) or a pair
// (Pair(x0, x1)) of values; it is a flat tuple (is_pair, x0, x1)
// (where x1 is meaningless for a single)
//
typedef
singpair(a: t@ype) = @(bool, a, a)
//
fun
singpair_is_pair
  {a:t0p}(sp: singpair(a)): bool = "mac#%"
fun
singpair_get_fst
  {a:t0p}(sp: singpair(a)): (a) = "mac#%"
fun
singpair_get_snd
  {a:t0p}(sp: singpair(a)): (a) = "mac#%" // for a pair
//
(* ****** ****** *)
//
// HX-2016-11-13:
//
// For grouping two consecutive events
// if the second occurs with delta ms of the first
// For instance, [EStream_singpair_trans] can be employed
// to support an implementation of double clicking
//
fun
EStream_singpair_trans
  {a:t0p}
(
xs: EStream(a), delta(*ms*): intGte(0)
) : EStream(singpair(a)) = "mac#%" // EStream_singpair_trans
//
(* ****** ****** *)

(* end of [baconjs_ext.sats] *)
