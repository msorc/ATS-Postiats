(*
** For ATS2TUTORIAL
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

staload UN = $UNSAFE

(* ****** ****** *)
//
datatype weekday =
  | Monday | Tuesday | Wednesday | Thursday | Friday
//
(* ****** ****** *)
//
fun
weekday2int
  (wd: weekday): int = $UN.cast{int}($UN.cast{intptr}(wd))
//
(* ****** ****** *)

val () = println! ("Monday -> ", weekday2int(Monday))
val () = println! ("Tuesday -> ", weekday2int(Tuesday))
val () = println! ("Wednesday -> ", weekday2int(Wednesday))
val () = println! ("Thursday -> ", weekday2int(Thursday))
val () = println! ("Friday -> ", weekday2int(Friday))

(* ****** ****** *)
//
fun
isFriday(x: weekday): bool =
  case+ x of Friday() => true | _ => false
//
(* ****** ****** *)

val () = assertloc (isFriday(Friday))
val () = assertloc (isFriday(Friday()))

(* ****** ****** *)

(* ****** ****** *)
//
// HX-2026-10: no GC
// a datatype may only have nullary constructors (such
// as [weekday] above); a datavtype is used otherwise,
// and its values are freed explicitly
//
(* ****** ****** *)

datavtype abc =
  | A of () | B of (bool) | C of (int, double)

fun
abc2tag
(x: !abc): int = let
  val p = $UN.castvwtp1{intptr}(x)
in
//
case+ 0 of
| _ when p < 1024 => $UN.cast{int}(p)
| _ (*heap-allocated*) => $UN.ptr0_get<int>($UN.cast{ptr}(p))
//
end // end of [abc2tag]

fun
abc_free(x: abc): void =
  case+ x of ~A() => () | ~B(_) => () | ~C(_, _) => ()

val () = let
  val x = A() in println! ("tag(A) = ", abc2tag(x)); abc_free(x)
end
val () = let
  val x = B(true) in println! ("tag(B) = ", abc2tag(x)); abc_free(x)
end
val () = let
  val x = C(0, 1.0) in println! ("tag(C) = ", abc2tag(x)); abc_free(x)
end

(* ****** ****** *)

datavtype ab = AA of () | BB of (bool)

fun
ab_free(x: ab): void = case+ x of ~AA() => () | ~BB(_) => ()

val () = let
  val x = AA()
  val () = assertloc (iseqz($UN.castvwtp1{ptr}(x)))
in
  ab_free(x)
end
val () = let
  val x = BB(true)
  val () = assertloc (true = $UN.ptr0_get<bool>($UN.castvwtp1{ptr}(x)))
in
  ab_free(x)
end
val () = let
  val x = BB(false)
  val () = assertloc (false = $UN.ptr0_get<bool>($UN.castvwtp1{ptr}(x)))
in
  ab_free(x)
end

(* ****** ****** *)

datavtype exp =
| Int of int
| Neg of (exp)
| Add of (exp, exp)
| Sub of (exp, exp)

(* ****** ****** *)

datavtype
intexp =
| IInt of int
| INeg of (intexp)
| IAdd of (intexp, intexp)
| ISub of (intexp, intexp)
| IfThenElse of (boolexp, intexp, intexp)
and
boolexp =
| Bool of bool
| Not of (boolexp)
| Disj of (boolexp, boolexp)
| Conj of (boolexp, boolexp)
| Less of (intexp, intexp)
| LessEq of (intexp, intexp)
//
symintr eval
//
extern
fun eval_intexp : (!intexp) -> int
extern
fun eval_boolexp : (!boolexp) -> bool
//
overload eval with eval_intexp
overload eval with eval_boolexp
//
extern
fun free_intexp : (intexp) -> void
extern
fun free_boolexp : (boolexp) -> void
//
(* ****** ****** *)
//
implement
eval_intexp
  (e0) = (
//
case+ e0 of
| IInt (i) => i
| INeg (e) => ~eval(e)
| IAdd (e1, e2) => eval(e1) + eval(e2)
| ISub (e1, e2) => eval(e1) - eval(e2)
| IfThenElse
    (e_test, e_then, e_else) =>
    if eval(e_test) then eval(e_then) else eval(e_else)
//
) (* end of [eval_intexp] *)
//
implement
eval_boolexp
  (e0) = (
//
case+ e0 of
| Bool (b) => b
| Not (e) => ~eval(e)
| Less (e1, e2) => eval(e1) < eval(e2)
| LessEq (e1, e2) => eval(e1) <= eval(e2)
| Conj (e1, e2) => eval(e1) && eval(e2)
| Disj (e1, e2) => eval(e1) || eval(e2)
//
) (* end of [eval_boolexp] *)
//
implement
free_intexp
  (e0) = (
//
case+ e0 of
| ~IInt (_) => ()
| ~INeg (e) => free_intexp(e)
| ~IAdd (e1, e2) => (free_intexp(e1); free_intexp(e2))
| ~ISub (e1, e2) => (free_intexp(e1); free_intexp(e2))
| ~IfThenElse
    (e_test, e_then, e_else) =>
    (free_boolexp(e_test); free_intexp(e_then); free_intexp(e_else))
//
) (* end of [free_intexp] *)
//
implement
free_boolexp
  (e0) = (
//
case+ e0 of
| ~Bool (_) => ()
| ~Not (e) => free_boolexp(e)
| ~Less (e1, e2) => (free_intexp(e1); free_intexp(e2))
| ~LessEq (e1, e2) => (free_intexp(e1); free_intexp(e2))
| ~Conj (e1, e2) => (free_boolexp(e1); free_boolexp(e2))
| ~Disj (e1, e2) => (free_boolexp(e1); free_boolexp(e2))
//
) (* end of [free_boolexp] *)
//
(* ****** ****** *)

val E0 =
IfThenElse (
  Less(IInt(1), IInt(2)), ISub(IInt(11), IInt(1)), IAdd(IInt(12), IInt(13))
) (* end of [val] *)

val () = assertlocmsg (eval(E0) = 10, "\n")
val () = free_intexp (E0)

(* ****** ****** *)

implement main0 () = ()

(* ****** ****** *)

(* end of [chap_datatypes.dats] *)
