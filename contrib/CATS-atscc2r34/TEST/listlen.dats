(* ****** ****** *)
//
// HX-2017-10:
// A running example
// from ATS2 to R(stat)
//
(* ****** ****** *)
//
#define
ATS_DYNLOADFLAG 0
//
(* ****** ****** *)
//
#define
LIBATSCC2R34_targetloc
"$PATSHOME/contrib/libatscc2r34"
//
(* ****** ****** *)
//
staload
"{$LIBATSCC2R34}/SATS/integer.sats"
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

%{^
######
options(expressions=100000);
######
if
(
!(exists("libatscc2r34.is.loaded"))
)
{
  assign("libatscc2r34.is.loaded", FALSE)
}
######
if
(
!(libatscc2r34.is.loaded)
)
{
  sys.source("./libatscc2r34/libatscc2r34_all.R", envir = globalenv())
}
######
%} // end of [%{^]

(* ****** ****** *)

%{$
xs <- fromto(0, 10)
message("listlen(", xs, ") =", listlen(xs))
%} // end of [%{$]

(* ****** ****** *)

(* end of [listlen.dats] *)
