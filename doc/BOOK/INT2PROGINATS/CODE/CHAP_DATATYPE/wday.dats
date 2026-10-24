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
** Example: an enumerative datatype
** (the constructors have no arguments, so no heap memory is allocated)
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

datatype wday =
  | Monday of ()
  | Tuesday of ()
  | Wednesday of ()
  | Thursday of ()
  | Friday of ()
  | Saturday of ()
  | Sunday of ()
// end of [wday]

(* ****** ****** *)

fun isWeekday
  (x: wday): bool = case x of
  | Monday() => true // the first bar (|) is optional
  | Tuesday() => true
  | Wednesday() => true
  | Thursday() => true
  | Friday() => true
  | Saturday() => false
  | Sunday() => false
// end of [isWeekday]

(* ****** ****** *)

fun isWeekday2
  (x: wday): bool = case x of
  | Saturday() => false | Sunday() => false | _ => true
// end of [isWeekday2]

(* ****** ****** *)

implement
main0 () =
{
//
val () = assertloc (isWeekday (Monday()))
val () = assertloc (isWeekday (Friday))
val () = assertloc (~isWeekday (Sunday()))
val () = assertloc (isWeekday2 (Monday()))
val () = assertloc (~isWeekday2 (Saturday))
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [wday.dats] *)
