(* ****** ****** *)
(*
// Implementing a module of ML-style
*)
(* ****** ****** *)
(*
//
// Author: Hongwei Xi
// TIme: the 4th of June, 2013
// Authoremail: gmhwxi AT gmail DOT edu
//
*)
(* ****** ****** *)
(*
//
##myatsccdef=\
curl --data-urlencode mycode@$1 \
http://www.ats-lang.org/SERVER/MYCODE/atslangweb_patsopt_tcats_0_.php | \
php -R 'if (\$argn != \"\") echo(json_decode(urldecode(\$argn))[1].\"\\n\");'
//
*)
(* ****** ****** *)

(* ****** ****** *)
//
// HX-2026-10: no GC
// A module is now a flat record of functions (no
// closures, no boxing); the sets are linear lists.
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

typedef
ordmod (a:t@ype) = @{ cmp= (a, a) -<fun> int }

(* ****** ****** *)

extern
fun{a:t@ype}
ordmod_compare (ord: ordmod (a), x: a, y: a): int
implement{a}
ordmod_compare (ord, x, y) = ord.cmp (x, y)

(* ****** ****** *)

absvtype set (a:t@ype) = ptr

(* ****** ****** *)

typedef
setmod (a:t@ype) =
@{
  sing= (a) -<fun1> set (a)
, isemp= (!set(a)) -<fun1> bool
, union= (ordmod(a), set(a), set(a)) -<fun1> set (a)
, copy= (!set(a)) -<fun1> set (a)
, print= (!set(a)) -<fun1> void
, free= (set(a)) -<fun1> void
} // end of [setmod]

(* ****** ****** *)

extern
fun{a:t@ype}
setmod_make (): setmod (a)

(* ****** ****** *)

local

assume set (a:t@ype) = List0_vt (a)

in (* in of [local] *)

implement{a}
setmod_make () = let
//
fun
funion
(
  ord: ordmod a
, xs: List0_vt a, ys: List0_vt a
) : List0_vt a =
(
case+ xs of
| ~list_vt_nil () => ys
| ~list_vt_cons (x, xs1) =>
  (
    case+ ys of
    | ~list_vt_nil () => list_vt_cons{a}(x, xs1)
    | ~list_vt_cons (y, ys1) => let
        val sgn =
          ordmod_compare<a> (ord, x, y)
      in
        if sgn < 0 then
          list_vt_cons{a}(x, funion (ord, xs1, list_vt_cons{a}(y, ys1)))
        else
        (
          if sgn > 0
          then
            list_vt_cons{a}(y, funion (ord, list_vt_cons{a}(x, xs1), ys1))
          else
            list_vt_cons{a}(x, funion (ord, xs1, ys1))
          // end of [if]
        ) // end of [if]
      end // end of [list_vt_cons]
  )
) (* end of [funion] *)
//
in @{
  sing= lam (x) =<fun1> list_vt_cons{a}(x, list_vt_nil)
, isemp= lam (xs) =<fun1> list_vt_is_nil (xs)
, union= lam (ord, xs, ys) =<fun1> funion (ord, xs, ys)
, copy= lam (xs) =<fun1> list_vt_copy<a> (xs)
, print= lam (xs) =<fun1> fprint_list_vt<a> (stdout_ref, xs)
, free= lam (xs) =<fun1> list_vt_free<a> (xs)
} end // end of [setmod_make]

end // end of [local]

(* ****** ****** *)

implement
main0 () = {
//
val ordmod_int =
  @{ cmp = lam (x:int, y:int): int =<fun> compare (x, y) }
//
val setmod_int = setmod_make<int> ()
//
val xs0 = setmod_int.sing (0)
val xs1 = setmod_int.sing (1)
val xs01 = setmod_int.union (ordmod_int, xs0, xs1)
val xs0101 =
  setmod_int.union (ordmod_int, setmod_int.copy (xs01), setmod_int.copy (xs01))
//
val () = (print! ("xs01 = "); setmod_int.print (xs01); print_newline ())
val () = (print! ("xs0101 = "); setmod_int.print (xs0101); print_newline ())
//
val () = setmod_int.free (xs01)
val () = setmod_int.free (xs0101)
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [ordset.dats] *)
