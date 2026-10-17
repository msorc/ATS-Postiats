// sort errors
sortdef bad1 = nosuchsort
sortdef bad2 = (int, int) -> nosuch
stadef bad3 = nosuchstatic
stadef bad4 (a: nosuch) = a
stadef bad5 = int (1, 2)
stadef bad6 = 1 + true
stadef bad7: int = true
stacst c1: nosuch
stacst c2: int
stadef bad8 = c2 (1)
stadef bad9 (a:int): int = a (1)
typedef t1 = nosuch
typedef t2 = list (int, int, int)
typedef t3 = int -<foo> int
typedef t4 (a:int) = a
typedef t5 (a:int) = int (a, a)
typedef t6 = @{ x= 1 }
typedef t7 = [n:int] n
fun g1 (x: nosuch): int
fun g2 {n:nosuch} (x: int n): int
fun g3 {n:nat | n} (x: int n): int
fun g4 (x: int (true)): int
fun g5 (x: int, y: int): int (x)
fun g6 (x: int): int (1, 2)
datasort c3 = A of (c3, c3) | B
stadef x1 = A
stadef x2 = (B)
