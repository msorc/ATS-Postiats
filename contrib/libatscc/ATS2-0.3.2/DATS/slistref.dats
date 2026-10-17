(* ****** ****** *)
(*
** libatscc-common
*)
(* ****** ****** *)

(*
staload "./../SATS/slistref.sats"
staload UN = "prelude/SATS/unsafe.sats"
*)

(* ****** ****** *)
//
// HX-2026-10: no GC
// The lists are linear: they are taken out of
// the references (by exchange) and put back in.
//
(* ****** ****** *)

assume
slistref_type
  (a:vt0p) = ref(List0_vt(a))

(* ****** ****** *)

implement
slistref_make_nil
  {a}((*void*)) =
  ref{List0_vt(a)}(list_vt_nil((*void*)))

(* ****** ****** *)

implement
slistref_length
  {a}(r0) = let
//
val xs =
  ref_exch_elt{List0_vt(a)}(r0, list_vt_nil())
val n0 = list_vt_length(xs)
val-~list_vt_nil() = ref_exch_elt{List0_vt(a)}(r0, xs)
//
in
  n0
end // end of [slistref_length]

(* ****** ****** *)

implement
slistref_push
  {a}(r0, x0) = let
//
val xs =
  ref_exch_elt{List0_vt(a)}(r0, list_vt_nil())
//
in
  let
    val-~list_vt_nil() =
      ref_exch_elt{List0_vt(a)}(r0, list_vt_cons(x0, xs))
    // end of [val]
  in
    // nothing
  end
end // end of [slistref_push]

(* ****** ****** *)

implement
slistref_pop_opt
  {a}(r0) = let
//
val xs =
  ref_exch_elt{List0_vt(a)}(r0, list_vt_nil())
//
in
//
case+ xs of
| ~list_vt_nil() => None_vt(*void*)
| ~list_vt_cons(x0, xs) => let
    val-~list_vt_nil() = ref_exch_elt{List0_vt(a)}(r0, xs) in Some_vt(x0)
  end // end of [list_vt_cons]
//
end // end of [slistref_pop_opt]

implement
slistref_pop_exn
  {a}(r0) = let
  val-~Some_vt(x0) = slistref_pop_opt{a}(r0) in x0
end // end of [slistref_pop_exn]

(* ****** ****** *)

implement
slistref_foldleft
  {res}{a}
  (r0, init, fopr) = let
//
fun
loop
{n:int}
(
  xs: !list_vt(a, n), res: res
, fopr: !(res, a) -<cloptr1> res
) : res =
(
case+ xs of
| list_vt_nil() => res
| list_vt_cons(x, xs1) =>
    let val r = fopr(res, x) in loop(xs1, r, fopr) end
)
//
val xs =
  ref_exch_elt{List0_vt(a)}(r0, list_vt_nil())
val res = loop(xs, init, fopr)
val-~list_vt_nil() = ref_exch_elt{List0_vt(a)}(r0, xs)
//
in
  cfun_free(fopr); res
end // end of [slistref_foldleft]

(* ****** ****** *)

implement
slistref_foldright
  {a}{res}
  (r0, fopr, sink) = let
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
val xs =
  ref_exch_elt{List0_vt(a)}(r0, list_vt_nil())
val res = auxr(xs, sink, fopr)
val-~list_vt_nil() = ref_exch_elt{List0_vt(a)}(r0, xs)
//
in
  cfun_free(fopr); res
end // end of [slistref_foldright]

(* ****** ****** *)

(* end of [slistref.dats] *)
