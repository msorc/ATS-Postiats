(* proof manager: views in flat tuples and records, nested; deref/assign through them; lambdas that keep or consume the proofs *)
#include "share/atspre_staload.hats"
extern praxi cons1 {l:addr} (pf: int @ l): void
extern praxi ax1 {l:addr} (pf: !int @ l): void
extern praxi ax2 {l:addr} (pf: int @ l): int @ l
extern praxi ax3 {l:addr} (pf: int @ l): (int @ l, int @ l)

fun d1 {l1,l2,l3:addr}
  (pf: @(int @ l1, int @ l2, int @ l3) | a: ptr l1, b: ptr l2, c: ptr l3): int = !c + !b + !a
fun d2 {l1,l2,l3:addr}
  (pf: ! @(int @ l1, int @ l2, int @ l3) | a: ptr l1, b: ptr l2, c: ptr l3): int = !c + !b + !a
fun d3 {l1,l2,l3:addr}
  (pf: ! @{x= int @ l1, y= int @ l2, z= int @ l3} | a: ptr l1, b: ptr l2, c: ptr l3): int = !c + !b + !a
fun d4 {l1,l2,l3:addr}
  (pf: ! @{x= int @ l1, y= int @ l2, z= int @ l3} | a: ptr l1, b: ptr l2, c: ptr l3): void = (!a := 1; !b := 2; !c := 3)
fun d5 {l1,l2:addr}
  (pf: ! @(int @ l1, @(int @ l2, int @ l1)) | a: ptr l1, b: ptr l2): int = !b + !a
fun d6 {l1,l2:addr}
  (pf: ! @(@(int @ l1, int @ l2), int @ l2) | a: ptr l1, b: ptr l2): int = !a + !b
fun d7 {l1,l2:addr}
  (pf: ! @{p= @{q= int @ l1}, r= int @ l2} | a: ptr l1, b: ptr l2): int = !a + !b
fun d8 {l1,l2:addr}
  (pf: ! @{p= @(int, int @ l1), r= int @ l2} | a: ptr l1, b: ptr l2): int = !a + !b
fun d9 {l1,l2:addr}
  (pf: ! @(int @ l1, int @ l2) | a: ptr l1, b: ptr l2): int = !b
fun d10 {l1,l2,l3:addr}
  (pf: ! @(int @ l1, int @ l2) | a: ptr l1, b: ptr l2, c: ptr l3): int = !c
fun d11 {l1:addr} {n:nat}
  (pf: ! @(@[int][n] @ l1, int) | a: ptr l1): int = 0
fun d12 {l1,l2:addr}
  (pf: !(int @ l1) | a: ptr l1, b: ptr l2): int = let
  fun aux {l:addr} (pf: !(int @ l1) | a: ptr l1, b: ptr l2): int = !b
in aux (pf | a, b) end
fun d13 {l1,l2:addr}
  (pf1: int @ l1, pf2: int @ l2 | a: ptr l1, b: ptr l2): (int @ l1, int @ l2 | int) = (pf1, pf2 | !a + !b)
fun d14 {l1,l2:addr}
  (pf1: !int @ l1, pf2: !int @ l2 | a: ptr l1, b: ptr l2): int = let
  val f = lam@ (): int => !a + !b
in f () end
fun d15 {l1,l2:addr}
  (pf1: !int @ l1, pf2: !int @ l2 | a: ptr l1, b: ptr l2): int = let
  val f = llam (): int => 1
  val n = f ()
  val () = cloptr_free ($UNSAFE.castvwtp0{cloptr(void)} (f))
in n end
fun d16 {l1,l2:addr}
  (pf1: !int @ l1, pf2: !int @ l2 | a: ptr l1, b: ptr l2): int =
  (try !a + !b with | ~MyExn _ => 0) where { exception MyExn of int }
fun d17 {l1:addr} (pf: int @ l1 | a: ptr l1): void = ()
fun d18 {l1:addr} (pf: int @ l1 | a: ptr l1): int = let
  prval () = cons1 (pf)
in 0 end
fun d19 {l1:addr} (pf: int @ l1 | a: ptr l1): (int @ l1 | int) = let
  val x = !a
in (pf | x) end
fun d20 {l1:addr} (pf: int @ l1 | a: ptr l1): (int @ l1 | int) = let
  val x = (if !a > 0 then !a else 0)
in (pf | x) end
prfun lemma1 {l1,l2:addr} .<>. (pf: !int @ l1, pf2: !int @ l2): void = ()
prfun lemma2 {l1,l2:addr} .<>. (pf: int @ l1, pf2: int @ l2): (int @ l1, int @ l2) = (pf, pf2)
prfun lemma3 {l1,l2:addr} .<>. (pf: (int @ l1, int @ l2)): void = ()
fun d21 {l1,l2:addr} (pf: int @ l1 | a: ptr l1): (int @ l1 | int) = let
  prval pf = ax2 (pf)
  prval () = ax1 (pf)
  prval (pf1, pf2) = ax3 (pf)
  prval () = cons1 (pf2)
in (pf1 | !a) end

(* lambdas with proof arguments typed downward: the proof variables are marked (isprf) in the downward path too *)
val lf1: {l:addr} (!int @ l | ptr l) -<cloptr1> void = lam (pf | p) => ()
val lf2: {l:addr} (int @ l | ptr l) -<cloptr1> (int @ l | int) = lam (pf | p) => (pf | !p)
val lf3: {l:addr} (!int @ l | ptr l) -<cloptr1> int = lam (pf | p) => !p
val lf4: {l1,l2:addr} (!int @ l1, !int @ l2 | ptr l1, ptr l2) -<cloptr1> int = lam (pf1, pf2 | p1, p2) => !p1 + !p2
val lf5: {l:addr} (!int @ l | ptr l) -<fun> void = lam (pf | p) => ()
val lf6: {l1,l2:addr} (!int @ l1, !int @ l2 | ptr l1, ptr l2) -<fun> int = lam (pf1, pf2 | p1, p2) => !p1 + !p2
val lf7: {l:addr} (!int @ l | ptr l) -<cloptr1> int = lam (pf | p) => (pf; 1)
val lf8: {l:addr} (!int @ l | ptr l, int) -<cloptr1> int = lam (pf | p, n) => n
fun applf {l:addr} (pf: !int @ l | p: ptr l, f: (!int @ l | ptr l) -<cloptr1> int): int = f (pf | p)
fun applf2 {l:addr} (pf: !int @ l | p: ptr l): int = applf (pf | p, lam (pf1 | q) => !q)
fun applf3 {l:addr} (pf: !int @ l | p: ptr l): int = applf (pf | p, lam (pf1 | q) => 1)
