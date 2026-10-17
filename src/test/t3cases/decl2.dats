(* declarations: reassume, extype, extern var, abstypes, termination metrics, val rec with linear patterns, var declarations without types *)
#include "share/atspre_staload.hats"

datavtype dvt = DVT of (int)
fun free_dvt (x: dvt): void = let val+ ~DVT _ = x in end
overload free with free_dvt

(* abstract types and assumptions *)
abstype abt1
abstype abt2
reassume abt1
assume abt2 = int
reassume abt2
assume abt1 = int
reassume abt1
absvtype avt1
reassume avt1
abstype abt3 (n:int)
assume abt3 (n:int) = int
absview av1
assume av1 = unit_v
absprop ap1
assume ap1 = unit_p
extype "foo_t" = int
extype "bar_t" = dvt
extern typedef "baz_t" = int
extern var "my_extvar" = 1
extern var "my_extvar2" = (1, true)
extern var "my_extvar3" = DVT 1
extern var "my_extvar4" = lam (x: int): int => x

(* metrics *)
fun m1 {n:nat} .<n>. (x: int n): int = if x > 0 then m1 (x - 1) else 0
and m2 {n:nat} .<n, n>. (x: int n): int = if x > 0 then m1 (x - 1) else 0
fun m3 {n:nat} .<n>. (x: int n): int = 0
and m4 {n:nat} .<n+1>. (x: int n): int = m3 x
fun m5 {n:nat} .<n>. (x: int n): int = 0
and m6 {b:bool} .<b>. (x: bool b): int = 0
fun m7 {n:nat} .<n>. (x: int n): int = 0
and m8 {s:int} (x: int s): int = 0
fun m9 {n:nat} (x: int n): int = 0
and m10 {n:nat} .<n>. (x: int n): int = 0
fun m11 {n:nat} .<n>. (x: int n): int = if x > 0 then m11 (x + 1) else 0
fun m12 {n:nat} .<n>. (x: int n): int = if x > 0 then m12 (x) else 0
fun m13 {n,m:nat} .<n,m>. (x: int n, y: int m): int =
  if x > 0 then m13 (x-1, y) else if y > 0 then m13 (x, y-1) else 0
fun m14 {n,m:nat} .<n+m>. (x: int n, y: int m): int =
  if x > 0 then m14 (x-1, y) else if y > 0 then m14 (x, y-1) else 0
fun m15 {n:nat} .<n>. (x: int n): int = $effmask_ntm (m15 (x))
fun m16 (x: int): int = m16 x
fun m17 (x: int):<!ntm> int = m17 x
fun m18 {n:nat} .<n>. (x: int n):<!ntm> int = m18 x
fun m19 {n:nat} .<n>. (x: int n): int = (fix f (y: int): int => f y) x

(* val rec with linear patterns *)
val rec r1: dvt = DVT 1
val rec r2 = DVT 1
val rec r3: (dvt, int) = (DVT 1, 2)
val rec r4: int = 1
val rec r5 = lam (x: dvt): dvt => x
val rec @(r6, r7) = @(DVT 1, 2)
val rec r8 = (lam (x: int): int => x, DVT 1)

(* var declarations *)
fun v1 (): void = let var x = 1 in () end
fun v2 (): void = let var x: int in () end
fun v3 (): void = let var x: int = 1 and y: int = 2 in () end
fun v4 (): void = let var x: int? in x := 1 end
fun v5 (): void = let var x: dvt in () end
fun v6 (): void = let var x: dvt = DVT 1 in free x end
fun v7 (): void = let var x: dvt = DVT 1 in () end
fun v8 (): void = let var x: int = true in () end
fun v9 (): void = let var x: int with pf = 1 in () end
fun v10 (): void = let var x with pf = 1 in () end
fun v11 (): void = let var x: int with pf in () end
fun v13 (): void = let var x: int = 1 var y: int = x in () end
fun v14 (): void = let var x: @(int, int) = @(1, 2) in () end
fun v15 (): void = let var x: @(int, int) in x.0 := 1; x.1 := 2 end
fun v16 (): void = let var x: @[int][3] in () end
fun v17 (): void = let var x = @[int][3](0) in () end
fun v18 (): void = let var x: @[int][3] = @[int][3](0) in () end
fun v19 (): void = let var x: @[dvt][3] in () end
fun v20 (): void = let var x: dvt? in () end
fun v21 (): void = let var x: dvt? = DVT 1 in () end
fun v22 (): void = let var x: (dvt?) in () end
fun v23 (): int = let var x: int = 1 and y: bool = x in 1 end

(* local declarations *)
fun d1 (): int = let
  local
    val x = 1
  in
    val y = x + 1
  end
in y end
fun d2 (): int = let
  fun f (x: int): int = x
  and g (x: int): int = f x
  val z = g 1
in z end
fun d3 (): int = let
  fun f (x: int): int = g x
  and g (x: int): int = f x
in 1 end
fun d4 (): int = let
  val rec f = lam (x: int): int => f x
in 1 end
fun d5 (): int = let
  prfun p {n:nat} .<n>. (x: int n): void = ()
  prval () = p 1
in 1 end
fun d8 (): int = let
  prval pf = unit_p()
  prval () = pf
in 1 end
fun d9 (): int = let
  prval pf = unit_v()
in 1 end
fun d10 (): int = let
  macdef m (x) = ,(x) + 1
in m 1 end
fun d11 (): int = let
  val x = 1
  val y = x
  val x = true
in y end
fun d12 (): int = let
  stadef t = int
  typedef u = t
  val x: u = 1
in x end
fun d13 (): int = let
  datatype d = D1 | D2
in 1 end
fun d14 (): int = let
  datavtype d = D1 | D2 of (int)
  val x = D2 1
  val+ ~D2 n = x
in n end
fun d15 (): int = let
  dataprop p (int) = | P0 (0) | {n:nat} P1 (n+1) of p (n)
  prval pf = P1 (P0 ())
in 1 end
fun d16 (): int = let
  dataview v (int) = | V0 (0) | {n:nat} V1 (n+1) of v (n)
  prval pf = V1 (V0 ())
  prval V1 (V0 ()) = pf
in 1 end
fun d17 (): int = let
  exception E of int
in 1 end
fun d18 (): int = let
  val x = (try 1 with | ~E1 => 2)
in x end
fun d19 (): int = let
  val x = $raise Subscript ()
in 1 end
fun d20 (): int = let
  #define X 3
in X end
fun d21 (): int = let
  implement main0 () = ()
in 1 end
fun d22 (): int = let
  extern fun foo (): int
  implement foo () = 1
in foo () end
fun d23 (): int = let
  extern fun foo (): int
  extern fun foo (): int
in 1 end
fun d24 (): int = let
  extern fun foo (): int = "mac#foo"
in foo () end
fun d25 (): int = let
  staload "prelude/SATS/integer.sats"
in 1 end
fun d26 (): int = let
  staload X = "prelude/SATS/integer.sats"
in 1 end
fun d28 (): int = let
  sortdef nat2 = {n:int | n >= 0}
in 1 end
fun d29 (): int = let
  stacst c: int
  stadef cc = c + 1
in 1 end
fun d30 (): int = let
  prval () = $solver_assert (unit_p ())
in 1 end

(* metrics of different lengths, longer first *)
fun n1 {n:nat} .<n,n>. (x: int n): int = if x > 0 then n2 (x - 1) else 0
and n2 {n:nat} .<n>. (x: int n): int = if x > 0 then n1 (x - 1) else 0
and n3 {n:nat} .<n,n,n>. (x: int n): int = n1 x
fun n4 {n:nat} .<n>. (x: int n): int = 0
and n5 {n:nat} .<n,n>. (x: int n): int = n4 x
and n6 {n:nat} .<n,n,n>. (x: int n): int = n5 x
and n7 {n:nat} .<n>. (x: int n): int = n6 x
fun n8 {n:nat} .<n,n>. (x: int n): int = 0
and n9 {n:nat} .<n,n,n>. (x: int n): int = 0
and n10 {n:nat} .<n>. (x: int n): int = 0
and n11 {n:nat} .<n,n>. (x: int n): int = n8 x
