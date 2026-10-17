(* ****** ****** *)
(*
** libatscc-common
*)
(* ****** ****** *)
//
typedef
fun0 (b:vt0p) = () -<fun1> b
typedef
fun1 (a:t0p, b:vt0p) = (a) -<fun1> b
typedef
fun2 (a1:t0p, a2:t0p, b:vt0p) = (a1, a2) -<fun1> b
typedef
fun3 (a1:t0p, a2:t0p, a3: t0p, b:vt0p) = (a1, a2, a3) -<fun1> b
//
(* ****** ****** *)
//
//
// HX-2026-10: no GC
// Closures are linear (cloptr): a function taking a closure
// consumes it (it is freed after its last use, or its ownership
// is passed to the target language, whose own GC reclaims it).
//
vtypedef
cfun0 (b:vt0p) = () -<cloptr1> b
vtypedef
cfun1 (a:t0p, b:vt0p) = (a) -<cloptr1> b
vtypedef
cfun2 (a1:t0p, a2:t0p, b:vt0p) = (a1, a2) -<cloptr1> b
vtypedef
cfun3 (a1:t0p, a2:t0p, a3: t0p, b:vt0p) = (a1, a2, a3) -<cloptr1> b
//
stadef cfun = cfun0
stadef cfun = cfun1
stadef cfun = cfun2
stadef cfun = cfun3
//
(* ****** ****** *)
//
// HX-2026-10:
// a closure turned into a native function of the target
// language (e.g., for registering a callback); the closure
// is consumed, that is, it is owned by the target language
//
fun
cloref2fun0
  {b:vt0p}
  (f: cfun0(b)): fun0(b) = "mac#%"
//
fun
cloref2fun1
  {a:t0p;b:vt0p}
  (f: cfun1(a, b)): fun1(a, b) = "mac#%"
//
fun
cloref2fun2
  {a1,a2:t0p;b:vt0p}
  (cfun2(a1, a2, b)): fun2(a1, a2, b) = "mac#%"
fun
cloref2fun3
  {a1,a2,a3:t0p;b:vt0p}
  (cfun3(a1, a2, a3, b)): fun3(a1, a2, a3, b) = "mac#%"
//
(* ****** ****** *)
//
// HX-2026-10: the closure is borrowed
//
fun
cloref0_app
  {b:vt0p}
  (f: !cfun0(b)): b = "mac#%"
//
fun
cloref1_app
  {a:t0p;b:vt0p}
  (f: !cfun1(a, b), a): b = "mac#%"
//
fun
cloref2_app
  {a1,a2:t0p;b:vt0p}
  (f: !cfun2(a1, a2, b), a1, a2): b = "mac#%"
//
fun
cloref3_app
  {a1,a2,a3:t0p;b:vt0p}
  (f: !cfun3(a1, a2, a3, b), a1, a2, a3): b = "mac#%"
//
symintr cloref_app
overload cloref_app with cloref0_app
overload cloref_app with cloref1_app
overload cloref_app with cloref2_app
overload cloref_app with cloref3_app
//
(* ****** ****** *)
//
// HX-2026-10:
// freeing a closure: it is a no-op as
// the target language has its own GC
//
castfn
cfun_free{f:vt0p}(f: f):<> void
//
(* ****** ****** *)

//
// HX-2026-10:
// arrays and matrices of the target language
// (they used to be declared in the prelude)
//
abstype
arrayref_vt0ype_int_type
  (a:vt@ype, n:int) = ptr
typedef
arrayref(a:vt@ype, n:int) = arrayref_vt0ype_int_type(a, n)
//
praxi
lemma_arrayref_param
  {a:vt0p}{n:int}(A: arrayref(a, n)): [n >= 0] void
//
abstype
arrszref_vt0ype_type(a:vt@ype) = ptr
typedef
arrszref(a:vt@ype) = arrszref_vt0ype_type(a)
//
abstype
matrixref_vt0ype_int_int_type
  (a:vt@ype, m:int, n:int) = ptr
typedef
matrixref
  (a:vt@ype, m:int, n:int) = matrixref_vt0ype_int_int_type(a, m, n)
//
praxi
lemma_matrixref_param
  {a:vt0p}{m,n:int}
  (M: matrixref(a, m, n)): [m >= 0; n >= 0] void
//
abstype
mtrxszref_vt0ype_type(a:vt@ype) = ptr
typedef
mtrxszref(a:vt@ype) = mtrxszref_vt0ype_type(a)
//
(* ****** ****** *)

(* end of [basics.sats] *)
