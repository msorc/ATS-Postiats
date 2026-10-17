(* selection of fields: linear records and tuples, temporaries, arrays, free@/fold@, addr@ and its errors, overloaded dot-symbols *)
#include "share/atspre_staload.hats"

datavtype dvt = DVT of (int)
fun free_dvt (x: dvt): void = let val+ ~DVT _ = x in end
overload free with free_dvt
fun mk (): dvt = DVT 0
vtypedef lrcd = @{ a= int, d= dvt }
vtypedef lrcd2 = @{ r= lrcd, c= int, e= dvt }
typedef rcd = @{ a= int, b= bool }
typedef rcd2 = @{ r= rcd, c= int }
datavtype node = Nil | Cons of (int, node)
fun mklr (): lrcd = @{ a= 1, d= DVT 1 }
fun mkr (): rcd = @{ a= 1, b= true }
fun mkr2 (): rcd2 = @{ r= @{ a= 1, b= true }, c= 3 }
fun mkt (): @(dvt, int) = @(DVT 1, 2)
fun mkta (): @[int][3] = @[int][3](0)

(* selections from linear non-mutable variables *)
fun s1 (x: lrcd): int = x.a
fun s2 (x: lrcd): dvt = x.d
fun s3 (x: lrcd2): int = x.r.a
fun s4 (x: lrcd2): dvt = x.r.d
fun s5 (x: lrcd2): dvt = x.e
fun s6 (x: lrcd): int = x.zzz
fun s7 (x: lrcd): int = x.a.b
fun s8 (x: @(dvt, int)): int = x.1
fun s9 (x: @(dvt, int)): dvt = x.0
fun s10 (x: @(dvt, int)): int = x.2
fun s11 (x: @(dvt, int)): int = (x.0; x.0; 1)
fun s12 (x: lrcd): dvt = (x.d; x.d)
fun s13 (x: lrcd): int = let val y = x.d val z = x.a in free y; z end
fun s14 (x: lrcd): int = let val z = x.a val y = x.d in free y; z end
fun s15 (x: @[dvt][3]): dvt = x[0]
fun s16 (x: @[int][3]): int = x[0]
fun s17 (x: @[int][3]): int = x[3]
fun s18 (x: @[int][3]): int = x[true]
fun s19 (x: @[int][3]): int = x[0, 1]
fun s22 (x: @[@[int][3]][3]): int = x[0][1]
fun s23 (x: lrcd): int = $UNSAFE.castvwtp0 (x.a)
fun s24 (x: int): int = x.a
fun s25 (x: dvt): int = x.a
fun s26 (x: rcd): int = x.a
fun s27 (x: rcd): bool = x.b
fun s28 (x: rcd2): int = x.r.a
fun s29 (x: rcd2): int = x.r.zzz
fun s30 (x: rcd2): bool = x.c.b
fun s31 (x: @(int, int)): int = x.0 + x.1
fun s32 (x: @(int, int)): int = x.2
fun s33 (x: '(int, int)): int = x.0
fun s34 (x: '{ a= int, b= int }): int = x.a
fun s35 (x: '{ a= int, b= int }): int = x.zzz
fun s36 (x: [n:nat] @{ a= int n, b= int }): int = x.a

(* selections from temporaries *)
fun t1 (): int = (mklr ()).a
fun t2 (): dvt = (mklr ()).d
fun t3 (): int = (mkr ()).a
fun t4 (): int = (mkr2 ()).r.a
fun t5 (): int = (mkt ()).1
fun t6 (): dvt = (mkt ()).0
fun t8 (): int = (mkr ()).zzz
fun t9 (): int = (1+2).a
fun t10 (): int = (mk ()).a
fun t11 (): int = ((mklr ()).a; (mklr ()).a)
fun t12 (): int = let val x = mklr () in x.a end
fun t13 (): int = let val x = mklr () val y = x.d in free y; x.a end
fun t14 (): int = let val x = mklr () in free (x.d); x.a end
fun t15 (): int = let val x = mklr () val a = x.a val d = x.d in free d; a end
fun t16 (): dvt = let val x = mklr () val a = x.a in x.d end
fun t17 (): int = let val x = mkt () val y = x.1 in free x.0; y end

(* selection from variables *)
fun m1 (): int = let var x: lrcd = mklr () val a = x.a val d = x.d in free d; a end
fun m2 (): int = let var x: lrcd = mklr () val d = x.d val d2 = x.d in free d; free d2; 1 end
fun m3 (): int = let var x: lrcd = mklr () in x.zzz end
fun m4 (): int = let var x: lrcd2 = @{ r= mklr (), c= 1, e= mk () } val d = x.r.d in free d; 1 end
fun m5 (): int = let var x: @[int][3] = @[int][3](0) in x[1] end
fun m6 (): int = let var x: @[int][3] = @[int][3](0) in x[1, 2] end
fun m7 (): int = let var x: @[int][3] = @[int][3](0) in x[3] end
fun m8 (): int = let var x: @[dvt][3] in x[1]; 1 end
fun m9 (): int = let var x: @[int][3] = @[int][3](0) in x.a end
fun m10 (): int = let var x: int = 1 in x.a end
fun m11 (): int = let var x: rcd = mkr () in x.a + (if x.b then 1 else 0) end
fun m12 (): int = let var x: rcd2 = mkr2 () in x.r.a + x.c end

(* pointers and views *)
fun p1 {l:addr} (pf: !lrcd @ l | p: ptr l): int = p->a
fun p2 {l:addr} (pf: !lrcd @ l | p: ptr l): dvt = p->d
fun p3 {l:addr} (pf: lrcd @ l | p: ptr l): dvt = p->d
fun p4 {l:addr} (pf: !lrcd2 @ l | p: ptr l): int = p->r.a
fun p5 {l:addr} (pf: !lrcd2 @ l | p: ptr l): dvt = p->r.d
fun p6 {l:addr} (pf: !lrcd @ l | p: ptr l): int = p->zzz
fun p7 {l:addr} (pf: !rcd @ l | p: ptr l): int = p->a
fun p8 {l:addr} (pf: !(@[dvt][3]) @ l | p: ptr l): dvt = p->[0]
fun p9 {l:addr} (pf: !(@[int][3]) @ l | p: ptr l): int = p->[0]
fun p10 {l:addr} (pf: !(@[int][3]) @ l | p: ptr l): int = p->[3]
fun p11 {l:addr} (p: ptr l): int = p->a
fun p12 (p: ptr): int = p->a
fun p13 (p: int): int = p->a
fun p14 {l:addr} (pf: !lrcd @ l | p: ptr l): int = (!p).a
fun p15 {l:addr} (pf: !lrcd @ l | p: ptr l): dvt = (!p).d
fun p16 {l:addr} (pf: !node @ l | p: ptr l): int = case+ !p of | @Cons (n, _) => (fold@ !p; n) | Nil () => 0
fun p17 (r: ref(lrcd)): int = r->a
fun p18 (r: ref(lrcd)): dvt = r->d
fun p19 (r: ref(rcd)): int = r->a
fun p20 (r: ref(rcd)): int = r->zzz
fun p21 (r: ref(@[int][3])): int = r->[0]
fun p22 (r: ref(@[int][3])): int = r->[3]
fun p23 (r: ref(@[dvt][3])): dvt = r->[0]
fun p24 (r: ref(lrcd)): int = (!r).a
fun p25 (r: ref(lrcd)): dvt = (!r).d

(* fold@ and free@ *)
fun f1 (x: node): void = case+ x of | @Cons (n, xs) => (fold@ x; free@ x) | ~Nil () => ()
fun f2 (x: node): void = case+ x of | @Cons (n, xs) => (free@ x) | ~Nil () => ()
fun f3 (x: node): void = case+ x of | @Cons (n, xs) => (fold@ x; free@ x; ()) | _ => ()
fun f4 (x: node): void = (fold@ x; free@ x)
fun f5 (x: node): void = (free@ x)
fun f6 (x: int): void = (fold@ x)
fun f7 (x: int): void = (free@ x)
fun f8 (x: dvt): void = case+ x of | @DVT (n) => (fold@ x; fold@ x; free@ x)
fun f9 {l:addr} (pf: !node @ l | p: ptr l): void = case+ !p of | @Cons (n, xs) => (fold@ !p) | _ => ()
fun f10 {l:addr} (pf: !node @ l | p: ptr l): void = (fold@ !p)
fun f11 {l:addr} (pf: !node @ l | p: ptr l): void = (free@ !p)
fun f12 {l:addr} (pf: node @ l | p: ptr l): void = case+ !p of | @Cons (n, xs) => (free@ !p) | _ => ()
fun f13 (): void = let var x: node = Nil () in case+ x of | @Cons (n, xs) => fold@ x | _ => () ; free@ x end
fun f14 (): void = let var x: node = Nil () in fold@ x end
fun f15 (): void = let var x: node = Nil () in free@ x end
fun f16 (): void = let var x: node = Cons (1, Nil ()) in case+ x of | @Cons (n, xs) => (fold@ x; free@ x) | _ => () end
fun f17 (): void = (fold@ (mk ()))
fun f18 (): void = (free@ (mk ()))
fun f19 (): void = (fold@ 3)
fun f20 (x: lrcd): void = (fold@ (x.d))
fun f21 (x: lrcd): void = (free@ (x.d))
fun f22 (x: lrcd): void = (free@ (x))
fun f23 (x: lrcd): void = (fold@ (x))
fun f24 (x: node): void = case+ x of | @Cons (n, xs) => (fold@ (x); free@ x) | _ => ()
fun f25 (x: !node): void = (fold@ x)
fun f26 (x: !node): void = (free@ x)
fn f28 (x: node):<> void = case+ x of | @Cons (n, xs) => (fold@ x; free@ x) | _ => ()
fn f29 (x: node):<> void = case+ x of | @Cons (n, xs) => (free@ x) | _ => ()

(* addr@ *)
fun a1 (): ptr = let var x: int = 1 in addr@ x end
fun a2 (x: int): ptr = addr@ x
fun a3 (): ptr = addr@ (1+2)
fun a4 (): ptr = let var x: rcd = mkr () in addr@ (x.a) end
fun a5 (): ptr = let var x: rcd = mkr () in addr@ (x.zzz) end
fun a6 (): ptr = let var x: @[int][3] = @[int][3](0) in addr@ (x[1]) end
fun a7 {l:addr} (p: ptr l): ptr = addr@ (!p)
fun a8 {l:addr} (pf: !rcd @ l | p: ptr l): ptr = addr@ (p->a)
fun a9 {l:addr} (pf: !rcd @ l | p: ptr l): ptr = addr@ (p->zzz)
fun a10 {l:addr} (p: ptr l): ptr = addr@ (p->a)
fun a11 (x: dvt): ptr = addr@ x
fun a12 (x: lrcd): ptr = addr@ (x.a)
fun a13 {l:addr} (pf: !rcd @ l | p: ptr l): ptr (l+0) = addr@ (!p)
fun a14 (r: ref(rcd)): ptr = addr@ (r->a)
fun a15 (r: ref(int)): ptr = addr@ (!r)
fun a16 (p: int): ptr = addr@ (!p)
fun a17 (): ptr = let var x: int = 1 prval pf = view@ x in addr@ x end
fun a18 (): ptr = let var x: int = 1 prval pf = view@ x in addr@ (x) end
fun a19 {l:addr} (pf: !int @ l | p: ptr l): ptr (l) = addr@ (!p)
fun a20 {l:addr} (p: ptr l): ptr (l) = addr@ (!p)
fun a21 (x: ptr): ptr = addr@ x
fun a22 (): ptr = addr@ (mk ())
fun a23 (): ptr = let val x = 1 in addr@ x end
fun a24 (): ptr = let var x: int = 1 in addr@ (!(addr@ x)) end

(* overloaded dot-symbols and sel *)
fun getx (p: ptr): int = 0
overload .x with getx
fun o1 (p: ptr): int = p.x
fun o2 (p: ptr): int = (p.x).x
fun o3 (x: dvt): int = x.x
fun o4 (x: lrcd): int = x.x
fun o5 (x: rcd): int = x.x
fun o6 (x: @(ptr, int)): int = x.0.x
fun o7 (x: @(ptr, int)): int = x.1.x

(* more: temporaries with existential types, indexes, addresses of selections *)
fun mkea (): [n:nat] @[int][n] = $UNSAFE.cast (0)
fun mker (): [n:nat] @{ a= int n, b= int } = $UNSAFE.cast (0)
fun x1 (): int = (mkea ()).[0]
fun x2 (): int = (mker ()).a
fun x3 (): int = (mker ()).zzz
fun x4 (x: @[int][3]): int = x.[0]
fun x5 (x: @[dvt][3]): dvt = x.[0]
fun x6 (x: @[dvt][3]): int = (x.[0]; x.[1]; 1)
fun x7 (x: @[int][3]): int = x.[5]
fun x8 (x: @[int][3]): int = x.[0].a
fun x9 (x: @[lrcd][3]): int = x.[0].a
fun x10 (x: @[lrcd][3]): dvt = x.[0].d
fun x11 (x: @(dvt, int)): int = x.0.a
fun x12 (): ptr = addr@ ((mkr ()).a)
fun x13 (x: rcd): ptr = addr@ (x.a)
fun x14 (): ptr = let var x: rcd2 = mkr2 () in addr@ (x.r.a) end
fun x15 {l:addr} (pf: !rcd2 @ l | p: ptr l): ptr = addr@ (p->r.a)
fun x16 {l:addr} (pf: !rcd2 @ l | p: ptr l): ptr = addr@ ((!p).r.a)
fun x17 (): ptr = let var x: rcd2 = mkr2 () in addr@ (x.r) end
fun x18 {l:addr} (pf: !rcd2 @ l | p: ptr l): ptr = addr@ (p->r)
fun x19 (r: ref(rcd2)): ptr = addr@ (r->r.a)
fun x20 (): ptr = let var x: dvt = mk () in addr@ x end
fun x21 (): ptr = let var x: lrcd = mklr () in addr@ (x.d) end
fun x22 (): ptr = let var x: lrcd = mklr () val d = x.d in addr@ (x.d) end
fun x23 (): ptr = let var x: lrcd = mklr () val d = x.d in addr@ x end
fun x24 (): ptr = let var x: lrcd = mklr () prval pf = view@ x in addr@ x end
fun x25 (): ptr = let var x: lrcd = mklr () prval pf = view@ x in addr@ (x.a) end
