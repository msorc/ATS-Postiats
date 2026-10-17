(* ****** ****** *)
//
// CATS-parsemit
//
(* ****** ****** *)
//
// HX-2014-07-02: start
//
(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload _ = "libats/DATS/arena.dats"
staload "./../SATS/catsparse.sats"

(* ****** ****** *)
//
//
// HX-2026-10: no GC
// a symbol is a pair @(name, stamp) in the global arena
//
typedef symrec = @(string, int)
//
assume symbol_type = ptr
//
implement
symbol_get_name
  (sym) = $effmask_all((arena_load<symrec>(sym)).0)
//
implement
eq_symbol_symbol
  (x1, x2) = ($UNSAFE.cast{intptr}(x1) = $UNSAFE.cast{intptr}(x2))
//
(* ****** ****** *)

local
//
staload SYMCNT =
{
//
#staload _(*anon*) =
"prelude/DATS/integer.dats"
//
#define
HX_GLOBALS_targetloc
"\
$PATSHOME/contrib\
/atscntrb/atscntrb-hx-globals"
#include
"{$HX_GLOBALS}/HATS/gcount.hats"
//
} (* end of [staload] *)

(* ****** ****** *)

staload SYMBOL =
{
//
#staload
"./../SATS/catsparse.sats"
//
typedef key = string
typedef itm = symbol
//
#define CAPACITY 4096
//
#staload
"libats/SATS/hashtbl_linprb.sats"
//
implement
hashtbl$recapacitize<> ((*void*)) = 1
//
#define
HX_GLOBALS_targetloc
"\
$PATSHOME/contrib\
/atscntrb/atscntrb-hx-globals"
#include
"{$HX_GLOBALS}/HATS/ghashtbl_linprb.hats"
//
} (* end of [staload] *)

in (* in-of-local *)

implement
symbol_make(name) = let
//
val pt = $SYMBOL.search_ref (name)
//
in
//
if isneqz(pt)
  then $UNSAFE.p2tr_get<symbol> (pt)
  else let
    val n = $SYMCNT.getinc ()
    val name = the_garena_strdup(name)
    val p = the_garena_alloc(sizeof<symrec>)
    val () = arena_store<symrec>(p, @(name, n))
    val sym = $UNSAFE.cast{symbol}(p)
    val-~None_vt() = $SYMBOL.insert_opt (name, sym)
  in
    sym
  end // end of [else]
//
end // end of [symbol_make]

end // end of [local]

(* ****** ****** *)

implement
fprint_symbol
  (out, x) = let
  val sr = arena_load<symrec>(x)
in
  fprint! (out, sr.0, "(", sr.1, ")")
end // end of [fprint_symbol]

(* ****** ****** *)

(* end of [catsparse_symbol.dats] *)
