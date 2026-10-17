(* taggen cases: every declaration *)
infixl 40 +++
infixr 30 +++ ***
prefix 50 ~~~
postfix 60 !!!
nonfix mynf
symintr sym1 sym2
symelim sym3
overload sym1 with f1
overload + with f2 of 10
#define N 10
#define F(x) x
#undef N
#if defined(A) #then
fun ga (x: int): int = x
#else
fun gb (x: int): int = x
#endif
#ifdef B
val vb = 1
#elif defined(C)
val vc = 2
#endif
tkindef mykind = "k"
stadef s1 = int
stadef s2 (a: type): type = a
and s3 = bool
typedef t1 = int
typedef t2 (a: t@ype) = a
and t3 = char
vtypedef vt1 = int
sortdef so = int
datasort srt1 = A | B
stacst sc1: int
extern prfun pf1 (): void
dataprop dp1 (int) = DP1 (0)
datatype dt1 (a: t@ype) = DT1 of a | DT2
and dt2 = DT3
datavtype dvt1 = DV1 of int
dataviewtype dvt2 = DV2
exception MyExn of int
exception MyExn2
abstype ab1
abst@ype ab2
absviewtype ab3
absprop ab4
assume ab1 = int
assume ab2 = int
reassume ab1
extern fun ef1 (x: int): int = "mac#ef1"
extern val ev1 : int = "mac#ev1"
extern castfn ec1 (x: int): int
extern praxi px1 (): void
macdef md1 (x) = x
macrodef md2 (x) = x
fun fa (x: int): int = x
and fb (x: int): int = x
fn fc (x: int): int = x
fnx fd (x: int): int = x
and fe (x: int): int = x
prfn pa (): void = ()
prfun pb (): void = ()
castfn cf1 (x: int): int = x
val v1 = 1
val v2: int = 2
val (v3, v4) = (3, 4)
val (v5: int) = 5
val @(v6, v7) = @(6, 7)
val '{a=v8} = '{a=8}
val v9 = 9 and v10 = 10
val+ v11 = 11
val- v12 = 12
prval pv1 = ()
val ~v13 = 13
val (v15 | v16) = (1 | 2)
val _ = 1
val v17 :int = 17
val opid = op+
var vr1 = 1
var vr2: int = 2
var vr3 with pfv3 = 3
var vr4: int with pfv4 = 4
implement imp1 () = ()
implement imp2<int> (x) = x
implement {a} imp3 (x) = x
implement imp4 (x) = x where { val y = x }
overload fa with fb
local
fun lf1 () = 1
val lv1 = 1
in
fun lf2 () = lf1 ()
end
staload "./mod_a.sats"
staload X = "./mod_b.sats"
dynload "./mod_a.dats"
#include "./inc_a.hats"
%{^
int x ;
%}
%{$
int y ;
%}
%{
int z ;
%}
#assert 1
#print "x"
#error "x"
#require "x"
#staload "./mod_a.sats"
#staload X = "./mod_b.sats"
#define M(x) x
classdec cls1
extype "x" = int
extvar "x" = 1
extern fun {a:t@ype} tf1 (x: a): a
extern fun tf2 {a:t@ype} (x: a): a
fun {a:t@ype} tf3 (x: a): a = x
fun tf4 {n:nat} .<n>. (x: int n): int n = x
fun tf5 (x: int):<cloref1> int = x
fun tf6 (x: int):<!wrt> int = x
val vw = 1 where { val y = 2 }
val vl = let val p = 1 in p end
val v1000 = (fix f (x: int): int => x)
local
val lvv = 1
in
val lvv2 = 2
end
local in end
#ifdef D
local
fun gl () = 1
in
fun gl2 () = gl ()
end
#endif
val op+ = 1
val op- = 2
val $M.pq1 = 3
val ($M.pq3, op*) = (5, 6)
val ((pq4: int): int) = 7
