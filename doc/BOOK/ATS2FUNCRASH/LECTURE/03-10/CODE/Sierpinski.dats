(* ****** ****** *)
//
// The ATS part and the JS part of the Sierpinski triangle:
// the code is for the JS backend (libatscc2js) and it is only
// type-checked here (see the Makefile): patsopt --typecheck -d
//
(* ****** ****** *)
//
abstype point // abstract type for points
//
(* ****** ****** *)
//
extern
fun
midpoint(A: point, B: point): point = "mac#"
//
extern
fun
TriangleRemove
  (A: point, B: point, C: point): void = "mac#"
//
extern
fun
SierpinskiDraw
( n: int
, A: point, B: point, C: point): void = "mac#"
//
(* ****** ****** *)
//
implement
SierpinskiDraw
(n, A, B, C) = (
//
if
(n > 0)
then let
//
val AB = midpoint(A, B)
val BC = midpoint(B, C)
val CA = midpoint(C, A)
//
val () = TriangleRemove(AB, BC, CA)
//
val () = SierpinskiDraw(n-1, A, AB, CA)
val () = SierpinskiDraw(n-1, B, BC, AB)
val () = SierpinskiDraw(n-1, C, CA, BC)
//
in
  // nothing
end // end of [then]
else () // end of [else]
//
) (* end of [SierpinskiDraw] *)
//
(* ****** ****** *)
//
%{
//
function
TriangleRemove
 (A, B, C)
{
  theCtx.save();
//
  theCtx.beginPath();
  theCtx.moveTo(A.x, A.y);
  theCtx.lineTo(B.x, B.y);
  theCtx.lineTo(C.x, C.y);
  theCtx.closePath();
//
  theCtx.fill();
//
  theCtx.restore();
} // end of [TriangleRemove]
//
%}
//
(* ****** ****** *)
//
%{
//
function
midpoint
(p1, p2)
{
//
  var
  xmid = (p1.x + p2.x)/2;
  var
  ymid = (p1.y + p2.y)/2;
//
  return { x: xmid, y: ymid };
//
}
//
%}
//
(* ****** ****** *)

(* end of [Sierpinski.dats] *)
