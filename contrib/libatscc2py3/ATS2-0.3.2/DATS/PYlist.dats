(*
** For writing ATS code
** that translates into Python
*)

(* ****** ****** *)

#define ATS_DYNLOADFLAG 0

(* ****** ****** *)
//
// HX-2014-08:
// prefix for external names
//
#define
ATS_EXTERN_PREFIX "ats2pypre_"
#define
ATS_STATIC_PREFIX "_ats2pypre_PYlist_"
//
(* ****** ****** *)
//
#define
LIBATSCC_targetloc
"$PATSHOME\
/contrib/libatscc/ATS2-0.3.2"
//
(* ****** ****** *)
//
#staload
UN = "prelude/SATS/unsafe.sats"
//
(* ****** ****** *)

#staload "./../basics_py.sats"

(* ****** ****** *)
//
#staload "./../SATS/integer.sats"
//
(* ****** ****** *)
//
#staload "./../SATS/print.sats"
#staload "./../SATS/filebas.sats"
//
(* ****** ****** *)

#staload "./../SATS/PYlist.sats"

(* ****** ****** *)
//
implement
{a}(*tmp*)
PYlist_sort_1(xs) = 
PYlist_sort_2
  (xs, lam(x1, x2) => gcompare_val_val<a>(x1, x2))
//
(* ****** ****** *)
//
implement
PYlist2list_vt
  {a}(xs) = let
//
fun
loop
(
  xs: PYlist(a), i: int, res: List0_vt(a)
) : List0_vt(a) =
  if i > 0
    then let
      val i = i - 1
      val x = PYlist_get_at(xs, $UN.cast{intGte(0)}(i))
    in
      loop(xs, i, list_vt_cons(x, res))
    end // end of [then]
    else res
//
in
  loop(xs, PYlist_length(xs), list_vt_nil())
end // end of [PYlist2list_vt]
//
implement
PYlist2list_vt_rev
  {a}(xs) = let
//
val n = PYlist_length(xs)
//
fun
loop
(
  xs: PYlist(a), i: int, res: List0_vt(a)
) : List0_vt(a) =
  if i < n
    then let
      val x = PYlist_get_at(xs, $UN.cast{intGte(0)}(i))
    in
      loop(xs, i+1, list_vt_cons(x, res))
    end // end of [then]
    else res
//
in
  loop(xs, 0, list_vt_nil())
end // end of [PYlist2list_vt_rev]
//
(* ****** ****** *)
//
implement
PYlist_oflist_vt
  {a}(xs) = let
//
fun
aux
(
  xs: !List_vt(a), res: PYlist(a)
) : PYlist(a) =
(
case+ xs of
| list_vt_nil() => res
| list_vt_cons(x, xs1) =>
    let val () = PYlist_append(res, x) in aux(xs1, res) end
)
//
in
  aux(xs, PYlist_nil())
end // end of [PYlist_oflist_vt]
//
implement
PYlist_oflist_vt_rev
  {a}(xs) = let
//
fun
aux
(
  xs: !List_vt(a), res: PYlist(a)
) : PYlist(a) =
(
case+ xs of
| list_vt_nil() => res
| list_vt_cons(x, xs1) =>
    let val () = PYlist_cons(x, res) in aux(xs1, res) end
)
//
in
  aux(xs, PYlist_nil())
end // end of [PYlist_oflist_vt_rev]
//
(* ****** ****** *)

(* end of [PYlist.dats] *)
