(* ****** ****** *)
(*
** The list functions of LECTURE/06 (the library of the book).
** The lists are linear (see LECTURE/05): the functions borrow their
** list arguments and construct new lists.
*)
(* ****** ****** *)
//
exception ListSubscriptExn of ()
//
(* ****** ****** *)
//
extern
fun
{a:t@ype}
list_head(xs: !List0_vt(a)): a
//
implement
{a}(*tmp*)
list_head(xs) =
(
case+ xs of
| list_vt_cons(x, _) => x
| _(* list_vt_nil() *) => $raise ListSubscriptExn()
)
//
(* ****** ****** *)
//
extern
fun
{a:t@ype}
list_head_opt
  (xs: !List0_vt(a)): Option_vt(a)
//
implement
{a}(*tmp*)
list_head_opt(xs) =
(
case+ xs of list_vt_cons(x, _) => Some_vt(x) | _ => None_vt()
)
//
(* ****** ****** *)
//
extern
fun
{a:t@ype}
list_last_opt
  (xs: !List0_vt(a)): Option_vt(a)
//
implement
{a}(*tmp*)
list_last_opt(xs) = let
//
fun
loop
(x0: a, xs: !List0_vt(a)): a =
(
case+ xs of
| list_vt_nil() => x0
| list_vt_cons(x1, xs) => loop(x1, xs)
)
//
in
//
case+ xs of
| list_vt_nil() => None_vt()
| list_vt_cons(x, xs) => Some_vt(loop(x, xs))
//
end // end of [list_last_opt]
//
(* ****** ****** *)
//
extern
fun
{a:t@ype}
list_get_at
(xs: !List0_vt(a), n: int): a
//
implement
{a}(*tmp*)
list_get_at
  (xs, n) =
(
case+ xs of
| list_vt_nil() =>
  $raise ListSubscriptExn()
| list_vt_cons(x, xs) =>
  if n <= 0 then x else list_get_at<a>(xs, n-1)
)
//
(* ****** ****** *)
//
fun
list_tally1
  (xs: !List0_vt(int)): int = let
  var fopr = lam@(res: int, x: int): int => res + x
in
  list_foldleft<int><int>(xs, 0, fopr)
end // end of [list_tally1]
//
fun
list_tally2
  (xs: !List0_vt(int)): int = let
//
fun
loop
(xs: !List0_vt(int), i: int, n: int, res: int): int =
  if i < n then loop(xs, i+1, n, res + list_get_at<int>(xs, i)) else res
//
in
  loop(xs, 0, list_length<int>(xs), 0)
end // end of [list_tally2]
//
(* ****** ****** *)
//
extern
fun
{a:t@ype}
{b:t@ype}
list_map
(xs: !List0_vt(a), fopr: &(a) -<clo1> b): List0_vt(b)
//
implement
{a}{b}
list_map
(
  xs, fopr
) = auxlst(xs, fopr) where
{
//
fun
auxlst
(xs: !List0_vt(a), fopr: &(a) -<clo1> b): List0_vt(b) =
(
case+ xs of
| list_vt_nil() => list_vt_nil()
| list_vt_cons(x, xs) => list_vt_cons(fopr(x), auxlst(xs, fopr))
)
//
} (* end of [list_map] *)
//
(* ****** ****** *)
//
extern
fun
{a,b:t@ype}
list_cross
(xs: !List0_vt(a), ys: !List0_vt(b)): List0_vt(@(a, b))
//
implement
{a,b}(*tmp*)
list_cross
  (xs, ys) = let
//
typedef ab = @(a, b)
//
in
//
case+ xs of
| list_vt_nil() => list_vt_nil()
| list_vt_cons(x, xs) => let
    var fopr = lam@(y: b): ab => @(x, y)
    val res1 = list_map<b><ab>(ys, fopr)
    val res2 = list_cross<a,b>(xs, ys)
  in
    list_vt_append<ab>(res1, res2)
  end // end of [list_vt_cons]
//
end // end of [list_cross]
//
(* ****** ****** *)
//
extern
fun
{a:t@ype}
list_foreach
(xs: !List0_vt(a), fwork: &(a) -<clo1> void): void
//
implement
{a}(*tmp*)
list_foreach
(
  xs, fwork
) = loop(xs, fwork) where
{
//
fun
loop
(xs: !List0_vt(a), fwork: &(a) -<clo1> void): void =
(
case+ xs of
| list_vt_nil() => ()
| list_vt_cons(x, xs) => (fwork(x); loop(xs, fwork))
)
//
} (* end of [list_foreach] *)
//
(* ****** ****** *)
//
extern
fun
{a:t@ype}
list_filter
(xs: !List0_vt(a), test: &(a) -<clo1> bool): List0_vt(a)
//
implement
{a}(*tmp*)
list_filter
(
  xs, test
) = auxlst(xs, test) where
{
//
fun
auxlst
(xs: !List0_vt(a), test: &(a) -<clo1> bool): List0_vt(a) =
(
case+ xs of
| list_vt_nil() =>
  list_vt_nil()
| list_vt_cons(x, xs) =>
  if test(x)
    then list_vt_cons(x, auxlst(xs, test)) else auxlst(xs, test)
  // end of [if]
)
//
} (* end of [list_filter] *)
//
(* ****** ****** *)
//
// [eqfn] is an envless function (it is captured by a closure)
//
extern
fun
{a:t@ype}
list_remdup
(xs: !List0_vt(a), eqfn: (a, a) -> bool): List0_vt(a)
//
implement
{a}(*tmp*)
list_remdup(xs, eqfn) =
(
case+ xs of
| list_vt_nil() =>
  list_vt_nil()
| list_vt_cons(x0, xs) => let
    var test = lam@(x: a): bool => ~eqfn(x0, x)
    val ys = list_filter<a>(xs, test)
    val zs = list_remdup<a>(ys, eqfn)
    val () = list_vt_free<a>(ys)
  in
    list_vt_cons(x0, zs)
  end // end of [list_vt_cons]
)
//
(* ****** ****** *)
//
extern
fun
{a:t@ype}
list_find_index
(xs: !List0_vt(a), test: &(a) -<clo1> bool): int
//
implement
{a}(*tmp*)
list_find_index
  (xs, test) = let
//
fun
loop
(xs: !List0_vt(a), i: int, test: &(a) -<clo1> bool): int =
(
case+ xs of
| list_vt_nil() => ~1
| list_vt_cons(x, xs) =>
  if test(x) then i else loop(xs, i+1, test)
)
//
in
  loop(xs, 0, test)
end // end of [list_find_index]
//
(* ****** ****** *)
//
extern
fun
{a:t@ype}
list_exists
(xs: !List0_vt(a), test: &(a) -<clo1> bool): bool
extern
fun
{a:t@ype}
list_forall
(xs: !List0_vt(a), test: &(a) -<clo1> bool): bool
//
implement
{a}(*tmp*)
list_exists(xs, test) =
list_find_index<a>(xs, test) >= 0
implement
{a}(*tmp*)
list_forall(xs, test) =
(
case+ xs of
| list_vt_nil() => true
| list_vt_cons(x, xs) => test(x) && list_forall<a>(xs, test)
)
//
(* ****** ****** *)
//
extern
fun
{a:t@ype}
{b:t@ype}
list_imap
(xs: !List0_vt(a), fopr: &(int, a) -<clo1> b): List0_vt(b)
//
implement
{a}{b}
list_imap
(
  xs, fopr
) = auxlst(0, xs, fopr) where
{
//
fun
auxlst
(i: int, xs: !List0_vt(a), fopr: &(int, a) -<clo1> b): List0_vt(b) =
(
case+ xs of
| list_vt_nil() => list_vt_nil()
| list_vt_cons(x, xs) => list_vt_cons(fopr(i, x), auxlst(i+1, xs, fopr))
)
//
} (* end of [list_imap] *)
//
(* ****** ****** *)
//
extern
fun
{a:t@ype}
list_iforall
(xs: !List0_vt(a), test: &(int, a) -<clo1> bool): bool
//
implement
{a}(*tmp*)
list_iforall(xs, test) = loop(0, xs, test) where
{
//
fun
loop
(i: int, xs: !List0_vt(a), test: &(int, a) -<clo1> bool): bool =
(
case+ xs of
| list_vt_nil() => true
| list_vt_cons(x, xs) => test(i, x) && loop(i+1, xs, test)
)
//
} (* end of [list_iforall] *)
//
(* ****** ****** *)

(* end of [listfun2.hats] *)
