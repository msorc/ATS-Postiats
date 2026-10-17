fun e1 (x: int): int = 1 + 
fun e2 (x: int): int = x
fun e2 (x: int): int = x
val e3 = lam (x: int) => x
fun e4 (x: int): int = e5 (x)
and e5 (x: int): int = x
fun e6 (x: int): int = lam (y: int): int => y
fun e7 (x: int) = x
fun e8 : int -> int = lam x => x
fun e9 (x: int): int = e9 (1) where { val y = nosuch }
val e10 : int = true
prfun e11 (): int = 0
fun e12 {n:nat} .<n>. (x: int n): int = e12 (x)
fun e13 (x: int): int = if x then 1 else 2
val e14 = (1, 2) = (1, 2)
val (e15, e16) = 1
val 1 = e17
var e18: nosuch = 1
fun e19 (x: int): int = 
  case+ x of 0 => 1 
fun e21 (x: int): int = x : bool
fun e22 (x: int): int = x : nosuch
fun e23 (x: int): int = (x : int) : int
val e24 = ()()
val e25 = (1)(2)
val e26 = lam (x: int, x: int): int => x
