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

(* ****** ****** *)

fun
eqref_type{a:t@ype}(x1: a, x2: a):<> bool

(* ****** ****** *)
//
// HX: the [base] is stored inside [rep]
//
fun llint_make_string (rep: string): llint
//
(* ****** ****** *)

fun double_make_string (rep: string): double

(* ****** ****** *)
//
// HX: finding the base of [rep]
//
fun intrep_get_base (rep: string): int
//
// HX: finding the length of the suffix [UuLl]*
fun intrep_get_nsfx (rep: string): uint // in the [rep]
//
(* ****** ****** *)
//
// HX: finding the length of the suffix [FfLl]*
fun float_get_nsfx (rep: string): uint // in the [rep]
//
(* ****** ****** *)

fun
dirpath_append
  (dir: string, path: string, sep: char): Strptr1
// end of [dirpath_append]

(* ****** ****** *)
//
fun
print_stropt(opt: Stropt): void
fun
prerr_stropt(opt: Stropt): void
fun
fprint_stropt(out: FILEref, opt: Stropt): void
//
(* ****** ****** *)

fun{
a:t@ype
} fprintlst
(
  out: FILEref
, xs: glist(a)
, sep: string
, fprint: (FILEref, a) -> void
) : void // end of [fprintlst]

fun{
a:t@ype
} fprintopt
(
  out: FILEref
, opt: gopt(a)
, fprint: (FILEref, a) -> void
) : void // end of [fprintopt]

(* ****** ****** *)
//
// HX-2011:
// for ordered lists
//
abstype lstord_type (a:t@ype) = ptr
typedef lstord(a:t@ype) = lstord_type(a)
//
fun{a:t@ype} lstord_nil (): lstord (a)
fun{a:t@ype} lstord_sing (x: a): lstord (a)
//
fun{a:t@ype}
lstord_insert
(
  xs: lstord a, x: a, cmp: (a, a) -> int
) : lstord (a) // end of [lstord_insert]
fun{a:t@ype}
lstord_union
(
  xs: lstord a, ys: lstord a, cmp: (a, a) -> int
) : lstord (a) // end of [lstord_union]

(*
** HX: it returns a list of the duplicates in [xs]
*)
fun{a:t@ype} lstord_get_dups
  (xs: lstord a, cmp: (a, a) -> int): glist(a)
// end of [lstord_get_dups]

fun{a:t@ype} lstord2list (xs: lstord a): glist(a)

(* ****** ****** *)
//
abstype charset_type = ptr
typedef charset = charset_type
//
typedef charlst = glist(char)
vtypedef charlst_vt = List_vt (char)
//
fun charset_sing (x: char): charset
fun charset_is_member (xs: charset, x: char): bool
fun charset_add (xs: charset, x: char): charset
//
fun charset_listize (xs: charset): charlst_vt
//
fun fprint_charset (out: FILEref, xs: charset): void
//
(* ****** ****** *)

(*
** HX: [queue_get_strptr1] relied on libats/linqueue_arr, which
** is gone; see PORTING.md (Open problems)
*)

(* ****** ****** *)

local

staload FCNTL = "libats/libc/SATS/fcntl.sats"
staload UNISTD = "libats/libc/SATS/unistd.sats"

in (*in-of-local*)

stadef fildes_v = $UNISTD.fildes_v

(*
//
// HX: [fd] is regular: no support for pipe
// HX: the function returns [strptr_null] as error indication
//
*)
fun
file2strptr
  {fd:int} (
  pf: !fildes_v fd  | fd: int fd
) : Strptr0 = "patsopt_file2strptr" // end of [file2strptr]
//
end // end of [local]

(* ****** ****** *)

fun{
a:t@ype
} tostring_fprint
  (prfx: string, fpr: (FILEref, a) -> void, x: a): Strptr0
// end of [tostring_fprint]

(* ****** ****** *)
//
fun
ptr_as_volatile (p: ptr): void // for stopping optimization
//
(* ****** ****** *)

(* end of [pats_utils.sats] *)
