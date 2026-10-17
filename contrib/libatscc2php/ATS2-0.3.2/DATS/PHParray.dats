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
ATS_STATIC_PREFIX "_ats2phppre_PHParray_"
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
#staload "./../SATS/list_vt.sats"
//
(* ****** ****** *)
//
implement
PHParray_make_list_vt
{a}(xs) =
(
$extfcall
( PHParray(a)
, "ats2phppre_PHParref2array", A
)
) where
{
  val A = PHParref_make_list_vt{a}(xs)
}
//
(* ****** ****** *)

implement
PHParray2list_vt
  {a}(A) = let
//
val [n:int] asz = A.size()
//
fun
loop
{i:nat|i <= n}
(i: int(i),
 res: list_vt(a, n-i)): list_vt(a, n) =
(
if i > 0
  then
  loop(i-1, list_vt_cons(A[i-1], res))
  else res
// end of [if]
) (* end of [loop] *)
//
in
  loop(asz, list_vt_nil())
end // end of [PHParray2list_vt]

(* ****** ****** *)

implement
PHParray2list_vt_rev
  {a}(A) = let
//
val [n:int] asz = A.size()
//
fun
loop
{n:nat}
{i:nat|i <= n}
( n: int(n)
, i: int(i)
, res: list_vt(a, i)): list_vt(a, n) =
(
if
(i < n)
then
loop(n, i+1, list_vt_cons(A[i], res))
else res
// end of [if]
) (* end of [loop] *)
//
in
  loop(asz, 0, list_vt_nil())
end // end of [PHParray2list_vt_rev]

(* ****** ****** *)

implement
PHParray2list_vt_map
  {a}{b}(A, fopr) = let
//
val [n:int] asz = A.size()
//
fun
loop
{n:nat}
{i:nat|i <= n}
( A: PHParray(a)
, f: !cfun(a, b)
, n: int(n)
, i: int(i)
, res: list_vt(b, i)): list_vt(b, n) =
(
if
(i < n)
then
loop(A, f, n, i+1, list_vt_cons(f(A[i]), res))
else res
// end of [if]
) (* end of [loop] *)
//
val res = loop(A, fopr, asz, 0, list_vt_nil())
//
in
  cfun_free(fopr); list_vt_reverse(res)
end // end of [PHParray2list_vt_map]

(* ****** ****** *)

implement
PHParray2list_vt_map_rev
  {a}{b}(A, fopr) = let
//
val [n:int] asz = A.size()
//
fun
loop
{n:nat}
{i:nat|i <= n}
( A: PHParray(a)
, f: !cfun(a, b)
, n: int(n)
, i: int(i)
, res: list_vt(b, i)): list_vt(b, n) =
(
if
(i < n)
then
loop(A, f, n, i+1, list_vt_cons(f(A[i]), res))
else res
// end of [if]
) (* end of [loop] *)
//
val res = loop(A, fopr, asz, 0, list_vt_nil())
//
in
  cfun_free(fopr); res
end // end of [PHParray2list_vt_map_rev]

(* ****** ****** *)

implement
PHParray_forall
  {a}(A, test) = let
//
val [n:int] asz = A.size()
//
fun
loop
{n:nat}
{i:nat|i <= n}
( A: PHParray(a)
, f: !cfun(a, bool)
, n: int(n)
, i: int(i)): bool =
(
if
(i < n)
then
(
if
f(A[i]) then loop(A, f, n, i+1) else false
) (* end of [then] *)
else true // end of [else]
// end of [if]
) (* end of [loop] *)
//
val res = loop(A, test, asz, 0)
//
in
  cfun_free(test); res
end // end of [PHParray_forall]

(* ****** ****** *)

implement
PHParray_foreach
  {a}(A, fwork) = let
//
val [n:int] asz = A.size()
//
fun
loop
{n:nat}
{i:nat|i <= n}
( A: PHParray(a)
, f: !cfun(a, void)
, n: int(n)
, i: int(i)): void =
(
if
(i < n)
then
(
let val () =
  f(A[i]) in loop(A, f, n, i+1)
end // end of [let]
) (* end of [then] *)
else ((*void*)) // end of [else]
// end of [if]
) (* end of [loop] *)
//
in
  loop(A, fwork, asz, 0); cfun_free(fwork)
end // end of [PHParray_foreach]

(* ****** ****** *)

implement
PHParray_streamize_elt
  {a}(A) =
  auxmain(asz, 0) where
{
//
val [n:int] asz = A.size()
//
fun
auxmain
{n:int}
{i:nat|i <= n}
(
 n: int(n), i: int(i)
) : stream_vt(a) = $ldelay
(
if i < n
  then
  stream_vt_cons
    (A[i], auxmain(n, i+1))
  // then
  else stream_vt_nil((*void*))
// end of [if]
) (* end of [auxmain] *)
//
} (* end of [PHParray_streamize_elt] *)

(* ****** ****** *)

(* end of [PHParray.dats] *)
