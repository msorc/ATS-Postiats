(* ****** ****** *)
//
// Numbering input lines
//
// Author: Hongwei Xi (January, 2013)
//
(* ****** ****** *)
//
#include "share/atspre_staload.hats"
//
(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

(* ****** ****** *)
//
// HX-2026-10: no GC
// the lines are kept in a linear list
//
implement
main () = let
//
fun loop
(
  xs: List0_vt (Strptr1), n: int
) : void = let
in
//
case+ xs of
| ~list_vt_cons
    (x, xs) => let
    val x0 = g1ofg0 ($UN.strptr2string (x))
    val islast =
    (
      case+ xs of
      | list_vt_nil () => true | list_vt_cons _ => false
    ) : bool // end of [val]
    val hasmore =
    (
      if islast
        then string_isnot_empty (x0) else true
      // end of [if]
    ) : bool // end of [val]
    val () =
    if hasmore then
    {
      val () = if n > 0 then print_char ('\n')
      val () = print_int (n+1)
      val () = print_string (":\t")
      val () = print_string (x0)
    } // end of [if] // end of [val]
    val () = strptr_free (x)
  in
    loop (xs, n+1)
  end // end of [list_vt_cons]
| ~list_vt_nil () => ()
//
end // end of [loop]
//
val lines =
  fileref_get_lines_stringlst (stdin_ref)
val () = loop (lines, 0)
val () = print_newline ()
//
in
  0(*normal*)
end // end of [main]

(* ****** ****** *)

(* end of [linenmbr.dats] *)
