(* pattern-matching exhaustiveness and redundancy (patcst2): integers, characters, booleans, strings, floats, flat and boxed tuples and records, constructors, nested and mixed patterns *)
#include "share/atspre_staload.hats"
datatype dt = A | B | C
datavtype vt = VA | VB of (int) | VC of (vt, vt)
fun vfree (x: vt): void = case+ x of | ~VA () => () | ~VB _ => () | ~VC (a, b) => (vfree a; vfree b)

fun i1 (x: int): int = case+ x of | 0 => 1 | 1 => 2
fun i2 (x: int): int = case+ x of | 0 => 1 | 1 => 2 | _ => 3
fun i3 (x: int): int = case+ x of | 0 => 1 | 0 => 2 | _ => 3
fun i4 (x: int): int = case+ x of | 0 => 1 | x when x > 0 => 2
fun i5 (x: int): int = case- x of | 0 => 1
fun i6 (x: int, y: int): int = case+ (x, y) of | (0, 0) => 1 | (0, _) => 2 | (_, 0) => 3
fun i7 (x: int, y: int): int = case+ @(x, y) of | @(0, 0) => 1 | @(_, _) => 3
fun i8 (x: uint): int = case+ x of | 0u => 1 | 1u => 2
fun i9 (x: lint): int = case+ x of | 0l => 1
fun c1 (x: char): int = case+ x of | 'a' => 1 | 'b' => 2
fun c2 (x: char): int = case+ x of | 'a' => 1 | 'a' => 2 | _ => 0
fun c3 (x: char): int = case+ x of | 'a' => 1 | 'b' => 2 | _ => 0
fun c4 (x: char, y: char): int = case+ @(x, y) of | @('a', 'b') => 1 | @(_, 'c') => 2
fun b1 (x: bool): int = case+ x of | true => 1
fun b2 (x: bool): int = case+ x of | true => 1 | false => 2
fun b3 (x: bool): int = case+ x of | true => 1 | true => 2 | false => 3
fun b4 (x: bool, y: bool): int = case+ @(x, y) of | @(true, true) => 1 | @(false, _) => 2
fun s1 (x: string): int = case+ x of | "a" => 1 | "b" => 2
fun s2 (x: string): int = case+ x of | "a" => 1 | "a" => 2 | _ => 0
fun s3 (x: string): int = case+ x of | "a" => 1 | _ => 0
fun d1 (x: dt): int = case+ x of | A () => 1 | B () => 2
fun d2 (x: dt): int = case+ x of | A () => 1 | B () => 2 | C () => 3
fun d3 (x: dt): int = case+ x of | A () => 1 | A () => 2 | _ => 3
fun d4 (x: dt): int = case+ x of | C () => 1 | C () => 2 | _ => 3
fun d5 (x: dt): int = case+ x of | C () => 1 | C () => 2
fun d6 (x: dt, y: dt): int = case+ @(x, y) of | @(A (), A ()) => 1 | @(B (), _) => 2 | @(_, C ()) => 3
fun d7 (x: dt, y: dt): int = case+ @(x, y) of | @(A (), _) => 1 | @(_, A ()) => 2 | @(B (), B ()) => 3 | @(C (), _) => 4 | @(_, C ()) => 5
fun v1 (x: vt): void = case+ x of | ~VA () => () | ~VB _ => ()
fun v2 (x: vt): void = case+ x of | ~VA () => () | ~VB _ => () | ~VC (a, b) => (vfree a; vfree b)
fun v3 (x: vt): void = case+ x of | ~VC (~VA (), b) => vfree b | ~VC (~VB _, b) => vfree b | ~VC (~VC (a1, a2), b) => (vfree a1; vfree a2; vfree b) | ~VA () => () | ~VB _ => ()
fun v4 (x: vt): void = case+ x of | ~VC (~VA (), b) => vfree b | ~VA () => () | ~VB _ => () 
fun r1 (x: @{a= int, b= bool}): int = case+ x of | @{a= 0, b= true} => 1 | @{a= 0, b= false} => 2
fun r2 (x: @{a= int, b= bool}): int = case+ x of | @{a= 0, b= true} => 1 | @{a= _, b= false} => 2 | @{a= _, b= true} => 3
fun r3 (x: @{a= int, b= bool}): int = case+ x of | @{a= 0, ...} => 1 | @{b= false, ...} => 2
fun r4 (x: @{a= dt, b= dt}): int = case+ x of | @{a= A (), b= A ()} => 1 | @{a= B (), ...} => 2 | @{b= C (), ...} => 3
fun r5 (x: @{a= dt, b= dt}): int = case+ x of | @{a= A (), ...} => 1 | @{b= A (), ...} => 2 | @{a= B (), b= B ()} => 3 | @{a= C (), ...} => 4 | @{b= C (), ...} => 5
fun t1 (x: @(dt, dt, dt)): int = case+ x of | @(A (), A (), A ()) => 1 | @(B (), _, _) => 2
fun t2 (x: @(int, char, bool)): int = case+ x of | @(0, 'a', true) => 1 | @(_, 'b', false) => 2 | @(_, _, _) => 3
fun t3 (x: @(int, @(char, bool))): int = case+ x of | @(0, @('a', true)) => 1 | @(0, @(_, false)) => 2 | @(_, @(_, true)) => 3
fun t4 (x: '(int, bool)): int = case+ x of | '(0, true) => 1 | '(_, false) => 2
fun e2 (x: int): int = case+ x of | 1 when x > 0 => 1 | 1 => 2 | _ => 3
fun e7 (x: int): int = let val+ 0 = x in 1 end
fun e8 (x: char): int = let val+ 'a' = x in 1 end
fun e9 (x: bool): int = let val+ true = x in 1 end
fun e10 (x: dt): int = let val+ A () = x in 1 end
fun e11 (x: string): int = let val+ "a" = x in 1 end
fun e12 (x: @(int, int)): int = let val+ @(0, y) = x in y end
fun e13 (x: float): int = case+ x of | 1.0f => 1 | _ => 2
fun e14 (x: double): int = case+ x of | 1.0 => 1
fun e16 {n:int} (x: int n): int = case+ x of | 0 => 1 | 1 => 2 | _ when x > 5 => 3
fun e17 (x: int, y: char, z: string): int = case+ @(x, y, z) of | @(0, 'a', "a") => 1 | @(_, 'a', "b") => 2
