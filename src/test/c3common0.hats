(* the part of the test of the constraint solver (c3dump.dats, c3dump1.dats) that is written once for ATS1 and ATS2 (see c3_gen.py): before the
   language specific part (c3hand.tmpl) *)
(* ****** ****** *)
fun dd_listvt_s3exp (xs: List0_vt (s3exp)): void = let
  fun loop (xs: List0_vt (s3exp), i: int): void =
    case+ xs of
    | ~list_vt_cons (x, xs) => ((if i > 0 then dd_ps ", "); print_s3exp x; loop (xs, i+1))
    | ~list_vt_nil () => ()
in
  dd_ps "["; loop (xs, 0); dd_ps "]"
end // end of [dd_listvt_s3exp]
fun pr_x (tag: string, x: s3exp): void = (dd_ps tag; dd_ps ": "; print_s3exp x; dd_nl ())
