// patterns
datatype d1 = A1 of int | B1 of (int, bool) | C1
datavtype v1 (a:vt@ype) = VN | VC of (a, v1 a)
dataprop p1 (int) = P1a (0) | {n:nat} P1b (n+1) of p1 n
fun f1 (x: d1): int = case+ x of
  | A1 n => n
  | B1 (n, true) => n
  | B1 (n, _) when n > 0 => ~n
  | C1 () => 0
  | _ => 1
fun f2 (x: (int, bool)): int = let val (a, b) = x in a end
fun f3 (x: @(int, bool)): int = let val @(a, b) = x in a end
fun f4 (x: @{ a= int, b= bool }): int = let val @{ a= u, b= _ } = x in u end
fun f5 (x: @{ a= int, b= bool }): int = let val @{ a= u, ... } = x in u end
fun f6 (x: list_vt (int, 2)): int = case+ x of ~list_vt_cons (a, ~list_vt_cons (b, ~list_vt_nil ())) => a + b
fun f7 (x: !list_vt (int, 2)): int = case+ x of list_vt_cons (a, list_vt_cons (b, _)) => a + b
fun f8 (x: int): int = case+ x of 0 => 1 | 1 => 2 | n => n
fun f9 (x: char): int = case+ x of 'a' => 1 | 'b' => 2 | _ => 3
fun f10 (x: string): int = case+ x of "a" => 1 | _ => 2
fun f11 (x: bool): int = case+ x of true => 1 | false => 2
fun f12 (x: double): int = case+ x of 1.0 => 1 | _ => 2
fun f13 {n:nat} (x: list_vt (int, n)): int = case+ x of
  | @list_vt_cons (a, xs) => let val n = a in fold@ x; n end
  | ~list_vt_nil () => 0
fun f14 (x: int): int = let val y as 1 = x in y end
fun f15 (x: int): int = let val (y: int) = x in y end
fun f16 (x: list_vt (int, 1)): int = let
  val ~list_vt_cons (a, xs) = x
  val () = list_vt_free xs
in a end
fun f17 (x: [n:nat] int n): int = let val [m:nat] y = x in y end
fun f18 (x: (int, int) -> int): int = x (1, 2)
fun f19 (x: (int, int)): int = case+ x of (0, _) => 0 | (_, 0) => 1 | (a, b) => a + b
fun f20 (x: !vbox (p1 0)): void = let prval vbox pf = x in () end
fun f21 (x: int) = case+ x of (1) => 1 | (n) => n
fun f22 (x: ()): int = case+ x of () => 0
fun f23 (x: d1): int = case+ x of | A1 _ => 1 | B1 _ => 2 | C1 _ => 3
fun f24 (x: d1): int = case+ x of | A1 (_) => 1 | B1 (_, _) => 2 | C1 () => 3
fun f25 (x: d1): int = case- x of A1 n => n
fun f26 (x: int): int = case+ x of | ~1 => 0 | n => n
fun f27 (x: int): int = let val 1 = x in 0 end
fun f29 {n:nat} (x: list_vt (int, n)): void = case+ x of
  | ~list_vt_nil () => ()
  | ~list_vt_cons (_, xs) => f29 (xs)
fun f30 (x: int): int = case+ x of x1 when x1 > 0 => x1 | x2 when x2 < 0 => ~x2 | _ => 0
