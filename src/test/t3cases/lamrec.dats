(* val rec with untyped lambdas: the types of the argument patterns are synthesized (p2at_syn_type, d2exp_syn_type) *)
#include "share/atspre_staload.hats"

#define N 3
#define M 0x10
datavtype dvt = DVT of (int)
vtypedef lrcd = @{ a= int, d= dvt }

val rec f1 = lam (1) => 2
val rec f2 = lam (true) => 1
val rec f3 = lam ('a') => 1
val rec f4 = lam ("abc") => 1
val rec f5 = lam (1.5) => 1
val rec f6 = lam (0xff) => 1
val rec f7 = lam (x) => x
val rec f8 = lam (_) => 1
val rec f9 = lam (x: int) => x
val rec f10 = lam (@(a, b)) => a
val rec f11 = lam (@{ a= x, b= y }) => x
val rec f12 = lam (@{ a= x, ... }) => x
val rec f13 = lam ('(a, b)) => a
val rec f14 = lam (x as y) => 1
val rec f15 = lam (a, b) => a
val rec f16 = lam {l:addr} (pf: !int @ l | p: ptr l) => !p
val rec f17 = lam (vbox pf | x: int) => x
val rec f18 = lam (DVT (x)) => x
val rec f19 = lam (@DVT (x)) => x
val rec f20 = lam () => 1
val rec f21 = lam ((a, b): @(int, int)) => a
val rec f22 = lam (~DVT (x)) => x
val rec f23 = lam ([n:int] x) => 1
val rec f23b = lam ([n:int] (x: int n)) => 1
val rec f23c = lam ((a, b)) => a
val rec f23d = lam (N) => 1
val rec f23e = lam (N, M) => 1
val rec f24 = lam (x) => f24 (x)
val rec f25 = lam (x: int): int => f25 (x)
val rec f26 = lam (0, 1) => 1
val rec f27 = llam (x) => x
val rec f28 = lam@ (x) => x
val rec f29 = lam (x) => (f29 (x); f30 x)
and f30 = lam (y) => f29 y
val rec f31 = lam (x: dvt): void => ()
val rec f32 = lam (DVT x) => f32 (DVT x)
val rec (g1, g2) = @(lam (x: int): int => g2 x, lam (y: int): int => g1 y)
val rec g3 = 3
val rec g4: int = 4
val rec g5 = @(1, 2)
val rec @(g6, g7) = @(lam (x: int): int => x, lam (y: int): int => y)
val rec g8 = DVT 1
val rec g9 = lam (x: dvt) => x
val rec g10 = lam (x: lrcd) => x.a
val rec g11 = lam (x: !lrcd) => x.a
val rec g12 = lam (x: &int >> int) => x
val rec g13 = lam (x: &int) => x
val rec g14 = lam (x) => ~x
val rec g15 = lam (x: int) => x + 1
val rec g16 = lam (x) => if x then 1 else 2
val rec g17 = lam (x) => (case+ x of | 1 => 2 | _ => 3)
val rec g18 = lam (x: int) => (case+ x of | 1 => 2 | _ => 3)
val rec g19 = lam (x) => (let val y = x in y end)
val rec g20 = lam (x) => $UNSAFE.cast{int} (x)
val rec g22 = lam (x: int) =<cloptr1> x
val rec g23 = lam (x: int) =<clo> x
val rec g24 = lam (x: int) =<prf> x
val rec g25 = lam (x: int) =<lin> x
val rec g27 = lam (x: int) =<cloref1> x
val rec g28 = fix h (x: int): int => h x
val rec g29 = fix@ h (x: int): int => h x
val rec g30 = lam (x: int) => (x, x)
val rec g31 = lam (x: int) => @(x, x)
val rec g32 = lam (x: int) => @{ a= x, b= x }
val rec g33 = lam (x: int) => $tup (x, x)
val rec g34 = lam (pf: unit_p | x: int) => (pf | x)
val rec g35 = lam (x: int) => ()

(* funs without result types: d2exp_syn_type of the definitions *)
fun h1 (x: int) = x
fun h2 (x: int) = (x, x)
fun h3 (x: int) = @(x, x)
fun h4 (x: int) = @{ a= x, b= x }
fun h5 (x: int) = (x; x)
fun h6 () = @[int](1, 2, 3)
fun h7 (x: int) = lam (y: int) => x + y
fun h8 {n:nat} (x: int n) = x
fun h9 (x: int) = $list_vt (x, x)
fun h10 (x: int) = $lst_vt {int} (x, x)
fun h11 (x: int) = ()
fun h12 (x: int) = 1
fun h13 (x: int) = true
fun h14 (x: int) = 'a'
fun h15 (x: int) = "abc"
fun h16 (x: int) = 1.5
fun h17 (x: int) = 0xff
fun h18 (x: int) = (x: int)
fun h19 (x: int) = (x: int; x)
fun h20 (x: int) = $extval (int, "foo")
fun h21 (x: int) = (x := 1)
fun h22 (x: int) = (if x > 0 then 1 else 2)
fun h23 (x: int) = lam@ (y: int) => x + y
fun h24 (x: int) = llam (y: int) => x + y
fun h25 (x: int) = lam {n:nat} (y: int n) => y
fun h26 (x: int) = let val y = x in y end
fun h27 (x: int) = $arrpsz {int} (1, 2)
fun h28 (x: int) = @[int](1)
fun h29 (x: int) = '(x, x)
fun h30 (x: int) = '{ a= x }
fun h31 (x: int) = $tup (x, x)
fun h32 (x: int) = $rec { a= x, b= x }
fun h33 (x: int) = $tup (1 | x)
fun h34 (x: int) = @(unit_p() | x)
fun h35 (x: int) = lam (pf: unit_p | y: int) => (pf | y)
fun h36 (x: int) = $effmask_all (x)
fun h37 (x: int) = ($showtype x)
fun h38 (x: int) = (x + 1)
and h39 (x: int) = h38 x
fun h40 (x: int) = (h38 x)
fun h41 (x: int) = lam (y: int) => lam (z: int) => x + y + z
fun h42 (x: int): int = x
fn h43 (x: int):<> int = x
fun h45 (x: int) = fix f (y: int): int => y
fun h47 (x: int) = #[n:nat | true] x
fun h48 (x: int) = lam (y: int): int =<cloptr1> y
