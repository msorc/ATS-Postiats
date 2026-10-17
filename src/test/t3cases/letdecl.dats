(* let with declarations, where, local, nested functions, val patterns *)
#include "share/atspre_staload.hats"

val a = let val x = 1 val y = 2 in x + y end
val b = x + y where { val x = 10 val y = 20 }

local
  val c = 5
  fun h (x: int): int = x + c
in
  fun g (x: int): int = h (x) * 2
end

fun f (x: int): int = let
  val y = x + 1
  val (z, w) = @(y * 2, y * 3)
  fun aux (n: int): int = n + z
  fun aux2 (n: int): int = aux (n) + w
  val () = ()
in aux2 (y) end

val (p, q) = @(1, 2)
val @(r, s) = @(3, 4)
val t = (case+ p of | 1 => 10 | _ => 20)

fun letrec (n: int): int = let
  fun even (n: int): bool = if n = 0 then true else odd (n - 1)
  and odd (n: int): bool = if n = 0 then false else even (n - 1)
in if even (n) then 1 else 0 end

fun letpf (x: int): int = let
  prval pf = ()
  val y = x
  prval () = pf
in y end

val u = let var z: int = 3 in z := z + 1; z end

abstype T = ptr
extern fun mk (): T
assume T = ptr
implement mk () = the_null_ptr
