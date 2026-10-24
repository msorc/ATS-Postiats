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
** Example: string processing
**
** Updated for the linear-only dialect of ATS2 (no GC): Option_vt replaces Option
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

fun
string_length
  {n:nat}
(
  str: string(n)
) : size_t(n) = let
  fun
  loop{i:nat | i <= n} .<n-i>.
    (str: string(n), i: size_t(i)): size_t(n) =
    if string_isnot_atend(str, i) then loop(str, succ(i)) else i
  // end of [loop]
in
  loop(str, i2sz(0))
end // end of [string_length]

typedef
sizeLt(n:int) = [i:nat | i < n] size_t(i)

fun
string_find{n:nat}
(
  str: string n, c0: char
) : Option_vt(sizeLt n) = let
  typedef res = sizeLt(n)
  fun loop{i:nat | i <= n}
  (
    str: string n, c0: char, i: size_t i
  ) : Option_vt(res) = let
    val isnot = string_isnot_atend(str, i)
  in
    if isnot then
      if (c0 = str[i])
        then Some_vt{res}(i) else loop(str, c0, succ(i))
      // end of [if]
    else None_vt() // end of [if]
  end (* end of [loop] *)
in
  loop(str, c0, i2sz(0))
end // end of [string_find]

fun
string_find2{n:nat}
(
  str: string n, c0: char
) : Option_vt(sizeLt n) = let
//
fun
loop
{i:nat | i <= n}
(
  str: string(n)
, c0: char, i: size_t(i)
) : Option_vt(sizeLt n) = let
  typedef res = sizeLt(n)
  val (pf | c) = string_test_at(str, i)
in
  if c != '\000' then let
    prval string_index_p_neqz() = pf
  in
    if (c0 = c)
      then Some_vt{res}(i) else loop(str, c0, succ(i))
    // end of [if]
  end else let
    prval string_index_p_eqz() = pf
  in
    None_vt((*void*)) // end of [if]
  end // end of [if]
end // end of [loop]
//
in
  loop(str, c0, i2sz(0))
end // end of [string_find2]


implement
main0 () =
{
//
val () = assertloc (string_length ("hello") = 5)
//
val-~Some_vt (i) = string_find ("hello", 'l')
val () = assertloc (i = 2)
val-~Some_vt (i) = string_find2 ("hello", 'o')
val () = assertloc (i = 4)
val-~None_vt () = string_find ("hello", 'z')
val-~None_vt () = string_find2 ("hello", 'z')
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [strings.dats] *)
