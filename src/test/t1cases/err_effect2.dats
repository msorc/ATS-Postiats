fun f (x: int):<!ntm,exn,ref,wrt> int = x
fun f2 (x: int):<fun1,!exnref> int = x
fun f3 (x: int):<cloref,nil> int = x
fun f4 (x: int):<1,~ntm> int = x
fun f5 (x: int):<> int = x
fun f6 (x: int):<!laz> int = x
fun f7 (x: int):<lin,prf> int = x
fun f8 (x: int):<cloptr1,!exnrefwrt,!refwrt,!exnwrt> int = x
fun f9 (x: int):<clo> int = x
fun f10 (x: int):<cloref> int = x
fun f11 (x: int):<clo1> int = x
fun f12 (x: int): int -<cloptr1> int = x
fun f13 (x: int): int -<lincloptr1> int = x
fun f14 (x: int): int -<clo1,!wrt> int = x
fun f15 {n:nat} .<n>. (x: int n): int = x
fun f16 {n:nat} (x: int n): int = if n > 0 then f16 (n-1) else 0
fun f17 (x: int):<!ntm> int = x
fnx f18 (x: int) = f19 x and f19 (x: int) = f18 x
