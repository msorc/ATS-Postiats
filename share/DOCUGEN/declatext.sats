(*
** declatext:
** For documenting declarations
*)

(* ****** ****** *)
//
staload LDOC =
"libatsdoc/SATS/libatsdoc_atext.sats"
//
typedef atext = $LDOC.atext
typedef atextlst = $LDOC.atextlst
//
(* ****** ****** *)
//
staload LSYNMK =
"utils/libatsynmark/SATS/libatsynmark.sats"
//
typedef d0eclreplst = $LSYNMK.d0eclreplst
//
staload "libats/SATS/arena.sats"
//
(* ****** ****** *)

//
// HX-2026-10: no GC. A [declitem] is a flat tuple (tag, string, string)
// (a datatype with non-nullary constructors is rejected); the lists are
// [glist]s (the global arena: they are never freed) and the unused
// components are [""]
//
#define DITMname 0 // (name, "")
#define DITMname2 1 // (name, href)
#define DITMsynop 2 // ("", "")
#define DITMsynop2 3 // (synop, "")
#define DITMdescrpt 4 // (content, "")
#define DITMexample 5 // (content, "")
#define DITMparamadd 6 // (name, desc)
#define DITMparamlist 7 // ("", "")
#define DITMfunretval 8 // (content, "")
//
typedef declitem = @(int(*tag*), string, string)
typedef declitemlst = glist(declitem)
typedef stringlst = glist(string)

(* ****** ****** *)

fun theDecltitle_get (): string
fun theDecltitle_set (x: string): void
fun decltitle (x: string): atext

(* ****** ****** *)

fun theDeclpreamble_get (): string
fun theDeclpreamble_set (x: string): void
fun declpreamble (x: string): atext

fun theDeclpostamble_get (): string
fun theDeclpostamble_set (x: string): void
fun declpostamble (x: string): atext

(* ****** ****** *)

fun theDeclname_get (): string
fun theDeclname_set (x: string): void

fun theDeclnameLst_add (x: string): void
fun theDeclnameLst_get (): stringlst

fun theDeclitemLst_add (x: declitem): void
fun theDeclitemLst_get (): declitemlst

fun declname (x: string): atext
fun declname2 (name: string, href: string): atext
//
// HX: for the current declname
//
fun declsynop ((*auto*)): atext
fun declsynopsis ((*auto*)): atext
//
fun declsynop2 (x: string): atext
fun declsynopsis2 (x: string): atext
//
fun declnamesynop (x: string): atext
//
fun decldescrpt (x: string): atext
//
fun declexample (x: string): atext // HX: optional
//
fun declparamadd
  (name: string, desc: string): atext
fun declparamlist (): atext // HX: optional
//
fun declfunretval (x: string): atext // HX: optional
//
(* ****** ****** *)

fun theDeclrepLst_get (): d0eclreplst
fun theDeclrepLst_set (xs: d0eclreplst): void

(* ****** ****** *)

(* end of [declatext.sats] *)
