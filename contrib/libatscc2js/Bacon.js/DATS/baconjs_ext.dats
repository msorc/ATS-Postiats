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
#define
ATS_DYNLOADFLAG 0 // no run-time dynloading
//
#define
ATS_EXTERN_PREFIX
"ats2js_baconjs_ext_" // prefix for extern names
#define
ATS_STATIC_PREFIX
"_ats2js_baconjs_ext_" // prefix for static names
//
(* ****** ****** *)
//
staload
UN =
"prelude/SATS/unsafe.sats"
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
staload "./../SATS/baconjs.sats"
staload "./../SATS/baconjs_ext.sats"
//
(* ****** ****** *)
//
(*
fun
EStream_scan_stream_opt
  {a,b,c:t0p}
(
  xs: EStream(b)
, ini: a, ys: stream_vt(c), fopr: cfun(a, b, c, Option_vt(a))
) : Property(a) = "mac#%" // end-of-function
*)
//
implement
EStream_scan_stream_opt
  {a,b,c}
  (xs, ini, ys, fopr) = let
//
// HX-2026-10: no GC
// [fopr2] is called for each event, so it cannot hold
// the linear [fopr]: the latter is turned into a (target)
// function; the (linear) stream is kept in a reference
//
val f3 = cloref2fun3{a,b,c,Option_vt(a)}(fopr)
val rys = ref{stream_vt(c)}(ys)
//
val
fopr2 = lam
(
  ini: a, x: b
) : a =<cloptr1> let
  val ys =
    ref_exch_elt{stream_vt(c)}(rys, $ldelay(stream_vt_nil()))
  // end of [val]
in
//
case+ !ys of
| ~stream_vt_nil() => ini
| ~stream_vt_cons(y, ys) => let
    val opt = f3(ini, x, y)
  in
    case+ opt of
    | ~None_vt() => let
        val ys = $ldelay(stream_vt_cons(y, ys), ~ys)
        val-~stream_vt_nil() = !(ref_exch_elt{stream_vt(c)}(rys, ys))
      in
        ini
      end // end of [None_vt]
    | ~Some_vt(ini) => let
        val-~stream_vt_nil() = !(ref_exch_elt{stream_vt(c)}(rys, ys))
      in
        ini
      end // end of [Some_vt]
  end // end of [stream_vt_cons]
//
end // end of [fopr2]
//
in
  EStream_scan(xs, ini, fopr2)
end // end of [EStream_scan_stream_opt]
//
(* ****** ****** *)
//
(*
fun
EValue_get_elt
  {a:t0p}
  (x: EValue(a)): (a) = "mac#%"
*)
implement
EValue_get_elt
  {a}(eval) =
  ref_get_elt($UN.cast{ref(a)}(eval))
//
(* ****** ****** *)
//
(*
fun
EValue_make_property
  {a:t0p}(Property(a)): EValue(a) = "mac#%"
*)
//
implement
EValue_make_property
  {a}(xs) = let
//
val x0 =
  $UN.cast{a}(0)
//
val
xref = ref{a}(x0)
//
val ((*void*)) =
Property_onValue
  (xs, lam(x) =<cloptr1> xref[] := x)
//
in
  $UN.cast{EValue(a)}(xref)
end // end of [EValue_make_property]

(* ****** ****** *)
//
(*
fun
EValue_make_estream_scan
  {a,b:t0p}
(
  x0: a, ys: EStream(b), fopr: cfun(a, b, a)
) : EValue(a) = "mac#%" // end-of-fun
*)
//
implement
EValue_make_estream_scan
  {a,b}
(
  x0, ys, fopr
) = let
//
val
xref = ref{a}(x0)
//
// HX-2026-10: the closure is called for each event
val f2 = cloref2fun2(fopr)
//
val () =
EStream_onValue{b}(
  ys, lam(y) =<cloptr1> xref[] := f2(xref[], y)
) (* end of [val] *)
//
in
  $UN.cast{EValue(a)}(xref)
end // end of [EValue_make_estream_scan]

(* ****** ****** *)

implement
singpair_is_pair{a}(sp) = sp.0
implement
singpair_get_fst{a}(sp) = sp.1
implement
singpair_get_snd{a}(sp) = sp.2

(* ****** ****** *)

local
//
// HX-2026-10: no GC
// Opening(n, x) = @(n, true, x) and Closing(n) = @(n, false, _)
//
typedef
tagged(a:t@ype) = @(int, bool, a)
//
// Issued(None) = @(0, _, _, _),
// Issued(Some(sp)) = @(1, _, _, sp) and Waiting(n, x) = @(2, n, x, _)
//
typedef
state(a:t@ype) = @(int, int, a, singpair(a))
//
in (* in-of-local *)

implement
EStream_singpair_trans
  {a}(xs, delta) = let
//
val x0 = $UN.cast{a}(0)
val sp0 = @(false, x0, x0): singpair(a)
//
val
xs_tagged =
EStream_scan{tagged(a)}{a}
(
  xs
, @(0, true, x0)
, lam(res, x) => @(res.0+1, true, x)
) (* end of [EStream_scan] *)
val
xs_tagged = Property_changes(xs_tagged)
//
val
ys_tagged =
EStream_flatMap
{tagged(a)}{tagged(a)}
( xs_tagged
, lam x =>
  Bacon_later(delta(*ms*), @(x.0, false, x0): tagged(a))
)
//
val
states =
Property_changes
(
EStream_scan
{state(a)}{tagged(a)}
(
  merge
  (
    xs_tagged, ys_tagged
  )
, @(0, 0, x0, sp0) // initial: Issued(None)
, lam(state, tagged) =>
  (
    if state.0 < 2
      then (
        if tagged.1
          then @(2, tagged.0, tagged.2, sp0) // Waiting
          else @(0, 0, x0, sp0) // Issued(None)
      ) (* end of [then] *)
      else (
        if tagged.1
          then @(1, 0, x0, @(true, state.2, tagged.2)) // Pair
          else (
            if tagged.0 < state.1
              then state else @(1, 0, x0, @(false, state.2, x0)) // Sing
          ) (* end of [else] *)
      ) (* end of [else] *)
  )
)
) (* end of [val] *)
//
val
states =
EStream_filter{state(a)}
  (states, lam(state) => state.0 = 1)
//
in
  EStream_map{state(a)}{singpair(a)}(states, lam(state) => state.3)
end // end of [EStream_singpair_trans]

end // end of [local]

(* ****** ****** *)

(* end of [baconjs_ext.dats] *)
