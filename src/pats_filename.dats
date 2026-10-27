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
//
#include "share/atspre_staload.hats"
#include "./pats_assert.hats"
//
(* ****** ****** *)

staload
UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)
//
staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"
//
(* ****** ****** *)
//
staload
UTL = "./pats_utils.sats"
staload
_(*UTL*) = "./pats_utils.dats"
//
(* ****** ****** *)
//
staload SYM = "./pats_symbol.sats"
//
typedef symbol = $SYM.symbol
overload = with $SYM.eq_symbol_symbol
//
(* ****** ****** *)

staload "./pats_filename.sats"

(* ****** ****** *)
//
fn
ptr_succ_char
  (p: ptr): ptr = ptr0_succ<char> (p)
//
(* ****** ****** *)
//
// HX: the global (never freed) cells for the global state
//
fun{a:t@ype}
gcell_make (x: a): ptr = let
  val p = the_garena_alloc (sizeof<a>)
  val () = $UN.ptr0_set<a> (p, x)
in
  p
end // end of [gcell_make]
//
(* ****** ****** *)

local
//
val theDirSep: char = '/'
val theCurDir: string = "./"
val theParDir: string = "../"
//
in (* in of [local] *)

implement theDirSep_get () = theDirSep
implement theCurDir_get () = theCurDir
implement theParDir_get () = theParDir

end // end of [local]

(* ****** ****** *)

local
//
staload
STR = "libats/libc/SATS/string.sats"
//
macdef strncmp = $STR.strncmp
//
in (* in of [local] *)

implement
givename_srchknd
  (given) = let
//
val dir = theCurDir_get()
val len = string_length(dir)
//
in
//
if
strncmp
(given, dir, len) = 0
then 0(*loc*)
else
(
(
if
0 =
strncmp
(
given, "$PATSHOMELOCS/", i2sz(14)
)
then 1
else 2(*ext*)
) (* end of [else] *)
) (* end of [else] *)
//
end // end of [givename_srchknd]

(* ****** ****** *)
//
// HX-2013-09:
// a gurled name looks like this:
// {}prelude/SATS/string.sats
// {$ATSCNTRB}/libgmp/SATS/string.sats
// {http://ats-lang.org/LIBRARY}prelude/SATS/string.sats
// {git@github.com:githwxi/ATS-Postiats.git}prelude/SATS/string.sats
//
implement
givename_get_ngurl
  (given) = let
//
fun loop
(
  p: ptr, n: int
, c0: char, c1: char
) : ptr = let
//
val c =
  $UN.ptr0_get<char>(p)
//
val p1 = ptr_succ_char(p)
//
in
//
case+ 0 of
| _ when c = c0 =>
    loop(p1, n+1, c0, c1)
| _ when c = c1 =>
    if n > 1 then loop(p1, n-1, c0, c1) else p1
| _ (* !=c0,c1 *) =>
    if c != '\000' then loop(p1, n, c0, c1) else the_null_ptr
//
end (* end of [loop] *)
//
val p0 = $UN.cast{ptr} (given)
val c0 = $UN.ptr0_get<char> (p0)
//
val p1 = (
case+ 0 of
| _ when
    c0 = '\{' => let
    val p = ptr_succ_char(p0) in loop (p, 1, c0, '\}')
  end // end of [_ when ...]
| _ (*rest-of-chars*) => the_null_ptr
) : ptr // end of [val]
//
val i0 = $UN.cast{lint}(p0)
val i1 = $UN.cast{lint}(p1)
//
in
  if i1 > i0 then $UN.cast{int}(i1 - i0) else ~1
end // end of [givename_get_ngurl]

end // end of [local]

(* ****** ****** *)
//
// HX: a filename is a cell [givename, partname, fullname]
// in the global arena
//
assume filename_type = ptr

fn
filename_new
(
  given: string, pname: string, fname: symbol
) : filename = let
  val p = the_garena_alloc (i2sz(24))
  val () = $UN.ptr0_set<string> (p, given)
  val () = $UN.ptr0_set<string> (ptr0_add_guint<byte> (p, i2sz(8)), pname)
  val () = $UN.ptr0_set<symbol> (ptr0_add_guint<byte> (p, i2sz(16)), fname)
in
  $UN.cast{filename}(p)
end // end of [filename_new]

(* ****** ****** *)
//
implement
filename_get_givename
  (fil) = $effmask_all ($UN.ptr0_get<string> ($UN.cast{ptr}(fil)))
//
implement
filename_get_partname
  (fil) =
  $effmask_all ($UN.ptr0_get<string> (ptr0_add_guint<byte> ($UN.cast{ptr}(fil), i2sz(8))))
//
implement
filename_get_fullname
  (fil) =
  $effmask_all ($UN.ptr0_get<symbol> (ptr0_add_guint<byte> ($UN.cast{ptr}(fil), i2sz(16))))
//
(* ****** ****** *)

implement
print_filename_full
  (fil) =
  fprint_filename_full(stdout_ref, fil)
implement
prerr_filename_full
  (fil) =
  fprint_filename_full(stderr_ref, fil)
implement
fprint_filename_full
  (out, fil) = let
  val fname =
  $SYM.symbol_get_name(filename_get_fullname(fil))
in
  fprint_string(out, fname)
end // end of [fprint_filename_full]

(* ****** ****** *)

implement
fprint2_filename_full
  (out, fil) = let
//
val given =
  filename_get_givename(fil)
val ngurl =
  givename_get_ngurl(given)
val fname =
  $SYM.symbol_get_name(filename_get_fullname(fil))
//
in
//
if ngurl < 0
  then fprint_string(out, fname)
  else
  (
    fprint_string(out, fname);
    fprint_string(out, "("); fprint_string(out, given); fprint_string(out, ")")
  ) (* end of [else] *)
// end of [if]
//
end // end of [fprint2_filename_full]

(* ****** ****** *)

implement
eq_filename_filename
  (x1, x2) =
  $effmask_all (filename_get_fullname(x1) = filename_get_fullname(x2))
// end of [eq_filename_filename]

(* ****** ****** *)

implement
compare_filename_filename
  (x1, x2) = let
//
val f1 =
$effmask_all ($SYM.symbol_get_name(filename_get_fullname(x1)))
//
val f2 =
$effmask_all ($SYM.symbol_get_name(filename_get_fullname(x2)))
//
val sgn = $effmask_all (compare_string_string (f1, f2))
//
in
  if sgn < 0 then ~1 else (if sgn > 0 then 1 else 0)
end // end of [compare_filename_filename]

(* ****** ****** *)
//
local
//
// HX: implemented in [pats_utils.dats]
//
extern
fun
string_test_suffix
(
  str: string, sffx: string
) : bool =
  "ext#patsopt_string_test_suffix"

in (* in of [local] *)
//
implement
filename_is_sats (fil) =
string_test_suffix
  (filename_get_partname(fil), ".sats")
//
implement
filename_is_dats (fil) =
string_test_suffix
  (filename_get_partname(fil), ".dats")
//
end // end of [local]
//
(* ****** ****** *)
//
extern
fun
givename_is_relative
  (given: string): bool
//
implement
givename_is_relative
  (given) = let
//
fun
aux
{n:int}
{i:nat | i <= n}
(
  given: string(n)
, i: size_t(i), dirsep: char
) : bool = let
//
val isnot =
  string_isnot_atend(given, i)
//
in
  if isnot
    then (given[i] != dirsep) else false
  // end of [if]
end // end of [aux]
//
val given =
  g1ofg0 (given)
//
val dirsep = theDirSep_get ()
//
in
  aux (given, i2sz(0), dirsep)
end // [givename_is_relative]
//
(* ****** ****** *)

implement
filename_dummy =
  filename_new ("", "", $SYM.symbol_empty)

implement
filename_stdin =
  filename_new ("__STDIN__", "__STDIN__", $SYM.symbol__STDIN__)

implement
filename_string =
  filename_new ("__STRING__", "__STRING__", $SYM.symbol__STRING__)

(* ****** ****** *)
//
implement
filename_is_dummy(fil) =
if
(
  filename_get_fullname(fil) = $SYM.symbol_empty
) then true else false
//
implement
filename_isnot_dummy(fil) =
if
(
  filename_get_fullname(fil) = $SYM.symbol_empty
) then false else true
//
(* ****** ****** *)
//
fn
fprint_path
  (out: FILEref, x: path): void = fprint_string(out, x)
//
implement
print_pathlst(xs) =
fprint_pathlst(stdout_ref, xs)
implement
prerr_pathlst(xs) =
fprint_pathlst(stderr_ref, xs)
//
implement
fprint_pathlst(out, xs) =
$UTL.fprintlst<path>(out, xs, ":", fprint_path)
//
(* ****** ****** *)
//
// HX: [getcwd_gc] of libats/libc is not implemented; the C code is below
//
extern
fun
patsopt_getcwd_gc(): Strptr0 = "ext#patsopt_getcwd_gc"
//
(* ****** ****** *)

local
//
vtypedef strptrlst = List0_vt (Strptr1)
//
fn
p2s
(
  x: !Strptr1
) :<> string = $UN.strptr2string(x)
//
fun
strptrlst_free
  (xs: strptrlst): void =
(
case+ xs of
| ~list_vt_nil () => ()
| ~list_vt_cons (x, xs) => (strptr_free (x); strptrlst_free (xs))
) (* end of [strptrlst_free] *)

fun
strptrlst_concat
  (xs: !strptrlst): Strptr1 =
(
case+ xs of
| list_vt_nil () => string0_copy ("")
| @list_vt_cons (x, xs1) => let
    val rest = strptrlst_concat (xs1)
    val res = string0_append (p2s(x), p2s(rest))
    val ((*freed*)) = strptr_free (rest)
  in
    res
  end // end of [list_vt_cons]
) (* end of [strptrlst_concat] *)
//
in (* in of [local] *)

implement
path_normalize_vt
  (s0) = let
//
fun
loop1
{n0,i0:nat | i0 <= n0}
(
  dirsep: char
, s0: string n0, n0: size_t n0, i0: size_t i0
, dirs: &strptrlst >> _
) : void =
(
if i0 < n0
  then loop2(dirsep, s0, n0, i0, i0, dirs) else ()
)
//
and
loop2
{n0,i0,i:nat | i0 < n0; i0 <= i; i <= n0}
(
  dirsep: char
, s0: string n0, n0: size_t n0, i0: size_t i0, i: size_t i
, dirs: &strptrlst >> _
) : void =
(
if
(i < n0)
then let
(*
  // empty
*)
in
//
if
(s0[i] != dirsep)
then
(
  loop2 (dirsep, s0, n0, i0, succ(i), dirs)
) (* end of [then] *)
else let
  val sbp =
  string_make_substring(s0, i0, succ(i - i0))
  val dir = $UN.castvwtp0{Strptr1}(sbp) // this is a no-op cast
in
  dirs := list_vt_cons (dir, dirs); loop1 (dirsep, s0, n0, succ(i), dirs)
end // end of [else]
//
end // end of [then]
else let
  val sbp =
  string_make_substring (s0, i0, i - i0)
  val dir = $UN.castvwtp0{Strptr1}(sbp) // this is a no-op cast
in
  dirs := list_vt_cons (dir, dirs)
end // end of [else]
//
) (* end of [loop1] and [loop2] *)
//
fun
dirs_process
(
  curdir: string, pardir: string
, npar: int, dirs: strptrlst, res: strptrlst
) : strptrlst = let
(*
// nothing
*)
in
  case+ dirs of
  | ~list_vt_nil
      () => let
      fun
      loop
      (
        pardir: string
      , npar: int, res: strptrlst
      ) : strptrlst =
        if npar > 0 then let
          val dir = string0_copy (pardir)
        in
          loop(pardir, npar - 1, list_vt_cons(dir, res))
        end else res // end of [if]
      // end of [loop]
    in
      loop(pardir, npar, res)
    end (* end of [list_vt_nil] *)
  | ~list_vt_cons
      (dir, dirs) => (
      if p2s(dir) = curdir then let
        val () = strptr_free(dir) in
        dirs_process(curdir, pardir, npar, dirs, res)
      end else if p2s(dir) = pardir then let
        val () = strptr_free(dir) in
        dirs_process(curdir, pardir, npar + 1, dirs, res)
      end else (
        if npar > 0 then let
          val () = strptr_free(dir)
        in
          dirs_process(curdir, pardir, npar - 1, dirs, res)
        end else begin
          dirs_process(curdir, pardir, 0, dirs, list_vt_cons(dir, res))
        end (* end of [if] *)
      ) // end of [if]
    ) (* end of [list_vt_cons] *)
end // end of [dirs_process]
//
val dirsep = theDirSep_get()
val curdir = theCurDir_get()
and pardir = theParDir_get()
//
var dirs
  : strptrlst = list_vt_nil()
//
val s0 = g1ofg0(s0)
//
val n0 = string_length(s0)
//
val () =
  loop1 (dirsep, s0, n0, i2sz(0), dirs)
//
val () =
dirs :=
dirs_process(curdir, pardir, 0, dirs, list_vt_nil)
//
val path = strptrlst_concat (dirs)
//
val ((*freed*)) = strptrlst_free (dirs)
//
in
  path(*strptr*)
end // end of [path_normalize_vt]

end // end of [local]

implement
path_normalize (s0) = let
  val str = path_normalize_vt (s0) // HX: the result is never freed
in
  res where {
    val res = the_garena_strdup ($UN.strptr2string(str))
    val ((*freed*)) = strptr_free (str)
  }
end // end of [path_normalize]

(* ****** ****** *)

local
//
fn
p2s
(
  x: !Strptr1
) :<> string = $UN.strptr2string(x)
//
in (* in of [local] *)

fun
partname_fullize
(
  pname: string
) : string = let
//
val isrel =
  givename_is_relative(pname)
//
in
//
if
isrel
then let
  val cwd = patsopt_getcwd_gc()
  val () = assertloc (strptr_isnot_null (cwd))
  val fname =
    filename_dirbase($UN.strptr2string(cwd), pname)
  // end of [val]
  val _freed_ = strptr_free(cwd)
  val fname_nf = path_normalize(p2s(fname))
  val _freed_ = strptr_free(fname)
in
  fname_nf
end // end of [then]
else pname // HX: [pname] is absolute
//
end // end of [partname_fullize]

end (* end of [local] *)

(* ****** ****** *)

local
//
assume
the_filenamelst_push_v = unit_v
//
// HX: the global state is kept in cells of the global arena
//
val the_filename =
  gcell_make<filename> (filename_dummy)
val the_filenamelst =
  gcell_make<glist(filename)> (glist_nil())
//
fn
the_filename_get(): filename =
  $UN.ptr0_get<filename> (the_filename)
fn
the_filename_set(x: filename): void =
  $UN.ptr0_set<filename> (the_filename, x)
fn
the_filenamelst_get(): glist(filename) =
  $UN.ptr0_get<glist(filename)> (the_filenamelst)
fn
the_filenamelst_set(xs: glist(filename)): void =
  $UN.ptr0_set<glist(filename)> (the_filenamelst, xs)
//
fun
filename_occurs
  (f0: filename): bool = let
//
fun
loop
(
  fs: glist(filename), f0: filename
) : bool = (
//
case+ glist_view(fs) of
| ~GLcons (f, fs) => let
    val eqfil =
      eq_filename_filename(f0, f)
    // end of [val]
  in
    if eqfil then true else loop (fs, f0)
  end // end of [GLcons]
//
| ~GLnil((*void*)) => false
//
) (* end of [loop] *)
//
in
  loop (the_filenamelst_get(), f0)
end // end of [filename_occurs]

in (* in of [local] *)
//
implement
filename_get_current((*void*)) = the_filename_get()
//
(* ****** ****** *)

implement
the_filenamelst_pop
(
  pf | (*none*)
) = let
//
prval unit_v() = pf
//
in
  the_filenamelst_ppop((*void*))
end // end of [the_filenamelst_pop]

implement
the_filenamelst_ppop
  ((*none*)) = let
//
val-
~GLcons(x0, xs) = glist_view (the_filenamelst_get())
val ((*void*)) = the_filenamelst_set (xs)
//
val () = the_filename_set (x0)
//
in
  // nothing
end // end of [the_filenamelst_ppop]

(* ****** ****** *)
//
implement
the_filenamelst_push(f0) = let
//
val () =
  the_filenamelst_ppush(f0) in (unit_v() | ())
//
end // end of [the_filenamelst_push]
//
implement
the_filenamelst_ppush(f0) = let
  val x0 = the_filename_get()
  val () = the_filename_set (f0)
  val () = the_filenamelst_set (glist_cons (x0, the_filenamelst_get()))
in
  // nothing
end // end of [the_filenamelst_ppush]
//
(* ****** ****** *)

implement
the_filenamelst_push_check
  (f0) = let
//
val (pf | ()) = the_filenamelst_push (f0)
//
val
isexi =
(
  if filename_isnot_dummy(f0) then filename_occurs(f0) else false
) : bool // end of [val]
//
in
  (pf | isexi)
end // end of [the_filenamelst_push_check]

(* ****** ****** *)

implement
fprint_the_filenamelst
  (out) = let
//
fun
loop (
  out: FILEref, fs: glist(filename)
) : void = (
//
case+ glist_view(fs) of
| ~GLcons (f, fs) => let
//
    val () =
    fprint_filename_full(out, f)
    val () = fprint_newline (out)
//
  in
    loop (out, fs)
  end // end of [GLcons]
//
| ~GLnil((*void*)) => ()
) (* end of[ loop] *)
//
in
  loop (out, the_filenamelst_get())
end // end of [fprint_the_filenamelst]

end // end of [local]

(* ****** ****** *)

local
//
assume
the_pathlst_push_v = unit_v
//
val the_pathlst = gcell_make<pathlst> (glist_nil())
val the_prepathlst = gcell_make<pathlst> (glist_nil())
//
in (* in of [local] *)

(* ****** ****** *)

fn
the_pathlst_get
  (): pathlst = $UN.ptr0_get<pathlst> (the_pathlst)

(* ****** ****** *)

implement
the_pathlst_pop
  (pf | (*none*)) =
{
//
prval unit_v() = pf
//
val-
~GLcons(_, xs) = glist_view (the_pathlst_get())
val ((*void*)) = $UN.ptr0_set<pathlst> (the_pathlst, xs)
//
} (* end of [the_pathlst_pop] *)

implement
the_pathlst_push(x0) = let
//
val () =
  the_pathlst_ppush(x0) in (unit_v() | ())
//
end // end of [the_pathlst_push]

implement
the_pathlst_ppush(x0) =
  $UN.ptr0_set<pathlst> (the_pathlst, glist_cons (x0, the_pathlst_get()))
// end of [the_pathlst_ppush]

(* ****** ****** *)

fn
the_prepathlst_get
(
  // argless
) : pathlst = $UN.ptr0_get<pathlst> (the_prepathlst)

(* ****** ****** *)

implement
the_prepathlst_push(x) =
  $UN.ptr0_set<pathlst>
    (the_prepathlst, glist_cons (x, the_prepathlst_get()))
// end of [the_prepathlst_push]

(* ****** ****** *)

end // end of [local]

(* ****** ****** *)

implement
filename_make
(
  given, pname, fname
) = let
//
val fname = $SYM.symbol_make_string (fname)
//
in
  filename_new (given, pname, fname)
end // end of [filename_make]

(* ****** ****** *)

local

(* ****** ****** *)

fn
p2s
(
  x: !Strptr1
) :<> String = $UN.strptr2string(x)

// HX: the result is kept forever (see [the_garena_strdup])
fn
strptr2stropt
  (x: Strptr1): Stropt = let
  val s = the_garena_strdup ($UN.strptr2string(x))
  val () = strptr_free (x)
in
  stropt_some (s)
end // end of [strptr2stropt]

(* ****** ****** *)

fun
aux_try
(
  paths: pathlst, given: string
) : Stropt = let
in
//
case+ glist_view(paths) of
| ~GLcons
  (
    path, paths
  ) => aux2_try(path, paths, given)
| ~GLnil((*void*)) => stropt_none()
//
end // end of [aux_try]

and
aux2_try
(
  path: path
, paths: pathlst, given: string
) : Stropt = let
//
  val
  partname =
  filename_dirbase(path, given)
//
  val isexi = test_file_exists(p2s(partname))
//
in
//
if
isexi
then
(
  strptr2stropt(partname)
) else let
  val () = strptr_free(partname) in aux_try(paths, given)
end // end of [if]
//
end // end of [aux2_try]

(* ****** ****** *)

fun
aux_local
(
  given: string
) : Stropt = let
  val fil = filename_get_current()
  val pname = filename_get_partname(fil)
  val pname2 =
    filename_merge(pname, given)
  val pname2_nf =
    path_normalize_vt(p2s(pname2))
  val ((*freed*)) = strptr_free(pname2)
  val isexi = test_file_exists(p2s(pname2_nf))
in
  if isexi then
    strptr2stropt(pname2_nf)
  else let
    val () = strptr_free(pname2_nf) in stropt_none()
  end // end of [if]
end // end of [aux_local]

(* ****** ****** *)

fun
aux_try_pathlst
(
  given: string
) : Stropt = ans where
{
//
val path = theCurDir_get()
val paths = the_pathlst_get()
//
val (ans) =
//
// HX:
// search the current directory first
//
(
aux2_try
( path
, paths, given
) (* aux2_try *)
)
// end of [val]
//
} (* end of [aux_try_pathlst] *)

fun
aux_try_prepathlst
(
  given: string
) : Stropt = ans where
{
//
val
paths = the_prepathlst_get()
//
val
(ans) =
aux_try
(paths, given)
// end of [val]
//
} (* end of [aux_try_prepathlst] *)

(* ****** ****** *)

fun
aux_tryloc
(
  paths: pathlst, given: string
) : Stropt = let
in
//
case+ glist_view(paths) of
| ~GLcons
  (
    path, paths
  ) => aux2_tryloc(path, paths, given)
| ~GLnil((*void*)) => stropt_none()
//
end // end of [aux_tryloc]

and
aux2_tryloc
(
  path: path
, paths: pathlst, given: string
) : Stropt = let
//
val
partname =
filename_dirbase(path, given)
//
val stropt = aux_local(p2s(partname))
//
val ((*freed*)) = strptr_free(partname)
//
in
//
if
(
stropt_is_some(stropt)
) then stropt(*path/given*) else aux_tryloc(paths, given)
// end of [if]
//
end // end of [aux2_tryloc]

(* ****** ****** *)

fun
aux_homelocs
(
  given: string
) : Stropt = let
//
fun
given_get_partname
(
  given
: string
) : string = let
//
#define NUL '\0'
//
val
sep = theDirSep_get()
//
fun
loop
(
  p: ptr, sep: char
) : string = let
//
val c = $UN.ptr0_get<char>(p)
//
in
//
// [given] should contain '/'!
//
if
(c = NUL)
then ""
else
(
if c != sep
  then loop(ptr_succ_char(p), sep)
  else $UN.cast{string}(ptr_succ_char(p))
// end of [if]
)
//
end // end of [loop]
//
in
  loop($UN.cast{ptr}(given), sep)
end // end of [given_get_partname]
//
val homelocs =
  the_PATSHOMELOCS_get_pathlst()
//
in
  aux_tryloc(homelocs, given_get_partname(given))
end // end of [aux_homelocs]

(* ****** ****** *)

fun
aux_relative
(
  given: string
) : Stropt = let
//
val
(knd) = givename_srchknd(given)
//
in
//
case+ knd of
//
| 0 (*local*) =>
  (
    //
    // given = "./<path>
    //
    aux_local(given)
  )
| 1 (* homelocs *) =>
  (
    //
    // given =
    // $PATSHOMELOCS/<path>
    //
    aux_homelocs(given)
  )
//
| _ (*external*) => let
    val
    opt = aux_try_pathlst(given)
  in
    if stropt_is_some(opt) then opt else aux_try_prepathlst(given)
  end // end of [_]
//
end // end of [aux_relative]

(* ****** ****** *)

in (* in of [local] *)

(* ****** ****** *)

implement
filenameopt_make_local
  (given) = let
//
val opt = aux_local(given)
val issome = stropt_is_some(opt)
//
in
//
if
issome
then let
  val partname = stropt_unsome(opt)
  val fullname = partname_fullize(partname)
in
  Some_vt(filename_make(given, partname, fullname))
end else None_vt() // end of [if]
//
end // end of [filenameopt_make_local]

(* ****** ****** *)

implement
filenameopt_make_relative
  (given, given2_ref) = let
//
val ngurl = givename_get_ngurl(given)
val given2 = pkgsrcname_relocatize(given, ngurl)
val ((*void*)) = (given2_ref := given2)
//
val opt =
(
case+ 0 of
| _ when
    givename_is_relative
    (
      given2
    ) => aux_relative(given2)
  // end of [_ when ...]
| _ (* given2 is absolute *) => let
    val
    isexi = test_file_exists(given2)
  in
    if isexi then stropt_some(given2) else stropt_none()
  end // end of [_]
) : Stropt // end of [val]
//
val issome = stropt_is_some(opt)
//
in
//
if
issome
then let
//
val partname = stropt_unsome(opt)
val fullname = partname_fullize(partname)
//
in
  Some_vt(filename_make(given, partname, fullname))
end // end of [then]
else None_vt() // end of [else]
//
end // end of [filenameopt_make_relative]

(* ****** ****** *)

end // end of [local]

(* ****** ****** *)

local
//
// HX: the result is kept forever
//
fn
my_make_substring_range
(
  src: string, beg: size_t, fin: size_t
) : string = let
  val
  len =
  (
    if fin >= beg then (fin - beg) else i2sz(0)
  ) : size_t // end of [val]
  val p = the_garena_alloc (len + i2sz(1))
  val () = $extfcall (void, "memcpy", p, ptr0_add_guint<char> ($UN.cast{ptr}(src), beg), len)
  val () = $UN.ptr0_set<char> (ptr0_add_guint<char> (p, len), '\000')
in
  $UN.cast{string}(p)
end // end of [my_make_substring_range]
//
(* ****** ****** *)
//
fun
pathlst_test
(
  xs: pathlst, x0: path
) : bool =
(
case+ glist_view(xs) of
| ~GLnil
    ((*void*)) => false
| ~GLcons
    (x_hd, xs_tl) =>
  if x0 = x_hd
    then true
    else pathlst_test(xs_tl, x0)
) (* end of [pathlst_test] *)
//
fn
pathlst_insert
(
  xs: pathlst,  x0: path
) : pathlst =
  if pathlst_test(xs, x0) then xs else glist_cons(x0, xs)
//
(* ****** ****** *)
//
val
the_PATSHOMELOCS =
  gcell_make<gopt(pathlst)> (gopt_none())
//
fun
the_PATSHOMELOCS_split
(
  paths: string
) : pathlst = let
//
#define NUL '\0'
#define COLON ':'
//
fun
loop2
(
  paths: string
, p: ptr
, i: size_t
, res: pathlst
) : pathlst = let
//
val c = $UN.ptr0_get<char>(p)
//
in
//
if
(c = NUL)
then res
else
(
if c = COLON
  then loop2(paths, ptr_succ_char(p), succ(i), res)
  else loop3(paths, ptr_succ_char(p), i, succ(i), res)
)
//
end (* end of [loop2] *)
//
and
loop3
(
  paths: string
, p: ptr
, i: size_t
, j: size_t
, res: pathlst
) : pathlst = let
//
val c = $UN.ptr0_get<char>(p)
//
in
//
if
(c = NUL)
then let
//
val path =
  my_make_substring_range(paths, i, j)
//
in
  pathlst_insert(res, path)
end // end of [then]
else
(
if
(c = COLON)
then let
//
val path =
  my_make_substring_range(paths, i, j)
//
in
//
loop2
(
paths, ptr_succ_char(p), succ(j), pathlst_insert(res, path)
)
//
end // end of [then]
else
(
  loop3(paths, ptr_succ_char(p), i, succ(j), res)
) (* end of [else] *)
) (* end of [else] *)
//
end (* end of [loop3] *)
//
in
//
glist_reverse
(
  loop2(paths, $UN.cast{ptr}(paths), i2sz(0), glist_nil())
) (* glist_reverse *)
//
end // end of [the_PATSHOMELOCS_split]
//
fun
the_PATSHOMELOCS_initize
  (): pathlst = let
//
val
paths = get() where
{
  extern
  fun
  get(
  // argless
  ) : Stropt =
    "ext#patsopt_PATSHOMELOCS_get"
} (* end of [val] *)
//
val issome = stropt_is_some(paths)
//
in
//
if
issome
then paths where
{
  val paths = stropt_unsome(paths)
  val paths = the_PATSHOMELOCS_split(paths)
  val ((*void*)) =
    $UN.ptr0_set<gopt(pathlst)> (the_PATSHOMELOCS, gopt_some(paths))
  // end of [val]
}
else paths where
{
  val paths = glist_nil()
  val ((*void*)) =
    $UN.ptr0_set<gopt(pathlst)> (the_PATSHOMELOCS, gopt_some(paths))
  // end of [val]
}
end // end of [ else]
//
in (* in-of-local *)

implement
the_PATSHOMELOCS_get_pathlst
  () = let
//
val
opt = $UN.ptr0_get<gopt(pathlst)> (the_PATSHOMELOCS)
//
in
//
case+ gopt_view(opt) of
| ~GOsome(paths) => paths
| ~GOnone((*void*)) => the_PATSHOMELOCS_initize()
//
end // end of [the_PATSHOMELOCS_get_pathlst]

end // end of [local]

(* ****** ****** *)

%{$

#include <unistd.h>

atstype_ptr
patsopt_getcwd_gc ()
{
  char *buf = (char*)ATS_MALLOC(4096) ;
  if (getcwd(buf, 4096) == NULL) { buf[0] = '\0' ; }
  return buf ;
} // end of [patsopt_getcwd_gc]

atstype_ptr
patsopt_filename_merge
(
  atstype_ptr ful, atstype_ptr bas
) {
  char c, dirsep ;
  char *p0, *p1, *p ;
  int n, n1, n2, found = 0 ;
  char *fulbas ;
  p0 = p = (char*)ful ;
  dirsep =
    patsopt_filename_theDirSep_get () ;
//
  while (1) {
    c = *p++ ;
    if (c == 0) break ;
    if (c == dirsep) { found = 1 ; p1 = p ; }
  }
//
  n1 = 0 ;
  if (found) n1 = (p1-p0) ;
  n2 = strlen ((char*)bas) ;
  n = n1 + n2 ;
  fulbas = ATS_MALLOC (n+1) ;
  memcpy (fulbas, ful, n1) ;
  memcpy (fulbas + n1, bas, n2) ;
  fulbas[n] = '\000' ;
//
  return fulbas ;
//
} // end of [patsopt_filename_merge]

atstype_ptr
patsopt_filename_dirbase
(
  atstype_ptr dir, atstype_ptr bas
) {
  int n1, n2, n ;
  char dirsep, *dirbas ;
//
  dirsep = patsopt_filename_theDirSep_get () ;
//
  n1 = strlen ((char*)dir) ;
  n2 = strlen ((char*)bas) ;
  n = n1 + n2 ;
//
  if (n1 > 0 && ((char*)dir)[n1-1] != dirsep) n += 1 ;
  dirbas = ATS_MALLOC (n + 1) ;
  memcpy (dirbas, dir, n1) ;
  if (n > n1 + n2) { dirbas[n1] = dirsep ; n1 += 1 ; }
  memcpy (dirbas + n1, bas, n2) ;
  dirbas[n] = '\000' ;
//
  return dirbas ;
} /* end of [patsopt_filename_dirbase] */

%} // end of [%{$]

(* ****** ****** *)

(* end of [pats_filename.dats] *)
