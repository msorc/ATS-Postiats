datasort s1 = SA | SB | SC
dataprop pr1 (s1) = P1A (SA) | P1B (SB) | P1C (SC)
fun c1 {n:nat} (x: int n): int = sif n > 0 then 1 else 0
fun c2 (x: int): int = ifcase | x > 0 => 1 | x < 0 => ~1 | _ => 0
fun c3 {s:s1} (pf: pr1 s): int = scase s of SA () => 1 | SB () => 2 | SC () => 3
fun c4 {s:s1} (pf: pr1 s): int = scase s of SA () => 1 | SB () => 2
fun c5 {s:s1} (pf: pr1 s): int = scase s of SA () => 1 | SA () => 2 | SB () => 3 | SC () => 4
fun c7 (x: int): int = let
  var i: int = 0
  val () = while (i < x) i := i + 1
  val () = for (i := 0; i < x; i := i + 1) ()
in i end
fun c8 (x: int): int = try x / 0 with | ~DivisionByZeroExn () => 0 | ~_ => 1
fun c9 (x: int): int = try x with ~MyE () => 1
exception MyE
fun c10 (x: int): int = (
  if x > 0 then let val () = () in 1 end else 2
)
fun c13 (x: int): int = case+ x of | 0 when true => 1 | 1 when false => 2 | _ => 3
fun c14 (x: int, y: int): int = case+ (x, y) of (0, 0) => 0 | (_, _) when x > y => 1 | (_, _) => 2
fun c15 (x: int): int = case+ x of 0 => 0 | n =>> n
fun c16 (x: int): int = (case+ x of 0 => 0 | _ => 1) + 1
fun c17 (x: int): int = if x > 0 then 1 else if x < 0 then ~1 else 0
fun c18 {n:nat} (x: int n): [m:nat] int m = sif n > 0 then x else 0
fun c19 (x: int): int = let in x end
fun c20 (x: int): int = let val x1 = x in let val x2 = x1 in x2 end end
fun c21 (x: int): int = x where { val y = x where { val z = x } }
fun c22 (x: !int): int = !x
fun c23 (x: &int): int = x
fun c24 (p: ptr, x: int): int = $UNSAFE.ptr0_get<int> (p) + x
fun c25 (x: int): int = begin x end
fun c26 (x: int): int = (x; x)
