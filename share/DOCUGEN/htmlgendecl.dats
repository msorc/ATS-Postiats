(*
** htmlgendecl:
** For generating html files describing declarations
*)

(* ****** ****** *)

//
// HX-2026-10: no GC (ATS2 port of the ATS1 version of this file): the
// lists are [glist]s of the global arena (never freed), a [declitem] is
// a flat tuple, the references are toplevel variables
//
(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

#include "share/atspre_staload.hats"
staload "libats/SATS/arena.sats"
staload _(*anon*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "./declatext.sats"
staload "./htmlgendecl.sats"

(* ****** ****** *)

staload
LDOC = "libatsdoc/SATS/libatsdoc_atext.sats"
#include "utils/atsdoc/HATS/atsdoc_compat.hats"

(* ****** ****** *)

#define
ATSCODEROOT
"http://ats-lang.sourceforge.net/DOCUMENT/ATS-Postiats"

(* ****** ****** *)

implement
myatscodelink
  (codepath, linkname) = let
//
val res = sprintf
(
  "<a href=\"%s/%s\">%s</a>", @(ATSCODEROOT, codepath, linkname)
) // end of [val]
//
in
  $LDOC.atext_strptr (res)
end // end of [myatscodelink]

(* ****** ****** *)

(* ****** ****** *)

local

staload SYM = "src/pats_symbol.sats"

fun auxlst
(
  stadyn: int, css: List0_vt ($LSYNMK.charlst), i: int
) : List0_vt (Strptr1) = let
in
//
case+ css of
| ~list_vt_cons
    (cs, css) => let
    val str =
      $LSYNMK.charlst_pats2xhtmlize_bground (stadyn, cs)
    // end of [val]
    val strlst = auxlst (stadyn, css, i+1)
  in
    list_vt_cons (str, strlst)
  end // end of [list_vt_cons]
| ~list_vt_nil () => list_vt_nil ()
//
end // end of [auxlst]

in (* in of [local] *)

implement
declname_find_synoplst
  (stadyn, name) = let
//
val sym =
  $SYM.symbol_make_string (name)
val xs = theDeclrepLst_get ()
val css = $LSYNMK.d0eclreplst_find_synop (xs, sym)
//
in
//
auxlst (stadyn, css, 0)
//
end // end of [declname_find_synoplst]

end // end of [local]

(* ****** ****** *)

implement
theDeclnameLst_make_menu () = let
//
fun aux (
  x: string
) : atext = let
  val str = sprintf ("<li><a href=\"#%s\">%s</a></li>\n", @(x, x))
in
  $LDOC.atext_strptr (str)
end // end of [aux]
fun auxlst (
  xs: stringlst
) : atextlst = let
in
  case+ glist_view (xs) of
  | ~GLcons
      (x, xs) => let
      val y = aux (x); val ys = auxlst (xs)
    in
      glist_cons (y, ys)
    end // end of [GLcons]
  | ~GLnil () => glist_nil ()
end // end of [auxlst]
//
val xs =
  theDeclnameLst_get ()
val ys = auxlst (xs)
//
in
//
$LDOC.atext_apptxt3 (
  $LDOC.atext_strcst "<menu>\n"
, $LDOC.atext_concatxt (ys)
, $LDOC.atext_strcst "</menu>"
) // end of [atext_apptxt3]
end // end of [theDeclnameLst_make_menu]

(* ****** ****** *)

//
// HX: the program that links this module does [dynload] libatsdoc (a
// second [dynload] of the same file in another module would define its
// flag twice)
//
#define ATSDOC_NO_DYNLOAD 1
#include "utils/atsdoc/HATS/xhtmlatxt.hats"

(* ****** ****** *)

typedef paramadd = @(string(*name*), string(*desc*))
typedef paramaddlst = glist(paramadd)

extern
fun theParamaddLst_add (x: paramadd): void
extern
fun theParamaddLst_add2 (name: string, desc: string): void
extern
fun theParamaddLst_get (): paramaddlst

local

var theParamaddLst_var: paramaddlst = glist_nil()
val theParamaddLst =
  ref_make_viewptr{paramaddlst}(view@ theParamaddLst_var | addr@ theParamaddLst_var)

in

implement
theParamaddLst_add (x) =
  ref_set_elt (theParamaddLst, glist_cons (x, ref_get_elt (theParamaddLst)))
// end of [theParamaddLst_add]

implement
theParamaddLst_add2
  (name, desc) = theParamaddLst_add (@(name, desc)) 
// end of [theParamaddLst_add2]

implement
theParamaddLst_get () = let
  val xs = ref_get_elt (theParamaddLst)
  val () = ref_set_elt (theParamaddLst, glist_nil())
in
  glist_reverse (xs)
end // end of [theParamaddLst_get]

end // end of [local]

(* ****** ****** *)

fun synoplst2atext
(
  name: string, xs: List0_vt (Strptr1)
) : atext = let
//
fun auxlst
  (xs: List0_vt (Strptr1)): atextlst = let
in
//
case+ xs of
| ~list_vt_cons (x, xs) => let
    val x1 = $UN.castvwtp1{string}(x)
    val x2 = sprintf ("<pre class=\"patsyntax\">\n%s</pre>\n", @(x1))
    val () = strptr_free (x)
    val atxt = $LDOC.atext_strptr (x2)
    val atxtlst = auxlst (xs)
  in
    glist_cons (atxt, atxtlst)
  end // end of [list_vt_cons]
| ~list_vt_nil () => glist_nil ()
//
end // end of [auxlst]
//
val atxtlst = auxlst (xs)
//
in
//
case+ glist_view (atxtlst) of
| ~GLcons _ => $LDOC.atext_concatxt (atxtlst)
| ~GLnil () => let
    val x = sprintf ("Synopsis for [%s] is unavailable.", @(name))
    val x1 = $UN.castvwtp1{string}(x)
    val x2 = sprintf ("<pre class=\"patsyntax\">\n%s</pre>\n", @(x1))
    val () = strptr_free (x)
  in
    $LDOC.atext_strptr (x2)
  end // end of [GLnil]
//
end // end of [synoplst2atext]

(* ****** ****** *)

local

fn HR (sz: int): atext = let
  val szs = tostrptr_int (sz)
  val str = sprintf (
    "<hr style=\"background-color: #E0E0E0; height: %spx;\"></hr>\n", @($UN.strptr2string(szs))
  ) // end of [val]
  val () = strptr_free (szs)
in
  $LDOC.atext_strptr (str)
end // end of [HR]

fn aux_name
  (name: string): atext = let
(*
  val () = println! ("aux_name: name = ", name)
*)
  val () = theDeclname_set (name)
  val str = sprintf ("<h2><a id=\"%s\">%s</a></h2>\n", @(name, name))
in
  $LDOC.atext_strptr (str)
end // end of [aux_name]

fn aux_name2
  (name: string, href: string): atext = let
(*
  val () = println! ("aux_name2: name = ", name)
  val () = println! ("aux_name2: href = ", href)
*)
  val () = theDeclname_set (name)
  val str = sprintf ("<h2><a id=\"%s\" href=\"%s\">%s</a></h2>\n", @(name, href, name))
in
  $LDOC.atext_strptr (str)
end // end of [aux_name2]

fn aux_synop () = let
(*
val () = println! ("aux_synop")
*)
val head =
  atext_apptxt2 (H3 ("Synopsis"), atext_newline())
// end of [val]
val name = theDeclname_get ()
val strlst = declname_find_synoplst (0(*sta*), name)
val synop = synoplst2atext (name, strlst)
//
in
  atext_apptxt2 (head, synop)
end // end of [aux_synop]

fn aux_synop2 (synop) = let
  val head =
    atext_apptxt2 (H3 ("Synopsis"), atext_newline())
  // end of [val]
in
  atext_apptxt2 (head, atext_strsub (synop))
end // end of [aux_synop2]

fn aux_descrpt (cntnt) = let
  val head =
    atext_apptxt2 (H3 ("Description"), atext_newline())
  // end of [val]
in
  atext_apptxt2 (head, atext_strsub (cntnt))
end // end of [aux_descrpt]

fn aux_example (cntnt) = let
  val head = atext_apptxt2 (H3 ("Example"), atext_newline())
in
  atext_apptxt2 (head, atext_strsub (cntnt))
end // end of [aux_example]

fun aux_paramadd
  (name, desc) = let
  val () = theParamaddLst_add2 (name, desc)
in
  atext_nil ()
end // end of [aux_paramadd]

fun aux_paramlist () = let
//
val head = atext_apptxt2 (H3 ("Parameters"), atext_newline())
//
val ul_beg = atext_strcst "<ul>"
val ul_body = let
//
fun auxlst
  (xs: paramaddlst): atext = let
in
  case+ glist_view (xs) of
  | ~GLcons (x, xs) => let
      val li_beg = atext_strcst "<li>"
      val li_end = atext_strcst "</li>"
      val name = x.0 and desc = x.1
      val itm1 = atext_strsub name
      val itm2 = atext_strcst " : "
      val itm3 = atext_strsub desc
      val li_body = atext_apptxt3 (itm1, itm2, itm3)
      val li_one = atext_apptxt3 (li_beg, li_body, li_end)
      val li_rest = auxlst (xs)
    in
      atext_apptxt2 (li_one, li_rest)
    end
  | ~GLnil () => atext_nil ()
end // end of [auxlst]
//
in
  auxlst (theParamaddLst_get ())
end // end of [val]
//
val ul_end = atext_strcst "</ul>"
//
val ul_all = atext_apptxt3 (ul_beg, ul_body, ul_end)
//
in
  atext_apptxt2 (head, ul_all)
end // end of [aux_funretval]

fun aux_funretval (cntnt) = let
  val head = atext_apptxt2 (H3 ("Return Value"), atext_newline())
in
  atext_apptxt2 (head, atext_strsub (cntnt))
end // end of [aux_funretval]

in (* in of [local] *)

implement
theDeclitemLst_make_content () = let
//
fun aux
  (x: declitem): atext = let
  val tag = x.0 and s1 = x.1 and s2 = x.2
in
//
if tag = DITMname then aux_name (s1)
else if tag = DITMname2 then aux_name2 (s1, s2)
//
else if tag = DITMsynop then aux_synop ((*void*))
else if tag = DITMsynop2 then aux_synop2 (s1)
//
else if tag = DITMdescrpt then aux_descrpt (s1)
//
else if tag = DITMexample then aux_example (s1)
//
else if tag = DITMparamadd then aux_paramadd (s1, s2)
else if tag = DITMparamlist then aux_paramlist ()
//
else (* tag = DITMfunretval *) aux_funretval (s1)
//
end // end of [aux]
//
fun auxlst
(
  xs: declitemlst, i: int
) : atextlst = let
in
//
case+ glist_view (xs) of
| ~GLcons
    (x, xs) => let
    val y = aux (x)
    val ys = auxlst (xs, i+1)
    val res = glist_cons<atext> (y, ys)
    val sep = (
      if i > 0 then
      (
        if x.0 = DITMname then true
        else if x.0 = DITMname2 then true
        else false (*non-name-entry*)
      ) else false
    ) : bool // end of [val]
  in
    if sep then glist_cons (HR(1), res) else res
  end // end of [GLcons]
| ~GLnil () => glist_nil ()
//
end // end of [auxlst]
//
val itmlst = theDeclitemLst_get ()
//
val atxtlst = auxlst (itmlst, 0(*i*))
//
in
  atext_concatxt (atxtlst)
end // end of [theDeclitemLst_make_content]

end // end of [local]

(* ****** ****** *)

(* end of [htmlgendecl.dats] *)
