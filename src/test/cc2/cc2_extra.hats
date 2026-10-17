(* the leaf dumpers of the ccomp layer (neutral): see cc2_gen.py *)
fun dd_double (x: double): void = fprint_double (dd_out, x)
fun dd_vbindmap (x: vbindmap): void = dd_ps "vbindmap"
