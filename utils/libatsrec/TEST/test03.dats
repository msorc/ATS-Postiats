(* ****** ****** *)
(*
** For testing libatsrec
*)
(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)
//
macdef
streamize_fileref_line =
streamize_fileref_line
//
(* ****** ****** *)
//
(* ****** ****** *)
//
#include "./../mylibies.hats"
//
#staload $LIBATSREC // opening it
#staload $STRINGBUF // opening it
//
#include "./../mylibies_link.hats"
//
(* ****** ****** *)

implement
main0(argc, argv) =
fileref_close(inp) where
{
//
val opt =
fileref_open_opt
  ("DATA/theQuestionDB.arec", file_mode_r)
val-
~Some_vt(inp) = opt
//
val xs = streamize_fileref_atsrec(inp)
//
val ((*void*)) =
stream_vt_foreach_cloptr
(
  xs
, lam(x) =>
  (fprint_atsrec(stdout_ref, x); print_newline(); atsrec_free(x))
) (* stream_vt_foreach_cloptr *)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [test03.dats] *)
