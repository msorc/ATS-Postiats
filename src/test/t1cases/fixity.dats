(* fixity declarations in dynamic code *)
infixl 60 +++
infixr 70 ***
infix 50 ===
prefix 80 !!!
postfix 90 ???
infixl (+) +++-
nonfix foo
fun f (x: int, y: int): int = x
val a = 1 +++ 2 *** 3 === 4
val b = !!! 1 +++ 2 ???
val c = 1 \f 2 + 3
val d = (1 +++ 2) \f 3
val e = f (1, 2) +++ f (3, 4)
val g = ~1 + 2 * 3 - 4 / 5 mod 6
val h = 1 :: 2 :: nil
val i = a < b andalso b <= c orelse not d
val j = x.lab ->lab k
fun k (_: int, _: int): int = 0
overload +++ with k
val (p1 +++ p2) = (1, 2)
val x1 = 1 \k 2
local
  infixl 10 ##
  fun l (x: int, y: int) = x
in
  val m = 1 ## 2
end
val n = 1 ## 2
