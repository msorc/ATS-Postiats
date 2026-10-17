(* the second part of s2common1.hats: after the generated dumpers (dd_s2exp ...) *)
(* ****** ****** *)
//
// the results that are linear are dumped (and freed) here
//
fun dd_optvt_s2exp (x: Option_vt (s2exp)): void =
  case+ x of ~Some_vt (e) => (dd_ps "Some_vt("; dd_s2exp e; dd_ps ")") | ~None_vt () => dd_ps "None_vt()"

fun dd_listvt_s2var (xs: List0_vt (s2var)): void = let
  fun loop (xs: List0_vt (s2var), i: int): void =
    case+ xs of
    | ~list_vt_cons (x, xs) => ((if i > 0 then dd_ps ","); dd_s2var x; loop (xs, i+1))
    | ~list_vt_nil () => ()
in
  dd_ps "["; loop (xs, 0); dd_ps "]"
end // end of [dd_listvt_s2var]

fun dd_listvt_s2Var (xs: List0_vt (s2Var)): void = let
  fun loop (xs: List0_vt (s2Var), i: int): void =
    case+ xs of
    | ~list_vt_cons (x, xs) => ((if i > 0 then dd_ps ","); dd_s2Var x; loop (xs, i+1))
    | ~list_vt_nil () => ()
in
  dd_ps "["; loop (xs, 0); dd_ps "]"
end // end of [dd_listvt_s2Var]

fun dd_listvt_s2cst (xs: List0_vt (s2cst)): void = let
  fun loop (xs: List0_vt (s2cst), i: int): void =
    case+ xs of
    | ~list_vt_cons (x, xs) => ((if i > 0 then dd_ps ","); dd_s2cst x; loop (xs, i+1))
    | ~list_vt_nil () => ()
in
  dd_ps "["; loop (xs, 0); dd_ps "]"
end // end of [dd_listvt_s2cst]

fun dd_listvt_d2con (xs: List0_vt (d2con)): void = let
  fun loop (xs: List0_vt (d2con), i: int): void =
    case+ xs of
    | ~list_vt_cons (x, xs) => ((if i > 0 then dd_ps ","); dd_d2con x; loop (xs, i+1))
    | ~list_vt_nil () => ()
in
  dd_ps "["; loop (xs, 0); dd_ps "]"
end // end of [dd_listvt_d2con]

fun dd_listvt_s2rtdat (xs: List0_vt (s2rtdat)): void = let
  fun loop (xs: List0_vt (s2rtdat), i: int): void =
    case+ xs of
    | ~list_vt_cons (x, xs) => ((if i > 0 then dd_ps ","); dd_s2rtdat x; loop (xs, i+1))
    | ~list_vt_nil () => ()
in
  dd_ps "["; loop (xs, 0); dd_ps "]"
end // end of [dd_listvt_s2rtdat]

(* ****** ****** *)
//
// the full state of the cells (all the fields through the getters)
//
fun chk_s2cst (x: s2cst): void = {
  val () = dd_ps "s2cst{"
  val () = dd_s2cst x
  val () = (dd_ps ",name="; dd_string (s2cst_get_name x))
  val () = (dd_ps ",loc="; dd_location (s2cst_get_loc x))
  val () = (dd_ps ",fil="; dd_filename (s2cst_get_fil x))
  val () = (dd_ps ",srt="; dd_s2rt (s2cst_get_srt x))
  val () = (dd_ps ",def="; dd_s2expopt (s2cst_get_def x))
  val () = (dd_ps ",pack="; dd_Stropt (s2cst_get_pack x))
  val () = (dd_ps ",isabs="; dd_s2expoptopt (s2cst_get_isabs x))
  val () = (dd_ps ",iscon="; dd_bool (s2cst_get_iscon x))
  val () = (dd_ps ",isrec="; dd_bool (s2cst_get_isrec x))
  val () = (dd_ps ",isasp="; dd_s2expopt (s2cst_get_isasp x))
  val () = (dd_ps ",islst="; dd_d2conpairopt (s2cst_get_islst x))
  val () = (dd_ps ",argsrtss="; dd_syms2rtlstlst (s2cst_get_argsrtss x))
  val () = (dd_ps ",dconlst="; dd_d2conlstopt (s2cst_get_dconlst x))
  val () = (dd_ps ",sup="; dd_s2cstlst (s2cst_get_sup x))
  val () = (dd_ps ",supcls="; dd_s2explst (s2cst_get_supcls x))
  val () = (dd_ps ",sVarset="; fprint_s2Varset (dd_out, s2cst_get_sVarset x))
  val () = (dd_ps ",dstag="; dd_int (s2cst_get_dstag x))
  val () = (dd_ps ",extdef="; dd_scstextdef (s2cst_get_extdef x))
  val () = (dd_ps ",stamp="; dd_stamp (s2cst_get_stamp x))
  val () = dd_ps "}"
  val () = dd_nl ()
}

fun chk_s2var (x: s2var): void = {
  val () = dd_ps "s2var{"
  val () = dd_s2var x
  val () = (dd_ps ",srt="; dd_s2rt (s2var_get_srt x))
  val () = (dd_ps ",tmplev="; dd_int (s2var_get_tmplev x))
  val () = (dd_ps ",sVarset="; fprint_s2Varset (dd_out, s2var_get_sVarset x))
  val () = (dd_ps ",bool="; dd_bool (s2var_is_bool x))
  val () = dd_ps "}"
  val () = dd_nl ()
}

fun chk_s2Var (x: s2Var): void = {
  val () = dd_ps "s2Var{"
  val () = dd_s2Var x
  val () = (dd_ps ",srt="; dd_s2rt (s2Var_get_srt x))
  val () = (dd_ps ",link="; dd_s2expopt (s2Var_get_link x))
  val () = (dd_ps ",szexp="; dd_s2zexp (s2Var_get_szexp x))
  val () = (dd_ps ",sVarlst="; dd_s2Varlst (s2Var_get_sVarlst x))
  val () = (dd_ps ",lbs="; dd_s2VarBoundlst (s2Var_get_lbs x))
  val () = (dd_ps ",ubs="; dd_s2VarBoundlst (s2Var_get_ubs x))
  val () = dd_ps "}"
  val () = dd_nl ()
}

fun chk_d2con (x: d2con): void = {
  val () = dd_ps "d2con{"
  val () = dd_d2con x
  val () = (dd_ps ",name="; dd_string (d2con_get_name x))
  val () = (dd_ps ",loc="; dd_location (d2con_get_loc x))
  val () = (dd_ps ",fil="; dd_filename (d2con_get_fil x))
  val () = (dd_ps ",scst="; dd_s2cst (d2con_get_scst x))
  val () = (dd_ps ",npf="; dd_int (d2con_get_npf x))
  val () = (dd_ps ",vwtp="; dd_int (d2con_get_vwtp x))
  val () = (dd_ps ",qua="; dd_s2qualst (d2con_get_qua x))
  val () = (dd_ps ",arg="; dd_s2explst (d2con_get_arg x))
  val () = (dd_ps ",arity_full="; dd_int (d2con_get_arity_full x))
  val () = (dd_ps ",arity_real="; dd_int (d2con_get_arity_real x))
  val () = (dd_ps ",ind="; dd_s2explstopt (d2con_get_ind x))
  val () = (dd_ps ",type="; dd_s2exp (d2con_get_type x))
  val () = (dd_ps ",tag="; dd_int (d2con_get_tag x))
  val () = (dd_ps ",pack="; dd_Stropt (d2con_get_pack x))
  val () = dd_ps "}"
  val () = dd_nl ()
}

fun chk_s2rtdat (x: s2rtdat): void = {
  val () = dd_ps "s2rtdat{"
  val () = dd_s2rtdat x
  val () = (dd_ps ",sconlst="; dd_s2cstlst (s2rtdat_get_sconlst x))
  val () = dd_ps "}"
  val () = dd_nl ()
}

fun chk_s2hole (x: s2hole): void = {
  val () = dd_ps "s2hole{"
  val () = dd_s2hole x
  val () = (dd_ps ",srt="; dd_s2rt (s2hole_get_srt x))
  val () = dd_ps "}"
  val () = dd_nl ()
}

(* ****** ****** *)

fun dd_listvt_s2exp (xs: List0_vt (s2exp)): void = let
  fun loop (xs: List0_vt (s2exp), i: int): void =
    case+ xs of
    | ~list_vt_cons (x, xs) => ((if i > 0 then dd_ps ","); dd_s2exp x; loop (xs, i+1))
    | ~list_vt_nil () => ()
in
  dd_ps "["; loop (xs, 0); dd_ps "]"
end // end of [dd_listvt_s2exp]

fun dd_listvt_vexp (xs: List0_vt (@(s2var, s2exp))): void = let
  fun loop (xs: List0_vt (@(s2var, s2exp)), i: int): void =
    case+ xs of
    | ~list_vt_cons (x, xs) => ((if i > 0 then dd_ps ","); dd_s2var (x.0); dd_ps "->"; dd_s2exp (x.1); loop (xs, i+1))
    | ~list_vt_nil () => ()
in
  dd_ps "["; loop (xs, 0); dd_ps "]"
end // end of [dd_listvt_vexp]

fun dd_listvt_staerr (xs: List0_vt (staerr)): void = let
  fun loop (xs: List0_vt (staerr), i: int): void =
    case+ xs of
    | ~list_vt_cons (x, xs) => ((if i > 0 then dd_ps ","); dd_staerr x; loop (xs, i+1))
    | ~list_vt_nil () => ()
in
  dd_ps "["; loop (xs, 0); dd_ps "]"
end // end of [dd_listvt_staerr]
