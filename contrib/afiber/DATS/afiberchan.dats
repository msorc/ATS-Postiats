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
// MS-2026-10 (step G): the channel is one C object
// (contrib/afiber/CATS/afiberchan.cats): the lock, the ring header and
// both wait queues on one cache line, the slots after it. The ATS type
// is that pointer; the C functions below work on it.
//
extern
fun chan_c_make
  (cap: size_t, tsz: size_t): ptr = "mac#atscntrb_afiberchan_make"
extern
fun chan_c_free (c: ptr): void = "mac#atscntrb_afiberchan_free"
//
extern
fun chan_c_lock (c: !ptr): (afiber_locked_v | void) = "mac#atscntrb_afiberchan_lock"
extern
fun chan_c_unlock (pf: afiber_locked_v | c: !ptr): void = "mac#atscntrb_afiberchan_unlock"
//
extern
fun chan_c_rfcnt_get (c: !ptr): intGt(0) = "mac#atscntrb_afiberchan_rfcnt_get"
extern
fun chan_c_rfcnt_set (c: !ptr, n: intGt(0)): void = "mac#atscntrb_afiberchan_rfcnt_set"
extern
fun chan_c_cap (c: !ptr): intGt(0) = "mac#atscntrb_afiberchan_cap"
extern
fun chan_c_size (c: !ptr): size_t = "mac#atscntrb_afiberchan_size"
extern
fun chan_c_is_full (c: !ptr): bool = "mac#atscntrb_afiberchan_is_full"
extern
fun chan_c_is_closed (c: !ptr): bool = "mac#atscntrb_afiberchan_is_closed"
extern
fun chan_c_set_closed (c: !ptr): void = "mac#atscntrb_afiberchan_set_closed"
extern
fun chan_c_push (c: !ptr): ptr = "mac#atscntrb_afiberchan_push"
extern
fun chan_c_pop (c: !ptr): ptr = "mac#atscntrb_afiberchan_pop"
//
// the lock must be held: the proof is passed to show it
extern
fun chan_c_park_recv (pf: !afiber_locked_v | c: !ptr): void = "mac#atscntrb_afiberchan_park_recv"
extern
fun chan_c_park_send (pf: !afiber_locked_v | c: !ptr): void = "mac#atscntrb_afiberchan_park_send"
extern
fun chan_c_wake_recv (pf: !afiber_locked_v | c: !ptr): void = "mac#atscntrb_afiberchan_wake_recv"
extern
fun chan_c_wake_send (pf: !afiber_locked_v | c: !ptr): void = "mac#atscntrb_afiberchan_wake_send"
extern
fun chan_c_wake_all (pf: !afiber_locked_v | c: !ptr): void = "mac#atscntrb_afiberchan_wake_all"
//
//
// MS-2026-10 (step J): the begin/end functions of the common paths. The
// result is the slot [p] and a view that says what the call left: ok
// (a slot, the lock is held), refused (closed; the lock is released),
// full/empty (NULL, the lock is held, the caller parks).
//
dataview
sendb_v (addr) =
  | sendb_full (null) of afiber_locked_v
  | sendb_refused (null+1) of ()
  | {l:addr | l > null+1} sendb_ok (l) of afiber_locked_v
dataview
recvb_v (addr) =
  | recvb_empty (null) of afiber_locked_v
  | recvb_refused (null+1) of ()
  | {l:addr | l > null+1} recvb_ok (l) of afiber_locked_v
//
extern
fun chan_c_send_begin (c: !ptr): [l:addr] (sendb_v(l) | ptr(l)) = "mac#atscntrb_afiberchan_send_begin"
extern
fun chan_c_trysend_begin (c: !ptr): [l:addr] (sendb_v(l) | ptr(l)) = "mac#atscntrb_afiberchan_trysend_begin"
extern
fun chan_c_send_recheck (pf: afiber_locked_v | c: !ptr): [l:addr] (sendb_v(l) | ptr(l)) = "mac#atscntrb_afiberchan_send_recheck"
extern
fun chan_c_send_end (pf: afiber_locked_v | c: !ptr): void = "mac#atscntrb_afiberchan_send_end"
extern
fun chan_c_recv_begin (c: !ptr): [l:addr] (recvb_v(l) | ptr(l)) = "mac#atscntrb_afiberchan_recv_begin"
extern
fun chan_c_tryrecv_begin (c: !ptr): [l:addr] (recvb_v(l) | ptr(l)) = "mac#atscntrb_afiberchan_tryrecv_begin"
extern
fun chan_c_recv_recheck (pf: afiber_locked_v | c: !ptr): [l:addr] (recvb_v(l) | ptr(l)) = "mac#atscntrb_afiberchan_recv_recheck"
extern
fun chan_c_recv_end (pf: afiber_locked_v | c: !ptr): void = "mac#atscntrb_afiberchan_recv_end"
//
extern
fun ptr_is_one {l:addr} (p: ptr(l)): bool(l==null+1) = "mac#atscntrb_afiberchan_ptr_is_one"
//
extern
fun{a:vt0p}
chan_send_aux {l:addr} (pf: sendb_v(l) | c: !ptr, x: a, p: ptr(l)): Option_vt(a)
extern
fun{a:vt0p}
chan_recv_aux {l:addr} (pf: recvb_v(l) | c: !ptr, p: ptr(l)): Option_vt(a)
//
(* ****** ****** *)

local

assume chan_vtype (a:vt0p) = ptr

in (* in-of-local *)

(* ****** ****** *)

implement
{a}(*tmp*)
chan_make (cap) =
  chan_c_make (i2sz(cap), sizeof<a>)
// end of [chan_make]

(* ****** ****** *)

implement
{a}(*tmp*)
chan_ref (chan) = let
//
val (pf | ()) = chan_c_lock (chan)
val () = chan_c_rfcnt_set (chan, chan_c_rfcnt_get (chan) + 1)
val () = chan_c_unlock (pf | chan)
//
in
  chan
end // end of [chan_ref]

(* ****** ****** *)
//
extern
fun{a:vt0p}
chan_buf_drain (c: !ptr, res: List0_vt(a)): List0_vt(a)
//
implement
{a}(*tmp*)
chan_buf_drain
  (c, res) =
(
if
chan_c_size (c) > i2sz(0)
then let
  val x = $UN.ptr0_get<a>(chan_c_pop (c))
in
  chan_buf_drain<a>(c, list_vt_cons(x, res))
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
val (pf | ()) = chan_c_lock (chan)
val rfcnt = chan_c_rfcnt_get (chan)
//
in
//
if
rfcnt <= 1
then let
  // the last owner: nobody else can reach the channel
  val () = chan_c_unlock (pf | chan)
  val xs = chan_buf_drain<a>(chan, list_vt_nil())
  val () = chan_c_free (chan)
in
  xs
end // end of [then]
else let
  val () = chan_c_rfcnt_set (chan, rfcnt - 1)
  val () = chan_c_unlock (pf | chan)
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
  val (pf | ()) = chan_c_lock (chan)
  val n = chan_c_rfcnt_get (chan)
  val () = chan_c_unlock (pf | chan)
in n
end // end of [chan_rfcnt]

implement
{}(*tmp*)
chan_capacity{a}(chan) = chan_c_cap (chan)

implement
{a}(*tmp*)
chan_size (chan) = let
  val (pf | ()) = chan_c_lock (chan)
  val n = chan_c_size (chan)
  val () = chan_c_unlock (pf | chan)
in sz2i(n)
end // end of [chan_size]

implement
{}(*tmp*)
chan_is_closed{a}(chan) = let
  val (pf | ()) = chan_c_lock (chan)
  val b = chan_c_is_closed (chan)
  val () = chan_c_unlock (pf | chan)
in b
end // end of [chan_is_closed]

implement
{}(*tmp*)
chan_close{a}(chan) = let
//
val (pf | ()) = chan_c_lock (chan)
val () = chan_c_set_closed (chan)
val () = chan_c_wake_all (pf | chan)
val () = chan_c_unlock (pf | chan)
//
in
  // nothing
end // end of [chan_close]

(* ****** ****** *)

implement
{a}(*tmp*)
chan_send_opt
  (chan, x0) = let
  val (pf | p) = chan_c_send_begin (chan)
in
  chan_send_aux<a>(pf | chan, x0, p)
end
// end of [chan_send_opt]

implement
{a}(*tmp*)
chan_send_aux
  {l} (pf | chan, x0, p) =
(
if
ptr_is_one (p)
then let
  prval sendb_refused() = pf in Some_vt(x0)
end // end of [then]
else (
if
ptr_isnot_null (p)
then let
  prval sendb_ok(pflk) = pf
  val () = $UN.ptr0_set<a>(p, x0)
  val () = chan_c_send_end (pflk | chan)
in
  None_vt()
end // end of [then]
else let
  // the buffer is full: park, the lock is held on return
  prval sendb_full(pflk) = pf
  val () = chan_c_park_send (pflk | chan)
  val (pf | p) = chan_c_send_recheck (pflk | chan)
in
  chan_send_aux<a>(pf | chan, x0, p)
end // end of [else]
) (* end of [else] *)
) (* end of [chan_send_aux] *)

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
  val (pf | p) = chan_c_recv_begin (chan)
in
  chan_recv_aux<a>(pf | chan, p)
end
// end of [chan_recv]

implement
{a}(*tmp*)
chan_recv_aux
  {l} (pf | chan, p) =
(
if
ptr_is_one (p)
then let
  prval recvb_refused() = pf in None_vt()
end // end of [then]
else (
if
ptr_isnot_null (p)
then let
  prval recvb_ok(pflk) = pf
  val x0 = $UN.ptr0_get<a>(p)
  val () = chan_c_recv_end (pflk | chan)
in
  Some_vt(x0)
end // end of [then]
else let
  // empty and open: park, the lock is held on return
  prval recvb_empty(pflk) = pf
  val () = chan_c_park_recv (pflk | chan)
  val (pf | p) = chan_c_recv_recheck (pflk | chan)
in
  chan_recv_aux<a>(pf | chan, p)
end // end of [else]
) (* end of [else] *)
) (* end of [chan_recv_aux] *)

(* ****** ****** *)

implement
{a}(*tmp*)
chan_trysend
  (chan, x0) = let
//
val (pf | p) = chan_c_trysend_begin (chan)
//
in
//
if
ptr_is_one (p)
then let
  prval sendb_refused() = pf in Some_vt(x0)
end // end of [then]
else (
if
ptr_isnot_null (p)
then let
  prval sendb_ok(pflk) = pf
  val () = $UN.ptr0_set<a>(p, x0)
  val () = chan_c_send_end (pflk | chan)
in
  None_vt()
end // end of [then]
else let
  // [trysend_begin] does not return NULL
  prval sendb_full(pflk) = pf
  val () = chan_c_unlock (pflk | chan)
in
  Some_vt(x0)
end // end of [else]
) (* end of [else] *)
//
end // end of [chan_trysend]

implement
{a}(*tmp*)
chan_tryrecv (chan) = let
//
val (pf | p) = chan_c_tryrecv_begin (chan)
//
in
//
if
ptr_is_one (p)
then let
  prval recvb_refused() = pf in None_vt()
end // end of [then]
else (
if
ptr_isnot_null (p)
then let
  prval recvb_ok(pflk) = pf
  val x0 = $UN.ptr0_get<a>(p)
  val () = chan_c_recv_end (pflk | chan)
in
  Some_vt(x0)
end // end of [then]
else let
  // [tryrecv_begin] does not return NULL
  prval recvb_empty(pflk) = pf
  val () = chan_c_unlock (pflk | chan)
in
  None_vt()
end // end of [else]
) (* end of [else] *)
//
end // end of [chan_tryrecv]

(* ****** ****** *)
//
// the non-allocating receive
//
extern
fun{a:vt0p}
chan_recv_ref_aux {l:addr}
  (pf: recvb_v(l) | c: !ptr, x: &a? >> opt(a, b), p: ptr(l)): #[b:bool] bool(b)
//
implement
{a}(*tmp*)
chan_recv_ref (chan, x) = let
  val (pf | p) = chan_c_recv_begin (chan)
in
  chan_recv_ref_aux<a>(pf | chan, x, p)
end // end of [chan_recv_ref]

implement
{a}(*tmp*)
chan_recv_ref_aux
  {l} (pf | chan, x, p) =
(
if
ptr_is_one (p)
then let
  prval recvb_refused() = pf
  prval () = opt_none{a}(x)
in
  false
end // end of [then]
else (
if
ptr_isnot_null (p)
then let
  prval recvb_ok(pflk) = pf
  val () = x := $UN.ptr0_get<a>(p)
  val () = chan_c_recv_end (pflk | chan)
  prval () = opt_some{a}(x)
in
  true
end // end of [then]
else let
  prval recvb_empty(pflk) = pf
  val () = chan_c_park_recv (pflk | chan)
  val (pf | p) = chan_c_recv_recheck (pflk | chan)
in
  chan_recv_ref_aux<a>(pf | chan, x, p)
end // end of [else]
) (* end of [else] *)
) (* end of [chan_recv_ref_aux] *)

implement
{a}(*tmp*)
chan_tryrecv_ref (chan, x) = let
//
val (pf | p) = chan_c_tryrecv_begin (chan)
//
in
//
if
ptr_is_one (p)
then let
  prval recvb_refused() = pf
  prval () = opt_none{a}(x)
in
  false
end // end of [then]
else (
if
ptr_isnot_null (p)
then let
  prval recvb_ok(pflk) = pf
  val () = x := $UN.ptr0_get<a>(p)
  val () = chan_c_recv_end (pflk | chan)
  prval () = opt_some{a}(x)
in
  true
end // end of [then]
else let
  // [tryrecv_begin] does not return NULL
  prval recvb_empty(pflk) = pf
  val () = chan_c_unlock (pflk | chan)
  prval () = opt_none{a}(x)
in
  false
end // end of [else]
) (* end of [else] *)
//
end // end of [chan_tryrecv_ref]

(* ****** ****** *)
//
// the batches: one lock acquisition for many items
//
extern
fun{a:vt0p}
chan_recv_batch_loop
  (pf: afiber_locked_v | c: !ptr, n: int, acc: List0_vt(a)): List0_vt(a)
extern
fun{a:vt0p}
chan_send_list_loop
  (pf: afiber_locked_v | c: !ptr, xs: List0_vt(a)): List0_vt(a)
//
implement
{a}(*tmp*)
chan_recv_batch (chan, n) = let
  val (pf | ()) = chan_c_lock (chan)
in
  chan_recv_batch_loop<a>(pf | chan, n, list_vt_nil())
end // end of [chan_recv_batch]

implement
{a}(*tmp*)
chan_recv_batch_loop
  (pf | chan, n, acc) =
(
if
n > 0 && chan_c_size (chan) > i2sz(0)
then let
  val x = $UN.ptr0_get<a>(chan_c_pop (chan))
  val () = chan_c_wake_send (pf | chan)
in
  chan_recv_batch_loop<a>(pf | chan, n-1, list_vt_cons(x, acc))
end // end of [then]
else (
case+ acc of
| list_vt_cons _ => let
    // took something (or [n] items): done
    val () = chan_c_unlock (pf | chan)
  in
    list_vt_reverse<a>(acc)
  end // end of [list_vt_cons]
| ~list_vt_nil() =>
  (
    if
    chan_c_is_closed (chan)
    then let
      val () = chan_c_unlock (pf | chan) in list_vt_nil()
    end // end of [then]
    else let
      val () = chan_c_park_recv (pf | chan)
    in
      chan_recv_batch_loop<a>(pf | chan, n, list_vt_nil())
    end // end of [else]
  ) (* end of [list_vt_nil] *)
) (* end of [else] *)
) (* end of [chan_recv_batch_loop] *)

implement
{a}(*tmp*)
chan_send_list (chan, xs) = let
  val (pf | ()) = chan_c_lock (chan)
in
  chan_send_list_loop<a>(pf | chan, xs)
end // end of [chan_send_list]

implement
{a}(*tmp*)
chan_send_list_loop
  (pf | chan, xs) =
(
case+ xs of
| ~list_vt_nil() => let
    val () = chan_c_unlock (pf | chan) in list_vt_nil()
  end // end of [list_vt_nil]
| ~list_vt_cons(x, xs1) =>
  (
    if
    chan_c_is_closed (chan)
    then let
      val () = chan_c_unlock (pf | chan) in list_vt_cons(x, xs1)
    end // end of [then]
    else (
      if
      chan_c_is_full (chan)
      then let
        // the receivers were woken by the pushes before; now wait for room
        val () = chan_c_park_send (pf | chan)
      in
        chan_send_list_loop<a>(pf | chan, list_vt_cons(x, xs1))
      end // end of [then]
      else let
        val () = $UN.ptr0_set<a>(chan_c_push (chan), x)
        val () = chan_c_wake_recv (pf | chan)
      in
        chan_send_list_loop<a>(pf | chan, xs1)
      end // end of [else]
    ) (* end of [else] *)
  ) (* end of [list_vt_cons] *)
) (* end of [chan_send_list_loop] *)

(* ****** ****** *)

end // end of [local]

(* ****** ****** *)

(* end of [afiberchan.dats] *)
