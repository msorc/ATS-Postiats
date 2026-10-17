(* patterns: defined constants (int/float/intrep), $lst patterns, existentials, vbox, as-patterns, boxed/flat mismatches, arities, call-by-reference arguments *)
#include "share/atspre_staload.hats"

datavtype dvt = DVT of (int)
fun free_dvt (x: dvt): void = let val+ ~DVT _ = x in end
overload free with free_dvt
#define N 3
#define M 0x10
#define F 1.5
#define BIG 123456789012345678901234567890
#define CH 'c'
#define BT true
#define STR "abc"

fun d1 (x: int): int = case+ x of | N => 1 | M => 2 | _ => 0
fun d2 (x: bool): int = case+ x of | N => 1 | _ => 0
fun d3 (x: char): int = case+ x of | N => 1 | _ => 0
fun d4 (x: double): int = case+ x of | F => 1 | _ => 0
fun d5 (x: int): int = case+ x of | F => 1 | _ => 0
fun d6 (x: int): int = case+ x of | BIG => 1 | _ => 0
fun d7 (x: bool): int = case+ x of | BIG => 1 | _ => 0
fun d8 (x: char): int = case+ x of | CH => 1 | _ => 0
fun d9 (x: bool): int = case+ x of | BT => 1 | _ => 0
fun d10 (x: string): int = case+ x of | STR => 1 | _ => 0
fun d11 (x: int): int = case+ x of | STR => 1 | _ => 0
fun d12 {n:int} (x: int n): int = case+ x of | N => 1 | _ => 0
fun d13 {n:int} (x: g1int(intknd, n)): int = case+ x of | N => 1 | _ => 0
fun d14 (x: uint): int = case+ x of | N => 1 | _ => 0
fun d15 (x: [n:nat] int n): int = case+ x of | N => 1 | _ => 0
fun d16 (x: lint): int = case+ x of | N => 1 | _ => 0
fun d17 (x: double): int = case+ x of | N => 1 | _ => 0
fun d18 (x: float): int = case+ x of | F => 1 | _ => 0
fun d19 (x: uint): int = case+ x of | BIG => 1 | _ => 0
fun d20 (x: int): int = case+ x of | 12345678901234567890 => 1 | 0xff => 2 | 0377 => 3 | 1u => 4 | 2L => 5 | _ => 0
fun d21 (x: uint): int = case+ x of | 12345678901234567890u => 1 | 0xffu => 2 | 1 => 3 | _ => 0
fun d22 (x: ulint): int = case+ x of | 1ul => 1 | 1u => 4 | 1L => 5 | _ => 0
fun d23 (x: [n:int] int n): int = case+ x of | 12345678901234567890 => 1 | _ => 0
fun d25 {n:int} (x: uint n): int = case+ x of | 12345678901234567890u => 1 | _ => 0

(* list patterns *)
fun l1 (x: list_vt(int, 2)): int = case+ x of | $lst(a, b) => a + b
fun l3 (x: list_vt(int, 2)): int = case+ x of | ~list_vt_cons (a, ~list_vt_cons (b, ~list_vt_nil ())) => a + b
fun l4 (x: int): int = case+ x of | $lst(a) => a | _ => 0
fun l5 (x: list_vt(int, 2)): int = case+ x of | $lst(a) => a | _ => 0
fun l6 (x: list_vt(int, 2)): int = case+ x of | $lst(a, b, c) => a | _ => 0
fun l7 (x: list_vt(int, 2)): int = case+ x of | $lst(a, b) => a + b
fun l8 (x: list_vt(int, 2)): int = case+ x of | $lst_vt(a, b) => a + b
fun l9 (x: list_vt(int, 2)): int = case+ x of | $lst_vt(a, b) => a + b
fun l10 (x: list_vt(int, 2)): int = case+ x of | $lst(a, b) => a + b
fun l11 (x: list_vt(int, 2)): int = case+ x of | $lst_t(a, b) => a + b
fun l12 (x: list_vt(int, 2)): int = case+ x of | $lst_t(a, b) => a + b
fun l13 (x: list_vt(bool, 2)): int = case+ x of | $lst(a, 1) => 1 | _ => 0
fun l14 (x: [n:nat] list_vt(int, n)): int = case+ x of | $lst(a, b) => a + b | _ => 0

(* existential patterns *)
extern fun g1 (): [n:nat] int n
extern fun g2 (): [n:nat] (int n, int n)
extern fun g3 (): [n:int] [k:int] (int n, int k)
extern fun g4 (): [n:nat] @{ f= int n, g= int n }
extern fun g5 (): [a:t@ype] (a, a)
extern fun g6 (): [l:addr] (int @ l | ptr l)
extern fun g7 (): [n:int | n > 0] int n
extern fun g8 (): [n,m:int] (int n, int m)
extern fun g9 (): [l:addr] (int @ l | ptr l)
fun e1 (): int = let val [m:int] y = g1 () in y end
fun e2 (): int = let val [m:int, k:int] y = g1 () in y end
fun e3 (): int = let val [m:int] y = 3 in y end
fun e4 (): int = let val [m:bool] y = g1 () in 0 end
fun e5 (): int = let val [m:int] y = g7 () in y end
fun e6 (): int = let val [m:int] [j:int] @(a, b) = g3 () in a + b end
fun e7 (): int = let val [m:int] @(a, b) = g2 () in a + b end
fun e8 (): int = let val [m:int] @{ f= a, g= b } = g4 () in a + b end
fun e9 (): int = let val [m:t@ype] @(a, b) = g5 () in 1 end
fun e10 (): int = let val [m:addr] (pf | p) = g6 () in !p end
fun e11 (): int = let val [m:int] (y: int m) = g1 () in y end
fun e12 (): int = let val [m:int] (y: int(m+1)) = g1 () in 0 end
fun e13 (): int = let val [m:int, k:int] @(a, b) = g8 () in a + b end
fun e15 (): int = let val [m:int, k:int, j:int] @(a, b) = g8 () in a + b end
fun e16 (): int = let val [m:int, k:int] @(a, b) = g2 () in a + b end
fun e17 (): int = let val [m:bool, k:int] @(a, b) = g8 () in a + b end
fun e18 (): int = let val [m:int, k:bool] @(a, b) = g8 () in a + b end
fun e19 (): int = case+ g1 () of | [m:int] 0 => 1 | _ => 0
fun e20 (): int = let val [m:int] [j:int] y = g1 () in y end
fun e21 (): int = let val [m:int] [j:int] (pf | p) = g9 () in 0 end
fun e22 (): int = let val [m:addr] @(pf | p) = g6 () in 0 end

(* vbox *)
fun v1 {l:addr} (pf: vbox(int @ l) | p: ptr l): int = let prval vbox pf1 = pf in 0 end
fun v2 {l:addr} (pf: vbox(int @ l) | p: ptr l): int = let prval vbox (pf1) = pf in !p end
fun v3 {l:addr} (pf: int @ l | p: ptr l): int = let prval vbox pf1 = pf in 0 end
fun v4 {l:addr} (pf: vbox(int @ l) | p: ptr l): int = let prval vbox (pf1) = pf in !p end
fun v5 {l:addr} (pf: vbox(dvt @ l) | p: ptr l): int = let prval vbox (pf1) = pf in 0 end
fun v6 (x: int): int = let prval vbox (pf1) = x in 0 end
fun v7 {l:addr} (pf: vbox(int @ l) | p: ptr l): int = let val vbox pf1 = pf in 0 end

(* as-patterns and annotations *)
fun s1 (x: @(int, int)): int = case+ x of | y as @(a, b) => a + b
fun s2 (x: dvt): int = case+ x of | y as @DVT (a) => (fold@ y; free@ y; a)
fun s3 (x: dvt): void = case+ x of | y as DVT (a) => free@ y
fun s4 (x: dvt): int = case+ x of | y as ~DVT (a) => a
fun s6 (x: !dvt): int = case+ x of | y as @DVT (a) => (fold@ y; a)
fun s7 (x: !dvt): int = case+ x of | y as DVT (a) => a
fun s8 (x: int): int = case+ x of | y as 0 => y | y as _ => y
fun s9 (x: int): int = case+ x of | y as z as 0 => y | _ => 1
fun s10 (x: !dvt): int = let val y as DVT (a) = x in a end
fun s11 (x: !dvt): void = let val y as @DVT (a) = x in fold@ y end
fun s12 (x: @(dvt, int)): void = let val y as @(@DVT (a), b) = x in fold@ (x.0) end
fun s13 (x: !(dvt, int)): void = let val y as @(@DVT (a), b) = x in fold@ (x.0) end

(* boxed / flat tuples and records *)
fun t1 (x: '(int, int)): int = case+ x of | '(a, b) => a + b
fun t2 (x: '(int, int)): int = case+ x of | @(a, b) => a + b
fun t3 (x: @(int, int)): int = case+ x of | '(a, b) => a + b
fun t4 (x: '{ a= int, b= int }): int = case+ x of | '{ a= a, b= b } => a + b
fun t5 (x: '{ a= int, b= int }): int = case+ x of | @{ a= a, b= b } => a + b
fun t6 (x: @{ a= int, b= int }): int = case+ x of | '{ a= a, b= b } => a + b
fun t8 {l:addr} (x: '(int @ l | int)): int = case+ x of | '(pf | a) => a
fun t10 {l:addr} (x: '(int @ l | int)): int = case+ x of | '(pf, pf2 | a) => a
fun t11 {l:addr} (x: '(int @ l | int)): int = case+ x of | '(a) => a
fun t7 (x: '(int, int)): int = case+ x of | '(a, b, c) => a
fun t13 {l:addr} (x: @(int @ l | int)): int = case+ x of | @(pf | a) => a
fun t14 (x: '(int | int)): int = case+ x of | '(pf | a) => a
fun t15 {l:addr} (x: @(int @ l, int @ l | int)): int = case+ x of | @(pf1 | a) => a
fun t16 {l:addr} (x: @(int @ l | int)): int = case+ x of | @(pf1, pf2 | a) => a
fun t17 (x: @(int | int, int)): int = case+ x of | @(pf | a) => a
fun t18 (x: $tup(int, int)): int = case+ x of | $tup(a, b) => a + b
fun t19 (x: $rec{a=int, b=int}): int = case+ x of | $rec{a=a, b=b} => a + b
fun t20 (x: '(int, int)): int = case+ x of | $tup(a, b) => a + b
fun t21 (x: @(int, int)): int = case+ x of | $tup(a, b) => a + b
fun t22 (x: @{a=int, b=int}): int = case+ x of | $rec{a=a, b=b} => a + b
fun t23 (x: '{a=int, b=int}): int = case+ x of | $rec{a=a, b=b} => a + b
fun t24 (x: @{a=int, b=int}): int = case+ x of | @{a=a, ...} => a
fun t25 (x: @{a=int, b=int}): int = case+ x of | @{b=b, a=a} => a
fun t26 (x: @{a=int, b=dvt}): int = case+ x of | @{a=a, ...} => a
fun t27 (x: @{a=int, b=int}): int = case+ x of | @{a=a, b=b, ...} => a
fun t28 (x: @{a=int, b=int}): int = case+ x of | @{a=a, ..., b=b} => a
fun t29 (x: @{a=int, b=int}): int = case+ x of | @{ b=b, c=c, ...} => b
fun t30 (x: @{a=dvt, b=dvt}): void = case+ x of | @{ a=a, b=b } => (free a; free b)
fun t31 (x: @{a=dvt, b=dvt}): void = case+ x of | @{ a=a, b=_ } => free a
fun t32 (x: @(dvt, dvt)): void = case+ x of | @(a, _) => free a
fun t33 (x: '(dvt, int)): void = case+ x of | '(a, _) => ()
fun t34 (x: @{ a= int, b= int }): int = case+ x of | @{ a= a, a= b } => a

(* call-by-reference arguments *)
fun r1 (x: &int >> int): void = ()
fun r2 (@(a, b): &(@(int, int)) >> @(int, int)): void = ()
fun r6 (@(a, b): &(@(int, int))): void = ()
fun r8 (x: &int, @(a, b): &(@(int, int))): void = ()
fun r4 (_: &int >> int): void = ()
fun r5 (x: int, y: &(int?) >> int): void = y := x
fun r7 (1: &int): void = ()
fun r9 {l:addr} (pf: !int @ l >> int @ l | p: ptr l): void = ()
fun r13 ((x: int): &int): void = ()

(* arities of argument lists *)
fun a1 (x: int, y: int): int = x + y
fun a2 {l:addr} (pf: int @ l | x: int): int = x
fun a3 {l:addr} (pf: int @ l, pf2: int @ l | x: int): int = x
fun a4 (pf: int | x: int): int = x
fun a5 {l:addr} (pf: !int @ l | ): void = ()
fun a6 {l:addr} (pf: !int @ l | x: int, y: int): void = ()
extern fun a1 (x: int): int
extern fun a8 (x: int): int
extern fun a9 (x: int): int
implement a1 (x) = x
