(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)

(* ***************************************************************** *)
(*                                                                   *)
(*                          ATS/libats/arena                         *)
(*                                                                   *)
(* ***************************************************************** *)

(*
** Copyright (C) 2026 Mikhail Sorochan
**
** Permission is hereby granted, free of charge, to any person obtaining a
** copy of this software and associated documentation files (the "Software"),
** to deal in the Software without restriction, including without limitation
** the rights to use, copy, modify, merge, publish, distribute, sublicense,
** and/or sell copies of the Software, and to permit persons to whom the
** Software is furnished to do so, subject to the following stated conditions:
**
** The above copyright notice and this permission notice shall be included in
** all copies or substantial portions of the Software.
**
** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
** OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
** FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
** THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
** LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
** FROM OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
** IN THE SOFTWARE.
*)

(* ****** ****** *)

(*
**
** HX-2026-10: no GC
**
** Arenas (or regions): memory that is allocated
** piecewise and released all at once. They are meant
** for data that is shared (and thus cannot be linear)
** but whose lifetime is well-delimited (e.g., the
** syntax trees built by a compiler-like tool).
**
** An arena is a linear value of type [arena(l)].
** The values stored in it are referred to through
** nonlinear handles indexed by [l] (aref, astring and
** alist); every access to such a handle requires the
** arena to be borrowed (!arena(l)). Hence, no handle
** can be used after the arena is freed.
**
*)

(* ****** ****** *)

#define
ATS_PACKNAME "ATSLIB.libats.arena"
#define
ATS_EXTERN_PREFIX "atslib_" // prefix for external names

(* ****** ****** *)
//
%{#
#include "libats/CATS/arena.cats"
%}
//
(* ****** ****** *)
//
absvtype
arena_vtype(l:addr) = ptr
//
vtypedef
arena(l:addr) = arena_vtype(l)
vtypedef Arena = [l:agz] arena(l)
//
(* ****** ****** *)
//
fun
arena_make_nil
  ((*void*)): Arena = "mac#%"
fun
arena_make_size
  (chunksz: sizeGte(1)): Arena = "mac#%"
//
// HX: releasing all the memory of the arena
//
fun
arena_free{l:addr}(ar: arena(l)): void = "mac#%"
//
// HX: the number of bytes allocated in the arena
//
fun
arena_get_ntotal{l:addr}(ar: !arena(l)): size_t = "mac#%"
//
(* ****** ****** *)
//
// HX:
// raw allocation (zero-filled); this is unsafe in
// the sense that the returned pointer is not tied to
// the arena in any way (it is used for implementing
// the safe interface below)
//
fun
arena_alloc{l:addr}
  (ar: !arena(l), bsz: size_t): Ptr1 = "mac#%"
//
// HX-2026-10:
// Aliasing-safe access (by memcpy) to arena memory:
// a flat value of type [a] is stored at [p]. (Accessing
// memory directly through the C types of different template
// instances of a flat type is undefined under strict aliasing.)
//
fun{a:t@ype}
arena_load(p: ptr): (a)
fun{a:t@ype}
arena_store(p: ptr, x: a): void
//
(* ****** ****** *)
//
// HX: a reference to a (flat) value in the arena
//
abstype
aref_type(l:addr, a:t@ype) = ptr
typedef
aref(l:addr, a:t@ype) = aref_type(l, a)
//
fun{a:t@ype}
aref_make{l:addr}
  (ar: !arena(l), x: a): aref(l, a)
//
fun{a:t@ype}
aref_get{l:addr}
  (ar: !arena(l), r: aref(l, a)): (a)
fun{a:t@ype}
aref_set{l:addr}
  (ar: !arena(l), r: aref(l, a), x: a): void
//
castfn
aref2ptr
  {l:addr}{a:t@ype}(r: aref(l, a)):<> Ptr1
//
(* ****** ****** *)
//
// HX: a string copied into the arena
//
abstype
astring_type(l:addr) = ptr
typedef
astring(l:addr) = astring_type(l)
//
fun{}
astring_make{l:addr}
  (ar: !arena(l), str: NSH(string)): astring(l)
//
fun{}
astring_length{l:addr}
  (ar: !arena(l), str: astring(l)): size_t
//
fun{}
astring_fprint{l:addr}
  (ar: !arena(l), out: FILEref, str: astring(l)): void
//
fun{}
astring_eq_string{l:addr}
  (ar: !arena(l), str1: astring(l), str2: NSH(string)): bool
fun{}
astring_compare{l:addr}
  (ar: !arena(l), str1: astring(l), str2: astring(l)): int
//
fun{}
astring_hash{l:addr}
  (ar: !arena(l), str: astring(l)): ulint
//
// HX: a (linear) copy that may outlive the arena
//
fun{}
astring_copy{l:addr}
  (ar: !arena(l), str: astring(l)): Strptr1
//
(* ****** ****** *)
//
// HX: (immutable) lists in the arena
//
abstype
alist_type(l:addr, a:t@ype) = ptr
typedef
alist(l:addr, a:t@ype) = alist_type(l, a)
//
fun{}
alist_nil
  {l:addr}{a:t@ype}((*void*)): alist(l, a)
fun{a:t@ype}
alist_cons{l:addr}
  (ar: !arena(l), x: a, xs: alist(l, a)): alist(l, a)
//
fun{}
alist_is_nil
  {l:addr}{a:t@ype}(xs: alist(l, a)): bool
fun{}
alist_is_cons
  {l:addr}{a:t@ype}(xs: alist(l, a)): bool
//
fun{a:t@ype}
alist_uncons{l:addr}
  (ar: !arena(l), xs: alist(l, a)): Option_vt(@(a, alist(l, a)))
//
// HX: [xs] must be non-empty (checked at run-time)
//
fun{a:t@ype}
alist_head{l:addr}(ar: !arena(l), xs: alist(l, a)): (a)
fun{a:t@ype}
alist_tail{l:addr}(ar: !arena(l), xs: alist(l, a)): alist(l, a)
//
fun{a:t@ype}
alist_sing{l:addr}(ar: !arena(l), x: a): alist(l, a)
//
// HX: [xs] is copied while [ys] is shared
//
fun{a:t@ype}
alist_append{l:addr}
  (ar: !arena(l), xs: alist(l, a), ys: alist(l, a)): alist(l, a)
//
fun{a:t@ype}
alist_length{l:addr}
  (ar: !arena(l), xs: alist(l, a)): intGte(0)
//
fun{a:t@ype}
alist_reverse{l:addr}
  (ar: !arena(l), xs: alist(l, a)): alist(l, a)
//
// HX: the given linear list is consumed
//
fun{a:t@ype}
alist_make_list_vt{l:addr}
  (ar: !arena(l), xs: List0_vt(a)): alist(l, a)
//
// HX: a linear copy of the given list
//
fun{a:t@ype}
alist_listize{l:addr}
  (ar: !arena(l), xs: alist(l, a)): List0_vt(a)
//
(* ****** ****** *)
//
// HX: hashtables (mapping keys to items) in the arena;
// an insertion shadows a previous entry of the same key
//
abstype
ahashtbl_type(l:addr, k:t@ype, i:t@ype) = ptr
typedef
ahashtbl(l:addr, k:t@ype, i:t@ype) = ahashtbl_type(l, k, i)
//
fun{k:t@ype}
ahashtbl$hash(key: k): ulint
fun{k:t@ype}
ahashtbl$equal(k1: k, k2: k): bool
//
fun{
k,i:t@ype
} ahashtbl_make_nil{l:addr}
  (ar: !arena(l), cap: sizeGte(1)): ahashtbl(l, k, i)
//
fun{
k,i:t@ype
} ahashtbl_get_size{l:addr}
  (ar: !arena(l), tbl: ahashtbl(l, k, i)): size_t
//
fun{
k,i:t@ype
} ahashtbl_search{l:addr}
  (ar: !arena(l), tbl: ahashtbl(l, k, i), key: k): Option_vt(i)
//
fun{
k,i:t@ype
} ahashtbl_insert{l:addr}
  (ar: !arena(l), tbl: ahashtbl(l, k, i), key: k, itm: i): void
//
// HX: a linear list of all the entries (in no particular order)
//
fun{
k,i:t@ype
} ahashtbl_listize{l:addr}
  (ar: !arena(l), tbl: ahashtbl(l, k, i)): List0_vt(@(k, i))
//
(* ****** ****** *)
//
// HX-2026-10:
// The global arena: what is allocated in it lives
// until the program exits (the arena is never freed).
// It suits compiler-like tools whose syntax trees are
// needed till the end. As there can be no use-after-free,
// the handles below need no arena to be borrowed.
//
(* ****** ****** *)
//
fun
the_garena_alloc
  (bsz: size_t): Ptr1 = "mac#atslib_the_garena_alloc"
//
// HX: a copy (in the global arena) that is never freed
//
fun
the_garena_strdup
  (str: NSH(string)): string = "mac#atslib_the_garena_strdup"
//
(* ****** ****** *)
//
// HX: (immutable) lists in the global arena
//
abstype
glist_type(a:t@ype) = ptr
typedef
glist(a:t@ype) = glist_type(a)
//
datavtype
glist_view(a:t@ype) =
  | GLnil of () | GLcons of (a, glist(a))
//
fun{}
glist_nil{a:t@ype}((*void*)): glist(a)
fun{a:t@ype}
glist_cons(x: a, xs: glist(a)): glist(a)
fun{a:t@ype}
glist_sing(x: a): glist(a)
//
fun{}
glist_is_nil{a:t@ype}(xs: glist(a)): bool
fun{}
glist_is_cons{a:t@ype}(xs: glist(a)): bool
//
// HX: for pattern matching
//
fun{a:t@ype}
glist_view(xs: glist(a)): glist_view(a)
//
// HX: [xs] must be non-empty (checked at run-time)
//
fun{a:t@ype}
glist_head(xs: glist(a)): (a)
fun{a:t@ype}
glist_tail(xs: glist(a)): glist(a)
//
fun{a:t@ype}
glist_length(xs: glist(a)): intGte(0)
//
fun{a:t@ype}
glist_reverse(xs: glist(a)): glist(a)
fun{a:t@ype}
glist_append(xs: glist(a), ys: glist(a)): glist(a)
//
// HX: the given linear list is consumed
//
fun{a:t@ype}
glist_make_list_vt(xs: List0_vt(a)): glist(a)
//
// HX: a linear copy of the given list
//
fun{a:t@ype}
glist_listize(xs: glist(a)): List0_vt(a)
//
// HX: printing (by fprint_val<a>) with a separator
//
fun{a:t@ype}
fprint_glist_sep
  (out: FILEref, xs: glist(a), sep: NSH(string)): void
//
(* ****** ****** *)
//
// HX: (immutable) options in the global arena
//
abstype
gopt_type(a:t@ype) = ptr
typedef
gopt(a:t@ype) = gopt_type(a)
//
datavtype
gopt_view(a:t@ype) =
  | GOnone of () | GOsome of (a)
//
fun{}
gopt_none{a:t@ype}((*void*)): gopt(a)
fun{a:t@ype}
gopt_some(x: a): gopt(a)
//
fun{}
gopt_is_none{a:t@ype}(opt: gopt(a)): bool
fun{}
gopt_is_some{a:t@ype}(opt: gopt(a)): bool
//
// HX: for pattern matching
//
fun{a:t@ype}
gopt_view(opt: gopt(a)): gopt_view(a)
//
// HX: [opt] must be some (checked at run-time)
//
fun{a:t@ype}
gopt_unsome(opt: gopt(a)): (a)
//
fun{a:t@ype}
gopt_make_option_vt(opt: Option_vt(a)): gopt(a)
//
(* ****** ****** *)

(* end of [arena.sats] *)
