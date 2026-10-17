abstype
hit_type = ptr
typedef
hit = hit_type

abstype
labhit_type = ptr
typedef
labhit = labhit_type

typedef hitlst = glist(hit)
typedef labhitlst = glist(labhit)
//
datavtype
hit_view =
  | HITnmd of (string)
  | HITapp of (hit, hitlst)
  | HITtyarr of (hit, s2explst)
  | HITtyrec of (labhitlst)
  | HITtysum of (int, labhitlst)
  | HITtyexn of (labhitlst)
  | HITtyvar of (s2var)
  | HITtyclo of (funlab)
  | HITvararg of (hit)
  | HITrefarg of (int, hit)
  | HITundef of (stamp, hisexp)
  | HITerror of ()
//
fun
hit_encode(v: hit_view): hit
fun
hit_view(x: hit): hit_view
fun
hit_view_free(v: hit_view): void
fun
hit_tag(x: hit): int
fun
hit_HITnmd(a0: string): hit
fun
hit_HITapp(a0: hit, a1: hitlst): hit
fun
hit_HITtyarr(a0: hit, a1: s2explst): hit
fun
hit_HITtyrec(a0: labhitlst): hit
fun
hit_HITtysum(a0: int, a1: labhitlst): hit
fun
hit_HITtyexn(a0: labhitlst): hit
fun
hit_HITtyvar(a0: s2var): hit
fun
hit_HITtyclo(a0: funlab): hit
fun
hit_HITvararg(a0: hit): hit
fun
hit_HITrefarg(a0: int, a1: hit): hit
fun
hit_HITundef(a0: stamp, a1: hisexp): hit
fun
hit_HITerror(): hit
fun
hit_is_HITnmd(x: hit): bool
fun
hit_is_HITapp(x: hit): bool
fun
hit_is_HITtyarr(x: hit): bool
fun
hit_is_HITtyrec(x: hit): bool
fun
hit_is_HITtysum(x: hit): bool
fun
hit_is_HITtyexn(x: hit): bool
fun
hit_is_HITtyvar(x: hit): bool
fun
hit_is_HITtyclo(x: hit): bool
fun
hit_is_HITvararg(x: hit): bool
fun
hit_is_HITrefarg(x: hit): bool
fun
hit_is_HITundef(x: hit): bool
fun
hit_is_HITerror(x: hit): bool
//
fun
labhit_new(a0: label, a1: stringopt, a2: hit): labhit
fun
labhit_lab(x: labhit): label
overload .labhit_lab with labhit_lab
fun
labhit_opt(x: labhit): stringopt
overload .labhit_opt with labhit_opt
fun
labhit_elt(x: labhit): hit
overload .labhit_elt with labhit_elt
//
