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
// (libats/afiber). A channel is reference-counted so that
// several fibers can own it: each [llam] captures its own
// [chan_ref]. Sending moves a (possibly linear) value into
// the channel; receiving moves it out. [chan_send] parks the
// current fiber while the channel is full, [chan_recv] while
// it is empty; [chan_close] wakes every parked fiber, after
// which sending fails and receiving drains then gives None.
//
%{#
#include "libats/CATS/afiberchan.cats"
%} // end of [%{#]

(* ****** ****** *)
//
#define
ATS_PACKNAME "ATSLIB.libats.afiberchan"
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
