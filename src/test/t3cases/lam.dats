(* lambdas with argument patterns, closures, static lambdas, fix *)
#include "share/atspre_staload.hats"

fun add1 (x: int): int = x + 1
fun swap (p: @(int, bool)): @(bool, int) = @(p.1, p.0)
fun fst {a,b:t@ype} (p: @(a, b)): a = p.0

fun apply {a,b:t@ype} (f: (a) -> b, x: a): b = f (x)
fun apply2 (f: (int, int) -> int, x: int, y: int): int = f (x, y)

val r1 = apply (add1, 3)
val r2 = apply2 (lam (x, y) => x * y + 1, 3, 4)
val r3 = apply2 (lam (x: int, y: int): int => if x > y then x else y, 3, 4)

fun twice (f: (int) -> int, x: int): int = f (f (x))
val r4 = twice (lam (x) => x + 2, 1)

fun fact (n: int): int = let
  fun loop (n: int, acc: int): int = if n <= 0 then acc else loop (n - 1, acc * n)
in loop (n, 1) end

val f5 = fix fib (n: int): int => if n < 2 then n else fib (n-1) + fib (n-2)

fun {a:t@ype} id (x: a): a = x
val r6 = id<int> (3)

fun stad {n:nat} (x: int n): int (n+1) = x + 1
val r7 = stad (5)

fun metric {n:nat} .<n>. (x: int n): int = if x > 0 then metric (x - 1) else 0

fun lamsta (x: int): int = let
  val f = lam {n:int} (y: int n): int n => y
in f (x) end

val lamlin = llam (x: int): int => x + 1
val r8 = lamlin (3)
val () = cloptr_free ($UNSAFE.castvwtp0{cloptr(void)} (lamlin))

fun pat1 (p: @(int, @(int, int))): int = let val @(a, @(b, c)) = p in a + b + c end
val pr = lam@ (x: int, y: int): int => x - y
val r9 = pr (3, 1)
