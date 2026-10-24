(*
** Copyright (C) 2011 Hongwei Xi, ATS Trustful Software, Inc.
**
** Permission is hereby granted, free of charge, to any person
** obtaining a copy of this software and associated documentation
** files (the "Software"), to deal in the Software without
** restriction, including without limitation the rights to use,
** copy, modify, merge, publish, distribute, sublicense, and/or sell
** copies of the Software, and to permit persons to whom the
** Software is furnished to do so, subject to the following
** conditions:
**
** The above copyright notice and this permission notice shall be
** included in all copies or substantial portions of the Software.
**
** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
** EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
** OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
** NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
** HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
** WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
** FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
** OTHER DEALINGS IN THE SOFTWARE.
*)

(* ****** ****** *)

(*
** Unsafe C-style programming: copying a list into an array
**
** Updated for the linear-only dialect of ATS2 (no GC): the list is borrowed
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

staload
UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

extern
fun{a:t@ype}
array_copy_from_list
  {n:nat} (A: !arrayptr(a, n), xs: !list_vt(a, n)): void

(* ****** ****** *)

implement
{a}(*tmp*)
array_copy_from_list
  (A, xs) = let
//
fun loop
  {n:nat}
(
  p: ptr, xs: !list_vt(a, n)
) : void =
(
case+ xs of
| list_vt_nil() => ()
| list_vt_cons(x, xs) => let
    val () = $UN.ptr0_set<a>(p, x) in loop (ptr0_succ<a>(p), xs)
  end // end of [list_vt_cons]
) (* end of [loop] *)
//
in
  loop (ptrcast(A), xs)
end // end of [array_copy_from_list]

(* ****** ****** *)

implement
main0 () =
{
//
val xs = $list_vt{int}(1, 2, 3)
val A = arrayptr_make_elt<int> (i2sz(3), 0)
val () = array_copy_from_list<int> (A, xs)
val a0 = A[0] and a1 = A[1] and a2 = A[2]
val () = assertloc (a0 = 1 && a1 = 2 && a2 = 3)
val () = list_vt_free (xs)
val () = arrayptr_free (A)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [ArrayCopyFromList.dats] *)
