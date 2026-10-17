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
// HX-2013-04:
// intrange (l, r) is for
// integers i satisfying l <= i < r
//
// HX-2026-10: no GC
// The closures are linear (cloptr): each of the
// following functions consumes the closure given to it.
//
(* ****** ****** *)
//
fun
int_repeat_cloptr
  (n: int, f: cfun0(void)): void = "mac#%"
//
overload repeat with int_repeat_cloptr of 100
//
(* ****** ****** *)
//
fun
int_exists_cloptr
  (n: int, f: cfun1(int, bool)): bool = "mac#%"
fun
int_forall_cloptr
  (n: int, f: cfun1(int, bool)): bool = "mac#%"
//
(* ****** ****** *)
//
fun
int_foreach_cloptr
  (n: int, f: cfun1(int, void)): void = "mac#%"
fun
int_rforeach_cloptr
  (n: int, f: cfun1(int, void)): void = "mac#%"
//
(* ****** ****** *)
//
fun
int_foldleft_cloptr
  {res:t0p}
(
  n0: int, ini: res, fopr: cfun2(res, int, res)
) : res = "mac#%" // end of [int_foldleft_cloptr]
//
fun
int_foldright_cloptr
  {res:t0p}
(
  n0: int, fopr: cfun2(int, res, res), snk: res
) : res = "mac#%" // end of [int_foldright_cloptr]
//
(* ****** ****** *)
//
fun
int_list_vt_map_cloptr
  {a:vt0p}{n:nat}
(
  n: int(n), fopr: cfun1(int, a)
) : list_vt(a, n) = "mac#%" // end-of-fun
//
(* ****** ****** *)
//
fun
int_stream_vt_map_cloptr
  {a:vt0p}{n:nat}
(
  n0: int(n), fopr: cfun1(int, a)
) : stream_vt(a) = "mac#%" // end-of-function
//
(* ****** ****** *)
//
fun
int2_exists_cloptr
( n1: int, n2: int
, pred: cfun2(int, int, bool)): bool = "mac#%"
fun
int2_forall_cloptr
( n1: int, n2: int
, pred: cfun2(int, int, bool)): bool = "mac#%"
//
fun
int2_foreach_cloptr
( n1: int, n2: int
, fwork: cfun2(int, int, void)): void = "mac#%"
//
(* ****** ****** *)
//
fun
intrange_exists_cloptr
  (l: int, r: int, f: cfun1(int, bool)): bool = "mac#%"
fun
intrange_forall_cloptr
  (l: int, r: int, pred: cfun1(int, bool)): bool = "mac#%"
//
(* ****** ****** *)
//
fun
intrange_foreach_cloptr
  (l: int, r: int, fwork: cfun1(int, void)): void = "mac#%"
fun
intrange_rforeach_cloptr
  (l: int, r: int, fwork: cfun1(int, void)): void = "mac#%"
//
(* ****** ****** *)
//
fun
intrange_foldleft_cloptr
  {res:t@ype}
(
  l: int, r: int, ini: res, fopr: cfun2(res, int, res)
) : res = "mac#%" // end of [intrange_foldleft_cloptr]
//
fun
intrange_foldright_cloptr
  {res:t@ype}
(
  l: int, r: int, fopr: cfun2(int, res, res), snk: res
) : res = "mac#%" // end of [intrange_foldright_cloptr]
//
(* ****** ****** *)
//
fun
intrange2_exists_cloptr
(
  l1: int, r1: int, l2: int, r2: int, f: cfun2(int, int, bool)
) : bool = "mac#%" // end of [intrange2_exists_cloptr]
fun
intrange2_forall_cloptr
(
  l1: int, r1: int, l2: int, r2: int, f: cfun2(int, int, bool)
) : bool = "mac#%" // end of [intrange2_forall_cloptr]
//
fun
intrange2_foreach_cloptr
(
  l1: int, r1: int, l2: int, r2: int, f: cfun2(int, int, void)
) : void = "mac#%" // end of [intrange2_foreach_cloptr]
//
(* ****** ****** *)

(* end of [intrange.sats] *)
