// sortdef, stadef, stacst, datasort, sorts of every form
sortdef nat1 = {a: int | a >= 1}
sortdef two = {a: int | a >= 0 && a <= 1}
sortdef ntype = (int, int) -> type
sortdef myprop = prop
datasort color = Red | Green | Blue
datasort tree = Leaf | Node of (tree, int, tree)
stacst sz: int
stacst mk: (int, int) -> int
stacst pred1: int -> bool
stadef zero = 0
stadef plus (a:int, b:int): int = a + b
stadef twice (a:int) = plus (a, a)
stadef max2 (a:int, b:int): int = a
stadef isc (c: color): bool = (c == Red)
stadef mylst = lst (int)
stadef p1 = (int, bool)
stadef ff = (int, int) -> int
stadef ty (a:t@ype): t@ype = a
typedef myint = int
typedef myint2 (n:int) = int (n)
typedef mypair (a:t@ype, b:t@ype) = @(a, b)
typedef myrec = @{ x= int, y= bool }
typedef myfun = (int, int) -> int
typedef myfun2 = int -<cloref1> int
typedef myfun3 = int -<lin,prf> void
vtypedef myvt = [n:nat] list_vt (int, n)
propdef myp (n:int) = [m:nat] (int m)
viewdef myv (l:addr) = int @ l
viewtypedef mypair2 = @(int, int)
prfun pf1 {n:nat} (x: int n): int n
fun f1 {n:int | n > 0} (x: int n): int (n+1)
fun f2 {a:t@ype} (x: a): a
fun f3 {n:nat; m:nat | n <= m} (x: int n, y: int m): int (m-n)
fun f4 (x: int): [n:int | n >= 0] int n
fun f5 {a:type} (x: !List0_vt (a) >> List0_vt (a), y: &int >> int): void
fun f6 {a:vt@ype} (x: &(a?) >> a): void
fun f7 (x: &int? >> int): void
fun f8 (x: !int, y: ~int): void
fun f9 (x: int, y: bool, z: char): @(int, bool)
