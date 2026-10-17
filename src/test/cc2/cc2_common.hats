(* the part of the ccomp group C2 test that is written once for ATS1 and ATS2, after the generated layers (see cc2_gen.py) *)
(* ****** ****** *)
//
// Everything here is in the common subset of ATS1 and ATS2 (the accessors cl_<field> and the shims are written per language: cc2_cells{1,2}.hats, cc2_shim{1,2}.hats).
// The dumpers of the five cells of pats_ccomp.sats (the generated dumpers cd_<T> call them): identity (stamp) and the fields that the modules read or change.
//
(* ****** ****** *)

implement cd_tmplab (x) = (dd_ps "tl#"; dd_stamp (cl_tmplab_stamp x); dd_ps "@"; dd_location (cl_tmplab_loc x))
implement cd_tmpvar (x) = (
  dd_ps "tmp#"; dd_stamp (cl_tmpvar_stamp x); dd_ps "{"; dd_location (cl_tmpvar_loc x)
; dd_ps ",ref="; dd_int (cl_tmpvar_ref x); dd_ps ",ret="; dd_int (cl_tmpvar_ret x); dd_ps ",top="; dd_int (cl_tmpvar_topknd x)
; dd_ps ",sfx="; dd_int (cl_tmpvar_suffix x); dd_ps ","; dd_hisexp (cl_tmpvar_type x); dd_ps "}"
)
implement cd_d2env (x) = (dd_ps "d2env("; dd_d2var (cl_d2env_var x); dd_ps ","; dd_hisexp (cl_d2env_type x); dd_ps ")")
implement cd_funlab (x) = (
  dd_ps "fl#"; dd_stamp (cl_funlab_stamp x); dd_ps "("; dd_string (cl_funlab_name x); dd_ps ",lv="; dd_int (cl_funlab_level x)
; dd_ps ",tk="; dd_int (cl_funlab_tmpknd x); dd_ps ",clo="; dd_bool (not (cl_funclo_is_fun (cl_funlab_funclo x))); dd_ps ")"
)
implement cd_funent (x) = (
  dd_ps "funent{"; dd_location (cl_funent_loc x); dd_ps ","; cd_funlab (cl_funent_lab x); dd_ps ",imparg="; dd_s2varlst (cl_funent_imparg x)
; dd_ps ",tmparg="; dd_s2explstlst (cl_funent_tmparg x); dd_ps ",tmpret="; cd_tmpvar (cl_funent_tmpret x)
; dd_ps ",flablst="; cd_funlablst (cl_funent_flablst x); dd_ps ",d2envlst="; cd_d2envlst (cl_funent_d2envlst x)
; dd_ps ",vbmap="; dd_vbindmap (cl_funent_vbindmap x); dd_ps ",body="; cd_instrlst (cl_funent_instrlst x)
; dd_ps ",fnx="; cd_funlablst (cl_funent_fnxlablst x); dd_ps "}"
)

(* ****** ****** *)

(* end of [cc2_common.hats] *)
