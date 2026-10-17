(* staloaded by staload.dats *)
abstype A_t = ptr
datatype A_d = A_x of int | A_y
sortdef A_s = int
stadef A_sta = 1
stacst A_c: int
fun a_foo (x: A_t): int
fun a_bar (x: int): A_d
overload ++ with a_foo
symintr aov
overload aov with a_foo
val a_val : int
