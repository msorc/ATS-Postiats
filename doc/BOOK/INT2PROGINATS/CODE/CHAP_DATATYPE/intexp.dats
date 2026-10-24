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
** Example: evaluating integer expressions
** The abstract syntax trees are allocated in the heap: they are
** linear values (datavtype) and must be freed.
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

datavtype IEXP =
  | IEXPcst of int // constants
  | IEXPneg of (IEXP) // negative
  | IEXPadd of (IEXP, IEXP) // addition
  | IEXPsub of (IEXP, IEXP) // subtraction
  | IEXPmul of (IEXP, IEXP) // multiplication
  | IEXPdiv of (IEXP, IEXP) // division
// end of [IEXP]

(* ****** ****** *)

fun
eval_iexp
  (e0: !IEXP): int =
(
case+ e0 of
| IEXPcst (n) => n
| IEXPneg (e) => ~eval_iexp (e)
| IEXPadd (e1, e2) => eval_iexp (e1) + eval_iexp (e2)
| IEXPsub (e1, e2) => eval_iexp (e1) - eval_iexp (e2)
| IEXPmul (e1, e2) => eval_iexp (e1) * eval_iexp (e2)
| IEXPdiv (e1, e2) => eval_iexp (e1) / eval_iexp (e2)
) (* end of [eval_iexp] *)

(* ****** ****** *)

fun
free_iexp
  (e0: IEXP): void =
(
case+ e0 of
| ~IEXPcst (_) => ()
| ~IEXPneg (e) => free_iexp (e)
| ~IEXPadd (e1, e2) => (free_iexp (e1); free_iexp (e2))
| ~IEXPsub (e1, e2) => (free_iexp (e1); free_iexp (e2))
| ~IEXPmul (e1, e2) => (free_iexp (e1); free_iexp (e2))
| ~IEXPdiv (e1, e2) => (free_iexp (e1); free_iexp (e2))
) (* end of [free_iexp] *)

(* ****** ****** *)

implement
main0 () =
{
//
// the abstract syntax tree of (~1+(2-3)*4)
//
val e0 =
  IEXPadd(IEXPneg(IEXPcst(1)), IEXPmul(IEXPsub(IEXPcst(2), IEXPcst(3)), IEXPcst(4)))
//
val () = assertloc (eval_iexp (e0) = ~5)
val () = free_iexp (e0)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [intexp.dats] *)
