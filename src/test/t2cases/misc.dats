tkindef k1 = "atstype_k1"
classdec cls1
classdec cls2 : cls1
classdec cls3 : nosuch
dynload "./staload_inc.hats"
#dynload "./nosuch.dats"
#include "./staload_inc.hats"
#include "./nosuch.hats"
#define X 1
#define Y(x) x + 1
#undef X
#if (1 > 0) #then
val ifx = 1
#else
val ifx = 2
#endif
#ifdef Y
val ify = 1
#endif
#print "x"
#assert (1 > 0)
extern fun misc1 (): void
stacst sa1: int
stadef sa2 = sa1
fun misc2 {n:nat} (x: int n): int n = x
val m3 = misc2 {1} (1)
val m4 = misc2 {1,2} (1)
val m5 = misc2 {} (1)
val m6 = misc2 {..} (1)
val m7 = misc2 {...} (1)
dataprop mp (int) = MP0 (0)
extern praxi m9 (): mp (0)
prval m10 = m9 ()
prval m11 = m9 () : mp (0)
abstype mt
typedef m13 = (mt, mt)
vtypedef m14 = (int, !int)
extern fun misc3 (x: int, y: !int): void
val m15 = $tuple (1)
val m16 = @[int][1] (1)
val m17 = (1, 2).0
val m18 = @(1, 2).1
val m19 = @{ a= 1 }.a
val m20 = @{ a= 1 }.b
exception Ex1 of int
val m21 = try $raise Ex1 (1) with ~Ex1 n => n
val m22 = $raise (Ex1 (1))
val m23 = (Ex1 (1) : exn)
