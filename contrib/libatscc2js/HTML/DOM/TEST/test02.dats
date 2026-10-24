#define ATS_MAINATSFLAG 1
#define ATS_DYNLOADNAME "test02__dynload"
#define LIBATSCC2JS_targetloc "$PATSHOME/contrib/libatscc2js"
#include "{$LIBATSCC2JS}/mylibies.hats"
#staload "{$LIBATSCC2JS}/HTML/DOM/SATS/document.sats"
extern fun run(): void = "mac#"
implement run() = let
  val e = document_getById_exn("out")
  val () = Element_set_innerHTML(e, "hello")
  val e2 = document_createElement("div")
  val () = Element_set_innerHTML(e2, "x")
  val e3 = theDocument_getById_exn(theDocument, "out")
in () end
