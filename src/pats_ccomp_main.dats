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
// Start Time: October, 2012
// Authoremail: gmhwxiATgmailDOTcom
//
(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of src/pats_ccomp_main.dats, see PORTING.md, "ccomp group B")
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload
UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "./pats_basics.sats"

(* ****** ****** *)
//
staload
FIL = "./pats_filename.sats"
typedef filename = $FIL.filename
//
(* ****** ****** *)

staload GLOB = "./pats_global.sats"

(* ****** ****** *)
//
staload
S2E = "./pats_staexp2.sats"
typedef d2con = $S2E.d2con
typedef d2conlst = $S2E.d2conlst
//
staload
D2E = "./pats_dynexp2.sats"
//
typedef d2cst = $D2E.d2cst
typedef d2cstlst = $D2E.d2cstlst
typedef d2cstopt = $D2E.d2cstopt
//
(* ****** ****** *)

staload "./pats_histaexp.sats"
staload "./pats_hidynexp.sats"

(* ****** ****** *)

staload "./pats_ccomp.sats"

(* ****** ****** *)

implement
emit_ats_ccomp_header
  (out) = let
//
  val () = emit_text (out, "/*\n")
  val () = emit_text (out, "** include runtime header files\n")
  val () = emit_text (out, "*/\n")
//
  val () = emit_text (out, "#ifndef _ATS_CCOMP_HEADER_NONE_\n")
//
  val () = emit_text (out, "#include \"pats_ccomp_config.h\"\n")
  val () = emit_text (out, "#include \"pats_ccomp_basics.h\"\n")
  val () = emit_text (out, "#include \"pats_ccomp_typedefs.h\"\n")
  val () = emit_text (out, "#include \"pats_ccomp_instrset.h\"\n")
  val () = emit_text (out, "#include \"pats_ccomp_memalloc.h\"\n")
//
  val () = emit_text (out, "#ifndef _ATS_CCOMP_EXCEPTION_NONE_\n")
  val () = emit_text (out, "#include \"pats_ccomp_memalloca.h\"\n")
  val () = emit_text (out, "#include \"pats_ccomp_exception.h\"\n")
  val () = emit_text (out, "#endif // end of [_ATS_CCOMP_EXCEPTION_NONE_]\n")
//
  val () = emit_text (out, "#endif /* _ATS_CCOMP_HEADER_NONE_ */\n")
  val () = emit_newline (out)
in
  emit_newline (out)
end // end of [emit_ats_ccomp_header]

(* ****** ****** *)

implement
emit_ats_ccomp_prelude
  (out) = let
//
val () = emit_text (out, "/*\n")
val () = emit_text (out, "** include prelude cats files\n")
val () = emit_text (out, "*/\n")
//
val () = emit_text (out, "#ifndef _ATS_CCOMP_PRELUDE_NONE_\n")
//
// HX: primary prelude cats files
//
val () = emit_text (out, "//\n")
val () = emit_text (out, "#include \"prelude/CATS/basics.cats\"\n")
//
val () = emit_text (out, "#include \"prelude/CATS/integer.cats\"\n")
//
val () = emit_text (out, "#include \"prelude/CATS/pointer.cats\"\n")
//
val () = emit_text (out, "#include \"prelude/CATS/integer_long.cats\"\n")
val () = emit_text (out, "#include \"prelude/CATS/integer_size.cats\"\n")
val () = emit_text (out, "#include \"prelude/CATS/integer_short.cats\"\n")
//
val () = emit_text (out, "#include \"prelude/CATS/bool.cats\"\n")
val () = emit_text (out, "#include \"prelude/CATS/char.cats\"\n")
val () = emit_text (out, "#include \"prelude/CATS/float.cats\"\n")
val () = emit_text (out, "#include \"prelude/CATS/integer_ptr.cats\"\n")
val () = emit_text (out, "#include \"prelude/CATS/integer_fixed.cats\"\n")
//
val () = emit_text (out, "#include \"prelude/CATS/memory.cats\"\n")
//
val () = emit_text (out, "#include \"prelude/CATS/string.cats\"\n")
val () = emit_text (out, "#include \"prelude/CATS/strptr.cats\"\n")
//
val () = emit_text (out, "//\n")
val () = emit_text (out, "#include \"prelude/CATS/fprintf.cats\"\n")
val () = emit_text (out, "//\n")
val () = emit_text (out, "#include \"prelude/CATS/filebas.cats\"\n")
//
// HX: secondary prelude cats files
//
val () = emit_text (out, "//\n")
val () = emit_text (out, "#include \"prelude/CATS/array.cats\"\n")
val () = emit_text (out, "#include \"prelude/CATS/arrayptr.cats\"\n")
val () = emit_text (out, "#include \"prelude/CATS/matrix.cats\"\n")
val () = emit_text (out, "#include \"prelude/CATS/matrixptr.cats\"\n")
//
val () = emit_text (out, "//\n")
val () = emit_text (out, "#endif /* _ATS_CCOMP_PRELUDE_NONE_ */\n")
//
val () = emit_text (out, "/*\n")
val () = emit_text (out, "** for user-supplied prelude\n")
val () = emit_text (out, "*/\n")
val () = emit_text (out, "#ifdef _ATS_CCOMP_PRELUDE_USER_\n")
val () = emit_text (out, "//\n")
val () = emit_text (out, "#include _ATS_CCOMP_PRELUDE_USER_\n")
val () = emit_text (out, "//\n")
val () = emit_text (out, "#endif /* _ATS_CCOMP_PRELUDE_USER_ */\n")
//
val () = emit_text (out, "/*\n")
val () = emit_text (out, "** for user2-supplied prelude\n")
val () = emit_text (out, "*/\n")
val () = emit_text (out, "#ifdef _ATS_CCOMP_PRELUDE_USER2_\n")
val () = emit_text (out, "//\n")
val () = emit_text (out, "#include _ATS_CCOMP_PRELUDE_USER2_\n")
val () = emit_text (out, "//\n")
val () = emit_text (out, "#endif /* _ATS_CCOMP_PRELUDE_USER2_ */\n")
//
in
  emit_newline (out)
end // end of [emit_ats_ccomp_prelude]

(* ****** ****** *)
//
// HX-2026-10: the [ref<Option(..)>] caches of ATS1 are cells of the global
// arena that hold a [gopt] (a null pointer is [None]); [initset2] resets them
//
extern
fun
the_dynconlst_get2(): d2conlst
and
the_dynconlst_set2(xs: d2conlst): void
and
the_dynconlst_initset2((*void*)): void
//
local

val
the_d2conlst = the_garena_alloc (i2sz(8))

in (*in-of-local*)

implement
the_dynconlst_get2
  ((*void*)) = let
//
val opt = $UN.ptr0_get<gopt(d2conlst)> (the_d2conlst)
//
in
//
if gopt_is_some (opt) then gopt_unsome<d2conlst> (opt)
else xs where
  {
    val xs = the_dynconlst_get()
    val () = $UN.ptr0_set<gopt(d2conlst)> (the_d2conlst, gopt_some<d2conlst>(xs))
  } (* end of [None] *)
//
end // end of [the_dynconlst_get2]

implement
the_dynconlst_set2(xs) =
  $UN.ptr0_set<gopt(d2conlst)> (the_d2conlst, gopt_some<d2conlst>(xs))
implement
the_dynconlst_initset2() =
  $UN.ptr0_set<gopt(d2conlst)> (the_d2conlst, gopt_none()(*void*))

end // end of [local]
//
(* ****** ****** *)
//
extern
fun
emit_funlablst_ptype
  (out: FILEref, fls: funlablst): void
//
implement
emit_funlablst_ptype (out, fls) = let
//
fun loop
(
  out: FILEref, fls: funlablst, i: int
) : void = let
in
//
if glist_is_cons (fls) then let
    val fl = glist_head<funlab> (fls)
    val fls = glist_tail<funlab> (fls)
    val fent =
      gopt_unsome<funent> (funlab_get_funent (fl))
    // end of [val]
    val () = emit_funent_ptype (out, fent)
  in
    loop (out, fls, i+1)
  end // end of [list_cons]
else ()
//
end // end of [loop]
//
in
  loop (out, fls, 0)
end // end of [emit_funlablst_ptype]
//
(* ****** ****** *)
//
extern
fun
emit_funlablst_closure
  (out: FILEref, fls: funlablst): void
//
implement
emit_funlablst_closure
  (out, fls) = let
//
fun loop
(
  out: FILEref, fls: funlablst, i: int
) : void = let
in
//
if glist_is_cons (fls) then let
    val fl = glist_head<funlab> (fls)
    val fls = glist_tail<funlab> (fls)
    val tmpknd = funlab_get_tmpknd(fl)
    val istmp =
    (
      if tmpknd > 0 then true else false
    ) : bool // end of [val]
    val isclo =
    (
      if istmp then false else let
        val fc = funlab_get_funclo(fl) in funclo_is_clo(fc)
      end // end of [let] // end of [if]
    ) : bool // end of [val]
    val fent = gopt_unsome<funent> (funlab_get_funent(fl))
    val () =
      if isclo then emit_funent_closure(out, fent)
    // end of [val]
  in
    loop(out, fls, i+1)
  end // end of [list_cons]
else ()
//
end // end of [loop]
//
in
  loop (out, fls, 0)
end // end of [emit_funlablst_closure]
//
(* ****** ****** *)
//
extern
fun
emit_funlablst_implmnt
  (out: FILEref, fls: funlablst): void
//
implement
emit_funlablst_implmnt
  (out, fls) = let
//
fun loop
(
  out: FILEref, fls: funlablst, i: int
) : void = let
in
//
if glist_is_cons (fls) then let
    val fl = glist_head<funlab> (fls)
    val fls = glist_tail<funlab> (fls)
    val tmpknd = funlab_get_tmpknd(fl)
    val fent = gopt_unsome<funent> (funlab_get_funent(fl))
    val () =
      if tmpknd > 0
        then fprint_string(out, "#if(0)\n")
      // end of [if]
    // end of [val]
    val () = emit_funent_implmnt(out, fent)
    val () =
      if tmpknd > 0
        then fprint_string(out, "#endif // end of [TEMPLATE]\n")
      // end of [if]
    // end of [val]
    val ((*flushed*)) = emit_newline(out)
  in
    loop(out, fls, i+1)
  end // end of [list_cons]
else ()
//
end // end of [loop]
//
in
  loop (out, fls, 0)
end // end of [emit_funlablst_implmnt]
//
(* ****** ****** *)

local

fun
auxlst_staticize
  (xs: tmpvarlst): void = let
in
//
if glist_is_cons (xs) then let
    val x = glist_head<tmpvar> (xs)
    val xs = glist_tail<tmpvar> (xs)
    val () = tmpvar_set_topknd(x, 1(*static*))
  in
    auxlst_staticize(xs)
  end // end of [list_cons]
else ()
//
end // end of [auxlst]

in (*in-of-local*)

implement
emit_the_tmpdeclst
  (out) = let
//
val p =
  the_toplevel_getref_tmpvarlst ()
val tmplst = $UN.ptr0_get<tmpvarlst> (p)
val () = auxlst_staticize (tmplst)
//
in
  emit_tmpdeclst (out, tmplst)
end // end of [emit_the_tmpdeclst]

end // end of [local]

(* ****** ****** *)

implement
emit_the_dynconlst_extdec
  (out) = let
//
val () = emit_text (out, "/*\n")
val () = emit_text (out, "dynconlst-declaration(beg)\n")
val () = emit_text (out, "*/\n")
//
val d2cs = the_dynconlst_get2 ()
val () = emit_d2conlst_extdec (out, d2cs)
//
val () = emit_text (out, "/*\n")
val () = emit_text (out, "dynconlst-declaration(end)\n")
val () = emit_text (out, "*/\n")
//
in
  // nothing
end // end of [emit_the_dynconlst_extdec]

(* ****** ****** *)
//
extern
fun
the_dyncstlst_get2(): d2cstlst
and
the_dyncstlst_set2(xs: d2cstlst): void
and
the_dyncstlst_initset2((*void*)): void
//
local

val the_d2cstlst = the_garena_alloc (i2sz(8))

in (*in-of-local*)

implement
the_dyncstlst_get2
  ((*void*)) = let
//
val opt = $UN.ptr0_get<gopt(d2cstlst)> (the_d2cstlst)
//
in
//
if gopt_is_some (opt) then gopt_unsome<d2cstlst> (opt)
else let
    val xs = the_dyncstlst_get()
    val () = $UN.ptr0_set<gopt(d2cstlst)> (the_d2cstlst, gopt_some<d2cstlst>(xs))
  in
    xs
  end // end of [None]
//
end // end of [the_dyncstlst_get2]

implement
the_dyncstlst_set2(xs) =
  $UN.ptr0_set<gopt(d2cstlst)> (the_d2cstlst, gopt_some<d2cstlst>(xs))
implement
the_dyncstlst_initset2() =
  $UN.ptr0_set<gopt(d2cstlst)> (the_d2cstlst, gopt_none()(*void*))

end // end of [local]
//
(* ****** ****** *)

implement
emit_the_dyncstlst_extdec
  (out) = let
//
val () = emit_text (out, "/*\n")
val () = emit_text (out, "dyncstlst-declaration(beg)\n")
val () = emit_text (out, "*/\n")
//
val d2cs = the_dyncstlst_get2 ()
val () = emit_d2cstlst_extdec (out, d2cs)
//
val () = emit_text (out, "/*\n")
val () = emit_text (out, "dyncstlst-declaration(end)\n")
val () = emit_text (out, "*/\n")
//
in
  // nothing
end // end of [emit_the_dyncstlst_extdec]

(* ****** ****** *)
//
extern
fun
the_extcodelst_get2(): hideclist
and
the_extcodelst_set2(xs: hideclist): void
and
the_extcodelst_initset2( (*void*) ): void
//
local

val
the_extlst = the_garena_alloc (i2sz(8))

in (*in-of-local*)

implement
the_extcodelst_get2
  ((*void*)) = let
//
val opt = $UN.ptr0_get<gopt(hideclist)> (the_extlst)
//
in
//
if gopt_is_some (opt) then gopt_unsome<hideclist> (opt)
else let
    val xs = the_extcodelst_get()
    val () = $UN.ptr0_set<gopt(hideclist)> (the_extlst, gopt_some<hideclist>(xs))
  in
    xs
  end // end of [None]
//
end // end of [the_extcodelst_get2]

implement
the_extcodelst_set2(xs) =
  $UN.ptr0_set<gopt(hideclist)> (the_extlst, gopt_some<hideclist>(xs))
implement
the_extcodelst_initset2() =
  $UN.ptr0_set<gopt(hideclist)> (the_extlst, gopt_none()(*void*))

end // end of [local]
//
(* ****** ****** *)
//
extern
fun
the_funlablst_get2
  ((*void*)): funlablst
and
the_funlablst_set2
  (fls: funlablst): void
and
the_funlablst_initset2(): void
//
local
//
val
the_flablst = the_garena_alloc (i2sz(8))
//
in (* in of [local] *)

implement
the_funlablst_get2
  ((*void*)) = let
//
val opt = $UN.ptr0_get<gopt(funlablst)> (the_flablst)
//
in
//
if gopt_is_some (opt) then gopt_unsome<funlablst> (opt)
else xs where
  {
    val xs = the_funlablst_get()
    val () = $UN.ptr0_set<gopt(funlablst)> (the_flablst, gopt_some<funlablst>(xs))
  } (* end of [None] *)
//
end // end of [the_fublablst_get2]

implement
the_funlablst_set2(fls) =
  $UN.ptr0_set<gopt(funlablst)> (the_flablst, gopt_some<funlablst>(fls))
implement
the_funlablst_initset2() =
  $UN.ptr0_set<gopt(funlablst)> (the_flablst, gopt_none()(*void*))

end // end of [local]
//
(* ****** ****** *)

implement
emit_the_funlablst
  (out) = let
//
val
fls = the_funlablst_get2()
//
val () = emit_funlablst_ptype(out, fls)
val () = emit_funlablst_closure(out, fls)
val () = emit_funlablst_implmnt(out, fls)
//
in
  // nothing
end // end of [emit_the_funlablst]

(* ****** ****** *)

implement
emit_the_primdeclst
  (out) = let
//
val p0 =
  the_toplevel_getref_primdeclst()
//
val pmdlst = $UN.ptr0_get<primdeclst>(p0)
//
in
  emit_primdeclst (out, pmdlst)
end // end of [emit_the_primdeclst]

(* ****** ****** *)

local

fun
aux
(
  out: FILEref, x: primdec
) : void = let
in
//
case+
primdec_node_view (x.primdec_node ())
of // case+
//
| ~PMDimpdec(imp) => let
    val opt =
      hiimpdec_get_instrlstopt(imp)
    // end of [val]
  in
    if gopt_is_none (opt) then ()
    else let
//
        val d2c =
          imp.hiimpdec_cst ()
        val hse =
          gopt_unsome<hisexp> (d2cst_get2_hisexp (d2c))
//
        val () = emit_text(out, "ATSdyncst_valimp(")
        val () = emit_d2cst (out, d2c)
        val () = emit_text (out, ", ")
        val () = emit_hisexp (out, hse)
        val () = emit_text (out, ") ;\n")
//
      in
        // nothing
      end // end of [Some]
  end // end of [PMDimpdec]
//
| ~PMDlocal
    (xs_head, xs_body) =>
  {
    val ((*void*)) = auxlst (out, xs_head)
    val ((*void*)) = auxlst (out, xs_body)
  } (* end of [PMDlocal] *)
//
| ~PMDinclude
    (knd, xs_incl) => if knd > 0 then auxlst(out, xs_incl)
  // end of [PMDinclude]
//
| v (*rest-of-PMD*) => primdec_node_view_free (v)
//
end // end of [aux]

and
auxlst
(
  out: FILEref, xs: primdeclst
) : void = let
in
//
if glist_is_cons (xs) then let
    val x = glist_head<primdec> (xs)
    val xs = glist_tail<primdec> (xs)
    val () = aux (out, x) in auxlst (out, xs)
  end // end of [list_cons]
else ()
//
end // end of [auxlst]

in (* in of [local] *)

implement
emit_the_primdeclst_valimp
  (out) = let
//
val p =
  the_toplevel_getref_primdeclst ()
// end of [val]
val pmdlst = $UN.ptr0_get<primdeclst> (p)
//
val () = emit_text (out, "/*\n")
val () = emit_text (out, "dynvalist-implementation(beg)\n")
val () = emit_text (out, "*/\n")
//
val () = auxlst (out, pmdlst)
//
val () = emit_text (out, "/*\n")
val () = emit_text (out, "dynvalist-implementation(end)\n")
val () = emit_text (out, "*/\n")
//
in
  // nothing
end // end of [emit_the_primdeclst_valimp]

end // end of [local]

(* ****** ****** *)

(*
#define MAIN_NONE 0
#define MAIN_VOID 1 // main()
#define MAIN_ARGC_ARGV 2 // main(argc, argv)
#define MAIN_ARGC_ARGV_ENVP 3 // main(argc, argv, envp)
*)

(* ****** ****** *)
//
extern
fun
the_mainats_initize(): void
extern
fun
the_mainats_d2copt_get(): d2cstopt
//
(* ****** ****** *)

local
//
val
the_mainats_d2copt = the_garena_alloc (i2sz(8))
//
in (* in of [local] *)

implement
the_mainats_initize
  ((*void*)) = let
//
fun
loop(fls: funlablst): void = let
//
in
//
if glist_is_cons (fls) then let
    val fl = glist_head<funlab> (fls)
    val fls = glist_tail<funlab> (fls)
    val opt =
      funlab_get_d2copt(fl)
    // end of [val]
    val () = (
      if gopt_is_some (opt) then let
        val d2c = gopt_unsome<d2cst> (opt)
      in
        if $D2E.d2cst_is_mainats(d2c)
          then $UN.ptr0_set<d2cstopt> (the_mainats_d2copt, opt)
        // end of [if]
      end else ()
    ) : void // end of [val]
  in
    loop(fls)
  end // end of [list_cons]
else ()
//
end // end of [loop]
//
val () =
  $UN.ptr0_set<d2cstopt> (the_mainats_d2copt, gopt_none())
//
in
  loop(the_funlablst_get2((*void*)))
end // end of [the_mainats_initize]

implement
the_mainats_d2copt_get() = $UN.ptr0_get<d2cstopt> (the_mainats_d2copt)

end // end of [local]

(* ****** ****** *)

extern
fun
the_dynloadflag_get(): int

implement
the_dynloadflag_get() = let
//
val
the_mainatsflag =
  $GLOB.the_MAINATSFLAG_get()
//
in
//
if
the_mainatsflag = 0
then let
  val opt = the_mainats_d2copt_get()
in
//
if gopt_is_some (opt) then (~1)
else $GLOB.the_DYNLOADFLAG_get()
//
end // end of [then]
else (~1) // HX: mainatsflag overrules dynloadflag
//
end // end of [the_dynloadflag_get]

(* ****** ****** *)

extern
fun
emit_main_arglst_err
  (out: FILEref, arty: int): void
implement
emit_main_arglst_err
  (out, arty) = let
//
val () =
  if arty >= 1 then emit_text (out, "argc")
val () =
  if arty >= 2 then emit_text (out, ", argv")
val () =
  if arty >= 3 then emit_text (out, ", envp")
val () = (
  if arty <= 0
    then emit_text (out, "err") else emit_text (out, ", err")
  // end of [if]
) : void // end of [val]
//
in
  // nothing
end // end of [emit_main_arglst_err]

(* ****** ****** *)
//
// HX-2026-10: this [emit_dynload] (out, infil) shadows the one of
// pats_ccomp.sats (out, hid) in this file only, as in ATS1
//
extern
fun
emit_dynload
  (out: FILEref, infil: filename): void
implement
emit_dynload
  (out, infil) =
{
  val () = emit_filename(out, infil)
  val () = emit_text(out, "__dynload")
}

extern
fun
emit_dynloadflag
  (out: FILEref, infil: filename): void
implement
emit_dynloadflag
  (out, infil) =
{
  val () = emit_filename(out, infil)
  val () = emit_text(out, "__dynloadflag")
}

(* ****** ****** *)

local

(* ****** ****** *)
//
staload "./pats_utils.sats"
staload _(*anon*) = "./pats_utils.dats"
//
(* ****** ****** *)

fn
the_tmpdeclst_emit
  (out: FILEref, _: int): void = emit_the_tmpdeclst(out)
// end of [the_tmpdeclst_emit]

fn
the_primdeclst_emit
  (out: FILEref, _: int): void = emit_the_primdeclst(out)
// end of [the_primdeclst_emit]

fn
the_funlablst_emit
  (out: FILEref, _: int): void = emit_the_funlablst(out)
// end of [the_funlablst_emit]

fun
the_tmpdeclst_stringize
(
) = tostring_fprint<int>
(
  "postiats_tmpdeclst_"
, the_tmpdeclst_emit, 0
) // end of [the_tmpdeclst_stringize]

fun
the_primdeclst_stringize
(
) = tostring_fprint<int>
(
  "postiats_primdeclst_"
, the_primdeclst_emit, 0
) // end of [the_funlablst_stringize]

fun
the_funlablst_stringize
(
) = tostring_fprint<int>
(
  "postiats_funlablst_", the_funlablst_emit, 0
) // end of [the_funlablst_stringize]

fun
aux_staload
  (out: FILEref): void = let
//
fun loop
(
  out: FILEref, xs: hideclist
) : void = let
in
//
if glist_is_cons (xs) then let
    val x = glist_head<hidecl> (xs)
    val xs = glist_tail<hidecl> (xs)
    val () =
      emit_staload(out, x) in loop(out, xs)
    // end of [val]
  end // end of [list_cons]
else ()
//
end // end of [loop]
//
val () = emit_text (out, "/*\n")
val () = emit_text (out, "staload-prologues(beg)\n")
val () = emit_text (out, "*/\n")
//
val () = loop(out, the_staloadlst_get())
//
val () = emit_text (out, "/*\n")
val () = emit_text (out, "staload-prologues(end)\n")
val () = emit_text (out, "*/\n")
//
in
  // nothing
end // end of [aux_staload]

fun
aux_dynload_ext
  (out: FILEref): void = let
//
fun loop
(
  out: FILEref, xs: hideclist
) : void = let
in
//
if glist_is_cons (xs) then let
    val x = glist_head<hidecl> (xs)
    val xs = glist_tail<hidecl> (xs)
    val-~HIDdynload (fil) = hidecl_node_view (x.hidecl_node ())
    val () = (
      emit_text
      (out, "ATSdynloadflag_init(");
      emit_filename(out, fil);
      emit_text(out, "__dynloadflag) ;\n")
    ) (* end of [val] *)
    val () =
      emit_text (out, "ATSextern()\n")
    val () =
      emit_text (out, "atsvoid_t0ype\n")
    val () = (
      emit_filename (out, fil);
      emit_text (out, "__dynload(/*void*/) ;\n")
    ) (* end of [val] *)
  in
    loop (out, xs)
  end (* end of [list_cons] *)
else ()
//
end // end of [loop]
//
in
  loop(out, the_dynloadlst_get())
end // end of [aux_dynload_ext]

fun
aux_dynload_ias
(
  out: FILEref
, infil: filename
) : void = let
//
val opt =
  $GLOB.the_DYNLOADNAME_get()
//
in
//
if
stropt_is_some(opt)
then let
//
val
name = stropt_unsome(opt)
//
val () = emit_text(out, "ATSextern()\n")
val () = emit_text(out, "atsvoid_t0ype\n")
//
val () =
(
  emit_text(out, name); emit_text(out, "()\n{\n")
)
//
val () = emit_text(out, "ATSfunbody_beg()\n")
//
val () =
  emit_text(out, "ATSINSmove_void(tmpret_void, ")
val () =
(
  emit_dynload(out, infil); emit_text(out, "()) ;\n")
)
//
val () = emit_text (out, "ATSfunbody_end()\n")
//
val () = emit_text (out, "ATSreturn_void(tmpret_void) ;\n")
//
val () = emit_text (out, "} // end-of-dynload-alias\n")
//
in
  // nothing
end // end of [then]
else () // end of [else]
//
end // end of [aux_dynload_ias]

fun
aux_dynload_def
(
  out: FILEref
, infil: filename, fbody: string
) : void = let
//
val
flag = the_dynloadflag_get()
//
val () =
if
(flag = 0)
then
emit_text(out, "#if(0)\n")
//
val () = emit_text(out, "/*\n")
val () =
(
emit_text
( out
, "** for initialization(dynloading)"
) (* emit_text *)
) (* end of [val] *)
//
val () = emit_text(out, "\n*/\n")
//
val () =
if
flag <= 0
then
(
//
emit_text(out, "ATSdynloadflag_minit(");
emit_dynloadflag(out, infil); emit_text(out, ") ;\n")
//
) (* end of [if] *)
//
val () = emit_text(out, "ATSextern()\n")
val () = emit_text(out, "atsvoid_t0ype\n")
//
val () = emit_dynload(out, infil)
val () = emit_text(out, "()\n{\n")
//
val () = emit_text(out, "ATSfunbody_beg()\n")
//
val () = emit_text(out, "ATSdynload(/*void*/)\n")
//
val () =
if
flag <= 0
then
emit_text
(out, "ATSdynloadflag_sta(\n")
//
val () =
if
flag >= 1
then
emit_text
(out, "ATSdynloadflag_ext(\n")
//
val () = emit_dynloadflag(out, infil)
val () = emit_text (out, "\n) ;\n")
val () = emit_text (out, "ATSif(\n")
val () = emit_text (out, "ATSCKiseqz(\n")
val () = emit_dynloadflag (out, infil)
val () = emit_text (out, "\n)\n) ATSthen() {\n")
val () = emit_text (out, "ATSdynloadset(")
val () = emit_dynloadflag (out, infil)
val ((*closing*)) = emit_text (out, ") ;\n")
//
val () = let
  val d2cs = the_dynconlst_get2()
  val () = emit_text (out, "/*\n")
  val () = emit_text (out, "dynexnlst-initize(beg)\n")
  val () = emit_text (out, "*/\n")
  val () = emit_d2conlst_initize (out, d2cs)
  val () = emit_text (out, "/*\n")
  val () = emit_text (out, "dynexnlst-initize(end)\n")
  val () = emit_text (out, "*/\n")
in
  // nothing
end // end of [val]
//
val () = emit_text (out, fbody)
val () = emit_text (out, "} /* ATSendif */\n")
//
val () = emit_text (out, "ATSfunbody_end()\n")
//
val () = emit_text (out, "ATSreturn_void(tmpret_void) ;\n")
val () = emit_text (out, "} /* end of [*_dynload] */\n")
//
val () = aux_dynload_ias (out, infil) // HX: creating an alias
//
val () =
if flag = 0 then emit_text (out, "#endif // end of [#if(0)]\n")
//
in
  // nothing
end // end of [aux_dynload_def]

fun
aux_main
(
  out: FILEref
, infil: filename, d2cmain: d2cst
) : void = let
//
val () = emit_text (out, "\n/*\n")
val () = emit_text (out, "** the ATS runtime")
val () = emit_text (out, "\n*/\n")
val () = emit_text (out, "#ifndef _ATS_CCOMP_RUNTIME_NONE_\n")
val () = emit_text (out, "#include \"pats_ccomp_runtime.c\"\n")
val () = emit_text (out, "#include \"pats_ccomp_runtime_memalloc.c\"\n")
val () = emit_text (out, "#ifndef _ATS_CCOMP_EXCEPTION_NONE_\n")
val () = emit_text (out, "#include \"pats_ccomp_runtime2_dats.c\"\n")
val () = emit_text (out, "#ifndef _ATS_CCOMP_RUNTIME_TRYWITH_NONE_\n")
val () = emit_text (out, "#include \"pats_ccomp_runtime_trywith.c\"\n")
val () = emit_text (out, "#endif /* _ATS_CCOMP_RUNTIME_TRYWITH_NONE_ */\n")
val () = emit_text (out, "#endif // end of [_ATS_CCOMP_EXCEPTION_NONE_]\n")
val () = emit_text (out, "#endif /* _ATS_CCOMP_RUNTIME_NONE_ */\n")
//
val () = emit_text (out, "\n/*\n")
val () = emit_text (out, "** the [main] implementation")
val () = emit_text (out, "\n*/\n")
//
val () = emit_text (out, "int\n")
val () = emit_text (out, "main\n")
val () = emit_text (out, "(\n")
val () = emit_text (out, "int argc, char **argv, char **envp")
val () = emit_text (out, "\n) {\n")
val () = emit_text (out, "int err = 0 ;\n")
val () = {
  val () = emit_filename (out, infil)
  val () = emit_text (out, "__dynload() ;\n")
} (* end of [val] *)
//
val arty = let
//
val ns =
  $D2E.d2cst_get_artylst(d2cmain)
//
in
  if glist_is_cons (ns) then glist_head<int> (ns) else 0
end : int // end of [val]
//
val () = emit_text (out, "ATS")
val () = emit_d2cst (out, d2cmain)
val () = emit_LPAREN (out)
val () = emit_main_arglst_err (out, arty)
val () = emit_RPAREN (out)
val () = emit_text (out, " ;\n")
//
val () = emit_text (out, "return (err) ;\n")
val () = emit_text (out, "} /* end of [main] */")
val () = emit_newline (out)
//
in
  // nothing
end // end of [aux_main]

fun
aux_main_ifopt
(
  out: FILEref, infil: filename
) : void = let
//
val opt = the_mainats_d2copt_get()
//
in
//
if gopt_is_some (opt)
  then aux_main(out, infil, gopt_unsome<d2cst> (opt)) else ()
//
end // end of [aux_main_ifopt]

#define DYNBEG 1
#define DYNMID 10
#define DYNEND 99

fun
aux_extcodelst_if
(
  out: FILEref, test: (int) -> bool
) : void = let
//
fun
loop
(
  out: FILEref, test: (int) -> bool, xs: hideclist
) : hideclist = let
in
//
if glist_is_cons (xs) then let
    val x = glist_head<hidecl> (xs)
    val xs1 = glist_tail<hidecl> (xs)
    val-~HIDextcode(knd, pos, _) = hidecl_node_view (x.hidecl_node ())
  in
    if test(pos) then let
      val () = emit_extcode(out, x) in loop(out, test, xs1)
    end else xs // end of [if]
  end // end of [if]
else glist_nil()
//
end // end of [loop]
//
val xs2 = loop(out, test, the_extcodelst_get2())
val ((*set*)) = the_extcodelst_set2(xs2)
//
in
  // nothing
end // end of [aux_extcodelst_if]

fn pos_eq_DYNBEG (pos: int): bool = (pos = DYNBEG)
fn pos_lt_DYNMID (pos: int): bool = (pos < DYNMID)
fn pos_lte_DYNMID (pos: int): bool = (pos <= DYNMID)
fn pos_lte_DYNEND (pos: int): bool = (pos <= DYNEND)

fun
aux_exndeclst
  (out: FILEref): void = let
//
fun
loop
(
  out: FILEref, xs: hideclist
) : void = let
in
//
if glist_is_cons (xs) then let
    val x = glist_head<hidecl> (xs)
    val xs = glist_tail<hidecl> (xs)
    val () = emit_exndec(out, x) in loop(out, xs)
  end // end of [list_cons]
else ()
//
end // end of [loop]
//
val () =
(
emit_text (out, "/*\n");
emit_text (out, "exnconlst-declaration(beg)\n");
emit_text (out, "*/\n");
) (* end of [val] *)
//
val () =
emit_text
(
  out
, "#ifndef _ATS_CCOMP_EXCEPTION_NONE_\n"
)
val () =
emit_text
(
  out
, "ATSextern()\natsvoid_t0ype\nthe_atsexncon_initize\n(\n  atstype_exnconptr d2c, atstype_string exnmsg\n) ;\n"
) // end of [val]
val () =
emit_text (out, "#endif // end of [_ATS_CCOMP_EXCEPTION_NONE_]\n")
//
val hids = the_exndeclst_get ()
val ((*void*)) = loop (out, hids)
//
val () = (
emit_text (out, "/*\n");
emit_text (out, "exnconlst-declaration(end)\n");
emit_text (out, "*/\n");
) (* end of [val] *)
//
in
  (* nothing *)
end // end of [aux_exndeclst]

(* ****** ****** *)

fun
aux_saspdeclst
(
  out: FILEref
) : void = let
//
fun
loop
(
  out: FILEref, xs: hideclist
) : void = let
in
//
if glist_is_cons (xs) then let
    val x = glist_head<hidecl> (xs)
    val xs = glist_tail<hidecl> (xs)
    val () = emit_saspdec(out, x)
  in
    loop(out, xs)
  end (* end of [list_cons] *)
else ((*void*))
//
end // end of [loop]
//
val () =
emit_text(out, "/*\n")
val () =
emit_text(out, "assumelst-declaration(beg)\n")
val () =
emit_text(out, "*/\n")
//
val () =
emit_text(out, "#ifndef _ATS_CCOMP_ASSUME_CHECK_NONE_\n")
//
val ((*void*)) =
loop(out, hids) where
{
  val hids = the_saspdeclst_get((*void*))
} (* end of [where] *) // end of [val]
//
val () =
emit_text(out, "#endif // #ifndef(_ATS_CCOMP_ASSUME_CHECK_NONE_)\n")
//
val () =
emit_text(out, "/*\n")
val () =
emit_text(out, "assumelst-declaration(end)\n")
val () =
emit_text(out, "*/\n")
//
in
  (* nothing *)
end // end of [aux_saspdeclst]

(* ****** ****** *)

fun
aux_extypelst
  (out: FILEref): void = let
//
fun loop
(
  out: FILEref, xs: hideclist
) : void = let
in
//
if glist_is_cons (xs) then let
    val x = glist_head<hidecl> (xs)
    val xs = glist_tail<hidecl> (xs)
    val () = emit_extype (out, x) in loop (out, xs)
  end // end of [list_cons]
else ((*void*))
//
end // end of [loop]
//
val () = emit_text (out, "/*\n")
val () = emit_text (out, "extypelst-declaration(beg)\n")
val () = emit_text (out, "*/\n")
//
val hids = the_extypelst_get ()
val ((*void*)) = loop (out, hids)
//
val () = emit_text (out, "/*\n")
val () = emit_text (out, "extypelst-declaration(end)\n")
val () = emit_text (out, "*/\n")
//
in
  (* nothing *)
end // end of [aux_extypelst]

in (* in of [local] *)

implement
ccomp_main
(
  out, flag, infil, hids
) = let
//
val () =
{
//
val () = the_dynconlst_initset2()
val () = the_dyncstlst_initset2()
val () = the_extcodelst_initset2()
val () = the_funlablst_initset2()
//
} (* end of [val] *)
//
val () = emit_time_stamp(out)
//
val () = emit_ats_ccomp_header(out)
val () = emit_ats_ccomp_prelude(out)
//
val () = let
  val pmds = hideclist_ccomp0(hids)
  val p_pmds = the_toplevel_getref_primdeclst()
  val () = $UN.ptr0_set<primdeclst>(p_pmds, pmds)
  val tmps =
    primdeclst_get_tmpvarset(pmds)
  val tmps =
    tmpvarset_vt_listize_free(tmps)
  val tmps = glist_make_list_vt<tmpvar>(tmps)
  val p_tmps = the_toplevel_getref_tmpvarlst()
  val () = $UN.ptr0_set<tmpvarlst>(p_tmps, tmps)
in
  // nothing
end // end of [val]
//
val
the_tmpdeclst_rep = the_tmpdeclst_stringize()
val
the_primdeclst_rep = the_primdeclst_stringize()
val
the_funlablst_rep = the_funlablst_stringize()
//
val () = aux_staload(out)
//
val () =
aux_extcodelst_if
  (out, pos_eq_DYNBEG)
//
val () = emit_the_typedeflst(out)
//
val () =
  emit_the_dynconlst_extdec(out)
val () =
  emit_the_dyncstlst_extdec(out)
//
val () =
  emit_the_primdeclst_valimp(out)
//
val () =
{
  val () = aux_exndeclst(out)
  val () = aux_extypelst(out)
  val () = aux_saspdeclst(out)
}
//
val () =
aux_extcodelst_if
  (out, pos_lt_DYNMID)
//
val () =
  fprint_strptr(out, the_tmpdeclst_rep)
val () = strptr_free(the_tmpdeclst_rep)
//
val () =
aux_extcodelst_if
  (out, pos_lte_DYNMID)
//
val () =
  fprint_strptr(out, the_funlablst_rep)
val () = strptr_free(the_funlablst_rep)
//
val () = // HX: the call must be made before
  the_mainats_initize() // aux_dynload is called
//
val () =
aux_dynload_ext(out)
val () =
aux_dynload_def(out, infil, fbody) where
{
  val fbody = $UN.castvwtp1{string}(the_primdeclst_rep)
} // end of [where] // end of [val]
val () = strptr_free (the_primdeclst_rep)
//
val () =
aux_main_ifopt(out, infil)
//
val () =
aux_extcodelst_if(out, pos_lte_DYNEND)
//
val () =
emit_text(out, "\n/* ****** ****** */\n")
val () =
emit_text(out, "\n/* end-of-compilation-unit */\n")
//
in
  // nothing
end // end of [ccomp_main]

end // end of [local for [ccomp_main]]

(* ****** ****** *)

(* end of [pats_ccomp_main.dats] *)
