(* references, pointers, left-values: :=, :=:, addr@, view@, !p and their errors *)
#include "share/atspre_staload.hats"

fun r1 (r: ref (int)): int = !r
fun r2 (r: ref (int)): void = !r := 3
fun r3 (r: ref (int)): void = let var x: int = 1 in !r :=: x end
fun r4 (r: ref (@(int, int))): int = (!r).0
fun r5 (r: ref (@{a=int, b=int})): void = (!r).a := 1
fun r6 (r: ref (@{a=int, b=int})): void = r->a := 1
fun r7 (r: ref (@(int, int))): int = r->0
fun r8 (r: ref (int)): void = let val x = !r in () end
fun r9 (r: ref (int)): int = let var x: int = 0 val () = x := !r in x end
fun r10 (r: ref (int)): void = r := 3
fun r11 (r: int): void = !r := 3
fun r12 (r: int): int = !r
fun r13 (r: int): void = let var x: int = 1 in !r :=: x end
fun r14 (r: int): ptr = addr@ r
fun r15 (): ptr = let var x: int = 1 in addr@ x end
fun r16 (x: int): ptr = addr@ x
fun r17 (): ptr = addr@ (1 + 2)
fun r18 (): void = let var x: int = 1 prval pf = view@ x in () end
fun r19 (x: int): void = let prval pf = view@ x in () end
fun r20 (): void = let prval pf = view@ (1 + 2) in () end
fun r21 (r: int): void = let prval pf = view@ (!r) in () end
fun r22 (p: ptr): void = let prval pf = view@ (!p) in () end
fun r23 {l:addr} (p: ptr l): void = let prval pf = view@ (!p) in () end
fun r24 {l:addr} (pf: int @ l | p: ptr l): void = let prval pf1 = pf in () end
fun r25 (): void = let var x: int = 1 prval pf = view@ x prval () = view@ x := pf in () end
fun r26 (): void = let var x: int = 1 prval pf = view@ x prval () = view@ x := 3 in () end
fun r27 (x: int): void = let prval () = view@ x := () in () end
fun r28 {l:addr} (p: ptr l): void = let prval pf = view@ (!p) prval () = view@ (!p) := pf in () end
fun r29 (): void = let var x: int = 1 var y: int = 2 val () = x :=: y in () end
fun r30 (): void = let var x: int = 1 var y: bool = true val () = x :=: y in () end
fun r31 (x: int, y: int): void = x :=: y
fun r32 (): void = let var x: int = 1 val () = x :=: 3 in () end
fun r33 (): void = let var x: int = 1 val () = 3 :=: x in () end
fun r34 (): void = let var x: int = 1 val () = 3 := x in () end
fun r35 (): void = let var x: int = 1 val () = x := true in () end
fun r36 (x: int): void = x := 3
fun r37 (): void = let val x = 1 val () = x := 3 in () end
fun r38 (): void = let var x: @(int, int) = @(1, 2) val () = x.0 := 5 in () end
fun r39 (): void = let var x: @(int, int) = @(1, 2) val () = x.2 := 5 in () end
fun r40 (): void = let var x: @(int, int) = @(1, 2) val () = x.0 := true in () end
fun r41 (): void = let var x: @{a=int, b=int} = @{a=1, b=2} val () = x.c := 5 in () end
fun r42 (): void = let var x: int = 1 val () = x.a := 5 in () end
fun r43 (): ptr = let var x: @(int, int) = @(1, 2) in addr@ (x.0) end
fun r44 (): ptr = let var x: @{a=int, b=int} = @{a=1, b=2} in addr@ (x.b) end
fun r45 {l:addr} (pf: !int @ l | p: ptr l): ptr = addr@ (!p)
fun r46 {l:addr} (pf: !(int, int) @ l | p: ptr l): ptr = addr@ (p->0)
fun r47 (p: ptr): ptr = addr@ (!p)
fun r48 (x: int): int = let var y: int = x in y end
fun r49 (): int = let var x: int = 1 val y = x val z = x + y in z end
fun r50 (): int = let var x: int = 1 val () = x := x + 1 val () = x := x * 2 in x end
fun r51 {l:addr} (pf: !int @ l | p: ptr l): int = !p + !p
fun r52 {l:addr} (pf: !int @ l | p: ptr l): void = (!p := !p + 1)
fun r53 {l:addr} (pf: !int? @ l >> int @ l | p: ptr l): void = !p := 3
fun r54 {l:addr} (pf: !int @ l >> int? @ l | p: ptr l): int = let val x = !p in x end
fun r55 {l:addr} (pf: int? @ l | p: ptr l): void = !p := 3
fun r56 {l:addr} (pf: !int @ l | p: ptr l): void = !p := true
fun r57 {l:addr} (pf: !int @ l | p: ptr l): void = let var x: int = 0 in !p :=: x end
fun r58 {l:addr} (pf: !int @ l | p: ptr l): void = let var x: bool = true in !p :=: x end
fun r59 {l:addr} (pf: !int @ l | p: ptr l): void = let val x = !p in () end
fun r60 {l1,l2:addr} (pf1: !int @ l1, pf2: !int @ l2 | p1: ptr l1, p2: ptr l2): void = !p1 := !p2
fun r61 {l:addr} (pf: !(@(int, int)) @ l | p: ptr l): int = p->0 + p->1
fun r62 {l:addr} (pf: !(@{a=int, b=int}) @ l | p: ptr l): void = p->a := p->b
fun r63 {l:addr} (pf: !(@{a=int, b=int}) @ l | p: ptr l): void = p->a :=: p->b
fun r64 {l:addr} (pf: !(@{a=int, b=int}) @ l | p: ptr l): void = p->c := 1
fun r65 (r: ref (int)): void = r->a := 1
fun r66 (r: ref (int)): int = !r + !r
fun r67 (): void = let var x: int = 1 val p = addr@ x val () = !p := 2 in () end
fun r68 (): int = let var x: int = 1 val p = addr@ x in !p end
fun r69 (): int = let var x: int = 1 val p = addr@ x prval pf = view@ x in !p end
fun r70 (): void = let var x: int? val () = x := 1 in () end
fun r71 (): int = let var x: int? in x end
fun r72 (): void = let var x: int = 1 and y: int = 2 val () = (x := y; y := x) in () end
fun r73 (): void = let var x = 1 var y = true in () end
fun r74 (): int = let var a = @[int][4](0) in a[0] end
fun r75 (): void = let var a = @[int][4](0) val () = a[1] := 3 val () = a[2] :=: a[3] in () end
fun r76 (): void = let var a = @[int][4](0) val () = a[true] := 3 in () end
fun r77 (): void = let var a = @[int][4](0) val () = a[~1] := 3 in () end
fun r78 (): void = let var a = @[int][4](0) val () = a[10] := 3 in () end
fun r79 (): void = let var a = @[int][4](0) val () = a[0][1] := 3 in () end
fun r80 (a: &(@[int][4])): void = a[0] := 3
fun r81 (a: &(@[int][4])): int = a[3]
fun r82 (a: &(@[int][4])): int = a[4]
fun r83 {n:nat} (a: &(@[int][n]), i: natLt n): void = a[i] := 3
fun r84 {n:nat} (a: &(@[int][n]), i: int): void = a[i] := 3
fun r85 (a: &(int)): void = a := 3
fun r86 (a: &(int)): int = a
fun r87 (a: &(int) >> int?): void = ()
fun r88 (a: &(int?) >> int): void = a := 3
fun r89 (a: &(int?) >> int): void = ()
fun r90 (a: &(@(int, int))): void = a.0 := 3
