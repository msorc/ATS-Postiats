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
// (afiber). A channel is reference-counted so that
// several fibers can own it: each [llam] captures its own
// [chan_ref]. Sending moves a (possibly linear) value into
// the channel; receiving moves it out. [chan_send] parks the
// current fiber while the channel is full, [chan_recv] while
// it is empty; [chan_close] wakes every parked fiber, after
// which sending fails and receiving drains then gives None.
//
%{#
#include "contrib/afiber/CATS/afiberchan.cats"
%} // end of [%{#]

(* ****** ****** *)
//
#define
ATS_PACKNAME "ATSCNTRB.afiberchan"
//
(* ****** ****** *)
//
absvtype
chan_vtype (a:vt@ype+) = ptr
vtypedef chan_vt (a:vt0p) = chan_vtype (a)
//
(* ****** ****** *)
//
fun{a:vt0p}
chan_make (cap: intGt(0)): chan_vt(a)
//
fun{a:vt0p}
chan_ref (ch: !chan_vt(a)): chan_vt(a) // one more owner
//
fun{a:vt0p}
chan_unref (ch: chan_vt(a)): List_vt(a) // the last owner gets the unreceived items
fun{a:t0p}
chan_unref_type (ch: chan_vt(a)): void // [chan_unref] plus [list_vt_free]
//
(* ****** ****** *)
//
fun{}
chan_rfcnt{a:vt0p} (ch: !chan_vt(a)): intGt(0)
fun{}
chan_capacity{a:vt0p} (ch: !chan_vt(a)): intGt(0)
fun{a:vt0p}
chan_size (ch: !chan_vt(a)): int // the number of buffered items
//
fun{}
chan_is_closed{a:vt0p} (ch: !chan_vt(a)): bool
fun{}
chan_close{a:vt0p} (ch: !chan_vt(a)): void // idempotent
//
(* ****** ****** *)
//
fun{a:vt0p}
chan_send_opt
  (ch: !chan_vt(a), x: a): Option_vt(a) // None: sent; Some(x): closed
fun{a:vt0p}
chan_send (ch: !chan_vt(a), x: a): void // fatal if closed
//
fun{a:vt0p}
chan_recv (ch: !chan_vt(a)): Option_vt(a) // None: closed and drained
//
fun{a:vt0p}
chan_trysend
  (ch: !chan_vt(a), x: a): Option_vt(a) // Some(x): full or closed
fun{a:vt0p}
chan_tryrecv (ch: !chan_vt(a)): Option_vt(a) // None: empty or closed
//
(* ****** ****** *)

(* end of [afiberchan.sats] *)
