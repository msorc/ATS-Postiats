(* the ATS1 part of the codegen2/patcst2 test that is not common (see cgcommon.hats) *)
(* ****** ****** *)
extern fun cg_env_clear (): void = "mac#cg_env_clear"
extern fun cg_env_put (kind: int, name: string, item: ptr): void = "mac#cg_env_put"
extern fun cg_env_get (kind: int, name: string): ptr = "mac#cg_env_get"
extern fun cg_getenv_int (): int = "mac#cg_getenv_int"
//
fun cg_vt2lst (xs: !p2atcstlst_vt): p2atcstlst = $UN.castvwtp1{p2atcstlst} (xs)
fun cg_lstlst (xss: !p2atcstlstlst_vt): p2atcstlstlst = $UN.castvwtp1{p2atcstlstlst} (xss)
fun cg_lvt2lst (xs: !labp2atcstlst_vt): labp2atcstlst = $UN.castvwtp1{labp2atcstlst} (xs)
fun cg_c2lau_pat (c2l: c2lau): p2atlst = c2l.c2lau_pat
fun cg_c2lau_noguard (c2l: c2lau): bool = (case+ c2l.c2lau_gua of list_nil () => true | list_cons _ => false)
//
// the tokens with a suffix (P2Ti0nt: the suffix is cut)
fun mktnode_int_sfx (k: int): tnode =
  T_INT (10, (case+ k mod 3 of 0 => "10L" | 1 => "7u" | _ => "123456789012345678901ULL"), (case+ k mod 3 of 0 => 1u | 1 => 1u | _ => 3u))
