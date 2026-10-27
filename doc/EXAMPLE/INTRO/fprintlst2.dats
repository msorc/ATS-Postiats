(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

(* ****** ****** *)
//
// HX-2026-10: no GC
// a list of lists is printed with the separator
// for the inner lists and the one for the outer list
//
fun
fprint_intlst
(
  out: FILEref, xs: !List0_vt(int)
) : void = let
//
implement
fprint_list_vt$sep<> (out) = fprint_string (out, ", ")
//
in
  fprint_list_vt<int> (out, xs)
end // end of [fprint_intlst]

fun
fprint_intlstlst
(
  out: FILEref, xss: !List0_vt(List0_vt(int)), i: int
) : void =
(
case+ xss of
| list_vt_nil () => ()
| @list_vt_cons (xs, xss1) => let
    val () = if i > 0 then fprint_string (out, "; ")
    val () = fprint_intlst (out, xs)
    val () = fprint_intlstlst (out, xss1, i+1)
  in
    // nothing
  end // end of [list_vt_cons]
) (* end of [fprint_intlstlst] *)

fun
intlstlst_free
(
  xss: List0_vt(List0_vt(int))
) : void =
(
case+ xss of
| ~list_vt_nil () => ()
| ~list_vt_cons (xs, xss) =>
    (list_vt_free<int> (xs); intlstlst_free (xss))
  // end of [list_vt_cons]
) (* end of [intlstlst_free] *)

(* ****** ****** *)

val () =
{
//
val out = stdout_ref
//
val xs1 = $list_vt{int}(0,1,2,3,4)
val xs2 = $list_vt{int}(5,6,7,8,9)
val xss = $list_vt{List0_vt(int)}(xs1, xs2)
//
val () = fprint_intlstlst (out, xss, 0)
val ((*void*)) = fprint_newline (out)
//
val () = intlstlst_free (xss)
//
} (* end of [val] *)

(* ****** ****** *)

implement
main0 () =
{
//
val () = println! ("The code has passed all the tests given here.")
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [fprintlst2.dats] *)
