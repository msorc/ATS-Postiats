(* ATS2: the language specific wrappers of the emit test (after the wrappers of pats_ccomp.spec; see ca_gen.py) *)
(* ****** ****** *)
%{^
extern char ca_chr (int) ;
extern char *ca_str (int) ;
extern double ca_dbl (int) ;
extern int ca_getexit (void) ;
%}
extern fun H_chr (i: int): char = "mac#ca_chr"
extern fun H_str (k: int): string = "mac#ca_str"
extern fun H_dbl (k: int): double = "mac#ca_dbl"
extern fun H_getexit (): int = "mac#ca_getexit"
//
fun H_vbmap0 (): vbindmap = d2varmap_nil<primval> ()
fun H_vbmap1 (d2v: d2var, pmv: primval): vbindmap = let
  var m: vbindmap = d2varmap_nil<primval> ()
  val _ = d2varmap_insert<primval> (m, d2v, pmv)
in m end
fun H_vbmap2 (d2v1: d2var, pmv1: primval, d2v2: d2var, pmv2: primval): vbindmap = let
  var m: vbindmap = d2varmap_nil<primval> ()
  val _ = d2varmap_insert<primval> (m, d2v1, pmv1)
  val _ = d2varmap_insert<primval> (m, d2v2, pmv2)
in m end
//
// the doubles of trans2_env: the filenv is a cell that holds the list of the declarations (ca_dbl.dats)
fun H_filenv (fil: filename, d2cs: d2eclist): filenv = let
  val p = the_garena_alloc (sizeof<ptr>)
  val () = $UN.ptr0_set<d2eclist> (p, d2cs)
in $UN.cast{filenv} (p) end
//
// the placeholder funlab of the types
fun H_hse_tyclo (flab: funlab): hisexp = hisexp_tyclo ($UN.cast{hisexp_funlab_type} (flab))
