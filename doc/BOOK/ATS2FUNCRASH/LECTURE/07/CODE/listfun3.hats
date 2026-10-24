(* ****** ****** *)
(*
** The list functions of LECTURE/07 (the library of the book).
** The lists are linear (see LECTURE/05 and LECTURE/06).
*)
(* ****** ****** *)
//
extern
fun
{a,b:t@ype}
list_zip
  {m,n:nat}
( xs: !list_vt(a, m)
, ys: !list_vt(b, n)): List0_vt(@(a, b))
//
implement
{a,b}(*tmp*)
list_zip(xs, ys) =
(
case+ xs of
| list_vt_nil() =>
  list_vt_nil()
| list_vt_cons(x, xs) =>
  (
    case+ ys of
    | list_vt_nil() =>
      list_vt_nil()
    | list_vt_cons(y, ys) =>
      list_vt_cons(@(x, y), list_zip<a,b>(xs, ys))
  )
)
//
(* ****** ****** *)
//
extern
fun {
a,b:t@ype}{c:t@ype
} list_map2
( xs: !List0_vt(a)
, ys: !List0_vt(b)
, fopr: &(a, b) -<clo1> c): List0_vt(c)
//
implement
{a,b}{c}
list_map2
(xs, ys, fopr) =
(
case+ xs of
| list_vt_nil() =>
  list_vt_nil()
| list_vt_cons(x, xs) =>
  (
    case+ ys of
    | list_vt_nil() =>
      list_vt_nil()
    | list_vt_cons(y, ys) =>
      list_vt_cons(fopr(x, y), list_map2<a,b><c>(xs, ys, fopr))
  ) (* end of [list_vt_cons] *)
)
//
(* ****** ****** *)
//
extern
fun
{a:t@ype}
list_merge
  {m,n:nat}
( xs: !list_vt(a, m)
, ys: !list_vt(a, n)
, cmp: &(a, a) -<clo1> int): list_vt(a, m+n)
//
implement
{a}(*tmp*)
list_merge
(xs0, ys0, cmp) = let
//
fun
auxlst
{m,n:nat}
( xs0: !list_vt(a, m)
, ys0: !list_vt(a, n)
, cmp: &(a, a) -<clo1> int
) : list_vt(a, m+n) = (
//
case+ xs0 of
| list_vt_nil() => list_vt_copy<a>(ys0)
| list_vt_cons
    (x1, xs1) => (
    case+ ys0 of
    | list_vt_nil() => list_vt_copy<a>(xs0)
    | list_vt_cons
        (y1, ys1) => let
        val sgn = cmp(x1, y1)
      in
        if (sgn <= 0)
          then list_vt_cons(x1, auxlst(xs1, ys0, cmp))
          else list_vt_cons(y1, auxlst(xs0, ys1, cmp))
        // end of [if]
      end // end of [list_vt_cons]
  ) (* end of [list_vt_cons] *)
//
) (* end of [auxlst] *)
//
in
  auxlst(xs0, ys0, cmp)
end // end of [list_merge]
//
(* ****** ****** *)
//
extern
fun
{a:t@ype}
list_take
  {n,k:nat | k <= n}
(xs: !list_vt(a, n), k: int(k)): list_vt(a, k)
//
extern
fun
{a:t@ype}
list_drop
  {n,k:nat | k <= n}
(xs: !list_vt(a, n), k: int(k)): list_vt(a, n-k)
//
implement
{a}(*tmp*)
list_take(xs, k) =
(
if k > 0
  then let
    val+list_vt_cons(x, xs) = xs
  in
    list_vt_cons(x, list_take<a>(xs, k-1))
  end
  else list_vt_nil()
)
//
implement
{a}(*tmp*)
list_drop(xs, k) =
(
if k > 0
  then let
    val+list_vt_cons(_, xs) = xs
  in
    list_drop<a>(xs, k-1)
  end
  else list_vt_copy<a>(xs)
)
//
(* ****** ****** *)
//
extern
fun
{a:t@ype}
list_mergesort
(xs: !List0_vt(a), cmp: &(a, a) -<clo1> int): List0_vt(a)
//
implement
{a}(*tmp*)
list_mergesort
  (xs, cmp) = let
//
// [msort]:
// the second argument is the length of the first one
//
fun
msort
{n:nat}
( xs: !list_vt(a, n)
, n: int(n)
, cmp: &(a, a) -<clo1> int): list_vt(a, n) =
if
(n >= 2)
then let
  val n1 = n / 2
  val xs1 = list_take<a>(xs, n1)
  val xs2 = list_drop<a>(xs, n1)
  val ys1 = msort(xs1, n1, cmp)
  val ys2 = msort(xs2, n-n1, cmp)
  val res = list_merge<a>(ys1, ys2, cmp)
  val () = list_vt_free<a>(xs1)
  val () = list_vt_free<a>(xs2)
  val () = list_vt_free<a>(ys1)
  val () = list_vt_free<a>(ys2)
in
  res
end // end of [then]
else list_vt_copy<a>(xs) // end of [else]
//
in
  msort(xs, list_length<a>(xs), cmp)
end // end of [list_mergesort]
//
(* ****** ****** *)
//
extern
fun
{a:t@ype}
list_choose2
(xs: !List0_vt(a)): List0_vt(@(a, a))
//
implement
{a}(*tmp*)
list_choose2
  (xs) = let
//
typedef aa = @(a, a)
//
in
//
case+ xs of
| list_vt_nil() =>
  list_vt_nil()
| list_vt_cons(x0, xs) => let
    var fopr = lam@(x: a): aa => @(x0, x)
    val res1 = list_map<a><aa>(xs, fopr)
    val res2 = list_choose2<a>(xs)
  in
    list_vt_append<aa>(res1, res2)
  end // end of [list_vt_cons]
//
end // end of [list_choose2]
//
(* ****** ****** *)
//
// A list of lists is linear and it is freed (or consumed) as a whole
//
fun
{a:t@ype}
lists_free
(xss: List0_vt(List0_vt(a))): void =
(
case+ xss of
| ~list_vt_nil() => ()
| ~list_vt_cons(xs, xss) => (list_vt_free<a>(xs); lists_free<a>(xss))
)
//
// [list_mapcons] consumes its second argument:
// the first argument is added to the front of each list in it
//
extern
fun
{a:t@ype}
list_mapcons
(x0: a, xss: List0_vt(List0_vt(a))): List0_vt(List0_vt(a))
//
implement
{a}(*tmp*)
list_mapcons(x0, xss) =
(
case+ xss of
| ~list_vt_nil() => list_vt_nil()
| ~list_vt_cons(xs, xss) =>
  list_vt_cons(list_vt_cons(x0, xs), list_mapcons<a>(x0, xss))
)
//
(* ****** ****** *)
//
extern
fun
{a:t@ype}
list_nchoose
(xs: !List0_vt(a), n: int): List0_vt(List0_vt(a))
//
implement
{a}(*tmp*)
list_nchoose
  (xs, n) =
  auxlst(xs, n) where
{
//
vtypedef xs = List0_vt(a)
//
fun
auxlst
(
xs: !xs, n: int
) : List0_vt(xs) =
(
if
(n <= 0)
then
list_vt_sing(list_vt_nil())
else
(
case+ xs of
| list_vt_nil() => list_vt_nil()
| list_vt_cons(x0, xs) =>
  list_vt_append<xs>(list_mapcons<a>(x0, auxlst(xs, n-1)), auxlst(xs, n))
) (* end of [else] *)
)
//
} (* end of [list_nchoose] *)
//
(* ****** ****** *)
//
// [list_nchoose_rest] is a generalization of [list_nchoose]:
// the pairs are flat tuples, which consist of two linear lists
//
extern
fun
{a:t@ype}
list_nchoose_rest
(xs: !List0_vt(a), n: int): List0_vt(@(List0_vt(a), List0_vt(a)))
//
implement
{a}(*tmp*)
list_nchoose_rest
  (xs, n) =
  auxlst(xs, n) where
{
//
vtypedef xs = List0_vt(a)
vtypedef xsxs = @(xs, xs)
//
// the first component of each pair of a list is extended
//
fun
cons1
(x0: a, res: List0_vt(xsxs)): List0_vt(xsxs) =
(
case+ res of
| ~list_vt_nil() => list_vt_nil()
| ~list_vt_cons(@(xs1, xs2), res) =>
  list_vt_cons(@(list_vt_cons(x0, xs1), xs2), cons1(x0, res))
)
//
// the second component of each pair of a list is extended
//
fun
cons2
(x0: a, res: List0_vt(xsxs)): List0_vt(xsxs) =
(
case+ res of
| ~list_vt_nil() => list_vt_nil()
| ~list_vt_cons(@(xs1, xs2), res) =>
  list_vt_cons(@(xs1, list_vt_cons(x0, xs2)), cons2(x0, res))
)
//
fun
auxlst
(
xs: !xs, n: int
) : List0_vt(xsxs) =
(
if
(n <= 0)
then
list_vt_cons(@(list_vt_nil(), list_vt_copy<a>(xs)), list_vt_nil())
else
(
case+ xs of
| list_vt_nil() => list_vt_nil()
| list_vt_cons(x0, xs) => let
    val res1 = cons1(x0, auxlst(xs, n-1))
    val res2 = cons2(x0, auxlst(xs, n-0))
  in
    list_vt_append<xsxs>(res1, res2)
  end // end of [list_vt_cons]
) (* end of [else] *)
)
//
} (* end of [list_nchoose_rest] *)
//
(* ****** ****** *)
//
extern
fun
{a:t@ype}
list_permute
(xs: !List0_vt(a)): List0_vt(List0_vt(a))
//
implement
{a}(*tmp*)
list_permute
  (xs) = (
case+ xs of
| list_vt_nil() =>
  list_vt_sing(list_vt_nil())
| list_vt_cons _ => let
    vtypedef xs = List0_vt(a)
    vtypedef xsxs = @(xs, xs)
//
    fun
    auxlst
    (yszs: List0_vt(xsxs)): List0_vt(xs) =
    (
      case+ yszs of
      | ~list_vt_nil() => list_vt_nil()
      | ~list_vt_cons(@(ys, zs), yszs) => let
          val-~list_vt_cons(y, ys) = ys
          val () = list_vt_free<a>(ys)
          val res = list_mapcons<a>(y, list_permute<a>(zs))
          val () = list_vt_free<a>(zs)
        in
          list_vt_append<xs>(res, auxlst(yszs))
        end // end of [list_vt_cons]
    ) (* end of [auxlst] *)
//
  in
    auxlst(list_nchoose_rest<a>(xs, 1))
  end (* end of [list_vt_cons] *)
)
//
(* ****** ****** *)

(* end of [listfun3.hats] *)
