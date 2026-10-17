(* linear closures, selection from linear records, loops with invariants, metrics of different lengths, sharing *)
#include "share/atspre_staload.hats"

datavtype il = inil | icons of (int, il)
fun ifree (xs: il): void = case+ xs of | ~icons (_, xs1) => ifree (xs1) | ~inil () => ()

fun c1 (xs: il): void = let val g = llam (): void => ifree (xs) in cloptr_free ($UNSAFE.castvwtp0{cloptr(void)} (g)) end
fun c2 (xs: il): void = let val g = lam (): void => ifree (xs) in () end
fun c3 (xs: il): void = let val g = lam@ (): void => ifree (xs) in () end
fun c4 (xs: il): (() -<lincloptr1> void) = llam (): void => ifree (xs)
fun c5 (xs: !il): int = let val g = llam (): int => 1 in cloptr_free ($UNSAFE.castvwtp0{cloptr(void)} (g)); 0 end
val d1 = lam (xs: il) => llam () => ifree (xs)
val d2 = lam (xs: il) => lam () => ifree (xs)
val d3 = llam (x: int) => x
val d4 = (llam (xs: il, n: int) => (ifree (xs); n)) 

vtypedef lr = @{ a= il, b= int }
fun s1 (r: &lr): int = r.b
fun s2 (r: &lr): il = r.a
fun s3 (r: lr): int = r.b
fun s4 (r: lr): il = r.a
fun s5 (r: &lr): void = r.a := inil ()
fun s6 (r: &lr): void = r.b := 3
fun s8 (t: &(@(il, il))): il = t.0
fun s9 (t: &(@(il, int))): int = t.1
fun s10 (t: &(@(il, int))): void = t.0 := inil ()
fun s11 (t: &(@(il, int))): void = t.0 :=: t.0
fun s12 (t: &(@(il, il))): void = t.0 :=: t.1
fun s13 (t: &(@(il, il)) >> @(il, il)): void = (t.0 := inil ())

fun l1 (n: int): int = let var i: int = 0 in (for (i := 0; i < n; i := i + 1) (); i) end
fun l2 {n:nat} (n: int n): int = let
  var i: int = 0
  val () = while* {i:nat | i <= n} .<n-i>. (i: int i): (i: int) => (i < n) (i := i + 1)
in i end
fun l3 {n:nat} (n: int n): int = let
  var i: int = 0
  val () = for* {i:nat | i <= n} .<n-i>. (i: int i): (i: int) => (i := 0; i < n; i := i + 1) ()
in i end
fun l4 (n: int): int = let var i: int = 0 val () = while (true) (if i > n then $break else (i := i + 1; $continue)) in i end
fun l5 (n: int): void = for (;;) ($break)
fun l6 (n: int): void = ($break)
fun l7 (n: int): void = while (n > 0) ($continue; $break)
fun l8 (n: int): void = let var i: int = 0 var s: il = inil () in (while (i < n) (s := icons (i, s); i := i + 1); ifree (s)) end
fun l9 (n: int): void = let var s: il = inil () in (while (n > 0) (ifree (s)); ifree (s)) end

fun m1 {m,n:nat} .<m,n>. (x: int m, y: int n): int = if x > 0 then m1 (x-1, y) else if y > 0 then m1 (x, y-1) else 0
fun m2 {m,n:nat} .<m>. (x: int m, y: int n): int = if x > 0 then m2 (x-1, y) else 0
fun m3 {m:nat} .<m,m>. (x: int m): int = if x > 0 then m3 (x-1) else 0
fun m4 {m:nat} .<m>. (x: int m): int = if x > 0 then m4 (x) else 0
fun m5 {m:nat} .<m>. (x: int m): int = if x > 0 then m5 (x-1) else 0
and m6 {m:nat} .<m,1>. (x: int m): int = m5 (x)
fun m7 (x: int): int = if x > 0 then m7 (x-1) else 0
fun m8 {m:int} .<m>. (x: int m): int = if x > 0 then m8 (x-1) else 0
fun m9 {m:nat} .<(*bad*)true>. (x: int m): int = 0
fun m10 {m:nat} .<m+1>. (x: int m): int = if x > 0 then m10 (x-1) else 0
