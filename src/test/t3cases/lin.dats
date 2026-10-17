(* linear data: datavtype, free, @-patterns, fold@, free@, linear variables, consumption *)
#include "share/atspre_staload.hats"

datavtype ilist = inil | icons of (int, ilist)

fun ilen (xs: !ilist): int = case+ xs of | icons (_, xs1) => 1 + ilen (xs1) | inil () => 0
fun ifree (xs: ilist): void = case+ xs of | ~icons (_, xs1) => ifree (xs1) | ~inil () => ()
fun icopy (xs: !ilist): ilist = case+ xs of | icons (x, xs1) => icons (x, icopy (xs1)) | inil () => inil ()
fun irev (xs: ilist): ilist = let
  fun loop (xs: ilist, acc: ilist): ilist = case+ xs of
    | ~icons (x, xs1) => loop (xs1, icons (x, acc))
    | ~inil () => acc
in loop (xs, inil ()) end

fun iinc (xs: !ilist): void = case+ xs of
  | @icons (x, xs1) => (x := x + 1; iinc (xs1); fold@ (xs))
  | @inil () => fold@ (xs)

fun ihead (xs: ilist): (int, ilist) = case+ xs of
  | @icons (x, xs1) => let val r = x val t = xs1 val () = free@ {...} (xs) in (r, t) end
  | ~inil () => (0, inil ())

fun leak (xs: ilist): int = 1
fun dup (xs: ilist): @(ilist, ilist) = @(xs, xs)
fun use1 (xs: ilist): void = let val () = ifree (xs) in () end
fun nouse (): void = let val xs = inil () in () end

datavtype tree = tleaf | tnode of (tree, int, tree)
fun tsize (t: !tree): int = case+ t of
  | tnode (l, _, r) => tsize (l) + 1 + tsize (r)
  | tleaf () => 0
fun tfree (t: tree): void = case+ t of
  | ~tnode (l, _, r) => (tfree (l); tfree (r))
  | ~tleaf () => ()
fun tins (t: tree, k: int): tree = case+ t of
  | ~tleaf () => tnode (tleaf (), k, tleaf ())
  | ~tnode (l, x, r) => if k < x then tnode (tins (l, k), x, r) else tnode (l, x, tins (r, k))

absvtype res = ptr
fun res_make (): res = $UNSAFE.castvwtp0{res} (the_null_ptr)
fun res_free (r: res): void = let val _ = $UNSAFE.castvwtp0{ptr} (r) in () end
fun res_use (r: !res): int = 0
fun res_main (): void = let val r = res_make () val _ = res_use (r) in res_free (r) end

vtypedef pair = @{ a= int, b= ilist }
fun pairf (p: pair): int = let val @{ a= a, b= b } = p val () = ifree (b) in a end

fun opt (x: int): Option_vt (int) = if x > 0 then Some_vt (x) else None_vt ()
fun optu (o: Option_vt (int)): int = case+ o of | ~Some_vt (x) => x | ~None_vt () => 0
fun optf (o: Option_vt (int)): int = case+ o of | Some_vt (x) => x | None_vt () => 0
fun lst (): List0_vt (int) = list_vt_cons (1, list_vt_cons (2, list_vt_nil ()))
fun lstu (): int = let val xs = lst () val n = list_vt_length (xs) val () = list_vt_free (xs) in n end
