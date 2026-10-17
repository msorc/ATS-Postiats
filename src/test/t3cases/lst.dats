(* $lst/$lst_t/$lst_vt patterns against a user-declared list_t0ype_int_type, evaluated #define constants as patterns *)
#include "share/atspre_staload.hats"

datavtype list_t0ype_int_type (a: vt@ype+, int) =
  | list_nil (a, 0) of ()
  | {n:int | n >= 0} list_cons (a, n+1) of (a, list_t0ype_int_type (a, n))
stadef list = list_t0ype_int_type

fun l1 (x: list(int, 2)): int = case+ x of | $lst(a, b) => a + b
fun l2 (x: list(int, 2)): int = case+ x of | $lst_t(a, b) => a + b
fun l3 (x: list(int, 2)): int = case+ x of | $lst_vt(a, b) => a + b
fun l4 (x: list(int, 2)): int = case+ x of | $lst(a) => a
fun l5 (x: list(int, 2)): int = case+ x of | $lst(a, b, c) => a
fun l6 (x: [n:nat] list(int, n)): int = case+ x of | $lst(a, b) => a + b | _ => 0
fun l7 (x: [n:nat] list(int, n)): int = case+ x of | $lst() => 0 | $lst(a) => a | _ => 1
fun l8 (x: list(bool, 2)): int = case+ x of | $lst(a, 1) => 1 | _ => 0
fun l9 (x: list_vt(int, 2)): int = case+ x of | $lst(a, b) => a + b
fun l12 (x: int): int = case+ x of | $lst(a) => a | _ => 0
fun l13 (x: list(int, 2)): int = let val $lst(a, b) = x in a + b end
fun l14 (x: list(int, 2)): int = let val $lst_vt(a, b) = x in a + b end
fun l15 (x: list_vt(int, 2)): int = let val $lst_t(a, b) = x in a + b end
fun l16 (x: list_vt(int, 2)): int = let val $lst_vt(a, b) = x in a + b end
fun l17 (x: list_vt(int, 2)): int = case+ x of | $lst_t(a, b) => a + b
fun l18 {n:int} (x: list(int, n)): int = case+ x of | $lst(a, b) => a + b | _ => 0
fun l19 {n:int} (x: list(int, n)): int = case+ x of | $lst(a, b) => a + b
fun l20 {a:t@ype} (x: list(a, 2)): int = case+ x of | $lst(a, b) => 1
fun l21 (x: list(int, 2)): int = case+ x of | $lst(a, b) => a + b | list_cons (c, _) => c

#define N2 %(1+2)
#define N3 %(100*100)
#define F3 (1.5)
#define S2 %("ab")
#define C2 %('a')
#define I3 (0xff)
fun d1 (x: int): int = case+ x of | N2 => 1 | N3 => 2 | _ => 0
fun d2 (x: double): int = case+ x of | F3 => 2 | _ => 0
fun d4 (x: bool): int = case+ x of | N2 => 1 | _ => 0
fun d5 (x: double): int = case+ x of | N2 => 1 | _ => 0
fun d6 {n:int} (x: int n): int = case+ x of | N2 => 1 | _ => 0
fun d7 (x: uint): int = case+ x of | N2 => 1 | _ => 0
fun d8 (x: string): int = case+ x of | S2 => 1 | _ => 0
fun d9 (x: char): int = case+ x of | C2 => 1 | _ => 0
fun d10 (x: int): int = case+ x of | I3 => 1 | _ => 0
fun d12 {n:int} (x: [m:int] int m): int = case+ x of | N2 => 1 | _ => 0
fun d13 (x: lint): int = case+ x of | N2 => 1 | _ => 0
fun d14 (x: llint): int = case+ x of | N2 => 1 | _ => 0
fun d15 (x: ptr): int = case+ x of | N2 => 1 | _ => 0
fun d16 (x: int): int = let val N2 = x in 0 end
fun d18 (x: int): int = let val (y: int) = x val N2 = y in 0 end
