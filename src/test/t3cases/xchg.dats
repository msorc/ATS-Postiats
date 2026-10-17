(* exchange :=: with variables, pointers, references, arrays, labels, linear parts and all the error paths *)
#include "share/atspre_staload.hats"

typedef rcd = @{ a= int, b= bool }
typedef rcd2 = @{ r= rcd, c= int }
datavtype dvt = DVT of (int)
fun free_dvt (x: dvt): void = let val+ ~DVT _ = x in end
overload free with free_dvt
vtypedef lrcd = @{ a= int, d= dvt }

(* no view *)
fun e1 (p: ptr, y: int): void = let var x: int = y in !p :=: x end
fun e2 (p: ptr, y: int): void = let var x: int = y in x :=: !p end
fun e3 {l:addr} (p: ptr l): void = let var x: int = 1 in !p :=: x end
fun e4 {l:addr} (p: ptr l): void = let var x: int = 1 in x :=: !p end
fun e5 {l:addr} (p: ptr l): void = let var x: int = 1 in p->a :=: x end
fun e6 {l:addr} (p: ptr l): void = let var x: int = 1 in x :=: p->a end
fun e7 {l:addr} (p: ptr l, q: ptr l): void = !p :=: !q

(* with views, labels *)
fun g1 {l:addr} (pf: !rcd @ l | p: ptr l): void = let var x: int = 1 in p->a :=: x end
fun g2 {l:addr} (pf: !rcd @ l | p: ptr l): void = let var x: int = 1 in x :=: p->a end
fun g3 {l:addr} (pf: !rcd @ l | p: ptr l): void = let var x: bool = true in x :=: p->a end
fun g4 {l:addr} (pf: !rcd @ l | p: ptr l): void = let var x: bool = true in p->a :=: x end
fun g5 {l:addr} (pf: !rcd @ l | p: ptr l): void = let var x: bool = true in p->b :=: x end
fun g6 {l:addr} (pf: !rcd @ l | p: ptr l): void = let var x: bool = true in p->zzz :=: x end
fun g7 {l:addr} (pf: !rcd @ l | p: ptr l): void = let var x: bool = true in x :=: p->zzz end
fun g8 {l:addr} (pf: !rcd2 @ l | p: ptr l): void = let var x: int = 1 in p->r.a :=: x end
fun g9 {l:addr} (pf: !rcd2 @ l | p: ptr l): void = let var x: int = 1 in x :=: p->r.a end
fun g10 {l:addr} (pf: !rcd2 @ l | p: ptr l): void = let var x: int = 1 in x :=: p->c.d end
fun g11 {l:addr} (pf: !int @ l | p: ptr l): void = let var x: int = 1 in x :=: p->c end
fun g12 {l:addr} (pf: !int @ l | p: ptr l): void = let var x: int = 1 in p->c :=: x end
fun g13 {l:addr} (pf: !rcd @ l | p: ptr l, q: ptr): void = let var x: int = 1 in p->a :=: q->a end
fun g14 {l:addr} (pf: !rcd @ l | p: ptr l, q: ptr): void = let var x: int = 1 in q->a :=: p->a end
fun g15 {l:addr} (pf: !int @ l | p: ptr l, y: int): void = !p :=: y
fun g16 {l:addr} (pf: !int @ l | p: ptr l): void = !p :=: 3
fun g17 {l:addr} (pf: !int @ l | p: ptr l, y: bool): void = !p :=: y
fun g18 {l:addr} (pf: !int @ l | p: ptr l): void = let var x: bool = true in !p :=: x end
fun g19 {l:addr} (pf: !int @ l | p: ptr l): void = let var x: bool = true in x :=: !p end

(* arrays *)
fun a1 (): int = let
  var a = @[int][3](0)
  var x: int = 5
  val () = a[1] :=: x
in x end
fun a2 {l:addr} (pf: !(@[int][3]) @ l | p: ptr l): void = let var x: int = 5 in p->[1] :=: x end
fun a3 {l:addr} (pf: !(@[int][3]) @ l | p: ptr l): void = let var x: int = 5 in x :=: p->[1] end
fun a4 {l:addr} (pf: !(@[int][3]) @ l | p: ptr l): void = let var x: int = 5 in p->[1,2] :=: x end
fun a5 {l:addr} (pf: !(@[int][3]) @ l | p: ptr l): void = let var x: int = 5 in p->[true] :=: x end
fun a6 {l:addr} (pf: !int @ l | p: ptr l): void = let var x: int = 5 in p->[1] :=: x end
fun a7 {l:addr} (pf: !int @ l | p: ptr l): void = let var x: int = 5 in x :=: p->[1] end
fun a8 {l:addr} (pf: !(@[dvt][3]) @ l | p: ptr l): void = let var x: dvt = DVT 1 in p->[1] :=: x end
fun a9 {l:addr} (pf: !(@[dvt][3]) @ l | p: ptr l): void = let var x: dvt = DVT 1 in x :=: p->[1] end
fun a10 (): void = let
  var a = @[int][3](0)
  var b = @[int][3](0)
  val () = a[1] :=: b[2]
in end
fun a11 (): void = let
  var a = @[int][3](0)
  var x: bool = true
  val () = a[1] :=: x
in end
fun a12 (): void = let
  var a = @[int][3](0)
  var x: bool = true
  val () = x :=: a[1]
in end
fun a13 (n: int): void = let
  var a = @[int][3](0)
  val () = a[n] :=: a[0]
in end
fun a14 {l:addr} (pf: !(@[rcd][3]) @ l | p: ptr l): void = let var x: int = 5 in p->[1].a :=: x end
fun a15 {l:addr} (pf: !(@[rcd][3]) @ l | p: ptr l): void = let var x: int = 5 in x :=: p->[1].a end
fun a16 {l:addr} (pf: !(@[rcd][3]) @ l | p: ptr l): void = let var x: bool = true in p->[1].a :=: x end

(* linear parts *)
fun l1 {l:addr} (pf: !lrcd @ l | p: ptr l): void = let var x: int = 1 in p->a :=: x end
fun l2 {l:addr} (pf: !lrcd @ l | p: ptr l): void = let var x: dvt = DVT 2 in p->d :=: x; free x end
fun l3 {l:addr} (pf: !lrcd @ l | p: ptr l): void = let var x: dvt = DVT 2 in x :=: p->d; free x end
fun l4 (r: ref(dvt)): void = let var x: dvt = DVT 2 in !r :=: x; free x end
fun l5 (r: ref(int)): void = let var x: int = 2 in !r :=: x end
fun l6 (r: ref(int)): void = let var x: int = 2 in x :=: !r end
fun l7 (r: ref(rcd)): void = let var x: int = 2 in r->a :=: x end
fun l8 (r: ref(rcd)): void = let var x: int = 2 in x :=: r->a end
fun l9 (r: ref(rcd)): void = let var x: bool = true in x :=: r->a end
fun l10 (r: ref(rcd)): void = let var x: bool = true in r->a :=: x end
fun l11 (r: ref(rcd)): void = let var x: bool = true in r->zzz :=: x end
fun l12 (r: ref(@[int][3])): void = let var x: int = 2 in r->[1] :=: x end
fun l13 (r: ref(int), s: ref(int)): void = !r :=: !s
fun l14 (r: ref(int), s: ref(bool)): void = !r :=: !s
fun l15 (r: ref(int), s: int): void = !r :=: !s
fun l16 (r: ref(int), s: int): void = !s :=: !r
fun l17 (r: ref(int), s: ptr): void = !r :=: !s
fun l18 (r: ref(int), s: ptr): void = !s :=: !r
fun l19 (r: ref(int)): void = !r :=: !r
fun l20 (r: ref(int)): void = !r :=: 1
fun l21 (r: ref(int), s: int): void = s->a :=: !r
fun l22 (s: dvt): void = let var x: int = 1 in s->a :=: x end
fun l23 (s: dvt): void = let var x: int = 1 in x :=: s->a end

(* pure and ghost-like contexts *)
fn w1 {l:addr} (pf: !int @ l | p: ptr l):<> void = let var x: int = 1 in !p :=: x end
fn w2 {l:addr} (pf: !int @ l | p: ptr l):<> void = let var x: int = 1 in x :=: !p end
fn w3 (r: ref(int)):<> void = let var x: int = 1 in !r :=: x end
fn w4 (r: ref(int)):<> void = let var x: int = 1 in x :=: !r end
fn w5 {l:addr} (pf: !int @ l | p: ptr l):<!wrt> void = let var x: int = 1 in !p :=: x end
fn w6 (r: ref(int)):<!ref> void = let var x: int = 1 in !r :=: x end
fn w7 (r: ref(int)):<!ref> void = let var x: int = 1 in x :=: !r end
fn w8 (): void = let var x: int = 1 var y: int = 2 in x :=: y end
fn w9 ():<> void = let var x: int = 1 var y: int = 2 in x :=: y end

(* left side of other kinds *)
fun n1 (x: dvt): void = let var y: dvt = DVT 1 in x :=: y; free y end
fun n2 (x: int): void = let var y: int = 1 in x :=: y end
fun n3 (): void = let var y: int = 1 in (1+2) :=: y end
fun n4 (): void = let var y: int = 1 in y :=: (1+2) end
fun n5 (): void = let var x: int = 1 prval pf = view@ x in (view@ x) :=: x end
fun n6 (): void = let var x: int = 1 var y: int = 2 in x :=: (view@ y) end
fun n7 (x: dvt): void = let var y: int = 1 prval pf = view@ x in free x end
fun n8 (): void = let var x: int = 1 prval pf = view@ x in (view@ x) :=: (view@ x) end
