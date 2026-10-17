(* ****** ****** *)
//
// CATS-parsemit
//
(* ****** ****** *)
//
// HX-2015-05-20
//
(* ****** ****** *)
//
#define
ATS_MAINATSFLAG 1
//
#define
ATS_DYNLOADNAME "catsparse_all_dynload"
//
(* ****** ****** *)

local #include "./DATS/catsparse_mylib.dats" in (*nothing*) end
(* ****** ****** *)
//
// HX-2026-10: the arena encoding of the syntax
//
local
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "libats/SATS/arena.sats"
staload _ = "libats/DATS/arena.dats"
staload "./SATS/catsparse.sats"
staload "./SATS/catsparse_parsing.sats"
in
#include "./DATS/catsparse_gen.hats"
#include "./DATS/catsparse_parsing_gen.hats"
end // end of [local]

(* ****** ****** *)
//
local #include "./DATS/catsparse_error.dats" in (*nothing*) end
local #include "./DATS/catsparse_print.dats" in (*nothing*) end
//
local #include "./DATS/catsparse_symbol.dats" in (*nothing*) end
//
local #include "./DATS/catsparse_fname.dats" in (*nothing*) end
local #include "./DATS/catsparse_posloc.dats" in (*nothing*) end
//
local #include "./DATS/catsparse_global.dats" in (*nothing*) end
//
local #include "./DATS/catsparse_syntax.dats" in (*nothing*) end
//
local #include "./DATS/catsparse_lexerr.dats" in (*nothing*) end
local #include "./DATS/catsparse_lexbuf.dats" in (*nothing*) end
local #include "./DATS/catsparse_lexing.dats" in (*nothing*) end
local #include "./DATS/catsparse_tokbuf.dats" in (*nothing*) end
//
local #include "./DATS/catsparse_parerr.dats" in (*nothing*) end
local #include "./DATS/catsparse_parsing.dats" in (*nothing*) end
local #include "./DATS/catsparse_parsing_d0exp.dats" in (*nothing*) end
local #include "./DATS/catsparse_parsing_d0ecl.dats" in (*nothing*) end
local #include "./DATS/catsparse_parsing_instr.dats" in (*nothing*) end
//
local #include "./DATS/catsparse_emit.dats" in (*nothing*) end
local #include "./DATS/catsparse_typedef.dats" in (*nothing*) end
local #include "./DATS/catsparse_fundecl.dats" in (*nothing*) end
//
(* ****** ****** *)

(* end of [catsparse_all.dats] *)
