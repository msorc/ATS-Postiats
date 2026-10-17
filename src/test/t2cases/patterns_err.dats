// pattern errors
datatype d1 = A1 of int | B1 of (int, bool) | C1
fun g1 (x: d1): int = case+ x of nosuch () => 0 | _ => 1
fun g2 (x: d1): int = case+ x of A1 (a, b) => a | _ => 1
fun g3 (x: d1): int = case+ x of A1 () => 0 | _ => 1
fun g4 (x: d1): int = case+ x of B1 (a) => a | _ => 1
fun g5 (x: int): int = case+ x of (a, a) => a
fun g6 (x: int): int = case+ x of vbox (a, b) => 1
fun g7 (x: d1): int = case+ x of ~A1 n => n | _ => 0
fun g8 (x: d1): int = case+ x of @A1 n => n | _ => 0
fun g9 (x: int): int = case+ x of nosuch => 1
fun g10 (x: int): int = case+ x of 1 (2) => 1 | _ => 0
fun g11 (x: d1): int = case+ x of A1 {n} (a) => a | _ => 0
fun g12 (x: d1): int = case+ x of A1 {a, b} (a) => a | _ => 0
fun g13 (x: int): int = let val [n:nosuch] y = x in y end
fun g14 (x: int): int = let val (y: nosuch) = x in y end
fun g15 (x: int): int = let val @{ a= u, a= v } = x in u end
fun g16 (x: d1): int = case+ x of A1 _ _ => 0 | _ => 1
