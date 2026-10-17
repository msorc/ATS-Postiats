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
ATS_EXTERN_PREFIX "ats2scmpre_"
#define
ATS_STATIC_PREFIX "_ats2scmpre_SCMlist_"
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

staload "./../basics_scm.sats"

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
staload "./../SATS/SCMlist.sats"

(* ****** ****** *)
//
implement
{a}(*tmp*)
SCMlist_sort_1(xs) = 
SCMlist_sort_2
  (xs, lam(x1, x2) => gcompare_val_val<a>(x1, x2))
//
(* ****** ****** *)
//
implement
SCMlist2list_vt_rev
  {a}(xs) = let
//
fun
loop
(
  xs: SCMlist(a), res: List0_vt(a)
) : List0_vt(a) =
(
if
SCMlist_is_nil(xs)
then res
else loop(SCMlist_tail(xs), list_vt_cons(SCMlist_head(xs), res))
) (* end of [loop] *)
//
in
  loop(xs, list_vt_nil())
end (* SCMlist2list_vt_rev *)
//
implement
SCMlist2list_vt
  {a}(xs) =
  list_vt_reverse(SCMlist2list_vt_rev{a}(xs))
//
(* ****** ****** *)
//
implement
SCMlist_oflist_vt_rev
  {a}(xs) = let
//
fun
aux
(
  xs: !List_vt(a), res: SCMlist(a)
) : SCMlist(a) =
(
case+ xs of
| list_vt_nil() => res
| list_vt_cons(x, xs1) => aux(xs1, SCMlist_cons(x, res))
) (* end of [aux] *)
//
in
  aux(xs, SCMlist_nil())
end // end of [SCMlist_oflist_vt_rev]
//
implement
SCMlist_oflist_vt
  {a}(xs) =
  SCMlist_reverse(SCMlist_oflist_vt_rev{a}(xs))
//
(* ****** ****** *)

(* end of [SCMlist.dats] *)
