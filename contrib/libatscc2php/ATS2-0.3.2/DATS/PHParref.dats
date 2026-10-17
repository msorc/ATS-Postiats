(*
** For writing ATS code
** that translates into PHP
*)

(* ****** ****** *)

#define ATS_DYNLOADFLAG 0

(* ****** ****** *)
//
// HX-2014-08:
// prefix for external names
//
#define
ATS_EXTERN_PREFIX "ats2phppre_"
#define
ATS_STATIC_PREFIX "_ats2phppre_PHParref_"
//
(* ****** ****** *)
//
#staload
UN = "prelude/SATS/unsafe.sats"
//
(* ****** ****** *)
//
#staload "./../basics_php.sats"
//
#staload "./../SATS/integer.sats"
//
#staload "./../SATS/PHParray.sats"
#staload "./../SATS/PHParref.sats"
//
(* ****** ****** *)

implement
PHParref_make_list_vt
{a}(xs) = (A) where
{
//
val A =
PHParref_nil()
//
fun
loop
(xs: !List_vt(a)): void =
(
case+ xs of
| list_vt_nil
  (
    // argless
  ) => ((*exit*))
| list_vt_cons
  (
    x, xs1
  ) => loop(xs1) where
  {
    val () = PHParref_extend(A, x)
  } (* end of [list_vt_cons] *)
)
//
val () = loop(xs) // initizing
//
} (* PHParref_make_list_vt *)

(* ****** ****** *)
//
implement
PHParref2list_vt
  {a}(A) =
  PHParray2list_vt{a}(PHParref2array(A))
//
implement
PHParref2list_vt_rev
  {a}(A) =
  PHParray2list_vt_rev{a}(PHParref2array(A))
//
(* ****** ****** *)
//
implement
PHParref_streamize_elt
  {a}(A) =
  PHParray_streamize_elt{a}(PHParref2array(A))
//
(* ****** ****** *)

(* end of [PHParref.dats] *)
