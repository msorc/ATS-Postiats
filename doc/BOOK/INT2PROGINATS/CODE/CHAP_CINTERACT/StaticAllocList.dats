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
** Example: constructing a statically allocated list
**
** Updated for the linear-only dialect of ATS2 (no GC): the list is a list_vt
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
//
vtypedef
list_node =
list_vt_cons_pstruct(int,ptr) // [list_node] for boxed nodes
//
extern
vtypedef "list_node" = list_node // exporting [list_node] to C
//
(* ****** ****** *)
//
typedef
list_node_ = $extype"list_node_" // [list_node_] for unboxed nodes
//
(* ****** ****** *)

local

#define N 10

(*
** static allocation
*)
var nodes = @[list_node_][N]()

fun loop
(
  p: ptr, i: int
) : void = let
in
//
if i < N then let
  val res =
  $UN.castvwtp0{list_node}(p)
  val+list_vt_cons (x, xs) = res
  val (
  ) = x := i*i
  val p = ptr_succ<list_node_> (p)
  val i = i + 1
  val () = (
    if i < N then xs := p else xs := the_null_ptr
  ) : void // end of [val]
  val _(*ptr*) = $UN.castvwtp0{ptr}((view@x, view@xs | res))
in
  loop (p, i)
end else ((*void*)) // end of [if]
//
end // end of [loop]

in (* in of [local] *)

val () = loop (addr@nodes, 0)
val xs_static = $UN.castvwtp0{list_vt(int,N)}((view@nodes|addr@nodes))
val () = println! ("xs_static = ", xs_static) // 0, 1, 4, 9, 16, ...
//
// the memory is static and is never freed: the list is given up
//
val _(*ptr*) = $UN.castvwtp0{ptr}(xs_static)

end // end of [local]

(* ****** ****** *)

implement main0 () = ()

(* ****** ****** *)

(* ****** ****** *)

(* end of [StaticAllocList.dats] *)
