fun f {n:nat} (x: int n): int = (fix g (x: int): int =<cloref1> x) x
val a = lam (x: int) => x
val b = fix f (x: int): int => x
val c = lam (x: int): int =<cloptr1> x
fun foo () = $showtype (1)
fun f2 (x: int, y: int) = x
val f = (1 | 2)
val g = @[int][1+2] (0)
val h = 1 : int
val (i, j) = (1, 2) : (int, int)
val k = if 1 then 2
val l = case+ 1 of | x when x > 0 => 1 | _ => 2
val m = (try 1 with | ~E () => 2)
val n = (for (i := 0; i < 3; i := i + 1) ())
val o = (while (true) ())
val p = (let val x = 1 in x end)
