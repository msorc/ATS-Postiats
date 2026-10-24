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
//
// HX-2026-10: arenas (no GC)
//
(* ****** ****** *)

#define
ATS_PACKNAME "ATSLIB.libats.arena"
#define
ATS_EXTERN_PREFIX "atslib_" // prefix for external names

(* ****** ****** *)

staload
UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/arena.sats"
//
// HX-2026-10: for the instances of the templates below
// (so that they need nothing else to be loaded)
//
staload _(*UN*) = "prelude/DATS/unsafe.dats"
staload _(*PTR*) = "prelude/DATS/pointer.dats"

(* ****** ****** *)

//
// HX-2026-10:
// all the accesses to arena memory go through
// [arena_load] and [arena_store] (see arena.sats)
//
implement
{a}(*tmp*)
arena_load
  (p) = x where
{
  var x: a?
  val _ =
  $extfcall
    (ptr, "memcpy", addr@x, p, sizeof<a>)
  val x = $UN.ptr0_get<a>(addr@x)
} (* end of [arena_load] *)
//
implement
{a}(*tmp*)
arena_store
  (p, x) = let
  var x = x
  val _ =
  $extfcall
    (ptr, "memcpy", p, addr@x, sizeof<a>)
in
  // nothing
end // end of [arena_store]
//
(* ****** ****** *)
//
// HX:
// a list cell: [tail: ptr][head: a]
//
macdef
CELL_HD(p) = ptr_add<byte>(,(p), sizeof<ptr>)
//
(* ****** ****** *)

implement
{a}(*tmp*)
aref_make
  {l}(ar, x) = let
  val p = arena_alloc(ar, sizeof<a>)
  val () = arena_store<a>(p, x)
in
  $UN.cast{aref(l, a)}(p)
end // end of [aref_make]

implement
{a}(*tmp*)
aref_get(ar, r) = arena_load<a>($UN.cast{ptr}(r))
implement
{a}(*tmp*)
aref_set(ar, r, x) = arena_store<a>($UN.cast{ptr}(r), x)

(* ****** ****** *)

implement
{}(*tmp*)
astring_make
  (ar, str) =
  $UN.cast(
    $extfcall(ptr, "atslib_arena_strdup", $UN.castvwtp1{ptr}(ar), str)
  ) (* $UN.cast *)
//
implement
{}(*tmp*)
astring_length
  (ar, str) = string_length($UN.cast{string}(str))
//
implement
{}(*tmp*)
astring_fprint
  (ar, out, str) = fprint_string(out, $UN.cast{string}(str))
//
implement
{}(*tmp*)
astring_eq_string
  (ar, str1, str2) = ($UN.cast{string}(str1) = str2)
//
implement
{}(*tmp*)
astring_compare
  (ar, str1, str2) =
  compare($UN.cast{string}(str1), $UN.cast{string}(str2))
//
implement
{}(*tmp*)
astring_hash
  (ar, str) = let
  fun loop
  (
    p: ptr, h: ulint
  ) : ulint = let
    val c = $UN.cast{int}($UN.ptr0_get<uchar>(p))
  in
    if c != 0
      then loop(ptr_succ<uchar>(p), h * 31UL + $UN.cast{ulint}(c))
      else h
    // end of [if]
  end // end of [loop]
in
  loop($UN.cast{ptr}(str), 5381UL)
end // end of [astring_hash]
//
implement
{}(*tmp*)
astring_copy
  (ar, str) = string0_copy($UN.cast{string}(str))
//
(* ****** ****** *)
//
// HX: the cells of alists and glists
//
extern
fun{a:t@ype}
acell_make(p: ptr, x: a, xs: ptr): void
extern
fun{a:t@ype}
acell_head(p: ptr): (a)
extern
fun{}
acell_tail(p: ptr): ptr
//
implement
{a}(*tmp*)
acell_make
  (p, x, xs) =
(
  arena_store<ptr>(p, xs); arena_store<a>(CELL_HD(p), x)
) (* end of [acell_make] *)
//
implement
{a}(*tmp*)
acell_head(p) = arena_load<a>(CELL_HD(p))
implement
{}(*tmp*)
acell_tail(p) = arena_load<ptr>(p)
//
(* ****** ****** *)
//
implement
{}(*tmp*)
alist_nil() = $UN.cast(the_null_ptr)
//
implement
{a}(*tmp*)
alist_cons
  (ar, x, xs) = let
  val p =
    arena_alloc(ar, sizeof<ptr> + sizeof<a>)
  val () = acell_make<a>(p, x, $UN.cast{ptr}(xs))
in
  $UN.cast(p)
end // end of [alist_cons]
//
implement
{}(*tmp*)
alist_is_nil(xs) = ($UN.cast{ptr}(xs) = the_null_ptr)
implement
{}(*tmp*)
alist_is_cons(xs) = ($UN.cast{ptr}(xs) > the_null_ptr)
//
implement
{a}(*tmp*)
alist_uncons
  {l}(ar, xs) = let
  val p = $UN.cast{ptr}(xs)
in
  if
  (p > the_null_ptr)
  then
  Some_vt(@(acell_head<a>(p), $UN.cast{alist(l, a)}(acell_tail(p))))
  else None_vt((*void*))
end // end of [alist_uncons]
//
implement
{a}(*tmp*)
alist_head
  (ar, xs) = let
  val p = $UN.cast{ptr}(xs)
  val () = assertloc(p > the_null_ptr)
in
  acell_head<a>(p)
end // end of [alist_head]
//
implement
{a}(*tmp*)
alist_tail
  {l}(ar, xs) = let
  val p = $UN.cast{ptr}(xs)
  val () = assertloc(p > the_null_ptr)
in
  $UN.cast{alist(l, a)}(acell_tail(p))
end // end of [alist_tail]
//
implement
{a}(*tmp*)
alist_sing
  (ar, x) = alist_cons<a>(ar, x, alist_nil())
//
implement
{a}(*tmp*)
alist_length
  (ar, xs) = let
  fun loop
  (
    p: ptr, n: intGte(0)
  ) : intGte(0) =
    if p > the_null_ptr
      then loop(acell_tail(p), n+1) else n
    // end of [if]
in
  loop($UN.cast{ptr}(xs), 0)
end // end of [alist_length]
//
implement
{a}(*tmp*)
alist_reverse
  {l}(ar, xs) = let
  fun loop
  (
    ar: !arena(l), p: ptr, res: alist(l, a)
  ) : alist(l, a) =
    if p > the_null_ptr
      then loop(ar, acell_tail(p), alist_cons<a>(ar, acell_head<a>(p), res))
      else res
    // end of [if]
in
  loop(ar, $UN.cast{ptr}(xs), alist_nil())
end // end of [alist_reverse]
//
implement
{a}(*tmp*)
alist_append
  {l}(ar, xs, ys) = let
  fun loop
  (
    ar: !arena(l), p: ptr, res: alist(l, a)
  ) : alist(l, a) =
    if p > the_null_ptr
      then loop(ar, acell_tail(p), alist_cons<a>(ar, acell_head<a>(p), res))
      else res
    // end of [if]
in
  loop(ar, $UN.cast{ptr}(alist_reverse<a>(ar, xs)), ys)
end // end of [alist_append]
//
implement
{a}(*tmp*)
alist_make_list_vt
  {l}(ar, xs) = let
  fun loop
  (
    ar: !arena(l), xs: List0_vt(a), res: alist(l, a)
  ) : alist(l, a) =
  (
    case+ xs of
    | ~list_vt_nil() => res
    | ~list_vt_cons(x, xs) => loop(ar, xs, alist_cons<a>(ar, x, res))
  ) (* end of [loop] *)
  val res = loop(ar, xs, alist_nil())
in
  alist_reverse<a>(ar, res)
end // end of [alist_make_list_vt]
//
implement
{a}(*tmp*)
alist_listize
  (ar, xs) = let
  fun loop
  (
    p: ptr, res: List0_vt(a)
  ) : List0_vt(a) =
    if p > the_null_ptr
      then loop(acell_tail(p), list_vt_cons(acell_head<a>(p), res))
      else res
    // end of [if]
in
  list_vt_reverse(loop($UN.cast{ptr}(xs), list_vt_nil()))
end // end of [alist_listize]
//
(* ****** ****** *)
//
// HX:
// a table: [cap: size_t][size: size_t][buckets: ptr]
// an entry: [next: ptr][key: k][itm: i]
//
macdef
TBL_CAP(p) = ,(p)
macdef
TBL_SIZE(p) = ptr_add<byte>(,(p), sizeof<size_t>)
macdef
TBL_BUCKETS(p) = ptr_add<byte>(,(p), sizeof<size_t> + sizeof<size_t>)
//
extern
fun{}
aslot_round(n: size_t): size_t
implement
{}(*tmp*)
aslot_round(n) = ((n + i2sz(7)) / i2sz(8)) * i2sz(8)
//
macdef
ENT_KEY(p) = ptr_add<byte>(,(p), sizeof<ptr>)
//
extern
fun{k:t@ype}
ahent_itm(p: ptr): ptr
implement
{k}(*tmp*)
ahent_itm(p) = ptr_add<byte>(p, sizeof<ptr> + aslot_round(sizeof<k>))
//
implement
{k,i}(*tmp*)
ahashtbl_make_nil
  {l}(ar, cap) = let
  val p =
    arena_alloc(ar, i2sz(3)*sizeof<ptr>)
  val ps =
    arena_alloc(ar, cap * sizeof<ptr>)
  val () = arena_store<size_t>(TBL_CAP(p), cap)
  val () = arena_store<size_t>(TBL_SIZE(p), i2sz(0))
  val () = arena_store<ptr>(TBL_BUCKETS(p), ps)
in
  $UN.cast(p)
end // end of [ahashtbl_make_nil]
//
implement
{k,i}(*tmp*)
ahashtbl_get_size
  (ar, tbl) = arena_load<size_t>(TBL_SIZE($UN.cast{ptr}(tbl)))
//
implement
{k,i}(*tmp*)
ahashtbl_search
  (ar, tbl, key) = let
//
fun loop
  (p: ptr): Option_vt(i) =
  if p > the_null_ptr
    then (
      if ahashtbl$equal<k>(key, arena_load<k>(ENT_KEY(p)))
        then Some_vt(arena_load<i>(ahent_itm<k>(p)))
        else loop(arena_load<ptr>(p))
      // end of [if]
    ) (* end of [then] *)
    else None_vt()
  // end of [if]
//
val pt = $UN.cast{ptr}(tbl)
val cap = arena_load<size_t>(TBL_CAP(pt))
val ps = arena_load<ptr>(TBL_BUCKETS(pt))
val h = $UN.cast{size_t}
  (ahashtbl$hash<k>(key) mod $UN.cast{ulint}(cap))
//
in
  loop(arena_load<ptr>(ptr_add<ptr>(ps, h)))
end // end of [ahashtbl_search]
//
implement
{k,i}(*tmp*)
ahashtbl_insert
  {l}(ar, tbl, key, itm) = let
//
fun
relink
(
  ps: ptr, cap: ulint, p: ptr
) : void =
  if p > the_null_ptr
    then let
      val next = arena_load<ptr>(p)
      val h = $UN.cast{size_t}
        (ahashtbl$hash<k>(arena_load<k>(ENT_KEY(p))) mod cap)
      val pb = ptr_add<ptr>(ps, h)
      val () = arena_store<ptr>(p, arena_load<ptr>(pb))
      val () = arena_store<ptr>(pb, p)
    in
      relink(ps, cap, next)
    end // end of [then]
  // end of [if]
//
val pt = $UN.cast{ptr}(tbl)
val cap = arena_load<size_t>(TBL_CAP(pt))
val size = arena_load<size_t>(TBL_SIZE(pt))
//
val () =
if size >= cap + cap then let
  val cap2 = cap + cap
  val ps = arena_load<ptr>(TBL_BUCKETS(pt))
  val ps2 = arena_alloc(ar, cap2 * sizeof<ptr>)
  fun loop
  (
    i: size_t
  ) : void =
    if i < cap then
    (
      relink(ps2, $UN.cast{ulint}(cap2), arena_load<ptr>(ptr_add<ptr>(ps, i)));
      loop(succ(i))
    ) (* end of [if] *)
  // end of [loop]
  val () = loop(i2sz(0))
in
  arena_store<size_t>(TBL_CAP(pt), cap2);
  arena_store<ptr>(TBL_BUCKETS(pt), ps2)
end // end of [if]
//
val cap = arena_load<size_t>(TBL_CAP(pt))
val ps = arena_load<ptr>(TBL_BUCKETS(pt))
val h = $UN.cast{size_t}
  (ahashtbl$hash<k>(key) mod $UN.cast{ulint}(cap))
val pb = ptr_add<ptr>(ps, h)
val pe =
  arena_alloc(ar, sizeof<ptr> + aslot_round(sizeof<k>)+sizeof<i>)
val () = arena_store<ptr>(pe, arena_load<ptr>(pb))
val () = arena_store<k>(ENT_KEY(pe), key)
val () = arena_store<i>(ahent_itm<k>(pe), itm)
val () = arena_store<ptr>(pb, pe)
//
in
  arena_store<size_t>(TBL_SIZE(pt), succ(size))
end // end of [ahashtbl_insert]
//
implement
{k,i}(*tmp*)
ahashtbl_listize
  (ar, tbl) = let
//
vtypedef res = List0_vt(@(k, i))
//
fun
loop1
(
  p: ptr, res: res
) : res =
  if p > the_null_ptr
    then
    loop1
    (
      arena_load<ptr>(p)
    , list_vt_cons(@(arena_load<k>(ENT_KEY(p)), arena_load<i>(ahent_itm<k>(p))), res)
    ) (* end of [then] *)
    else res
  // end of [if]
//
val pt = $UN.cast{ptr}(tbl)
val cap = arena_load<size_t>(TBL_CAP(pt))
val ps = arena_load<ptr>(TBL_BUCKETS(pt))
//
fun
loop2
(
  i: size_t, res: res
) : res =
  if i < cap
    then loop2(succ(i), loop1(arena_load<ptr>(ptr_add<ptr>(ps, i)), res))
    else res
  // end of [if]
//
in
  loop2(i2sz(0), list_vt_nil())
end // end of [ahashtbl_listize]
//
(* ****** ****** *)
//
// HX: the global arena
//
implement
{}(*tmp*)
glist_nil() = $UN.cast(the_null_ptr)
//
implement
{a}(*tmp*)
glist_cons
  (x, xs) = let
  val p =
    the_garena_alloc(sizeof<ptr> + sizeof<a>)
  val () = acell_make<a>(p, x, $UN.cast{ptr}(xs))
in
  $UN.cast(p)
end // end of [glist_cons]
//
implement
{a}(*tmp*)
glist_sing(x) = glist_cons<a>(x, glist_nil())
//
implement
{}(*tmp*)
glist_is_nil(xs) = ($UN.cast{ptr}(xs) = the_null_ptr)
implement
{}(*tmp*)
glist_is_cons(xs) = ($UN.cast{ptr}(xs) > the_null_ptr)
//
implement
{a}(*tmp*)
glist_view
  (xs) = let
  val p = $UN.cast{ptr}(xs)
in
  if
  (p > the_null_ptr)
  then GLcons(acell_head<a>(p), $UN.cast{glist(a)}(acell_tail(p)))
  else GLnil((*void*))
end // end of [glist_view]
//
implement
{a}(*tmp*)
glist_head
  (xs) = let
  val p = $UN.cast{ptr}(xs)
  val () = assertloc(p > the_null_ptr)
in
  acell_head<a>(p)
end // end of [glist_head]
//
implement
{a}(*tmp*)
glist_tail
  (xs) = let
  val p = $UN.cast{ptr}(xs)
  val () = assertloc(p > the_null_ptr)
in
  $UN.cast{glist(a)}(acell_tail(p))
end // end of [glist_tail]
//
implement
{a}(*tmp*)
glist_length
  (xs) = let
  fun loop
  (
    p: ptr, n: intGte(0)
  ) : intGte(0) =
    if p > the_null_ptr then loop(acell_tail(p), n+1) else n
  // end of [loop]
in
  loop($UN.cast{ptr}(xs), 0)
end // end of [glist_length]
//
implement
{a}(*tmp*)
glist_reverse
  (xs) = let
  fun loop
  (
    p: ptr, res: glist(a)
  ) : glist(a) =
    if p > the_null_ptr
      then loop(acell_tail(p), glist_cons<a>(acell_head<a>(p), res))
      else res
    // end of [if]
in
  loop($UN.cast{ptr}(xs), glist_nil())
end // end of [glist_reverse]
//
implement
{a}(*tmp*)
glist_append
  (xs, ys) = let
  fun loop
  (
    p: ptr, res: glist(a)
  ) : glist(a) =
    if p > the_null_ptr
      then loop(acell_tail(p), glist_cons<a>(acell_head<a>(p), res))
      else res
    // end of [if]
in
  loop($UN.cast{ptr}(glist_reverse<a>(xs)), ys)
end // end of [glist_append]
//
implement
{a}(*tmp*)
glist_make_list_vt
  (xs) = let
  fun loop
  (
    xs: List0_vt(a), res: glist(a)
  ) : glist(a) =
  (
    case+ xs of
    | ~list_vt_nil() => res
    | ~list_vt_cons(x, xs) => loop(xs, glist_cons<a>(x, res))
  ) (* end of [loop] *)
in
  glist_reverse<a>(loop(xs, glist_nil()))
end // end of [glist_make_list_vt]
//
implement
{a}(*tmp*)
glist_listize
  (xs) = let
  fun loop
  (
    p: ptr, res: List0_vt(a)
  ) : List0_vt(a) =
    if p > the_null_ptr
      then loop(acell_tail(p), list_vt_cons(acell_head<a>(p), res))
      else res
    // end of [if]
in
  list_vt_reverse(loop($UN.cast{ptr}(xs), list_vt_nil()))
end // end of [glist_listize]
//
implement
{a}(*tmp*)
fprint_glist_sep
  (out, xs, sep) = let
  fun loop
  (
    p: ptr, i: int
  ) : void =
    if p > the_null_ptr
      then let
        val () = if i > 0 then fprint_string(out, sep)
        val () = fprint_val<a>(out, acell_head<a>(p))
      in
        loop(acell_tail(p), i+1)
      end // end of [then]
    // end of [if]
in
  loop($UN.cast{ptr}(xs), 0)
end // end of [fprint_glist_sep]
//
(* ****** ****** *)
//
// HX: a gopt is null or points to its value
//
implement
{}(*tmp*)
gopt_none() = $UN.cast(the_null_ptr)
//
implement
{a}(*tmp*)
gopt_some
  (x) = let
  val p = the_garena_alloc(sizeof<a>)
  val () = arena_store<a>(p, x)
in
  $UN.cast(p)
end // end of [gopt_some]
//
implement
{}(*tmp*)
gopt_is_none(opt) = ($UN.cast{ptr}(opt) = the_null_ptr)
implement
{}(*tmp*)
gopt_is_some(opt) = ($UN.cast{ptr}(opt) > the_null_ptr)
//
implement
{a}(*tmp*)
gopt_view
  (opt) = let
  val p = $UN.cast{ptr}(opt)
in
  if p > the_null_ptr
    then GOsome(arena_load<a>(p)) else GOnone()
  // end of [if]
end // end of [gopt_view]
//
implement
{a}(*tmp*)
gopt_unsome
  (opt) = let
  val p = $UN.cast{ptr}(opt)
  val () = assertloc(p > the_null_ptr)
in
  arena_load<a>(p)
end // end of [gopt_unsome]
//
implement
{a}(*tmp*)
gopt_make_option_vt
  (opt) =
(
  case+ opt of
  | ~Some_vt(x) => gopt_some<a>(x)
  | ~None_vt((*void*)) => gopt_none()
) (* end of [gopt_make_option_vt] *)
//
(* ****** ****** *)

(* end of [arena.dats] *)
