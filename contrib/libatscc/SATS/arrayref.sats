(* ****** ****** *)
(*
** libatscc-common
*)
(* ****** ****** *)

(*
staload "./../basics.sats"
*)

(* ****** ****** *)
//
fun
arrayref_make_elt
  {a:t0p}{n:nat}
  (int(n), a): arrayref(a, n) = "mac#%"
//
(* ****** ****** *)
//
fun
arrayref_get_at
  {a:t0p}{n:int}
  (arrayref(a, n), natLt(n)): a = "mac#%"
//
fun
arrayref_set_at
  {a:t0p}{n:int}
  (arrayref(a, n), natLt(n), a): void = "mac#%"
//
fun
arrayref_exch_at
  {a:vt0p}{n:int}
  (arrayref(a, n), natLt(n), x0: a): (a) = "mac#%"
//
(* ****** ****** *)

overload [] with arrayref_get_at of 100
overload [] with arrayref_set_at of 100

(* ****** ****** *)
//
fun
arrayref_exists_cloptr
  {a:vt0p}{n:int}
( A0: arrayref(a, n)
, asz: int(n), ftest: natLt(n) -<cloptr1> bool
) : bool = "mac#%" // end-of-fun
//
fun
arrayref_forall_cloptr
  {a:vt0p}{n:int}
( A0: arrayref(a, n)
, asz: int(n), ftest: natLt(n) -<cloptr1> bool
) : bool = "mac#%" // end-of-fun
//
(* ****** ****** *)

fun
arrayref_foreach_cloptr
  {a:vt0p}{n:int}
( A0: arrayref(a, n)
, asz: int(n), fwork: natLt(n) -<cloptr1> void
) : void = "mac#%" // end-of-fun

(* ****** ****** *)
//
fun
arrayref_tabulate_cloptr
  {a:vt0p}{n:int}
(
  asz: int(n), fopr: (natLt(n)) -<cloptr1> (a)
) : arrayref(a, n) = "mac#%" // end-of-fun
//
(* ****** ****** *)
//
// HX: array-with-size
//
(* ****** ****** *)
//
fun
arrszref_size
  {a:vt0p}
  (A: arrszref(a)): intGte(0) = "mac#%"
fun
arrszref_get_size
  {a:vt0p}
  (A: arrszref(a)): intGte(0) = "mac#%"
//
overload size with arrszref_size
overload .size with arrszref_get_size
//
(* ****** ****** *)
//
fun
arrszref_make_elt
  {a:t0p}{n:nat}
  (asz: int(n), a): arrszref(a) = "mac#%"
//
(* ****** ****** *)
//
fun
arrszref_get_arrayref
  {a:t0p}
  (arrszref(a)): [n:nat] arrayref(a,n) = "mac#%"
//
fun
arrszref_make_arrayref
  {a:t0p}{n:int}
  (arrayref(a, n), int(n)) : arrszref(a) = "mac#%"
//
(* ****** ****** *)
//
fun
arrszref_get_at
  {a:t0p}(A: arrszref(a), i: int): a = "mac#%"
//
fun
arrszref_set_at
  {a:t0p}(A: arrszref(a), i: int, x0: a): void = "mac#%"
//
fun
arrszref_exch_at
  {a:vt0p}(A: arrszref(a), i: int, x0: a): (a) = "mac#%"
//
(* ****** ****** *)

overload [] with arrszref_get_at of 100
overload [] with arrszref_set_at of 100

(* ****** ****** *)
//
fun
arrszref_exists_cloptr
  {a:vt0p}
(
A0: arrszref(a), pred: intGte(0) -<cloptr1> bool
) : bool = "mac#%" // arrszref_exists_cloptr
fun
arrszref_forall_cloptr
  {a:vt0p}
(
A0: arrszref(a), pred: intGte(0) -<cloptr1> bool
) : bool = "mac#%" // arrszref_forall_cloptr
//
(* ****** ****** *)
//
fun
arrszref_foreach_cloptr
  {a:vt0p}
(
A0: arrszref(a), fwork: intGte(0) -<cloptr1> void
) : void = "mac#%" // arrszref_foreach_cloptr
//
//
(* ****** ****** *)
//
fun
arrszref_tabulate_cloptr
  {a:vt0p}{n:int}
( asz: int(n)
, fopr: natLt(n) -<cloptr1> a): arrszref(a) = "mac#%"
//
(* ****** ****** *)

(* end of [arrayref.sats] *)
