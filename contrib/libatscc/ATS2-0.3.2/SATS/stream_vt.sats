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
fun{}
stream_vt_make_nil
{a:vt0p}
(
// argless
) : stream_vt(a) = "mac#%"
//
fun{}
stream_vt_make_cons
  {a:t0p}
(
x0: a, xs: stream_vt(INV(a))
) :<> stream_vt(a) = "mac#%"
//
(* ****** ****** *)
//
fun{}
stream_vt_sing
  {a:t0p}
  (x0: a): stream_vt_con(a) = "mac#%"
fun{}
stream_vt_make_sing
  {a:t0p}(x0: a): stream_vt(a) = "mac#%"
//
(* ****** ****** *)
//
fun
stream_vt_free
  {a:vt0p}
  (stream_vt(a)):<!wrt> void = "mac#%"
//
(* ****** ****** *)
//
(* ****** ****** *)
//
fun
stream_vt_length
  {a:t0p}
  (stream_vt(INV(a))): intGte(0) = "mac#%"
//
(* ****** ****** *)
//
fun
stream_vt_takeLte
  {a:vt0p}
(
xs: stream_vt(INV(a)), n0: intGte(0)
) :<> stream_vt(a) = "mac#%" // end-of-fun
//
(* ****** ****** *)
//
fun
stream2list_vt
  {a:vt0p}
  (stream_vt(INV(a))): List0_vt(a) = "mac#%"
fun
stream2list_vt_rev
  {a:vt0p}
  (stream_vt(INV(a))): List0_vt(a) = "mac#%"
//
(* ****** ****** *)
//
fun
stream_vt_append
  {a:vt0p}
(
  stream_vt(INV(a)), stream_vt(a)
) :<> stream_vt(a) = "mac#%" // end-of-fun
//
(* ****** ****** *)
//
fun
stream_vt_concat
  {a:vt0p}
(
  xss: stream_vt(stream_vt(INV(a)))
) :<> stream_vt(a) = "mac#%" // end-of-fun
//
(* ****** ****** *)
//
//
// HX-2026-10: no GC
// The closures are linear (cloptr): each of the following
// functions consumes the closure given to it (a lazy stream
// keeps it until the stream is evaluated or freed).
//
fun
stream_vt_map_cloptr
  {a:vt0p}{b:vt0p}
(
  xs: stream_vt(INV(a)), fopr: (a) -<cloptr1> b
) : stream_vt(b) = "mac#%" // end-of-function
//
fun
stream_vt_filter_cloptr
  {a:t0ype}
(
  xs: stream_vt(INV(a)), pred: (a) -<cloptr1> bool
) : stream_vt(a) = "mac#%" // end-of-function
//
(* ****** ****** *)
//
fun
stream_vt_exists_cloptr
  {a:t0ype}
(
  stream_vt(INV(a)), pred: (a) -<cloptr1> bool
) : bool = "mac#%" // end-of-function
fun
stream_vt_forall_cloptr
  {a:t0ype}
(
  stream_vt(INV(a)), pred: (a) -<cloptr1> bool
) : bool = "mac#%" // end-of-function
//
(* ****** ****** *)
//
fun
stream_vt_foreach_cloptr
  {a:vt0ype}
(
  xs: stream_vt(INV(a)), fwork: (a) -<cloptr1> void
) : void = "mac#%" // end-of-function
fun
stream_vt_iforeach_cloptr
  {a:vt0ype}
(
  xs: stream_vt(INV(a)), fwork: (Nat, a) -<cloptr1> void
) : void = "mac#%" // end-of-function
fun
stream_vt_rforeach_cloptr
  {a:vt0ype}
(
  xs: stream_vt(INV(a)), fwork: (a) -<cloptr1> void
) : void = "mac#%" // end-of-function
//
(* ****** ****** *)
//
fun
stream_vt_tabulate_cloptr
  {a:t0p}
  (fopr: intGte(0) -<cloptr1> a): stream_vt(a) = "mac#%"
//
(* ****** ****** *)
//
overload length with stream_vt_length of 100
//
overload append with stream_vt_append of 100
overload concat with stream_vt_concat of 100
//
overload .takeLte with stream_vt_takeLte of 100
//
(* ****** ****** *)

(* end of [stream_vt.sats] *)
