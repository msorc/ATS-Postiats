(*
** For writing ATS code
** that translates into Clojure
*)

(* ****** ****** *)
//
// HX-2014-08:
// prefix for external names
//
#define
ATS_EXTERN_PREFIX "ats2cljpre_"
//
(* ****** ****** *)
//
// Clojure datatypes
//
staload "./../basics_clj.sats"
//
(* ****** ****** *)
//
fun
CLJlist_nil
  {a:t0p}(): CLJlist(a) = "mac#%"
//
fun
CLJlist_cons
  {a:t0p}
(
  x0: a, xs: CLJlist(INV(a))
) : CLJlist(a) = "mac#%" // end-of-fun
//
(* ****** ****** *)
//
fun
CLJlist_sing
  {a:t0p}(x: a): CLJlist(a) = "mac#%"
//
fun
CLJlist_pair
  {a:t0p}(x1: a, x2: a): CLJlist(a) = "mac#%"
//
(* ****** ****** *)
//
fun
CLJlist_make_elt
  {a:t0p}{n:nat}
  (n: int(n), x0: a): CLJlist(a) = "mac#%"
//
(* ****** ****** *)
//
fun
CLJlist_is_nil
  {a:t0p}(CLJlist(INV(a))): bool = "mac#%"
//
fun
CLJlist_is_cons
  {a:t0p}(CLJlist(INV(a))): bool = "mac#%"
//
fun
CLJlist_isnot_nil
  {a:t0p}(CLJlist(INV(a))): bool = "mac#%"
//
(* ****** ****** *)
//
fun
CLJlist_length
  {a:t0p}(xs: CLJlist(INV(a))): int = "mac#%"
//
(* ****** ****** *)
//
// HX-2026-10: [xs] must be non-empty
fun
CLJlist_head
  {a:t0p}(xs: CLJlist(INV(a))): a = "mac#%"
fun
CLJlist_tail
  {a:t0p}(xs: CLJlist(INV(a))): CLJlist(a) = "mac#%"
//
fun
CLJlist_reverse
  {a:t0p}(xs: CLJlist(INV(a))): CLJlist(a) = "mac#%"
//
(* ****** ****** *)
//
fun
CLJlist2list_vt
  {a:t0p}(CLJlist(INV(a))): List0_vt(a) = "mac#%"
fun
CLJlist2list_vt_rev
  {a:t0p}(CLJlist(INV(a))): List0_vt(a) = "mac#%"
//
(* ****** ****** *)
//
// HX-2026-10: no GC (the list is borrowed)
//
fun
CLJlist_oflist_vt
  {a:t0p}(xs: !List_vt(INV(a))): CLJlist(a) = "mac#%"
fun
CLJlist_oflist_vt_rev
  {a:t0p}(xs: !List_vt(INV(a))): CLJlist(a) = "mac#%"
//
(* ****** ****** *)
//
fun{a:t0p}
CLJlist_sort_1
  (xs: CLJlist(INV(a))): CLJlist(a)
fun
CLJlist_sort_2{a:t0p}
(
  xs: CLJlist(INV(a)), cmp: (a, a) -<cloptr1> int
) : CLJlist(a) = "mac#%" // end-of-function
//
(* ****** ****** *)

(* end of [CLJlist.sats] *)
