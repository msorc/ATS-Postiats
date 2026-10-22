(*
** A simple implementation
** of tokenization based on jsonats
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

%{^
#define \
atstyarr_field_undef(fname) fname[]
%} // end of [%{]

(* ****** ****** *)
//
#include "./../mylibies.hats"
#include "./../mylibies_link.hats"
#staload $JSONATS // opening it!
//
(* ****** ****** *)
//
#define
HX_CSTREAM_targetloc
"\
$PATSHOME/contrib\
/atscntrb/atscntrb-hx-cstream"
//
(* ****** ****** *)
//
#staload _ =
"libats/DATS/stringbuf.dats"
//
#include
"{$HX_CSTREAM}/mylibies.hats"
#include
"{$HX_CSTREAM}/mylibies_link.hats"
//
#staload $CSTREAM // opening it
#staload $CSTOKENER // opening it
//
(* ****** ****** *)

implement
main0 (argc, argv) =
{
//
val fname =
(
if argc >= 2
  then argv[1] else "test01.dats"
// end of [if]
) : string
//
val-~Some_vt(inp) =
fileref_open_opt (fname, file_mode_r)
val cs0 = cstream_make_fileref (inp)
//
val tknr =
  tokener_make_cstream (cs0)
//
fun
loop
(
  tknr: !tokener(token)
) : void = let
  val tok = tokener_get_token<token> (tknr)
  val () = fprintln! (stdout_ref, "tok = ", tok)
  val iseof = (case+ tok of TOKeof () => true | _ => false): bool
  val () = token_free (tok)
in
  if iseof then () else loop (tknr)
end // end of [loop]
//
val () = loop (tknr)
//
val ((*void*)) = tokener_free (tknr)
//
val ((*void*)) = fileref_close (inp)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [test01.dats] *)
