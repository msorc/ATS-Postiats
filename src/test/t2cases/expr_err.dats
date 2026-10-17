// dynamic expression errors
val e1 = nosuch
val e2 = nosuch (1, 2)
val e4 = lam (x: nosuch): int => x
val e5 = case+ 1 of nosuch () => 1
val e7 = 1 2
val e8 = x where { val x = nosuch2 }
val e10 = @[nosuch][1] (1)
val e11 = $extval (nosuch, "x")
fun e12 (x: int): int = e12a (x)
val e13 = lam (x) => x
val e14 = (lam (x: int): int => x) (1, 2)
val e15 = @{ x= 1, x= 2 }
val e16 = ,(1)
val e17 = %(1)
val e18 = `(1)
val e19 = 1 :: 2
val e21 = f<int> (1)
val e22 = $tyrep (nosuch)
val e26 = 1 :=: 2
val e28 = (1).x
val e29 = (1)->x
extern fun e30fun {a:t@ype} (x: a): a
typedef e30 = $d2ctype (e30fun<int>)
typedef e30b = $d2ctype (e30fun)
typedef e30c = $d2ctype (e30fun<int,int>)
fun e31 {n:nat} (x: int n): int = e31 {nosuch} (x)
fun e32 (x: int): int = e32 {1, 2} (x)
fun e33 (x: int): int = e33 (1, 2, 3)
val e34 = foldat (1)
val e35 = freeat (1)
val e36 = 1 where { val x = 1 and y = x }
