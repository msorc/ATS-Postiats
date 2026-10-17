(*
** For writing ATS code
** that translates into Clojure
*)

(* ****** ****** *)

#define ATS_DYNLOADFLAG 0

(* ****** ****** *)
//
// HX-2014-08:
// prefix for external names
//
#define
ATS_EXTERN_PREFIX "ats2cljpre_"
#define
ATS_STATIC_PREFIX "_ats2cljpre_CLJlist_"
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
staload
UN = "prelude/SATS/unsafe.sats"
//
(* ****** ****** *)

staload "./../basics_clj.sats"

(* ****** ****** *)
//
staload "./../SATS/integer.sats"
//
(* ****** ****** *)
//
staload "./../SATS/print.sats"
staload "./../SATS/filebas.sats"
//
(* ****** ****** *)

staload "./../SATS/list_vt.sats"
staload "./../SATS/CLJlist.sats"

(* ****** ****** *)
//
implement
{a}(*tmp*)
CLJlist_sort_1(xs) = 
CLJlist_sort_2
  (xs, lam(x1, x2) => gcompare_val_val<a>(x1, x2))
//
(* ****** ****** *)

implement
CLJlist2list_vt_rev
  {a}(xs) = let
//
fun
loop
(
  xs: CLJlist(a), res: List0_vt(a)
) : List0_vt(a) =
(
if
CLJlist_is_nil(xs)
then res
else loop(CLJlist_tail(xs), list_vt_cons(CLJlist_head(xs), res))
) (* end of [loop] *)
//
in
  loop(xs, list_vt_nil())
end (* CLJlist2list_vt_rev *)
//
implement
CLJlist2list_vt
  {a}(xs) =
  list_vt_reverse(CLJlist2list_vt_rev{a}(xs))
//
(* ****** ****** *)
//
implement
CLJlist_oflist_vt_rev
  {a}(xs) = let
//
fun
aux
(
  xs: !List_vt(a), res: CLJlist(a)
) : CLJlist(a) =
(
case+ xs of
| list_vt_nil() => res
| list_vt_cons(x, xs1) => aux(xs1, CLJlist_cons(x, res))
) (* end of [aux] *)
//
in
  aux(xs, CLJlist_nil())
end // end of [CLJlist_oflist_vt_rev]
//
implement
CLJlist_oflist_vt
  {a}(xs) =
  CLJlist_reverse(CLJlist_oflist_vt_rev{a}(xs))
//
(* ****** ****** *)

(* end of [CLJlist.dats] *)
