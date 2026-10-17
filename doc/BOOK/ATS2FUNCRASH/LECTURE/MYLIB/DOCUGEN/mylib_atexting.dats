(* ****** ****** *)
(*
//
For mylib of ATS2FUNCRASH
//
*)
(* ****** ****** *)
//
#define
ATEXTING_targetloc
"$PATSHOME/utils/atexting"
#define
LIBATSREC_targetloc
"$PATSHOME/utils/libatsrec"
//
(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)
//
#include
"{$LIBATSREC}/mylibies.hats"
#include
"{$LIBATSREC}/mylibies_link.hats"
//
(* ****** ****** *)
//
#define MAIN_NONE 1
//
#include
"{$ATEXTING}/mylibies.hats"
#include
"{$ATEXTING}/mylibies_link.hats"
//
#staload $ATEXTING // opening it
#staload "libats/SATS/arena.sats" // HX-2026-10
#staload _ = "libats/DATS/arena.dats"
//
(* ****** ****** *)

val () = the_nsharp_set(2)

(* ****** ****** *)

fun
html_print
(cs: string): void = let
//
fun
charpr(c: char): void =
(
ifcase
//
| c = '<' => print("&lt;")
| c = '>' => print("&gt;")
//
| _(*else*) => print_char(c)
//
)
//
in
loop(string2ptr(cs)) where
{
  fun
  loop(p: ptr): void = let
    val c = $UNSAFE.ptr0_get<char>(p)
  in
    if c != '\000' then (charpr(c); loop(ptr_succ<char>(p)))
  end // end of [loop]
} (* end of [where] *)
end // end of [html_print]

(* ****** ****** *)
//
local
#include
"{$ATEXTING}\
/DATS/SHARE/atexting_textdef_pre.dats"
in
  // nothing
end // end of [local]
//
local
(*
#include
"{$ATEXTING}\
/DATS/SHARE/atexting_textdef_xhtml.dats"
*)
in
  // nothing
end // end of [local]
//
(* ****** ****** *)
//
//
// HX-2026-10: no GC
// an entry is a list of (key, value) pairs in the
// global arena; the DB is a linear hashtable that is
// kept as a pointer (it lives until the program exits)
//
typedef
myentry = glist(@(string, string))
//
fun
myentry_get
(
  ent: myentry, key: string
) : string =
(
case+ glist_view(ent) of
| ~GLnil() => ""
| ~GLcons(kv, ent) =>
    if kv.0 = key then kv.1 else myentry_get(ent, key)
)
//
(* ****** ****** *)
//
extern
fun
theDB_search
(
  name: string
) : Option_vt(myentry)
//
extern
fun
theDB_insert
  (name: string, myentry): void
//
(* ****** ****** *)
//
extern fun theDB_initize(): void
//
(* ****** ****** *)

local
//
typedef
key = string and itm = myentry
//
staload UN = "prelude/SATS/unsafe.sats"
staload "libats/SATS/hashtbl_chain.sats"
staload _ = "libats/DATS/qlist.dats"
staload _ = "libats/DATS/hashfun.dats"
staload _ = "libats/DATS/linmap_list.dats"
staload _ = "libats/DATS/hashtbl_chain.dats"
//
vtypedef map = hashtbl(key, itm)
//
var
theDB_var: ptr =
  $UN.castvwtp0{ptr}(hashtbl_make_nil<key,itm>(i2sz(1024)))
val
theDB =
  ref_make_viewptr{ptr}(view@theDB_var | addr@theDB_var)
//
in
//
implement
theDB_search(k) = opt where
{
  val tbl = $UN.castvwtp0{map}(theDB[])
  val opt = hashtbl_search_opt<key,itm>(tbl, k)
  val _ = $UN.castvwtp0{ptr}(tbl)
}
implement
theDB_insert(k, x) =
{
  val tbl = $UN.castvwtp0{map}(theDB[])
  val () = hashtbl_insert_any<key,itm>(tbl, k, x)
  val _ = $UN.castvwtp0{ptr}(tbl)
} (* end of [theDB_insert] *)
//
(* ****** ****** *)

implement
theDB_initize() = let
//
val opt =
fileref_open_opt
("./../mylib.arec", file_mode_r)
val-
~Some_vt(inp) = opt
//
// a record turned into an entry (its strings are
// copied into the global arena and then freed)
//
fun
entry_make
(
  kvs: $LIBATSREC.atsrec
) : myentry =
(
case+ kvs of
| ~list_vt_nil() => glist_nil()
| ~list_vt_cons(kv, kvs) => let
    val @(k, v) = kv
    val kv2 = @(strptr2gstring(k), strptr2gstring(v))
  in
    glist_cons<@(string,string)>(kv2, entry_make(kvs))
  end // end of [list_vt_cons]
)
//
fun
loop
(
  xs: stream_vt($LIBATSREC.atsrec)
) : void =
(
case+ !xs of
| ~stream_vt_nil() => ()
| ~stream_vt_cons(x0, xs) => let
    val ent = entry_make(x0)
    val name = myentry_get(ent, "name")
    val () =
    if name != "" then theDB_insert(name, ent)
  in
    loop(xs)
  end // end of [stream_vt_cons]
)
//
in
  loop($LIBATSREC.streamize_fileref_atsrec(inp))
end // end of [theDB_initize]

(* ****** ****** *)

end // end of [local]

(* ****** ****** *)

local
//

(* ****** ****** *)

fun
__interface__
(
l0: location
,
xs: atextlst
) : atext = res where
{
//
val-
~GLcons(x0, _) = glist_view(xs)
//
val x0 = atext_strngfy(x0)
val-
~Some_vt(ent) = theDB_search(x0)
//
val () =
print!("extern\n")
val () =
print!(myentry_get(ent, "interface"))
//
val res = atext_make_nil(l0)
//
} (* end of [__interface__] *)

fun
__implement__
(
l0: location
,
xs: atextlst
) : atext = res where
{
//
val-
~GLcons(x0, _) = glist_view(xs)
//
val x0 = atext_strngfy(x0)
val-
~Some_vt(ent) = theDB_search(x0)
//
val () =
print!(myentry_get(ent, "implement"))
//
val res = atext_make_nil(l0)
//
} (* end of [__implement__] *)

(* ****** ****** *)

fun
__html_dynfun__
(
l0: location
,
xs: atextlst
) : atext = res where
{
//
val-
~GLcons(x0, _) = glist_view(xs)
//
val x0 = atext_strngfy(x0)
val-
~Some_vt(ent) = theDB_search(x0)
//
val () =
print!("\
<div
 style=\"margin-top:20px;margin-bottom:20px\">\n")
//
val () =
print!("<center>\n")
val () =
print!
("<dynfun>", x0, "</dynfun>\n")
val () =
print!("</center>\n")
//
val () =
print!("\
<h2>Interface</h2>\n")
val () =
print!("<sats2xhtml>")
val () =
html_print(myentry_get(ent, "interface"))
val () = println!("</sats2xhtml>")
//
val () =
print!("\
<h2>Implementation</h2>\n")
val () =
print!("<dats2xhtml>")
val () =
html_print(myentry_get(ent, "implement"))
val () = println!("</dats2xhtml>")
//
val () =
print!("\
<h2>Description</h2>\n")
val () =
print!("<description>")
val () =
println!(myentry_get(ent, "description"))
val () = println!("</description>")
//
val () = println!("</div>")
//
val ((*separator*)) = println!("<hr></hr>")
//
val res = atext_make_nil(l0)
//
} (* end of [__html_dynfun__] *)

(* ****** ****** *)

in (* in-of-local *)

(* ****** ****** *)

val () =
the_atextmap_insert
(
"interface"
,
atextdef_TEXTDEFfun(lam(loc, xs) => __interface__(loc, xs))
) (* the_atextmap_insert *)

val () =
the_atextmap_insert
(
"implement"
,
atextdef_TEXTDEFfun(lam(loc, xs) => __implement__(loc, xs))
) (* the_atextmap_insert *)

(* ****** ****** *)

val () =
the_atextmap_insert
(
"html_dynfun"
,
atextdef_TEXTDEFfun(lam(loc, xs) => __html_dynfun__(loc, xs))
) (* the_atextmap_insert *)

(* ****** ****** *)

end // end of [local]

(* ****** ****** *)
//
//
(* ****** ****** *)
//
val () = theDB_initize()
//
(* ****** ****** *)

implement
main0((*void*)) =
{
//
val atxts =
parsing_from_stdin()
val ((*void*)) =
atextlst_topeval(stdout_ref, atxts)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [mylib_atexting.dats] *)
