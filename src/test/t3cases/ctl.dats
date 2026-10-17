(* if, case, scase, loops, try-with, raise *)
#include "share/atspre_staload.hats"

fun f1 (x: int): int = if x > 0 then 1 else if x < 0 then ~1 else 0
fun f2 (x: int): int = case+ x of | 0 => 1 | 1 => 2 | _ => 3
fun f3 (b: bool): int = case+ b of | true => 1 | false => 0
fun f4 (x: int, y: int): int = case+ (x, y) of | (0, _) => 1 | (_, 0) => 2 | (_, _) => 3
fun f5 {n:int} (x: int n): int = sif n > 0 then 1 else 0
fun f7 (x: int): int = ifcase | x = 0 => 1 | x = 1 => 2 | _ => 3

fun loop1 (n: int): int = let
  var i: int = 0
  var s: int = 0
  val () = while (i < n) (s := s + i; i := i + 1)
in s end

fun loop2 (n: int): int = let
  var s: int = 0
  val () = for (s := 0; s < n; s := s + 1) ()
in s end

fun loop3 (n: int): int = let
  var i: int = 0
  val () = while (true) (if i >= n then $break else i := i + 1)
in i end

fun loop4 (n: int): int = let
  var i: int = 0
  var s: int = 0
  val () = while (i < n) let val () = i := i + 1 in if i = 3 then $continue else s := s + i end
in s end

exception MyExn of int
fun tw (x: int): int = try (if x > 0 then $raise MyExn (x) else 0) with | ~MyExn (n) => n + 1
fun tw2 (x: int): int = try x + 1 with | ~MyExn (n) => 0 | ~_ => 7

fun ifno (x: int): void = if x > 0 then ()
fun cpt {n:nat} (x: int n): int = case+ x of | 0 => 0 | n when n > 5 => 1 | _ => 2
fun seq (x: int): int = (x + 1; x + 2; x + 3)
fun cond (x: int): int = if x > 0 then 1 else 0
