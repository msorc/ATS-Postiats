(* ****** ****** *)

(*
** libatscc-common
*)

(* ****** ****** *)

(*
//
staload "./../SATS/stream.sats"
//
staload UN = "prelude/SATS/unsafe.sats"
//
*)

(* ****** ****** *)
//
implement
{}(*tmp*)
stream_vt_make_nil() =
$ldelay(stream_vt_nil())
//
(* ****** ****** *)
//
implement
{}(*tmp*)
stream_vt_make_cons(x, xs) =
$ldelay(
  stream_vt_cons(x, xs), $effmask_wrt(~xs)
)(*$ldelay*)
//
(* ****** ****** *)
//
implement
{}(*tmp*)
stream_vt_sing(x0) =
stream_vt_cons(x0, stream_vt_make_nil())
//
implement
{}(*tmp*)
stream_vt_make_sing(x0) =
$ldelay
(
  stream_vt_cons(x0, stream_vt_make_nil())
) (* $ldelay *)
//
(* ****** ****** *)
//
implement
stream_vt_free{a}(xs) = ~(xs)
//
(* ****** ****** *)

implement
stream_vt_takeLte
  {a}(xs, n0) =
(
$effmask_all
(auxmain(xs, n0)) where
{
//
fun
auxmain
(
xs: stream_vt(a), n0: Nat
) : stream_vt(a) = $ldelay
(
//
if
(n0 > 0)
then
(
case+ !xs of
| ~stream_vt_nil() =>
    stream_vt_nil()
| ~stream_vt_cons(x, xs) =>
    stream_vt_cons(x, auxmain(xs, n0-1))
)
else
(
  ~(xs); stream_vt_nil()
)
,
~(xs) // HX: called for freeing the stream!
//
) (* [$ldelay] *)
//
} (* end of [where] *)
) (* end of [stream_vt_takeLte] *)

(* ****** ****** *)

implement
stream_vt_length
  {a}(xs) =
  loop(xs, 0) where
{
//
fun
loop
(
xs: stream_vt(a), len: intGte(0)
) : intGte(0) =
(
case+ !xs of
| ~stream_vt_nil() => len
| ~stream_vt_cons(_, xs) => loop(xs, len+1)
) (* end of [loop] *)
//
} (* end of [stream_vt_length] *)

(* ****** ****** *)
//
implement
stream2list_vt
  {a}(xs) =
  aux(xs) where
{
//
fun
aux
(xs: stream_vt(a)): List0_vt(a) =
(
case+ !xs of
| ~stream_vt_nil() => list_vt_nil()
| ~stream_vt_cons(x, xs) => list_vt_cons(x, aux(xs))
)
//
}
//
implement
stream2list_vt_rev
  {a}(xs) =
  loop(xs, nil_vt()) where
{
//
fun
loop
(
xs: stream_vt(a), res: List0_vt(a)
) : List0_vt(a) =
(
case+ !xs of
| ~stream_vt_nil() => res
| ~stream_vt_cons(x, xs) => loop(xs, cons_vt(x, res))
) (* end of [loop] *)
//
} (* end of [stream2list_vt_rev] *)

(* ****** ****** *)

implement
stream_vt_append
  {a}
(
  xs, ys
) =
$effmask_all
(auxmain(xs, ys)) where
{
//
fun
auxmain
(
  xs: stream_vt(a)
, ys: stream_vt(a)
) : stream_vt(a) = $ldelay
(
(
  case+ !xs of
  | ~stream_vt_nil() => !ys
  | ~stream_vt_cons(x, xs) =>
      stream_vt_cons(x, auxmain(xs, ys))
    // end of [stream_vt_cons]
) : stream_vt_con(a)
, (~(xs); ~(ys)) // HX: for freeing the stream!
) (* end of [auxmain] *)
//
} (* end of [stream_vt_append] *)

(* ****** ****** *)

implement
stream_vt_concat
  {a}(xss) = let
//
fun
auxmain
(
  xss: stream_vt(stream_vt(a))
) : stream_vt(a) = $ldelay
(
//
case+ !xss of
| ~stream_vt_nil
    ((*void*)) => stream_vt_nil()
| ~stream_vt_cons
    (xs, xss) => !(stream_vt_append(xs, auxmain(xss)))
//
,
~(xss) // HX: called for freeing the stream!
) (* end of [auxmain] *)
//
in
  $effmask_all(auxmain(xss))
end (* end of [stream_vt_concat] *)

(* ****** ****** *)
//
//
// HX-2026-10: no GC
// The closure is passed along the stream and freed when the
// stream is exhausted or freed.
//
implement
stream_vt_map_cloptr
  {a}{b}
(
  xs, f0
) =
  auxmain(xs, f0) where
{
//
fun
auxmain
(
  xs: stream_vt(a), f0: (a) -<cloptr1> b
) : stream_vt(b) = $ldelay
(
(
case+ !xs of
| ~stream_vt_nil() =>
    (cfun_free(f0); stream_vt_nil())
| ~stream_vt_cons(x, xs) => let
    val y = f0(x)
  in
    stream_vt_cons(y, auxmain(xs, f0))
  end // end of [stream_vt_cons]
) : stream_vt_con(b)
,
(~(xs); cfun_free(f0)) // called when the stream is freed
) (* end of [auxmain] *)
//
} (* end of [stream_vt_map_cloptr] *)

(* ****** ****** *)

implement
stream_vt_filter_cloptr
  {a}(xs, p0) =
  auxmain(xs, p0) where
{
//
fun
auxmain
(
  xs: stream_vt(a), p0: (a) -<cloptr1> bool
) : stream_vt(a) = $ldelay
(
  auxcon(xs, p0)
,
(~(xs); cfun_free(p0)) // called when the stream is freed
) (* end of auxmain *)
//
and
auxcon
(
  xs: stream_vt(a), p0: (a) -<cloptr1> bool
) : stream_vt_con(a) =
(
case+ !xs of
| ~stream_vt_nil
    ((*_*)) => (cfun_free(p0); stream_vt_nil())
  // end of [stream_vt_nil]
| ~stream_vt_cons
    (x, xs1) =>
  (
    if p0(x)
      then stream_vt_cons(x, auxmain(xs1, p0))
      else auxcon(xs1, p0)
    // end of [if]
  ) (* end of [stream_vt_cons] *)
) (* end of [auxcon] *)
//
} (* end of [stream_vt_filter_cloptr] *)

(* ****** ****** *)

implement
stream_vt_exists_cloptr
  {a}(xs, pred) = let
//
fun
loop
(
  xs: stream_vt(a), pred: !(a) -<cloptr1> bool
) : bool =
(
  case+ !xs of
  | ~stream_vt_nil() => false
  | ~stream_vt_cons(x, xs) =>
      if pred(x) then (~xs; true) else loop(xs, pred)
    // stream_vt_cons
)
//
val ans = loop(xs, pred)
//
in
  cfun_free(pred); ans
end // end of [stream_vt_exists_cloptr]

(* ****** ****** *)

implement
stream_vt_forall_cloptr
  {a}(xs, pred) = let
//
fun
loop
(
  xs: stream_vt(a), pred: !(a) -<cloptr1> bool
) : bool =
(
  case+ !xs of
  | ~stream_vt_nil() => true
  | ~stream_vt_cons(x, xs) =>
      if pred(x) then loop(xs, pred) else (~xs; false)
    // stream_vt_cons
)
//
val ans = loop(xs, pred)
//
in
  cfun_free(pred); ans
end // end of [stream_vt_forall_cloptr]

(* ****** ****** *)

implement
stream_vt_foreach_cloptr
  {a}(*poly*)
  (xs, fwork) = let
//
fun
loop
(
  xs: stream_vt(a), fwork: !(a) -<cloptr1> void
) : void =
(
case+ !xs of
| ~stream_vt_nil() => ()
| ~stream_vt_cons(x, xs) =>
    (fwork(x); loop(xs, fwork))
)
//
val () = loop(xs, fwork)
//
in
  cfun_free(fwork)
end // end of [stream_vt_foreach_cloptr]

(* ****** ****** *)

implement
stream_vt_iforeach_cloptr
  {a}(*poly*)
  (xs, fwork) = let
//
fun
loop
(
  i: Nat, xs: stream_vt(a), fwork: !(Nat, a) -<cloptr1> void
) : void =
(
case+ !xs of
| ~stream_vt_nil() => ()
| ~stream_vt_cons(x, xs) =>
    (fwork(i, x); loop(i+1, xs, fwork))
)
//
val () = loop(0, xs, fwork)
//
in
  cfun_free(fwork)
end // end of [stream_vt_iforeach_cloptr]

(* ****** ****** *)

implement
stream_vt_rforeach_cloptr
  {a}(*poly*)
  (xs, fwork) = let
//
fun
auxmain
(
  xs: stream_vt(a), fwork: !(a) -<cloptr1> void
) : void =
(
case+ !xs of
| ~stream_vt_nil() => ()
| ~stream_vt_cons(x, xs) =>
    (auxmain(xs, fwork); fwork(x))
)
//
val () = auxmain(xs, fwork)
//
in
  cfun_free(fwork)
end // end of [stream_vt_rforeach_cloptr]

(* ****** ****** *)

implement
stream_vt_tabulate_cloptr
  {a}(fopr) = auxmain(0, fopr) where
{
//
fun
auxmain
(
  n0: intGte(0), fopr: intGte(0) -<cloptr1> a
) : stream_vt(a) =
$ldelay
(
let
  val x = fopr(n0) in stream_vt_cons(x, auxmain(n0+1, fopr))
end
,
cfun_free(fopr) // called when the stream is freed
) (* end of [auxmain] *)
//
} (* end of [stream_tabulate_cloptr] *)

(* ****** ****** *)

(* end of [stream_vt.dats] *)
