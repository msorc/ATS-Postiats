(* overloaded symbols: arities, static/dynamic candidates, ties, priorities, dot-symbols applied to arguments, curried results *)
#include "share/atspre_staload.hats"

datavtype dvt = DVT of (int)
fun free_dvt (x: dvt): void = let val+ ~DVT _ = x in end
overload free with free_dvt

fun f1 {n:nat} .<n>. (x: int n): int = 0
fun f2 (x: bool): int = 1
fun f3 (x: char): int = 2
fun f4 (x: int, y: int): int = 3
fun f5 (x: int): (int) -<fun> int = lam y => x + y
fun f6 {a:t@ype} (x: a): int = 5
fun f7 {n:nat} (x: int n): [m:nat] int m = 6
fun f8 (x: double): int = 8
fun f9 (x: int) (y: int): int = x + y
fun f10 {n:nat} .<n>. (x: int n, y: int n): int = 10
fun f11 (x: dvt): int = (free x; 11)
fun f12 (x: !dvt): int = 12
fun f13 (x: string): int = 13
fun f14 (x: ptr): int = 14
fun f15 (pf: unit_v | x: int): int = 15
fun f16 {l:addr} (pf: !int @ l | p: ptr l): int = 16
overload ov with f1
overload ov with f2
overload ov with f3
overload ov with f4
overload ov with f5
overload ov with f8
overload ov with f10
overload ov with f11 of 10
overload ov with f12 of 20
overload ov with f13
overload ov with f14
overload ov with f15
overload ov with f16
overload ov2 with f1
overload ov2 with f6
overload ov3 with f1
overload ov3 with f7
overload ov4 with f1 of 1
overload ov4 with f6 of 2
overload ov5 with f1 of 2
overload ov5 with f6 of 2
overload ov6 with f9
overload ov6 with f4

val a1 = ov 1
val a2 = ov true
val a3 = ov 'c'
val a4 = ov (1, 2)
val a5 = ov 1 2
val a6 = ov 1.5
val a7 = ov "abc"
val a8 = ov ()
val a9 = ov (1, 2, 3)
val a10 = ov (ov 1)
val a11 = ov (1, ov 2)
val a12 = ov (ov 1, ov true)
fun a13 (x: dvt): int = ov x
fun a14 (x: !dvt): int = ov x
fun a15 (x: dvt): int = (ov x; ov x)
fun a16 (x: dvt): int = (ov x) + (ov x)
val a17 = ov2 1
val a18 = ov2 true
val a19 = ov3 1
val a20 = ov4 1
val a21 = ov4 true
val a22 = ov5 1
val a23 = ov6 (1, 2)
val a24 = ov6 1 2
val a25 = ov6 1
fun a27 {n:nat} (x: int n): int = ov x
fun a28 {n:nat} (x: int n, y: int n): int = ov (x, y)
fun a29 {n,m:nat} (x: int n, y: int m): int = ov (x, y)
fun a30 (x: [n:nat] int n): int = ov x
val a31 = ov (ov 1) 2
val a32 = ov (1) (2)
fun a33 {l:addr} (pf: !int @ l | p: ptr l): int = ov (pf | p)
fun a34 (pf: unit_v | x: int): int = ov (pf | x)
fun a35 {l:addr} (pf: int @ l | p: ptr l): int = ov (pf | p)
val a36 = ov (unit_v () | 1)
val a37 = ov{1} 1
val a38 = ov<int> 1
val a39 = ov (lam (x: int) => x)
fun a40 (x: int): int = ov (x := 1)
fun a41 (x: int): int = ov (x, x, x, x)

(* dot-symbols *)
fun getx (p: ptr): int = 0
fun getx2 (p: ptr, k: int): int = 1
fun getx3 (p: ptr, k: int, l: int): int = 2
fun getx4 (p: dvt, k: int): int = 3
fun getx5 (p: !dvt): int = 4
fun setx (p: ptr, k: int): void = ()
overload .x with getx
overload .x with getx2
overload .x with getx3
overload .x with getx4
overload .x with getx5
overload .x with setx
fun b1 (p: ptr): int = p.x
fun b2 (p: ptr): int = p.x ()
fun b3 (p: ptr): int = p.x (1)
fun b4 (p: ptr): int = p.x (1, 2)
fun b5 (p: ptr): int = p.x (1, 2, 3)
fun b6 (p: ptr): void = p.x := 3
fun b7 (p: ptr): int = p.y
fun b8 (p: ptr): int = p.y (1)
fun b9 (p: dvt): int = p.x (1)
fun b10 (p: !dvt): int = p.x
fun b11 (p: !dvt): int = p.x (1)
fun b12 (p: int): int = p.x
fun b13 (p: ptr): int = (p.x) + (p.x (1))
fun b14 (p: @(ptr, ptr)): int = p.0.x (p.1.x)
fun b15 (p: ptr): int = p.x (p.x)
fun b16 (p: ptr): int = p.x (true)
fun b17 {n:nat} (p: ptr, k: int n): int = p.x (k)
fun b18 (p: ptr): int = (1+2).x
fun b19 (p: ptr): int = p.x{1}
fun b20 (p: ptr): int = p.x{1} (1)

(* operators *)
fun addp (x: ptr, y: ptr): ptr = x
fun addb (x: bool, y: bool): bool = x
fun addd (x: dvt, y: dvt): dvt = (free y; x)
overload + with addp
overload + with addb
overload + with addd
overload - with addp of 10
val c1 = 1 + 2
val c2 = true + false
fun c3 (x: ptr, y: ptr): ptr = x + y
fun c4 (x: dvt, y: dvt): dvt = x + y
val c5 = 1 + true
val c6 = "a" + "b"
val c7 = 1.5 + 2.5
fun c8 (x: ptr, y: ptr): ptr = x - y
fun c9 (x: int, y: int): int = x - y
fun c14 (x: int, y: int): bool = x < y
fun c15 (x: int, y: bool): bool = x < y
fun c16 (x: ptr, y: ptr): bool = x < y
fun c17 (x: ptr, y: ptr): bool = x = y
fun c18 (x: dvt, y: dvt): bool = x = y
fun c19 (x: int, y: int): bool = x != y
fun c20 (x: int): int = x + x + x
fun c21 (x: ptr): ptr = x + x + x
fun c22 (x: int, y: ptr): ptr = x + y

(* dot-symbols with proof arguments *)
fun getx6 {l:addr} (pf: !int @ l | p: ptr l, k: int): int = 6
fun getx7 {l:addr} (pf: !int @ l | p: ptr l): int = 7
overload .y with getx6
overload .y with getx7
fun d1 {l:addr} (pf: !int @ l | p: ptr l): int = p.y
fun d2 {l:addr} (pf: !int @ l | p: ptr l): int = p.y (pf | 1)
fun d3 {l:addr} (pf: !int @ l | p: ptr l): int = p.y (1)
fun d4 {l:addr} (pf: !int @ l | p: ptr l): int = p.y (pf | )
fun d5 {l:addr} (pf: !int @ l | p: ptr l): int = p.y (pf, pf | 1)
fun d6 {l:addr} (pf: !int @ l | p: ptr l): int = p.y (pf | 1, 2)
fun d7 {l:addr} (pf: !int @ l | p: ptr l): int = p.y (pf | 1) (pf | 2)

(* case without clauses *)
fun e1 (x: int): int = case x of | _ => 1
fun e2 (x: int): int = case+ x of | _ => 1
fun e3 (x: int): int = case- x of | _ => 1
fun e4 (x: bool): int = case x of | true => 1
fun e5 (x: bool): int = case- x of | true => 1
fun e6 (x: bool): int = case+ x of | true => 1
fun e7 (x: bool): int = case+ x of | true => 1 | false => 2 | true => 3
fun e8 (x: bool): int = case x of | true when x => 1
fun e9 (x: bool): int = case+ x of | true when x => 1 | false => 2
fun e11 {n:int} (x: int n): int = sif n > 0 then 1 else 2
