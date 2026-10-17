(* constructor patterns: decorations ~ and @ applied wrongly, unfolded types matched again, proof arities, nonlinear constructors *)
#include "share/atspre_staload.hats"

datavtype dvt = DVT of (int)
fun free_dvt (x: dvt): void = let val+ ~DVT _ = x in end
overload free with free_dvt
datavtype node = Nil | Cons of (int, node)
datatype color = Red | Green | Blue
dataprop pr (int) = | PR0 (0) | {n:nat} PR1 (n+1) of pr (n)
dataview vw (int) = | VW0 (0) | {n:nat} VW1 (n+1) of vw (n)
dataview vw2 (l:addr) = | VW2 (l) of (int @ l | )
datavtype pair = Pair of (dvt, dvt)

(* the type of the matched variable is already unfolded *)
fun u1 (x: dvt): int = case+ x of | @DVT (n) => (case+ x of | ~DVT (m) => m)
fun u2 (x: dvt): int = case+ x of | @DVT (n) => (case+ x of | @DVT (m) => m)
fun u3 (x: dvt): int = case+ x of | @DVT (n) => (case+ x of | DVT (m) => m)
fun u4 (x: dvt): int = case+ x of | @DVT (n) => (fold@ x; case+ x of | ~DVT (m) => m)
fun u5 (x: node): int = case+ x of | @Cons (n, xs) => (case+ x of | Nil () => 0 | Cons (a, b) => a)
fun u6 (x: node): int = case+ x of | @Cons (n, xs) => (case+ x of | ~Nil () => 0 | ~Cons (a, b) => a)
fun u7 (x: node): int = case+ x of | @Cons (n, xs) => (case+ x of | @Nil () => 0 | @Cons (a, b) => a)
fun u8 (x: node): int = case+ x of | @Cons (n, xs) => (fold@ x; free x; 0) | ~Nil () => 0
fun u10 (x: pair): int = case+ x of | @Pair (a, b) => (case+ x of | ~Pair (c, d) => (free c; free d; 0))
fun u11 (x: pair): int = case+ x of | ~Pair (a, b) => (free a; free b; 0)
fun u12 (x: pair): int = case+ x of | @Pair (a, b) => (fold@ x; free@ x; 0)
fun u13 (x: !pair): int = case+ x of | @Pair (a, b) => (fold@ x; 0)
fun u14 (x: !pair): int = case+ x of | Pair (a, b) => 0
fun u15 (x: !pair): int = case+ x of | ~Pair (a, b) => 0
fun u16 (x: pair): int = case+ x of | Pair (a, b) => (free a; free b; 0)
fun u17 (x: pair): int = case+ x of | Pair (a, b) => 0

(* nonlinear constructors *)
fun c1 (x: color): int = case+ x of | Red () => 1 | Green () => 2 | Blue () => 3
fun c2 (x: color): int = case+ x of | ~Red () => 1 | _ => 2
fun c3 (x: color): int = case+ x of | @Red () => 1 | _ => 2
fun c4 (x: color): int = case+ x of | Red => 1 | _ => 2
fun c5 (x: color): int = case+ x of | Red (1) => 1 | _ => 2
fun c6 (x: color): int = case+ x of | Red (a, b) => 1 | _ => 2
fun c7 (x: int): int = case+ x of | Red () => 1 | _ => 2
fun c9 (x: color): int = let val ~Red () = x in 1 end
fun c10 (x: color): int = let val @Red () = x in 1 end
fun c11 (x: color): int = case+ x of | Red () when true => 1 | _ => 2
fun c12 (x: !color): int = case+ x of | Red () => 1 | _ => 2
fun c13 (x: color): color = case+ x of | Red () => Green () | Green () => Blue () | Blue () => Red ()
fun c14 (x: color, y: color): int = case+ (x, y) of | (Red (), Red ()) => 1 | (_, _) => 2
fun c15 (x: color, y: color): int = case+ (x, y) of | (Red (), _) => 1 | (_, Green ()) => 2 | (_, _) => 3

(* proofs *)
fun p1 {n:nat} (pf: pr n): void = case+ pf of | PR0 () => () | PR1 (pf1) => ()
fun p2 {n:nat} (pf: pr n): void = case+ pf of | PR0 (pf1 | ) => () | PR1 (pf1) => ()
fun p3 {n:nat} (pf: pr n): void = case+ pf of | PR0 () => () | PR1 (pf1 | pf2) => ()
fun p4 {n:nat} (pf: pr n): void = case+ pf of | PR0 () => () | PR1 () => ()
fun p5 {n:nat} (pf: pr n): void = case+ pf of | PR0 () => () | PR1 (pf1, pf2) => ()
fun p6 {n:nat} (pf: vw n): void = case+ pf of | ~VW0 () => () | ~VW1 (pf1) => (pf1 := pf1; ())
fun p7 {n:nat} (pf: vw n): void = case+ pf of | ~VW0 () => () | ~VW1 (pf1 | ) => ()
fun p8 {n:nat} (pf: vw n): void = case+ pf of | ~VW0 () => () | ~VW1 () => ()
fun p9 {n:nat} (pf: vw n): void = case+ pf of | VW0 () => () | VW1 (pf1) => ()
fun p10 {n:nat} (pf: !vw n): void = case+ pf of | VW0 () => () | VW1 (pf1) => ()
fun p11 {n:nat} (pf: vw n): void = case+ pf of | @VW0 () => () | @VW1 (pf1) => fold@ pf
fun p12 {n:nat} (pf: !vw n): void = case+ pf of | @VW0 () => fold@ pf | @VW1 (pf1) => fold@ pf
fun p13 {l:addr} (pf: vw2 l): int @ l = case+ pf of | ~VW2 (pf1 | ) => pf1
fun p14 {l:addr} (pf: vw2 l): int @ l = case+ pf of | ~VW2 (pf1) => pf1
fun p15 {l:addr} (pf: vw2 l): int @ l = case+ pf of | ~VW2 (pf1 | pf2) => pf1
fun p16 {l:addr} (pf: vw2 l): int @ l = case+ pf of | ~VW2 (pf1, pf2 | ) => pf1
fun p17 {l:addr} (pf: !vw2 l): void = case+ pf of | VW2 (pf1 | ) => ()
fun p18 {l:addr} (pf: !vw2 l): void = case+ pf of | @VW2 (pf1 | ) => fold@ pf
fun p19 (pf: pr 0): void = case+ pf of | PR0 () => ()
fun p20 (pf: pr 0): void = case+ pf of | PR1 (pf1) => ()
fun p21 (pf: pr 1): void = case+ pf of | PR0 () => () | PR1 (pf1) => ()
fun p22 (pf: pr 1): void = case+ pf of | PR1 (pf1) => ()
fun p23 {n:nat} (pf: pr (n+1)): void = case+ pf of | PR1 (pf1) => ()
fun p24 {n:nat} (pf: pr n): void = case+ pf of | PR1 (pf1) => ()
fun p25 {n:nat} (pf: pr n): void = case+ pf of | PR0 () => ()
fun p26 {n:int} (pf: pr n): void = case+ pf of | PR0 () => () | PR1 (pf1) => ()
fun p27 (pf: [n:nat] pr n): void = case+ pf of | PR0 () => () | PR1 (pf1) => ()
prfun p28 {n:nat} .<n>. (pf: pr n): void = case+ pf of | PR0 () => () | PR1 (pf1) => p28 pf1

(* constructor patterns of wrong types and arities *)
fun w1 (x: dvt): int = case+ x of | ~Nil () => 0 | ~DVT (n) => n
fun w2 (x: dvt): int = case+ x of | ~DVT (n, m) => n
fun w3 (x: dvt): int = case+ x of | ~DVT () => 0
fun w5 (x: node): int = case+ x of | ~Nil (n) => n | ~Cons (n, m) => n
fun w7 (x: node): int = case+ x of | ~Cons (n, m, o) => 0 | ~Nil () => 0
fun w8 (x: node): int = case+ x of | ~Cons (true, m) => 0 | ~Nil () => 0
fun w9 (x: node): int = case+ x of | ~Cons (1, ~Nil ()) => 0 | ~Cons (n, ~Cons (m, xs)) => (free xs; 0) | ~Nil () => 0
fun w10 (x: node): int = case+ x of | ~Cons (1, y) => (free y; 0) | ~Cons (_, y) => (free y; 1) | ~Nil () => 2
fun w11 (x: node): int = case+ x of | Cons (1, y) => 0 | _ => 1
fun w13 (x: node): int = case+ x of | ~Cons (_, _) => 0 | ~Nil () => 1
fun w14 (x: node): int = case+ x of | ~Cons (n, ~Nil ()) => n | ~Cons (n, @Cons (m, xs)) => (fold@ xs; 0) | _ => 0
fun w15 (x: node): int = let val ~Cons (n, xs) = x in free xs; n end
fun w16 (x: node): int = let val+ ~Cons (n, xs) = x in free xs; n end
fun w17 (x: node): int = let val- ~Cons (n, xs) = x in free xs; n end
fun w18 (x: node): int = let val @Cons (n, xs) = x in fold@ x; free x; n end
fun w19 (x: node): int = let val Cons (n, xs) = x in n end
fun w20 (x: node, y: node): int = case+ (x, y) of | (~Nil (), ~Nil ()) => 0 | (~Cons (n, xs), ~Nil ()) => (free xs; n) | (~Nil (), ~Cons (n, ys)) => (free ys; n) | (~Cons (n, xs), ~Cons (m, ys)) => (free xs; free ys; n + m)

(* values of constructor types *)
fun k1 (): int = let val x = DVT 1 in case+ x of | ~DVT (n) => n end
fun k2 (): int = let val x = DVT 1 in case+ x of | @DVT (n) => (fold@ x; free x; n) end
fun k3 (): int = let val x = DVT 1 in case+ x of | DVT (n) => (free x; n) end
fun k4 (): int = case+ DVT 1 of | ~DVT (n) => n
fun k5 (): int = case+ DVT 1 of | @DVT (n) => n
fun k6 (): int = let val x = Cons (1, Nil ()) in case+ x of | ~Cons (n, xs) => (free xs; n) end
fun k7 (): int = let val x = Cons (1, Nil ()) in case+ x of | @Cons (n, xs) => (fold@ x; free x; n) end
fun k8 (): int = let val x = Nil () in case+ x of | ~Nil () => 0 end
fun k9 (): int = let val x = Nil () in case+ x of | @Nil () => 0 end
fun k10 (): int = let val x = Nil () in case+ x of | Nil () => 0 end
fun k11 (): int = let val x = Pair (DVT 1, DVT 2) in case+ x of | ~Pair (a, b) => (free a; free b; 0) end
fun k12 (): int = let val x = Red () in case+ x of | ~Red () => 0 | _ => 1 end
fun k13 (): int = let val x = Red () in case+ x of | @Red () => 0 | _ => 1 end
fun k14 (): int = let val x = Red () in case+ x of | Red () => 0 | _ => 1 end
fun k15 (): int = let val x = Cons (1, Nil ()) in case+ x of | @Cons (n, xs) => (fold@ x; case+ x of | ~Cons (a, b) => (free b; a)) end
fun k16 (): int = let val x = DVT 1 val y = x in case+ y of | ~DVT (n) => n end
fun k18 (): int = let val x = @(DVT 1, 2) in case+ x of | @(~DVT (n), m) => n + m end
fun k19 (x: dvt): int = case+ x of | ~DVT (n) => n
fun k20 (x: dvt): int = case+ x of | ~DVT (n) when n > 0 => n | ~DVT (n) => 0
fun k21 (): int = case+ (DVT 1) of | ~DVT (1) => 1 | ~DVT (_) => 2
fun k22 (): int = case+ (Cons (1, Nil ())) of | ~Cons (n, ~Nil ()) => n | ~Cons (_, xs) => (free xs; 0)

(* constructor types written in the source: S2Edatcontyp *)
fun q1 (x: Cons_pstruct (int, node)): int = case+ x of | ~Cons (n, xs) => (free xs; n)
fun q2 (x: Cons_pstruct (int, node)): int = case+ x of | @Cons (n, xs) => (fold@ x; free x; n)
fun q3 (x: Cons_pstruct (int, node)): int = case+ x of | Cons (n, xs) => (free x; n)
fun q4 (x: DVT_pstruct (int)): int = case+ x of | ~DVT (n) => n
fun q5 (x: DVT_pstruct (int)): int = case+ x of | @DVT (n) => (fold@ x; free x; n)
fun q6 (x: DVT_pstruct (int)): int = case+ x of | DVT (n) => (free x; n)
fun q7 (x: Nil_pstruct ()): int = case+ x of | ~Nil () => 0
fun q8 (x: Nil_pstruct ()): int = case+ x of | @Nil () => 0
fun q9 (x: Nil_pstruct ()): int = case+ x of | Nil () => 0
fun q10 (x: Cons_pstruct (int, node)): int = case+ x of | ~Nil () => 0 | ~Cons (n, xs) => (free xs; n)
fun q11 (x: Cons_pstruct (int, node)): int = case+ x of | ~Nil () => 0
fun q12 (x: Pair_pstruct (dvt, dvt)): int = case+ x of | ~Cons (n, xs) => 0
fun q13 (x: Red_pstruct ()): int = case+ x of | ~Red () => 0
fun q14 (x: Red_pstruct ()): int = case+ x of | @Red () => 0
fun q15 (x: Red_pstruct ()): int = case+ x of | Red () => 0
fun q16 (x: Red_pstruct ()): int = case+ x of | Green () => 0
fun q17 (x: color): int = case+ x of | Red () => 0 | Green () => 1 | Blue () => 2
