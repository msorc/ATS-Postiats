(* downward typing (trdn): lambdas, tuples, records, sequences, ifcase with expected types and mismatches *)
#include "share/atspre_staload.hats"

val l1: (int) -> int = lam (x) => x
val l2: (int, int) -> int = lam (x) => x
val l3: (int) -> int = lam (x, y) => x
val l4: (int) -> int = lam (x: bool) => 1
val l5: (int) -> bool = lam (x) => x
val l6: int = lam (x) => x
val l7: (int) -<cloref> int = lam (x) => x
val l8: (int) -<lincloptr> int = llam (x) => x
val l9: (int) -> int = llam (x) => x
val l10: (int) -<fun,!wrt> int = lam (x) => (print x; x)
val l11: (int) -<fun> int = lam (x) => (print x; x)
val l12: (int | int) -> int = lam (x) => x
val l13: (int | int) -> int = lam (pf | x) => x
val l14: (!int) -> int = lam (x) => x
val l15: (&int) -> int = lam (x) => x
val l16: (&int >> int?) -> int = lam (x) => 1
val l17: {n:nat} (int n) -> int n = lam {n:nat} (x) => x
val l18: {n:nat} (int n) -> int n = lam {m:nat} (x) => x
val l19: {n:nat} (int n) -> int n = lam (x) => x
val l20: {n:nat} (int n) -> int (n+1) = lam (x) => x
val l21: (int) -> int = lam {n:nat} (x) => x
val l22: (@(int, int)) -> int = lam (@(a, b)) => a
val l23: (@(int, int)) -> int = lam (@(a, b, c)) => a
val l24: (@{a=int, b=int}) -> int = lam (@{a=x, b=y}) => x
val l25: (@{a=int, b=int}) -> int = lam (@{a=x}) => x
val l26: (int) -<> int = lam (x) => x
val l28: (int) -<> int = lam (x) => (print x; x)
val l29: (int) -> int = fix f (x) => f (x)
exception E
val t1: @(int, int) = @(1, 2)
val t2: @(int, int) = @(1, 2, 3)
val t3: @(int, int) = @(1)
val t4: @(int, int) = @(1, true)
val t5: @(int, int) = 1
val t6: @(int, int, int) = (1, 2, 3)
val t7: @(int | int) = (() | 1)
val t8: @{a=int, b=int} = @{a=1, b=2}
val t9: @{a=int, b=int} = @{a=1}
val t10: @{a=int, b=int} = @{a=1, b=2, c=3}
val t11: @{a=int, b=int} = @{a=1, c=2}
val t12: @{a=int, b=int} = @{a=true, b=2}
val t13: @{a=int, b=int} = @(1, 2)
val t14: @(int, int) = @{a=1, b=2}
val t15: @(int, @(int, int)) = @(1, @(2, 3))
val t16: @(int, @(int, int)) = @(1, @(2, true))
val t17: @(int, @(int, int)) = @(1, (2, 3))
val t18: @[int][3] = @[int][3](0)
val t19: @[int][3] = @[int][2](0)
val t20: @[int][3] = @[int](1, 2, 3)
val t21: @[int][3] = @[int](1, 2)
val s1: int = (1; 2)
val s2: int = (1; true)
val s3: void = (1; ())
val s4: int = ()
val s5: void = 1
val s6: int = (let val x = 1 in x end)
val s7: bool = (let val x = 1 in x end)
val s8: int = (if true then 1 else 2)
val s9: int = (if true then 1 else true)
val s10: int = (if true then true else 2)
val s11: int = (if 1 then 1 else 2)
val s12: int = (if true then 1)
val s13: void = (if true then ())
val s14: void = (if true then 1)
val s15: int = ifcase | true => 1 | _ => 2
val s16: int = ifcase | true => 1 | _ => true
val s17: int = ifcase | 1 => 1 | _ => 2
val s18: int = ifcase | true => 1
val s19: int = (sif 1 > 0 then 1 else 2)
val s20: int = (sif 1 > 0 then 1 else true)
val s21: int = (case+ 1 of | 0 => 1 | _ => 2)
val s22: int = (case+ 1 of | 0 => 1 | _ => true)
val s23: int = (case+ 1 of | 0 => 1)
val s24: int = (case+ true of | 0 => 1 | _ => 2)
val s25: void = (case+ 1 of | 0 => () | _ => ())
val s26: int = let val x = 1 in x end
val s27: int = (try 1 with | ~E () => 2)
val s28: int = (try 1 with | ~E () => true)
val s29: int = $raise (E ())
val s30: int = $effmask_all (1)
val s31: int = $effmask_all (true)
val s32: int = $ldelay (1)
val s33: lazy_vt (int) = $ldelay (1)
val s34: lazy_vt (int) = $ldelay (true)
val s35: lazy_vt (int) = $ldelay (1, lazy_vt_free (s33))
val s36: [n:int] int n = 1
val s37: [n:int] int n = true
val s38: [n:int | n > 5] int n = 1
val s39: [n:int | n > 0] int n = 1
val s40: int 1 = 1
val s41: int 2 = 1
val s42: [n:int] (int n, int n) = @(1, 1)
val s43: [n:int] (int n, int n) = @(1, 2)
val s44: (int, int) = @(1, 2)
val s45: int = $extval (int, "0")
val s46: bool = $extval (int, "0")
val s47: int = $extfcall (int, "f", 1)
val s48: int = 'c'
val s49: char = "s"
val s50: string = "s"
val s51: double = 1.0
val s52: double = 1
val s53: int = 1.0
