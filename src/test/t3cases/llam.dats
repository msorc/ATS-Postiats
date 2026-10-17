(* linear closures: llam capturing and consuming linear values, lam capturing linear values, nested closures, two proofs in arguments *)
#include "share/atspre_staload.hats"

datavtype dvt = DVT of (int)
fun free_dvt (x: dvt): void = let val+ ~DVT _ = x in end
overload free with free_dvt
fun mk (): dvt = DVT 0

fun f1 (x: dvt): () -<lincloptr1> void = llam () => free x
fun f2 (x: dvt, y: dvt): () -<lincloptr1> void = llam () => (free x; free y)
fun f3 (x: dvt): void = let
  val f = llam () => free x
in f () end
fun f4 (x: dvt): void = let
  val f = llam () => free x
  val () = f ()
in end
fun f5 (x: dvt): () -<lincloptr1> void = let
  val f = llam () => free x
in f end
fun f6 (x: dvt): () -<cloptr1> void = lam () => free x
fun f7 (x: dvt): () -<cloptr1> void = lam () => (let val+ DVT (n) = x in () end)
fun f8 (x: dvt): void = let
  val f = llam () => (free x; free x)
in f () end
fun f9 (x: dvt): void = let
  val f = llam () => free x
in free x; f () end
fun f10 (x: dvt): void = let
  val f = llam (y: dvt) => (free x; free y)
in f (mk ()) end
fun f11 (x: dvt): void = let
  val f = llam () => (let val g = llam () => free x in g () end)
in f () end
fun f12 (x: dvt): void = let
  val f = llam () => (let val g = lam () => free x in g () end)
in f () end
fun f13 (x: dvt, n: int): void = let
  val f = llam () => (if n > 0 then free x else free x)
in f () end
fun f14 (x: dvt, n: int): void = let
  val f = llam () => (if n > 0 then free x else ())
in f () end
fun f15 (x: dvt, n: int): void = let
  val f = llam () => (case+ n of | 0 => free x | _ => free x)
in f () end
fun f16 (n: int): void = let
  val x = DVT 1
  val f = llam () => free x
in f () end
fun f17 (n: int): void = let
  val x = DVT 1
  val y = DVT 2
  val f = llam () => (free x; free y)
in f () end
fun f18 (n: int): void = let
  var x: dvt = DVT 1
  val f = llam () => free x
in f () end
fun f19 (n: int): void = let
  var x: int = 1
  val f = llam () => (x := x + 1)
in f () end
fun f20 (n: int): void = let
  var x: int = 1
  val f = lam@ () => (x := x + 1)
in f () end
fun f21 (n: int): int = let
  var x: int = 1
  val f = lam@ () => x
in f () end
fun f22 (x: int): void = let
  val f = llam () => x
in f () end
fun f23 (x: int): void = let
  val f = llam () => x
  val () = f ()
in end
fun f24 {l:addr} (pf: dvt @ l | p: ptr l): void = let
  val f = llam () => (let prval pf1 = pf in () end)
in f () end
fun f25 {l:addr} (pf: !int @ l | p: ptr l): void = let
  val f = lam () => !p
in () end
fun f26 {l:addr} (pf: !int @ l | p: ptr l): void = let
  val f = lam@ () => !p
in () end
fun f27 {l:addr} (pf: int @ l | p: ptr l): (int @ l | void) = let
  val f = llam () => (let prval pf1 = pf in () end)
in (pf | ()) end
fun f28 (x: dvt): void = let
  val f = llam () => (let val y = x in free y end)
in f () end
fun f29 (x: dvt): void = let
  val f = llam () => (let val @DVT (n) = x in fold@ x; free x end)
in f () end
fun f30 (x: dvt): void = let
  val f = llam () => (case+ x of | ~DVT (n) => ())
in f () end
fun f31 (x: dvt): void = let
  val f = llam () => (case+ x of | DVT (n) => free x)
in f () end
fun f32 (x: dvt): void = let
  val f = llam () => (case+ x of | DVT (n) => ())
in f () end

(* two proofs in arguments *)
dataprop pr (int) = | PR0 (0) | {n:nat} PR1 (n+1) of pr (n)
fun g1 {l1,l2:addr} (pf1: !int @ l1, pf2: !int @ l2 | p: ptr l1, q: ptr l2): int = !p + !q
fun g2 {l1,l2:addr} (pf1: int @ l1, pf2: int @ l2 | p: ptr l1, q: ptr l2): (int @ l1, int @ l2 | void) = (pf1, pf2 | ())
fun g3 {l1,l2:addr} (pf1: int @ l1, pf2: int @ l2 | p: ptr l1, q: ptr l2): void = ()
fun g4 {l1,l2:addr} (pf1: int @ l1, pf2: int @ l2 | p: ptr l1, q: ptr l2): (int @ l1 | void) = (pf1 | ())
fun g5 (pf1: unit_p, pf2: unit_p | x: int): int = x
fun g6 (pf1: unit_v, pf2: unit_v | x: int): int = x
fun g7 (pf1: unit_v, pf2: unit_p, pf3: unit_v | x: int): int = x
fun g8 (pf1: !unit_v, pf2: !unit_p, pf3: !unit_v | x: int): int = x
fun g9 {n:nat} (pf1: pr (n), pf2: pr (n) | x: int n): int = x
fun g10 (pf1: unit_v, pf2: unit_v | x: int): (unit_v, unit_v | int) = (pf1, pf2 | x)
val h1 = lam (pf1: unit_p, pf2: unit_p | x: int) => x
val h2 = lam (pf1: unit_v, pf2: unit_v | x: int) => (pf1, pf2 | x)
val h3 = lam (pf1, pf2 | x: int) => x
val h4 = lam (pf1: unit_p, pf2: unit_v | x: int) => (pf2 | x)
val h5 = lam (pf1: unit_p, pf2: unit_v | x: int) => (pf1, pf2 | x)
fun g11 (pf1: unit_p, pf2: unit_p | x: int): void = let prval () = pf1 prval () = pf2 in end
fun g12 (pf1: unit_p, pf2: unit_p | x: int): void = let prval () = pf2 in end
fun g13 (pf1: unit_v, pf2: unit_v | x: int): void = let prval unit_v () = pf2 in end
fun g14 (pf1: unit_v, pf2: unit_v | x: int): void = let prval unit_v () = pf1 prval unit_v () = pf2 in end
fun g15 (pf1: unit_p, pf2: unit_p | x: int): int = g5 (pf2, pf1 | x)
fun g16 (pf1: unit_p, pf2: unit_p | x: int): int = g5 (pf2 | x)
fun g17 (pf1: unit_p, pf2: unit_p | x: int): int = g5 (pf2, pf1, pf1 | x)
