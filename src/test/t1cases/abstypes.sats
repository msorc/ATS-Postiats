(* abstract types, sorts, static constants *)
sortdef nat = {a: int | a >= 0}
sortdef two = (int, bool)
datasort tree = Leaf of () | Node of (tree, int, tree)
datasort color = Red | Green | Blue
stacst foo: (int, int) -> bool
stacst fooo: int
stadef bar = foo
stadef baz (x:int, y:int) = x + y
stadef baz2 (x:int, y:int): int = x + y
stadef lam1 = lam (x: int) => x + 1
stadef lam2 = lam (x: int, y: int): int => x + y
abstype t0 = ptr
abstype t1 (n: int) = ptr
abst@ype t2 (a: t@ype) = int
absvtype t3 (a: vt@ype) = ptr
absview t4 (l: addr)
absprop t5 (n: int)
absvt@ype t6 (a: t@ype) = $extype"x"
typedef t10 = [n:nat] (t1 n, int n)
typedef t11 (a: t@ype) = @(a, a)
vtypedef t12 (a: vt@ype) = (a, a)
propdef p1 (n: int) = t5 n
viewdef v1 (l: addr) = t4 l
viewtypedef vt1 (a:vt@ype) = a
tkindef mykind = "mykind"
typedef t13 = int(int) -<fun,prf> int
typedef t14 = (int -<cloref1> int, int -<cloptr,exn> int, int -<lin,prf> int, !ref int)
typedef t15 = {a: int | a > 0} [b: int | b > 0] @{x= int(a), y= int(b)}
typedef t16 = &int >> int
typedef t17 = &(int?) >> int
typedef t18 = (&int, &int? >> int, !int, int?, int?!, &!int)
typedef t19 = int?!
typedef t20 = a0 \t11 b0
typedef t21 = @[int][3]
typedef t22 = [n:nat] @[int][n]
assume t0 = int
reassume t0
stadef x = ~1
stadef y = 'a'
stadef z = "str"
stadef w = 0x1F
stadef w2 = 1.5
