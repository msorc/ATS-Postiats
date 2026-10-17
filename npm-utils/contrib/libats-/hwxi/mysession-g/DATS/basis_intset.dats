(*
** integer sets
*)

(* ****** ****** *)
//
staload
UN =
"prelude/SATS/unsafe.sats"
//
(* ****** ****** *)
//
staload
"./../SATS/basis_intset.sats"
//
// HX-2026-10: no GC
// an intset is a sorted list in the global arena
//
staload
"libats/SATS/arena.sats"
staload
_ = "libats/DATS/arena.dats"
//
(* ****** ****** *)

assume
intset(n:int, xs:iset) = glist(int)

(* ****** ****** *)
//
// HX: [xs] reversed onto [res]
//
extern
fun{}
glist_revapp2_vt
(
  xs: glist(int), res: List0_vt(int)
) : List0_vt(int)
implement
{}(*tmp*)
glist_revapp2_vt
  (xs, res) =
(
case+ glist_view(xs) of
| ~GLnil() => res
| ~GLcons(x, xs) => glist_revapp2_vt(xs, cons_vt(x, res))
)

(* ****** ****** *)
//
implement
{}(*tmp*)
intset_nil() = glist_nil()
//
implement
{}(*tmp*)
intset_int(x) = glist_sing<int>(x)
//
implement
{}(*tmp*)
intset_int2(x1, x2) = glist_cons<int>(x1, glist_sing<int>(x2))
//
implement
{}(*tmp*)
intset_int3(x1, x2, x3) =
  glist_cons<int>(x1, glist_cons<int>(x2, glist_sing<int>(x3)))
//
(* ****** ****** *)

implement
{}(*tmp*)
intset_add_elt
  (xs, x0) = let
//
fun
aux
(
  xs: glist(int)
, res: List0_vt(int)
) : List0_vt(int) =
(
case+ glist_view(xs) of
| ~GLnil() =>
    cons_vt(x0, res)
  // list_nil
| ~GLcons(x, xs) =>
    if x < x0
      then aux(xs, cons_vt(x, res))
      else (
        if x > x0
          then
          glist_revapp2_vt
            (xs, cons_vt(x, cons_vt(x0, res)))
          // end of [then]
          else
          glist_revapp2_vt(xs, cons_vt(x0, res))
      ) (* end of [else] *)
   // end of [list_cons]
)
//
in
  glist_make_list_vt<int>(list_vt_reverse(aux(xs, nil_vt())))
end // end of [intset_add_elt]

(* ****** ****** *)

implement
{}(*tmp*)
intset_union
  (xs1, xs2) = let
//
fnx
aux0
(
  xs1: glist(int)
, xs2: glist(int)
, res: List0_vt(int)
) : List0_vt(int) =
(
case+ glist_view(xs1) of
| ~GLnil() => glist_revapp2_vt(xs2, res)
| ~GLcons(x1, xs1) => aux1(x1, xs1, xs2, res)
)
//
and
aux1
(
  x1: int
, xs1: glist(int)
, xs2: glist(int)
, res: List0_vt(int)
) : List0_vt(int) =
(
case+ glist_view(xs2) of
| ~GLnil() =>
    glist_revapp2_vt(xs1, cons_vt(x1, res))
  // end of [list_nil]
| ~GLcons(x2, xs2) => aux2(x1, xs1, x2, xs2, res)
)
//
and
aux2
(
  x1: int
, xs1: glist(int)
, x2: int
, xs2: glist(int)
, res: List0_vt(int)
) : List0_vt(int) =
(
//
if x1 < x2
  then
  aux1(x2, xs2, xs1, cons_vt(x1, res))
  else (
    if x1 > x2
      then
      aux1(x1, xs1, xs2, cons_vt(x2, res))
      else aux0(xs1, xs2, cons_vt(x1, res))
  ) (* end of [else] *)
) (* end of [aux2] *)
//
in
  glist_make_list_vt<int>(list_vt_reverse(aux0(xs1, xs2, nil_vt())))
end // end of [intset_union]

(* ****** ****** *)

implement
{}(*tmp*)
intset_intersect
  (xs1, xs2) = let
//
fnx
aux0
(
  xs1: glist(int)
, xs2: glist(int)
, res: List0_vt(int)
) : List0_vt(int) =
(
case+ glist_view(xs1) of
| ~GLnil() => res
| ~GLcons(x1, xs1) => aux1(x1, xs1, xs2, res)
)
//
and
aux1
(
  x1: int
, xs1: glist(int)
, xs2: glist(int)
, res: List0_vt(int)
) : List0_vt(int) =
(
case+ glist_view(xs2) of
| ~GLnil() => res
| ~GLcons(x2, xs2) => aux2(x1, xs1, x2, xs2, res)
)
//
and
aux2
(
  x1: int
, xs1: glist(int)
, x2: int
, xs2: glist(int)
, res: List0_vt(int)
) : List0_vt(int) =
(
//
if x1 < x2
  then aux1(x2, xs2, xs1, res)
  else (
    if x1 > x2
      then aux1(x1, xs1, xs2, res)
      else aux0(xs1, xs2, cons_vt(x1, res))
  ) (* end of [else] *)
) (* end of [aux2] *)
//
in
  glist_make_list_vt<int>(list_vt_reverse(aux0(xs1, xs2, nil_vt())))
end // end of [intset_intersect]

(* ****** ****** *)

implement
{}(*tmp*)
intset_ncomplement
  (xs, n) = let
//
fun
aux1
(
  i: int
, res: List0_vt(int)
) : List0_vt(int) =
(
//
if (i < n)
  then aux1(i+1, cons_vt(i, res)) else res
//
) (* end of [aux1] *)
//
and
aux2
(
  i: int
, x0: int
, xs: glist(int)
, res: List0_vt(int)
) : List0_vt(int) = (
//
if
(i < x0)
then (
  aux2(i+1, x0, xs, cons_vt(i, res))
) else (
  case+ glist_view(xs) of
  | ~GLnil() => aux1(i+1, res)
  | ~GLcons(x, xs) => aux2(i+1, x, xs, res)
) (* end of [else] *)
//
) (* end of [aux2] *)
//
val ys = (
//
case+ glist_view(xs) of
| ~GLnil() => aux1(0, nil_vt)
| ~GLcons(x, xs) => aux2(0, x, xs, nil_vt)
//
) : List0_vt(int)
//
in
  glist_make_list_vt<int>(list_vt_reverse(ys))
end // end of [intset_ncomplement]

(* ****** ****** *)

implement
{}(*tmp*)
intset_foreach_clo
  {n}(xs, fwork) = let
in
  loop(xs, fwork) where
  {
    fun
    loop
    (
      xs: glist(int), fwork: &((natLt(n)) -<clo1> void)
    ) : void =
    (
      case+ glist_view(xs) of
      | ~GLnil() => ()
      | ~GLcons(x, xs) =>
          (fwork($UN.cast{natLt(n)}(x)); loop(xs, fwork))
    )
  }
end // end of [intset_foreach_clo]

(* ****** ****** *)

implement
{}(*tmp*)
intset2_foreach_clo
  {n}(xs, ys, fwork) = let
//
vtypedef
fwork = (natLt(n), natLt(n)) -<clo1> void
//
fun
aux
(
  x: int, ys: glist(int), fwork: &fwork
) : void =
(
case+ glist_view(ys) of
| ~GLnil() => ()
| ~GLcons(y, ys) => let
    val x =
      $UN.cast{natLt(n)}(x)
    val y =
      $UN.cast{natLt(n)}(y)
    val ((*void*)) = fwork(x, y) in aux(x, ys, fwork)
  end (* end of [GLcons] *)
)
//
fun
auxlst
(
  xs: glist(int), ys: glist(int), fwork: &fwork
) : void =
(
case+ glist_view(xs) of
| ~GLnil() => ()
| ~GLcons(x, xs) =>
  (
    let val () = aux(x, ys, fwork) in auxlst(xs, ys, fwork) end
  ) (* end of [GLcons] *)
)
in
  auxlst(xs, ys, fwork)
end // end of [intset2_foreach_clo]

(* ****** ****** *)

implement
{}(*tmp*)
cintset_foreach_clo
  {n}(n, xs, fwork) = let
//
vtypedef
fwork = (natLt(n)) -<clo1> void
//
fun
aux1
(
  i: natLte(n), fwork: &fwork
): void = (
//
if i < n then
  let val () = fwork(i) in aux1(i+1, fwork) end
) (* end of [aux] *)
//
fun
aux2
(
  i: natLt(n)
, xs: glist(int), fwork: &fwork
) : void =
(
case+ glist_view(xs) of
| ~GLnil() =>
  let val () = fwork(i) in aux1(i+1, fwork) end
| ~GLcons(x, xs) => aux3(i, x, xs, fwork)
)
//
and
aux3
(
  i: natLte(n)
, x: int, xs: glist(int), fwork: &fwork
) : void =
if
(i < x)
then let
//
val i =
  $UN.cast{natLt(n)}(i)
//
val ((*void*)) = fwork(i)
//
in
  aux3(i+1, x, xs, fwork)
//
end // end of [then]
else let
  val i = i + 1
in
  if i < n then aux2(i, xs, fwork) else ()
end // end of [else]
//
in
  if n > 0 then aux2(0, xs, fwork) else ()
end // end of [cintset_foreach_clo]

(* ****** ****** *)
//
implement{}
print_intset(xs) = fprint_intset(stdout_ref, xs)
implement{}
prerr_intset(xs) = fprint_intset(stderr_ref, xs)
//
implement{}
fprint_intset(out, xs) = fprint_glist_sep<int>(out, xs, "+")
//
(* ****** ****** *)

(* end of [basis_intset.dats] *)
