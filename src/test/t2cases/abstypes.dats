abstype t0
assume t0 = int
abstype t1 (n:int) = ptr
assume t1 (n:int) = int (n)
absvtype w0
assume w0 = ptr
absprop p0
reassume t0
abstype t9
extern fun mk (): t9
assume t9 = [n:nat] int n
absprop p9 (n:int)
assume p9 (n:int) = [m:nat | m == n] unit_p
abstype bad1
assume bad2 = int
assume bad1 = int
assume bad1 = int
reassume nosuch
reassume bool
local
abstype loc1
in
assume loc1 = int
fun mkloc (): loc1 = $UNSAFE.cast (0)
end
