(* termination metrics: mutually recursive functions whose metrics have different lengths and sorts, .<>., calls that do not decrease *)
#include "share/atspre_staload.hats"

fun f1 {n:int} .<n>. (x: int n): int = if x > 0 then g1 (x - 1, 0) else 0
and g1 {n:int}{m:int} .<n,m>. (x: int n, y: int m): int = if x > 0 then h1 (x - 1, true) else 0
and h1 {n:int}{b:bool} .<n,b>. (x: int n, y: bool b): int = if x > 0 then f1 (x - 1) else 0

fun f1b {n:int} .<n>. (x: int n): int = if x > 0 then g1b (x - 1, true) else 0
and g1b {n:int}{b:bool} .<n,b>. (x: int n, y: bool b): int = if x > 0 then h1b (x - 1, 0) else 0
and h1b {n:int}{m:int} .<n,m>. (x: int n, y: int m): int = if x > 0 then f1b (x - 1) else 0

fun f1c {n:int} .<n>. (x: int n): int = if x > 0 then g1c (x - 1, 0) else 0
and g1c {n:int}{m:int} .<n,m>. (x: int n, y: int m): int = if x > 0 then h1c (x - 1) else 0
and h1c {b:bool} .<b>. (x: bool b): int = 0

fun f1d {n:int} .<n,n>. (x: int n): int = if x > 0 then g1d (x - 1) else 0
and g1d {n:int} .<n>. (x: int n): int = if x > 0 then h1d (x - 1, true) else 0
and h1d {n:int}{b:bool} .<n,b>. (x: int n, y: bool b): int = 0

fun f2 {n:nat} .<n>. (x: int n): int = if x > 0 then g2 (x - 1, 0) else 0
and g2 {n:nat}{m:nat} .<n,m>. (x: int n, y: int m): int = if x > 0 then h2 (x - 1, 0) else 0
and h2 {n:nat}{m:nat}{k:nat} .<n,m,k>. (x: int n, y: int m, z: int k): int = if x > 0 then f2 (x - 1) else 0

fun f3 {n:nat} .<n,0>. (x: int n): int = if x > 0 then g3 (x - 1) else 0
and g3 {n:nat} .<n>. (x: int n): int = if x > 0 then f3 (x - 1) else 0

fun f4 {n:nat} .<n>. (x: int n): int = if x > 0 then g4 (x - 1) else 0
and g4 {n:nat} .<n,n>. (x: int n): int = if x > 0 then f4 (x - 1) else 0
and h4 {n:nat} .<n,n,n>. (x: int n): int = if x > 0 then f4 (x - 1) else 0
and i4 {n:nat} .<n>. (x: int n): int = if x > 0 then f4 (x - 1) else 0

fun f5 {n:nat} .<n>. (x: int n): int = if x > 0 then f5 (x) else 0
fun f6 {n:nat} .<n>. (x: int n): int = if x > 0 then f6 (x + 1) else 0
fun f7 {n:nat} .<n>. (x: int n): int = f7 (x - 1)
fun f8 {n:nat}{m:nat} .<n,m>. (x: int n, y: int m): int = if x > 0 then f8 (x - 1, y + 1) else if y > 0 then f8 (x, y - 1) else 0
fun f9 {n:nat}{m:nat} .<n+m>. (x: int n, y: int m): int = if x > 0 then f9 (x - 1, y) else if y > 0 then f9 (x, y - 1) else 0
fun f10 {n:int} .<n>. (x: int n): int = if x > 0 then f10 (x - 1) else 0
fun f11 {n:int} .<n>. (x: int n): int = if x > 0 then f11 (x - 1) else f11 (x + 1)
fun f12 {n:nat} .<>. (x: int n): int = if x > 0 then f12 (x - 1) else 0
fun f13 (x: int): int = if x > 0 then f13 (x - 1) else 0
fun f14 (x: int): int = if x > 0 then f14 (x - 1) else 0
and g14 {n:nat} .<n>. (x: int n): int = if x > 0 then g14 (x - 1) else 0
fun f15 {n:nat} .<n>. (x: int n): int = (if x > 0 then f15 (x - 1) else 0) + (let fun aux {k:nat} .<k>. (y: int k): int = if y > 0 then aux (y - 1) else 0 in aux (x) end)
fun f16 {a:type}{n:nat} .<n>. (x: int n, y: a): a = if x > 0 then f16 (x - 1, y) else y
fun f17 {n:nat} .<n>. (x: int n): int = let val f = lam@ (y: int): int => f17 (x - 1) in f (0) end
fun f18 {n:nat} .<n>. (x: int n): int = let val f = lam (y: int): int => f18 (x - 1) in f (0) end
fun f19 {n:nat} .<n>. (x: int n): int = let val f = llam (y: int): int => f19 (x - 1) in cloptr_free ($UNSAFE.castvwtp0{cloptr(void)} (f)); 0 end

val rec v1 : {n:nat} int n -<cloptr1> int = lam {n:nat} (x: int n) => 0
val rec v2 = fix r {n:nat} .<n>. (x: int n): int => if x > 0 then r (x - 1) else 0
val v3 = fix r {n:nat} .<n+1>. (x: int n): int => if x > 0 then r (x - 1) else 0
val v4 = lam {n:nat} .<n>. (x: int n): int => x
val v5 = lam {n:nat} .<n,n>. (x: int n): int => x
