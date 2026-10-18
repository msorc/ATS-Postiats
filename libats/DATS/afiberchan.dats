(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-2014 Hongwei Xi, ATS Trustful Software, Inc.
** All rights reserved
**
** ATS is free software;  you can  redistribute it and/or modify it under
** the terms of  the GNU GENERAL PUBLIC LICENSE (GPL) as published by the
** Free Software Foundation; either version 3, or (at  your  option)  any
** later version.
** 
** ATS is distributed in the hope that it will be useful, but WITHOUT ANY
** WARRANTY; without  even  the  implied  warranty  of MERCHANTABILITY or
** FITNESS FOR A PARTICULAR PURPOSE.  See the  GNU General Public License
** for more details.
** 
** You  should  have  received  a  copy of the GNU General Public License
** along  with  ATS;  see the  file COPYING.  If not, please write to the
** Free Software Foundation,  51 Franklin Street, Fifth Floor, Boston, MA
** 02110-1301, USA.
*)


(* ****** ****** *)
//
// HX-2026-10:
// afiberchan: bounded linear channels between fibers
//
(* ****** ****** *)

staload
UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/afiber.sats"
staload "libats/SATS/afiberchan.sats"

(* ****** ****** *)
//
// the ring buffer (libats/CATS/afiberchan.cats)
//
extern
fun ring_make
  (cap: size_t, tsz: size_t): ptr = "mac#atslib_afiberchan_ring_make"
extern
fun ring_free (r: ptr): void = "mac#atslib_afiberchan_ring_free"
extern
fun ring_size (r: ptr): size_t = "mac#atslib_afiberchan_ring_size"
extern
fun ring_is_full (r: ptr): bool = "mac#atslib_afiberchan_ring_is_full"
extern
fun ring_push (r: ptr): ptr = "mac#atslib_afiberchan_ring_push"
extern
fun ring_pop (r: ptr): ptr = "mac#atslib_afiberchan_ring_pop"
//
(* ****** ****** *)
//
datavtype
chan_struct =
CHAN of
@{
  cap=intGt(0)
, rfcnt=intGt(0)
, closed=bool
, buf=ptr // the ring buffer
, sendq=afiber_waitq
, recvq=afiber_waitq
} (* end of [chan_struct] *)
//
(* ****** ****** *)

local

assume chan_vtype (a:vt0p) = chan_struct

in (* in-of-local *)

(* ****** ****** *)

implement
{a}(*tmp*)
chan_make (cap) = let
//
val chan = CHAN(_)
val+CHAN(ch) = chan
//
val () = ch.cap := cap
val () = ch.rfcnt := 1
val () = ch.closed := false
val () = ch.buf := ring_make (i2sz(cap), sizeof<a>)
val () = ch.sendq := afiber_waitq_make ()
val () = ch.recvq := afiber_waitq_make ()
//
in
  fold@(chan); chan
end // end of [chan_make]

(* ****** ****** *)

implement
{a}(*tmp*)
chan_ref (chan) = let
//
val@CHAN(ch) = chan
val () = ch.rfcnt := ch.rfcnt + 1
prval () = fold@(chan)
//
in
  $UN.castvwtp1{chan_vt(a)}(chan)
end // end of [chan_ref]

(* ****** ****** *)
//
extern
fun{a:vt0p}
chan_buf_drain (buf: ptr, res: List0_vt(a)): List0_vt(a)
//
implement
{a}(*tmp*)
chan_buf_drain
  (buf, res) =
(
if
ring_size (buf) > i2sz(0)
then let
  val x = $UN.ptr0_get<a>(ring_pop (buf))
in
  chan_buf_drain<a>(buf, list_vt_cons(x, res))
end // end of [then]
else list_vt_reverse<a>(res)
// end of [if]
) (* end of [chan_buf_drain] *)
//
(* ****** ****** *)

implement
{a}(*tmp*)
chan_unref (chan) = let
//
val@CHAN(ch) = chan
//
val rfcnt = ch.rfcnt
//
in
//
if
rfcnt <= 1
then let
  val xs = chan_buf_drain<a>(ch.buf, list_vt_nil())
  val () = ring_free (ch.buf)
  val () = afiber_waitq_free (ch.sendq)
  val () = afiber_waitq_free (ch.recvq)
  val () = free@(chan)
in
  xs
end // end of [then]
else let
  val () = ch.rfcnt := rfcnt - 1
  prval () = fold@(chan)
  prval () = $UN.cast2void(chan)
in
  list_vt_nil()
end // end of [else]
//
end // end of [chan_unref]

implement
{a}(*tmp*)
chan_unref_type (chan) =
  list_vt_free<a>(chan_unref<a>(chan))
// end of [chan_unref_type]

(* ****** ****** *)

implement
{}(*tmp*)
chan_rfcnt{a}(chan) = let
  val@CHAN(ch) = chan; val n = ch.rfcnt; prval () = fold@(chan) in n
end // end of [chan_rfcnt]

implement
{}(*tmp*)
chan_capacity{a}(chan) = let
  val@CHAN(ch) = chan; val n = ch.cap; prval () = fold@(chan) in n
end // end of [chan_capacity]

implement
{a}(*tmp*)
chan_size (chan) = let
  val@CHAN(ch) = chan; val n = ring_size (ch.buf); prval () = fold@(chan) in sz2i(n)
end // end of [chan_size]

implement
{}(*tmp*)
chan_is_closed{a}(chan) = let
  val@CHAN(ch) = chan; val b = ch.closed; prval () = fold@(chan) in b
end // end of [chan_is_closed]

implement
{}(*tmp*)
chan_close{a}(chan) = let
//
val@CHAN(ch) = chan
val () = ch.closed := true
val () = afiber_waitq_wake_all (ch.recvq)
val () = afiber_waitq_wake_all (ch.sendq)
prval () = fold@(chan)
//
in
  // nothing
end // end of [chan_close]

(* ****** ****** *)

implement
{a}(*tmp*)
chan_send_opt
  (chan, x0) = let
//
val@CHAN(ch) = chan
//
in
//
if
ch.closed
then let
  prval () = fold@(chan) in Some_vt(x0)
end // end of [then]
else (
if
ring_is_full (ch.buf)
then let
  val () = afiber_waitq_park (ch.sendq)
  prval () = fold@(chan)
in
  chan_send_opt<a>(chan, x0)
end // end of [then]
else let
  val () = $UN.ptr0_set<a>(ring_push (ch.buf), x0)
  val _ = afiber_waitq_wake_one (ch.recvq)
  prval () = fold@(chan)
in
  None_vt()
end // end of [else]
) (* end of [else] *)
//
end // end of [chan_send_opt]

implement
{a}(*tmp*)
chan_send (chan, x0) = let
//
val opt = chan_send_opt<a>(chan, x0)
//
in
//
case+ opt of
| ~None_vt() => ()
| ~Some_vt(x0) => let
    prval () = $UN.cast2void(x0)
    val () =
    fprintln! (stderr_ref, "libats/afiberchan: [chan_send]: the channel is closed.")
  in
    assertloc(false)
  end // end of [Some_vt]
//
end // end of [chan_send]

(* ****** ****** *)

implement
{a}(*tmp*)
chan_recv (chan) = let
//
val@CHAN(ch) = chan
//
in
//
if
ring_size (ch.buf) > i2sz(0)
then let
  val x0 = $UN.ptr0_get<a>(ring_pop (ch.buf))
  val _ = afiber_waitq_wake_one (ch.sendq)
  prval () = fold@(chan)
in
  Some_vt(x0)
end // end of [then]
else (
if
ch.closed
then let
  prval () = fold@(chan) in None_vt()
end // end of [then]
else let
  val () = afiber_waitq_park (ch.recvq)
  prval () = fold@(chan)
in
  chan_recv<a>(chan)
end // end of [else]
) (* end of [else] *)
//
end // end of [chan_recv]

(* ****** ****** *)

implement
{a}(*tmp*)
chan_trysend
  (chan, x0) = let
//
val@CHAN(ch) = chan
//
in
//
if
ch.closed || ring_is_full (ch.buf)
then let
  prval () = fold@(chan) in Some_vt(x0)
end // end of [then]
else let
  val () = $UN.ptr0_set<a>(ring_push (ch.buf), x0)
  val _ = afiber_waitq_wake_one (ch.recvq)
  prval () = fold@(chan)
in
  None_vt()
end // end of [else]
//
end // end of [chan_trysend]

implement
{a}(*tmp*)
chan_tryrecv (chan) = let
//
val@CHAN(ch) = chan
//
in
//
if
ring_size (ch.buf) > i2sz(0)
then let
  val x0 = $UN.ptr0_get<a>(ring_pop (ch.buf))
  val _ = afiber_waitq_wake_one (ch.sendq)
  prval () = fold@(chan)
in
  Some_vt(x0)
end // end of [then]
else let
  prval () = fold@(chan) in None_vt()
end // end of [else]
//
end // end of [chan_tryrecv]

(* ****** ****** *)

end // end of [local]

(* ****** ****** *)

(* end of [afiberchan.dats] *)
