(* ****** ****** *)
//
// HX-2016-07:
// A running example
// from ATS2 to Clojure
//
(* ****** ****** *)
//
#define ATS_DYNLOADFLAG 0
//
(* ****** ****** *)
//
#define
LIBATSCC2CLJ_targetloc
"$PATSHOME\
/contrib/libatscc2clj/ATS2-0.3.2"
//
(* ****** ****** *)
//
#include
"{$LIBATSCC2CLJ}/staloadall.hats"
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
//
extern 
fun
main0_ats
(
// argumentless
) : void = "mac#listlen_main0_ats"
//
implement
main0_ats () =
{
//
val xs = fromto(0, 10)
val n0 = listlen(xs)
val () = list_vt_free(xs)
val () = println!
(
  "listlen(fromto(0, 10)) = ", n0
) (* end of [val] *)
//
} (* end of [main0_ats] *)
//
(* ****** ****** *)

%{$
;;
(listlen_main0_ats)
;;
%} // end of [%{]

(* ****** ****** *)

(* end of [listlen.dats] *)
