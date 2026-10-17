fun f1 (x: int): int = x
fn f2 (x: int): int = x
fnx f3 (x: int): int = f4 (x)
and f4 (x: int): int = f3 (x)
fun f5 (x: int): int = f6 (x)
and f6 (x: int): int = if x > 0 then f5 (x-1) else 0
prfun f7 {n:nat} .<n>. (): void = ()
prfn f8 {n:nat} (): void = ()
extern praxi f9 {n:nat} (): void
extern castfn f10 (x: int): bool
fun f11 {n:nat} .<n>. (x: int n): int n = if x > 0 then 1 + f11 (x-1) else 0
fun f12 {n,m:nat} .<n+m>. (x: int n, y: int m): int = 0
fun f13 {n:nat} (x: int n): int n = (
  let fun loop {i:nat | i <= n} .<i>. (i: int i): int i = if i > 0 then loop (i-1) else 0 in loop (x) end
)
val v1 = 1
val v2 = (1, 2)
val (a1, a2) = v2
val+ 1 = v1
val- 2 = v1
val x as (y1, y2) = v2
prval pf = ()
prval () = pf
val rec fr (x: int): int = if x > 0 then fr (x-1) else 0
and gr (x: int): int = fr (x)
val lazy1 = lam (x: int): int => x
var vv1: int = 1
var vv2: int
var vv3 = 3
and vv4: int = 4
fun f14 (x: int): int = let
  val a = x
  and b = x + 1
in a + b end
fun f15 {a:t@ype} (x: a): a = x
fun f16 (x: int): int = f16 (x)
fun f17 (x: int): int = 1 where { fun g (y: int): int = y }
fun f18 (x: int): int = f19 (x)
fun f19 (x: int): int = x
fun f20 (x: int): int = x where { val z = f20 (1) }
fun f21 .<>. (x: int): int = x
fun f22 {n:nat} .<n, 0>. (x: int n): int = 0
fun f23 {n:int} (x: int n): int = f23 {n} (x)
fun f25 (f: int -<cloref1> int, x: int): int = f (x)
fun f26 (x: int): (int -<cloref1> int) = lam y =<cloref1> x + y
val gg = f26 (1)
fun f27 (x: int): int = let fun g (y: int): int = y + x in g (x) end
