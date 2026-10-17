(* applications, effects, constructors, untyped control forms, overloaded symbol alone, template ids *)
#include "share/atspre_staload.hats"

symintr bar
extern fun bar1 (x: int): int
extern fun bar2 (x: bool): bool
overload bar with bar1
overload bar with bar2
val f1 = bar
val f2 = (bar)
val v1 = ifcase | true => 1 | _ => 2
val v2 = sif 1 > 0 then 1 else 2
val v3 = (if true then 1 else 2)
val v4 = (case+ 1 of | 0 => 1 | _ => 2)
val v5 = ifcase | 1 > 0 => () | _ => ()
fn pure1 ():<> int = (print 1; 1)
fn pure3 (x: int):<> int = x + 1
fn pure4 ():<> void = ()
fn e1b ():<> int = pure3 (1)
fn e5 ():<!wrt> int = (print 1; 1)
fn e6 ():<!ref> int = (print 1; 1)
fn e7 ():<fun> int = 1
fn e8 ():<cloref> int = 1
fn e4 ():<!exn> int = e1b ()
fn e14 ():<!ntm> int = e5 ()
fn e15 ():<!wrt> int = e14 ()
fn e16 ():<!ref> int = e5 ()
fn e17 ():<!wrt> int = e6 ()
fun nt1 ():<!ntm> int = 1
fn e1 ():<!ntm> int = 1
fun e11 ():<!all> int = 1
fun e13 ():<1> int = 1
fun app1 (f: (int) -> int, x: int): int = f (x)
fun app2 (f: (int) -<fun,!wrt> int, x: int): int = f (x)
fun app3 (f: (int) -<cloref> int, x: int): int = f (x)
fun app4 (f: (int, int) -> int, x: int): int = f (x)
fun app5 (f: (int) -> int, x: int, y: int): int = f (x, y)
fun app6 (f: (int) -> int): int = f ()
fun app7 (f: (int) -> int): int = f (1)(2)
fun app8 (f: (int) -> ((int) -> int)): int = f (1)(2)
fun app9 (f: int): int = f (1)
fun app10 (f: (!int) -> int, x: int): int = f (x)
fun app11 (f: (&int) -> int, x: int): int = f (x)
fun app12 (f: (&int) -> int): int = let var x: int = 1 in f (x) end
fun app13 (f: (&int >> int?) -> int): int = let var x: int = 1 in f (x) end
fun app14 {n:nat} (f: (int n) -> int n, x: int): int = f (x)
fun app15 {n:nat} (f: {m:nat} (int m) -> int m, x: int n): int = f (x)
fun app16 {n:nat} (f: {m:nat} (int m) -> int (m+1), x: int n): int (n+1) = f (x)
fun app17 (f: (int | int) -> int, x: int): int = f (x)
fun app18 (f: (int | int) -> int, x: int): int = f (() | x)
fun app19 {l:addr} (f: {l:addr} (!int @ l | ptr l) -> int, p: ptr l): int = f (view@ x | p) where { var x: int = 1 }
fun app20 (f: (int) -> int, g: (int) -> int): int = f (g (1))
fun app21 (f: (int) -> int): int = f (f (f (1)))
fun app22 (): int = (lam (x: int): int => x + 1) (2)
fun app23 (): int = (llam (x: int): int => x + 1) (2)
fun app24 (): int = (lam@ (x: int): int => x + 1) (2)
fun app25 (): int = (fix f (x: int): int => if x > 0 then f (x - 1) else 0) (3)
fun app26 {a:t@ype} (x: a): a = x
val app27 = app26<int> (1)
val app28 = app26 (1)
val app29 = app26<int, int> (1)
val app30 = app26<> (1)
extern fun {a:t@ype} tf (x: a): a
val app31 = tf<int> (1)
val app32 = tf (1)
val app33 = tf<bool> (1)
fun app34 (): int = tf<int> (1) + tf<int> (2)
extern fun {a:t@ype}{b:t@ype} tf2 (x: a, y: b): a
val app35 = tf2<int><bool> (1, true)
val app36 = tf2<int> (1, true)
val app37 = tf2<int><bool><char> (1, true)
datavtype dv1 = D1A | D1B of int | D1C of (int, int)
val c1 = D1A
val c2 = D1A ()
val c3 = D1B (1)
val c4 = D1B (1, 2)
val c5 = D1B
val c6 = D1C (1, 2)
val c7 = D1C (1)
val c8 = D1C (true, 2)
val c9 = D1C @(1, 2)
val c10 = D1B (| 1)
datavtype dv2 (n:int) = D2A (0) | {n:nat} D2B (n+1) of (int, dv2 n)
val c11 = D2A ()
val c12 = D2B (1, D2A ())
val c13 = D2B (1, 2)
val c14: dv2 (1) = D2B (1, D2A ())
val c15: dv2 (2) = D2B (1, D2A ())
fun c16 (): dv1 = D1C (1, 2)
fun c17 (): List0_vt (int) = list_vt_cons (1, list_vt_nil ())
fun c18 (): List0_vt (int) = list_vt_cons (true, list_vt_nil ())
fun c19 (): List0_vt (int) = list_vt_nil ()
fun c20 (): List0_vt (int) = list_vt_cons (1)
val c21 = list_vt_cons{int}{0} (1, list_vt_nil ())
val c22 = list_vt_cons (1, list_vt_cons (2, list_vt_nil ()))
