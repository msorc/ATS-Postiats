extern fun{a:t@ype} t1 (x: a): a
implement {a} t1 (x) = x
extern fun{a,b:t@ype} t2 (x: a, y: b): @(a, b)
implement {a,b} t2 (x, y) = @(x, y)
extern fun{a:t@ype} t3 {n:nat} (x: int n): int n
implement {a} t3 {n} (x) = x
extern fun{a:t@ype} {b:t@ype} t4 (x: a, y: b): a
implement {a} {b} t4 (x, y) = x
extern fun{a:t@ype} t5 (x: a): a
implement t5<int> (x) = x + 1
implement t5<bool> (x) = not x
implement {a} t5 (x) = x
val x1 = t1<int> (1)
val x2 = t2<int,bool> (1, true)
val x3 = t3<int> {3} (3)
val x4 = t4<int><bool> (1, true)
val x5 = t5<int> (1)
val x6 = t1 (2)
val x7 = t1<> (3)
val x8 = t5<char> ('c')
fun{a:t@ype} t6 (x: a): a = t1<a> (x)
fun t7 (): int = t6<int> (1) + t6 (2)
implement(a) t8 (x: a): a = x
extern fun{a:t@ype} t9 (x: a): a
implement t9<int> (x) = t9<int> (x)
extern fun{a:vt@ype} t10 (x: &a >> a): void
implement {a} t10 (x) = ()
extern fun{a:t@ype} t11 (): int
implement {a} t11 () = 0
val e1 = t1<nosuch> (1)
val e2 = t2<int> (1, true)
val e3 = t1<int,int> (1)
val e4 = nosuchtmp<int> (1)
implement t1<int> (x, y) = x
implement nosuch<int> (x) = x
implement t5<int,int> (x) = x
implement {a} t5 (x, y) = x
implement t3<int> {a, b} (x) = x
implement {a} t3 {n, m} (x) = x
extern fun t12 (x: int): int
implement t12<int> (x) = x
fun t13 (x: int): int = x
implement t13 (x) = x + 1
implement t13 (x) = x + 2
extern val v14: int
implement v14 = 1
implement v14 = 2
extern fun t15 {n:nat} (x: int n): int n
implement t15 (x) = x
implement t15 {m} (x) = x
implement t15 {m,k} (x) = x
