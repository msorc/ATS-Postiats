(* ****** ****** *)
//
// HX-2014-11:
// A running example
// from ATS2 to Perl5
//
(* ****** ****** *)
//
#define
LIBATSCC2PL_targetloc
"$PATSHOME\
/contrib/libatscc2pl/ATS2-0.3.2"
//
(* ****** ****** *)
//
#include
"{$LIBATSCC2PL}/staloadall.hats"
//
(* ****** ****** *)
//
extern
fun
listlen
  : {a:t@ype} (!List0_vt(a)) -> int = "mac#listlen"
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

extern
fun
main0_pl : () -> void = "mac#"
implement
main0_pl () =
{
//
val xs = fromto(0, 10)
val n0 = listlen(xs)
val () = list_vt_free(xs)
val () = println! ("listlen(fromto(0, 10)) = ", n0)
} (* end of [main0_pl] *)

(* ****** ****** *)

%{^
require "./libatscc2pl/libatscc2pl_all.pl";
%} // end of [%{^]

(* ****** ****** *)

%{$
main0_pl();
%} // end of [%{$]

(* ****** ****** *)

(* end of [listlen.dats] *)
