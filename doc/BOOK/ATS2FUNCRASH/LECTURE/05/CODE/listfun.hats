(* ****** ****** *)
(*
** The list functions of LECTURE/05 (the library of the book).
** A list is a linear list, List0_vt(a): there is no garbage
** collector, and so a list has to be freed by its owner. The functions
** below only borrow their list arguments (the symbol [!]) and construct
** a new list as the result: an argument is never changed, which is the
** way functional list-processing works.
*)
(* ****** ****** *)
//
extern
fun
{a:t@ype}
list_length
  {n:nat}(xs: !list_vt(a, n)): int(n)
//
implement
{a}(*tmp*)
list_length(xs) =
(
case+ xs of
| list_vt_nil() => 0
| list_vt_cons(x0, xs1) => 1 + list_length<a>(xs1)
) (* end of [list_length] *)
//
(* ****** ****** *)
//
extern
fun
{a:t@ype}
list_append
  {m,n:nat}
( xs: !list_vt(a, m)
, ys: !list_vt(a, n)): list_vt(a, m+n)
//
implement
{a}(*tmp*)
list_append(xs, ys) =
(
case+ xs of
| list_vt_nil() => list_vt_copy<a>(ys)
| list_vt_cons(x, xs) => list_vt_cons(x, list_append<a>(xs, ys))
) (* end of [list_append] *)
//
(* ****** ****** *)
//
extern
fun
{a:t@ype}
list_revappend
  {m,n:nat}
( xs: !list_vt(a, m)
, ys: list_vt(a, n)): list_vt(a, m+n)
//
extern
fun
{a:t@ype}
list_reverse
  {n:nat}(xs: !list_vt(a, n)): list_vt(a, n)
//
implement
{a}(*tmp*)
list_revappend(xs, ys) =
(
case+ xs of
| list_vt_nil() => ys
| list_vt_cons(x, xs) => list_revappend<a>(xs, list_vt_cons(x, ys))
) (* end of [list_revappend] *)
//
implement
{a}(*tmp*)
list_reverse(xs) = list_revappend<a>(xs, list_vt_nil())
//
(* ****** ****** *)
//
extern
fun
{r:vt@ype}
{a:t@ype}
list_foldleft
( xs: !List0_vt(a)
, r0: r, fopr: &(r, a) -<clo1> r): r
//
implement
{r}{a}
list_foldleft
( xs
, r0, fopr) =
loop(xs, r0, fopr) where
{
fun
loop
(
xs: !List0_vt(a), r0: r, fopr: &(r, a) -<clo1> r
) : r =
(
case+ xs of
| list_vt_nil() => r0
| list_vt_cons(x, xs) => loop(xs, fopr(r0, x), fopr)
) (* end of [loop] *)
}
//
(* ****** ****** *)
//
extern
fun
{a:t@ype}
list_length2(xs: !List0_vt(a)): int
//
implement
{a}(*tmp*)
list_length2(xs) = let
  var fopr = lam@(r: int, _: a): int => r + 1
in
  list_foldleft<int><a>(xs, 0, fopr)
end // end of [list_length2]
//
extern
fun
{a:t@ype}
list_revappend2
(xs: !List0_vt(a), ys: List0_vt(a)): List0_vt(a)
//
implement
{a}(*tmp*)
list_revappend2(xs, ys) = let
  var fopr = lam@(ys: List0_vt(a), x: a): List0_vt(a) => list_vt_cons(x, ys)
in
  list_foldleft<List0_vt(a)><a>(xs, ys, fopr)
end // end of [list_revappend2]
//
(* ****** ****** *)
//
extern
fun
{a:t@ype}
{r:vt@ype}
list_foldright
( xs: !List0_vt(a)
, fopr: &(a, r) -<clo1> r, r0: r): r
//
implement
{a}{r}
list_foldright
( xs
, fopr, r0) =
auxlst(xs, fopr, r0) where
{
fun
auxlst
(
xs: !List0_vt(a), fopr: &(a, r) -<clo1> r, r0: r
) : r =
(
case+ xs of
| list_vt_nil() => r0
| list_vt_cons(x, xs) => fopr(x, auxlst(xs, fopr, r0))
) (* end of [auxlst] *)
}
//
(* ****** ****** *)
//
extern
fun
{a:t@ype}
list_append2
(xs: !List0_vt(a), ys: !List0_vt(a)): List0_vt(a)
//
implement
{a}(*tmp*)
list_append2(xs, ys) = let
  var fopr = lam@(x: a, ys: List0_vt(a)): List0_vt(a) => list_vt_cons(x, ys)
in
  list_foldright<a><List0_vt(a)>(xs, fopr, list_vt_copy<a>(ys))
end // end of [list_append2]
//
(* ****** ****** *)
//
// A list of lists is consumed by the concatenation
//
extern
fun
{a:t@ype}
list_concat(xss: List0_vt(List0_vt(a))): List0_vt(a)
//
implement
{a}(*tmp*)
list_concat(xss) =
(
case+ xss of
| ~list_vt_nil() => list_vt_nil()
| ~list_vt_cons(xs, xss) => list_vt_append<a>(xs, list_concat<a>(xss))
) (* end of [list_concat] *)
//
(* ****** ****** *)
//
// This implementation is correct but it is O(n*n)-time
//
extern
fun
{a:t@ype}
list_reverse2(xs: !List0_vt(a)): List0_vt(a)
//
implement
{a}(*tmp*)
list_reverse2(xs) =
(
case+ xs of
| list_vt_nil() => list_vt_nil()
| list_vt_cons(x, xs) =>
  list_vt_append<a>(list_reverse2<a>(xs), list_vt_cons(x, list_vt_nil()))
)
//
(* ****** ****** *)
//
extern
fun
{a:t@ype}
list_insertion_sort
(
xs: !List0_vt(a), cmp: &(a, a) -<clo1> int
) : List0_vt(a)
//
implement
{a}(*tmp*)
list_insertion_sort
  (xs, cmp) = let
//
fun
insord
( x0: a
, xs: List0_vt(a)
, cmp: &(a, a) -<clo1> int): List0_vt(a) =
(
case+ xs of
| ~list_vt_nil() =>
  list_vt_sing(x0)
| ~list_vt_cons(x1, xs1) =>
  (
    if cmp(x0, x1) < 0
      then list_vt_cons(x0, list_vt_cons(x1, xs1))
      else list_vt_cons(x1, insord(x0, xs1, cmp))
    // end of [if]
  ) // end of [list_vt_cons]
) (* end of [insord] *)
//
fun
loop
( xs: !List0_vt(a)
, res: List0_vt(a)
, cmp: &(a, a) -<clo1> int): List0_vt(a) =
(
case+ xs of
| list_vt_nil() => res
| list_vt_cons(x, xs) => loop(xs, insord(x, res, cmp), cmp)
) (* end of [loop] *)
//
in
//
loop(xs, list_vt_nil(), cmp)
//
end // end of [list_insertion_sort]
//
(* ****** ****** *)

(* end of [listfun.hats] *)
