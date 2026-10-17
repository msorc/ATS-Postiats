(* the part of the test of group 1 of the trans3 port (t3g1_gen.py) that differs in ATS1 and ATS2 (see t3hand.tmpl: "2|" lines are ATS2 only, "1|" lines ATS1 only) *)
(* ****** ****** *)
fun mktok_int (k: int, base: int, rep: string, sfx: uint): i0nt = token_make (mkloc (k), token_node_T_INT (base, rep, sfx))
fun mktok_float (k: int, base: int, rep: string, sfx: uint): f0loat = token_make (mkloc (k), token_node_T_FLOAT (base, rep, sfx))
fun mktok_int2 (k: int, rep: string): i0nt = mktok_int (k, $UT.intrep_get_base (rep), rep, $UT.intrep_get_nsfx (rep))
fun mktok_float2 (k: int, rep: string): f0loat = mktok_float (k, 10, rep, $UT.float_get_nsfx (rep))
fun t_funclo_of (e: d2exp, fc0: funclo): void = let
  var fc: funclo = fc0
  val e1 = d2exp_funclo_of_d2exp (e, fc)
in
  (dd_d2exp e1; dd_ps " "; dd_funclo fc; dd_nl ())
end
fun t_s2eff_of (e: d2exp): void = let
  var fe: s2eff
  val e1 = d2exp_s2eff_of_d2exp (e, fe)
in
  (dd_d2exp e1; dd_ps " "; dd_s2eff fe; dd_nl ())
end
fun t_d23free (d2e: d2exp, d3e: d3exp): void = let
  val () = d23exp_free (D23Ed2exp d2e)
  val () = d23exp_free (D23Ed3exp d3e)
  val xs = list_vt_cons (D23Ed2exp d2e, list_vt_cons (D23Ed3exp d3e, list_vt_nil ()))
in
  d23explst_free (xs)
end
fun mk_strint (n: int): s2exp = s2exp_string_int_type ($UN.cast{size_t} (n))

