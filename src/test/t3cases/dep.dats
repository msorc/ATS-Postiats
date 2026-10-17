(* dependent types, existentials, universals, static application, sif, constraints *)
#include "share/atspre_staload.hats"

fun add {m,n:nat} (x: int m, y: int n): int (m+n) = x + y
fun sub {m,n:nat | m >= n} (x: int m, y: int n): int (m-n) = x - y
fun abs1 {n:int} (x: int n): [m:nat | m == abs(n)] int m = if x >= 0 then x else ~x
fun max {m,n:int} (x: int m, y: int n): [k:int | k >= m; k >= n] int k = if x >= y then x else y
fun len {n:nat} (xs: list_vt (int, n)): int n = let
  fun loop {i,j:nat} (xs: !list_vt (int, i), acc: int j): int (i+j) =
    case+ xs of
    | list_vt_cons (_, xs1) => loop (xs1, acc + 1)
    | list_vt_nil () => acc
  val n = loop (xs, 0)
  val () = list_vt_free (xs)
in n end

fun f1 {b:bool} (b: bool b): int = if b then 1 else 0
fun f2 {n:int} (x: int n): bool (n > 0) = x > 0
fun f3 {n:int | n > 0} (x: int n): int = x - 1
val v3 = f3 (3)
val v4 = f3 (0)

fun ex1 (x: int): [n:int] int n = x
fun ex2 (): [n:nat] (int n, int n) = let val x = 3 in @(x, x) end
val () = let val [n:int] y = ex1 (3) in () end
val () = let val @(a, b) = ex2 () in () end

fun sa {a:t@ype} {n:nat} (xs: list_vt (a, n)): list_vt (a, n) = xs
fun hd {a:t@ype} {n:pos} (xs: !list_vt (a, n) >> list_vt (a, n)): int = 0

extern praxi lemma {n:nat} (): [n >= 0] void
fun usepf {n:nat} (x: int n): int = let prval () = lemma {n} () in x end

fun cmp {m,n:int} (x: int m, y: int n): bool (m < n) = x < y
fun cmp2 {m,n:int} (x: int m, y: int n): [b:bool | b == (m <= n)] bool b = x <= y
fun idx {n:nat} {i:nat | i < n} (a: &(@[int][n]), i: int i): int = a[i]
fun idx2 {n:nat} (a: &(@[int][n]), i: natLt (n)): int = a[i]
fun cnt {n:nat} (x: int n): int = 
  if x = 0 then 0 else 1 + cnt (x - 1)
fun termi {n:nat} .<n>. (x: int n): int = if x = 0 then 0 else termi (x - 1)
fun termi2 {m,n:nat} .<m+n>. (x: int m, y: int n): int = if x > 0 then termi2 (x-1, y) else if y > 0 then termi2 (x, y-1) else 0
fun bad {n:nat} (x: int n): int (n+1) = x
fun bad2 (x: int): int 3 = x
