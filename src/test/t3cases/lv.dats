(* call-by-reference arguments (&, >>), left-value restoration, patterns with constructors in untyped lambdas, funarg exhaustiveness *)
#include "share/atspre_staload.hats"

extern fun f_ref (x: &int): void
extern fun f_refchg (x: &int >> bool): void
extern fun f_refuninit (x: &int? >> int): void
extern fun f_refuninit2 (x: &(@(int, int))? >> @(int, int)): void
extern fun f_refconsume (x: &int >> int?): void
extern fun f_refarr (x: &(@[int][3])): void
extern fun f_rec (x: &(@{a=int, b=int})): void
extern fun f_view {l:addr} (pf: !int @ l | p: ptr l): void
extern fun f_vchg {l:addr} (pf: !int? @ l >> int @ l | p: ptr l): void
extern fun f_lin (x: &ptr): void

fun t1 (): void = let var x: int = 1 in f_ref (x) end
fun t2 (): void = let var x: int = 1 in f_refchg (x) end
fun t3 (): int = let var x: int = 1 val () = f_refchg (x) in 0 end
fun t4 (): void = let var x: int? in f_refuninit (x) end
fun t5 (): int = let var x: int? val () = f_refuninit (x) in x end
fun t6 (): void = let var x: int = 1 in f_refuninit (x) end
fun t7 (): void = let var x: int = 1 in f_refconsume (x) end
fun t8 (): int = let var x: int = 1 val () = f_refconsume (x) in x end
fun t9 (): void = f_ref (1)
fun t10 (x: int): void = f_ref (x)
fun t11 (): void = let val x = 1 in f_ref (x) end
fun t12 (): void = let var x: bool = true in f_ref (x) end
fun t13 (): void = let var a = @[int][3](0) in f_refarr (a) end
fun t14 (): void = let var a = @[int][4](0) in f_refarr (a) end
fun t15 (): void = let var r: @{a=int, b=int} = @{a=1, b=2} in f_rec (r) end
fun t16 (): void = let var r: @{a=int, b=int} = @{a=1, b=2} in f_ref (r.a) end
fun t17 (): void = let var r: @{a=int, b=int} = @{a=1, b=2} in f_refchg (r.a) end
fun t18 (): void = let var r: @{a=int, b=int} = @{a=1, b=2} in f_refuninit (r.a) end
fun t19 (): void = let var r: @(int, int) = @(1, 2) in f_ref (r.1) end
fun t20 (): void = let var r: @(int, int) = @(1, 2) in f_refconsume (r.1) end
fun t21 (): void = let var a = @[int][3](0) in f_ref (a[1]) end
fun t22 (): void = let var a = @[int][3](0) in f_refchg (a[1]) end
fun t23 {l:addr} (pf: !int @ l | p: ptr l): void = f_ref (!p)
fun t24 {l:addr} (pf: !int @ l | p: ptr l): void = f_refchg (!p)
fun t25 {l:addr} (pf: !int @ l | p: ptr l): void = f_refconsume (!p)
fun t26 {l:addr} (pf: int? @ l | p: ptr l): void = f_refuninit (!p)
fun t27 {l:addr} (pf: !int? @ l >> int @ l | p: ptr l): void = f_refuninit (!p)
fun t28 (p: ptr): void = f_ref (!p)
fun t29 (r: ref (int)): void = f_ref (!r)
fun t30 (r: ref (int)): void = f_refchg (!r)
fun t31 (r: ref (int)): void = f_refconsume (!r)
fun t32 (r: ref (@(int, int))): void = f_ref ((!r).0)
fun t33 (): void = let var x: int = 1 in (f_ref (x); f_ref (x); f_refchg (x); f_refchg (x)) end
fun t34 (): void = let var x: ptr = the_null_ptr in f_lin (x) end
fun t35 (x: &int): void = f_ref (x)
fun t36 (x: &int): void = f_refchg (x)
fun t37 (x: &int >> bool): void = f_refchg (x)
fun t38 (x: &int? >> int): void = f_refuninit (x)
fun t39 (x: &int? >> int): void = (x := 3; f_ref (x))
fun t40 (x: &int >> int?): void = f_refconsume (x)
fun t41 (x: &int >> int?): void = ()
fun t42 (x: &int >> bool): void = ()
fun t43 (x: &int >> bool): void = x := true
fun t44 (x: &int?): void = f_ref (x)

datavtype dv = DA | DB of (int, int) | DC of (dv, dv)
val g1 = lam (DA ()) => 0
val g2 = lam (DB (a, b)) => a
val g3 = lam (~DB (a, b)) => a
val g4 = lam (~DA ()) => 0
val g5 = lam (~DC (x, y)) => 0
val g6 = lam (@DB (a, b)) => 0
val g7 = lam (x: dv) => x
val g9 = fix f (x: dv): int => (case+ x of | ~DA () => 0 | ~DB (_, _) => 1 | ~DC (a, b) => f (a) + f (b))
fun h1 (~DA ()): int = 0
fun h2 (~DB (a, b)): int = a
fun h3 (~DB (a, b), x: int): int = a + x
fun h4 (x: int, ~DB (a, b)): int = a + x
fun h5 (~DA (), ~DA ()): int = 0
fun h6 (0): int = 0
fun h7 (true): int = 0
fun h8 (x: int, 1): int = 0
fun h9 (@(a, b): @(int, int)): int = a
fun h10 (@(a, 1): @(int, int)): int = a
fun h11 (_: int): int = 0
fun h12 (x as y: int): int = 0
fun h14 (x: !dv): int = case+ x of | DA () => 0 | DB (a, b) => a | DC (_, _) => 1
