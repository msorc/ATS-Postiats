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
val tup_flat = @("a", "b")
//
val-"a" = tup_flat.0 and "b" = tup_flat.1
//
// HX-2026-10:
// boxed tuples are no longer supported (no GC)
//
//
(* ****** ****** *)
//
//
// HX-2026-10: no GC
// a point is a linear object that is freed explicitly
//
absvtype point = ptr
//
extern
fun
point_make
  (x: double, y: double): point
extern
fun
point_free (p: point): void
//
extern
fun point_get_x (p: !point): double
and point_get_y (p: !point): double
//
extern
fun point_set_x (p: !point, x: double): void
and point_set_y (p: !point, x: double): void
//
local
//
datavtype
point_rep = POINT of (double, double)
//
assume point = point_rep
//
in (* end of [local] *)

implement
point_make (x, y) = POINT (x, y)
implement
point_free (p) = let val~POINT (_, _) = p in (*none*) end

implement
point_get_x (p) = let val+POINT (x, _) = p in x end
implement
point_get_y (p) = let val+POINT (_, y) = p in y end

implement
point_set_x (p, x) =
  let val+@POINT (x0, _) = p in x0 := x; fold@(p) end
implement
point_set_y (p, y) =
  let val+@POINT (_, y0) = p in y0 := y; fold@(p) end

end // end of [local]
//
extern
fun print_point (!point): void
extern
fun fprint_point (FILEref, !point): void
//
overload print with print_point
overload fprint with fprint_point
//
symintr .x .y
overload .x with point_get_x
overload .x with point_set_x
overload .y with point_get_y
overload .y with point_set_y
//
implement
print_point
  (p) = fprint_point (stdout_ref, p)
//
implement
fprint_point (out, p) =
  fprint! (out, "(x=", p.x(), ", y=", p.y(), ")")
//
(* ****** ****** *)
//
val p0 = point_make (1.0, ~1.0)
//
val x0 = p0.x() // point_get_x (p0)
and y0 = p0.y() // point_get_y (p0)
val () = (print! ("p0 = "); print_point (p0); print_newline ())
//
//
// HX-2026-10:
// [p0.x := y0] is not supported for a linear [p0]
//
val () = point_set_x (p0, y0)
and () = point_set_y (p0, x0)
val () = (print! ("p0 = "); print_point (p0); print_newline ())
//
val () = point_free (p0)
//
(* ****** ****** *)
//
// HX: a variant of the above code
//
val p0 = point_make (1.0, ~1.0)
val x0 = p0.x() // point_get_x (p0)
and y0 = p0.y() // point_get_y (p0)
val () = (print! ("p0 = "); print_point (p0); print_newline ())
//
val () = p0.x(y0) // point_set_x (p0, y0)
and () = p0.y(x0) // point_set_y (p0, x0)  
val () = (print! ("p0 = "); print_point (p0); print_newline ())
//
val () = point_free (p0)
//
(* ****** ****** *)
//
absvtype counter = ptr
//
extern
fun counter_make (): counter
extern
fun counter_free (counter): void
//
extern
fun counter_get (cntr: !counter): int
extern
fun counter_incby (cntr: !counter, n: int): void
//
overload .get with counter_get
overload .incby with counter_incby
//
(* ****** ****** *)

local

(* ****** ****** *)

datavtype
counter2 = COUNTER of int

(* ****** ****** *)

assume counter = counter2

in (* in-of-local *)
//
implement
counter_make () = COUNTER (0)
//
implement
counter_free (cntr) =
  let val~COUNTER _ = cntr in (*none*) end
//
implement
counter_get (cntr) =
  let val+COUNTER (count) = cntr in count end
//
implement
counter_incby (cntr, n) =
  let val+@COUNTER (count) = cntr in count := count + n; fold@(cntr) end
//
end // end of [local]

(* ****** ****** *)

val c0 = counter_make()
val n0 = c0.get()
val () = c0.incby(1)
val n1 = c0.get()
val () = assertloc (n0 + 1 = n1)
val () = counter_free (c0)

(* ****** ****** *)

implement main0 () = ()

(* ****** ****** *)

(* end of [chap_dotoverld.dats] *)
