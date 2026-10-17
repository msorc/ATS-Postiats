(*
** Syntax-hiliting ATS code
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)
//
staload
UN =
"prelude/SATS/unsafe.sats"
//
(* ****** ****** *)

staload
STDLIB =
"libats/libc/SATS/stdlib.sats"

(* ****** ****** *)

#define BUFSZ 1024

(* ****** ****** *)

typedef charptr = $extype"char*"

(* ****** ****** *)
//
#define MVF "mv -f"
//
#define
MYTEXTING "./../MYTEXT/bin/mytexting"
//
(* ****** ****** *)

fun
process_one
(
  inp: string
) : void = let
//
var buf = @[byte][BUFSZ]()
//
val inp = $UN.cast{charptr}(inp)
val bufp = $UN.cast{charptr}(addr@buf)
//
val
_(*int*) =
$extfcall
( int
, "snprintf"
, bufp, BUFSZ, "%s %s %s.bak", MVF, inp, inp
) (* $extfcall *)
val () =
  fprintln! (stdout_ref, $UN.cast{string}(bufp))
val () =
  ignoret($STDLIB.system($UN.cast{string}(bufp)))
//
val
_(*int*) =
$extfcall
( int
, "snprintf"
, bufp, BUFSZ
, "%s -ns 12 --output %s --input %s.bak"
, MYTEXTING, inp, inp
) (* $extfcall *)
val () =
  fprintln! (stdout_ref, $UN.cast{string}(bufp))
val () =
  ignoret($STDLIB.system($UN.cast{string}(bufp)))
//
in
  // nothing
end // end of [process_one]

(* ****** ****** *)

implement
main0{n}
(
  argc, argv
) = let
//
fun
loop
(
  argv: !argv(n), i: natLte(n)
) : void =
(
  if i < argc
    then (process_one(argv[i]); loop(argv, i+1))
  // end of [if]
)
//
in
  loop(argv, 1)
end (* end of [main0] *)

(* ****** ****** *)

(* end of [synhilit.dats] *)
