(*
** For writing ATS code
** that translates into Javascript
*)

(* ****** ****** *)
//
#define
ATS_DYNLOADFLAG 0
//
(* ****** ****** *)
//
// HX-2014-08:
// prefix for external names
//
#define
ATS_EXTERN_PREFIX "ats2jspre_"
#define
ATS_STATIC_PREFIX "_ats2jspre_JSarray_"
//
(* ****** ****** *)
//
#define
LIBATSCC_targetloc
"$PATSHOME/contrib/libatscc"
//
(* ****** ****** *)
//
#staload
UN =
"prelude/SATS/unsafe.sats"
//
(* ****** ****** *)

#staload "./../basics_js.sats"

(* ****** ****** *)

#staload "./../SATS/integer.sats"

(* ****** ****** *)

#staload "./../SATS/JSarray.sats"

(* ****** ****** *)

implement
JSarray_make_list_vt
  {a}(xs) = let
//
fun
loop
(
  A: JSarray(a), xs: List_vt(a)
) : void =
(
case+ xs of
| ~list_vt_nil() => ()
| ~list_vt_cons(x, xs) =>
  let
    val _ = A.push(x) in loop(A, xs)
  end // [list_vt_cons]
)
//
val A = JSarray_nil{a}()
//
in
  let val () = loop(A, xs) in A end
end // end of [JSarray_make_list_vt]

(* ****** ****** *)

implement
JSarray_tabulate_cloptr
  {a}{n}
(
  asz, fopr
) = let
//
val A = JSarray_nil{a}()
//
fun
loop
{i:nat | i <= n}
(
  i: int(i), fopr: !cfun(natLt(n), a)
) : void =
(
if i < asz
  then let
    val _ =
    JSarray_push(A, fopr(i)) in loop(i+1, fopr)
  end // end of [then]
  else () // end of [else]
// end of [if]
) (* end of [loop] *)
//
val () = loop(0, fopr)
//
in
  cfun_free(fopr); A
end (* end of [JSarray_tabulate_cloptr] *)

(* ****** ****** *)
//
implement
{a}(*tmp*)
JSarray_sort_1(A) = 
JSarray_sort_2
  (A, lam(x1, x2) =<cloptr1> gcompare_val_val<a>(x1, x2))
//
(* ****** ****** *)

(* end of [JSarray.dats] *)
