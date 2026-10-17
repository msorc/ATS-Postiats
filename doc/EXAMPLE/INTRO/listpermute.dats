(* ****** ****** *)
//
// Enumerate all of
// the permutations of a list
//
// Author: Hongwei Xi (February, 2014)
//
(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
#staload UN = $UNSAFE // aliasing
//
(* ****** ****** *)
//
// HX-2026-10: no GC
// the permutations are linear lists
//
vtypedef intlst = List0_vt(int)
vtypedef intlstlst = List0_vt(intlst)
//
(* ****** ****** *)
//
fun
nth (xs: !intlst, i: int): int =
(
case+ xs of
| list_vt_nil () => 0 // HX: deadcode
| list_vt_cons (x, xs1) => if i > 0 then nth (xs1, i-1) else x
) (* end of [nth] *)
//
// HX: a copy of [xs] without its i-th element
//
fun
copy_without (xs: !intlst, i: int): intlst =
(
case+ xs of
| list_vt_nil () => list_vt_nil ()
| list_vt_cons (x, xs1) =>
    if i > 0
      then list_vt_cons (x, copy_without (xs1, i-1))
      else list_vt_copy<int> (xs1)
    // end of [if]
) (* end of [copy_without] *)
//
fun
list_mcons (x0: int, xss: intlstlst): intlstlst =
(
case+ xss of
| ~list_vt_nil () => list_vt_nil ()
| ~list_vt_cons (xs, xss) =>
    list_vt_cons (list_vt_cons (x0, xs), list_mcons (x0, xss))
  // end of [list_vt_cons]
) (* end of [list_mcons] *)
//
fun
listpermute (xs: !intlst): intlstlst = let
//
val n = list_vt_length (xs)
//
fun
loop (xs: !intlst, i: int): intlstlst =
(
if
(i < n)
then let
  val x = nth (xs, i)
  val xs1 = copy_without (xs, i)
  val xss1 = list_mcons (x, listpermute (xs1))
  val () = list_vt_free<int> (xs1)
in
  list_vt_append<intlst> (xss1, loop (xs, i+1))
end // end of [then]
else list_vt_nil ()
) (* end of [loop] *)
//
in
//
if n = 0
  then list_vt_cons (list_vt_nil (), list_vt_nil ())
  else loop (xs, 0)
//
end // end of [listpermute]
//
fun
intlstlst_print (xss: !intlstlst): void =
(
case+ xss of
| list_vt_nil () => ()
| @list_vt_cons (xs, xss1) => let
    val () = fprint_list_vt<int> (stdout_ref, xs)
    val () = print_newline ()
    val () = intlstlst_print (xss1)
  in
    fold@ (xss)
  end // end of [list_vt_cons]
) (* end of [intlstlst_print] *)
//
fun
intlstlst_free (xss: intlstlst): void =
(
case+ xss of
| ~list_vt_nil () => ()
| ~list_vt_cons (xs, xss) =>
    (list_vt_free<int> (xs); intlstlst_free (xss))
  // end of [list_vt_cons]
) (* end of [intlstlst_free] *)
//
(* ****** ****** *)

implement
main0 () =
{
//
val xs =
  list_make_intrange (0, 4)
val xs = $UN.castvwtp0{intlst}(xs)
//
val xss = listpermute (xs)
//
val () = print! ("permute(")
val () = fprint_list_vt<int> (stdout_ref, xs)
val () = print! (") =\n")
val () = intlstlst_print (xss)
//
val () = list_vt_free<int> (xs)
val () = intlstlst_free (xss)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [listpermute.dats] *)
