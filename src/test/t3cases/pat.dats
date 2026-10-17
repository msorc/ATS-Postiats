(* patterns of every kind against matching and mismatching types: errors of p2at_trdn *)
#include "share/atspre_staload.hats"

fun p1 (x: int): int = case+ x of | 0 => 1 | 1 => 2 | _ => 3
fun p2 (x: bool): int = case+ x of | true => 1 | false => 0
fun p3 (x: char): int = case+ x of | 'a' => 1 | 'b' => 2 | _ => 3
fun p4 (x: string): int = case+ x of | "a" => 1 | "b" => 2 | _ => 3
fun p5 (x: double): int = case+ x of | 1.0 => 1 | _ => 0
fun p6 (x: int): int = case+ x of | true => 1 | _ => 0
fun p7 (x: bool): int = case+ x of | 0 => 1 | _ => 0
fun p8 (x: int): int = case+ x of | 'a' => 1 | _ => 0
fun p9 (x: int): int = case+ x of | "a" => 1 | _ => 0
fun p10 (x: int): int = case+ x of | 1.0 => 1 | _ => 0
fun p11 (x: char): int = case+ x of | 1 => 1 | _ => 0
fun p12 (x: string): int = case+ x of | 1 => 1 | _ => 0
fun p15 (x: @(int, int)): int = case+ x of | @(a, b, c) => a | _ => 0
fun p16 (x: @(int, int)): int = case+ x of | @(a) => a | _ => 0
fun p17 (x: int): int = case+ x of | @(a, b) => a | _ => 0
fun p18 (x: @(int, int)): int = case+ x of | @(a, _) => a
fun p19 (x: @{a=int, b=int}): int = case+ x of | @{a=aa, b=bb} => aa + bb
fun p20 (x: @{a=int, b=int}): int = case+ x of | @{a=aa} => aa
fun p21 (x: @{a=int, b=int}): int = case+ x of | @{a=aa, c=cc} => aa
fun p22 (x: @{a=int, b=int}): int = case+ x of | @{a=aa, b=bb, c=cc} => aa
fun p23 (x: @{a=int, b=int}): int = case+ x of | @{a=aa, ...} => aa
fun p24 (x: @{a=int, b=int}): int = case+ x of | @(a, b) => a
fun p25 (x: @(int, int)): int = case+ x of | @{a=aa, b=bb} => aa
fun p26 (x: int): int = case+ x of | (y: int) => y
fun p27 (x: int): int = case+ x of | (y: bool) => 1
fun p28 (x: int): int = case+ x of | y as z => 1
fun p31 (x: ptr): int = case+ x of | _ when ptr_is_null (x) => 1 | _ => 0
fun p32 (x: int): int = case+ x of | 0 when true => 1 | 1 when x > 0 => 2 | _ => 3
fun p33 {n:nat} (x: int n): int = case+ x of | 0 => 1 | _ => 2
fun p34 {n:nat} (x: int n): int = case+ x of | n when n > 0 => 1 | _ => 2
fun p35 (x: [n:nat] int n): int = case+ x of | 0 => 1 | _ => 2
fun p36 (x: [n:nat] (int n, int n)): int = case+ x of | @(a, b) => a
fun p37 (x: [n:nat] (int n, int n)): int = let val [m:int] @(a, b) = x in a + b end
fun p38 (x: [n:nat] (int n, int n)): int = let val [m:int, k:int] @(a, b) = x in a + b end
datavtype dt = DA | DB of () | DC of (int, int)
fun p40 (x: dt): int = case+ x of | DA () => 1 | DB () => 2 | DC (a, b) => a + b
fun p41 (x: dt): int = case+ x of | DA () => 1
fun p42 (x: dt): int = case+ x of | DC (a) => 1 | _ => 0
fun p43 (x: dt): int = case+ x of | DC (a, b, c) => 1 | _ => 0
fun p44 (x: int): int = case+ x of | DA () => 1 | _ => 0
fun p45 (x: dt): int = case+ x of | DC (a, b) when a > b => 1 | DC (_, _) => 2 | _ => 0
fun p46 (x: dt): int = case+ x of | @DC (a, b) => 1 | _ => 0
fun p47 (x: dt): int = case+ x of | ~DC (a, b) => 1 | _ => 0
datavtype dv = DVA | DVB of (int, dv)
fun p49 (x: dv): int = case+ x of | ~DVA () => 1 | ~DVB (a, b) => a
fun p50 (x: dv): int = case+ x of | DVA () => 1 | DVB (a, b) => a
fun p51 (x: !dv): int = case+ x of | DVA () => 1 | DVB (a, b) => a
fun p52 (x: !dv): int = case+ x of | @DVB (a, b) => (fold@ x; a) | DVA () => 0
fun p53 (x: dv): int = case+ x of | ~DVB (a, b) => a | _ => 0
fun p54 (x: dv): int = case+ x of | ~DVB (a, ~DVA ()) => a | ~DVB (a, ~DVB (_, _)) => a | ~DVA () => 0
fun p55 (x: dv): int = let val ~DVA () = x in 0 end
fun p56 (x: dv): int = let val ~DVB (a, b) = x val () = (case+ b of | ~DVA () => () | ~DVB (_, _) => ()) in a end
fun p57 (x: int): int = let val 0 = x in 1 end
fun p58 (x: int, y: int): int = let val (a, b) = (x, y) in a + b end
fun p59 (x: int): int = let val (a: int, b: bool) = (x, x) in 1 end
fun p60 (x: int): int = let val @(a, b) = x in 1 end
fun p61 (x: int): int = let val+ 0 = x in 1 end
fun p62 (x: int): int = let val- 0 = x in 1 end
abstype abt
fun p63 (x: abt): int = case+ x of | _ => 1
fun p64 (x: int): int = let val [n:int] y = x in y end
