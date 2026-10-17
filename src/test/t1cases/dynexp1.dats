(* dynamic expressions: functions *)
fun f1 {n:nat} .<n>. (x: int n): int n = if x > 0 then f1 (x-1) else 0
fun f2 (x: int):<> int = x
fun f3 (x: int):<!exn> int = x
fnx f4 (x: int): int = f5 (x)
and f5 (x: int): int = f4 (x)
fn f6 (x: int, y: int): int = x + y
prfun p1 {n:nat} .<n>. (): void = ()
prfn p2 (): void = ()
castfn c1 (x: int): int = x
extern fun ef1 (x: int): int
implement ef1 (x) = x + 1
val l1 = lam (x: int) => x + 1
val l2 = lam (x: int): int => x + 1
val l3 = llam (x: int) =<lincloptr1> x + 1
val l4 = lam@ (x: int, y: int) => x + y
val l5 = llam@ (x: int, y: int) => x + y
val l6 = lam (x: int) =<cloref1> x
val l7 = lam (x: int): int =<cloptr1> x
val l8 = fix fx (x: int): int => if x > 0 then fx (x-1) else 0
val l9 = fix@ fx2 (x: int): int => x
val l10 = lam (pf: unit_p | x: int) => x
val l11 = lam {n:nat} (x: int n): int n => x
val l12 = lam [n:nat] (x: int n): int n => x
val l13 = lam (x: int) =<> x
val l14 = lam (x: int) =<fun,!wrt> x
val l15 = lam () => 1
val l16 = lam (x: int, y: int) => lam (z: int) => x + y + z
val l17 = lam (x: int) (y: int) => x + y
fun f7 (x: int) (y: int): int = x + y
fun f8 {a:t@ype} (x: a): a = x
fun f9 (x: int, y: int): int = let
  val z = x + y
  fun g (a: int): int = a + z
in g (1) end
fun f10 (x: int): int = g (x) where { fun g (a: int): int = a + 1 }
fun f11 (x: int): int = begin x + 1 end
fun f12 (x: int): int = (print x; x)
fun f13 (xs: list_vt (int, 2)): int = case+ xs of | ~list_vt_cons (x, _) => x | ~list_vt_nil () => 0
fun f14 (x: int): int = case x of | 0 => 1 | 1 when x > 0 => 2 | _ => 3
fun f15 (x: int): int = case- x of | 0 => 1
fun f16 (x: int): int = if x > 0 then 1 else if x < 0 then ~1 else 0
fun f17 {n:int} (x: int n): int = sif n > 0 then 1 else 0
fun f18 {n:int} (x: int n): int = case+ x of | 0 => 1 | _ => 2
fun f19 (x: int): int = ifcase | x > 0 => 1 | x < 0 => ~1 | _ => 0
fun f20 (x: int): int = try x with | ~E () => 0 | ~F (y) => y
fun f21 (x: int): int = (for (i := 0; i < 3; i := i + 1) (); x)
fun f22 (x: int): int = (while (x > 0) (); x)
fun f23 (): void = let var i: int = 0 in () end
