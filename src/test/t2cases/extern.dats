extern fun e1 (x: int): int = "mac#e1"
extern fun e2 (x: int): int = "ext#e2"
extern fun e3 (x: int): int = "sta#e3"
extern fun e4 (x: int): int = "e4"
extern fun e5 (x: int): int
extern val e6: int = "mac#e6"
extern val e7: int
extern castfn e8 (x: int): bool
extern praxi e9 {n:nat} (): int n
extern prfun e10 {n:nat} (x: int n): int n
extern prval e11: int
extern fun e12 (x: int): int = "mac#%"
extern fun e13 (): void = "ext#%"
extern fun{a:t@ype} e14 (x: a): a
extern fun e15 {a:t@ype} (x: a): a = "mac#e15"
extern fun e18 (x: int): int
implement e18 (x) = x
implement e12 (x) = x
extern fun e19 (x: int): int
and e20 (x: int): int
extern fun e21 (x: int): int = "mac#"
extern fun e22 (x: int): int = ""
%{^
#include <stdio.h>
%}
%{$
int e1 (int x) { return x ; }
%}
extern fun e24 (x: int): int
implement e24 (x) = e18 (x) + e12 (x)
implement e5 (x) = x
val e25 = e1 (1)
