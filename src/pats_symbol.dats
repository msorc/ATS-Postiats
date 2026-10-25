(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-2013 Hongwei Xi, ATS Trustful Software, Inc.
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
// Author: Hongwei Xi
// Authoremail: gmhwxi AT gmail DOT com
// Start Time: March, 2011
//
(* ****** ****** *)

#include "share/atspre_staload.hats"
#include "./pats_assert.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "./pats_symbol.sats"

(* ****** ****** *)
//
// HX: a symbol is a cell [name, stamp] in the global arena
//
assume symbol_type = ptr

(* ****** ****** *)

fn
symbol_new
  (name: string, stamp: uint): symbol = let
  val p = the_garena_alloc (i2sz(16))
  val () = $UN.ptr0_set<string> (p, name)
  val () = $UN.ptr0_set<uint> (ptr0_add_guint<byte> (p, i2sz(8)), stamp)
in
  $UN.cast{symbol}(p)
end // end of [symbol_new]

implement
symbol_get_name (x) = $effmask_all ($UN.ptr0_get<string> ($UN.cast{ptr}(x)))
implement
symbol_get_stamp (x) =
  $effmask_all ($UN.ptr0_get<uint> (ptr0_add_guint<byte> ($UN.cast{ptr}(x), i2sz(8))))

(* ****** ****** *)

local
//
staload
"libats/SATS/hashtbl_linprb.sats"
staload _(*anon*) =
"libats/DATS/hashtbl_linprb.dats"
staload "libats/SATS/hashfun.sats"
staload _(*anon*) =
"libats/DATS/hashfun.dats"
//
#define HASHTBLSZ 1024
//
typedef key = string
typedef itm = symbol
//
implement
hash_key<key> (x) =
  string_hash_multiplier (33UL, 5381UL, x)
implement
equal_key_key<key>
  (x1, x2) = (compare (x1, x2) = 0)
// end of [equal_key_key]
//
// HX: the symbol table lives forever (it is never freed)
//
val the_symtbl =
  $UN.castvwtp0{ptr}(hashtbl_make_nil<key,itm> (i2sz(HASHTBLSZ)))
//
in // in of [local]
//
val symbol_null = $UN.cast{symbol} (the_null_ptr) // HX: a hack!
//
fun symbol_insert (
  k: string, i: symbol
) : void = () where {
  val tbl = $UN.castvwtp0{hashtbl(key,itm)}(the_symtbl)
  val opt = hashtbl_insert_opt<key,itm> (tbl, k, i)
  val () = (case+ opt of ~Some_vt _ => () | ~None_vt () => ())
  val _ = $UN.castvwtp0{ptr}(tbl)
} // end of [symbol_insert]

fun symbol_search
  (k: string): symbol = let
  val tbl = $UN.castvwtp0{hashtbl(key,itm)}(the_symtbl)
  val opt = hashtbl_search_opt<key,itm> (tbl, k)
  val _ = $UN.castvwtp0{ptr}(tbl)
in
  case+ opt of
  | ~Some_vt (x) => x
  | ~None_vt ((*void*)) => symbol_null
end // end of [symbol_search]

end // end of [local]

(* ****** ****** *)

local
//
var the_symbol_stamp: uint = 0u
val the_symbol_stamp_ref =
  ref_make_viewptr{uint}(view@ the_symbol_stamp | addr@ the_symbol_stamp)
//
fun stamp_getinc
  (): uint = n where {
  val n = ref_get_elt (the_symbol_stamp_ref)
  val () = ref_set_elt (the_symbol_stamp_ref, n + 1u)
} // end of [stamp_getinc]
//
in // in of [local]

implement
symbol_make_string
  (name) = let
//
  fn symbol_is_null (x: symbol):<> bool = ptr_is_null ($UN.cast{ptr}(x))
//
  val x = symbol_search (name)
in
//
if
symbol_is_null (x)
then let
  val stamp = stamp_getinc ()
  val name = the_garena_strdup (name) // HX: the name is kept
  val x = symbol_new (name, stamp)
  val () = symbol_insert (name, x)
in
  x // newly created symbol
end // end of [then]
else x // HX: symbol of the given name is found
//
end // [symbol_make_string]

end // end of [local]

(* ****** ****** *)

implement
symbol_empty = x where {
  val x = symbol_make_string ""
//
// HX-2011-03-20:
// make sure that this is the first created symbol
//
  val () = assertloc (symbol_get_stamp (x) = 0u)
} // end of [symbol_empty]

(* ****** ****** *)
//
implement symbol_NEG = symbol_make_string "~"
//
implement symbol_ADD = symbol_make_string "+"
implement symbol_SUB = symbol_make_string "-"
implement symbol_MUL = symbol_make_string "*"
implement symbol_DIV = symbol_make_string "/"
//
implement symbol_AMPERSAND = symbol_make_string "&"
implement symbol_AMPERBANG = symbol_make_string "&!"
implement symbol_AMPERQMARK = symbol_make_string "&?"
//
implement symbol_AT = symbol_make_string "@"
implement symbol_BACKSLASH = symbol_make_string "\\"
implement symbol_BANG = symbol_make_string "!"
//
implement symbol_COLONEQ = symbol_make_string ":="
implement symbol_COLONEQCOLON = symbol_make_string ":=:"
//
implement symbol_GT = symbol_make_string ">"
implement symbol_GTEQ = symbol_make_string ">="
implement symbol_LT = symbol_make_string "<"
implement symbol_LTEQ = symbol_make_string "<="
//
implement symbol_EQ = symbol_make_string "="
implement symbol_EQEQ = symbol_make_string "=="
implement symbol_LTGT = symbol_make_string "<>"
implement symbol_BANGEQ = symbol_make_string "!="
//
implement symbol_GTLT = symbol_make_string "><"
//
implement symbol_GTGT = symbol_make_string ">>"
implement symbol_LTLT = symbol_make_string "<<"
//
implement symbol_LAND = symbol_make_string "&&"
implement symbol_LOR = symbol_make_string "||"
//
implement symbol_LRBRACKETS = symbol_make_string "[]"
//
implement symbol_MINUSGT = symbol_make_string "->"
//
implement symbol_QMARK = symbol_make_string "?"
implement symbol_QMARKBANG = symbol_make_string "?!"
//
implement symbol_TILDE = symbol_make_string "~"
implement symbol_UNDERSCORE = symbol_make_string "_"
//
implement symbol_VBOX = symbol_make_string "vbox"
//
implement symbol_LAMAT = symbol_make_string "lam@"
implement symbol_LLAMAT = symbol_make_string "llam@"
(*
//
// YD-2018-07-07:
// 'ref@' is removed since 2015-12-10
//
implement symbol_REFAT = symbol_make_string "ref@"
*)
//
(* ****** ****** *)
//
implement symbol_INT = symbol_make_string "int"
implement symbol_BOOL = symbol_make_string "bool"
implement symbol_ADDR = symbol_make_string "addr"
//
(*
implement symbol_CHAR = symbol_make_string "char"
*)
//
implement symbol_REAL = symbol_make_string "real"
//
implement symbol_FLOAT = symbol_make_string "float"
implement symbol_STRING = symbol_make_string "string"
//
implement symbol_CLS = symbol_make_string "cls" // nominal classes
//
implement symbol_EFF = symbol_make_string "eff" // sets of effects
//
implement symbol_TKIND = symbol_make_string "tkind" // template args
//
implement symbol_PROP = symbol_make_string "prop"
implement symbol_TYPE = symbol_make_string "type"
implement symbol_T0YPE = symbol_make_string "t@ype"
implement symbol_VIEW = symbol_make_string "view"
implement symbol_VTYPE = symbol_make_string "vtype"
implement symbol_VT0YPE = symbol_make_string "vt0ype"
implement symbol_VIEWTYPE = symbol_make_string "viewtype"
implement symbol_VIEWT0YPE = symbol_make_string "viewt0ype"
//
implement symbol_TYPES = symbol_make_string "types"
//
(* ****** ****** *)

implement
symbol_TRUE_BOOL = symbol_make_string "true_bool"
implement
symbol_FALSE_BOOL = symbol_make_string "false_bool"

(* ****** ****** *)

implement
symbol_DEFINED = symbol_make_string "defined"
implement
symbol_UNDEFINED = symbol_make_string "undefined"

(* ****** ****** *)

implement symbol_CAR = symbol_make_string "car"
implement symbol_CDR = symbol_make_string "cdr"
implement symbol_ISNIL = symbol_make_string "isnil"
implement symbol_ISCONS = symbol_make_string "iscons"
implement symbol_ISLIST = symbol_make_string "islist"

implement symbol_TUPZ = symbol_make_string "tupz"

(* ****** ****** *)
//
implement
symbol__STDIN__ = symbol_make_string "__STDIN__"
implement
symbol__STRING__ = symbol_make_string "__STRING__"
//
(* ****** ****** *)
//
implement
symbol_PATSHOME = symbol_make_string "PATSHOME"
//
implement
symbol_PATSCONTRIB = symbol_make_string "PATSCONTRIB"
//
implement
symbol_PATSHOMELOCS = symbol_make_string "PATSHOMELOCS"
//
implement
symbol_PATSRELOCROOT = symbol_make_string "PATSRELOCROOT"
//
(* ****** ****** *)
//
implement
symbol_ATS_PACKNAME = symbol_make_string "ATS_PACKNAME"
//
(*
// HX-2014-06-06: this one is no longer in use:
implement
symbol_ATS_STALOADFLAG = symbol_make_string "ATS_STALOADFLAG"
*)
implement
symbol_ATS_DYNLOADFLAG = symbol_make_string "ATS_DYNLOADFLAG"
//
(* ****** ****** *)

implement
symbol_ATS_DYNLOADNAME = symbol_make_string "ATS_DYNLOADNAME"

(* ****** ****** *)

implement
symbol_ATS_MAINATSFLAG = symbol_make_string "ATS_MAINATSFLAG"

(* ****** ****** *)

implement
symbol_ATS_EXTERN_PREFIX = symbol_make_string "ATS_EXTERN_PREFIX"
implement
symbol_ATS_STATIC_PREFIX = symbol_make_string "ATS_STATIC_PREFIX"

(* ****** ****** *)

implement
eq_symbol_symbol (x1, x2) = symbol_get_stamp (x1) = symbol_get_stamp (x2)
implement
neq_symbol_symbol (x1, x2) = symbol_get_stamp (x1) != symbol_get_stamp (x2)

(* ****** ****** *)

implement
compare_symbol_symbol (x1, x2) = let
  val n1 = symbol_get_stamp (x1) and n2 = symbol_get_stamp (x2)
in
  if n1 < n2 then ~1 else (if n1 > n2 then 1 else 0)
end // end of [compare_symbol_symbol]

(* ****** ****** *)

implement
print_symbol (x) = fprint_symbol (stdout_ref, x)
implement
prerr_symbol (x) = fprint_symbol (stderr_ref, x)

(* ****** ****** *)
//
implement
fprint_symbol
  (out, x) = fprint_string (out, symbol_get_name (x))
//
implement
fprint_symbolopt
  (out, opt) = let
in
//
case+ gopt_view(opt) of
| ~GOsome (x) => {
    val () =
      fprint_string (out, "Some(")
    val () = fprint_symbol (out, x)
    val () = fprint_string (out, ")")
  } (* end of [Some] *)
| ~GOnone () => fprint_string (out, "None()")
//
end (* end of [fprint_symbolopt] *)
//
(* ****** ****** *)

(* end of [pats_symbol.dats] *)
