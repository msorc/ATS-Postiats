(* the ATS1 counterpart of ccb_leaf2.hats *)
(* ****** ****** *)

fun dd_double (x: double): void = fprint_double (dd_out, x)

fun dd_tmplab (x: tmplab): void = (dd_ps "tmplab("; dd_location (tmplab_get_loc x); dd_ps ","; dd_stamp (tmplab_get_stamp x); dd_ps ")")

fun dd_tmpvar (x: tmpvar): void = (
  dd_ps "tmpvar{loc="; dd_location (tmpvar_get_loc x);
  dd_ps ",type="; fprint_hisexp (dd_out, tmpvar_get_type x);
  dd_ps ",ref="; dd_bool (tmpvar_isref x);
  dd_ps ",ret="; dd_int (tmpvar_get_tailcal x);
  dd_ps ",topknd="; dd_int (tmpvar_get_topknd x);
  dd_ps ",origin="; dd_tmpvaropt (tmpvar_get_origin x);
  dd_ps ",suffix="; dd_int (tmpvar_get_suffix x);
  dd_ps ",stamp="; dd_stamp (tmpvar_get_stamp x); dd_ps "}"
)
and dd_tmpvaropt (x: tmpvaropt): void = (
  case+ x of Some (y) => (dd_ps "Some("; dd_tmpvar y; dd_ps ")") | None () => dd_ps "None"
)

fun dd_d2env (x: d2env): void = (dd_ps "d2env("; dd_d2var (d2env_get_var x); dd_ps ","; fprint_hisexp (dd_out, d2env_get_type x); dd_ps ")")

fun dd_funlab (x: funlab): void = (
  dd_ps "funlab{name="; dd_string (funlab_get_name x);
  dd_ps ",level="; dd_int (funlab_get_level x);
  dd_ps ",funclo="; dd_funclo (funlab_get_funclo x);
  dd_ps ",type="; fprint_hisexp (dd_out, funlab_get_type x);
  dd_ps ",tmpknd="; dd_int (funlab_get_tmpknd x);
  dd_ps ",ncopy="; dd_int (funlab_get_ncopy x);
  dd_ps ",origin=";
  (case+ funlab_get_origin x of Some (y) => dd_stamp (funlab_get_stamp y) | None () => dd_ps "-");
  dd_ps ",suffix="; dd_int (funlab_get_suffix x);
  dd_ps ",funent="; (case+ funlab_get_funent x of Some _ => dd_ps "some" | None () => dd_ps "none");
  dd_ps ",stamp="; dd_stamp (funlab_get_stamp x); dd_ps "}"
)
