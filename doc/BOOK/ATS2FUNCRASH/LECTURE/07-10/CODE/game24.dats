(* ****** ****** *)
//
// The game of 24. The expressions are shared (a subexpression
// is a part of many expressions), and so they are kept in the global
// arena; the lists of expressions are linear lists of handles.
//
(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
staload UN = "prelude/SATS/unsafe.sats"
//
staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"
//
(* ****** ****** *)
//
#include "./../../05/CODE/listfun.hats"
#include "./../../06/CODE/listfun2.hats"
#include "./../../07/CODE/listfun3.hats"
//
(* ****** ****** *)
//
#define
int2dbl g0int2float_int_double
#define
dbl2int g0float2int_double_int
//
(* ****** ****** *)
//
// the arena encoding of [expr] is generated from game24.spec
//
staload "./game24.sats"
#include "./game24_gen_dats.hats"
//
vtypedef exprlst = List0_vt(expr)
//
(* ****** ****** *)
//
val myproof =
expr_EXPRbop('/', expr_EXPRbop('-', expr_EXPRbop('*', expr_EXPRnum(10.0), expr_EXPRnum(10.0)), expr_EXPRnum(4.0)), expr_EXPRnum(4.0))
//
(* ****** ****** *)
//
extern
fun
eval_expr(x0: expr): double
//
overload eval with eval_expr
//
implement
eval_expr(x0) =
(
case+ expr_view(x0) of
| ~EXPRnum(v0) => v0
| ~EXPRbop(opr, x1, x2) => let
    val v1 = eval_expr(x1)
    val v2 = eval_expr(x2)
  in
    case+ opr of
    | '+' => v1 + v2
    | '-' => v1 - v2
    | '*' => v1 * v2
    | '/' => v1 / v2
    | _(*unrecognized*) =>
      let val () = assertloc(false) in 0.0 end
  end
) (* end of [eval_expr] *)
//
(* ****** ****** *)
//
extern
fun
print_expr : (expr) -> void
extern
fun
fprint_expr : (FILEref, expr) -> void
//
overload print with print_expr
overload fprint with fprint_expr
//
(* ****** ****** *)
//
implement
print_expr(x0) =
fprint_expr(stdout_ref, x0)
//
implement
fprint_expr(out, x0) =
(
case+ expr_view(x0) of
| ~EXPRnum(v0) =>
  fprint(out, dbl2int(v0))
| ~EXPRbop(opr, x1, x2) =>
  fprint!(out, "(", x1, opr, x2, ")")
)
//
(* ****** ****** *)
//
extern
fun
add_expr_expr
  : (expr, expr) -> expr
and
sub_expr_expr
  : (expr, expr) -> expr
and
mul_expr_expr
  : (expr, expr) -> expr
and
div_expr_expr
  : (expr, expr) -> expr
//
overload + with add_expr_expr
overload - with sub_expr_expr
overload * with mul_expr_expr
overload / with div_expr_expr
//
(* ****** ****** *)
//
implement
add_expr_expr(x1, x2) = expr_EXPRbop('+', x1, x2)
implement
sub_expr_expr(x1, x2) = expr_EXPRbop('-', x1, x2)
implement
mul_expr_expr(x1, x2) = expr_EXPRbop('*', x1, x2)
implement
div_expr_expr(x1, x2) = expr_EXPRbop('/', x1, x2)
//
(* ****** ****** *)
//
#define EPSILON 1E-8
//
extern
fun
eq_expr_int(expr, int): bool
//
overload = with eq_expr_int
//
implement
eq_expr_int(x0, i0) = abs(eval_expr(x0) - i0) < EPSILON
//
(* ****** ****** *)
//
extern
fun
combine_expr_expr(expr, expr): exprlst
//
overload combine with combine_expr_expr
//
(* ****** ****** *)
//
// [cons_if(b, x, res)] is [x :: res] if [b] is true or [res] otherwise
//
fun
cons_if
(b: bool, x: expr, res: exprlst): exprlst =
if b then list_vt_cons(x, res) else res
//
implement
combine_expr_expr
  (x1, x2) = res where
{
//
val res = list_vt_nil{expr}()
val res = list_vt_cons(x1+x2, res)
val res = list_vt_cons(x1-x2, res)
val res = list_vt_cons(x2-x1, res)
val res = list_vt_cons(x1*x2, res)
val res = cons_if(~(x2 = 0), x1/x2, res)
val res = cons_if(~(x1 = 0), x2/x1, res)
//
val res = list_vt_reverse(res)
//
} (* end of [combine_expr_expr] *)
//
(* ****** ****** *)
//
//
vtypedef task = List0_vt(expr)
//
// the new tasks that are made of a list of expressions
// and a task [rest] (which is copied for each expression)
//
fun
tasks_make
(es: !List0_vt(expr), rest: !task): List0_vt(task) =
(
case+ es of
| list_vt_nil() => list_vt_nil()
| list_vt_cons(e, es) =>
  list_vt_cons(list_vt_cons(e, list_vt_copy<expr>(rest)), tasks_make(es, rest))
)
//
extern
fun
do_one(xs: !task): List0_vt(task)
//
implement
do_one(xs) = let
//
// [yszs] is a list of pairs (a list of two expressions, the rest)
//
fun
auxlst
(yszs: List0_vt(@(task, task))): List0_vt(task) =
(
case+ yszs of
| ~list_vt_nil() => list_vt_nil()
| ~list_vt_cons(@(x1x2, rest), yszs) => let
    val x1 = list_get_at<expr>(x1x2, 0)
    val x2 = list_get_at<expr>(x1x2, 1)
    val es = combine(x1, x2)
    val res = tasks_make(es, rest)
    val () = list_vt_free<expr>(es)
    val () = list_vt_free<expr>(x1x2)
    val () = list_vt_free<expr>(rest)
  in
    list_vt_append<task>(res, auxlst(yszs))
  end // end of [list_vt_cons]
)
//
in
  auxlst(list_nchoose_rest<expr>(xs, 2))
end // end of [do_one]
//
(* ****** ****** *)
//
// all the tasks that are obtained by calling [do_one] on each of the given
// tasks, which are consumed
//
fun
do_one_all
(xss: List0_vt(task)): List0_vt(task) =
(
case+ xss of
| ~list_vt_nil() => list_vt_nil()
| ~list_vt_cons(xs, xss) => let
    val res = do_one(xs)
    val () = list_vt_free<expr>(xs)
  in
    list_vt_append<task>(res, do_one_all(xss))
  end // end of [list_vt_cons]
)
//
extern
fun
do_ones(n: int, xss: List0_vt(task)): List0_vt(task)
//
implement
do_ones(n, xss) =
if n >= 2
  then do_ones(n-1, do_one_all(xss)) else xss
//
(* ****** ****** *)
//
extern
fun
play_game
( n1: int
, n2: int
, n3: int
, n4: int): exprlst
//
implement
play_game
  (n1, n2, n3, n4) = let
//
  val x1 = expr_EXPRnum(int2dbl(n1))
  val x2 = expr_EXPRnum(int2dbl(n2))
  val x3 = expr_EXPRnum(int2dbl(n3))
  val x4 = expr_EXPRnum(int2dbl(n4))
//
  val xs = $list_vt{expr}(x1, x2, x3, x4)
  val xss = do_ones(4, list_vt_cons(xs, list_vt_nil()))
//
  // only the tasks that consist of an expression
  // of the value 24 are kept (the tasks are consumed)
  fun
  auxlst
  (xss: List0_vt(task)): exprlst =
  (
    case+ xss of
    | ~list_vt_nil() => list_vt_nil()
    | ~list_vt_cons(xs, xss) => let
        val-~list_vt_cons(x, xs) = xs
        val () = list_vt_free<expr>(xs)
      in
        if (x = 24)
          then list_vt_cons(x, auxlst(xss)) else auxlst(xss)
      end // end of [list_vt_cons]
  )
//
in
  auxlst(xss)
end // end of [play_game]
//
(* ****** ****** *)

implement
main0() = () where
{
//
val () = println! ("myproof = ", myproof, " = ", eval(myproof))
//
val ps = play_game(10, 10, 4, 4)
val () = println! ("(10,10,4,4) is good: ", list_vt_length<expr>(ps) > 0)
val-~list_vt_cons(p, ps) = ps
val () = println! ("a proof: ", p, " = ", eval(p))
val () = list_vt_free<expr>(ps)
//
val ps = play_game(5, 7, 7, 11)
val () = println! ("(5,7,7,11) is good: ", list_vt_length<expr>(ps) > 0)
val () = list_vt_free<expr>(ps)
//
val ps = play_game(1, 1, 1, 1)
val () = println! ("(1,1,1,1) is good: ", list_vt_length<expr>(ps) > 0)
val () = list_vt_free<expr>(ps)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [game24.dats] *)
