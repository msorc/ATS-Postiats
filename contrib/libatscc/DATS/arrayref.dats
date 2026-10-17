(*
** libatscc-common
*)

(* ****** ****** *)

(*
//
staload "./../SATS/arrayref.sats"
//
staload UN = "prelude/SATS/unsafe.sats"
//
*)

(* ****** ****** *)
//
implement
arrayref_exists_cloptr
  (A, n, pred) =
(
int_exists_cloptr(n, $UN.castvwtp0{cfun1(int,bool)}(pred))
)
implement
arrayref_forall_cloptr
  (A, n, pred) =
(
int_forall_cloptr(n, $UN.castvwtp0{cfun1(int,bool)}(pred))
)
//
implement
arrayref_foreach_cloptr
  (A, n, fwork) =
(
int_foreach_cloptr(n, $UN.castvwtp0{cfun1(int,void)}(fwork))
)
//
(* ****** ****** *)
//
// HX: array-with-size
//
(* ****** ****** *)
//
implement
arrszref_make_elt
  {a}(n, x0) = let
//
val A =
  arrayref_make_elt{a}(n, x0)
//
in
  arrszref_make_arrayref{a}(A, n)
end (* end of [arrszref_make_elt] *)
//
(* ****** ****** *)
//
implement
arrszref_exists_cloptr
  {a}(A, pred) = let
  val asz = arrszref_size(A)
in
//
int_exists_cloptr
  (asz, $UN.castvwtp0{cfun1(int,bool)}(pred))
//
end // end of [arrszref_exists_cloptr]
//
implement
arrszref_forall_cloptr
  {a}(A, pred) = let
  val asz = arrszref_size(A)
in
//
int_forall_cloptr
  (asz, $UN.castvwtp0{cfun1(int,bool)}(pred))
//
end // end of [arrszref_forall_cloptr]
//
(* ****** ****** *)
//
implement
arrszref_foreach_cloptr
  {a}(ASZ, fwork) = let
  val asz = arrszref_size(ASZ)
in
//
int_foreach_cloptr
  (asz, $UN.castvwtp0{cfun1(int,void)}(fwork))
//
end // end of [arrszref_foreach_cloptr]
//
(* ****** ****** *)
//
implement
arrszref_tabulate_cloptr
  {a}{n}(asz, fopr) = let
//
val fopr =
$UN.castvwtp0{natLt(n) -<cloptr1> a?}(fopr)
in
$UN.cast
(
arrszref_make_arrayref
  (arrayref_tabulate_cloptr{a?}(asz, fopr), asz)
)
end (* end of [arrszref_tabulate] *)
//
(* ****** ****** *)

(* end of [arrayref.dats] *)
