(* ******************************************************************* *)
(*                                                                     *)
(*                         ATS/contrib/afiber                          *)
(*                                                                     *)
(* ******************************************************************* *)

(*
** Copyright (C) 2026 Mikhail Sorochan
**
** Permission is hereby granted, free of charge, to any person obtaining a
** copy of this software and associated documentation files (the "Software"),
** to deal in the Software without restriction, including without limitation
** the rights to use, copy, modify, merge, publish, distribute, sublicense,
** and/or sell copies of the Software, and to permit persons to whom the
** Software is furnished to do so, subject to the following stated conditions:
**
** The above copyright notice and this permission notice shall be included in
** all copies or substantial portions of the Software.
**
** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
** OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
** FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
** THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
** LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
** FROM OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
** IN THE SOFTWARE.
*)


(* ****** ****** *)
//
// MS-2026-10:
// afiberchan: bounded linear channels between fibers
//
(* ****** ****** *)

staload
UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "contrib/afiber/SATS/afiber.sats"
staload "contrib/afiber/SATS/afiberchan.sats"

(* ****** ****** *)
//
// the ring buffer (contrib/afiber/CATS/afiberchan.cats)
//
extern
fun ring_make
  (cap: size_t, tsz: size_t): ptr = "mac#atscntrb_afiberchan_ring_make"
extern
fun ring_free (r: ptr): void = "mac#atscntrb_afiberchan_ring_free"
extern
fun ring_size (r: ptr): size_t = "mac#atscntrb_afiberchan_ring_size"
extern
fun ring_is_full (r: ptr): bool = "mac#atscntrb_afiberchan_ring_is_full"
extern
fun ring_push (r: ptr): ptr = "mac#atscntrb_afiberchan_ring_push"
extern
fun ring_pop (r: ptr): ptr = "mac#atscntrb_afiberchan_ring_pop"
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
, lock=afiber_spin // protects all of the above, and the wait queues
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
val () = ch.lock := afiber_spin_make ()
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
val (pf | ()) = afiber_spin_lock (ch.lock)
val () = ch.rfcnt := ch.rfcnt + 1
val () = afiber_spin_unlock (pf | ch.lock)
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
val (pf | ()) = afiber_spin_lock (ch.lock)
val rfcnt = ch.rfcnt
//
in
//
if
rfcnt <= 1
then let
  // the last owner: nobody else can reach the channel
  val () = afiber_spin_unlock (pf | ch.lock)
  val xs = chan_buf_drain<a>(ch.buf, list_vt_nil())
  val () = ring_free (ch.buf)
  val () = afiber_waitq_free (ch.sendq)
  val () = afiber_waitq_free (ch.recvq)
  val () = afiber_spin_free (ch.lock)
  val () = free@(chan)
in
  xs
end // end of [then]
else let
  val () = ch.rfcnt := rfcnt - 1
  val () = afiber_spin_unlock (pf | ch.lock)
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
  val@CHAN(ch) = chan
  val (pf | ()) = afiber_spin_lock (ch.lock)
  val n = ch.rfcnt
  val () = afiber_spin_unlock (pf | ch.lock)
  prval () = fold@(chan)
in n
end // end of [chan_rfcnt]

implement
{}(*tmp*)
chan_capacity{a}(chan) = let
  val@CHAN(ch) = chan; val n = ch.cap; prval () = fold@(chan) in n
end // end of [chan_capacity]

implement
{a}(*tmp*)
chan_size (chan) = let
  val@CHAN(ch) = chan
  val (pf | ()) = afiber_spin_lock (ch.lock)
  val n = ring_size (ch.buf)
  val () = afiber_spin_unlock (pf | ch.lock)
  prval () = fold@(chan)
in sz2i(n)
end // end of [chan_size]

implement
{}(*tmp*)
chan_is_closed{a}(chan) = let
  val@CHAN(ch) = chan
  val (pf | ()) = afiber_spin_lock (ch.lock)
  val b = ch.closed
  val () = afiber_spin_unlock (pf | ch.lock)
  prval () = fold@(chan)
in b
end // end of [chan_is_closed]

implement
{}(*tmp*)
chan_close{a}(chan) = let
//
val@CHAN(ch) = chan
val (pf | ()) = afiber_spin_lock (ch.lock)
val () = ch.closed := true
val () = afiber_waitq_wake_all (pf | ch.recvq)
val () = afiber_waitq_wake_all (pf | ch.sendq)
val () = afiber_spin_unlock (pf | ch.lock)
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
val (pf | ()) = afiber_spin_lock (ch.lock)
//
in
//
if
ch.closed
then let
  val () = afiber_spin_unlock (pf | ch.lock)
  prval () = fold@(chan) in Some_vt(x0)
end // end of [then]
else (
if
ring_is_full (ch.buf)
then let
  val () = afiber_waitq_park (pf | ch.sendq, ch.lock)
  val () = afiber_spin_unlock (pf | ch.lock)
  prval () = fold@(chan)
in
  chan_send_opt<a>(chan, x0)
end // end of [then]
else let
  val () = $UN.ptr0_set<a>(ring_push (ch.buf), x0)
  val _ = afiber_waitq_wake_one (pf | ch.recvq)
  val () = afiber_spin_unlock (pf | ch.lock)
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
    fprintln! (stderr_ref, "afiberchan: [chan_send]: the channel is closed.")
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
val (pf | ()) = afiber_spin_lock (ch.lock)
//
in
//
if
ring_size (ch.buf) > i2sz(0)
then let
  val x0 = $UN.ptr0_get<a>(ring_pop (ch.buf))
  val _ = afiber_waitq_wake_one (pf | ch.sendq)
  val () = afiber_spin_unlock (pf | ch.lock)
  prval () = fold@(chan)
in
  Some_vt(x0)
end // end of [then]
else (
if
ch.closed
then let
  val () = afiber_spin_unlock (pf | ch.lock)
  prval () = fold@(chan) in None_vt()
end // end of [then]
else let
  val () = afiber_waitq_park (pf | ch.recvq, ch.lock)
  val () = afiber_spin_unlock (pf | ch.lock)
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
val (pf | ()) = afiber_spin_lock (ch.lock)
//
in
//
if
ch.closed || ring_is_full (ch.buf)
then let
  val () = afiber_spin_unlock (pf | ch.lock)
  prval () = fold@(chan) in Some_vt(x0)
end // end of [then]
else let
  val () = $UN.ptr0_set<a>(ring_push (ch.buf), x0)
  val _ = afiber_waitq_wake_one (pf | ch.recvq)
  val () = afiber_spin_unlock (pf | ch.lock)
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
val (pf | ()) = afiber_spin_lock (ch.lock)
//
in
//
if
ring_size (ch.buf) > i2sz(0)
then let
  val x0 = $UN.ptr0_get<a>(ring_pop (ch.buf))
  val _ = afiber_waitq_wake_one (pf | ch.sendq)
  val () = afiber_spin_unlock (pf | ch.lock)
  prval () = fold@(chan)
in
  Some_vt(x0)
end // end of [then]
else let
  val () = afiber_spin_unlock (pf | ch.lock)
  prval () = fold@(chan) in None_vt()
end // end of [else]
//
end // end of [chan_tryrecv]

(* ****** ****** *)

end // end of [local]

(* ****** ****** *)

(* end of [afiberchan.dats] *)
