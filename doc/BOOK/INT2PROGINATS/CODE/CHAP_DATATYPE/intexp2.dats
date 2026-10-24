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
** Example: evaluating integer expressions (with if-then-else)
** The datavtypes IEXP and BEXP are defined mutually recursively
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

datavtype IEXP =
  | IEXPcst of int // integer constants
  | IEXPneg of (IEXP) // negative
  | IEXPadd of (IEXP, IEXP) // addition
  | IEXPsub of (IEXP, IEXP) // subtraction
  | IEXPmul of (IEXP, IEXP) // multiplication
  | IEXPdiv of (IEXP, IEXP) // division
  | IEXPif of (BEXP(*test*), IEXP(*then*), IEXP(*else*))
// end of [IEXP]

and BEXP = // [and] for combining datavtype declarations
  | BEXPcst of bool // boolean constants
  | BEXPneg of BEXP // negation
  | BEXPconj of (BEXP, BEXP) // conjunction
  | BEXPdisj of (BEXP, BEXP) // disjunction
  | BEXPeq of (IEXP, IEXP) // equal-to
  | BEXPneq of (IEXP, IEXP) // not-equal-to
  | BEXPlt of (IEXP, IEXP) // less-than
  | BEXPlte of (IEXP, IEXP) // less-than-equal-to
  | BEXPgt of (IEXP, IEXP) // greater-than
  | BEXPgte of (IEXP, IEXP) // greater-than-equal-to
// end of [BEXP]

(* ****** ****** *)

fun
eval_iexp
(
  e0: !IEXP
) : int = (
//
case+ e0 of
| IEXPcst n => n
| IEXPneg (e) => ~eval_iexp (e)
| IEXPadd (e1, e2) => eval_iexp (e1) + eval_iexp (e2)
| IEXPsub (e1, e2) => eval_iexp (e1) - eval_iexp (e2)
| IEXPmul (e1, e2) => eval_iexp (e1) * eval_iexp (e2)
| IEXPdiv (e1, e2) => eval_iexp (e1) / eval_iexp (e2)
| IEXPif
  (
    e_test, e_then, e_else
  ) =>
  (
    if eval_bexp (e_test) then eval_iexp (e_then) else eval_iexp (e_else)
  ) // end of [IEXPif]
//
) (* end of [eval_iexp] *)

and
eval_bexp
(
  e0: !BEXP
) : bool = (
//
case+ e0 of
| BEXPcst b => b
| BEXPneg (e) => ~eval_bexp (e)
| BEXPconj (e1, e2) =>
    if eval_bexp (e1) then eval_bexp (e2) else false
| BEXPdisj (e1, e2) =>
    if eval_bexp (e1) then true else eval_bexp (e2)
| BEXPeq (e1, e2) => eval_iexp (e1) = eval_iexp (e2)
| BEXPneq (e1, e2) => eval_iexp (e1) != eval_iexp (e2)
| BEXPlt (e1, e2) => eval_iexp (e1) < eval_iexp (e2)
| BEXPlte (e1, e2) => eval_iexp (e1) <= eval_iexp (e2)
| BEXPgt (e1, e2) => eval_iexp (e1) > eval_iexp (e2)
| BEXPgte (e1, e2) => eval_iexp (e1) >= eval_iexp (e2)
//
) (* end of [eval_bexp] *)

(* ****** ****** *)
//
// The expressions are consumed (and freed) by the two functions below
//
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
| ~IEXPif (e1, e2, e3) => (free_bexp (e1); free_iexp (e2); free_iexp (e3))
) (* end of [free_iexp] *)

and
free_bexp
  (e0: BEXP): void =
(
case+ e0 of
| ~BEXPcst (_) => ()
| ~BEXPneg (e) => free_bexp (e)
| ~BEXPconj (e1, e2) => (free_bexp (e1); free_bexp (e2))
| ~BEXPdisj (e1, e2) => (free_bexp (e1); free_bexp (e2))
| ~BEXPeq (e1, e2) => (free_iexp (e1); free_iexp (e2))
| ~BEXPneq (e1, e2) => (free_iexp (e1); free_iexp (e2))
| ~BEXPlt (e1, e2) => (free_iexp (e1); free_iexp (e2))
| ~BEXPlte (e1, e2) => (free_iexp (e1); free_iexp (e2))
| ~BEXPgt (e1, e2) => (free_iexp (e1); free_iexp (e2))
| ~BEXPgte (e1, e2) => (free_iexp (e1); free_iexp (e2))
) (* end of [free_bexp] *)

(* ****** ****** *)

implement
main0 () =
{
//
// (if 1+2 <= 3*4 then 5+6 else 7-8)
//
val e0 =
  IEXPif
  (
    BEXPlte
    (
      IEXPadd (IEXPcst 1, IEXPcst 2)
    , IEXPmul (IEXPcst 3, IEXPcst 4)
    )
  , IEXPadd (IEXPcst 5, IEXPcst 6)
  , IEXPsub (IEXPcst 7, IEXPcst 8)
  ) (* end of [val] *)
//
val () = assertloc (eval_iexp (e0) = 11)
val () = free_iexp (e0)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [intexp2.dats] *)
