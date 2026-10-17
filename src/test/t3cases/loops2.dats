(* loops with linear states: consumed/retained variables, merging failures, break and continue in strange places *)
#include "share/atspre_staload.hats"

datavtype dvt = DVT of (int)
fun free_dvt (x: dvt): void = let val+ ~DVT _ = x in end
overload free with free_dvt
fun mk (): dvt = DVT 0

fun lp1 (x: dvt, n: int): void = let
  var i: int = 0
in
  while (i < n) (free x; i := i + 1)
end

fun lp2 (n: int): void = let
  val x = DVT 1
  val () = while (n > 0) (free x)
in end

fun lp3 (n: int): void = let
  val x = DVT 1
  val () = free x
  val () = while (n > 0) (x := DVT 2)
in free x end

fun lp4 (n: int): void = let
  val x = DVT 1
  val () = while (n > 0) (free x; x := DVT 2)
in free x end

fun lp5 (n: int): void = let
  val x = DVT 1
  val () = while (n > 0) (if n > 5 then (free x; $break) else ())
in free x end

fun lp6 (n: int): void = let
  val x = DVT 1
  val () = while (n > 0) (if n > 5 then (free x; $continue) else ())
in free x end

fun lp7 (n: int): void = let
  var x: int?
  val () = while (n > 0) (x := 1)
in end

fun lp8 (n: int): void = let
  var x: int = 1
  var y: int? 
  val () = while (n > 0) (y := x)
in end

fun lp9 (n: int): void = let
  var x: int = 1
  prval pf = view@ x
  val () = while (n > 0) ()
  prval () = view@ x := pf
in end

fun lp10 (n: int): void = let
  var x: int = 1
  val () = while (n > 0) (let prval pf = view@ x prval () = view@ x := pf in () end)
in end

fun lp11 (n: int): void = let
  var x: int = 1
  prval pf = view@ x
  val () = while (n > 0) (let prval () = view@ x := pf in () end)
in end

fun lp12 (n: int): void = let
  var x: int = 1
  val () = while (n > 0) (let prval pf = view@ x in () end)
in end

fun lp13 (n: int): void = let
  var x: int = 1
  var i: int = 0
  val () = for (i := 0; i < n; i := i + 1) (let val y = x in () end)
in end

fun lp14 (n: int): void = let
  val x = DVT 1
  var i: int = 0
  val () = for (i := 0; i < n; (free x; i := i + 1)) ()
in end

fun lp15 (n: int): void = let
  val x = DVT 1
  var i: int = 0
  val () = for (i := 0; (free x; i < n); i := i + 1) ()
in free x end

fun lp16 (n: int): void = let
  val x = DVT 1
  val () = while ((free x; n > 0)) ()
in end

fun lp17 (n: int): void = let
  val x = DVT 1
  val () = while (n > 0) (let val y = mk () in free y end)
in free x end

fun lp18 (n: int): void = let
  val x = DVT 1
  val () = while (n > 0) (let val y = mk () in if n > 0 then $break else free y end)
in free x end

fun lp19 (n: int): void = while (true) (let val f = lam () => $break in () end)
fun lp20 (n: int): void = while (true) (let val f = lam () => $continue in () end)
fun lp21 (n: int): void = $break
fun lp22 (n: int): void = $continue
val () = $break
val () = $continue
fun lp23 (n: int): void = for (;;) ($break; ())
fun lp24 (n: int): void = for (;;) ($continue; ())
fun lp25 (n: int): void = let var i: int = 0 in for (; i < n; i := i + 1) (if i > 3 then $break else $continue) end
fun lp26 (n: int): void = while (n > 0) (while (n > 1) ($break); $break)
fun lp27 (n: int): void = while (n > 0) (let val x = DVT 1 in free x; $break end)
fun lp28 (n: int): void = while (n > 0) (let val x = DVT 1 in $break end)
fun lp29 (n: int): void = while (n > 0) (let val x = DVT 1 in $continue end)
fun lp30 (n: int): void = let val x = DVT 1 in while (n > 0) ($break) end
fun lp31 (n: int): int = (while (n > 0) ($break); 1)
fun lp32 (n: int): void = while (n) ()
fun lp33 (n: int): void = let var i: int = 0 in while (i < 10) (i := i + 1; if i = 5 then $break) end

(* metrics in loops *)
fun lm1 {n:nat} (n: int n): void = let
  var i: int = n
in
  while* {i:nat} .<i>. (i: int i): (i: int) => (i > 0) (i := i - 1)
end

fun lm2 {n:nat} (n: int n): void = let
  var i: int = n
in
  while* {i:nat} .<i>. (i: int i): (i: int) => (i > 0) (i := i + 1)
end

fun lm3 {n:nat} (n: int n): void = let
  var i: int = n
in
  while* {i:int} .<i>. (i: int i): (i: int) => (i > 0) (i := i - 1)
end

fun lm4 {n:nat} (n: int n): void = let
  var i: int = n
in
  for* {i:nat} .<i>. (i: int i): (i: int) => (; i > 0; i := i - 1) ()
end

fun lm5 {n:nat} (n: int n): void = let
  var i: int = n
  var x: dvt = DVT 1
in
  while* {i:nat} .<i>. (i: int i, x: dvt): (i: int, x: dvt) => (i > 0) (i := i - 1);
  free x
end

fun lm6 {n:nat} (n: int n): void = let
  var i: int = n
  var x: dvt = DVT 1
in
  while* {i:nat} .<i>. (i: int i): (i: int) => (i > 0) (i := i - 1);
  free x
end
