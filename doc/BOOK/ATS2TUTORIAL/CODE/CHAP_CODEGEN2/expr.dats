(*
** For ATS2TUTORIAL
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

staload "./expr.sats"

(* ****** ****** *)
//
extern
fun
datcon_expr : (!expr) -> string
extern
fun
datcontag_expr : (!expr) -> int
//
(* ****** ****** *)

#ifdef
CODEGEN2
#then
//
#codegen2("datcon", expr)
#codegen2("datcontag", expr)
//
#else
//
#include "./expr_codegen2.hats"
//
implement
datcon_expr(x) = datcon_expr_(x)
//
implement
datcontag_expr(x) = datcontag_expr_(x)
//
//
#endif // #ifdef(CODEGEN2)

(* ****** ****** *)

extern
fun
fprint_expr
  (out: FILEref, x: !expr): void
//
implement
fprint_expr(out, x) =
(
case+ x of
| Int(i) => fprint!(out, "Int(", i, ")")
| Var(s) => fprint!(out, "Var(", s, ")")
| Add(x1, x2) =>
  (fprint!(out, "("); fprint_expr(out, x1); fprint!(out, "+"); fprint_expr(out, x2); fprint!(out, ")"))
| Sub(x1, x2) =>
  (fprint!(out, "("); fprint_expr(out, x1); fprint!(out, "-"); fprint_expr(out, x2); fprint!(out, ")"))
| Mul(x1, x2) =>
  (fprint!(out, "("); fprint_expr(out, x1); fprint!(out, "*"); fprint_expr(out, x2); fprint!(out, ")"))
| Div(x1, x2) =>
  (fprint!(out, "("); fprint_expr(out, x1); fprint!(out, "/"); fprint_expr(out, x2); fprint!(out, ")"))
| Ifgtz(x1, x2, x3) =>
  (
    fprint!(out, "Ifgtz(");
    fprint_expr(out, x1); fprint!(out, ","); fprint_expr(out, x2); fprint!(out, ","); fprint_expr(out, x3);
    fprint!(out, ")")
  )
| Ifgtez(x1, x2, x3) =>
  (
    fprint!(out, "Ifgtez(");
    fprint_expr(out, x1); fprint!(out, ","); fprint_expr(out, x2); fprint!(out, ","); fprint_expr(out, x3);
    fprint!(out, ")")
  )
)
//
(* ****** ****** *)

extern
fun
expr_free : (expr) -> void
//
implement
expr_free(x) =
(
case+ x of
| ~Int _ => ()
| ~Var _ => ()
| ~Add(x1, x2) => (expr_free(x1); expr_free(x2))
| ~Sub(x1, x2) => (expr_free(x1); expr_free(x2))
| ~Mul(x1, x2) => (expr_free(x1); expr_free(x2))
| ~Div(x1, x2) => (expr_free(x1); expr_free(x2))
| ~Ifgtz(x1, x2, x3) => (expr_free(x1); expr_free(x2); expr_free(x3))
| ~Ifgtez(x1, x2, x3) => (expr_free(x1); expr_free(x2); expr_free(x3))
)
//
(* ****** ****** *)

implement
main0 () =
{
//
val E = Add(Int(10), Mul(Int(1), Int(2)))
val () = (fprint_expr(stdout_ref, E); fprint_newline(stdout_ref))
val () = fprintln! (stdout_ref, "datcon(E) = ", datcon_expr(E))
val () = fprintln! (stdout_ref, "datcontag(E) = ", datcontag_expr(E))
val () = expr_free(E)
//
val E2 = Div(Int(1), Sub(Int(2), Int(3)))
val () = fprintln! (stdout_ref, "datcon(E2) = ", datcon_expr(E2))
val () = fprintln! (stdout_ref, "datcontag(E2) = ", datcontag_expr(E2))
val () = expr_free(E2)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [expr.dats] *)
