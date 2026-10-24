(*
** For ATS2TUTORIAL
*)

(* ****** ****** *)
//
datavtype expr =
  | Int of int
  | Var of string
  | Add of (expr, expr)
  | Sub of (expr, expr)
  | Mul of (expr, expr)
  | Div of (expr, expr)
  | Ifgtz of (expr, expr, expr) // if expr > 0 then ... else ...
  | Ifgtez of (expr, expr, expr) // if expr >= 0 then ... else ...
//
(* ****** ****** *)

fun{}
datcon_expr_ : (!expr) -> string
fun{}
datcontag_expr_ : (!expr) -> intGte(0)

(* ****** ****** *)

(* end of [expr.sats] *)
