(* ****** ****** *)
(*
** libatscc-common
*)
(* ****** ****** *)

(*
staload "./../basics.sats"
staload "./../SATS/intrange.sats"
*)

(* ****** ****** *)
//
// HX-2026-10: no GC
// The closures are linear: they are borrowed by
// the loops and freed once the loops are done.
//
(* ****** ****** *)

implement
int_repeat_cloptr
  (n0, fwork) = let
//
fun
loop
(
  n: int, fwork: !cfun0(void)
) : void = (
//
if n > 0
  then (fwork(); loop(n-1, fwork)) else ()
//
) (* end of [loop] *)
//
val () = loop (n0, fwork)
//
in
  cfun_free(fwork)
end // end of [int_repeat_cloptr]

(* ****** ****** *)
//
implement
int_exists_cloptr
  (n0, pred) =
(
  intrange_exists_cloptr(0, n0, pred)
)
implement
int_forall_cloptr
  (n0, pred) =
(
  intrange_forall_cloptr(0, n0, pred)
)
//
(* ****** ****** *)
//
implement
int_foreach_cloptr
  (n0, fwork) =
(
  intrange_foreach_cloptr(0, n0, fwork)
)
implement
int_rforeach_cloptr
  (n0, fwork) =
(
  intrange_rforeach_cloptr(0, n0, fwork)
)
//
(* ****** ****** *)
//
implement
int_foldleft_cloptr
  {res}
  (n0, ini, fopr) =
(
  intrange_foldleft_cloptr{res}(0, n0, ini, fopr)
)
implement
int_foldright_cloptr
  {res}
  (n0, fopr, snk) =
(
  intrange_foldright_cloptr{res}(0, n0, fopr, snk)
)
//
(* ****** ****** *)

implement
int_list_vt_map_cloptr
  {a}{n}(n0, fopr) = let
//
fun
aux
{ i:nat
| i <= n
}
(
  i: int(i), fopr: !cfun1(int, a)
) : list_vt(a, n-i) =
(
if
(i < n0)
then let
  val x = fopr(i)
in
  list_vt_cons(x, aux(i+1, fopr))
end // end of [then]
else list_vt_nil()
// end of [if]
)
//
val res = aux(0, fopr)
//
in
  cfun_free(fopr); res
end // end of [int_list_vt_map_cloptr]

(* ****** ****** *)

#if
defined(ATSCC_STREAM_VT)
//
implement
int_stream_vt_map_cloptr
  {a}{n}(n0, fopr) = let
//
fun
aux
{i:nat}
(
  i: int(i), fopr: cfun1(int, a)
) : stream_vt(a) = $ldelay
(
(
if
(i < n0)
then let
  val x = fopr(i)
in
  stream_vt_cons(x, aux(i+1, fopr))
end // end of [then]
else let
  val () = cfun_free(fopr) in stream_vt_nil((*void*))
end // end of [else]
) : stream_vt_con(a)
//
, cfun_free(fopr) // HX: the stream is freed
//
) (* $ldelay *) // [aux]
//
in
  aux(0, fopr)
end // end of [int_stream_vt_map_cloptr]
//
#endif // ATSCC_STREAM_VT

(* ****** ****** *)
//
implement
int2_exists_cloptr
  (n1, n2, pred) =
(
intrange2_exists_cloptr (0, n1, 0, n2, pred)
)
//
implement
int2_forall_cloptr
  (n1, n2, pred) =
(
intrange2_forall_cloptr (0, n1, 0, n2, pred)
)
//
implement
int2_foreach_cloptr
  (n1, n2, fwork) =
(
intrange2_foreach_cloptr (0, n1, 0, n2, fwork)
)
//
(* ****** ****** *)

implement
intrange_exists_cloptr
  (l, r, pred) = let
//
fun
loop
(
  l: int, r: int, pred: !cfun1(int, bool)
) : bool = (
//
if l < r
  then (
    if pred(l) then true else loop (l+1, r, pred)
  ) else false
//
) (* end of [loop] *)
//
val ans = loop (l, r, pred)
//
in
  cfun_free(pred); ans
end // end of [intrange_exists_cloptr]

(* ****** ****** *)

implement
intrange_forall_cloptr
  (l, r, pred) = let
//
fun
loop
(
  l: int, r: int, pred: !cfun1(int, bool)
) : bool = (
//
if l < r
  then (
    if pred(l) then loop(l+1, r, pred) else false
  ) else true
//
) (* end of [loop] *)
//
val ans = loop (l, r, pred)
//
in
  cfun_free(pred); ans
end // end of [intrange_forall_cloptr]

(* ****** ****** *)

implement
intrange_foreach_cloptr
  (l, r, fwork) = let
//
fun
loop (
  l: int, r: int, fwork: !cfun1(int, void)
) : void = (
//
if (l < r)
then let
  val () = fwork(l) in loop(l+1, r, fwork)
end // end of [then]
else ((*void*)) // else
//
) (* end of [loop] *)
//
val () = loop(l, r, fwork)
//
in
  cfun_free(fwork)
end // end of [intrange_foreach_cloptr]

(* ****** ****** *)

implement
intrange_rforeach_cloptr
  (l, r, fwork) = let
//
fun
loop (
  l: int, r: int, fwork: !cfun1(int, void)
) : void = (
//
if (l < r)
then let
  val () = fwork(r-1) in loop(l, r-1, fwork)
end // end of [then]
else ((*void*)) // else
//
) (* end of [loop] *)
//
val () = loop(l, r, fwork)
//
in
  cfun_free(fwork)
end // end of [intrange_rforeach_cloptr]

(* ****** ****** *)

implement
intrange_foldleft_cloptr
  {res}
(
  l, r, ini, fopr
) = let
//
fun
loop
(
  l: int, r: int, ini: res, fopr: !cfun2(res, int, res)
) : res =
(
if (l < r)
  then loop(l+1, r, fopr(ini, l), fopr) else ini
// end of [if]
) (* end of [loop] *)
//
val res = loop(l, r, ini, fopr)
//
in
  cfun_free(fopr); res
end (* end of [intrange_foldleft_cloptr] *)

(* ****** ****** *)

implement
intrange_foldright_cloptr
  {res}
(
  l, r, fopr, snk
) = let
//
fun
loop
(
  l: int, r: int, fopr: !cfun2(int, res, res), snk: res
) : res =
(
if (l < r)
  then loop(l, r-1, fopr, fopr(r-1, snk)) else snk
// end of [if]
) (* end of [loop] *)
//
val res = loop(l, r, fopr, snk)
//
in
  cfun_free(fopr); res
end (* end of [intrange_foldright_cloptr] *)

(* ****** ****** *)

implement
intrange2_exists_cloptr
(
  l1, r1, l2, r2, pred
) = let
//
fun
loop1
(
  i: int, pred: !cfun2(int, int, bool)
) : bool =
(
if i < r1
  then (
    if loop2(i, l2, pred) then true else loop1(i+1, pred)
  ) else false
// end of [if]
)
//
and
loop2
(
  i: int, j: int, pred: !cfun2(int, int, bool)
) : bool =
(
if j < r2
  then (
    if pred(i, j) then true else loop2(i, j+1, pred)
  ) else false
// end of [if]
)
//
val ans = loop1(l1, pred)
//
in
  cfun_free(pred); ans
end // end of [intrange2_exists_cloptr]

(* ****** ****** *)

implement
intrange2_forall_cloptr
(
  l1, r1, l2, r2, pred
) = let
//
fun
loop1
(
  i: int, pred: !cfun2(int, int, bool)
) : bool =
(
if i < r1
  then (
    if loop2(i, l2, pred) then loop1(i+1, pred) else false
  ) else true
// end of [if]
)
//
and
loop2
(
  i: int, j: int, pred: !cfun2(int, int, bool)
) : bool =
(
if j < r2
  then (
    if pred(i, j) then loop2(i, j+1, pred) else false
  ) else true
// end of [if]
)
//
val ans = loop1(l1, pred)
//
in
  cfun_free(pred); ans
end // end of [intrange2_forall_cloptr]

(* ****** ****** *)

implement
intrange2_foreach_cloptr
(
  l1, r1, l2, r2, fwork
) = let
//
fun
loop1
(
  i: int, fwork: !cfun2(int, int, void)
) : void =
(
if i < r1
  then (loop2(i, l2, fwork); loop1(i+1, fwork)) else ()
// end of [if]
)
//
and
loop2
(
  i: int, j: int, fwork: !cfun2(int, int, void)
) : void =
(
if j < r2
  then (fwork(i, j); loop2(i, j+1, fwork)) else ()
// end of [if]
)
//
val () = loop1(l1, fwork)
//
in
  cfun_free(fwork)
end // end of [intrange2_foreach_cloptr]

(* ****** ****** *)

(* end of [intrange.dats] *)
