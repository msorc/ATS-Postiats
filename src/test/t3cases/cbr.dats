(* call-by-reference (set_type of left-values), unfolding patterns on left-values, linear function application *)
#include "share/atspre_staload.hats"

datavtype dvt = DVT of (int)
fun free_dvt (x: dvt): void = let val+ ~DVT _ = x in end
overload free with free_dvt
typedef rcd = @{ a= int, b= bool }
vtypedef lrcd = @{ a= int, d= dvt }

fun mk1 (x: &int? >> int): void = x := 1
fun mk2 (x: &dvt? >> dvt): void = x := DVT 1
fun use1 (x: &dvt >> dvt?): void = let val+ ~DVT n = x in end
fun inc (x: &int >> int): void = x := x + 1
fun chg (x: &int >> bool): void = $UNSAFE.castvwtp0{void}(x)

fun keep (x: &dvt >> dvt): void = ()
fun keepi (x: &int >> int): void = ()
(* variables *)
fun k1 (x: dvt): void = (keep x; keep x; free x)
fun k2 (x: dvt): void = (keep x; free x)
fun k3 (r: lrcd): void = (keep (r.d); keep (r.d); free (r.d))
fun k4 (r: lrcd): void = (keepi (r.a); keepi (r.a); free (r.d))
fun k5 (r: lrcd): void = (keepi (r.d); free (r.d))
fun k6 (x: dvt): void = (keep x; use1 x; keep x)
fun a1 (): void = let var x: dvt = DVT 1 val () = use1 x in end
fun a2 (): void = let var x: dvt val () = mk2 x val () = use1 x in end
fun a3 (): void = let var x: dvt = DVT 1 val () = use1 x val () = mk2 x val () = use1 x in end
fun a4 (): int = let var x: int val () = mk1 x val () = inc x in x end
fun a5 (): bool = let var x: int = 1 val () = chg x in x end
fun a6 (x: dvt): void = use1 x
fun a7 (x: dvt): void = mk2 x
fun a8 (x: int): void = inc x
fun a9 (): void = let val x = DVT 1 in use1 x end
fun a10 (): void = let val x = DVT 1 val () = free x in mk2 x; free x end

fun a11 (x: dvt): void = (mk2 x; mk2 x; free x)
fun a12 (x: dvt): void = (use1 x; mk2 x; free x)
fun a13 (x: dvt): void = (use1 x; use1 x)
fun a14 (x: int): void = (inc x; inc x)
fun a15 (x: dvt): void = (use1 x; mk2 x; mk2 x; free x)

(* selections *)
fun b12 (r: lrcd): void = (use1 (r.d); mk2 (r.d); mk2 (r.d); free (r.d))
fun b13 (r: lrcd): void = (use1 (r.d); mk2 (r.d); free (r.d))
fun b14 (r: lrcd): void = (inc (r.a); inc (r.a); free (r.d))
fun b1 (): void = let var r: lrcd = @{ a= 1, d= DVT 1 } val () = use1 (r.d) val () = mk2 (r.d) val () = use1 (r.d) in end
fun b2 (r: lrcd): void = use1 (r.d)
fun b3 (r: lrcd): void = (inc (r.a); free (r.d))
fun b4 (): void = let var r: lrcd = @{ a= 1, d= DVT 1 } val () = use1 (r.zzz) in end
fun b5 (): void = let var r: lrcd = @{ a= 1, d= DVT 1 } val () = inc (r.d) in end
fun b7 (): void = let var a = @[int][2](1, 2) val () = inc (a[0]) in end
fun b8 (): void = let var a = @[int][2](1, 2) val () = inc (a[2]) in end
fun b9 (): void = let var a = @[int][2](1, 2) val () = inc (a[true]) in end
fun b10 (a: @[int][2]): void = inc (a[0])
fun b11 (): void = let var r: rcd = @{ a= 1, b= true } val () = inc (r.a) val () = chg (r.a) in end

(* pointers *)
fun c1 {l:addr} (pf: !dvt @ l | p: ptr l): void = use1 (!p)
fun c2 {l:addr} (pf: !lrcd @ l | p: ptr l): void = (inc (p->a); use1 (p->d); mk2 (p->d))
fun c3 {l:addr} (p: ptr l): void = use1 (!p)
fun c4 (p: ptr): void = use1 (!p)
fun c5 (p: int): void = use1 (!p)
fun c6 {l:addr} (pf: !lrcd @ l | p: ptr l): void = inc (p->d)
fun c7 {l:addr} (pf: !lrcd @ l | p: ptr l): void = inc (p->zzz)
fun c8 {l:addr} (pf: !(@[dvt][2]) @ l | p: ptr l): void = use1 (p->[0])
fun c9 {l:addr} (pf: !(@[dvt][2]) @ l | p: ptr l): void = (use1 (p->[0]); mk2 (p->[0]))
fun c10 (r: ref(dvt)): void = use1 (!r)
fun c11 (r: ref(int)): void = inc (!r)
fun c12 (r: ref(lrcd)): void = use1 (r->d)

(* view@ as argument *)
fun pv {l:addr} (pf: !int @ l >> int? @ l | p: ptr l): void = ()
fun pv2 {l:addr} (pf: !int? @ l >> int @ l | p: ptr l): void = ()
fun d2 {l:addr} (pf: int @ l | p: ptr l): (int? @ l | void) = let val () = pv (pf | p) in (pf | ()) end
fun d3 {l:addr} (pf: int? @ l | p: ptr l): (int @ l | void) = let val () = pv2 (pf | p) in (pf | ()) end
fun d4 (): void = let var x: int = 1 val () = pv (view@ x | addr@ x) val () = pv2 (view@ x | addr@ x) in end
fun d5 {l:addr} (pf: !int @ l | p: ptr l): void = let val () = pv (pf | p) in end
fun d6 {l:addr} (p: ptr l): void = let val () = pv (view@ (!p) | p) in end
fun d7 (null: ptr null): void = let val () = pv (view@ (1+2) | null) in end
fun d8 {l:addr} (pf: int @ l | p: ptr l): (int? @ l | void) = let val () = pv (view@ (!p) | p) in (pf | ()) end
fun d9 (x: dvt, null: ptr null): void = let val () = pv (view@ x | null) in free x end
fun d10 {l:addr} (pf: int @ l | p: ptr l): void = let val () = pv (pf | p) val () = pv2 (pf | p) prval () = $UNSAFE.castview0 (pf) in end
fun d11 {l:addr} (pf: int @ l | p: ptr l): void = let val () = pv (pf | p) val () = pv (pf | p) prval () = $UNSAFE.castview0 (pf) in end
fun d12 {l:addr} (pf: int @ l | p: ptr l): void = let val () = pv (unit_v() | p) prval () = $UNSAFE.castview0 (pf) in end
fun d13 (x: dvt, null: ptr null, pf: int @ null): void = let val () = pv (pf | null) in free x end
fun d14 {l:addr} (pf: (int @ l, int @ l) | p: ptr l): void = let val () = pv (pf.0 | p) in end
fun d15 (p: ptr): void = let val () = pv (view@ (!p) | p) in end

(* non-left-values as reference arguments *)
fun e1 (): void = use1 (DVT 1)
fun e2 (): void = inc (1)
fun e3 (): void = let var x: int = 1 in inc (x+1) end
fun e4 (n: int): void = inc (n+1)

(* unfolding patterns on left-values *)
fun u1 (x: dvt): dvt = case+ x of | @DVT (n) => (fold@ x; x)
fun u2 (x: dvt): dvt = case+ x of | @DVT (n) => (n := 2; fold@ x; x)
fun u3 (): dvt = case+ DVT 1 of | @DVT (n) => (n := 2; fold@ (DVT 1); DVT 1)
fun u4 (x: !dvt): void = case+ x of | @DVT (n) => (n := 2; fold@ x)
fun u5 (x: !dvt): void = case+ x of | @DVT (n) => ()
fun u6 (x: dvt): void = case+ x of | @DVT (n) => (n := 2; free@ x)
fun u7 (x: dvt): void = let val @DVT (n) = x in n := 3; fold@ x; free x end
fun u8 (x: !lrcd): void = let val @{ a= a, d= d } = x in end
fun u9 (x: lrcd): void = let val @{ a= a, d= @DVT (n) } = x in end
fun u10 (x: !lrcd): void = case+ x.d of | @DVT (n) => (n := 3; fold@ (x.d))
fun u11 {l:addr} (pf: !dvt @ l | p: ptr l): void = case+ !p of | @DVT (n) => (n := 3; fold@ (!p))
fun u12 {l:addr} (pf: !dvt @ l | p: ptr l): void = case+ !p of | @DVT (n) => (n := 3)
fun u13 (): void = let var x: dvt = DVT 1 in case+ x of | @DVT (n) => (n := 3; fold@ x); free x end
fun u14 (): void = let var x: dvt = DVT 1 in case+ x of | @DVT (n) => (n := 3) end
fun u15 (x: dvt): void = case+ x of | ~DVT n => ()
fun u16 (x: dvt): int = case+ x of | @DVT (n) => (let val m = n in fold@ x; free x; m end)
fun u17 (x: dvt): void = case+ x of | @DVT (n) => (free@ x)
fun u18 (x: dvt, y: dvt): void = case+ (x, y) of | (@DVT (n), @DVT (m)) => (fold@ x; fold@ y; free x; free y)
fun u19 (x: dvt, y: dvt): void = case+ @(x, y) of | @(@DVT (n), @DVT (m)) => (fold@ x; fold@ y; free x; free y)
fun u20 (x: dvt): void = case+ x of | @DVT (n) => (fold@ x; free x) | ~DVT n => ()
fun u21 {l:addr} (p: ptr l): void = case+ !p of | @DVT (n) => ()
fun u22 (r: ref(dvt)): void = case+ !r of | @DVT (n) => (fold@ (!r))
fun u23 (): void = case+ (DVT 1) of | @DVT (n) => ()
fun u24 (x: int): void = case+ x of | @DVT (n) => ()

(* linear function application *)
fun f1 (f: () -<lin,prf> void): void = (f (); f ())
fun f2 (f: () -<lincloptr1> void): void = (f (); f ())
fun f3 (f: () -<lincloptr1> void): void = f ()
fun f4 (f: () -<cloptr1> void): void = (f (); f ())
fun f5 (f: !(() -<lincloptr1> void)): void = f ()
fun f6 (f: () -<cloref1> void): void = (f (); f ())
fun f7 (f: () -<lin,cloptr1> void): void = (f (); f ())
fun f8 (f: () -<lin> void): void = (f (); f ())
fun f9 (f: () -<lin,fun> void): void = (f (); f ())
fun f10 (f: () -<clo> void): void = f ()
fun f11 (f: &(() -<clo1> void)): void = (f (); f ())
fun f12 (f: &(() -<lin,clo1> void)): void = (f (); f ())
fun f13 (f: &(() -<lin,clo1> void) >> _): void = f ()
fun f14 (f: () -<lincloptr> void): void = f ()
