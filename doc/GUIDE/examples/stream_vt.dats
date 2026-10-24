(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(*
** $delay -> $ldelay: a lazy stream is a stream_vt, consumed
** as it is read; the unread rest is freed with ~.
*)
#include "share/atspre_staload.hats"
//
fun from (n: int): stream_vt(int) =
  $ldelay (stream_vt_cons (n, from (n+1)))
//
implement main0 () = {
  // stream_vt_nth_exn consumes the stream (the unread rest is freed)
  val x = stream_vt_nth_exn (from (1), 4)
  val () = println! ("the fifth natural number = ", x)
}
