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
// HX-2026-10: no GC
// closures are linear (cloptr) and freed explicitly
//
(* ****** ****** *)

extern
fun{
a:t@ype}{b:t@ype
} list_map_cloptr{n:int}
  (xs: !list_vt (a, n), f: !(a) -<cloptr> b): list_vt (b, n)

(* ****** ****** *)

implement
{a}{b}(*tmp*)
list_map_cloptr (xs, f) =
(
case+ xs of
| list_vt_nil () => list_vt_nil ()
| list_vt_cons (x, xs1) =>
    list_vt_cons (f (x), list_map_cloptr<a><b> (xs1, f))
  // end of [list_vt_cons]
) (* end of [list_map_cloptr] *)

(* ****** ****** *)

fun foo{n:int}
(
  x0: int, xs: !list_vt (int, n)
) : list_vt (int, n) = res where
{
//
val f = lam (x: int): int =<cloptr> x0 + x
val res = list_map_cloptr (xs, f)
val () = cloptr_free ($UNSAFE.castvwtp0{cloptr(void)}(f))
//
} (* end of [foo] *)

(* ****** ****** *)

val xs =
$list_vt{int}(0, 1, 2, 3, 4)
val () = println! ("xs = ", xs)
val ys = foo (5, xs)
val () = println! ("ys = ", ys)
val () = list_vt_free (xs)
val () = list_vt_free (ys)

(* ****** ****** *)

fun
acker(m:int, n:int): int =
(
  case+ (m, n) of
  | (0, _) => n + 1
  | (m, 0) => acker (m-1, 1)
  | (_, _) => acker (m-1, acker (m, n-1))
) (* end of [acker] *)

(* ****** ****** *)
//
// HX-2026-10:
// a curried function such as
// [fun acker2 (m:int) (n:int): int = acker (m, n)]
// would create a cloref closure; the linear version
// returns a cloptr closure that must be freed
//
fun acker3 (m:int) = lam (n:int): int =<cloptr1> acker (m, n)
//
val () = let
  val f = acker3 (3)
  val () = println! ("acker3(3)(4) = ", f(4))
in
  cloptr_free ($UNSAFE.castvwtp0{cloptr(void)}(f))
end // end of [val]

(* ****** ****** *)

implement main0 () = {}

(* ****** ****** *)

(* end of [chap_cloptr.dats] *)
