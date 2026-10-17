extern fun f1 (x: int):<clo> int
extern fun f2 (x: int):<cloptr> int
extern fun f3 (x: int):<!ntm> int
extern fun f4 {n:nat} (x: int n):<!ntm> int
extern fun f5 (x: int):<cloref> int
extern fun f6 (x: int):<1> int
extern praxi p1 (): void
extern prfun p2 (): void
extern castfn c1 (x: int): int
extern val v1 : int
extern prval pv1 : void
extern fn f7 (x: int) : int = "ext#f7"
extern fn f8 (x: int) : int = "mac#f8"
extern fn f9 (x: int) : int = "sta#f9"
extern fn f10 (x: int) : int = "plain"
