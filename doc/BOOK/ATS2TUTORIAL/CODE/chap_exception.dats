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
//
// HX-2026-10: no GC
// the list is borrowed and the predicate is
// a (stack-allocated) closure passed by reference
//
extern
fun{a:t@ype}
list_find_rightmost
  (!List_vt (a), &((a) -<clo1> bool)): Option_vt (a)
//
(* ****** ****** *)

implement{a}
list_find_rightmost
  (xs, pred) = let
//
fun aux
(
  xs: !List_vt(a), pred: &((a) -<clo1> bool)
) : Option_vt (a) =
  case+ xs of
  | list_vt_nil () => None_vt ()
  | list_vt_cons (x, xs) => let
      val res = aux (xs, pred)
    in
      case+ res of
      | Some_vt _ => res
      | ~None_vt () =>
          if pred (x) then Some_vt (x) else None_vt ()
        // end of [None]
    end (* end of [cons] *)
//
in
  aux (xs, pred)
end // end of [list_find_rightmost]

(* ****** ****** *)

//
// HX-2026-10:
// a linear value cannot be used inside [try]
// unless it is local to it (as raising an exception
// would otherwise abandon it); so the exception-based
// search is shown here on integers instead of a list
//
extern
fun
int_find_rightmost
  (n: int, pred: (int) -<fun1> bool): Option_vt (int)
//
implement
int_find_rightmost
  (n, pred) = let
//
exception Found of (int)
//
fun aux
(
  i: int
) : void =
  if i < n then let
    val () = aux (i+1)
  in
    if pred (i) then $raise Found(i) else ()
  end // end of [if]
//
in
//
try let
  val () = aux (0)
in
  None_vt ()
end with
  | ~Found(x) => Some_vt (x)
//
end // end of [int_find_rightmost]

(* ****** ****** *)

implement
main0 () = () where
{
//
val xs = $list_vt{int}(0, 1, 2, 3, 4, 5)
//
var pred =
  lam@ (x: int): bool =<clo1> (0 <= x && x <= 4)
//
val-~Some_vt(4) =
  list_find_rightmost<int> (xs, pred)
//
val-~Some_vt(4) =
  int_find_rightmost (6, lam (x) =<fun1> (0 <= x && x <= 4))
//
//
val () = list_vt_free (xs)
//
val () = println! ("The code has passed minimal testing.")
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [chap_exception.dats] *)

