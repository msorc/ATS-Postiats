(* TEST DOUBLES for the ATS1 side of the emit test (the ATS2 twin is ca_dbl.dats): the hitype / hisexp emitters (another group's: both sides use the same
   text), and the filenv cell. Everything else of pats_ccomp.sats is the REAL ATS1 module. *)
(* ****** ****** *)
local
assume hitype_type = '(int, hisexp)
in
implement hisexp_typize (flag, hse) = '(flag, hse)
implement fprint_hitype (out, x) = {
  val () = fprint_string (out, "HIT[")
  val () = fprint_int (out, x.0)
  val () = fprint_string (out, ";")
  val () = fprint_hisexp (out, x.1)
  val () = fprint_string (out, "]")
}
end // end of [local]
implement print_hitype (x) = fprint_hitype (stdout_ref, x)
implement prerr_hitype (x) = fprint_hitype (stderr_ref, x)
implement fprint_hitypelst (out, xs) = ()
implement emit_hitype (out, hit) = {
  val () = fprint_string (out, "{")
  val () = fprint_hitype (out, hit)
  val () = fprint_string (out, "}")
}
fun fprint_hname (out: FILEref, hse: hisexp): void = {
  val+ HITNAM (_, _, name) = hse.hisexp_name
  val () = fprint_string (out, name)
  val () = fprint_string (out, " ")
}
implement emit_hisexp (out, hse) = {
  val () = fprint_string (out, "{HSE ")
  val () = fprint_hname (out, hse)
  val () = fprint_hisexp (out, hse)
  val () = fprint_string (out, "}")
}
implement emit_hisexp_sel (out, hse) = {
  val () = fprint_string (out, "{SEL ")
  val () = fprint_hname (out, hse)
  val () = fprint_hisexp (out, hse)
  val () = fprint_string (out, "}")
}
implement emit_hisexplst_sep (out, hses, sep) = let
  fun loop (out: FILEref, sep: string, hses: hisexplst, i: int): void =
    case+ hses of
    | list_cons (hse, hses) => let
        val () = if i > 0 then fprint_string (out, sep)
        val () = emit_hisexp (out, hse)
      in loop (out, sep, hses, i+1) end
    | list_nil () => ()
in
  loop (out, sep, hses, 0)
end
implement emit_the_typedeflst (out) = ()
//
implement $TRENV2.filenv_get_d2eclist (fenv) = !($UN.cast{ref (d2eclist)} (fenv))
implement fprint_tmprimval (out, x) = (
  case+ x of
  | TPMVnone (pmv) => (fprint_string (out, "TPMVnone("); fprint_primval (out, pmv); fprint_string (out, ")"))
  | TPMVsome (tmp, pmv) => (
      fprint_string (out, "TPMVsome("); fprint_tmpvar (out, tmp); fprint_string (out, "<-"); fprint_primval (out, pmv); fprint_string (out, ")")
    )
)
//
// the doubles that the linked ATS1 objects of other modules need (never called by the cases)
implement $TRENV2.the_d2varlev_get () = 0
implement $TRENV2.filenv_getref_tmpcstimpmap (fenv) = $UN.cast{Ptr1} (1)
implement $TRENV2.filenv_getref_tmpvardecmap (fenv) = $UN.cast{Ptr1} (1)
