(* type-restoration for a left-value that fails: an internal error that ends the translation (the context cannot be formed) *)
#include "share/atspre_staload.hats"
datavtype dvt = DVT of (int)
vtypedef lrcd = @{ a= int, d= dvt }
fun use1 (x: &dvt >> dvt?): void = let val+ ~DVT n = x in end
fun b15 (r: lrcd): void = (use1 (r.zzz))
