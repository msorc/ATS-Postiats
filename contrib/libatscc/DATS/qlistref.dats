(* ****** ****** *)
(*
** libatscc-common
*)
(* ****** ****** *)

(*
staload "./../SATS/qlistref.sats"
staload UN = "prelude/SATS/unsafe.sats"
*)

(* ****** ****** *)
//
// HX-2026-10: no GC
// The lists are linear: they are taken out of
// the references (by exchange) and put back in.
//
(* ****** ****** *)

//
// HX-2026-10:
// a queue: @(front, back) where the back is reversed
//
vtypedef
qrep(a:vt0p) = @(List0_vt(a), List0_vt(a))
//
assume
qlistref_type(a:vt0p) = ref(qrep(a))

(* ****** ****** *)

implement
qlistref_make_nil
  {a}((*void*)) =
  ref{qrep(a)}(@(list_vt_nil(), list_vt_nil()))

(* ****** ****** *)
//
extern
fun
qlistref_takeout
  {a:vt0p}(que: qlistref(a)): qrep(a)
extern
fun
qlistref_putback
  {a:vt0p}(que: qlistref(a), q: qrep(a)): void
//
implement
qlistref_takeout
  {a}(que) =
  ref_exch_elt{qrep(a)}(que, @(list_vt_nil(), list_vt_nil()))
//
implement
qlistref_putback
  {a}(que, q) = let
  val @(f0, b0) = ref_exch_elt{qrep(a)}(que, q)
  val-~list_vt_nil() = f0
  val-~list_vt_nil() = b0
in
  // nothing
end // end of [qlistref_putback]
//
(* ****** ****** *)

implement
qlistref_length
  {a}(que) = let
  val @(f, b) = qlistref_takeout{a}(que)
  val n = list_vt_length(f) + list_vt_length(b)
in
  qlistref_putback{a}(que, @(f, b)); n
end // end of [qlistref_length]

(* ****** ****** *)

implement
qlistref_enqueue
  {a}(que, x0) = let
  val @(f, b) = qlistref_takeout{a}(que)
in
  qlistref_putback{a}(que, @(f, list_vt_cons(x0, b)))
end // end of [qlistref_enqueue]

(* ****** ****** *)

implement
qlistref_dequeue_opt
  {a}(que) = let
//
val @(f, b) = qlistref_takeout{a}(que)
//
val @(f, b) =
(
  case+ f of
  | list_vt_cons _ => @(f, b)
  | ~list_vt_nil() => @(list_vt_reverse(b), list_vt_nil())
) : @(List0_vt(a), List0_vt(a))
//
in
//
case+ f of
| ~list_vt_nil() =>
  (
    qlistref_putback{a}(que, @(list_vt_nil(), b)); None_vt()
  )
| ~list_vt_cons(x0, f) =>
  (
    qlistref_putback{a}(que, @(f, b)); Some_vt(x0)
  )
//
end // end of [qlistref_dequeue_opt]

implement
qlistref_dequeue_exn
  {a}(que) = let
  val-~Some_vt(x0) = qlistref_dequeue_opt{a}(que) in x0
end // end of [qlistref_dequeue_exn]

(* ****** ****** *)

implement
qlistref_foldleft
  {res}{a}
  (que, init, fopr) = let
//
fun
auxl
{n:int}
(
  res: res, xs: !list_vt(a, n)
, fopr: !(res, a) -<cloptr1> res
) : res =
(
case+ xs of
| list_vt_nil() => res
| list_vt_cons(x, xs1) =>
    let val r = fopr(res, x) in auxl(r, xs1, fopr) end
)
//
fun
auxr
{n:int}
(
  xs: !list_vt(a, n), res: res
, fopr: !(res, a) -<cloptr1> res
) : res =
(
case+ xs of
| list_vt_nil() => res
| list_vt_cons(x, xs1) =>
    let val r = auxr(xs1, res, fopr) in fopr(r, x) end
)
//
val @(f, b) = qlistref_takeout{a}(que)
val res = auxl(init, f, fopr)
val res = auxr(b, res, fopr)
//
in
  qlistref_putback{a}(que, @(f, b)); cfun_free(fopr); res
end // end of [qlistref_foldleft]

(* ****** ****** *)

implement
qlistref_foldright
  {a}{res}
  (que, fopr, sink) = let
//
fun
auxl
{n:int}
(
  res: res, xs: !list_vt(a, n)
, fopr: !(a, res) -<cloptr1> res
) : res =
(
case+ xs of
| list_vt_nil() => res
| list_vt_cons(x, xs1) =>
    let val r = fopr(x, res) in auxl(r, xs1, fopr) end
)
//
fun
auxr
{n:int}
(
  xs: !list_vt(a, n), res: res
, fopr: !(a, res) -<cloptr1> res
) : res =
(
case+ xs of
| list_vt_nil() => res
| list_vt_cons(x, xs1) =>
    let val r = auxr(xs1, res, fopr) in fopr(x, r) end
)
//
val @(f, b) = qlistref_takeout{a}(que)
val res = auxl(sink, b, fopr)
val res = auxr(f, res, fopr)
//
in
  qlistref_putback{a}(que, @(f, b)); cfun_free(fopr); res
end // end of [qlistref_foldright]

(* ****** ****** *)

(* end of [qlistref.dats] *)
