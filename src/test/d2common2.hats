(* the second part of d2common1.hats: after the generated dumpers (dd_s2exp, dd_d2exp ...) *)
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

fun dd_listvt_d2cst (xs: List0_vt (d2cst)): void = let
  fun loop (xs: List0_vt (d2cst), i: int): void =
    case+ xs of
    | ~list_vt_cons (x, xs) => ((if i > 0 then dd_ps ","); dd_d2cst x; loop (xs, i+1))
    | ~list_vt_nil () => ()
in
  dd_ps "["; loop (xs, 0); dd_ps "]"
end // end of [dd_listvt_d2cst]

fun dd_listvt_d2var (xs: List0_vt (d2var)): void = let
  fun loop (xs: List0_vt (d2var), i: int): void =
    case+ xs of
    | ~list_vt_cons (x, xs) => ((if i > 0 then dd_ps ","); dd_d2var x; loop (xs, i+1))
    | ~list_vt_nil () => ()
in
  dd_ps "["; loop (xs, 0); dd_ps "]"
end // end of [dd_listvt_d2var]

fun dd_listvt_vexp (xs: List0_vt (@(d2var, s2exp))): void = let
  fun loop (xs: List0_vt (@(d2var, s2exp)), i: int): void =
    case+ xs of
    | ~list_vt_cons (x, xs) => ((if i > 0 then dd_ps ","); dd_d2var (x.0); dd_ps "->"; dd_s2exp (x.1); loop (xs, i+1))
    | ~list_vt_nil () => ()
in
  dd_ps "["; loop (xs, 0); dd_ps "]"
end // end of [dd_listvt_vexp]

(* ****** ****** *)
//
// the full state of the cells (all the fields through the getters)
//
fun chk_d2cst (x: d2cst): void = {
  val () = dd_ps "d2cst{"
  val () = dd_d2cst x
  val () = (dd_ps ",name="; dd_string (d2cst_get_name x))
  val () = (dd_ps ",loc="; dd_location (d2cst_get_loc x))
  val () = (dd_ps ",fil="; dd_filename (d2cst_get_fil x))
  val () = (dd_ps ",kind="; dd_dcstkind (d2cst_get_kind x))
  val () = (dd_ps ",decarg="; dd_s2qualst (d2cst_get_decarg x))
  val () = (dd_ps ",artylst="; dd_intlst (d2cst_get_artylst x))
  val () = (dd_ps ",type="; dd_s2exp (d2cst_get_type x))
  val () = (dd_ps ",hisexp="; dd_hisexpopt (d2cst_get_hisexp x))
  val () = (dd_ps ",funlab="; dd_funlabopt (d2cst_get_funlab x))
  val () = (dd_ps ",def="; dd_d2expopt (d2cst_get_def x))
  val () = (dd_ps ",pack="; dd_Stropt (d2cst_get_pack x))
  val () = (dd_ps ",extdef="; dd_dcstextdef (d2cst_get_extdef x))
  val () = (dd_ps ",stamp="; dd_stamp (d2cst_get_stamp x))
  val () = (dd_ps ",mac="; dd_bool (d2cst_is_mac x))
  val () = (dd_ps ",prf="; dd_bool (d2cst_is_prf x))
  val () = (dd_ps ",nonprf="; dd_bool (d2cst_is_nonprf x))
  val () = (dd_ps ",static="; dd_bool (d2cst_is_static x))
  val () = (dd_ps ",fundec="; dd_bool (d2cst_is_fundec x))
  val () = (dd_ps ",valdec="; dd_bool (d2cst_is_valdec x))
  val () = (dd_ps ",castfn="; dd_bool (d2cst_is_castfn x))
  val () = (dd_ps ",funcst="; dd_bool (d2cst_is_funcst x))
  val () = (dd_ps ",tmpcst="; dd_bool (d2cst_is_tmpcst x))
  val () = (dd_ps ",mainats="; dd_bool (d2cst_is_mainats x))
  val () = dd_ps "}"
  val () = dd_nl ()
}

fun chk_d2var (x: d2var): void = {
  val () = dd_ps "d2var{"
  val () = dd_d2var x
  val () = (dd_ps ",loc="; dd_location (d2var_get_loc x))
  val () = (dd_ps ",level="; dd_int (d2var_get_level x))
  val () = (dd_ps ",linval="; dd_int (d2var_get_linval x))
  val () = (dd_ps ",isfix="; dd_bool (d2var_get_isfix x))
  val () = (dd_ps ",isprf="; dd_bool (d2var_get_isprf x))
  val () = (dd_ps ",decarg="; dd_s2qualst (d2var_get_decarg x))
  val () = (dd_ps ",addr="; dd_s2expopt (d2var_get_addr x))
  val () = (dd_ps ",view="; dd_d2varopt (d2var_get_view x))
  val () = (dd_ps ",finknd="; dd_d2vfin (d2var_get_finknd x))
  val () = (dd_ps ",type="; dd_s2expopt (d2var_get_type x))
  val () = (dd_ps ",hisexp="; dd_hisexpopt (d2var_get_hisexp x))
  val () = (dd_ps ",mastype="; dd_s2expopt (d2var_get_mastype x))
  val () = (dd_ps ",utimes="; dd_int (d2var_get_utimes x))
  val () = (dd_ps ",stamp="; dd_stamp (d2var_get_stamp x))
  val () = (dd_ps ",linear="; dd_bool (d2var_is_linear x))
  val () = (dd_ps ",linprf="; dd_bool (d2var_is_linprf x))
  val () = (dd_ps ",mutabl="; dd_bool (d2var_is_mutabl x))
  val () = dd_ps "}"
  val () = dd_nl ()
}

fun chk_d2mac (x: d2mac): void = {
  val () = dd_ps "d2mac{"
  val () = dd_d2mac x
  val () = (dd_ps ",loc="; dd_location (d2mac_get_loc x))
  val () = (dd_ps ",kind="; dd_int (d2mac_get_kind x))
  val () = (dd_ps ",arglst="; dd_m2acarglst (d2mac_get_arglst x))
  val () = (dd_ps ",def="; dd_d2exp (d2mac_get_def x))
  val () = (dd_ps ",stamp="; dd_stamp (d2mac_get_stamp x))
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
