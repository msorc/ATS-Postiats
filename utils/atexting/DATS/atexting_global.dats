(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-2016 Hongwei Xi, ATS Trustful Software, Inc.
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

(* Author: Hongwei Xi *)
(* Authoremail: gmhwxiATgmailDOTcom *)
(* Start time: January, 2016 *)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)
//
#staload "./../SATS/atexting.sats"
//
#staload "libats/SATS/arena.sats" // HX-2026-10
#staload _ = "libats/DATS/arena.dats"
//
(* ****** ****** *)

local
//
//
// HX-2026-10: no GC (made of a static var)
//
var
the_nsharp_ref_var: int = 0
val the_nsharp_ref =
  ref_make_viewptr{int}(view@the_nsharp_ref_var | addr@the_nsharp_ref_var)
//
in (* in-of-local *)
//
implement
the_nsharp_get() = the_nsharp_ref[]
implement
the_nsharp_set(ns) = the_nsharp_ref[] := ns
//
end // end of [local]

(* ****** ****** *)

#staload
FIL = {
//
#define
GLOBALS_targetloc
"\
$PATSHOME/contrib\
/atscntrb/atscntrb-hx-globals"
//
#staload "./../SATS/atexting.sats"
//
typedef T = fil_t
//
#include "{$GLOBALS}/HATS/gstacklst.hats"
//
implement
the_filename_get
  ((*void*)) = get_top_exn()
//
implement
the_filename_pop() = pop_exn()
implement
the_filename_push(fil) = push(fil)
//
} (* end of [staload] *)

(* ****** ****** *)

#staload
PARERR = {
//
#define
GLOBALS_targetloc
"\
$PATSHOME/contrib\
/atscntrb/atscntrb-hx-globals"
//
#staload"./../SATS/atexting.sats"
//
typedef T = parerr
//
#staload"prelude/DATS/list_vt.dats"
//
#include"{$GLOBALS}/HATS/gstacklst.hats"
//
(* ****** ****** *)
//
implement
the_parerrlst_clear() =
  list_vt_free<T>(pop_all((*void*)))
//
(* ****** ****** *)
//
implement
the_parerrlst_length() = get_size()
//
(* ****** ****** *)
//
implement
the_parerrlst_insert(err) = push(err)
//
(* ****** ****** *)
//
implement
the_parerrlst_pop_all((*void*)) = pop_all()
//
(* ****** ****** *)
//
} (* end of [staload] *)

(* ****** ****** *)

staload
TEXTDEF = {

(* ****** ****** *)
//
staload
"./../SATS/atexting.sats"
//
(* ****** ****** *)

implement
fprint_val<atextdef> = fprint_atextdef

(* ****** ****** *)

implement
fprint_atextdef
  (out, def0) = (
//
case+ atextdef_view(def0) of
| ~TEXTDEFnil() => fprint(out, "atextdef_TEXTDEFnil()")
| ~TEXTDEFval _ => fprint(out, "atextdef_TEXTDEFval(...)")
| ~TEXTDEFfun _ => fprint(out, "atextdef_TEXTDEFfun(...)")
| ~TEXTDEFfstr _ => fprint(out, "atextdef_TEXTDEFfstr(...)")
//
) (* end of [fprint_atextdef] *)

(* ****** ****** *)
//
implement
the_atextdef_search
  (k0) =
(
  the_atextmap_search(k0)
)
//
(* ****** ****** *)

implement
the_atextdef_search2
  (k0) = let
//
val def =
  the_atextstk_search(k0)
//
in
//
case+ atextdef_view(def) of
| ~TEXTDEFnil() =>
  the_atextdef_search(k0)
| v0(*non-TEXTDEFnil*) => (atextdef_view_free(v0); def)
//
end // end of [the_atextdef_search2]

(* ****** ****** *)

local
//
typedef
key = string
and
itm = atextdef
//
vtypedef
keyitmlst_vt =
  List0_vt@(key, itm)
//
typedef
mystack = ref(keyitmlst_vt)
//
//
// HX-2026-10: no GC (made of a static var)
//
var
the_atextstk_var: keyitmlst_vt = list_vt_nil
val the_atextstk =
  ref_make_viewptr{keyitmlst_vt}(view@the_atextstk_var | addr@the_atextstk_var)
//
assume
the_atextstk_v(n:int) = unit_v
//
in (* in-of-local *)
//
implement
the_atextstk_pop1
(pf | (*void*)) =
{
//
prval unit_v() = pf
//
val
(vbox pf | p0) =
ref_get_viewptr(the_atextstk)
//
val-
~list_vt_cons(_, kxs) = !p0
val ((*void*)) = (!p0 := kxs)
//
} (* end of [the_atextstk_pop] *)
//
implement
the_atextstk_push1
  (k, x) =
  (unit_v | ()) where
{
//
val
(vbox pf | p0) =
ref_get_viewptr(the_atextstk)
//
val kxs = !p0
val ((*void*)) =
  (!p0 := list_vt_cons((k, x), kxs))
//
} (* end of [the_atextstk_pop] *)
//
implement
the_atextstk_search
  (k0) = let
//
fun
loop
(
  kxs: !keyitmlst_vt
) : itm =
(
case+ kxs of
| list_vt_nil
    () => atextdef_TEXTDEFnil()
  // list_vt_nil
| @list_vt_cons(kx, kxs_) =>
  (
    if k0 = kx.0
      then let val res = kx.1 in fold@(kxs); res end
      else (
        let val res = loop(kxs_) in fold@(kxs); res end
      ) (* else *)
    // end of [if]
  ) (* end of [list_vt_cons] *)
)
//
val
(vbox pf | p0) =
ref_get_viewptr(the_atextstk)
//
in
  $effmask_ref(loop(!p0))
end // end of [the_atextstk_search]
//
end // end of [local]

(* ****** ****** *)

local
//
// HX-2026-10: no GC
// the map is a linear hashtable (hashtbl_chain) that is
// kept as a pointer: it is taken out and put back by each
// operation (the definitions are in the global arena)
//
typedef key = string and itm = atextdef
//
staload UN = "prelude/SATS/unsafe.sats"
staload "libats/SATS/hashtbl_chain.sats"
staload _ = "libats/DATS/qlist.dats"
staload _ = "libats/DATS/hashfun.dats"
staload _ = "libats/DATS/linmap_list.dats"
staload _ = "libats/DATS/hashtbl_chain.dats"
//
vtypedef map = hashtbl(key, itm)
//
var
the_atextmap_var: ptr =
  $UN.castvwtp0{ptr}(hashtbl_make_nil<key,itm>(i2sz(1024)))
val
the_atextmap =
  ref_make_viewptr{ptr}(view@the_atextmap_var | addr@the_atextmap_var)
//
fn
the_atextmap_takeout
  ((*void*)): map = $UN.castvwtp0{map}(the_atextmap[])
fn
the_atextmap_putback
  (tbl: map): void = let
  val _ = $UN.castvwtp0{ptr}(tbl) in ((*void*))
end // end of [the_atextmap_putback]
//
in (* in-of-local *)

implement
the_atextmap_search
  (k0) = let
//
val tbl = the_atextmap_takeout()
val opt = hashtbl_search_opt<key,itm>(tbl, k0)
val ((*void*)) = the_atextmap_putback(tbl)
//
in
//
case+ opt of
| ~Some_vt(def0) => def0
| ~None_vt((*void*)) => atextdef_TEXTDEFnil()
//
end // end of [the_atextmap_search]

implement
the_atextmap_insert
  (k0, def0) = let
//
val tbl = the_atextmap_takeout()
var res: itm
val found = hashtbl_insert<key,itm>(tbl, k0, def0, res)
prval () = opt_clear(res)
val ((*void*)) = the_atextmap_putback(tbl)
//
in
  // nothing
end // end of [the_atextmap_insert]

implement
the_atextmap_remove
  (k0) = let
//
val tbl = the_atextmap_takeout()
val _(*removed*) = hashtbl_remove<key,itm>(tbl, k0)
val ((*void*)) = the_atextmap_putback(tbl)
//
in
  // nothing
end // end of [the_atextmap_remove]

implement
the_atextmap_insert_fstring
  (k0, fstr) =
  the_atextmap_insert(k0, atextdef_TEXTDEFfstr(fstr))

end // end of [local]

} (* end of [staload] *)

(* ****** ****** *)

(* end of [atexting_global.dats] *)
