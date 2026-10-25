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
//
staload UN = "prelude/SATS/unsafe.sats"
//
staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"
//
(* ****** ****** *)
//
staload "./pats_utils.sats"
//
(* ****** ****** *)

%{^
//
static char *patsopt_PATSHOME = (char*)0 ;
static char *patsopt_PATSCONTRIB = (char*)0 ;
static char *patsopt_PATSHOMELOCS = (char*)0 ;
static char *patsopt_PATSRELOCROOT = (char*)0 ;
//
#define \
patsopt_getenv(name) getenv(name)
//
extern
atstype_ptr
patsopt_getenv_gc
  (atstype_ptr name);
//
ATSextern()
atstype_ptr
patsopt_PATSHOME_get()
{
  return patsopt_PATSHOME ; // optional string
} // end of [patsopt_PATSHOME_get]
ATSextern()
atstype_void
patsopt_PATSHOME_set()
{
//
  patsopt_PATSHOME = (char*)0;
//
  if
  (
   !patsopt_PATSHOME
  )
  {
    patsopt_PATSHOME = patsopt_getenv_gc("PATSHOME") ;
  }
//
  if
  (
   !patsopt_PATSHOME
  )
  {
    patsopt_PATSHOME = patsopt_getenv_gc("ATS2HOME") ;
  }
//
  return ;
//
} // end of [patsopt_PATSHOME_set]
//
ATSextern()
atstype_ptr
patsopt_PATSCONTRIB_get()
{
  return patsopt_PATSCONTRIB ; // optional string
} // end of [patsopt_PATSCONTRIB_get]
ATSextern()
atstype_void
patsopt_PATSCONTRIB_set()
{
//
  patsopt_PATSCONTRIB = patsopt_getenv_gc("PATSCONTRIB") ;
//
  if
  (
   !patsopt_PATSCONTRIB
  )
  {
    patsopt_PATSCONTRIB = patsopt_getenv_gc("ATSCONTRIB") ;
  }
//
  return ;
//
} // end of [patsopt_PATSCONTRIB_set]
//
ATSextern()
atstype_ptr
patsopt_PATSHOMELOCS_get()
{
  return patsopt_PATSHOMELOCS ; // optional string
} // end of [patsopt_PATSHOMELOCS_get]
ATSextern()
atstype_void
patsopt_PATSHOMELOCS_set()
{
//
  patsopt_PATSHOMELOCS = patsopt_getenv_gc("PATSHOMELOCS") ;
//
  if
  (
   !patsopt_PATSHOMELOCS
  )
  {
    patsopt_PATSHOMELOCS = patsopt_getenv_gc("ATSHOMELOCS") ;
  }
//
  return ;
} // end of [patsopt_PATSHOMELOCS_set]
//
ATSextern()
atstype_ptr
patsopt_PATSRELOCROOT_get()
{
  return patsopt_PATSRELOCROOT ; // optional string
} // end of [patsopt_PATSRELOCROOR_get]
ATSextern()
atstype_void
patsopt_PATSRELOCROOT_set()
{
//
  patsopt_PATSRELOCROOT = patsopt_getenv_gc("PATSRELOCROOT") ;
//
  if
  (
   !patsopt_PATSRELOCROOT
  )
  {
    patsopt_PATSRELOCROOT = patsopt_getenv_gc("ATSRELOCROOT") ;
  }
//
  return ;
//
} // end of [patsopt_PATSRELOCROOT_set]
//
%} (* end of [%{^] *)

(* ****** ****** *)

extern
fun
patsopt_getenv_gc
(
  name: string
) : Stropt = "ext#patsopt_getenv_gc"
//
implement
patsopt_getenv_gc
  (name) = let
//
val opt =
patsopt_getenv (name) where
{
extern
fun
patsopt_getenv
  (name: string): stropt = "mac#patsopt_getenv"
} (* end of [val] *)
//
in
//
if
stropt_is_some(opt)
then stropt_some(the_garena_strdup(stropt_unsome(opt)))
else stropt_none()
//
end // end of [patsopt_getenv_gc]

(* ****** ****** *)

implement
eqref_type
  {a} (x1, x2) = let
  extern castfn __cast (x: a):<> ptr
  val x1 = __cast (x1) and x2 = __cast (x2)
in
  (x1 = x2)
end // end of [eqref_type]

(* ****** ****** *)
//
// HX: case-insensitive string comparision
//
extern
fun strcasecmp (
  x1: string, x2: string
) :<> int
  = "ext#patsopt_strcasecmp"
//
implement
strcasecmp
  (x1, x2) = let
//
#define NUL '\000'
//
fun
loop
(
p1: ptr, p2: ptr
) : int = let
//
val c1 = toupper($UN.ptr0_get<char>(p1))
val c2 = toupper($UN.ptr0_get<char>(p2))
//
in
//
if
(c1 < c2)
then (~1)
else
(
if
(c1 > c2)
then ( 1 )
else
(
if c1 != NUL then loop(ptr0_succ<char>(p1), ptr0_succ<char>(p2)) else (0)
) (* end of [else] *)
) (* end of [else] *)
//
end // end of [loop]
//
in
//
$effmask_all
  (loop($UN.cast{ptr}(x1), $UN.cast{ptr}(x2)))
//
end // end of [strcasecmp]
//
(* ****** ****** *)
//
extern
fun
string_test_prefix
(
  str: string, prfx: string
) :<> bool
  = "ext#patsopt_string_test_prefix"
//
implement
string_test_prefix
  (str, prfx) = let
//
#define NUL '\000'
//
fun loop (
  p1: ptr, p2: ptr
) : bool = let
  val c1 = $UN.ptr0_get<char> (p1)
in
//
if c1 > NUL then let
  val c2 = $UN.ptr0_get<char> (p2)
in
  if c1 = c2 then loop (ptr0_succ<char>(p1), ptr0_succ<char>(p2)) else false
end else true // end of [if]
//
end // end of [loop]
//
in
  $effmask_all (loop ($UN.cast{ptr}(prfx), $UN.cast{ptr}(str)))
end // end of [patsopt_string_test_prefix]
//
(* ****** ****** *)
//
extern
fun
string_test_sffx
(
  str: string, sffx: string
) :<> bool
  = "ext#patsopt_string_test_suffix"
//
implement
string_test_sffx
  (str, sffx) = let
//
val n1 = string_length (str)
val n2 = string_length (sffx)
//
in
//
if
n1 >= n2
then let
  val p1 = $UN.cast{ptr}(str)
  val str2 = $UN.cast{string}(ptr0_add_guint<char>(p1, n1 - n2))
in
  str2 = sffx
end // end of [then]
else false // end of [else]
//
end // end of [string_test_sffx]
//
(* ****** ****** *)

local

(* ****** ****** *)

staload
STDLIB = "libats/libc/SATS/stdlib.sats"

(* ****** ****** *)

extern
fun
strtoll_c
  (nptr: string, endptr: ptr, base: int): llint = "mac#strtoll"

fun
llint_make_string_sgn
  {n,i:nat | i <= n}
(
  sgn: int, rep: string (n), i: size_t i
) : llint = let
in
//
if
string_isnot_atend (rep, i)
then let
  val c0 = rep[i]
in
  case+ c0 of
  | '0' => (
      if string_isnot_atend (rep, i+1) then let
        val i = i+1
        val c0 = rep[i]
      in
        if (c0 != 'x' && c0 != 'X') then
          llint_make_string_sgn_base (sgn, 8(*base*), rep, i)
        else
          llint_make_string_sgn_base (sgn, 16(*base*), rep, i+1)
        // end of [if]
      end else 0ll (* end of [if] *)
    ) // end of ['0']
  | _ (*non-0*) =>
      llint_make_string_sgn_base (sgn, 10(*base*), rep, i)
end // end of [then]
else 0ll // end of [else]
//
end // end of [llint_make_string_sgn]

and
llint_make_string_sgn_base
  {n,i:nat | i <= n}
(
  sgn: int, base: intBtw (2,36+1), rep: string (n), i: size_t i
) : llint = let
//
fun substring
  {n,i:nat | i <= n}
  (x: string n, i: size_t i): string (n-i) =
  $effmask_all ($UN.cast{string(n-i)}(ptr0_add_guint<char>($UN.cast{ptr}(x), i)))
//
in
  g0int2int_int_llint(sgn) * strtoll_c (substring (rep, i), the_null_ptr, base)
end // end of [llint_make_string_sgn_base]

in (* in of [local] *)

implement
llint_make_string
  (rep) = let
//
var sgn: int = 1
val [n0:int] rep = g1ofg0 (rep)
val isnot = string_isnot_empty (rep)
//
in
//
if isnot then let
  val c0 = rep[0] in
//
case+ c0 of
| '+' => llint_make_string_sgn ( 1(*sgn*), rep, i2sz(1))
| '-' => llint_make_string_sgn (~1(*sgn*), rep, i2sz(1))
| '~' => llint_make_string_sgn (~1(*sgn*), rep, i2sz(1)) // HX: should it be supported?
| _ (*rest*) => llint_make_string_sgn (1(*sgn*), rep, i2sz(0))
//
end else 0ll // end of [if]
//
end // end of [llint_make_string]

implement
double_make_string (rep) = $STDLIB.atof (rep)

end // end of [local]

(* ****** ****** *)

implement
intrep_get_base (rep) = let
  val rep = g1ofg0 (rep)
  val isnot = string_isnot_atend (rep, 0)
in
//
if isnot then let
  val c0 = rep[0]
in
//
if c0 = '0' then let
  val isnot = string_isnot_atend (rep, i2sz(1))
in
  if isnot then let
    val c1 = rep[1]
    val isxX = (if c1 = 'x' then true else c1 = 'X'): bool
  in
    if isxX
      then 16
      else (
        if isdigit (c1) then 8 else 10
      )
    // end of [if]
  end
    else 10
  // end of [if]
end else 10 // end of [if]
//
end else 10 // end of [if]
//
end // end of [intrep_get_base]

fun
string_contains_char
  (str: string, c: char): bool = let
  fun loop (p: ptr, c: char): bool = let
    val c1 = $UN.ptr0_get<char> (p)
  in
    if c1 = '\000' then false else (if c1 = c then true else loop (ptr0_succ<char>(p), c))
  end // end of [loop]
in
  $effmask_all (loop ($UN.cast{ptr}(str), c))
end // end of [string_contains_char]

implement
intrep_get_nsfx (rep) = let
//
macdef
test (c) = string_contains_char ("ulUL", ,(c))
//
val [n:int] rep = g1ofg0 (rep)
//
fun loop
  {i:nat | i <= n} .<i>. (
  rep: string n, i: size_t i, k: uint
) : uint = let
in
  if i > 0 then let
    val i1 = i - 1
    val c = rep[i1]
  in
    if test (c) then loop (rep, i1, k+1u) else k
  end else k
end // end of [loop]
//
val n = string_length (rep)
//
in
  loop (rep, n, 0u)
end // end of [intrep_get_nsfx]

(* ****** ****** *)

implement
float_get_nsfx (rep) = let
//
macdef
test (c) = string_contains_char ("fFlL", ,(c))
//
val [n:int] rep = g1ofg0 (rep)
//
fun loop
  {i:nat | i <= n} .<i>.
(
  rep: string n, i: size_t i, k: uint
) : uint = let
in
  if i > 0 then let
    val i1 = i - 1
    val c = rep[i1]
  in
    if test (c) then loop (rep, i1, k+1u) else k
  end else k
end // end of [loop]
//
val n = string_length (rep)
//
in
  loop (rep, n, 0u)
end // end of [float_get_nsfx]

(* ****** ****** *)

local
//
assume
lstord_type (a:t@ype) = glist(a)
//
in (* in of [local] *)

implement{a}
lstord_nil () = glist_nil ()

implement{a}
lstord_sing (x) = glist_sing (x)

implement{a}
lstord_insert
  (xs, x0, cmp) = let
  fun aux
    (xs: glist(a), x0: a, cmp: (a, a) -> int): glist(a) =
    case+ glist_view(xs) of
    | ~GLcons (x, xs1) =>
        if cmp (x0, x) <= 0 then
          glist_cons (x0, xs) else glist_cons (x, aux (xs1, x0, cmp))
        // end of [if]
    | ~GLnil () => glist_sing (x0)
  // end of [aux]
in
  aux (xs, x0, cmp)
end // end of [lstord_insert]

implement{a}
lstord_union
  (xs1, xs2, cmp) = let
//
fun
aux
(
  xs1: glist(a), xs2: glist(a), cmp: (a, a) -> int
) : glist(a) =
(
  case+ glist_view(xs1) of
  | ~GLnil () => xs2
  | ~GLcons (x1, xs11) => (
    case+ glist_view(xs2) of
    | ~GLnil () => xs1
    | ~GLcons (x2, xs21) =>
        if cmp (x1, x2) <= 0 then
          glist_cons (x1, aux (xs11, xs2, cmp))
        else
          glist_cons (x2, aux (xs1, xs21, cmp))
        // end of [if]
    ) // end of [GLcons]
) (* end of [aux] *)
//
in
  aux (xs1, xs2, cmp)
end // end of [lstord_union]

implement{a}
lstord_get_dups
  (xs, cmp) = let
//
fun aux (
  x0: a, xs: glist(a), cnt: int, cmp: (a, a) -> int
) : glist(a) =
  case+ glist_view(xs) of
  | ~GLcons (x, xs) =>
      if cmp (x, x0) = 0 then
        aux (x0, xs, cnt+1, cmp)
      else ( // HX: x0 < x holds
        if cnt > 0 then
          glist_cons (x0, aux (x, xs, 0, cmp)) else aux (x, xs, 0, cmp)
        // end of [if]
      ) // end of [if]
  | ~GLnil () =>
      if cnt > 0 then glist_sing (x0) else glist_nil ()
    // end of [GLnil]
(* end of [aux] *)
//
in
//
case+ glist_view(xs) of
| ~GLnil () => glist_nil ()
| ~GLcons (x, xs) => aux (x, xs, 0, cmp)
//
end // end of [lstord_get_dups]

implement{a} lstord2list (xs) = xs

end // end of [local]

(* ****** ****** *)

implement
dirpath_append
  (dir, path, sep) = let
//
val p0 = $UN.cast2ptr (path)
val c0 = $UN.ptr0_get<char> (p0)
//
in
  if c0 = sep
    then string0_append (dir, path)
    else let
      val sep1 = string_sing ($UN.cast{charNZ}(sep))
      val res =
        string0_append3 (dir, $UN.castvwtp1{string}(sep1), path)
      val ((*freed*)) = strnptr_free (sep1)
    in
      res
    end // end of [else]
  // end of [if]
end // end of [dirpath_append]

(* ****** ****** *)
//
implement
print_stropt
 (opt) =
 fprint_stropt(stdout_ref, opt)
implement
prerr_stropt
 (opt) =
 fprint_stropt(stderr_ref, opt)
//
implement
fprint_stropt
 (out, opt) = let
in
//
if
stropt_is_some(opt)
then
  fprint_string(out, stropt_unsome(opt))
else
  fprint_string(out, "(none)")
// end of [if]
//
end (* end of [fprint_stropt] *)
//
(* ****** ****** *)

implement
{a}(*tmp*)
fprintlst (
  out, xs, sep, fprint
) = let
//
fun
aux (
  out: FILEref, xs: glist(a), i: int
, sep: string, fprint: (FILEref, a) -> void
) : void =
(
  case+ glist_view(xs) of
  | ~GLnil () => ()
  | ~GLcons (x, xs) => let
      val () =
      if i > 0 then
        fprint_string (out, sep)
      // end of [val]
    in
       fprint (out, x); aux (out, xs, i+1, sep, fprint)
    end // end of [list_cons]
) (* end of [aux] *)
//
in
  aux (out, xs, 0, sep, fprint)
end // end of [fprintlst]

(* ****** ****** *)

implement
{a}(*tmp*)
fprintopt
(
  out, opt, fprint
) = (
  case+ gopt_view(opt) of
  | ~GOnone () =>
      fprint_string (out, "None()")
  | ~GOsome (x) => let
      val () =
        fprint_string (out, "Some(")
      val () = fprint (out, x)
      val () = fprint_string (out, ")")
    in
      // nothing
    end // end of [Some]
) (* end of [fprintopt] *)

(* ****** ****** *)

local
//
// HX: a charset is a list of chars in DESCENDING order (and duplicate-free), like [funset_listord] of ATS1:
// [charset_listize] (and [fprint_charset]) give the largest char first
//
assume charset_type = glist(char)
//
in (*in-of-local*)

implement
charset_sing (x) = glist_sing (x)

implement
charset_is_member
  (xs, x) = (
//
case+ glist_view(xs) of
| ~GLnil () => false
| ~GLcons (x1, xs1) => (
    if x1 > x
      then charset_is_member (xs1, x) else (x1 = x)
    // end of [if]
  ) (* end of [GLcons] *)
//
) (* end of [charset_is_member] *)

implement
charset_add
  (xs, x) = (
//
case+ glist_view(xs) of
| ~GLnil () => glist_sing (x)
| ~GLcons (x1, xs1) => (
    if x1 > x
      then glist_cons (x1, charset_add (xs1, x))
      else (if x1 = x then xs else glist_cons (x, xs))
    // end of [if]
  ) (* end of [GLcons] *)
//
) (* end of [charset_add] *)

implement
charset_listize (xs) = glist_listize (xs)

end // end of [local]

implement
fprint_charset
  (out, xs) = let
//
val xs = charset_listize (xs)
//
fun loop
(
  out: FILEref, xs: charlst_vt, i: int
) : void = (
//
case+ xs of
| ~list_vt_nil () => ()
| ~list_vt_cons (x, xs) => let
    val () =
      if i > 0 then fprint (out, ", ")
    // end of [val]
  in
    fprint_char (out, x); loop (out, xs, i+1)
  end // end of [list_vt_cons]
//
) (* end of [loop] *)
//
in
  loop (out, xs, 0)
end // end of [fprint_charset]

(* ****** ****** *)

%{$
//
#include <unistd.h>
//
// HX: replaces atslib_fildes_read_all_err of ATS1
// (reads exactly ntot bytes; returns 0 or -1)
//
static
int
patsopt_fildes_read_all_err
(
  int fd, void *buf, size_t ntot
) {
  char *p = (char*)buf ;
  while (ntot > 0) {
    ssize_t n = read(fd, p, ntot) ;
    if (n <= 0) return -1 ;
    p += n ; ntot -= n ;
  }
  return 0 ;
}
//
atstype_ptr
patsopt_file2strptr
(
  atstype_int fd
) {
  int err = 0 ;
  int nerr = 0 ;
  char* sbp = (char*)0 ;
//
  long int ofs_beg, ofs_end, nbyte ;
//
  ofs_beg = lseek (fd, 0L, SEEK_CUR) ;
  if (ofs_beg < 0) nerr += 1 ;
  ofs_end = lseek (fd, 0L, SEEK_END) ;
  if (ofs_end < 0) nerr += 1 ;
  ofs_beg = lseek (fd, ofs_beg, SEEK_SET) ;
  if (ofs_beg < 0) nerr += 1 ;
  nbyte = ofs_end - ofs_beg ;
//
  if (nerr == 0) { sbp = ATS_MALLOC(nbyte + 1) ; }
  if (sbp == NULL) nerr += 1 ;
//
  if (nerr == 0) {
    err = patsopt_fildes_read_all_err (fd, sbp, nbyte) ;
  }
  if (err < 0) { nerr += 1 ; }
//
  if (nerr==0) {
    sbp[ofs_end] = '\0'; return sbp ;
  }
//
  if (sbp) free(sbp) ; return (NULL) ;
} // end of [patsopt_file2strptr]
//
%} // end of [%{$]

(* ****** ****** *)

local
//
// HX-2015-10-07:
// It can be interesting to implement
// tostrong_fprint based on open_memstream
//
// HX: this port uses [tmpfile] (the [prfx] is not used)
//
extern
fun
patsopt_tmpfile(): ptr = "mac#tmpfile"
extern
fun
patsopt_fileno(out: ptr): int = "mac#fileno"
extern
fun
patsopt_rewind(out: ptr): void = "mac#rewind"
extern
fun
patsopt_fflush(out: ptr): int = "mac#fflush"
extern
fun
patsopt_fclose(out: ptr): int = "mac#fclose"
//
in (* in of [local] *)

implement{a}
tostring_fprint
  (prfx, fpr, x) = let
//
val out = patsopt_tmpfile ()
//
in
//
if
$UN.cast{lint}(out) != 0L
then let
//
  val () = fpr($UN.castvwtp0{FILEref}(out), x)
  val err = patsopt_fflush(out)
  val () = patsopt_rewind(out)
  val [fd:int] fd = g1ofg0 (patsopt_fileno(out))
//
  prval pffil = $UN.castview0{fildes_v(fd)}(0)
  val res = file2strptr(pffil | fd)
  prval ((*void*)) = $UN.castview0{void}(pffil)
//
  val err = patsopt_fclose(out)
in
  res (*strptr*)
end // end of [then]
else strptr_null((*void*))
//
end // end of [tostring_fprint]

end // end of [local]

(* ****** ****** *)
//
// HX-2015-01-27:
// for stopping optimization
//
implement ptr_as_volatile(ptr) = ((*dummy*))
//
(* ****** ****** *)

(* end of [pats_utils.dats] *)
