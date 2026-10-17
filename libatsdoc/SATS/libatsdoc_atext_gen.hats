abstype
atext_type = ptr
typedef
atext = atext_type

typedef atextlst = glist(atext)
//
datavtype
atext_view =
  | ATEXTnil of ()
  | ATEXTstrcst of (string)
  | ATEXTstrsub of (string)
  | ATEXTapptxt2 of (atext, atext)
  | ATEXTappstr2 of (string, string)
  | ATEXTapptxt3 of (atext, atext, atext)
  | ATEXTappstr3 of (string, string, string)
  | ATEXTconcatxt of (atextlst)
  | ATEXTconcatxtsep of (atextlst, atext)
//
fun
atext_encode(v: atext_view): atext
fun
atext_view(x: atext): atext_view
fun
atext_view_free(v: atext_view): void
fun
atext_tag(x: atext): int
fun
atext_ATEXTnil(): atext
fun
atext_ATEXTstrcst(a0: string): atext
fun
atext_ATEXTstrsub(a0: string): atext
fun
atext_ATEXTapptxt2(a0: atext, a1: atext): atext
fun
atext_ATEXTappstr2(a0: string, a1: string): atext
fun
atext_ATEXTapptxt3(a0: atext, a1: atext, a2: atext): atext
fun
atext_ATEXTappstr3(a0: string, a1: string, a2: string): atext
fun
atext_ATEXTconcatxt(a0: atextlst): atext
fun
atext_ATEXTconcatxtsep(a0: atextlst, a1: atext): atext
fun
atext_is_ATEXTnil(x: atext): bool
fun
atext_is_ATEXTstrcst(x: atext): bool
fun
atext_is_ATEXTstrsub(x: atext): bool
fun
atext_is_ATEXTapptxt2(x: atext): bool
fun
atext_is_ATEXTappstr2(x: atext): bool
fun
atext_is_ATEXTapptxt3(x: atext): bool
fun
atext_is_ATEXTappstr3(x: atext): bool
fun
atext_is_ATEXTconcatxt(x: atext): bool
fun
atext_is_ATEXTconcatxtsep(x: atext): bool
//
