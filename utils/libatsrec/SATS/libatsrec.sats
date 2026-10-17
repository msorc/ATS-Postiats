(* ****** ****** *)
(*
**
** Author: Hongwei Xi
** Start Time: May, 2017
** Authoremail: gmhwxiATgmailDOTcom
**
*)
(* ****** ****** *)
//
#staload
"libats/SATS/stringbuf.sats"
//
(* ****** ****** *)
//
fun
line_is_key
{n:int}(line: string(n)): intLt(n)
//
(* ****** ****** *)
//
fun
line_get_key
  {n:int}
(
  line: string(n), kend: intBtw(0, n)
) : Strptr1
//
(* ****** ****** *)
//
fun
line_is_nsharp
  (line: string, nsharp: intGte(1)): bool
//
(* ****** ****** *)
//
fun
line_add_value
  {n:int}
(
  line: string(n)
, kend: intBtw(0, n), buf: !stringbuf
) : int // end of [line_add_value]
//
fun
line_add_value_cont
  (line: string, buf: !stringbuf): int
//
(* ****** ****** *)
//
datavtype
linenum_vt =
| LINENUM of (int, Strptr1)
//
where
linenumlst_vt = List0_vt(linenum_vt)
//
(* ****** ****** *)
//
fun
lines_grouping
(
xs: stream_vt(linenum_vt)
) : stream_vt(linenumlst_vt)
//
(* ****** ****** *)
//
fun{}
process_key_value
  (key: Strptr1, value: Strptr1): void
//
(* ****** ****** *)
//
fun{}
process_linenumlst(linenumlst_vt): void
//
(* ****** ****** *)
//
// HX-2026-10: no GC
// A record is a linear list of (key, value) pairs
// in the order in which they appear in the file
// (it used to be a hashtable from libats/ML).
//
vtypedef
atsrec = List0_vt(@(Strptr1(*key*), Strptr1(*value*)))
//
fun
atsrec_free(kvs: atsrec): void
//
// HX: a copy of the value associated with [key]
//
fun
atsrec_search
  (kvs: !atsrec, key: string): Option_vt(Strptr1)
//
fun
fprint_atsrec(out: FILEref, kvs: !atsrec): void
//
overload fprint with fprint_atsrec
//
fun
streamize_fileref_atsrec
  (inp: FILEref): stream_vt(atsrec)
//
(* ****** ****** *)

(* end of [libatsrec.sats] *)
