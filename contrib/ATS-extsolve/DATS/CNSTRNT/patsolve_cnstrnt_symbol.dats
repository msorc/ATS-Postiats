(*
** ATS-extsolve:
** For solving ATS-constraints
** with external SMT-solvers
*)

(* ****** ****** *)

(*
** Author: Hongwei Xi
** Authoremail: gmhwxiATgmailDOTcom
*)

(* ****** ****** *)
//
// HX-2026-10: no GC
// A symbol is an interned astring; so symbols
// can be compared by their addresses. The symbol table
// maps names to symbols; the names in the table are
// astrings (cast to strings for hashing and comparison)
//
(* ****** ****** *)

#staload
"libats/SATS/hashfun.sats"
#staload
_(*anon*) = "libats/DATS/hashfun.dats"

(* ****** ****** *)

local
//
typedef key = string
//
implement
ahashtbl$hash<key>
  (k) = string_hash_multiplier(31UL, 61803UL, k)
implement
ahashtbl$equal<key>(k1, k2) = (k1 = k2)
//
in (* in-of-local *)
//
implement
symtbl_make_nil
  {l}(ar) =
  $UN.cast{symtbl(l)}
  (ahashtbl_make_nil<key,ptr>(ar, i2sz(1024)))
//
implement
symbol_make_name
  {l}(ar, tbl, name) = let
//
val tbl =
  $UN.cast{ahashtbl(l,key,ptr)}(tbl)
val opt =
  ahashtbl_search<key,ptr>(ar, tbl, name)
//
in
//
case+ opt of
| ~Some_vt(p) => $UN.cast{symbol(l)}(p)
| ~None_vt((*void*)) => let
    val str = astring_make(ar, name)
    val p_str = $UN.cast{ptr}(str)
    val () =
    ahashtbl_insert<key,ptr>
      (ar, tbl, $UN.cast{string}(p_str), p_str)
    // end of [val]
  in
    $UN.cast{symbol(l)}(p_str)
  end // end of [None_vt]
//
end // end of [symbol_make_name]
//
end // end of [local]

(* ****** ****** *)

implement
symbol_get_name
  {l}(ar, sym) = $UN.cast{astring(l)}(sym)

(* ****** ****** *)

implement
fprint_symbol
  (ar, out, sym) =
  astring_fprint(ar, out, symbol_get_name(ar, sym))
// end of [fprint_symbol]

(* ****** ****** *)
//
implement
eq_symbol_symbol
  (x1, x2) = ($UN.cast{ptr}(x1) = $UN.cast{ptr}(x2))
implement
neq_symbol_symbol
  (x1, x2) = ($UN.cast{ptr}(x1) != $UN.cast{ptr}(x2))
//
(* ****** ****** *)

(* end of [patsolve_cnstrnt_symbol.dats] *)
