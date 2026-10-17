(* ****** ****** *)
//
// HX-2014-08:
// A running example
// from ATS2 to Node.js
//
(* ****** ****** *)
//
#define
LIBATSCC2JS_targetloc
"$PATSHOME/contrib/libatscc2js"
//
(* ****** ****** *)
//
staload
"{$LIBATSCC2JS}/SATS/integer.sats"
//
(* ****** ****** *)
//
extern
fun
listlen{a:t0p}
  : (!List0_vt(a)) -> int = "mac#listlen"
//
implement
listlen{a}
  (xs) = let
//
fun
loop{i,j:nat} .<i>.
(
  xs: !list_vt(a, i), res: int(j)
) : int(i+j) = let
in
//
case+ xs of
| list_vt_nil () => res | list_vt_cons (_, xs) => loop (xs, res+1)
//
end // end of [loop]
//
prval () = lemma_list_vt_param (xs)
//
in
  loop (xs, 0)
end // end of [listlen]
//
(* ****** ****** *)
//
extern
fun
fromto
  : (int, int) -> List0_vt (int) = "mac#fromto"
//
implement
fromto (m, n) =
if m < n
  then list_vt_cons (m, fromto (m+1, n)) else list_vt_nil ()
// end of [if]
//
(* ****** ****** *)

%{^
//
// file inclusion
//
var fs = require('fs');
eval(fs.readFileSync('./libatscc2js/CATS/basics_cats.js').toString());
eval(fs.readFileSync('./libatscc2js/CATS/integer_cats.js').toString());
%} // end of [%{^]

(* ****** ****** *)

%{$
var xs = fromto(0, 10)
console.log("listlen(", xs, ") =", listlen(xs))
%} // end of [%{$]

(* ****** ****** *)

(* end of [listlen.dats] *)
