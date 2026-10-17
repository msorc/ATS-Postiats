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

staload "libats/SATS/arena.sats"

abstype symbol_type = ptr // boxed
typedef symbol = symbol_type
typedef symbolist = glist(symbol)
typedef symbolopt = gopt(symbol)

(* ****** ****** *)

val symbol_empty : symbol = "ext#patsopt_symbol_empty"

(* ****** ****** *)
//
val symbol_NEG : symbol = "ext#patsopt_symbol_NEG" // ~
//
val symbol_ADD : symbol = "ext#patsopt_symbol_ADD" // +
val symbol_SUB : symbol = "ext#patsopt_symbol_SUB" // -
val symbol_MUL : symbol = "ext#patsopt_symbol_MUL" // *
val symbol_DIV : symbol = "ext#patsopt_symbol_DIV" // /
//
val symbol_AMPERSAND : symbol = "ext#patsopt_symbol_AMPERSAND" // & // read-only
val symbol_AMPERBANG : symbol = "ext#patsopt_symbol_AMPERBANG" // &! // read-write
val symbol_AMPERQMARK : symbol = "ext#patsopt_symbol_AMPERQMARK" // &? // write-only
//
val symbol_AT : symbol = "ext#patsopt_symbol_AT" // @
val symbol_BACKSLASH : symbol = "ext#patsopt_symbol_BACKSLASH" // \
val symbol_BANG : symbol = "ext#patsopt_symbol_BANG" // !
val symbol_COLONEQ : symbol = "ext#patsopt_symbol_COLONEQ" // := // assign
val symbol_COLONEQCOLON : symbol = "ext#patsopt_symbol_COLONEQCOLON" // :=: // exhange
//
val symbol_GT : symbol = "ext#patsopt_symbol_GT" // >
val symbol_GTEQ : symbol = "ext#patsopt_symbol_GTEQ" // >=
val symbol_LT : symbol = "ext#patsopt_symbol_LT" // <
val symbol_LTEQ : symbol = "ext#patsopt_symbol_LTEQ" // <=
//
val symbol_EQ : symbol = "ext#patsopt_symbol_EQ" // =
val symbol_EQEQ : symbol = "ext#patsopt_symbol_EQEQ" // ==
val symbol_LTGT : symbol = "ext#patsopt_symbol_LTGT" // <>
val symbol_BANGEQ : symbol = "ext#patsopt_symbol_BANGEQ" // !=
//
val symbol_GTLT : symbol = "ext#patsopt_symbol_GTLT" // ><
//
val symbol_GTGT : symbol = "ext#patsopt_symbol_GTGT" // >>
val symbol_LTLT : symbol = "ext#patsopt_symbol_LTLT" // <<
//
val symbol_LAND : symbol = "ext#patsopt_symbol_LAND" // &&
val symbol_LOR : symbol = "ext#patsopt_symbol_LOR" // ||
val symbol_LRBRACKETS : symbol = "ext#patsopt_symbol_LRBRACKETS" // []
val symbol_MINUSGT : symbol = "ext#patsopt_symbol_MINUSGT" // ->
val symbol_QMARK : symbol = "ext#patsopt_symbol_QMARK" // ?
val symbol_QMARKBANG : symbol = "ext#patsopt_symbol_QMARKBANG" // ?!
val symbol_TILDE : symbol = "ext#patsopt_symbol_TILDE" // ~
val symbol_UNDERSCORE : symbol = "ext#patsopt_symbol_UNDERSCORE" // _
//
val symbol_VBOX : symbol = "ext#patsopt_symbol_VBOX" // for vbox pattern
//
val symbol_LAMAT : symbol = "ext#patsopt_symbol_LAMAT" // lam@
val symbol_LLAMAT : symbol = "ext#patsopt_symbol_LLAMAT" // llam@
(*
//
// YD-2018-07-07:
// 'ref@' is removed since 2015-12-10
//
val symbol_REFAT : symbol // ref@
*)
//
(* ****** ****** *)
//
// HX: for pre-defined predicative sorts
//
val symbol_INT : symbol = "ext#patsopt_symbol_INT"
val symbol_BOOL : symbol = "ext#patsopt_symbol_BOOL"
val symbol_ADDR : symbol = "ext#patsopt_symbol_ADDR"
//
(*
val symbol_CHAR : symbol
*)
//
val symbol_REAL : symbol = "ext#patsopt_symbol_REAL"
//
val symbol_FLOAT : symbol = "ext#patsopt_symbol_FLOAT"
val symbol_STRING : symbol = "ext#patsopt_symbol_STRING"
//
val symbol_CLS : symbol = "ext#patsopt_symbol_CLS" // for nominal classes
//
val symbol_EFF : symbol = "ext#patsopt_symbol_EFF" // for sets of effects
//
val symbol_TKIND : symbol = "ext#patsopt_symbol_TKIND" // HX-2012-05-23: for template args
//
// HX: for pre-defined impredicative sorts
//
val symbol_PROP : symbol = "ext#patsopt_symbol_PROP"
val symbol_TYPE : symbol = "ext#patsopt_symbol_TYPE"
val symbol_T0YPE : symbol = "ext#patsopt_symbol_T0YPE"
val symbol_VIEW : symbol = "ext#patsopt_symbol_VIEW"
val symbol_VTYPE : symbol = "ext#patsopt_symbol_VTYPE"
val symbol_VT0YPE : symbol = "ext#patsopt_symbol_VT0YPE"
val symbol_VIEWTYPE : symbol = "ext#patsopt_symbol_VIEWTYPE"
val symbol_VIEWT0YPE : symbol = "ext#patsopt_symbol_VIEWT0YPE"
//
val symbol_TYPES : symbol = "ext#patsopt_symbol_TYPES"
//
(* ****** ****** *)

val symbol_TRUE_BOOL : symbol = "ext#patsopt_symbol_TRUE_BOOL"
val symbol_FALSE_BOOL : symbol = "ext#patsopt_symbol_FALSE_BOOL"

(* ****** ****** *)

val symbol_DEFINED : symbol = "ext#patsopt_symbol_DEFINED" // defined
val symbol_UNDEFINED : symbol = "ext#patsopt_symbol_UNDEFINED" // undefined

(* ****** ****** *)

val symbol_TUPZ : symbol = "ext#patsopt_symbol_TUPZ" // TUPSIZE // for syndef

(* ****** ****** *)

val symbol_CAR : symbol = "ext#patsopt_symbol_CAR" // car
val symbol_CDR : symbol = "ext#patsopt_symbol_CDR" // mfcdr
val symbol_ISLIST : symbol = "ext#patsopt_symbol_ISLIST" // islist
val symbol_ISCONS : symbol = "ext#patsopt_symbol_ISCONS" // iscons
val symbol_ISNIL : symbol = "ext#patsopt_symbol_ISNIL"  // islist

(* ****** ****** *)
//
val symbol__STDIN__ : symbol = "ext#patsopt_symbol__STDIN__"
val symbol__STRING__ : symbol = "ext#patsopt_symbol__STRING__"
//
(* ****** ****** *)
//
val symbol_PATSHOME : symbol = "ext#patsopt_symbol_PATSHOME"
//
val symbol_PATSCONTRIB : symbol = "ext#patsopt_symbol_PATSCONTRIB"
//
val symbol_PATSHOMELOCS : symbol = "ext#patsopt_symbol_PATSHOMELOCS"
//
val symbol_PATSRELOCROOT : symbol = "ext#patsopt_symbol_PATSRELOCROOT"
//
(* ****** ****** *)
//
val symbol_ATS_PACKNAME : symbol = "ext#patsopt_symbol_ATS_PACKNAME"
//
(*
//
// HX-2014-06-06:
// this one is no longer in use
//
val symbol_ATS_STALOADFLAG : symbol
*)
val symbol_ATS_DYNLOADFLAG : symbol = "ext#patsopt_symbol_ATS_DYNLOADFLAG"
//
val symbol_ATS_DYNLOADNAME : symbol = "ext#patsopt_symbol_ATS_DYNLOADNAME"
//
val symbol_ATS_MAINATSFLAG : symbol = "ext#patsopt_symbol_ATS_MAINATSFLAG"
//
val symbol_ATS_EXTERN_PREFIX : symbol = "ext#patsopt_symbol_ATS_EXTERN_PREFIX"
val symbol_ATS_STATIC_PREFIX : symbol = "ext#patsopt_symbol_ATS_STATIC_PREFIX"
//
(* ****** ****** *)
//
fun
eq_symbol_symbol (x1: symbol, x2: symbol):<> bool
fun
neq_symbol_symbol (x1: symbol, x2: symbol):<> bool
fun
compare_symbol_symbol (x1: symbol, x2: symbol):<> Sgn
//
overload = with eq_symbol_symbol
overload != with eq_symbol_symbol
overload compare with compare_symbol_symbol
//
(* ****** ****** *)
//
fun print_symbol (x: symbol): void
fun prerr_symbol (x: symbol): void
//
overload print with print_symbol
overload prerr with prerr_symbol
//
fun fprint_symbol (out: FILEref, x: symbol): void
fun fprint_symbolopt (out: FILEref, opt: symbolopt): void
//
(* ****** ****** *)

fun symbol_get_name (x: symbol):<> string
fun symbol_get_stamp (x: symbol):<> uint

(* ****** ****** *)

fun symbol_make_string (name: string): symbol

(* ****** ****** *)

(* end of [pats_symbol.sats] *)
