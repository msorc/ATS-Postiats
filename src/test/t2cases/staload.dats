staload "./staload_a.sats"
staload A1 = "./staload_a.sats"
staload B = "./staload_b.sats"
staload _ = "./staload_a.sats"
staload "./staload_a.sats"
#staload "./staload_a.sats"
staload A2 = "./staload_a.sats"
val x1 = a_val + $A1.a_val
fun f1 (x: A_t): int = a_foo (x) + $A1.a_foo (x) + aov (x)
fun f2 (x: $B.A_t): int = $B.b_foo (x)
fun f3 (x: $A1.A_d): int = case+ x of $A1.A_x n => n | $A1.A_y () => 0
fun f4 (x: A_d): int = case+ x of A_x n => n | A_y () => 0
fun f5 (x: $A1.A_t): [n: $A1.A_s] int n = 0
stadef zz = $A1.A_sta
stadef yy = $A1.A_c
val e1 = $NOSUCH.a_val
val e2 = $A1.nosuch
val e3 = $x1.a_val
staload C = "./nosuch_file.sats"
staload D = "./staload_a.sats"
val e4 = $D.a_val
staload "./staload_a.sats"
local
staload L = "./staload_a.sats"
in
val x2 = $L.a_val
end
val e5 = $L.a_val
staload X = "prelude/SATS/integer.sats"
staload "prelude/SATS/list.sats"
staload "libats/SATS/linmap_avltree.sats"
staload LM = "libats/SATS/linmap_avltree.sats"
staload _ = "libats/DATS/linmap_avltree.dats"
