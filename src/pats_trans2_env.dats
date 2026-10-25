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
// Start Time: September, 2011
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_trans2_env.dats).
// The environments are never freed [symenv]s kept as pointers; [filenv] is an
// 8-word block of the global arena. The proofs of ATS1 are gone (rule T1-5).
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

#include "./mylibies.hats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)

staload
FIL = "./pats_filename.sats"
typedef filename = $FIL.filename

(* ****** ****** *)

staload SYM = "./pats_symbol.sats"
staload SYN = "./pats_syntax.sats"
staload "./pats_syntax.sats"

(* ****** ****** *)

staload "./pats_errmsg.sats"
staload _(*anon*) = "./pats_errmsg.dats"
implement prerr_FILENAME<> () = prerr "pats_trans2_env"

(* ****** ****** *)

staload "./pats_symmap.sats"
staload _(*anon*) = "./pats_symmap.dats"
staload "./pats_symenv.sats"
staload _(*anon*) = "./pats_symenv.dats"
staload "./pats_staexp2.sats"
staload "./pats_dynexp2.sats"
staload "./pats_namespace.sats"
staload _(*anon*) = "./pats_namespace.dats"

(* ****** ****** *)

staload "./pats_trans2.sats"
staload "./pats_trans2_env.sats"

(* ****** ****** *)
//
// HX: a cell of the global arena that holds a flat value
//
fn{a:t@ype}
t2env_cell_make (x: a): ptr = let
  val p = the_garena_alloc (sizeof<a>)
  val () = $UN.ptr0_set<a> (p, x)
in
  p
end // end of [t2env_cell_make]
//
(* ****** ****** *)

local
//
// HX: the layout of a [filenv] (8 words):
// name, sort, sexp, dexp, decl2, decl3, tcimap, tvdmap
//
assume filenv_type = ptr
//
macdef FE_name = 0
macdef FE_sort = 1
macdef FE_sexp = 2
macdef FE_dexp = 3
macdef FE_decl2 = 4
macdef FE_decl3 = 5
macdef FE_tcimap = 6
macdef FE_tvdmap = 7
//
fn fe_setptr (p: ptr, x: ptr): void = $UN.ptr0_set<ptr> (p, x)
//
fn fe_addr (fenv: filenv, i: int): ptr =
  ptr0_add_guint<ptr> ($UN.cast{ptr}(fenv), $UN.cast{size_t}(i))
//
in (* in of [local] *)

implement
filenv_make
(
  fil, s2tm, s2im, d2im, d2cs
) = let
//
val p = the_garena_alloc (i2sz(64))
val fenv = $UN.cast{filenv}(p)
//
val () = $UN.ptr0_set<filename> (fe_addr (fenv, FE_name), fil)
val () = fe_setptr (fe_addr (fenv, FE_sort), $UN.castvwtp0{ptr}(s2tm))
val () = fe_setptr (fe_addr (fenv, FE_sexp), $UN.castvwtp0{ptr}(s2im))
val () = fe_setptr (fe_addr (fenv, FE_dexp), $UN.castvwtp0{ptr}(d2im))
val () = $UN.ptr0_set<d2eclist> (fe_addr (fenv, FE_decl2), d2cs)
//
// HX: decl3, tcimap and tvdmap start as None (a null pointer)
//
in
  fenv
end // end of [filenv_make]

implement
filenv_get_name (fenv) = $UN.ptr0_get<filename> (fe_addr (fenv, FE_name))

implement
filenv_get_s2temap (fenv) = fe_addr (fenv, FE_sort)
implement
filenv_get_s2itmmap (fenv) = fe_addr (fenv, FE_sexp)
implement
filenv_get_d2itmmap (fenv) = fe_addr (fenv, FE_dexp)

implement
filenv_get_d2eclist (fenv) = $UN.ptr0_get<d2eclist> (fe_addr (fenv, FE_decl2))

(* ****** ****** *)

implement
filenv_getref_d3eclistopt (fenv) = $UN.cast{Ptr1}(fe_addr (fenv, FE_decl3))

(* ****** ****** *)

implement
filenv_getref_tmpcstimpmap (fenv) = $UN.cast{Ptr1}(fe_addr (fenv, FE_tcimap))
implement
filenv_getref_tmpvardecmap (fenv) = $UN.cast{Ptr1}(fe_addr (fenv, FE_tvdmap))

end // end of [local]

(* ****** ****** *)

local
//
vtypedef s2rtenv = symenv (s2rtext)
//
val the_s2rtenv_ptr = let
  val (pf | p) = symenv_make_nil<s2rtext> ()
  prval () = $UN.castview0{void}(pf)
in
  p
end // end of [val]
//
(* ****** ****** *)

fn
the_s2rtenv_fopr
  (env: ptr, fenv: filenv): s2rtextopt_vt = let
  val id = $UN.cast{symbol}(env)
  val p = filenv_get_s2temap (fenv)
  val (pf, fpf | p0) = $UN.ptr0_vtake{s2temap}(p)
  val ans = symmap_search<s2rtext> (!p0, id)
  prval () = fpf (pf)
in
  ans
end // end of [the_s2rtenv_fopr]

fn
the_s2rtenv_find_namespace
  (id: symbol): s2rtextopt_vt =
  the_namespace_search<s2rtext> ($UN.cast{ptr}(id), the_s2rtenv_fopr)
// end of [the_s2rtenv_find_namespace]

(* ****** ****** *)

in (* in of [local] *)

(* ****** ****** *)

implement
the_s2rtenv_add (id, s2te) = () where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{s2rtenv}(the_s2rtenv_ptr)
  val () = symenv_insert<s2rtext> (!p0, id, s2te)
  prval () = fpf (pf)
} // end of [the_s2rtenv_add]

(* ****** ****** *)

implement
the_s2rtenv_find (id) = let
  val ans = let
    val (pf, fpf | p0) = $UN.ptr0_vtake{s2rtenv}(the_s2rtenv_ptr)
    val ans = symenv_search<s2rtext> (!p0, id)
    prval () = fpf (pf)
  in
    ans
  end // end of [val]
in
//
case+ ans of
| ~Some_vt (x) => Some_vt (x)
| ~None_vt () => let
    val ans =
    the_s2rtenv_find_namespace(id)
  in
    case+ ans of
    | ~Some_vt (x) => Some_vt (x)
    | ~None_vt () => ans where {
        val (pf, fpf | p0) = $UN.ptr0_vtake{s2rtenv}(the_s2rtenv_ptr)
        val ans = symenv_pervasive_search<s2rtext> (!p0, id)
        prval () = fpf (pf)
      } // end of [None_vt]
  end // end of [None_vt]
//
end // end of [the_s2rtenv_find]

(* ****** ****** *)

implement
the_s2rtenv_top_clear
  () = () where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{s2rtenv}(the_s2rtenv_ptr)
  val () = symenv_top_clear<s2rtext> (!p0)
  prval () = fpf (pf)
} // end of [the_s2rtenv_top_clear]

(* ****** ****** *)

implement
the_s2rtenv_pop () = map where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{s2rtenv}(the_s2rtenv_ptr)
  val map = symenv_pop<s2rtext> (!p0)
  prval () = fpf (pf)
} // end of [the_s2rtenv_pop]

implement
the_s2rtenv_pop_free
  () = () where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{s2rtenv}(the_s2rtenv_ptr)
  val () = symenv_pop_free<s2rtext> (!p0)
  prval () = fpf (pf)
} // end of [the_s2rtenv_pop_free]

implement
the_s2rtenv_push_nil
  () = () where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{s2rtenv}(the_s2rtenv_ptr)
  val () = symenv_push_nil<s2rtext> (!p0)
  prval () = fpf (pf)
} // end of [the_s2rtenv_push_nil]

(* ****** ****** *)

implement
the_s2rtenv_localjoin () = () where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{s2rtenv}(the_s2rtenv_ptr)
  val () = symenv_localjoin<s2rtext> (!p0)
  prval () = fpf (pf)
} // end of [the_s2rtenv_localjoin]

(* ****** ****** *)

fn the_s2rtenv_save () = () where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{s2rtenv}(the_s2rtenv_ptr)
  val () = symenv_savecur<s2rtext> (!p0)
  prval () = fpf (pf)
} // end of [the_s2rtenv_save]

fn the_s2rtenv_restore () : s2temap = map where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{s2rtenv}(the_s2rtenv_ptr)
  val map = symenv_restore<s2rtext> (!p0)
  prval () = fpf (pf)
} // end of [the_s2rtenv_restore]

(* ****** ****** *)

implement
the_s2rtenv_pervasive_joinwth0 (map) = () where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{s2rtenv}(the_s2rtenv_ptr)
  val () = symenv_pervasive_joinwth0<s2rtext> (!p0, map)
  prval () = fpf (pf)
} // end of [the_s2rtenv_pervasive_joinwth0]
implement
the_s2rtenv_pervasive_joinwth1 (map) = () where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{s2rtenv}(the_s2rtenv_ptr)
  val () = symenv_pervasive_joinwth1<s2rtext> (!p0, map)
  prval () = fpf (pf)
} // end of [the_s2rtenv_pervasive_joinwth1]

(* ****** ****** *)

end // end of [local]

(* ****** ****** *)

implement
the_s2rtenv_find_qua
  (q, id) = let
in
//
case+ $SYN.s0rtq_node_view (q.s0rtq_node ()) of
| ~$SYN.S0RTQnone _ =>
    the_s2rtenv_find (id)
| ~$SYN.S0RTQsymdot (sym) => let
    val ans = the_s2expenv_find (sym)
  in
    case+ ans of
    | ~Some_vt (s2i) => (
      case+ s2itm_view (s2i) of
      | ~S2ITMfilenv (fenv) => let
          val p = filenv_get_s2temap (fenv)
          val (pf, fpf | p_map) = $UN.ptr0_vtake{s2temap}(p)
          val ans = symmap_search<s2rtext> (!p_map, id)
          prval () = fpf (pf)
        in
          ans
        end // en dof [S2ITMfil]
      | v => let
          val () = s2itm_view_free (v)
          val loc = q.s0rtq_loc ()
          val () = prerr_error2_loc (loc)
          val () = prerr ": the qualifier ["
          val () = $SYM.prerr_symbol (sym)
          val () = prerr "] should refer to a filename but it does not."
          val () = prerr_newline ()
        in
          None_vt ()
        end
      ) // end of [Some_vt]
    | ~None_vt () => let
        val loc = q.s0rtq_loc ()
        val () = prerr_error2_loc (loc)
        val () = prerr ": the qualifier ["
        val () = $SYM.prerr_symbol (sym)
        val () = prerr "] is unrecognized."
        val () = prerr_newline ()
      in
        None_vt ()
      end
    // end of [case]
  end // end of [S2RTsymdot]
//
end // end of [the_s2rtenv_find_qua]

(* ****** ****** *)

local
//
vtypedef s2expenv = symenv (s2itm)
//
val the_s2expenv_ptr = let
  val (pf | p) = symenv_make_nil<s2itm> ()
  prval () = $UN.castview0{void}(pf)
in
  p
end // end of [val]
//
(* ****** ****** *)

fn
the_s2expenv_fopr
  (env: ptr, fenv: filenv): s2itmopt_vt = let
  val id = $UN.cast{symbol}(env)
  val p = filenv_get_s2itmmap (fenv)
  val (pf, fpf | p0) = $UN.ptr0_vtake{s2itmmap}(p)
  val ans = symmap_search<s2itm> (!p0, id)
  prval () = fpf (pf)
in
  ans
end // end of [the_s2expenv_fopr]

fn
the_s2expenv_find_namespace
  (id: symbol): s2itmopt_vt =
  the_namespace_search<s2itm> ($UN.cast{ptr}(id), the_s2expenv_fopr)
// end of [the_s2expenv_find_namespace]

(* ****** ****** *)

in (* in of [local] *)

(* ****** ****** *)

implement
the_s2expenv_add (id, s2i) = () where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{s2expenv}(the_s2expenv_ptr)
  val () = symenv_insert<s2itm> (!p0, id, s2i)
  prval () = fpf (pf)
} // end of [the_s2expenv_add]

(* ****** ****** *)

implement
the_s2expenv_find (id) = let
  val ans = let
    val (pf, fpf | p0) = $UN.ptr0_vtake{s2expenv}(the_s2expenv_ptr)
    val ans = symenv_search<s2itm> (!p0, id)
    prval () = fpf (pf)
  in
    ans
  end // end of [val]
in
//
case+ ans of
| ~Some_vt (x) => Some_vt (x)
| ~None_vt () => let
    val ans =
    the_s2expenv_find_namespace(id)
  in
    case+ ans of
    | ~Some_vt (x) => Some_vt (x)
    | ~None_vt () => ans where {
        val (pf, fpf | p0) = $UN.ptr0_vtake{s2expenv}(the_s2expenv_ptr)
        val ans = symenv_pervasive_search<s2itm> (!p0, id)
        prval () = fpf (pf)
      } // end of [None_vt]
  end // end of [None_vt]
//
end // end of [the_s2expenv_find]

(* ****** ****** *)

implement
the_s2expenv_pervasive_find (id) = ans where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{s2expenv}(the_s2expenv_ptr)
  val ans = symenv_pervasive_search<s2itm> (!p0, id)
  prval () = fpf (pf)
} // end of [the_s2expenv_pervasive_find]

(* ****** ****** *)

implement
the_s2expenv_top_clear
  () = () where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{s2expenv}(the_s2expenv_ptr)
  val () = symenv_top_clear<s2itm> (!p0)
  prval () = fpf (pf)
} // end of [the_s2expenv_top_clear]

(* ****** ****** *)

implement
the_s2expenv_pop () = map where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{s2expenv}(the_s2expenv_ptr)
  val map = symenv_pop<s2itm> (!p0)
  prval () = fpf (pf)
} // end of [the_s2expenv_pop]

implement
the_s2expenv_pop_free
  () = () where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{s2expenv}(the_s2expenv_ptr)
  val () = symenv_pop_free<s2itm> (!p0)
  prval () = fpf (pf)
} // end of [the_s2expenv_pop_free]

implement
the_s2expenv_push_nil
  () = () where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{s2expenv}(the_s2expenv_ptr)
  val () = symenv_push_nil<s2itm> (!p0)
  prval () = fpf (pf)
} // end of [the_s2expenv_push_nil]

(* ****** ****** *)

implement
the_s2expenv_localjoin () = () where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{s2expenv}(the_s2expenv_ptr)
  val () = symenv_localjoin<s2itm> (!p0)
  prval () = fpf (pf)
} // end of [the_s2expenv_localjoin]

(* ****** ****** *)

fn the_s2expenv_save () = () where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{s2expenv}(the_s2expenv_ptr)
  val () = symenv_savecur<s2itm> (!p0)
  prval () = fpf (pf)
} // end of [the_s2expenv_save]

fn the_s2expenv_restore () : s2itmmap = map where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{s2expenv}(the_s2expenv_ptr)
  val map = symenv_restore<s2itm> (!p0)
  prval () = fpf (pf)
} // end of [the_s2expenv_restore]

(* ****** ****** *)

implement
the_s2expenv_pervasive_joinwth0 (map) = () where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{s2expenv}(the_s2expenv_ptr)
  val () = symenv_pervasive_joinwth0<s2itm> (!p0, map)
  prval () = fpf (pf)
} // end of [the_s2expenv_pervasive_joinwth0]
implement
the_s2expenv_pervasive_joinwth1 (map) = () where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{s2expenv}(the_s2expenv_ptr)
  val () = symenv_pervasive_joinwth1<s2itm> (!p0, map)
  prval () = fpf (pf)
} // end of [the_s2expenv_pervasive_joinwth1]

end // end of [local]

(* ****** ****** *)

implement
the_s2expenv_find_qua
  (q, id) = let
in
//
case+ $SYN.s0taq_node_view (q.s0taq_node ()) of
//
| ~$SYN.S0TAQnone _ =>
    the_s2expenv_find (id)
//
| ~$SYN.S0TAQsymdot (sym) => let
    val ans = the_s2expenv_find (sym)
  in
    case+ ans of
    | ~Some_vt (s2i) => (
      case+ s2itm_view (s2i) of
      | ~S2ITMfilenv (fenv) => let
          val p = filenv_get_s2itmmap (fenv)
          val (pf, fpf | p_map) = $UN.ptr0_vtake{s2itmmap}(p)
          val ans = symmap_search<s2itm> (!p_map, id)
          prval () = fpf (pf)
        in
          ans
        end // en dof [S2ITMfil]
      | v => let
          val () = s2itm_view_free (v)
          val loc = q.s0taq_loc ()
          val () = prerr_error2_loc (loc)
          val () = prerr ": the qualifier ["
          val () = $SYM.prerr_symbol (sym)
          val () = prerr "] should refer to a filename but it does not."
          val () = prerr_newline ((*void*))
        in
          None_vt ()
        end
      ) // end of [Some_vt]
    | ~None_vt () => let
        val loc = q.s0taq_loc ()
        val () = prerr_error2_loc (loc)
        val () = prerr ": the qualifier ["
        val () = $SYM.prerr_symbol (sym)
        val () = prerr "] is unrecognized."
        val () = prerr_newline ((*void*))
      in
        None_vt ()
      end
  end // end of [S2RTsymdot]
//
end // end of [the_s2expenv_find_qua]

(* ****** ****** *)

implement
the_s2expenv_add_scst
  (s2c) = let
val id = s2cst_get_sym s2c
//
val s2cs = (
  case+ the_s2expenv_find (id) of
  | ~Some_vt s2i => (
    case+ s2itm_view (s2i) of
    | ~S2ITMcst s2cs => s2cs
    | v => (s2itm_view_free (v); glist_nil ())
    ) // end of [Some_vt]
  | ~None_vt () => glist_nil ()
) : s2cstlst // end of [val]
//
val s2i = s2itm_S2ITMcst (glist_cons (s2c, s2cs))
//
in
  the_s2expenv_add (id, s2i)
end // end of [the_s2expenv_add_scst]

implement
the_s2expenv_add_svar
  (s2v) = let
  val id = s2var_get_sym (s2v)
in
  the_s2expenv_add (id, s2itm_S2ITMvar s2v)
end // end of [the_s2expenv_add_svar]

implement
the_s2expenv_add_svarlst
  (s2vs) = (
  case+ glist_view (s2vs) of
  | ~GLcons (s2v, s2vs) => (the_s2expenv_add_svar (s2v); the_s2expenv_add_svarlst (s2vs))
  | ~GLnil () => ()
) // end of [the_s2expenv_add_svarlst]

implement
the_s2expenv_add_sp2at
  (sp2t) = (
  case+ sp2at_node_view (sp2t.sp2at_node ()) of
  | ~SP2Tcon (s2c, s2vs) => the_s2expenv_add_svarlst (s2vs)
  | ~SP2Terr () => () // HX: a placeholder for indicating an error
) // end of [the_s2expenv_add_sp2at]

implement
the_s2expenv_add_datconptr (d2c) = let
  val sym = d2con_get_sym d2c
  val name = $SYM.symbol_get_name (sym)
  val name1 = string0_append (name, "_unfold")
  val id = $SYM.symbol_make_string ($UN.strptr2string (name1))
  val () = strptr_free (name1)
  val () = the_s2expenv_add (id, s2itm_S2ITMdatconptr (d2c))
in
  // empty
end // end of [the_s2expenv_add_datconptr]

implement
the_s2expenv_add_datcontyp
  (d2c) = let
  val
  sym = d2con_get_sym(d2c)
  val
  name = $SYM.symbol_get_name(sym)
  val name1 = string0_append (name, "_pstruct")
  val id =
  $SYM.symbol_make_string ($UN.strptr2string (name1))
  val () = strptr_free (name1)
  val () =
  the_s2expenv_add(id, s2itm_S2ITMdatcontyp (d2c))
in
  // empty
end // end of [the_s2expenv_add_datcontyp]

(* ****** ****** *)

local

val the_maclev = t2env_cell_make<int> (1) // HX: the initial level is 1

in (* in of [local] *)

implement
the_maclev_get () = $UN.ptr0_get<int> (the_maclev)

implement
the_maclev_inc
  (loc) = let
  val lev = $UN.ptr0_get<int> (the_maclev)
  val () = if lev > 0 then {
    val () = prerr_error2_loc (loc)
    val () = prerr ": the syntax `(...) is used incorrectly at this location.";
    val () = prerr_newline ()
  } // end of [if] // end of [val]
in
  $UN.ptr0_set<int> (the_maclev, lev + 1)
end // end of [the_maclev_inc]

implement
the_maclev_dec
  (loc) = let
  val lev = $UN.ptr0_get<int> (the_maclev)
  val () = if lev = 0 then {
    val () = prerr_error2_loc (loc)
    val () = prerr ": the syntax ,(...) or %(...) is used incorrectly at this location.";
    val () = prerr_newline ()
  } // end of [if] // end of [val]
in
  $UN.ptr0_set<int> (the_maclev, lev - 1)
end // end of [the_maclev_dec]

end // end of [local]

(* ****** ****** *)

local

val the_macdeflev = t2env_cell_make<int> (0)

in (* in of [local] *)

implement
the_macdeflev_get () = $UN.ptr0_get<int> (the_macdeflev)

implement
the_macdeflev_inc () =
  $UN.ptr0_set<int> (the_macdeflev, $UN.ptr0_get<int> (the_macdeflev) + 1)
// end of [macdeflev_inc]

implement
the_macdeflev_dec () =
  $UN.ptr0_set<int> (the_macdeflev, $UN.ptr0_get<int> (the_macdeflev) - 1)
// end of [macdeflev_dec]

end // end of [local]

(* ****** ****** *)

local

val the_tmplev = t2env_cell_make<int> (0)

in (* in of [local] *)

implement
the_tmplev_get () = $UN.ptr0_get<int> (the_tmplev)

implement
the_tmplev_inc () =
  $UN.ptr0_set<int> (the_tmplev, $UN.ptr0_get<int> (the_tmplev) + 1)
// end of [tmplev_inc]

implement
the_tmplev_dec () =
  $UN.ptr0_set<int> (the_tmplev, $UN.ptr0_get<int> (the_tmplev) - 1)
// end of [tmplev_dec]

end // end of [local]

(* ****** ****** *)

(*
** HX-2012-06-07:
** this function is currently not used
** in the implementation of ATS2
*)
implement
s2var_check_tmplev
  (loc, s2v) = let
  val lev = s2var_get_tmplev (s2v)
in
  if lev > 0 then let
      val tmplev = the_tmplev_get ()
    in
      if lev < tmplev then let
        val () = prerr_error2_loc (loc)
        val () = prerr ": the static variable ["
        val () = prerr_s2var (s2v)
        val () = prerr "] is out of scope."
        val () = prerr_newline ()
      in
        the_trans2errlst_add (trans2err_T2E_s2var_check_tmplev (s2v))
      end // end of [if]
    end // end of [_ when lev > 0]]
  else () // HX: [s2v] is not a template variable
end // end of [s2var_tmplev_check]

(* ****** ****** *)

implement
s2qualstlst_set_tmplev
  (s2qs, tmplev) = let
//
fun auxvs (s2vs: s2varlst, tmplev: int): void =
  case+ glist_view (s2vs) of
  | ~GLcons (s2v, s2vs) => (s2var_set_tmplev (s2v, tmplev); auxvs (s2vs, tmplev))
  | ~GLnil () => ()
//
fun aux (s2qs: s2qualst, tmplev: int): void =
  case+ glist_view (s2qs) of
  | ~GLcons (s2q, s2qs) => (auxvs (s2q.s2qua_svs (), tmplev); aux (s2qs, tmplev))
  | ~GLnil () => ()
//
in
  aux (s2qs, tmplev)
end // end of [s2qualstlst_set_tmplev]

(* ****** ****** *)

local
//
val the_d2varlev = t2env_cell_make<int> (0)
//
in (* in of [local] *)

implement
the_d2varlev_get () = $UN.ptr0_get<int> (the_d2varlev)

implement
the_d2varlev_inc
  ((*void*)) = let
  val n = $UN.ptr0_get<int> (the_d2varlev)
in
  $UN.ptr0_set<int> (the_d2varlev, n + 1)
end // end of [the_d2varlev_inc]

implement
the_d2varlev_dec
  ((*void*)) = let
  val n = $UN.ptr0_get<int> (the_d2varlev)
in
  $UN.ptr0_set<int> (the_d2varlev, n - 1)
end // end of [the_d2varlev_dec]

implement
the_d2varlev_save () = let
  val n = $UN.ptr0_get<int> (the_d2varlev)
  val () = $UN.ptr0_set<int> (the_d2varlev, 0)
in
  n
end (* end of [the_d2varlev_save] *)

implement
the_d2varlev_restore (lvl0) = $UN.ptr0_set<int> (the_d2varlev, lvl0)

end // end of [local]

(* ****** ****** *)

local
//
vtypedef d2expenv = symenv (d2itm)
//
val the_d2expenv_ptr = let
  val (pf | p) = symenv_make_nil<d2itm> ()
  prval () = $UN.castview0{void}(pf)
in
  p
end // end of [val]
//
(* ****** ****** *)

fn
the_d2expenv_fopr
  (env: ptr, fenv: filenv): d2itmopt_vt = let
  val id = $UN.cast{symbol}(env)
  val p = filenv_get_d2itmmap (fenv)
  val (pf, fpf | p0) = $UN.ptr0_vtake{d2itmmap}(p)
  val d2iopt = symmap_search<d2itm> (!p0, id)
  prval () = fpf (pf)
in
  case+ d2iopt of
  | ~None_vt () => None_vt ()
  | ~Some_vt (d2i) =>
    // HX-2019-02-11: d2var is not exported
    if d2itm_is_D2ITMvar (d2i) then None_vt () else Some_vt (d2i)
end // end of [the_d2expenv_fopr]

fn
the_d2expenv_find_namespace
  (id: symbol): d2itmopt_vt =
  the_namespace_search<d2itm> ($UN.cast{ptr}(id), the_d2expenv_fopr)
// end of [the_d2expenv_find_namespace]

in (* in of [local] *)

implement
the_d2expenv_add (id, d2i) = () where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{d2expenv}(the_d2expenv_ptr)
  val () = symenv_insert<d2itm> (!p0, id, d2i)
  prval () = fpf (pf)
} // end of [the_d2expenv_add]

(* ****** ****** *)

implement
the_d2expenv_find (id) = let
  val ans = let
    val (pf, fpf | p0) = $UN.ptr0_vtake{d2expenv}(the_d2expenv_ptr)
    val ans = symenv_search<d2itm> (!p0, id)
    prval () = fpf (pf)
  in
    ans
  end // end of [val]
in
//
case+ ans of
| ~Some_vt (x) => Some_vt (x)
| ~None_vt () => let
    val ans =
    the_d2expenv_find_namespace(id)
  in
    case+ ans of
    | ~Some_vt (x) => Some_vt (x)
    | ~None_vt () => ans where {
        val (pf, fpf | p0) = $UN.ptr0_vtake{d2expenv}(the_d2expenv_ptr)
        val ans = symenv_pervasive_search<d2itm> (!p0, id)
        prval () = fpf (pf)
      } // end of [None_vt]
  end // end of [None_vt]
//
end // end of [the_d2expenv_find]

(* ****** ****** *)

implement
the_d2expenv_current_find (id) = ans where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{d2expenv}(the_d2expenv_ptr)
  val ans = symenv_search<d2itm> (!p0, id)
  prval () = fpf (pf)
} // end of [the_d2expenv_current_find]

implement
the_d2expenv_pervasive_find (id) = ans where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{d2expenv}(the_d2expenv_ptr)
  val ans = symenv_pervasive_search<d2itm> (!p0, id)
  prval () = fpf (pf)
} // end of [the_d2expenv_pervasive_find]

(* ****** ****** *)

implement
the_d2expenv_top_clear
  () = () where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{d2expenv}(the_d2expenv_ptr)
  val () = symenv_top_clear<d2itm> (!p0)
  prval () = fpf (pf)
} // end of [the_d2expenv_top_clear]

(* ****** ****** *)

implement
the_d2expenv_pop () = map where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{d2expenv}(the_d2expenv_ptr)
  val map = symenv_pop<d2itm> (!p0)
  prval () = fpf (pf)
} // end of [the_d2expenv_pop]

implement
the_d2expenv_pop_free
  () = () where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{d2expenv}(the_d2expenv_ptr)
  val () = symenv_pop_free<d2itm> (!p0)
  prval () = fpf (pf)
} // end of [the_d2expenv_pop_free]

implement
the_d2expenv_push_nil
  () = () where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{d2expenv}(the_d2expenv_ptr)
  val () = symenv_push_nil<d2itm> (!p0)
  prval () = fpf (pf)
} // end of [the_d2expenv_push_nil]

(* ****** ****** *)

implement
the_d2expenv_localjoin () = () where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{d2expenv}(the_d2expenv_ptr)
  val () = symenv_localjoin<d2itm> (!p0)
  prval () = fpf (pf)
} // end of [the_d2expenv_localjoin]

(* ****** ****** *)

fn the_d2expenv_save () = () where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{d2expenv}(the_d2expenv_ptr)
  val () = symenv_savecur<d2itm> (!p0)
  prval () = fpf (pf)
} // end of [the_d2expenv_save]

fn the_d2expenv_restore () : d2itmmap = map where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{d2expenv}(the_d2expenv_ptr)
  val map = symenv_restore<d2itm> (!p0)
  prval () = fpf (pf)
} // end of [the_d2expenv_restore]

(* ****** ****** *)

implement
the_d2expenv_pervasive_joinwth0 (map) = () where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{d2expenv}(the_d2expenv_ptr)
  val () = symenv_pervasive_joinwth0<d2itm> (!p0, map)
  prval () = fpf (pf)
} // end of [the_d2expenv_pervasive_joinwth0]
implement
the_d2expenv_pervasive_joinwth1 (map) = () where {
  val (pf, fpf | p0) = $UN.ptr0_vtake{d2expenv}(the_d2expenv_ptr)
  val () = symenv_pervasive_joinwth1<d2itm> (!p0, map)
  prval () = fpf (pf)
} // end of [the_d2expenv_pervasive_joinwth1]

end // end of [local]

(* ****** ****** *)

implement
the_d2expenv_find_qua
  (q, id) = let
in
//
case+
$SYN.d0ynq_node_view (q.d0ynq_node ())
of // case+
| ~$SYN.D0YNQnone _ =>
    the_d2expenv_find(id)
  // end of [D0YNQnone]
| ~$SYN.D0YNQsymdot(sym) => let
    val ans =
      the_s2expenv_find(sym)
    // end of [val]
  in
    case+ ans of
    | ~Some_vt(s2i) =>
      (
      case+ s2itm_view (s2i) of
      | ~S2ITMfilenv
        (
          fenv
        ) => ans where
        {
          val p = filenv_get_d2itmmap(fenv)
          val (pf, fpf | p_map) = $UN.ptr0_vtake{d2itmmap}(p)
          val ans = symmap_search<d2itm> (!p_map, id)
          prval () = fpf (pf)
        } (* end of [S2ITMfil] *)
      | v (*rest-of-s2itm*) => let
          val () = s2itm_view_free (v)
          val () =
            prerr_error2_loc(q.d0ynq_loc ())
          // end of [val]
          val () = prerr ": the qualifier ["
          val () = $SYM.prerr_symbol(sym)
          val () = prerr "] should refer to a filename but it does not."
          val () = prerr_newline((*void*))
        in
          None_vt ((*void*))
        end
      ) // end of [Some_vt]
    | ~None_vt((*void*)) => let
        val () =
          prerr_error2_loc(q.d0ynq_loc ())
        // end of [val]
        val () = prerr ": the qualifier ["
        val () = $SYM.prerr_symbol(sym)
        val () = prerr "] is unrecognized."
        val () = prerr_newline((*void*))
      in
        None_vt ((*void*))
      end // end of [None_vt]
  end // end of [S2RTsymdot]
//
end // end of [the_d2expenv_find_qua]

(* ****** ****** *)

implement
the_d2expenv_add_dcon
  (d2c) = let
//
val id = d2con_get_sym d2c
val d2cs =
(
case+
  the_d2expenv_find (id) of
| ~Some_vt d2i => (
    case+ d2itm_view (d2i) of
    | ~D2ITMcon d2cs => d2cs
    | v => (d2itm_view_free (v); glist_nil ())
  ) // end of [Some_vt]
| ~None_vt ((*void*)) => glist_nil ()
) : d2conlst // end of [val]
val d2i = d2itm_D2ITMcon (glist_cons (d2c, d2cs))
//
in
  the_d2expenv_add (id, d2i)
end // end of [the_d2expenv_add_dcon]

(* ****** ****** *)

implement
the_d2expenv_add_dcst (d2c) = let
  val id = d2cst_get_sym (d2c) in the_d2expenv_add (id, d2itm_D2ITMcst d2c)
end // end of [the_d2expenv_add_dcst]

(* ****** ****** *)

implement
the_d2expenv_add_dmacdef (d2m) = let
  val id = d2mac_get_sym (d2m) in the_d2expenv_add (id, d2itm_D2ITMmacdef d2m)
end // end of [the_d2expenv_add_dmacdef]
implement
the_d2expenv_add_dmacvar (d2v) = let
  val id = d2var_get_sym (d2v) in the_d2expenv_add (id, d2itm_D2ITMmacvar d2v)
end // end of [the_d2expenv_add_dmacvar]
implement
the_d2expenv_add_dmacvarlst
  (d2vs) = (
  case+ glist_view (d2vs) of
  | ~GLcons (d2v, d2vs) => (the_d2expenv_add_dmacvar (d2v); the_d2expenv_add_dmacvarlst (d2vs))
  | ~GLnil () => ()
) // end of [the_d2expenv_add_dmacvarlst]

(* ****** ****** *)

implement
the_d2expenv_add_dvar (d2v) = let
  val id = d2var_get_sym (d2v) in the_d2expenv_add (id, d2itm_D2ITMvar d2v)
end // end of [the_d2expenv_add_dvar]
implement
the_d2expenv_add_dvarlst
  (d2vs) = (
  case+ glist_view (d2vs) of
  | ~GLcons (d2v, d2vs) => (the_d2expenv_add_dvar (d2v); the_d2expenv_add_dvarlst (d2vs))
  | ~GLnil () => ()
) // end of [the_d2expenv_add_dvarlst]
implement
the_d2expenv_add_dvaropt (opt) = (
  case+ gopt_view (opt) of ~GOsome (d2v) => the_d2expenv_add_dvar (d2v) | ~GOnone () => ()
) // end of [the_d2expenv_add_dvaropt]

(* ****** ****** *)

implement
the_d2expenv_add_fundeclst
  (knd, f2ds) = let
//
fun auxlst
(
  f2ds: f2undeclst
) : void = (
case+ glist_view (f2ds) of
| ~GLcons
    (f2d, f2ds) => let
    val () = the_d2expenv_add_dvar (f2d.f2undec_var ())
  in
    auxlst (f2ds)
  end // end of [list_cons]
| ~GLnil ((*none*)) => ()
) (* end of [auxlist] *)
//
in
//
case+ glist_view (f2ds) of
| ~GLcons
    (f2d, f2ds) => let
    val () = the_d2expenv_add_dvar (f2d.f2undec_var ())
  in
    if not(funkind_is_mutailrec(knd)) then auxlst (f2ds)
  end // end of [list_cons]
| ~GLnil ((*none*)) => ()
//
end // end of [the_d2expenv_add_fundeclst]

(* ****** ****** *)

local

val the_staload_level = t2env_cell_make<int> (0)

in (* in of [local] *)

implement
the_staload_level_get () = $UN.ptr0_get<int> (the_staload_level)

implement
the_staload_level_push
  () = () where {
  val n = $UN.ptr0_get<int> (the_staload_level)
  val () = $UN.ptr0_set<int> (the_staload_level, n+1)
} // end of [the_staload_level_push]

implement
the_staload_level_pop
  () = let
  val n = $UN.ptr0_get<int> (the_staload_level)
  val () = $UN.ptr0_set<int> (the_staload_level, n-1)
in
  // nothing
end // end of [the_staload_level_pop]

end // end of [local]

(* ****** ****** *)

local
//
vtypedef filenvmap = symmap(filenv)
//
val the_filenvmap_ptr = let
  val map = symmap_make_nil<filenv> ()
  val p = the_garena_alloc (sizeof<ptr>)
  val () = $UN.ptr0_set<ptr> (p, $UN.castvwtp0{ptr}(map))
in
  p
end // end of [val]
//
in (* in of [local] *)

implement
the_filenvmap_add (fid, fenv) = let
  val (pf, fpf | p) = $UN.ptr0_vtake{filenvmap}(the_filenvmap_ptr)
  val () = symmap_insert<filenv> (!p, fid, fenv)
  prval () = fpf (pf)
in
end // end of [the_filenvmap_add]

implement
the_filenvmap_find (fid) = let
  val (pf, fpf | p) = $UN.ptr0_vtake{filenvmap}(the_filenvmap_ptr)
  val ans = symmap_search<filenv> (!p, fid)
  prval () = fpf (pf)
in
  ans
end // end of [the_filenvmap_find]

end // end of [local]

(* ****** ****** *)

implement
the_trans2_env_pop
  ((*none*)) = {
  val () = the_namespace_pop ()
  val () = the_s2rtenv_pop_free ((*none*))
  val () = the_s2expenv_pop_free ((*none*))
  val () = the_d2expenv_pop_free ((*none*))
} // end of [the_trans2_env_pop]

implement
the_trans2_env_push () = let
  val () = the_namespace_push ()
  val () = the_s2rtenv_push_nil ()
  val () = the_s2expenv_push_nil ()
  val () = the_d2expenv_push_nil ()
in
  // empty
end // end of [the_trans2_env_push]

implement
the_trans2_env_localjoin
  ((*none*)) = {
  val () = the_namespace_localjoin ()
  val () = the_s2rtenv_localjoin ((*none*))
  val () = the_s2expenv_localjoin ((*none*))
  val () = the_d2expenv_localjoin ((*none*))
} // end of [trans2_env_localjoin]

implement
the_trans2_env_pervasive_joinwth1
  (fil, d2cs) = {
  val m0 = the_s2rtenv_pop ((*none*))
  val () = the_s2rtenv_pervasive_joinwth1 (m0)
  val m1 = the_s2expenv_pop ((*none*))
  val () = the_s2expenv_pervasive_joinwth1 (m1)
  val m2 = the_d2expenv_pop ((*none*))
  val () = the_d2expenv_pervasive_joinwth1 (m2)
//
  val fsym = $FIL.filename_get_fullname (fil)
  val fenv = filenv_make (fil, m0, m1, m2, d2cs)
  val ((*void*)) = the_filenvmap_add (fsym, fenv)
//
} // end of [the_trans2_env_pervasive_joinwth1]

(* ****** ****** *)

implement
the_trans2_env_save () = let
  val () = the_namespace_save ()
  val () = the_s2rtenv_save ()
  val () = the_s2expenv_save ()
  val () = the_d2expenv_save ()
in
  // empty
end // end of [the_trans1_env_save]

implement
the_trans2_env_restore
  ((*none*)) = let
  val () = the_namespace_restore ()
  val m0 = the_s2rtenv_restore ()
  val m1 = the_s2expenv_restore ()
  val m2 = the_d2expenv_restore ()
in
  @(m0, m1, m2)
end // end of [the_trans2_env_restore]

(* ****** ****** *)

local

fun
the_s2rtenv_initialize
(
// argless
) : void = {
//
  val () = the_s2rtenv_push_nil ()
//
// HX: pre-defined predicative sorts
//
  val () = the_s2rtenv_add ($SYM.symbol_INT, s2rtext_S2TEsrt s2rt_int)
  val () = the_s2rtenv_add ($SYM.symbol_ADDR, s2rtext_S2TEsrt s2rt_addr)
  val () = the_s2rtenv_add ($SYM.symbol_BOOL, s2rtext_S2TEsrt s2rt_bool)
//
  val () = the_s2rtenv_add ($SYM.symbol_REAL, s2rtext_S2TEsrt s2rt_real)
//
  val () = the_s2rtenv_add ($SYM.symbol_FLOAT, s2rtext_S2TEsrt s2rt_float)
  val () = the_s2rtenv_add ($SYM.symbol_STRING, s2rtext_S2TEsrt s2rt_string)
//
  val () = the_s2rtenv_add ($SYM.symbol_CLS, s2rtext_S2TEsrt s2rt_cls) // classes
//
  val () = the_s2rtenv_add ($SYM.symbol_EFF, s2rtext_S2TEsrt s2rt_eff) // effects
//
  val () = the_s2rtenv_add ($SYM.symbol_TKIND, s2rtext_S2TEsrt s2rt_tkind)
//
// HX: pre-defined impredicative sorts
//
  val () = the_s2rtenv_add ($SYM.symbol_PROP, s2rtext_S2TEsrt s2rt_prop)
//
  val () = the_s2rtenv_add ($SYM.symbol_VIEW, s2rtext_S2TEsrt s2rt_view)
//
  val () = the_s2rtenv_add ($SYM.symbol_TYPE, s2rtext_S2TEsrt s2rt_type)
  val () = the_s2rtenv_add ($SYM.symbol_T0YPE, s2rtext_S2TEsrt s2rt_t0ype)
//
  val () = the_s2rtenv_add ($SYM.symbol_TYPES, s2rtext_S2TEsrt s2rt_types)
//
  val () = the_s2rtenv_add ($SYM.symbol_VTYPE, s2rtext_S2TEsrt s2rt_vtype)
  val () = the_s2rtenv_add ($SYM.symbol_VT0YPE, s2rtext_S2TEsrt s2rt_vt0ype)
//
  val () = the_s2rtenv_add ($SYM.symbol_VIEWTYPE, s2rtext_S2TEsrt s2rt_vtype)
  val () = the_s2rtenv_add ($SYM.symbol_VIEWT0YPE, s2rtext_S2TEsrt s2rt_vt0ype)
//
  val map = the_s2rtenv_pop ((*none*))
  val ((*void*)) = the_s2rtenv_pervasive_joinwth0 (map)
//
} (* end of [trans2_env_initialize] *)

fun
the_s2rtenv_reinitialize(): void = the_s2rtenv_top_clear ()

(* ****** ****** *)
//
fun
the_s2expenv_initialize (): void = ()
fun
the_s2expenv_reinitialize(): void = the_s2expenv_top_clear()
//
(* ****** ****** *)
//
fun
the_d2expenv_initialize (): void = ()
//
fun
the_d2expenv_reinitialize(): void = the_d2expenv_top_clear()
//
(* ****** ****** *)

val the_trans2_env_flag = t2env_cell_make<int> (0)

(* ****** ****** *)

in (* in of [local] *)

implement
the_trans2_env_initialize
(
// argumentless
) = let
//
val n = $UN.ptr0_get<int> (the_trans2_env_flag)
val () = $UN.ptr0_set<int> (the_trans2_env_flag, n+1)
//
in
//
if
n = 0
then {
  val () = the_s2rtenv_initialize ()
  val () = the_s2expenv_initialize ()
  val () = the_d2expenv_initialize ()
} else {
  val () = the_s2rtenv_reinitialize ()
  val () = the_s2expenv_reinitialize ()
  val () = the_d2expenv_reinitialize ()
} (* end of [if] *)
//
end // end of [the_trans2_env_initialize]

end // end of [local]

(* ****** ****** *)

(* end of [pats_trans2_env.dats] *)
