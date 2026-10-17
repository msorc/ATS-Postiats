(*
** For ATS2TUTORIAL
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

//
// HX-2026-10: no GC
// a symbol is a flat value (no heap allocation);
// the table of symbols is a linear hashtable that
// lives as long as the program (it is never freed)
//
staload UN = $UNSAFE
//
staload "libats/SATS/hashtbl_chain.sats"
//
staload _(*anon*) = "libats/DATS/hashfun.dats"
staload _(*anon*) = "libats/DATS/linmap_list.dats"
staload _(*anon*) = "libats/DATS/hashtbl_chain.dats"
//
abst@ype symbol = @(string, int)
//
extern
fun symbol_eq (symbol, symbol): bool
extern
fun symbol_neq (symbol, symbol): bool
//
extern
fun fprint_symbol : fprint_type(symbol)  
//
overload = with symbol_eq
overload != with symbol_neq
overload fprint with fprint_symbol
//
implement
fprint_val<symbol> = fprint_symbol
//
extern
fun symbol_make_name(string): symbol
//
local
//
assume symbol = @(string, int)
//
typedef key = string and itm = int
//
var theCount: int = 0
prval pfbox = vbox_make_view{int @ theCount}(view@(theCount))
//
val theSymtbl =
$UN.castvwtp0{ptr}(hashtbl_make_nil<key,itm>(i2sz(1024)))
//
fun
symtbl_search
  (name: key): Option_vt(itm) = let
  val tbl = $UN.castvwtp0{hashtbl(key,itm)}(theSymtbl)
  val res = hashtbl_search_opt<key,itm> (tbl, name)
  prval () = $UN.cast2void (tbl)
in
  res
end // end of [symtbl_search]
//
fun
symtbl_insert
  (name: key, n: itm): void = let
  val tbl = $UN.castvwtp0{hashtbl(key,itm)}(theSymtbl)
  val () = hashtbl_insert_any<key,itm> (tbl, name, n)
  prval () = $UN.cast2void (tbl)
in
  // nothing
end // end of [symtbl_insert]
//
in (*in-of-local*)
//
implement
symbol_eq (x1, x2) = x1.1 = x2.1
implement
symbol_neq (x1, x2) = x1.1 != x2.1
//
implement
fprint_symbol
  (out, x) = fprint! (out, "SYMBOL(", x.0, ", ", x.1, ")")
//
implement
symbol_make_name
  (name) = let
//
val opt = symtbl_search(name)
//
in
  case+ opt of
  | ~Some_vt(n) => @(name, n)
  | ~None_vt() => let
      val n = let
        prval vbox(pf) = pfbox
        val n = $effmask_ref(ptr_get<int>(pf | addr@(theCount)))
        val () = $effmask_ref(ptr_set<int>(pf | addr@(theCount), n + 1))
      in
        n
      end // end of [val]
      val () = symtbl_insert(name, n)
    in
      @(name, n)
    end // end of [None_vt]
end // end of [symbol_make_name]
//
end // end of [local]
//
val sym0 = symbol_make_name("potato")
val sym0 = symbol_make_name("potato")
//
val sym1 = symbol_make_name("tomato")
val sym1 = symbol_make_name("tomato")
//
val sym2 = symbol_make_name("cucumber")
val sym2 = symbol_make_name("cucumber")
//
val sym3 = symbol_make_name("zucchini")
val sym3 = symbol_make_name("zucchini")
//
val out = stdout_ref
val ((*void*)) = fprintln! (out, "sym0 = ", sym0)
val ((*void*)) = fprintln! (out, "sym1 = ", sym1)
val ((*void*)) = fprintln! (out, "sym2 = ", sym2)
val ((*void*)) = fprintln! (out, "sym3 = ", sym3)
//
implement main0 () = {}

(* ****** ****** *)

(* end of [chap_hashtable2.dats] *)
