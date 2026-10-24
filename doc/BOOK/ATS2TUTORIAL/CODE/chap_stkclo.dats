(*
** For ATS2TUTORIAL
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)
//
typedef res = double
//
(* ****** ****** *)
//
// HX-2026-10: no GC
// the arrays are given by pointers to their
// contents (instead of arrayrefs)
//
macdef
get_at(A, i) = $UNSAFE.ptr0_get_at_int<res>(,(A), ,(i))
//
(* ****** ****** *)
//
fun
{res:t@ype}
ifold{n:nat}
(
  n: int(n)
, fopr: &(res, natLt(n)) -<clo1> res, ini: res
) : res = let
//
fun
loop
{i:nat | i <= n} .<n-i>.
(
  i: int(i)
, fopr: &(res, natLt(n)) -<clo1> res, res: res
) : res =
  if i < n
    then loop(i+1, fopr, fopr(res, i)) else res
  // end of [if]
//
in
  loop(0, fopr, ini)
end // end of [ifold]
//
(* ****** ****** *)
//
fun
dotprod
  {n:nat}
(
  n: int(n)
, A: ptr, B: ptr
) : res = let
//
var
fopr =
lam@(res: res, i: natLt(n)): res => res + get_at(A, i)*get_at(B, i)
//
in
  ifold<res>(n, fopr, 0.0)
end // end of [dotprod]
//
(* ****** ****** *)

implement
main0 () = () where
{
//
val N = 3
var A = @[res](1.0, 2.0, 3.0)
//
val res =
dotprod(N, addr@A, addr@A)
val ((*void*)) = println! ("1.0*1.0+2.0*2.0+3.0*3.0 = ", res)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [chap_stkclo.dats] *)
