(*
** A simple implementation
** of tokenization based on cstream
*)

(* ****** ****** *)

(*
** Author: HX-2014-01-09 (gmhwxiATgmailDOTcom)
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

#staload
UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)
//
#staload "libats/SATS/stringbuf.sats"
//
#staload _ = "libats/DATS/stringbuf.dats"
//
(* ****** ****** *)
//
#include
"./../mylibies.hats"
//
#staload $CSTREAM
#staload $CSTOKENER
//
(* ****** ****** *)

#include
"./../mylibies_link.hats"

(* ****** ****** *)

//
// HX-2026-10: no GC
// tokens are linear
//
datavtype token =
  | TOKide of Strptr1
  | TOKint of int
  | TOKlparen of ()
  | TOKrparen of ()
  | TOKerr of (int)
  | TOKeof of ((*void*))
// end of [token]

(* ****** ****** *)

extern
fun fprint_token
  (out: FILEref, x: !token): void
extern
fun token_free (x: token): void
overload fprint with fprint_token

(* ****** ****** *)

implement
fprint_token (out, x) =
(
case+ x of
//
| TOKide(ide) =>
    fprint! (out, "TOKide(", $UN.strptr2string(ide), ")")
| TOKint(int) =>
    fprint! (out, "TOKint(", int, ")")
//
| TOKlparen() => fprint! (out, "TOKlparen(", ")")
| TOKrparen() => fprint! (out, "TOKrparen(", ")")
//
| TOKerr(int) => fprint! (out, "TOKerr(", int, ")")
| TOKeof((*void*)) => fprint! (out, "TOKeof(", ")")
) (* end of [fprint_token] *)

(* ****** ****** *)

implement
token_free (x) =
(
case+ x of
| ~TOKide(ide) => strptr_free(ide)
| ~TOKint _ => ()
| ~TOKlparen() => ()
| ~TOKrparen() => ()
| ~TOKerr _ => ()
| ~TOKeof() => ()
) (* end of [token_free] *)

implement
tokener$token_free<token> (x) = token_free (x)

(* ****** ****** *)
//
#define c2i char2int0
#define i2c int2char0
//
fun isalnum_ (x: int): bool =
  let val x = i2c(x) in isalnum(x) || (x = '_') end
//
(* ****** ****** *)
//
extern
fun
tokener_get_ide
(
  !cstream, i0: &int >> _, sbf: !stringbuf
) : Strptr1 // end of [tokener_get_ide]
//
implement
tokener_get_ide
  (cs0, i0, sbf) = let
//
fun loop
(
  cs0: !cstream
, sbf: !stringbuf
) : int = let
//
val i = cstream_get_char(cs0)
//
in
//
if i >= 0 then
(
//
if
isalnum_(i)
then let
//
val c = $UN.cast{charNZ}(i)
val _ =
  stringbuf_insert(sbf, c) in loop(cs0, sbf)
//
end // end-of-then
else (i) // end-of-else
//
) else (i)
//
end // end of [tokener_get_ide]
//
val _ =
  stringbuf_insert(sbf, $UN.cast{charNZ}(i0))
//
val () = i0 := loop(cs0, sbf)
//
in
  stringbuf_truncout_all (sbf)
end // end of [tokener_get_ide]

(* ****** ****** *)

extern
fun
tokener_get_int
  (!cstream, i0: &int >> _, !stringbuf): int
//
implement
tokener_get_int
  (cs0, i0, sbf) = let
//
fun loop
(
  cs0: !cstream, res: &int >> _
) : int = let
  val i = cstream_get_char (cs0)
in
//
if i >= 0 then
(
  if isdigit (i)
    then let
      val d = i2c(i) - '0'
      val () = res := 10*res+d
    in
      loop (cs0, res)
    end // end-of-then
    else (i) // end-of-else
) else (i)
//
end // end of [loop]
//
var res: int = (i2c(i0) - '0')
val ((*void*)) = i0 := loop (cs0, res)
//
in
  res
end // end of [tokener_get_int]

(* ****** ****** *)
//
%{^
#define LPAREN '('
#define RPAREN ')'
%}
//
macdef LPAREN = $extval (int, "LPAREN")
macdef RPAREN = $extval (int, "RPAREN")
//
(* ****** ****** *)
//
extern
fun cstream_WS_skip
  (cs0: !cstream, i0: &int >> _): void
//
implement
cstream_WS_skip
  (cs0, i0) = let
//
fun loop
  (cs0: !cstream): int = let
  val c = cstream_get_char (cs0)
in
  if isspace (c) then loop (cs0) else c
end // end of [loop]
//
in
  if isspace (i0) then i0 := loop (cs0)
end // end of [cstream_WS_skip]
//
(* ****** ****** *)

implement
tokener_get_token$main<token>
  (cs0, i0, sbf) = let
//
val () = cstream_WS_skip (cs0, i0)
//
in
//
if (
i0 >= 0
) then (
case+ 0 of
| _ when
    (i0 = LPAREN) => let
    val () = i0 := cstream_get_char (cs0)
  in
    TOKlparen ()
  end
| _ when
    (i0 = RPAREN) => let
    val () = i0 := cstream_get_char (cs0)
  in
    TOKrparen ()
  end
| _ when
    isalpha (i0) => let
    val ide = tokener_get_ide (cs0, i0, sbf)
  in
    TOKide (ide)
  end
| _ when
    isdigit (i0) => let
    val int = tokener_get_int (cs0, i0, sbf)
  in
    TOKint (int)
  end
| _ (*unrecogized*) => let
    val i1 = i0
    val () = i0 := cstream_get_char (cs0)
  in
    TOKerr (i1)
  end
) else (
  TOKeof(*void*)
) (* end of [if] *)
//
end // end of [tokener_get_token$main]

(* ****** ****** *)

implement
main0 (argc, argv) =
{
//
val fname =
(
if argc >= 2
  then argv[1] else "tokener.dats"
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
  val () = (print! ("tok = "); fprint_token (stdout_ref, tok); print_newline ())
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

(* end of [tokener.dats] *)
