abstype
trans1err_type = ptr
typedef
trans1err = trans1err_type

//
datavtype
trans1err_view =
  | T1E_prec_tr of (i0de)
  | T1E_e0xp_tr of (e0xp)
  | T1E_s0rt_tr of (s0rt)
  | T1E_s0exp_tr of (s0exp)
  | T1E_p0at_tr of (p0at)
  | T1E_d0exp_tr of (d0exp)
  | T1E_d0cstdec_tr of (d0cstdec)
  | T1E_termet_check of (location)
  | T1E_i0nclude_tr of (d0ecl)
  | T1E_s0taload_tr of (d0ecl)
  | T1E_d0ynload_tr of (d0ecl)
//
fun
trans1err_encode(v: trans1err_view): trans1err
fun
trans1err_view(x: trans1err): trans1err_view
fun
trans1err_view_free(v: trans1err_view): void
fun
trans1err_tag(x: trans1err): int
fun
trans1err_T1E_prec_tr(a0: i0de): trans1err
fun
trans1err_T1E_e0xp_tr(a0: e0xp): trans1err
fun
trans1err_T1E_s0rt_tr(a0: s0rt): trans1err
fun
trans1err_T1E_s0exp_tr(a0: s0exp): trans1err
fun
trans1err_T1E_p0at_tr(a0: p0at): trans1err
fun
trans1err_T1E_d0exp_tr(a0: d0exp): trans1err
fun
trans1err_T1E_d0cstdec_tr(a0: d0cstdec): trans1err
fun
trans1err_T1E_termet_check(a0: location): trans1err
fun
trans1err_T1E_i0nclude_tr(a0: d0ecl): trans1err
fun
trans1err_T1E_s0taload_tr(a0: d0ecl): trans1err
fun
trans1err_T1E_d0ynload_tr(a0: d0ecl): trans1err
fun
trans1err_is_T1E_prec_tr(x: trans1err): bool
fun
trans1err_is_T1E_e0xp_tr(x: trans1err): bool
fun
trans1err_is_T1E_s0rt_tr(x: trans1err): bool
fun
trans1err_is_T1E_s0exp_tr(x: trans1err): bool
fun
trans1err_is_T1E_p0at_tr(x: trans1err): bool
fun
trans1err_is_T1E_d0exp_tr(x: trans1err): bool
fun
trans1err_is_T1E_d0cstdec_tr(x: trans1err): bool
fun
trans1err_is_T1E_termet_check(x: trans1err): bool
fun
trans1err_is_T1E_i0nclude_tr(x: trans1err): bool
fun
trans1err_is_T1E_s0taload_tr(x: trans1err): bool
fun
trans1err_is_T1E_d0ynload_tr(x: trans1err): bool
//
