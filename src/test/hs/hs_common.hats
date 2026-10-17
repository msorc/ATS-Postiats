(*
** The test of pats_histaexp, in the common subset of ATS1 and ATS2 (continued): the objects of the cases and [hs_all], which the
** cases (hs_cases.hats) call. See hs_leaf.hats.
*)
(* ****** ****** *)

extern castfn hs_funlab_of_int (i: int): funlab

fun hs_funlab (i: int): funlab = hs_funlab_of_int (i)

(* ****** ****** *)
//
// the objects of the cases
//
val hs_loc = $LOC.location_dummy
val hs_fil = $FIL.filename_dummy

val hs_c0 = hs_cst (0, s2rt_fun (LC_s2rtlst (s2rt_t0ype, LN_s2rtlst ()), s2rt_t0ype))
val hs_c1 = hs_cst (1, s2rt_fun (LC_s2rtlst (s2rt_t0ype, LC_s2rtlst (s2rt_int, LN_s2rtlst ())), s2rt_type))
val hs_c2 = hs_cst (2, s2rt_fun (LC_s2rtlst (s2rt_int, LN_s2rtlst ()), s2rt_t0ype))
val hs_c3 = hs_cst (3, s2rt_fun (LN_s2rtlst (), s2rt_prop))
val hs_c4 = hs_cst (4, s2rt_t0ype)
val hs_c5 = hs_cst (5, s2rt_type)
val hs_c6 = hs_cst (6, s2rt_int)
val hs_c7 = hs_cst (7, s2rt_view)
val hs_c8 = hs_cst (8, s2rt_vtype)

val hs_v0 = $SYM.symbol_make_string ("hs_va")
val hs_v0 = s2var_make_id_srt (hs_v0, s2rt_t0ype)
val hs_v1 = s2var_make_id_srt ($SYM.symbol_make_string ("hs_vb"), s2rt_type)
val hs_v2 = s2var_make_id_srt ($SYM.symbol_make_string ("hs_vc"), s2rt_t0ype)
val hs_v3 = s2var_make_id_srt ($SYM.symbol_make_string ("hs_vd"), s2rt_int)
val hs_v4 = s2var_make_id_srt ($SYM.symbol_make_string ("hs_ve"), s2rt_vtype)
val hs_v5 = s2var_make_id_srt ($SYM.symbol_make_string ("hs_vf"), s2rt_addr)

val hs_d0 = hs_dcon (0, hs_c4)
val hs_d1 = hs_dcon (1, hs_c5)
val hs_d2 = hs_dcon (2, hs_c4)

fun hs_void_cst (): s2cst = s2cstref_get_cst ($S2C.the_atsvoid_t0ype)

(* ****** ****** *)

fun hs_q (tag: string, i: int): void = (dd_ps " "; dd_ps tag; dd_ps "="; dd_int i)
fun hs_qb (tag: string, b: bool): void = (dd_ps " "; dd_ps tag; dd_ps "="; dd_bool b)

fun hs_sub_1 (): stasub = let
  var sub = stasub_make_nil ()
  val () = stasub_add (sub, hs_v0, s2exp_int (7))
  val () = stasub_add (sub, hs_v1, s2exp_cst (hs_c4))
in
  sub
end

fun hs_sub_2 (): stasub = let
  var sub = stasub_make_nil ()
  val () = stasub_add (sub, hs_v2, s2exp_cstapp (hs_c0, LC_s2explst (s2exp_var (hs_v3), LN_s2explst ())))
  val () = stasub_add (sub, hs_v3, s2exp_int (1))
  val () = stasub_add (sub, hs_v4, s2exp_cst (hs_void_cst ()))
in
  sub
end

fun hs_subst1 (tag: string, sub: !stasub, h: hisexp): void = let
  val h2 = hisexp_subst (sub, h)
in
  dd_ps " subst "; dd_ps tag; dd_ps (if hs_same (h, h2) then " same: " else " new: "); dd_hisexp h2; dd_nl ();
  dd_ps "   fprint: "; fprint_hisexp (dd_out, h2); dd_nl ()
end

fun hs_all (i: int, h: hisexp): void = let
  val () = (dd_ps "case "; dd_int i; dd_nl ())
  val () = (dd_ps " dd: "; dd_hisexp h; dd_nl ())
  val () = (dd_ps " fprint: "; fprint_hisexp (dd_out, h); dd_nl ())
  val () = (dd_ps " name: "; dd_hitnam (hs_name h); dd_nl ())
  val () = (hs_q ("boxknd", hisexp_get_boxknd h); hs_q ("extknd", hisexp_get_extknd h))
  val () = (hs_qb ("boxed", hisexp_is_boxed h); hs_qb ("void", hisexp_is_void h); hs_qb ("fun_void", hisexp_fun_is_void h))
  val () = (hs_qb ("noret", hisexp_is_noret h); hs_qb ("fun_noret", hisexp_fun_is_noret h))
  val () = (hs_qb ("tyarr", hisexp_is_tyarr h); hs_qb ("tyrecsin", hisexp_is_tyrecsin h); dd_nl ())
  var sub1 = hs_sub_1 ()
  val () = hs_subst1 ("1", sub1, h)
  val () = stasub_free sub1
  var sub2 = hs_sub_2 ()
  val () = hs_subst1 ("2", sub2, h)
  val () = stasub_free sub2
  var sub3 = stasub_make_nil ()
  val () = hs_subst1 ("0", sub3, h)
  val () = stasub_free sub3
in
end

(* ****** ****** *)
//
// the constants and the functions that do not depend on a tree
//
fun hs_consts (): void = let
  val () = dd_ps "consts\n"
  val () = (dd_hisexp hisexp_tybox; dd_nl ())
  val () = (dd_hisexp hisexp_typtr; dd_nl ())
  val () = (dd_hisexp hisexp_funptr; dd_nl ())
  val () = (dd_hisexp hisexp_cloptr; dd_nl ())
  val () = (dd_hisexp hisexp_clotyp; dd_nl ())
  val () = (dd_hisexp hisexp_arrptr; dd_nl ())
  val () = (dd_hisexp hisexp_datconptr; dd_nl ())
  val () = (dd_hisexp hisexp_datcontyp; dd_nl ())
  val () = (dd_hisexp hisexp_exnconptr; dd_nl ())
  val () = (dd_hisexp hisexp_undefined; dd_nl ())
  val () = (dd_hisexp (hisexp_int_t0ype ()); dd_nl ())
  val () = (dd_hisexp (hisexp_bool_t0ype ()); dd_nl ())
  val () = (dd_hisexp (hisexp_size_t0ype ()); dd_nl ())
  val () = (dd_hisexp (hisexp_void_t0ype ()); dd_nl ())
  val () = (print_hisexp (hisexp_void_t0ype ()); print_newline ())
  val () = (dd_hitnam (hs_name (hisexp_tybox)); dd_nl ())
  val () = (print_funlab (hs_funlab 2); print_newline ())
  val () = (prerr_funlab (hs_funlab 1); prerr_newline ())
  val () = (prerr_hisexp (hisexp_void_t0ype ()); prerr_newline ())
  val lh = K_labhisexp (hs_lab 1, hs_none (), hisexp_funptr)
  val () = (dd_hisexp (labhisexp_get_elt lh); dd_nl ())
in
end

