(*
** declatext:
** For documenting declarations
*)

(* ****** ****** *)

//
// HX-2026-10: no GC (ATS2 port of the ATS1 version of this file): the
// references are toplevel variables (the lists are [glist]s of the global
// arena, see declatext.sats)
//
(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

#include "share/atspre_staload.hats"
staload "libats/SATS/arena.sats"
staload _(*anon*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "./declatext.sats"

(* ****** ****** *)

local

var theDecltitle_var: string = ""
val theDecltitle =
  ref_make_viewptr{string}(view@ theDecltitle_var | addr@ theDecltitle_var)

in // in of [local]
implement theDecltitle_get () = ref_get_elt (theDecltitle)
implement theDecltitle_set (x) = ref_set_elt (theDecltitle, x)
end // end of [local]
implement
decltitle (x) = let
  val () = theDecltitle_set (x) in $LDOC.atext_nil ()
end // end of [decltitle]

(* ****** ****** *)

local

var theDeclpreamble_var: string = ""
val theDeclpreamble =
  ref_make_viewptr{string}(view@ theDeclpreamble_var | addr@ theDeclpreamble_var)

in // in of [local]
implement theDeclpreamble_get () = ref_get_elt (theDeclpreamble)
implement theDeclpreamble_set (x) = ref_set_elt (theDeclpreamble, x)
end // end of [local]
implement
declpreamble (x) = let
  val () = theDeclpreamble_set (x) in $LDOC.atext_nil ()
end // end of [declpreamble]

(* ****** ****** *)

local

var theDeclpostamble_var: string = ""
val theDeclpostamble =
  ref_make_viewptr{string}(view@ theDeclpostamble_var | addr@ theDeclpostamble_var)

in // in of [local]
implement theDeclpostamble_get () = ref_get_elt (theDeclpostamble)
implement theDeclpostamble_set (x) = ref_set_elt (theDeclpostamble, x)
end // end of [local]
implement
declpostamble (x) = let
  val () = theDeclpostamble_set (x) in $LDOC.atext_nil ()
end // end of [declpostamble]

(* ****** ****** *)

local

var theDeclname_var: string = ""
val theDeclname =
  ref_make_viewptr{string}(view@ theDeclname_var | addr@ theDeclname_var)

in // in of [local]
implement theDeclname_get () = ref_get_elt (theDeclname)
implement theDeclname_set (x) = ref_set_elt (theDeclname, x)
end // end of [local]

(* ****** ****** *)

local

var theDeclnameLst_var: stringlst = glist_nil()
val theDeclnameLst =
  ref_make_viewptr{stringlst}(view@ theDeclnameLst_var | addr@ theDeclnameLst_var)

in // in of [local]

implement
theDeclnameLst_add (x) =
  ref_set_elt (theDeclnameLst, glist_cons (x, ref_get_elt (theDeclnameLst)))
// end of [theDeclnameLst_add]

implement theDeclnameLst_get () = let
  val xs = ref_get_elt (theDeclnameLst)
  val () = ref_set_elt (theDeclnameLst, glist_nil())
in
  glist_reverse (xs)
end // end of [theDeclnameLst_get]

end // end of [local]

(* ****** ****** *)

local

var theDeclitemLst_var: declitemlst = glist_nil()
val theDeclitemLst =
  ref_make_viewptr{declitemlst}(view@ theDeclitemLst_var | addr@ theDeclitemLst_var)

in // in of [local]

implement
theDeclitemLst_add (x) =
  ref_set_elt (theDeclitemLst, glist_cons (x, ref_get_elt (theDeclitemLst)))
// end of [theDeclitemLst_add]

implement theDeclitemLst_get () = let
  val xs = ref_get_elt (theDeclitemLst)
  val () = ref_set_elt (theDeclitemLst, glist_nil())
in
  glist_reverse (xs)
end // end of [theDeclitemLst_get]

end // end of [local]

(* ****** ****** *)

implement
declname (x) = let
  val () = theDeclnameLst_add (x)
  val () = theDeclitemLst_add (@(DITMname, x, ""))
in
  $LDOC.atext_nil ()
end // end of [declname]

implement
declname2 (name, href) = let
  val () = theDeclnameLst_add (name)
  val () = theDeclitemLst_add (@(DITMname2, name, href))
in
  $LDOC.atext_nil ()
end // end of [declname]

implement
declsynop () = let
  val () = theDeclitemLst_add (@(DITMsynop, "", ""))
in
  $LDOC.atext_nil ()
end // end of [declsynop]
implement declsynopsis () = declsynop ()

implement
declsynop2 (x) = let
  val () = theDeclitemLst_add (@(DITMsynop2, x, ""))
in
  $LDOC.atext_nil ()
end // end of [declsynop2]
implement declsynopsis2 (x) = declsynop2 (x)

implement
declnamesynop (x) = let
  val _ignored = declname (x)
  val _ignored = declsynopsis ()
in
  $LDOC.atext_nil ()
end // end of [declname]

implement
decldescrpt (x) = let
  val () = theDeclitemLst_add (@(DITMdescrpt, x, ""))
in
  $LDOC.atext_nil ()
end // end of [decldescrpt]

implement
declexample (x) = let
  val () = theDeclitemLst_add (@(DITMexample, x, ""))
in
  $LDOC.atext_nil ()
end // end of [declexample]

implement
declparamlist () = let
  val () = theDeclitemLst_add (@(DITMparamlist, "", ""))
in
  $LDOC.atext_nil ()
end // end of [declparamlist]

implement
declparamadd (x1, x2) = let
  val () = theDeclitemLst_add (@(DITMparamadd, x1, x2))
in
  $LDOC.atext_nil ()
end // end of [declparamadd]

implement
declfunretval (x) = let
  val () = theDeclitemLst_add (@(DITMfunretval, x, ""))
in
  $LDOC.atext_nil ()
end // end of [declfunretval]

(* ****** ****** *)

local

var theDeclrepLst_var: d0eclreplst = glist_nil()
val theDeclrepLst =
  ref_make_viewptr{d0eclreplst}(view@ theDeclrepLst_var | addr@ theDeclrepLst_var)

in // in of [local]
implement theDeclrepLst_get () = ref_get_elt (theDeclrepLst)
implement theDeclrepLst_set (xs) = ref_set_elt (theDeclrepLst, xs)
end // end of [local]

(* ****** ****** *)

(* end of [declatext.dats] *)
