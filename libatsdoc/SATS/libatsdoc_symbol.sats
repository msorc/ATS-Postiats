(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-20?? Hongwei Xi, ATS Trustworthy Software, Inc.
** All rights reserved
**
** ATS is free software;  you can  redistribute it and/or modify it under
** the terms of the GNU LESSER GENERAL PUBLIC LICENSE as published by the
** Free Software Foundation; either version 2.1, or (at your option)  any
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
(* ****** ****** *)
//
// Author: Hongwei Xi (hwxi AT cs DOT bu DOT edu)
// Start Time: April, 2011
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of the ATS1 version of this file).
// A symbol is the (interned) entry of a table that lives in C and is
// never freed; it does not need the initialization that the symbols of
// src/ do, and libatsdoc.a can be linked with libatsopt.a. [theAtextMap]
// (libatsdoc_atext.sats) keeps its values in the same table.
//
(* ****** ****** *)

%{#
#include "libatsdoc/CATS/libatsdoc_symbol.cats"
%}

(* ****** ****** *)

abstype symbol_type = ptr
typedef symbol = symbol_type

(* ****** ****** *)

val symbol_empty : symbol = "ext#libatsdoc_symbol_empty"

(* ****** ****** *)

fun eq_symbol_symbol (x1: symbol, x2: symbol):<> bool
overload = with eq_symbol_symbol
fun neq_symbol_symbol (x1: symbol, x2: symbol):<> bool
overload != with neq_symbol_symbol

fun compare_symbol_symbol (x1: symbol, x2: symbol):<> int
overload compare with compare_symbol_symbol

(* ****** ****** *)

fun fprint_symbol
  (out: FILEref, x: symbol): void
overload fprint with fprint_symbol
fun print_symbol (x: symbol): void
overload print with print_symbol
fun prerr_symbol (x: symbol): void
overload prerr with prerr_symbol

(* ****** ****** *)

typedef stamp = uint

fun symbol_get_name (x: symbol):<> string = "mac#libatsdoc_symbol_get_name"
fun symbol_get_stamp (x: symbol):<> stamp = "mac#libatsdoc_symbol_get_stamp"
fun symbol_make_string (name: string): symbol = "mac#libatsdoc_symbol_make_string"

(* ****** ****** *)

(* end of [libatsdoc_symbol.sats] *)
