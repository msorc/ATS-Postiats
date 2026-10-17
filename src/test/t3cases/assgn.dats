(* assignment := : linear variables (re-initialization, selection), pointers without views, boxed records (sharing), references, wrt effects, overloaded dot-symbols *)
#include "share/atspre_staload.hats"

typedef rcd = @{ a= int, b= bool }
typedef brec = '{ a= int, b= bool }
datavtype dvt = DVT of (int)
fun free_dvt (x: dvt): void = let val+ ~DVT _ = x in end
overload free with free_dvt
vtypedef lrcd = @{ a= int, d= dvt }
vtypedef lrcd2 = @{ r= lrcd, c= int }

(* linear variables *)
fun l1 (): void = let
  val x = DVT 1
  val () = free x
  val () = x := DVT 2
in free x end

fun l2 (): void = let
  val x = DVT 1
  val () = x := DVT 2
in free x end

fun l3 (x: dvt): void = let
  val () = x := DVT 2
in free x end

fun l4 (): void = let
  val x = DVT 1
  val () = free x
  val () = x := 3
in free x end

fun l5 (): void = let
  val x = DVT 1
  val () = free x
  val () = x := DVT 2
  val () = x := DVT 3
in free x end

fun l6 (): void = let
  val x = DVT 1
  val () = free x
  val () = x := DVT 2
in end

(* linear flat tuples/records with selection *)
fun s1 (): void = let
  val x = @(DVT 1, 2)
  val () = x.1 := 3
  val+ ~DVT n = x.0
in end

fun s2 (): void = let
  val x = @(DVT 1, 2)
  val () = x.0 := DVT 3
in let val+ ~DVT n = x.0 in end end

fun s3 (): void = let
  val x = @(DVT 1, 2)
  val () = x.zzz := 3
in let val+ ~DVT n = x.0 in end end

fun s4 (x: lrcd): void = let
  val () = x.a := 3
in let val+ ~DVT n = x.d in end end

fun s5 (x: lrcd2): void = let
  val () = x.r.a := 3
in let val+ ~DVT n = x.r.d in end end

fun s6 (): void = let
  prval pf = @(unit_p(), unit_v())
  prval () = pf.0 := unit_p()
  prval unit_v() = pf.1
in end

fun s7 (): void = let
  prval pf = @(unit_p(), unit_v())
  prval () = pf.1 := unit_v()
  prval unit_v() = pf.1
in end

fun s8 (): void = let
  prval pf = @(unit_p(), unit_v())
  prval () = pf.2 := unit_v()
  prval unit_v() = pf.1
in end

(* a local variable and the view taken away *)
fun v1 (): int = let
  var x: int = 1
  prval pf = view@ x
  val () = x := 2
  prval () = view@ x := pf
in x end

fun v2 (): int = let
  var r: rcd = @{ a= 1, b= true }
  prval pf = view@ r
  val () = r.a := 2
  prval () = view@ r := pf
in r.a end

fun v3 (): int = let
  var r: rcd = @{ a= 1, b= true }
  val () = r.a := true
  val () = r.zzz := 2
in r.a end

(* pointers *)
fun p1 {l:addr} (p: ptr l): void = !p := 3
fun p2 (p: ptr): void = !p := 3
fun p3 {l:addr} (p: ptr l): void = p->a := 3
fun p4 {l:addr} (pf: !int @ l | p: ptr l): void = !p := true
fun p5 {l:addr} (pf: !rcd @ l | p: ptr l): void = p->a := true
fun p6 {l:addr} (pf: !rcd @ l | p: ptr l): void = p->zzz := true
fun p7 {l:addr} (pf: !dvt @ l | p: ptr l): void = !p := DVT 1
fun p8 {l:addr} (pf: !lrcd @ l | p: ptr l): void = p->d := DVT 1
fun p9 {l:addr} (pf: !lrcd @ l | p: ptr l): void = p->a := 1
fun p10 {l:addr} (pf: dvt @ l | p: ptr l): (dvt? @ l | void) = let val+ ~DVT n = !p in end
fun p11 {l:addr} (pf: !brec @ l | p: ptr l): void = p->a := 3
fun p12 {l:addr} (pf: !brec @ l | p: ptr l): void = (!p).a := 3
fun p13 {l:addr} (pf: !int @ l | p: ptr l): void = p->[0] := 3
fun p14 {l:addr} (pf: !(@[int][4]) @ l | p: ptr l): void = p->[0] := 3
fun p15 {l:addr} (pf: !(@[int][4]) @ l | p: ptr l): void = p->[0] := true
fun p16 {l:addr} (pf: !(@[int][4]) @ l | p: ptr l): void = p->[0,1] := 3
fun p17 {l:addr} (pf: !(@[dvt][4]) @ l | p: ptr l): void = p->[0] := DVT 1
fun p18 {l:addr} (pf: !(@[rcd][4]) @ l | p: ptr l): void = p->[0].a := 4
fun p19 (x: int): void = !x := 3
fun p20 (x: int): void = x->a := 3
fun p21 (x: int): void = x->[0] := 3

(* references *)
fn r1 (r: ref(int)):<!ref> void = !r := 3
fn r2 (r: ref(int)):<> void = !r := 3
fn r3 (r: ref(int)): void = !r := true
fn r4 (r: ref(brec)): void = r->a := 3
fn r5 (r: ref(brec)): void = (!r).a := 3
fn r6 (r: ref(rcd)): void = r->a := 3
fn r7 (r: ref(rcd)): void = r->zzz := 3
fn r8 (r: ref(dvt)): void = !r := DVT 1
fn r9 (r: ref(lrcd)): void = r->d := DVT 1
fn r10 (r: ref(lrcd)): void = r->a := 1
fn r11 (r: ref(@[int][3])): void = r->[0] := 1
fn r12 (r: ref(@[dvt][3])): void = r->[0] := DVT 1
fn r13 (r: ref(@[int][3])): void = r->[0,1] := 1
fn r14 (r: ref(int)): void = r->[0] := 1

(* writing in pure functions *)
fn w1 ():<> int = let var x: int = 1 val () = x := 2 in x end
fn w2 {l:addr} (pf: !int @ l | p: ptr l):<> void = !p := 3
fn w3 {l:addr} (pf: !int @ l | p: ptr l):<!wrt> void = !p := 3
fn w4 (): void = let
  prval pf = unit_p()
  prval () = pf := unit_p()
  prval unit_p() = pf
in end

(* overloaded dot-symbols *)
fun getx (p: ptr): int = 0
fun setx (p: ptr, x: int): void = ()
overload .x with getx
overload .x with setx
fun o1 (p: ptr): void = p.x := 3
fun o2 (p: ptr): int = p.x
fun o3 (p: ptr): void = p.y := 3
fun o4 (p: ptr): void = p.x := true
fun o5 (p: ptr): void = (1+2).x := 3
fun o6 (): void = 3 := 4
fun o7 (p: ptr): void = p := p
fun o8 (): void = let var a = @[int][3](0) in a[1] := 3 end
fun o9 (): void = let var a = @[int][3](0) in a[1] := true end
fun o10 (a: arrayptr(int, 3)): void = a[1] := 3
fun o11 (a: arrayptr(int, 3)): void = a[1] := true
fun o12 (a: arrayptr(int, 3)): void = a[5] := 3
fun o13 (a: arrayptr(int, 3)): int = a[1]
