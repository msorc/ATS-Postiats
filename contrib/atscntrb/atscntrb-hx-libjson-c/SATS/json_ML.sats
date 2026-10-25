(* ****** ****** *)
(*
**
** Author: Hongwei Xi
** Start Time: May, 2013
** Authoremail: gmhwxiATgmailDOTcom
**
*)
(* ****** ****** *)
(*
** A quasi ML-style API in ATS for json-c
*)
(* ****** ****** *)

(*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-2013 Hongwei Xi, ATS Trustful Software, Inc.
** All rights reserved
**
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

staload "./json.sats"

(* ****** ****** *)
//
#define
ATS_PACKNAME "ATSCNTRB.jsonc_ML"
#define
ATS_EXTERN_PREFIX
"atscntrb_jsonc_ML_" // prefix for external names
//
(* ****** ****** *)

//
// HX-2026-10: no GC
// A jsonval is a linear tree: it owns its strings, its
// array elements and its object fields; it is freed by
// [jsonval_free].
//
typedef json_int = llint
//
datavtype
jsonval =
  | JSONnul of ()
//
  | JSONint of (json_int)
  | JSONbool of (json_bool)
  | JSONfloat of (double)
  | JSONstring of (Strptr1)
//
  | JSONarray of (List0_vt(jsonval)) // array
  | JSONobject of (List0_vt(@(Strptr1, jsonval))) // hashtable
// end of [jsonval]
//
vtypedef jsonvalist = List0_vt(jsonval)
vtypedef labjsonval = @(Strptr1, jsonval)
vtypedef labjsonvalist = List0_vt(labjsonval)
//
vtypedef jsonvalist_vt = jsonvalist
//
(* ****** ****** *)
//
fun
jsonval_free(x: jsonval): void
fun
jsonval_copy(x: !jsonval): jsonval
//
(* ****** ****** *)
//
fun
print_jsonval(!jsonval): void
fun
prerr_jsonval(!jsonval): void
fun
fprint_jsonval(out: FILEref, x: !jsonval): void
//
overload print with print_jsonval
overload prerr with prerr_jsonval
overload fprint with fprint_jsonval
//
(* ****** ****** *)
//
fun
fprint_jsonvalist
  (out: FILEref, xs: !jsonvalist): void
fun
fprint_labjsonvalist
  (out: FILEref, lxs: !labjsonvalist): void
//
(* ****** ****** *)
//
fun jsonval_ofstring(str: string): jsonval
fun jsonval_tostring(jsv: !jsonval): Strptr1
//
(* ****** ****** *)
//
fun
json_object2val0(jso: json_object0): jsonval
fun
json_object2val1(jso: !json_object0): jsonval
//
(* ****** ****** *)
//
// HX: [jsonval_objectify] consumes its argument
//
fun jsonval_objectify(jsv: jsonval): json_object0
fun jsonval_objectify1(jsv: !jsonval): json_object0
//
(* ****** ****** *)

(* end of [json_ML.sats] *)
