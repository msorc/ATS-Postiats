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
** A package for finite sets of integers
**
** A set is a linear value: it is allocated in the heap and it is
** either consumed by a function (the type [intset]) or borrowed by
** a function (the type [!intset]).
*)

(* ****** ****** *)

staload "./mylist.sats"

(* ****** ****** *)

absvtype intset_vtype = ptr // a boxed and linear abstract type
vtypedef intset = intset_vtype

(* ****** ****** *)

// empty set
fun intset_make_nil (): intset

// singleton set of [x]
fun intset_make_sing (x: int): intset

// turning a list into a set (the list is consumed)
fun intset_make_list (xs: mylist int): intset

// turning a set into a list (the set is consumed)
fun intset_listize (xs: intset): mylist (int)

// freeing a set
fun intset_free (xs: intset): void

// membership test
fun intset_ismem (xs: !intset, x: int): bool

// computing the size of [xs]
fun intset_size (xs: !intset): int

// adding [x] into [xs]
fun intset_add (xs: intset, x: int): intset

// deleting [x] from [xs]
fun intset_del (xs: intset, x: int): intset

// union of [xs1] and [xs2]
fun intset_union (xs1: intset, xs2: intset): intset

// intersection of [xs1] and [xs2]
fun intset_inter (xs1: intset, xs2: intset): intset

// difference between [xs1] and [xs2]
fun intset_differ (xs1: intset, xs2: intset): intset

(* ****** ****** *)

(* end of [intset.sats] *)
