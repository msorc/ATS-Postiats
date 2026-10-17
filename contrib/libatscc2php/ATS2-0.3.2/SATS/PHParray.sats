(* ****** ****** *)
(*
** For writing ATS code
** that translates into PHP
*)
(* ****** ****** *)
//
// HX-2014-08:
// prefix for external names
//
#define
ATS_EXTERN_PREFIX "ats2phppre_"
#define
ATS_STATIC_PREFIX "_ats2phppre_PHParray_"
//
(* ****** ****** *)
//
#staload
"./../basics_php.sats" // PHP datatypes
//
(* ****** ****** *)
//
fun
PHParray_nil
  {a:t0p}(): PHParray(a) = "mac#%"
fun
PHParray_sing
  {a:t0p}(a): PHParray(a) = "mac#%"
fun
PHParray_pair
  {a:t0p}(a, a): PHParray(a) = "mac#%"
//
(* ****** ****** *)
//
fun
PHParray_make_elt
  {a:t0p}
  (asz: intGte(0), x0: a): PHParray(a) = "mac#%"
//
(* ****** ****** *)
//
// HX-2026-10: no GC (the list is borrowed)
fun
PHParray_make_list_vt
  {a:t0p}(xs: !List_vt(INV(a))): PHParray(a) = "mac#%"
//
(* ****** ****** *)
//
fun
PHParray_size
  {a:t0p}(PHParray(a)): intGte(0) = "mac#%"
//
overload size with PHParray_size of 100
overload .size with PHParray_size of 100
//
(* ****** ****** *)
//
fun
PHParray_get_at
  {a:t0p}(A: PHParray(a), i: int): a = "mac#%"
//
overload [] with PHParray_get_at of 100
//
(* ****** ****** *)
//
fun
PHParray2list_vt
  {a:t0p}(A: PHParray(a)): List0_vt(a) = "mac#%"
fun
PHParray2list_vt_rev
  {a:t0p}(A: PHParray(a)): List0_vt(a) = "mac#%"
//
(* ****** ****** *)
//
// HX-2026-10:
// the closures (cloptr) given to the following
// functions are consumed
//
fun
PHParray2list_vt_map
  {a:t0p}{b:t0p}
  (A: PHParray(a), fopr: cfun(a, b)): List0_vt(b) = "mac#%"
fun
PHParray2list_vt_map_rev
  {a:t0p}{b:t0p}
  (A: PHParray(a), fopr: cfun(a, b)): List0_vt(b) = "mac#%"
//
(* ****** ****** *)
//
// HX-2026-10: [test] and [fwork] are consumed
fun
PHParray_forall
  {a:t0p}
  (A: PHParray(a), test: cfun(a, bool)): bool = "mac#%"
fun
PHParray_foreach
  {a:t0p}
  (A: PHParray(a), test: cfun(a, void)): void = "mac#%"
//
(* ****** ****** *)
//
fun
PHParray_streamize_elt
  {a:t0p}(A: PHParray(a)): stream_vt(a) = "mac#%"
//
(* ****** ****** *)
//
fun
PHParray_join
  {a:t0p}(A: PHParray(a)): string = "mac#%"
fun
PHParray_join_sep
  {a:t0p}(A: PHParray(a), sep: string): string = "mac#%"
//
(* ****** ****** *)
//
(*
typedef strchr = string(1)
*)
fun
PHParray_of_string(cs: string): PHParray(strchr) = "mac#%"
//
(* ****** ****** *)

(* end of [PHParray.sats] *)
