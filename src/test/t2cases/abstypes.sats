abstype t0
abstype t1 (int)
abstype t2 (a:t@ype, n:int) = ptr
abstype t3 = int
abst@ype u0 (n:int)
abst@ype u1 (a:t@ype) = a
absprop p0
absprop p1 (n:int)
absview v0
absview v1 (a:t@ype, l:addr)
absvtype w0
absvtype w1 (a:vt@ype) = ptr
absvt@ype x0 (a:vt@ype)
absviewtype y0
absviewt@ype y1 (n:int)
typedef tt = (t0, t1 (3), t2 (int, 4))
fun mk0 (): t0
fun mk1 {n:int} (x: int n): t1 (n)
fun use1 (x: !v1 (int, null) >> v1 (int, null)): void
prfun lemma1 {n:nat} (): p1 (n)
praxi ax1 {n:int} (x: p1 n): p1 (n+1)
