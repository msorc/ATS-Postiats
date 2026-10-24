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
** Example: function templates and polymorphic functions
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

typedef charint = (char, int)
typedef intchar = (int, char)

(* ****** ****** *)
//
fun{
a,b:t@ype
} swap (xy: (a, b)): (b, a) = (xy.1, xy.0)
//
fun
swap_char_int (xy: charint): intchar = swap<char,int> (xy)
fun
swap_int_char (xy: intchar): charint = swap<int,char> (xy)
//
(* ****** ****** *)
//
fun
{a:t@ype}
{b:t@ype}
swap2 (xy: (a, b)): (b, a) = (xy.1, xy.0)
//
fun
swap_char_int2 (xy: charint): intchar = swap2<char><int> (xy)
fun
swap_int_char2 (xy: intchar): charint = swap2<int><char> (xy)
//
(* ****** ****** *)

fun
swap_boxed{a,b:type} (xy: (a, b)): (b, a) = (xy.1, xy.0)

fun
swap2_boxed{a:type}{b:type} (xy: (a, b)): (b, a) = (xy.1, xy.0)

(* ****** ****** *)
//
// Composing two functions: they are flat closures (on the stack)
// and are passed by reference
//
fun{
a,b,c:t@ype
} compose_apply
(
  f: &(a) -<clo1> b, g: &(b) -<clo1> c, x: a
) : c = g (f (x))

(* ****** ****** *)

fun divopt
(
  x: int, y: int
) : Option_vt (int) =
  if y != 0 then Some_vt{int}(x/y) else None_vt((*void*))
// end of [divopt]

(* ****** ****** *)

implement
main0 () =
{
//
val-~Some_vt (q) = divopt (7, 2)
val () = assertloc (q = 3)
val-~None_vt () = divopt (7, 0)
//
//
val ic = swap_char_int (('a', 1))
val () = assertloc (ic.0 = 1 && ic.1 = 'a')
val ci = swap_int_char2 ((1, 'a'))
val () = assertloc (ci.0 = 'a' && ci.1 = 1)
//
val AB = (box("A"), box("B"))
//
typedef boxstr = boxed(string)
val BA1 = swap_boxed{boxstr,boxstr} (AB)
val BA2 = swap_boxed (AB) // omitting type arguments may be fine
//
val () = println! ("BA1.0 = ", unbox(BA1.0))
val () = println! ("BA1.1 = ", unbox(BA1.1))
val () = println! ("BA2.0 = ", unbox(BA2.0))
val () = println! ("BA2.1 = ", unbox(BA2.1))
//
val BA3 = swap2_boxed (AB) // both static arguments to be synthesized
val BA4 = swap2_boxed{...} (AB) // both static arguments to be synthesized
val BA5 = swap2_boxed{..}{boxstr} (AB) // 1st static argument to be synthesized
val BA6 = swap2_boxed{boxstr}{..} (AB) // 2nd static argument to be synthesized
val BA7 = swap2_boxed{..}{..} (AB) // both static arguments to be synthesized
val BA8 = swap2_boxed{boxstr}{boxstr} (AB) // both static arguments are provided
//
var inc_by_1 = lam@ (x:int): int => x+1
var mul_by_2 = lam@ (x:int): int => x*2
//
// [mul_by_2] first and then [inc_by_1]
//
val r1 = compose_apply<int,int,int> (mul_by_2, inc_by_1, 100)
//
// [inc_by_1] first and then [mul_by_2]
//
val r2 = compose_apply<int,int,int> (inc_by_1, mul_by_2, 100)
//
val () = assertloc (r1 = 201)
val () = assertloc (r2 = 202)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [misc.dats] *)
