(* d2exp_syn_type / p2at_syn_type: lambdas applied at once, patterns without annotations, literals with suffixes *)
#include "share/atspre_staload.hats"

val a1 = (lam (x) => x) (3)
val a2 = (lam (x, y) => x + y) (1, 2)
val a3 = (lam (p) => p.0) (@(1, 2))
val a4 = (lam (r) => r.a) (@{a=1, b=2})
val a5 = (lam (x) => x) ((1; 2))
val a6 = (lam (x) => x) ('c')
val a7 = (lam (x) => x) ("str")
val a8 = (lam (x) => x) (1.5)
val a9 = (lam (x) => x) (true)
val a10 = (lam (x) => x) (())
val a11 = (lam (x) => x) (1L)
val a12 = (lam (x) => x) (1U)
val a13 = (lam (x) => x) (1UL)
val a14 = (lam (x) => x) (1LL)
val a15 = (lam (x) => x) (1ULL)
val a16 = (lam (x) => x) (1.5f)
val a17 = (lam (x) => x) (1.5l)
val a18 = (lam (x) => x) (the_null_ptr)
val a19 = (lam (x) => x) ($arrpsz{int} (1, 2, 3))
val a20 = (lam (x) => x) (lam (y) => y)
val a21 = (lam (x) => x) (let val z = 1 in z end)
val a22 = (lam (x) => x) (if true then 1 else 2)
val a23 = (lam (x) => x) (@(1, @(2, 3)))
val a26 = (lam (x) => x) (addr@ a1)
val a27 = (lam (x: int) => x) (3)
val a28 = (lam (x: int, y: bool) => x) (3, true)
val a29 = (lam (x, y: bool) => x) (3, true)
val a30 = (lam (0) => 1) (0)
val a31 = (lam (1L) => 1) (1L)
val a32 = (lam (1U) => 1) (1U)
val a33 = (lam ('c') => 1) ('c')
val a34 = (lam ("s") => 1) ("s")
val a35 = (lam (1.5) => 1) (1.5)
val a36 = (lam (true) => 1) (true)
val a37 = (lam (@(x, y)) => x) (@(1, 2))
val a38 = (lam (@{a=x, b=y}) => x) (@{a=1, b=2})
val a39 = (lam (_) => 1) (1)
val a40 = (lam ((x: int)) => x) (1)
val a41 = (lam (x) => (lam (y) => x + y)) (1)
val a42 = (lam ((): void) => 1) (())
val a43 = (lam (0xffL) => 1) (0xffL)
val a45 = (lam (1ul) => 1) (1ul)
val a46 = (lam (1lu) => 1) (1lu)
val a48 = (lam (p) => p.0) (@(1, 2, 3))
val a49 = (lam (x, y, z) => x) (1, 2, 3)
val a50 = (lam (1e3) => 1) (1e3)
val b1 = 0xFFFFFFFFFFFFFFFFFFFF
val b2 = 1000000000000000000000000
val b3 = 12UL
val b4 = 12LLU
val b5 = 1.0e-3f
val b6 = 2e10
val b7 = 0x1p3
val b8 = 123456789012345678LL
val b9 = 0377
