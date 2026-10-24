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
** Exporting types in ATS for use in C
**
** Updated for the linear-only dialect of ATS2 (no GC): abc is a datavtype
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

datavtype abc =
  | cons1 of int | cons2 of (int, double)

(* ****** ****** *)

extern
vtypedef "cons2_node" = cons2_pstruct(int, double)

(* ****** ****** *)
//
// the declaration of the C function (which is
// defined at the end of the generated C file)
//
%{^
extern void *cons2_make (int i, double d) ;
%}

(* ****** ****** *)

extern
fun
cons2_make(int, double): abc = "mac#"

(* ****** ****** *)

implement
main0 () =
{
//
val-~cons2(i, d) = cons2_make(1, 2.34)
//
val () = assertloc (i = 1)
val () = assertloc (d > 2.33 && d < 2.35)
//
} (* end of [main0] *)

(* ****** ****** *)

%{$
void *
cons2_make
(
  int i, double d
) {
  cons2_node p ;
  p = ATS_MALLOC(sizeof(cons2_node_)) ;
  p->contag = 1 ;
  p->atslab__0 = i ;
  p->atslab__1 = d ;
  return p ;
} /* end of [cons2_make] */
%}

(* ****** ****** *)

(* end of [abc.dats] *)
