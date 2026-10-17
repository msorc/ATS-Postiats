(*
** For generating HTMLTOC
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
staload
STDLIB =
"libats/libc/SATS/stdlib.sats"
//
(* ****** ****** *)

#define BUFSZ 1024

(* ****** ****** *)

typedef charptr = $extype"char*"

(* ****** ****** *)

fun
fsed
(
  inp: string
) : void = let
//
var buf = @[byte][BUFSZ]()
//
val CAT = "cat"
val SED = "sed"
//
val inp = $UN.cast{charptr}(inp)
val bufp = $UN.cast{charptr}(addr@buf)
//
val script = "\
s/'><\\/BODY'/'><SCRIPT SRC=\".\\/assets\\/ATS2TUTORIAL-BOOK.js\"><\\/SCRIPT><\\/BODY'/\
" // end of [val]
//
val _(*int*) =
$extfcall(int
, "snprintf"
, bufp, BUFSZ, "%s %s | %s %s > HTMLTOC/%s"
, CAT, inp, SED, script, inp)
//
val ((*void*)) =
  fprintln! (stdout_ref, "fsed: command = ", $UN.cast{string}(bufp))
//
in
  ignoret($STDLIB.system($UN.cast{string}(bufp)))
end // end of [fsed]

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
    then (fsed(argv[i]); loop(argv, i+1))
  // end of [if]
)
//
in
  loop(argv, 1)
end (* end of [main0] *)

(* ****** ****** *)

(* end of [htmltoc.dats] *)
